"""Activate prepared layouts only when their final art alignment is recorded.

The preparation preview uses source art. A generated image alone must never
activate source-image collision/occlusion coordinates in the live game.
"""
import hashlib
import json
import struct
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'art/environments'


def read(name):
    path = ART / name
    return json.loads(path.read_text(encoding='utf8')) if path.exists() else {}


def fingerprint(row):
    return hashlib.sha256(json.dumps(row, sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def ready(key, row, approvals=None):
    record = (read('review/prepared-art-alignment.json') if approvals is None else approvals).get(key, {})
    path = ART / 'scenes' / (key + '-retro.png')
    return (record.get('layout_sha256') == fingerprint(row) and path.is_file()
            and record.get('art_sha256') == hashlib.sha256(path.read_bytes()).hexdigest())


def world_build(city):
    result = {}
    approvals = read('review/prepared-art-alignment.json')
    for key, source in read('prepared-worlds.json').items():
        if source['city'] != city or not ready(key, source, approvals):
            continue
        row = deepcopy(source)
        row.update(texture=f'res://art/environments/scenes/{key}-retro.png',
                   pixel_art=True, art_pending=False,
                   source=[0,0,*struct.unpack('>II',(ART/f'scenes/{key}-retro.png').read_bytes()[16:24])],
                   alignment_status='final_art_aligned',implementation_stage='replacement_art_and_geometry')
        result[key] = row
    return result


def activity_build(city):
    plates = read('prepared-activity-plates.json')
    worlds = read('prepared-worlds.json')
    live = read('city-gameplay.json')
    approvals = read('review/prepared-art-alignment.json')
    output, staging = {}, {}
    for key, beats in read('prepared-activity-staging.json').items():
        if key.split(':')[0] != city:
            continue
        backgrounds = set()
        def collect(value):
            if isinstance(value, dict):
                if 'bg_scene' in value: backgrounds.add(value['bg_scene'])
                for item in value.values(): collect(item)
            elif isinstance(value, list):
                for item in value: collect(item)
        collect(beats)
        if not all(ready(bg, plates[bg] if bg in plates else worlds[bg], approvals)
                   if bg in plates or bg in worlds else bg in live and not live[bg].get('art_pending', True)
                   for bg in backgrounds):
            continue
        staging[key] = beats
        for bg in backgrounds & plates.keys():
            row = deepcopy(plates[bg])
            row.update(texture=f'res://art/environments/scenes/{bg}-retro.png', pixel_art=True,asset_pending=False,
                       source=[0,0,*struct.unpack('>II',(ART/f'scenes/{bg}-retro.png').read_bytes()[16:24])])
            output[bg] = row
    return output, staging
