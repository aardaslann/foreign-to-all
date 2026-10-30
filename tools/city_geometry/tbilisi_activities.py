"""Tbilisi activity sets preserve the existing branches, costs and learning."""
from .shapes import point, object_
from .tbilisi import sign, transit
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=128)|extra))


def build():
    plates={}
    for name,floor in [('Hall',733),('Bazaar',712),('Domes',752),('Bath',811),
                       ('Yard',825),('Fabrika',756),('Balcony',805)]:
        key='ActivityTbilisi'+name
        plates[key]=dict(city='tbilisi',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1672,940 if name=='Balcony' else 941],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityTbilisiFabrika']['lettering']=[
        sign((691,383,263,50),'ფაბრიკა','#d4bc89','#32474b',32)]
    plates['ActivityTbilisiHall']['animation_patches']=[
        dict(kind='laundry',rect=[*point(1077,286),*point(46,76)]),
        dict(kind='laundry',rect=[*point(1180,286),*point(45,74)])]
    plates['ActivityTbilisiYard']['animation_patches']=[
        dict(kind='laundry',rect=[*point(558,414),*point(43,49)])]
    plates['ActivityTbilisiDomes']['motion']=[
        dict(kind='steam',rect=[*point(1059,324),*point(50,81)]),
        dict(kind='steam',rect=[*point(1400,414),*point(40,58)])]
    plates['ActivityTbilisiBath']['motion']=[
        dict(kind='steam',rect=[*point(339,573),*point(50,64)]),
        dict(kind='steam',rect=[*point(478,573),*point(45,69)])]
    plates['ActivityTbilisiBath']['objects']=[object_('bath_water',718,[(184,695,411,20)],[],
        water=dict(kind='spouts',streams=[
            [point(315,477),point(315,491),point(315,506)],
            [point(1358,477),point(1356,491),point(1356,505)]],
            pool=[*point(186,671),*point(414,29)]))]
    metro=transit()
    metro['city']='tbilisi'
    plates['ActivityTbilisiEscalator']=metro
    stage={}
    door=shot('TbilisiSololaki',[actor(1491,790,'watch')],.85,420,379)
    pass_in=shot('TbilisiSololaki',[actor(1448,794,'watch'),actor(1568,753,'carry')],
                  .85,420,379)
    hall=shot('ActivityTbilisiHall',[person(1012,810,'look_up')],.5,648,324,full_plate=True)
    window=shot('ActivityTbilisiHall',[person(858,793,'look_up'),person(1156,788,'carry')],
                .5,590,324)
    landing=shot('ActivityTbilisiHall',[person(383,446,'look_up')],.39,510,253)
    stage['tbilisi:sololaki']={'door':beat(door,[{},pass_in]),'nobody':beat(pass_in),
        'hall':beat(hall,[{},window]),'landing':beat(landing)}
    cheese=shot('ActivityTbilisiBazaar',[person(620,794,'watch'),
        person(735,620,'cut',clip_row=17)],.43,500,396)
    sample=shot('ActivityTbilisiBazaar',[person(668,782,'take'),
        person(758,620,'offer',clip_row=17)],.45,365,420,prop='cheese',prop_holder=0)
    buy=shot('ActivityTbilisiBazaar',[person(668,782,'take'),
        person(758,620,'cut',clip_row=17)],.45,365,420,prop='parcel',prop_holder=0)
    strings=shot('ActivityTbilisiBazaar',[person(1105,783,'look_up'),
        person(1295,786,'eat')],.72,520,381,prop='churchkhela',prop_holder=1)
    taste=shot('ActivityTbilisiBazaar',[person(1123,789,'eat'),
        person(1310,786,'watch')],.72,408,431,prop='churchkhela',prop_holder=0)
    stage['tbilisi:dezerter']={'cheese':beat(cheese,[{},sample]),
        'bought':beat(buy),'candles':beat(strings,[{}]),'tried':beat(taste)}
    domes=shot('ActivityTbilisiDomes',[person(687,849,'watch')],.5,648,324,full_plate=True)
    inside=shot('ActivityTbilisiBath',[person(865,839,'watch'),person(1468,848,'stand')],
                .5,648,324,full_plate=True)
    scrub=shot('ActivityTbilisiBath',[person(1084,685,'sit',seated=True),
        person(948,752,'scrub')],.67,397,389)
    impress=shot('ActivityTbilisiBath',[person(1084,685,'wave',seated=True),
        person(948,752,'offer')],.67,397,389)
    flinch=shot('ActivityTbilisiBath',[person(1084,685,'recoil',seated=True),
        person(948,752,'watch')],.67,397,389)
    soak=shot('ActivityTbilisiBath',[person(398,670,'swim',world_height=115,clip_row=16)],
              .28,422,376,plate_swimming=True)
    stage['tbilisi:avlabari']={'domes':beat(domes,[{},scrub]),'look':beat(domes),
        'inside':beat(inside),'kisi':beat(scrub),'react':beat(impress),
        'flinch':beat(flinch),'soak':beat(soak)}
    avenue=shot('TbilisiSaburtalo',[actor(956,839,'walk')],.5,648,324,full_plate=True)
    men=[person(816,694,'count',seated=True,clip_row=17,z=.1),
         person(586,751,'sit',seated=True,z=.4),
         person(1103,751,'count',seated=True,z=.4),
         person(835,828,'sit',seated=True,z=.8)]
    yard=shot('ActivityTbilisiYard',[person(1338,856,'watch'),*men],.5,648,324,full_plate=True)
    greet=shot('ActivityTbilisiYard',[person(1338,856,'wave'),*men],.57,496,414)
    through=shot('ActivityTbilisiYard',[person(1316,858,'walk'),
        *[dict(m,act='watch') for m in men]],.57,496,414)
    escalator=shot('ActivityTbilisiEscalator',[actor(762,557,'stand',world_height=68)],
                   .5,530,320)
    stage['tbilisi:saburtalo']={'avenue':beat(avenue,[{},yard]),'yard':beat(yard),
        'nodded':beat(greet),'through':beat(through),'metro':beat(escalator)}
    factory=shot('ActivityTbilisiFabrika',[person(775,812,'watch'),
        person(1455,699,'sit',seated=True),person(1323,669,'sit',seated=True),
        person(931,793,'walk')],.5,648,324,full_plate=True)
    sat=shot('ActivityTbilisiFabrika',[person(343,721,'sit',seated=True),
        person(169,703,'sit',seated=True),person(655,791,'walk')],.30,412,425)
    balcony=shot('ActivityTbilisiBalcony',[person(950,849,'look_up')],
                 .5,648,324,full_plate=True)
    brace=shot('ActivityTbilisiBalcony',[person(1082,837,'watch')],.70,401,411)
    stage['tbilisi:chugureti']={'yard':beat(factory,[{},balcony]),'sat':beat(sat),
        'balcony':beat(balcony),'close':beat(brace)}
    return plates,stage

