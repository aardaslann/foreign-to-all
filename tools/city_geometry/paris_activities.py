"""Paris activities: authored stage geography, furniture contact and calm cuts."""
from copy import deepcopy
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=132)|extra))


def build():
    plates={}
    for name,floor in [('Rosiers',669),('Vosges',721),('Tertre',792),
                       ('Vines',747),('BellevilleView',730),('DefenseAxis',735),('ChampLawn',787)]:
        key='ActivityParis'+name
        plates[key]=dict(city='paris',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1671 if name=='Vosges' else 1672,941],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityParisRosiers']['lettering']=[
        sign((810,265,533,38),'FALAFEL','#153b2e','#ead5a2',26)]
    plates['ActivityParisPortrait']=deepcopy(plates['ActivityParisTertre'])
    plates['ActivityParisPortrait']['animation_patches']=[
        dict(kind='charcoal_portrait',rect=[*point(831,513),*point(97,114)])]
    # Water animates within the actual pictured streams, never across stone.
    plates['ActivityParisVosges']['animation_patches']=[
        dict(kind='water',rect=[*point(1030,481),*point(13,63)]),
        dict(kind='water',rect=[*point(1134,485),*point(13,59)]),
        dict(kind='water',rect=[*point(1069,432),*point(37,38)])]
    stage={}
    rosier_walk=shot('ActivityParisRosiers',[person(648,799,'walk')],.47,400,456)
    queue=shot('ActivityParisRosiers',[person(953,759,'queue'),
        person(1067,610,'offer',clip_row=17),person(777,785,'queue')],.60,315,409)
    greeted=shot('ActivityParisRosiers',[person(987,759,'take'),
        person(1082,610,'offer',clip_row=17)],.61,310,403,prop='falafel',prop_holder=0)
    vosges=shot('ActivityParisVosges',[person(848,803,'watch')],.53,510,385)
    bench=shot('ActivityParisVosges',[person(432,661,'sit',seated=True)],.34,420,432)
    stage['paris:marais']={
        'street':beat(rosier_walk,[{},queue]),'queue':beat(queue),
        'greeted':beat(greeted),'cold':beat(greeted),
        'vosges':beat(vosges,choices={'ok':dict(staging=bench)})}

    approach=shot('ParisMontmartre',[actor(726,799,'look_up')],.50,648,324,full_plate=True)
    artists=shot('ActivityParisTertre',[person(484,803,'watch'),
        person(1043,674,'write',seated=True),person(688,706,'sit',seated=True)],.52,400,447)
    portrait=shot('ActivityParisPortrait',[person(688,706,'sit',seated=True),
        person(1043,674,'write',seated=True)],.51,330,405)
    returned=shot('ActivityParisPortrait',[person(698,812,'take'),
        person(1075,794,'offer',world_height=148)],.51,365,440,prop='portrait',prop_holder=0)
    vines=shot('ActivityParisVines',[person(757,816,'watch')],.48,460,423)
    stage['paris:montmartre']={
        'square':beat(approach,[{},artists]),'pitch':beat(artists),
        'portrait':beat(portrait),'honest':beat(returned),'polite':beat(returned),
        'vines':beat(vines)}

    hill=shot('ParisBelleville',[actor(868,807,'walk')],.55,400,464)
    panorama=shot('ActivityParisBellevilleView',[person(724,804,'watch')],.5,520,357)
    market=shot('ParisBelleville',[actor(608,790,'watch'),actor(464,760,'offer')],.33,330,491)
    purchase=shot('ParisBelleville',[actor(608,790,'take'),actor(464,760,'offer')],.33,330,491,
                  prop='apple',prop_holder=0)
    stage['paris:belleville']={
        'hill':beat(hill,[{},panorama]),'top':beat(panorama),
        'market':beat(market),'tried':beat(purchase),'pointed':beat(purchase)}

    arche=shot('ParisLaDefense',[actor(850,834,'look_up')],.5,648,324,full_plate=True)
    axis=shot('ActivityParisDefenseAxis',[person(700,815,'watch')],.5,530,359)
    stage['paris:ladefense']={
        'deck':beat(arche,[{},arche]),'arche':beat(arche),
        'axis':beat(axis),'why':beat(axis)}

    tower=shot('ActivityParisChampLawn',[person(740,841,'look_up')],.54,648,324,full_plate=True)
    picnic=shot('ActivityParisChampLawn',[person(400,863,'sit',seated=True),
        person(725,857,'sit',seated=True),person(878,847,'sit',seated=True)],.47,440,428)
    seller=shot('ActivityParisChampLawn',[person(779,780,'watch'),person(1002,780,'offer')],.55,360,435,
                prop='tower_charm',prop_holder=1)
    bought=shot('ActivityParisChampLawn',[person(779,780,'take'),person(1002,780,'offer')],.55,360,435,
                prop='tower_charm',prop_holder=0)
    police=shot('ActivityParisChampLawn',[person(472,861,'sit',seated=True),
        person(940,779,'walk',appearance={'wear':'jacket','cut':'crop'}),
        person(1235,779,'walk',appearance={'wear':'jacket','cut':'crop'})],.57,430,431)
    stage['paris:champdemars']={
        'lawn':beat(tower,[{},picnic,seller]),'grass':beat(picnic),
        'police':beat(police),'seller':beat(seller),
        'compare':beat(seller),'deal':beat(bought),'full':beat(bought)}
    return plates,stage
