"""Zürich's five activities, staged on the pictured floor and furniture."""
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=128)|extra))


def build():
    plates={}
    for name,floor in [('Kiosk',650),('Freitag',763),('Badi',752),('Garden',729),
                       ('MFOPark',715),('MFOUpper',677),('WestRoof',714)]:
        key='ActivityZurich'+name
        plates[key]=dict(city='zurich',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1672,941],pixel_art=True,floor=point(0,floor)[1],
            lettering=[],motion=[],animation_patches=[])
    plates['ActivityZurichKiosk']['lettering']=[
        sign((788,268,414,56),'DÖNER KEBAB','#501e25','#e7d6b8',31),
        sign((1245,264,307,60),'LEBENSMITTEL','#153d3b','#e7d6b8',25)]
    plates['ActivityZurichKiosk']['motion']=[dict(kind='steam',rect=[*point(1054,493),*point(48,42)])]
    plates['ActivityZurichFreitag']['lettering']=[sign((712,691,126,19),'FREITAG','#28312e',size=15)]
    plates['ActivityZurichGarden']['lettering']=[sign((1357,225,47,132),'KUNMING\n↕\nZÜRICH','#e0d6b4','#4e251b',8)]
    plates['ActivityZurichGarden']['motion']=[dict(kind='water',rect=[*point(970,555),*point(214,52)])]
    plates['ActivityZurichBadi']['motion']=[dict(kind='water',rect=[*point(353,555),*point(867,115)])]
    plates['ActivityZurichMFOPark']['lettering']=[sign((1523,636,89,53),'MFO-PARK\nMaschinenfabrik\nOerlikon','#4c3b29','#e1d5b2',8)]
    stage={}
    fountain=shot('ZurichNiederdorf',[actor(1097,724,'watch')],.70,346,410)
    bottle=shot('ZurichNiederdorf',[actor(1070,737,'watch'),actor(1162,624,'take',clip_row=19)],.71,320,410,
                prop='bottle',prop_holder=1)
    drink=shot('ZurichNiederdorf',[actor(1104,723,'drink'),actor(1480,735,'walk')],.73,330,420,
               prop='bottle',prop_holder=0)
    count=shot('ZurichNiederdorf',[actor(860,757,'walk'),actor(1390,744)],.5,500,365)
    stage['zurich:niederdorf']={'spout':beat(fountain,[{},bottle]),
                               'drank':beat(drink),'count':beat(count)}
    street=shot('ActivityZurichKiosk',[person(633,773,'walk')],.52,463,443)
    queue=shot('ActivityZurichKiosk',[person(970,749,'queue'),
        person(1103,640,'offer',clip_row=17),person(764,765,'queue')],.56,365,417)
    buy=shot('ActivityZurichKiosk',[person(989,749,'take'),
        person(1103,640,'cut',clip_row=17)],.59,330,416,prop='kebab',prop_holder=0)
    stroll=shot('ActivityZurichKiosk',[person(682,795,'walk'),person(1293,756,'watch'),
        person(1430,759,'stand')],.51,495,430)
    stage['zurich:langstrasse']={'kiosk':beat(street,[{},queue]),'walked':beat(stroll),'bought':beat(buy)}
    arches=shot('ZurichWest',[actor(813,794,'watch')],.5,648,324,full_plate=True)
    tower=shot('ActivityZurichFreitag',[person(1177,853,'look_up')],.5,648,324,full_plate=True)
    walk=shot('ZurichWest',[actor(708,800,'walk')],.44,460,385)
    roof=shot('ActivityZurichWestRoof',[person(628,850,'watch')],.53,505,373)
    chimney=shot('ActivityZurichWestRoof',[person(696,838,'look_up')],.61,451,326)
    stage['zurich:zurichwest']={'arches':beat(arches,[{},tower]),
        'walked':beat(walk,choices={'tower':dict(staging=tower)}),'tower':beat(roof),'chimney':beat(chimney)}
    deck=shot('ActivityZurichBadi',[person(664,828,'watch')],.5,648,324,full_plate=True)
    swim=shot('ActivityZurichBadi',[person(682,829,'watch'),
        person(1138,629,'swim',world_height=96,clip_row=16)],.56,420,417,plate_swimming=True)
    in_water=shot('ActivityZurichBadi',[person(916,628,'swim',world_height=100,clip_row=16),
        person(1151,635,'swim',world_height=96,clip_row=16)],.61,382,396,plate_swimming=True)
    dry=shot('ActivityZurichBadi',[person(682,832,'stand'),person(906,830,'walk')],.47,363,457)
    garden=shot('ActivityZurichGarden',[person(864,831,'watch')],.5,648,324,full_plate=True)
    stage['zurich:seefeld']={'wall':beat(deck,[{},swim]),'watched':beat(dry),
        'lunch':beat(in_water),'cold':beat(in_water),
        'garden':beat(garden)}
    frame=shot('ActivityZurichMFOPark',[person(843,851,'look_up')],.5,648,324,full_plate=True)
    lunch=shot('ActivityZurichMFOPark',[person(843,838,'walk'),person(303,750,'sit',seated=True)],.45,489,423)
    upper=shot('ActivityZurichMFOUpper',[person(830,828,'watch')],.5,648,324,full_plate=True)
    plaque=shot('ActivityZurichMFOPark',[person(1423,829,'watch')],.83,330,466)
    stage['zurich:oerlikon']={'frame':beat(frame,[{},lunch]),'up':beat(upper),
        'plaque':beat(plaque,choices={'ok':dict(staging=frame)})}
    return plates,stage
