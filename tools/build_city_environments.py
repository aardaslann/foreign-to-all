"""Build reviewed, scene-specific city overrides without touching the first two cities.

Modules opt in individual scenes only after their image and geometry are authored.
The progress register explicitly distinguishes installation from verification.
"""
import importlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/environments'
FIRST_CITIES = {'berlin', 'istanbul'}


def validate_lettering(scene, row):
    # A positional font size in the ink slot passes Python compilation but
    # raises a draw error in Godot. Catch invalid native labels before export.
    for label in row.get('lettering', []):
        assert isinstance(label.get('ink'), str), (scene, label, 'ink must be a color string')
        assert isinstance(label.get('background'), str), (scene, label, 'background must be a color string')
        assert isinstance(label.get('size'), (int, float)) and label['size'] > 0, (scene, label)


def add_fixture_footprints(row):
    """Native ticket terminals need the same ground contact as painted props.

    Their 42px-wide drawing is authored in world coordinates by
    EnvironmentDesign._draw_fitting. Keep the solid base under that drawing,
    leaving the tall screen available for correct front/back overlap.
    """
    for i, fixture in enumerate(row.get('fittings', [])):
        if fixture.get('kind') != 'ticket':
            continue
        x,y = fixture['at']
        row['objects'].append(dict(id=f'native_ticket_base_{i}',sort_y=y,
            footprints=[[round(x-21,2),round(y-9,2),42,9]],polygons=[]))


def main():
    layouts = json.loads((ART / 'layouts.json').read_text(encoding='utf8'))
    cities = sorted({row['city'] for row in layouts.values()} - FIRST_CITIES)
    generated = {}
    activity_plates, activity_staging = {}, {}
    for city in cities:
        module_path = ROOT / 'tools/city_geometry' / (city+'.py')
        if not module_path.exists():
            continue
        module = importlib.import_module('city_geometry.'+city)
        if (ROOT / 'tools/city_geometry' / (city+'_activities.py')).exists():
            activities=importlib.import_module('city_geometry.'+city+'_activities')
            plates, staging=activities.build()
            for key, plate in plates.items():
                validate_lettering(key, plate)
            activity_plates.update(plates)
            activity_staging.update(staging)
        for scene, row in module.build().items():
            validate_lettering(scene, row)
            assert layouts[scene]['city'] == city, (scene, city)
            assert scene not in generated, scene
            assert row.get('objects'), scene+' has no authored object inventory'
            add_fixture_footprints(row)
            ids = [obj['id'] for obj in row['objects']]
            assert len(ids) == len(set(ids)), scene+' has duplicate objects'
            for obj in row['objects']:
                assert obj['footprints'] and all(r[2] > 0 and r[3] > 0 for r in obj['footprints']), (scene, obj['id'])
            texture = ROOT / row['texture'].removeprefix('res://')
            assert texture.is_file(), texture
            generated[scene] = row
    (ART / 'city-gameplay.json').write_text(json.dumps(generated, ensure_ascii=False, indent=2)+'\n', encoding='utf8')
    for filename, data in [('city-activity-plates.json',activity_plates),('city-activity-staging.json',activity_staging)]:
        (ART / filename).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    progress_path = ART / 'city-completion-progress.json'
    progress = json.loads(progress_path.read_text(encoding='utf8')) if progress_path.exists() else {}
    stages = ['art_review', 'geometry_review', 'lettering_review', 'movement_test',
              'interaction_test', 'arrival_test', 'motion_review', 'activity_review']
    for scene, row in layouts.items():
        if row['city'] in FIRST_CITIES:
            continue
        entry = progress.setdefault(scene, {'city': row['city'], **dict.fromkeys(stages, 'pending')})
        entry['installed'] = scene in generated
        entry['geometry_installed'] = scene in generated
        entry['redesigned_art_installed'] = (scene in generated and
            not generated[scene].get('art_pending', False))
    progress_path.write_text(json.dumps(progress, ensure_ascii=False, indent=2)+'\n', encoding='utf8')
    redesigned = sum(row['redesigned_art_installed'] for row in progress.values())
    print(f'{len(generated)} of {len(progress)} remaining-city scenes have authored geometry; '
          f'{redesigned} also have replacement retro art; final review states retained separately')


if __name__ == '__main__':
    main()
