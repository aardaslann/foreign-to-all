"""Build all non-image assets for the last four cities; never call image APIs."""
import json
import re
from pathlib import Path
from city_geometry.remaining_worlds import build as worlds_build
from city_geometry.remaining_activities import build as activities_build
from build_city_environments import validate_lettering

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/environments'
REVIEW = ART / 'review'
CITIES = ['newyork','saopaulo','sydney','toronto']
STYLE = ART / 'scenes/HonoluluWaikiki-retro.png'
COMMON = (
    'Professional richly detailed retro pixel game environment, 1672 by 941, near-side-on '
    '16:9 game camera. Hard stepped 2–4 pixel contours, clustered colour ramps, crisp masonry, '
    'metal and timber, deep but readable shading. Preserve complete plants from pot to crown, '
    'all bicycle wheels and handlebars, leg gaps, railing gaps and translucent glass. '
    'No smooth vector lines, soft airbrush, painterly blur, photoreal textures or glow. '
    'No characters, people, animals, text, numbers, logos or pseudo-writing; all sign panels blank '
    'for native game lettering. Objects must have complete visible bases, believable construction '
    'and usable space around them. The style reference is only a rendering reference, not a source '
    'of architecture or vegetation. Keep one coherent scene, no border or collage. '
)
IDENTITY = {
    'NewYorkLowerEast':'Lower East Side brick tenements, iron fire escapes, laundromat, brownstone stoop and bodega produce displays.',
    'NewYorkHarlem':'Harlem brownstone row, carved lintels, coherent full stoops, front areaway rails and mature street trees.',
    'NewYorkWilliamsburg':'Brooklyn low brick workshops, café and bridge trusses; complete prominent wooden rooftop water tank, hoops and maintenance ladder.',
    'NewYorkJacksonHeights':'Roosevelt Avenue under riveted green elevated steel, silver 7 train and South Asian/Latin American food shops. Train must stay entirely in the top y0–121 strip.',
    'SaoPauloLiberdade':'Liberdade red suzuranto lamps, Japanese-Brazilian shops and São Paulo black-and-white mosaic pavement. Make left shop doorway an actual small hotel entry; bookshop-side door an exchange entry.',
    'SaoPauloBixiga':'Bixiga low stucco houses, tiled roofs, small balconies, bakery, repair shop and mixed neighbourhood uses; local mosaic paving.',
    'SaoPauloMercadao':'Mercado Municipal monumental cream-and-ochre hall, high arched windows, glazed market bays and working produce/loading frontage.',
    'SaoPauloPaulista':'Avenida Paulista skyline and MASP, red structural piers lifting the glass museum clear of the open public space. Museum is the principal architectural focus. Keep subway stair approach open.',
    'SaoPauloVilaMadalena':'Vila Madalena/Beco do Batman, vividly painted independent murals, low terracotta-roof houses, café, complete bicycle and cobbled pavement.',
    'SydneyCircularQuay':'Circular Quay with steel Harbour Bridge left and recognisable Opera House shells right, harbour ferry, working green kiosks and sandstone quay. Convert left kiosk/frontage to a believable hotel entrance and right information kiosk to a currency exchange. Neither service may be a floor sign.',
    'SydneyCBD':'Sydney sandstone civic architecture against towers, Sydney Tower in skyline, Town Hall rail entrance, map display, news kiosk and planted street trees.',
    'SydneyNewtown':'King Street painted terrace shops, iron lace balconies, records/café/kebab frontage and independent mural, native Australian street tree.',
    'SydneyBondi':'Bondi cream pavilion, coastal promenade, Norfolk Island pines, complete surfboards, patrol flags and blue ocean. Keep the central stair gap in promenade railing open.',
    'SydneyCabramatta':'Cabramatta Vietnamese/Chinese-Australian shops, Freedom Plaza green-roof gateway with complete stone guardian lions, produce boxes and broad usable footpath.',
    'TorontoDowntown':'Downtown Toronto masonry storefronts and glass skyline with CN Tower, real hotel and exchange doors, red TTC glass shelter with clear panes and street furniture.',
    'TorontoKensington':'Kensington Market converted Victorian gabled houses, colourful timber porches, produce stalls, secondhand clothes and neighbourhood murals.',
    'TorontoGerrard':'Gerrard India Bazaar low red-brick shops with sari fabric displays, jewellery and groceries, full glass TTC shelter.',
    'TorontoDistillery':'Distillery District preserved red-brick industrial buildings, tall arched black iron windows, pedestrian cobbles, timber barrels on a wheeled cart and planted boxes.',
    'TorontoScarborough':'Scarborough neighbourhood strip mall: bakery, family grocer and pharmacy, blue glass bus shelter, bicycle parking and concrete planted beds; towers and trees behind.',
}
ROOM = {
    'Hotel':'Preserve the pictured lobby layout, reception joinery and lamp details, seating, complete luggage handles and planter foliage. Keep a real exit and clear queue at reception.',
    'Exchange':'Preserve the pictured exchange office or frontage, transparent teller glazing, actual counter, chairs and open floor. Blank fascia and rate board. Do not bake a clerk or numerical rates.',
    'Transit':'Preserve local station architecture, its actual stair/exit, ticket equipment, platform, complete seats and bins. Isolate train doors from fixed columns so only the doors animate. Keep public approaches visibly clear.',
    'Airport':'Preserve the local terminal structure and existing windows, baggage carousel, seats and trolleys. Include an actual information counter at the reserved coordinates. Leave broad connected aisles to services and ground transport.',
}


def save(path,data):
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8')


def walk(value):
    if isinstance(value,dict):
        yield value
        for child in value.values(): yield from walk(child)
    elif isinstance(value,list):
        for child in value: yield from walk(child)


def validate(worlds,plates,stage):
    layouts=json.loads((ART/'layouts.json').read_text(encoding='utf8'))
    expected={k for k,v in layouts.items() if v['city'] in CITIES}-{ 'NewYorkMidtown' }
    assert set(worlds)==expected, ('missing or unexpected worlds',expected^set(worlds))
    expected_activities={f"{v['city']}:{v['district']}" for v in layouts.values()
                         if v['city'] in CITIES and 'district' in v}-{'newyork:midtown'}
    assert set(stage)==expected_activities, ('activity coverage',expected_activities^set(stage))
    for key,row in worlds.items():
        validate_lettering(key,row)
        source=ROOT/row['texture'].removeprefix('res://')
        assert source.exists(),source
        text=(ROOT/f'scenes/world/{key}.tscn').read_text(encoding='utf8')
        nodes=set(re.findall(r'\[node name="([^"]+)"',text))
        assert set(row['anchors']) <= nodes,(key,'unknown anchor',set(row['anchors'])-nodes)
        ids=[o['id'] for o in row['objects']]
        assert len(ids)==len(set(ids)),(key,'duplicate object')
        assert all(o['footprints'] and all(r[2]>0 and r[3]>0 for r in o['footprints']) for o in row['objects']),key
        for label in row['lettering']:
            assert 'object' not in label or label['object'] in ids,(key,label)
    backgrounds=set(worlds)|set(plates)|{'NewYorkMidtown'}
    for key,beats in stage.items():
        for value in walk(beats):
            if 'bg_scene' in value:
                assert value['bg_scene'] in backgrounds,(key,value['bg_scene'])
                assert value.get('authored_plate') and 'cam_y' in value,(key,'camera missing')
                for person in value.get('cast',[]):
                    assert len(person['world_at'])==2 and person['world_height']>0,(key,person)
                    if 'motion_path' in person:
                        assert person['motion_path']['secs']>0,(key,person)
    for key,row in plates.items():validate_lettering(key,row)


def main():
    worlds=worlds_build();plates,stage=activities_build()
    # Source-layout drafts use the exact old PNG dimensions for honest previews.
    validate(worlds,plates,stage)
    for name,data in [('prepared-worlds.json',worlds),('prepared-activity-plates.json',plates),
                      ('prepared-activity-staging.json',stage)]:save(ART/name,data)
    assets=[]
    for key,row in worlds.items():
        room=next((r for r in ROOM if key.endswith(r)),None)
        identity=IDENTITY.get(key, row['city'].title()+' '+str(room)+'. '+ROOM.get(room,''))
        notes=' Preserve the source composition and object placement. Complete rather than crop the named objects: '+', '.join(o['id'] for o in row['objects'])+'. '
        if room=='Airport':
            obj=next(o for o in row['objects'] if o['id']=='information_counter')
            points=obj['polygons'][0]
            xy=[round(points[0][0]*1672/1152),round(points[0][1]*941/648)]
            size=[round((points[2][0]-points[0][0])*1672/1152),round((points[2][1]-points[0][1])*941/648)]
            notes+=f'Information counter front top-left {xy}, size {size}, on reference canvas. It must be solid cabinetry with clear standing room in front; no duplicate cafe counter substitution. '
        prompt=COMMON+'Use reference 1 as the layout to preserve; reference 2 only as pixel style. '+identity+notes
        assets.append(dict(id=key,city=row['city'],kind='world',prompt=prompt,
            refs=[str(ART/f'scenes/{key}.png'),str(STYLE)],
            status='image_required',alignment='source_layout_prepared_final_art_alignment_required'))
    for key,row in plates.items():
        assets.append(dict(id=key,city=row['city'],kind='activity',
            prompt=COMMON+'Create a dedicated activity set in this city, following this exact spatial design contract: '+row['asset_contract'],
            refs=[str(ART/f"scenes/{row['source_fallback']}.png"),str(STYLE)],
            status='image_required',alignment='designed_coordinate_contract_final_art_alignment_required'))
    from city_geometry.prepared import ready
    for asset in assets:
        row = worlds.get(asset['id'], plates.get(asset['id']))
        if ready(asset['id'], row):
            asset.update(status='installed', alignment='final_art_aligned')
        elif (ART / f"scenes/{asset['id']}-retro.png").exists():
            asset.update(status='alignment_required', alignment='generated_art_requires_alignment')
    save(REVIEW/'remaining-assets.json',assets)
    for city in CITIES:
        save(REVIEW/f'{city}-prepared-art-requests.json',[r for r in assets if r['city']==city])
    save(REVIEW/'remaining-preparation-coverage.json',dict(
        scope='Prepared code and source-layout drafts; not final art or full playthrough approval.',
        worlds=len(worlds),objects=sum(len(v['objects']) for v in worlds.values()),
        activities=len(stage),activity_beats=sum(len(v) for v in stage.values()),activity_sets=len(plates),
        native_signs=sum(len(v['lettering']) for v in worlds.values())+sum(len(v['lettering']) for v in plates.values()),
        image_requests=len(assets),pending_images=sum(a['status']=='image_required' for a in assets),
        installed_assets=sum(a['status']=='installed' for a in assets),
        cities={c:dict(worlds=[k for k,v in worlds.items() if v['city']==c],
        activities=[k for k in stage if k.startswith(c+':')],art_requests=[r['id'] for r in assets if r['city']==c]) for c in CITIES}))
    print(f'Prepared {len(worlds)} worlds, {sum(len(r["objects"]) for r in worlds.values())} objects, '
          f'{len(stage)} activities / {sum(len(v) for v in stage.values())} beats, and {len(assets)} image requests.')


if __name__=='__main__':main()
