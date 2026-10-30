"""Rome activities retain their original choices/rewards on city-specific sets."""
from .shapes import point, sign, object_
from .london_activities import actor, shot, beat
from .rome import trastevere


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=128)|extra))


def build():
    plates={}
    for name,floor in [('Butcher',702),('EsquilinoMarket',754),('GarbatellaCourt',764),
                       ('MontiPiazza',752),('MontiBar',757),('TrastevereSteps',754),('Mattatoio',715)]:
        key='ActivityRome'+name
        plates[key]=dict(city='rome',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1672,941],pixel_art=True,floor=point(0,floor)[1],
            lettering=[],motion=[],animation_patches=[])
    plates['ActivityRomeButcher']['lettering']=[
        sign((758,129,420,67),'MACELLERIA','#ddd0ad','#632e25',31)]
    plates['ActivityRomeEsquilinoMarket']['lettering']=[
        sign((1033,272,316,37),'SPEZIE E LEGUMI','#8e352c',size=23)]
    plates['ActivityRomeMontiBar']['lettering']=[
        sign((800,225,78,82),'AL BANCO\n\nCAFFÈ\nBIBITE','#292b23','#e3d7af',9)]
    plates['ActivityRomeMontiBar']['motion']=[dict(kind='steam',rect=[*point(247,303),*point(30,35)])]
    plates['ActivityRomeMattatoio']['lettering']=[
        sign((1330,527,66,109),'MATTATOIO\n\nARTE\nE CULTURA','#dfddd1','#3d4745',8)]
    plates['ActivityRomeGarbatellaCourt']['animation_patches']=[
        dict(kind='laundry',rect=[*point(784,247),*point(60,71)]),
        dict(kind='laundry',rect=[*point(940,282),*point(61,54)]),
        dict(kind='laundry',rect=[*point(1128,280),*point(70,54)])]
    plates['ActivityRomeMontiPiazza']['objects']=[object_('fountain',748,[(788,680,441,66)],[],
        water=dict(kind='spouts',streams=[
            [point(961,416),point(958,475),point(958,553),point(958,620)],
            [point(1062,416),point(1066,478),point(1066,553),point(1066,620)],
            [point(1012,402),point(1012,374),point(1018,385),point(1018,403)]],
            pool=[*point(835,615),*point(356,12)]))]
    # The learned thumb action changes the direction of the nasone stream.
    nasone=trastevere()
    nasone['city']='rome'
    for obj in nasone['objects']:
        if obj['id']=='nasone':
            obj['water']=dict(kind='spouts',streams=[
                [point(715,637),point(718,598),point(731,590),point(747,611)]],
                pool=[*point(716,720),*point(32,3)])
    plates['ActivityRomeNasoneArc']=nasone
    stage={}
    market=shot('ActivityRomeButcher',[person(564,774,'watch'),person(740,789,'queue'),
        person(937,797,'queue'),person(1131,562,'cut',clip_row=17)],.52,470,398)
    butcher=shot('ActivityRomeButcher',[person(680,769,'point'),
        person(911,562,'cut',clip_row=17)],.55,363,398)
    bought=shot('ActivityRomeButcher',[person(681,773,'take'),
        person(911,562,'hand_over',clip_row=17)],.55,363,398,prop='parcel',prop_holder=0)
    history=shot('ActivityRomeMattatoio',[person(784,819,'look_up'),person(953,817,'watch')],
                 .5,648,324,full_plate=True)
    stage['rome:testaccio']={'counter':beat(market,[{},butcher]),
                             'why':beat(history),'bought':beat(bought)}
    hall=shot('ActivityRomeEsquilinoMarket',[person(618,821,'walk')],.5,648,324,full_plate=True)
    spices=shot('ActivityRomeEsquilinoMarket',[person(813,798,'watch'),
        person(1179,620,'offer',clip_row=17)],.65,388,431)
    queue=shot('ActivityRomeEsquilinoMarket',[person(754,829,'queue'),
        person(944,831,'listen'),person(1125,828,'count')],.57,424,440)
    cone=shot('ActivityRomeEsquilinoMarket',[person(813,798,'take'),
        person(1179,620,'count',clip_row=17)],.65,388,431,prop='spice_cone',prop_holder=0)
    stage['rome:esquilino']={'hall':beat(hall,[{},spices]),'queue':beat(queue),'cone':beat(cone)}
    corner=shot('RomeTrastevere',[actor(812,767,'watch')],.46,338,414)
    child=shot('ActivityRomeNasoneArc',[actor(890,764,'watch'),
        actor(764,722,'drink',world_height=70)],.46,326,412)
    arc=shot('ActivityRomeNasoneArc',[actor(762,712,'drink')],.45,300,402)
    wet=shot('RomeTrastevere',[actor(755,744,'reach')],.45,300,402)
    steps=shot('ActivityRomeTrastevereSteps',[person(755,750,'sit',seated=True),
        person(932,750,'sit',seated=True),person(1071,750,'sit',seated=True)],
        .5,648,324,full_plate=True)
    stage['rome:trastevere']={'corner':beat(corner,[{},child]),'watched':beat(child),
                             'arc':beat(arc),'wet':beat(wet),'steps':beat(steps)}
    piazza=shot('ActivityRomeMontiPiazza',[person(684,830,'watch'),
        person(871,730,'sit',seated=True),person(1024,740,'sit',seated=True),
        person(1180,734,'drink',seated=True),person(1395,811,'stand')],
        .5,648,324,full_plate=True)
    counter=shot('ActivityRomeMontiBar',[person(882,731,'take'),
        person(687,531,'hand_over',clip_row=17)],.45,371,386,prop='bottle',prop_holder=0)
    edge=shot('ActivityRomeMontiPiazza',[person(635,807,'watch'),
        person(938,736,'sit',seated=True),person(1154,735,'drink',seated=True)],.58,472,384)
    outside=shot('ActivityRomeMontiPiazza',[person(827,724,'sit',seated=True),
        person(991,740,'sit',seated=True),person(1154,735,'drink',seated=True)],
        .59,435,401,prop='bottle',prop_holder=0)
    inside=shot('ActivityRomeMontiBar',[person(1290,630,'sit',seated=True),
        person(970,742,'offer')],.73,396,373,prop='bottle',prop_holder=1)
    stage['rome:monti']={'piazza':beat(piazza,[{},counter]),'edge':beat(edge),
                        'outside':beat(outside),'inside':beat(inside)}
    road=shot('ActivityRomeGarbatellaCourt',[person(356,754,'walk')],.5,648,324,full_plate=True)
    woman=person(1366,379,'reach',clip_row=17,world_height=112)
    wait=shot('ActivityRomeGarbatellaCourt',[person(463,790,'look_up'),woman],
              .5,648,324,full_plate=True)
    court=shot('ActivityRomeGarbatellaCourt',[person(534,826,'stand'),
        person(1240,789,'watch',world_height=85),person(1418,808,'watch',world_height=85),
        person(1490,775,'carry')],.54,541,373)
    table=shot('ActivityRomeGarbatellaCourt',[person(738,710,'sit',seated=True),
        person(995,710,'sit',seated=True),person(1218,804,'walk')],.55,400,409)
    presumed=shot('ActivityRomeGarbatellaCourt',[person(738,710,'sit',seated=True),
        person(1400,795,'carry')],.55,485,394)
    welcome=shot('ActivityRomeGarbatellaCourt',[person(534,826,'walk'),
        person(1240,789,'watch',world_height=85)],.5,648,324,full_plate=True)
    stage['rome:garbatella']={'road':beat(road,[{},wait]),'waited':beat(wait),'court':beat(court),
        'welcome':beat(welcome),'table':beat(table),'presumed':beat(presumed),'backed':beat(road)}
    return plates,stage
