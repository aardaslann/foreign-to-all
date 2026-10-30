"""Moscow activity direction on authored sets; original choices/rewards retained."""
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=128)|extra))


def build():
    plates={}
    for name,floor in [('Stolovaya',656),('Remont',767),('TsoyWall',700),
                       ('Vernisazh',719),('IzmaylovoKremlin',796),
                       ('Churchyard',799),('Gallery',753)]:
        key='ActivityMoscow'+name
        plates[key]=dict(city='moscow',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1672,941],pixel_art=True,floor=point(0,floor)[1],
            lettering=[],motion=[],animation_patches=[])
    plates['ActivityMoscowStolovaya']['lettering']=[
        sign((452,109,818,85),'СУПЫ    ·    САЛАТЫ    ·    ГОРЯЧЕЕ','#34483d','#e5d9b8',31)]
    plates['ActivityMoscowStolovaya']['motion']=[
        dict(kind='steam',rect=[*point(1009,332),*point(32,35)]),
        dict(kind='steam',rect=[*point(1062,336),*point(25,34)])]
    plates['ActivityMoscowRemont']['lettering']=[
        sign((683,219,591,44),'РЕМОНТ  ·  КЛЮЧИ  ·  ЧАСЫ','#526c6b','#e3dbbb',27)]
    plates['ActivityMoscowTsoyWall']['lettering']=[
        sign((548,348,260,97),'ЦОЙ ЖИВ','#00000000','#38332e',42),
        sign((883,378,260,84),'КИНО','#00000000','#9d493b',39),
        sign((674,503,173,44),'ЦОЙ ЖИВ','#00000000','#ead9aa',21),
        sign((908,529,121,35),'КИНО','#00000000','#293e48',19),
        sign((1112,270,202,41),'ЦОЙ ЖИВ','#00000000','#594537',21)]
    plates['ActivityMoscowVernisazh']['lettering']=[
        sign((770,332,207,31),'ВЕРНИСАЖ','#655039','#ead8ae',19)]
    plates['ActivityMoscowVernisazh']['motion']=[
        dict(kind='steam',rect=[*point(1310,339),*point(29,36)])]
    stage={}
    # Counter staff stop at the service edge; customer soles stay on tile.
    tray=shot('ActivityMoscowStolovaya',[person(530,773,'watch')],.5,648,324,full_plate=True)
    choose=shot('ActivityMoscowStolovaya',[person(1016,765,'point'),
        person(1125,512,'offer',clip_row=20)],.66,438,372,prop='food_tray',prop_holder=0)
    cashier=shot('ActivityMoscowStolovaya',[person(1263,753,'watch'),
        person(1464,512,'count',clip_row=20)],.81,348,368,prop='food_tray',prop_holder=0)
    stage['moscow:kitaygorod']={'tray':beat(tray,[{},choose]),
        'pointed':beat(choose),'till':beat(cashier)}
    booth=shot('ActivityMoscowRemont',[person(541,846,'watch'),
        person(976,618,'cut',clip_row=20)],.5,648,324,full_plate=True)
    repair=shot('ActivityMoscowRemont',[person(820,838,'watch'),
        person(976,618,'cut',clip_row=20)],.54,422,465,prop='shoe',prop_holder=1)
    shoe=shot('ActivityMoscowRemont',[person(855,838,'take'),
        person(976,618,'offer',clip_row=20)],.55,422,465,prop='shoe',prop_holder=0)
    stage['moscow:basmanny']={'booth':beat(booth,[{},repair]),
        'watched':beat(repair),'shoe':beat(shoe)}
    stall=shot('ActivityMoscowVernisazh',[person(974,825,'watch'),
        person(1119,625,'offer',clip_row=20)],.5,648,324,full_plate=True)
    bargain=shot('ActivityMoscowVernisazh',[person(974,825,'point'),
        person(1119,625,'offer',clip_row=20)],.63,430,436,prop='badge',prop_holder=1)
    bought=shot('ActivityMoscowVernisazh',[person(982,826,'take'),
        person(1119,625,'hand_over',clip_row=20)],.63,430,436,prop='badge',prop_holder=0)
    walk=shot('ActivityMoscowVernisazh',[person(809,833,'walk'),
        person(1119,625,'wave',clip_row=20)],.56,472,436)
    kremlin=shot('ActivityMoscowIzmaylovoKremlin',[person(908,877,'look_up')],
        .5,648,324,full_plate=True)
    stage['moscow:izmaylovo']={'stalls':beat(stall,[{},bargain]),'half':beat(bargain),
        'paid':beat(bought),'shook':beat(bought),'walked':beat(walk),'kremlin':beat(kremlin)}
    street=shot('MoscowArbat',[actor(966,835,'walk')],.5,648,324,full_plate=True)
    wall=shot('ActivityMoscowTsoyWall',[person(854,798,'watch'),person(1081,786,'reach')],
        .5,648,324,full_plate=True)
    read=shot('ActivityMoscowTsoyWall',[person(809,784,'look_up')],.49,452,370)
    ask=shot('ActivityMoscowTsoyWall',[person(823,798,'watch'),person(1090,793,'wave')],.55,430,407)
    busk=shot('ActivityMoscowTsoyWall',[person(1105,818,'watch'),person(1386,738,'strum')],
        .76,388,413,prop='guitar',prop_holder=1)
    stage['moscow:arbat']={'street':beat(street,[{},wall]),'wall':beat(read),
        'asked':beat(ask),'clean':beat(read),'busker':beat(busk)}
    lane=shot('MoscowZamoskvorechye',[actor(940,833,'walk')],.5,648,324,full_plate=True)
    visitor=person(964,783,'reach',appearance={'cut':'bob','wear':'jacket'})
    gate=shot('ActivityMoscowChurchyard',[person(688,852,'watch'),visitor],
        .5,648,324,full_plate=True,prop='scarf',prop_holder=1)
    threshold=shot('ActivityMoscowChurchyard',[person(776,817,'watch'),visitor],
        .54,438,432,prop='scarf',prop_holder=1)
    correct=shot('ActivityMoscowChurchyard',[person(907,761,'walk'),
        person(1138,674,'stand')],.61,448,390)
    spare=shot('ActivityMoscowChurchyard',[person(1006,720,'take'),
        person(1165,667,'offer',appearance={'build':'elder','cut':'bob','wear':'coat'})],
        .66,362,386,prop='scarf',prop_holder=0)
    gallery=shot('ActivityMoscowGallery',[person(646,824,'look_up')],.5,648,324,full_plate=True)
    stage['moscow:zamoskvorechye']={'lane':beat(lane,[{},gate]),'watched':beat(threshold),
        'correct':beat(correct),'raw':beat(spare),'gallery':beat(gallery)}
    return plates,stage
