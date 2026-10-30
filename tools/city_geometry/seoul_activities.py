"""Five Seoul activities on measured sets, retaining original story branches.

World-space staging keeps soles on paving and seats. Counter staff are clipped
at the actual service edge, and only machinery/food details animate on plates.
"""
from .shapes import point
from .seoul import sign
from .london_activities import actor,shot,beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=128)|extra))


def build():
    singer_look={'build':'adult','cut':'long','wear':'blazer',
        'pal':{'C':'#46657c','D':'#354c60','O':'#273340','R':'#33272a'}}
    plates={}
    for name,floor in [('Lathe',710),('EuljiroNight',741),('Gwangjang',727),
                       ('MangwonJeon',735),('HongdaeBusking',704),
                       ('ShoeWorkshop',713),('FactoryCafe',738)]:
        key='ActivitySeoul'+name
        plates[key]=dict(city='seoul',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,1672,941],pixel_art=True,floor=point(0,floor)[1],
            lettering=[],motion=[],animation_patches=[])
    plates['ActivitySeoulLathe']['lettering']=[
        sign((748,177,670,64),'정밀가공 · 금속','#efdfc3','#293e49',size=34),
        sign((204,262,314,29),'을지공업사','#254967',size=21)]
    plates['ActivitySeoulLathe']['animation_patches']=[
        dict(kind='rotor_marks',rect=[*point(981,495),*point(14,38)],speed=8.0)]
    plates['ActivitySeoulEuljiroNight']['lettering']=[
        sign((677,184,343,48),'정밀공업','#d6c5ac','#2c3d45',size=27),
        sign((1373,224,204,39),'노가리 · 맥주','#263c51',size=23)]
    plates['ActivitySeoulGwangjang']['lettering']=[
        sign((852,113,542,63),'광장시장 · 빈대떡','#e5d7ba','#25463f',size=34)]
    plates['ActivitySeoulGwangjang']['motion']=[
        dict(kind='steam',rect=[*point(848,442),*point(35,62)]),
        dict(kind='steam',rect=[*point(983,439),*point(30,62)])]
    plates['ActivitySeoulGwangjang']['animation_patches']=[
        dict(kind='rotor_marks',rect=[*point(1466,411),*point(111,18)],speed=.85)]
    plates['ActivitySeoulMangwonJeon']['lettering']=[
        sign((826,223,494,61),'망원시장 · 전','#eddfbf','#2f483d',size=34)]
    plates['ActivitySeoulMangwonJeon']['motion']=[
        dict(kind='steam',rect=[*point(830,449),*point(27,54)]),
        dict(kind='steam',rect=[*point(1015,452),*point(23,49)])]
    plates['ActivitySeoulHongdaeBusking']['lettering']=[
        sign((243,226,319,35),'홍대 음악','#254967',size=27),
        sign((971,222,406,46),'커피 · 차','#e8d5b4','#354a44',size=28),
        sign((746,337,40,54),'오늘\nLIVE','#ce5167',size=11)]
    plates['ActivitySeoulShoeWorkshop']['lettering']=[
        sign((704,89,851,36),'성수 수제화','#253a49',size=30),
        sign((1324,322,114,43),'구두수선','#dcc7a3','#354339',size=20)]
    plates['ActivitySeoulFactoryCafe']['lettering']=[
        sign((1077,309,225,35),'공장 커피','#d7ba87','#324740',size=24),
        sign((1450,307,91,58),'커피\n차','#204d43',size=17)]
    plates['ActivitySeoulFactoryCafe']['motion']=[
        dict(kind='steam',rect=[*point(193,548),*point(28,38)])]
    stage={}

    # Euljiro: a stationary workshop, then the same kind of lane after closing.
    day=shot('SeoulEuljiro',[actor(861,843)],.5,648,324,full_plate=True)
    worker=person(1115,600,'cut',clip_row=20,appearance={'cut':'crop','wear':'shopcoat'})
    lathe=shot('ActivitySeoulLathe',[person(796,811),worker],.62,452,389)
    part=shot('ActivitySeoulLathe',[person(818,811,'watch'),
        person(1115,600,'offer',clip_row=20,appearance={'cut':'crop','wear':'shopcoat'})],
        .61,430,389,prop='metal_part',prop_holder=1)
    # Crate tops are y655; seated sprites end on that surface, not at the feet
    # of the crate. A separate wide shot preserves the evening alley reveal.
    night=shot('ActivitySeoulEuljiroNight',[person(703,806),
        person(1299,657,'sit',seated=True,world_height=110)],.5,648,324,full_plate=True)
    drinks=shot('ActivitySeoulEuljiroNight',[
        person(973,656,'sit',seated=True,world_height=110),
        person(1299,657,'offer',seated=True,world_height=110)],
        .66,390,381,prop='glass',prop_holder=0)
    poured=shot('ActivitySeoulEuljiroNight',[
        person(973,656,'pour',seated=True,world_height=110),
        person(1299,657,'watch',seated=True,world_height=110)],
        .66,390,381,prop='bottle',prop_holder=0)
    stage['seoul:euljiro']={'day':beat(day,[{},lathe]),'chain':beat(part),
        'night':beat(night,[{},drinks]),'sat':beat(poured)}

    # The three stools stay part of the authored counter set; actors use their
    # measured seat height rather than receiving generic floating chairs.
    cook=person(1280,587,'offer',clip_row=20,appearance={'build':'elder','cut':'bob','wear':'apron'})
    market=shot('ActivitySeoulGwangjang',[person(619,799),cook],.5,648,324,full_plate=True)
    seated=person(1120,629,'sit',seated=True,world_height=112)
    served=shot('ActivitySeoulGwangjang',[seated,cook],.69,398,354,prop='jeon',prop_holder=0)
    eat=shot('ActivitySeoulGwangjang',[
        person(1120,629,'eat',seated=True,world_height=112),cook,
        person(840,628,'eat',seated=True,world_height=106,appearance={'build':'elder','cut':'bob'}),
        person(1376,629,'sit',seated=True,world_height=112,appearance={'wear':'suit','cut':'crop'})],
        .68,440,362,prop='jeon',prop_holder=0)
    order=shot('ActivitySeoulGwangjang',[
        person(1120,629,'point',seated=True,world_height=112),cook],.69,398,354,prop='jeon',prop_holder=1)
    paid=shot('ActivitySeoulGwangjang',[
        person(1120,629,'hand_over',seated=True,world_height=112),
        person(1280,587,'take',clip_row=20,appearance={'build':'elder','cut':'bob','wear':'apron'})],
        .69,398,354,prop='coin')
    stage['seoul:jongno']={'aisle':beat(market,[{},served]),'ate':beat(eat),
        'ordered':beat(order),'paid':beat(paid)}

    vendor=person(1203,603,'cut',clip_row=20,appearance={'cut':'bob','wear':'apron'})
    lane=shot('ActivitySeoulMangwonJeon',[person(635,810),vendor],.5,648,324,full_plate=True)
    choose=shot('ActivitySeoulMangwonJeon',[person(1041,799,'point'),vendor],.66,422,399)
    one=shot('ActivitySeoulMangwonJeon',[person(1041,799,'take'),
        person(1203,603,'offer',clip_row=20,appearance={'cut':'bob','wear':'apron'})],
        .66,422,399,prop='jeon',prop_holder=0)
    hers=shot('ActivitySeoulMangwonJeon',[person(1041,799,'eat'),
        person(1203,603,'watch',clip_row=20,appearance={'cut':'bob','wear':'apron'})],
        .66,422,399,prop='jeon',prop_holder=0)
    stage['seoul:mangwon']={'lane':beat(lane,[{},choose]),'one':beat(one),'hers':beat(hers)}

    # Crowd positions describe a loose arc around the performer. Everyone keeps
    # a distinct lane; the close-in choice deliberately puts the player inside.
    singer=person(1074,659,'strum',world_height=150,appearance=singer_look)
    crowd=[person(812,704),person(881,865),person(1180,874),person(1450,809)]
    street=shot('ActivitySeoulHongdaeBusking',[person(511,832,'walk'),singer],
        .5,648,324,full_plate=True,prop='guitar',prop_holder=1)
    ring=shot('ActivitySeoulHongdaeBusking',[person(646,816),singer,*crowd],
        .64,500,397,prop='guitar',prop_holder=1)
    joined=shot('ActivitySeoulHongdaeBusking',[person(646,816,'wave'),singer,*crowd],
        .64,500,397,prop='guitar',prop_holder=1)
    tipped=shot('ActivitySeoulHongdaeBusking',[person(1382,777,'hand_over'),
        person(1074,659,'wave',world_height=150,appearance=singer_look),
        person(1225,809,'queue'),person(1064,853,'queue')],.73,417,416,prop='coin',prop_holder=0)
    inside=shot('ActivitySeoulHongdaeBusking',[person(933,749,'recoil'),singer,*crowd],
        .64,500,397,prop='guitar',prop_holder=1)
    stage['seoul:hongdae']={'street':beat(street,[{},ring]),'edge':beat(ring),
        'joined':beat(joined),'tipped':beat(tipped),'inside':beat(inside)}

    brick=shot('SeoulSeongsu',[actor(842,804,'walk')],.5,648,324,full_plate=True)
    shoemaker=person(1147,595,'cut',clip_row=20,
        appearance={'build':'elder','cut':'crop','wear':'shopcoat'})
    workshop=shot('ActivitySeoulShoeWorkshop',[person(850,803),shoemaker],
        .64,472,389,prop='shoe',prop_holder=1)
    held=shot('ActivitySeoulShoeWorkshop',[person(850,803),
        person(1147,595,'offer',clip_row=20,appearance={'build':'elder','cut':'crop','wear':'shopcoat'})],
        .64,472,389,prop='shoe',prop_holder=1)
    coffee=shot('ActivitySeoulFactoryCafe',[
        person(312,655,'drink',seated=True,world_height=110)],.30,477,363,prop='glass',prop_holder=0)
    stage['seoul:seongsu']={'brick':beat(brick,[{},workshop]),'shop':beat(workshop),
        'watched':beat(held),'cafe':beat(coffee)}
    return plates,stage
