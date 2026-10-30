"""Dakar's five activities: measured sets, stable cameras, native small props."""
import struct
from copy import deepcopy
from pathlib import Path
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=124,appearance={}) | extra))


def build():
    plates={}
    for name,floor in [('Tailor',666),('ClothShop',718),('Kermel',721),
                       ('OuakamLookout',719),('OuakamPath',681),
                       ('OuakamShore',705),('YoffLanding',666)]:
        key='ActivityDakar'+name
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        plates[key]=dict(city='dakar',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityDakarKermel']['lettering']=[
        sign((678,263,265,31),'MARCHÉ KERMEL','#00000000','#384e47',size=26)]
    plates['ActivityDakarClothShop']['lettering']=[
        sign((1445,388,54,80),'WAX\n6 YARDS','#00000000',size=13)]
    for suffix,bounds in [('OuakamLookout',(286,361,287,49)),
                          ('OuakamPath',(970,330,155,43)),
                          ('OuakamShore',(1111,392,539,151)),
                          ('YoffLanding',(872,355,500,159))]:
        x,y,w,h=bounds
        plates['ActivityDakar'+suffix]['animation_patches']=[dict(kind='water',rect=[*point(x,y),*point(w,h)])]
    plates['ActivityDakarTailorSewing']=deepcopy(plates['ActivityDakarTailor'])
    plates['ActivityDakarTailorSewing']['animation_patches']=[
        dict(kind='sewing_wheel',rect=[*point(1052,467),*point(17,35)])]

    stage={}
    tailor_look={'build':'adult','wear':'openshirt','cut':'crop','face':''}
    woman_look={'build':'adult','wear':'dress','cut':'tied','face':''}
    tailor=person(929,566,'sew',clip_row=20,appearance=tailor_look)
    machine=shot('ActivityDakarTailorSewing',[person(755,790),tailor],.54,570,356)
    customer=shot('ActivityDakarTailorSewing',[person(676,801),tailor,
        person(1184,778,'offer',appearance=woman_look)],.57,534,370,
        prop='wax_cloth',prop_holder=2)
    measure=shot('ActivityDakarTailor',[person(632,813),
        person(789,798,'reach',appearance=tailor_look),
        person(930,795,'watch',appearance=woman_look)],.49,412,424)
    cloth=shot('ActivityDakarTailor',[person(759,791),tailor | {'act':'watch'}],
               .52,440,406,prop='wax_cloth',prop_holder=0)
    handover=shot('ActivityDakarTailor',[person(755,790,'hand_over'),
        person(932,789,'take',appearance=tailor_look)],.51,411,425,prop='wax_cloth')
    stage['dakar:medina']={'machine':beat(machine,[machine,customer]),
        'measure':beat(measure,[measure]),'cloth':beat(cloth),'ordered':beat(handover,[handover])}

    seller=person(1166,546,'offer',clip_row=20,appearance=tailor_look)
    shop=shot('ActivityDakarClothShop',[person(933,791),seller],.63,570,355)
    explain=shot('ActivityDakarClothShop',[person(936,791,'point'),seller],.63,467,402,
                 prop='wax_cloth',prop_holder=1)
    tearing=explain | {'cast':[person(936,791),seller | {'act':'cut'}]}
    bought=shot('ActivityDakarClothShop',[person(1012,806,'take'),seller | {'act':'watch'}],
                .65,466,412,prop='wax_cloth',prop_holder=0)
    stage['dakar:sandaga']={'bolts':beat(shop,[shop,explain]),'why':beat(explain),
                           'six':beat(bought,[tearing])}

    hall=shot('ActivityDakarKermel',[person(776,857,'walk')],.5,648,324,full_plate=True)
    florist=person(1255,823,'wave',appearance=woman_look)
    greeting=shot('ActivityDakarKermel',[person(1042,839),florist],.69,466,414)
    conversation=greeting | {'cast':[person(1042,839,'watch'),florist | {'act':'watch'}]}
    wrapping=greeting | {'cast':[person(1042,839),florist | {'act':'offer'}],
                          'prop':'bouquet','prop_holder':1}
    flowers=greeting | {'cast':[person(1053,839,'take'),florist | {'act':'watch'}],
                         'prop':'bouquet','prop_holder':0}
    square=shot('DakarPlateau',[person(933,806,'look_up')],.5,648,324,full_plate=True)
    stage['dakar:plateau']={'hall':beat(hall,[hall,greeting]),'answered':beat(conversation),
        'back':beat(wrapping),'cut':beat(flowers),'sold':beat(flowers),'square':beat(square)}

    lookout=shot('ActivityDakarOuakamLookout',[person(694,849)],.5,648,324,full_plate=True)
    path=shot('ActivityDakarOuakamPath',[person(697,837,'walk'),
        person(975,807,'carry',appearance=tailor_look),
        person(1265,791,'carry',world_height=110,appearance=woman_look)],
        .5,648,324,full_plate=True,prop='wood_crate',prop_holder=1)
    boy=person(957,824,'carry',world_height=104,
               appearance={'build':'teen','wear':'tee','cut':'crop','face':''})
    down=shot('ActivityDakarOuakamPath',[person(774,834),boy],.52,510,389,
              prop='wood_crate',prop_holder=1)
    carry=shot('ActivityDakarOuakamPath',[person(773,832,'carry'),boy | {'act':'carry'}],
               .52,510,389,prop='shared_crate',prop_holders=[0,1])
    shore=shot('ActivityDakarOuakamShore',[person(763,822)],.5,648,324,full_plate=True)
    surf=shot('ActivityDakarOuakamShore',[person(783,820),
        person(1232,524,'surf',world_height=42,z=.2,kit='surfboard'),
        person(1459,575,'surf',world_height=48,z=.3,kit='surfboard')],
        .5,648,324,full_plate=True)
    stage['dakar:ouakam']={'road':beat(lookout,[lookout,path]),'down':beat(down),
        'carry':beat(carry),'shore':beat(shore),'surf':beat(surf),'stay':beat(lookout)}

    fisherman={'build':'adult','wear':'tee','cut':'crop','face':''}
    beach=shot('ActivityDakarYoffLanding',[person(935,803)],.5,648,324,full_plate=True)
    pullers=[person(x,735,'haul_rope',world_height=110,appearance=fisherman)
             for x in [1030,1176,1322]]
    hauling=shot('ActivityDakarYoffLanding',[person(641,813),*pullers],
        .5,648,324,full_plate=True,prop='hauling_rope',prop_holders=[1,2,3],
        prop_world_from=point(850,564))
    join=hauling | {'cast':[person(896,747,'haul_rope'),*pullers],'prop_holders':[0,1,2,3]}
    stayed=join | {'cast':[p | {'act':'watch'} for p in join['cast']]}
    vendor=person(1514,678,'offer',world_height=116,appearance=woman_look)
    buying=shot('ActivityDakarYoffLanding',[person(1306,756),vendor],.83,432,409,
                prop='wrapped_fish',prop_holder=1)
    paid=buying | {'cast':[person(1315,757,'take'),vendor | {'act':'watch'}],'prop_holder':0}
    stage['dakar:yoff']={'beach':beat(beach,[beach,hauling]),'rope':beat(join),
        'stayed':beat(stayed),'watch':beat(beach),'buy':beat(buying),
        'paid':beat(paid),'haggled':beat(buying)}
    return plates,stage
