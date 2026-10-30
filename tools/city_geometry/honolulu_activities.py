"""Honolulu's five stories staged against measured, stationary pixel sets."""
import struct
from copy import deepcopy
from pathlib import Path
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=124,appearance={},z=y/1000) | extra))


def build():
    plates={}
    for name,floor in [('KuhioBeach',720),('KuhioLineup',720),('LeiStand',674),
                       ('ManoaPorch',702),('ManoaInterior',691),('Mural',741),
                       ('WaimeaLookout',713),('WaimeaSand',712)]:
        key='ActivityHonolulu'+name
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        plates[key]=dict(city='honolulu',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityHonoluluLeiStand']['lettering']=[
        sign((548,177,560,41),'CHINATOWN · LEI','#00000000','#305442',size=30)]
    for name,bounds in [('KuhioBeach',(570,390,1080,121)),
                        ('KuhioLineup',(40,396,1590,469)),
                        ('WaimeaLookout',(711,239,616,203)),
                        ('WaimeaSand',(428,264,1007,245))]:
        x,y,w,h=bounds
        plates['ActivityHonolulu'+name]['animation_patches']=[
            dict(kind='water',rect=[*point(x,y),*point(w,h)])]
    plates['ActivityHonoluluManoaRain']=deepcopy(plates['ActivityHonoluluManoaPorch'])
    plates['ActivityHonoluluManoaRain']['animation_patches']=[
        dict(kind='rain',rect=[*point(200,246),*point(410,390)])]
    stage={}
    elder={'build':'elder','wear':'tee','cut':'crop','face':'','barefoot':True}
    boardman=person(987,833,'carry',appearance=elder,kit='board_carry')
    beach=shot('ActivityHonoluluKuhioBeach',[person(695,845)],.5,648,324,full_plate=True)
    offer=shot('ActivityHonoluluKuhioBeach',[person(721,829),boardman | {'act':'point'}],
               .51,470,404)
    approach=shot('ActivityHonoluluKuhioBeach',[person(721,829),boardman],.51,470,404)
    lineup=shot('ActivityHonoluluKuhioLineup',[
        person(713,743,'swim',clip_row=16,kit='paddle_board',appearance={'barefoot':True}),
        person(959,756,'swim',clip_row=16,kit='paddle_board',appearance=elder)],
        .5,537,383,plate_swimming=True)
    standing=shot('ActivityHonoluluKuhioLineup',[
        person(730,780,'surf',kit='surfboard',clip_row=26,appearance={'barefoot':True}),
        person(961,715,'swim',clip_row=16,kit='paddle_board',appearance=elder)],
        .5,537,383,plate_swimming=True)
    # Small native surfers make the lineup legible without baking people into art.
    distant=[person(x,y,'surf',kit='surfboard',clip_row=26,world_height=28,z=.1,
                     appearance={'build':'adult','wear':'tee','cut':'crop','barefoot':True})
              for x,y in [(884,485),(1117,437),(1287,473),(1473,505)]]
    watch=beach | {'cast':[person(695,845)]+distant}
    paid=offer | {'cast':[person(721,829,'hand_over'),boardman | {'act':'wave'}],
                   'prop':'coin','prop_holder':0}
    stage['honolulu:waikiki']={
        'sand':beat(offer,[watch,approach,offer]),
        'watched':beat(watch),'out':beat(standing,[lineup,lineup]),
        'again':beat(lineup),'paid':beat(paid)}

    seller_look={'build':'adult','wear':'blouse','cut':'tied','face':''}
    seller=person(965,573,'string_lei',clip_row=20,appearance=seller_look)
    stall=shot('ActivityHonoluluLeiStand',[person(733,755),seller],.52,496,369,
               prop='lei',prop_holder=1)
    sale=stall | {'cast':[person(655,750),seller | {'act':'hand_over'},
                          person(1121,751,'carry',appearance={'wear':'tee','cut':'crop','face':''})],
                    'prop_holder':2}
    returned=stall | {'cast':[person(754,751,'offer'),seller | {'act':'take'}]}
    worn=stall | {'cast':[person(754,751,'walk',kit='lei_worn'),seller | {'act':'watch'}],
                   'prop':''}
    stage['honolulu:chinatown']={'stand':beat(stall,[stall,sale]),
        'watched':beat(sale),'gave':beat(returned),'wore':beat(worn)}

    host=person(1063,738,'wave',appearance={'build':'adult','wear':'shirt','cut':'crop','face':'','barefoot':True})
    porch=shot('ActivityHonoluluManoaPorch',[person(930,820),host],.5,648,324,full_plate=True)
    rain=porch | {'bg_scene':'ActivityHonoluluManoaRain','cast':[person(735,840,'recoil')]}
    stopped=porch | {'cast':[person(930,820),host | {'act':'watch'}]}
    doorstep=shot('ActivityHonoluluManoaPorch',[person(946,812),host | {'world_at':point(1089,688)}],
                  .67,408,398)
    family={'build':'elder','wear':'dress','cut':'tied','face':'','barefoot':True}
    interior=shot('ActivityHonoluluManoaInterior',[
        person(799,799,appearance={'barefoot':True}),
        person(1125,797,appearance=family)],.57,516,388)
    shoes=interior | {'cast':[person(799,799),person(1125,797,'look',appearance=family)]}
    stage['honolulu:manoa']={'porch':beat(porch,[rain,stopped,doorstep]),
                            'off':beat(interior),'in':beat(shoes)}

    artist_look={'build':'adult','wear':'tee','cut':'tied','face':''}
    # Feet meet the pictured rung at y553; no walking or reach translation
    # may shift this actor away from the ladder while working.
    artist=person(1117,553,'spray',world_height=108,appearance=artist_look,clip_row=26)
    mural=shot('ActivityHonoluluMural',[person(824,833),artist],.5,648,324,
               full_plate=True,prop='spray_can',prop_holder=1)
    held=shot('ActivityHonoluluMural',[person(1091,795,'hold_ladder'),artist],
               .65,479,382,prop='spray_can',prop_holder=1)
    handover=shot('ActivityHonoluluMural',[person(986,802,'take'),
        person(1231,802,'offer',appearance=artist_look)],.64,431,416,
        prop='spray_can',prop_holder=0)
    asked=mural | {'cast':[person(891,812,'wave'),artist]}
    stage['honolulu:kakaako']={
        'wall':beat(mural,[mural,mural],choices={'hold':{'staging':held}}),
        'held':beat(handover),'asked':beat(asked,choices={'hold':{'staging':held}}),
        'looked':beat(mural)}

    spectators=[person(650,774),person(895,773,appearance={'build':'adult','wear':'tee','cut':'crop','face':''}),
                person(1144,775,appearance={'build':'adult','wear':'shirt','cut':'bob','face':''})]
    lookout=shot('ActivityHonoluluWaimeaLookout',spectators,.5,648,324,full_plate=True)
    wave=lookout | {'cast':[spectators[0] | {'act':'recoil'},*spectators[1:]]}
    surfers=[person(x,y,'surf',world_height=24,kit='surfboard',clip_row=26,z=.1,
                     appearance={'build':'adult','wear':'tee','cut':'crop','barefoot':True})
        for x,y in [(694,306),(760,299),(826,310),(889,312),(1047,353),(1118,367),(1212,375),(1321,385)]]
    watched=lookout | {'cast':spectators+surfers}
    sand=shot('ActivityHonoluluWaimeaSand',[person(701,814,'recoil'),
        person(979,847,'wave',appearance={'build':'adult','wear':'tee','cut':'crop','face':''})],
        .5,648,324,full_plate=True)
    ice=lookout | {'cast':[spectators[0] | {'act':'eat'},*spectators[1:]],'prop':'shave_ice','prop_holder':0}
    stage['honolulu:northshore']={'road':beat(lookout,[lookout,wave]),
        'watched':beat(watched),'sand':beat(sand),'ice':beat(ice)}
    return plates,stage
