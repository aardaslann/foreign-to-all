"""Five La Paz encounters on measured pixel sets; story logic is unchanged."""
import struct
from copy import deepcopy
from pathlib import Path
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=122,appearance={},z=y/1000) | extra))


def build():
    plates={}
    for name,floor in [('Feria',766),('Scale',739),('Casera',775),('Abaroa',713),
                       ('SanPedroSquare',729),('CableCabin',824),('ZonaSur',789),('Mall',710)]:
        key='ActivityLaPaz'+name
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        plates[key]=dict(city='lapaz',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityLaPazFeria']['lettering']=[
        sign((667,430,225,31),'FERIA 16 DE JULIO','#00000000','#403a37',size=20)]
    plates['ActivityLaPazAbaroa']['animation_patches']=[
        dict(kind='water',rect=[*point(650,527),*point(243,21)])]
    plates['ActivityLaPazCableCabin']['lettering']=[
        sign((669,20,335,30),'LÍNEA VERDE · IRPAVI','#00000000',size=23)]
    plates['ActivityLaPazCableCabin']['animation_patches']=[
        dict(kind='cable_cars',rect=[*point(928,80),*point(540,194)],
             covers=[ [point(x,y) for x,y in [(1342,93),(1470,65),(1522,590),(1414,579)]] ])]
    # Treads move along their actual diagonal, never over the rails.
    plates['ActivityLaPazMall']['animation_patches']=[
        dict(kind='escalator_sloped',rect=[*point(1249,397),*point(122,277)],direction=1),
        dict(kind='escalator_sloped',rect=[*point(1339,397),*point(140,277)],direction=-1)]
    stage={}
    seller_look={'build':'adult','wear':'blouse','cut':'tied','face':''}
    feria=shot('ActivityLaPazFeria',[person(685,855)],.5,648,324,full_plate=True)
    walk=feria | {'cast':[person(1028,855,'walk'),person(1224,837,'carry',appearance={'wear':'coat','cut':'crop'})],
                  'prop':'potato_bag','prop_holder':1}
    scale_seller=person(839,604,'count',world_height=118,clip_row=18,appearance=seller_look)
    scale=shot('ActivityLaPazScale',[person(663,840),scale_seller],.52,488,387)
    purchase=scale | {'cast':[person(663,840,'take'),scale_seller | {'act':'offer'}],
                       'prop':'potato_bag','prop_holder':0}
    stage['lapaz:elalto']={'edge':beat(feria,[feria,walk]),'endless':beat(walk),
        'scale':beat(scale,[scale],choices={'buy':{'staging':purchase}}),'bought':beat(purchase)}

    casera=person(1034,610,'offer',world_height=110,clip_row=18,appearance=seller_look)
    stall=shot('ActivityLaPazCasera',[person(898,849),casera],.57,511,390)
    row=shot('ActivityLaPazCasera',[person(531,838),casera,
        person(1128,850,'take',appearance={'wear':'shirt','cut':'crop','face':''})],.5,648,324,
        full_plate=True,prop='potato_bag',prop_holder=2)
    paid=stall | {'cast':[person(889,849,'hand_over'),casera | {'act':'take'}],
                     'prop':'coin','prop_holder':0}
    extra=stall | {'cast':[person(884,849,'take'),casera | {'act':'offer'}],
                      'prop':'potato_bag','prop_holder':0}
    stage['lapaz:rodriguez']={'row':beat(stall,[row,row]),'why':beat(row),
        'first':beat(paid,[paid]),'yapa':beat(extra,[extra])}

    worker={'build':'adult','wear':'coat','cut':'crop','face':'','balaclava':True}
    seated_customer=person(537,650,'sit',appearance={'wear':'blouse','cut':'bob'},
                           seated=True,kit='shoe_customer')
    polish=person(644,773,'polish_shoe',world_height=100,appearance=worker,
                  seated=True,seat=True,kit='shoe_brush')
    colleague=person(1095,820,'watch',world_height=108,
                     appearance=worker | {'wear':'jacket'},seated=True,seat=True)
    square=shot('ActivityLaPazAbaroa',[person(855,845),polish,seated_customer,colleague],.5,648,324,
        full_plate=True,object='shoeshine',object_world_at=point(597,755),object_world_unit=1.6,
        prop='shoe',prop_holder=3)
    close=square | {'cam':[.39,452],'cam_y':427,'full_plate':False}
    shoes=close | {'cast':[person(537,650,'sit',seated=True,kit='shoe_customer'),polish,colleague],
                       'prop_holder':2}
    far=square | {'cast':[person(345,650,'sit',seated=True),polish,seated_customer,colleague]}
    api=shot('ActivityLaPazAbaroa',[person(454,650,'drink',seated=True)],.3,420,410,
             prop='api',prop_holder=0)
    stage['lapaz:sopocachi']={'plaza':beat(square,[square,close]),
        'why':beat(close),'shoes':beat(shoes),'avoided':beat(far),'api':beat(api)}

    mother={'build':'adult','wear':'blouse','cut':'tied','face':''}
    child={'build':'child','wear':'tee','cut':'crop','face':''}
    plaza=shot('ActivityLaPazSanPedroSquare',[person(864,827)],.5,648,324,full_plate=True)
    gate=plaza | {'cast':[person(972,839),person(1423,724,'carry',appearance=mother),
                          person(1287,771,'walk',world_height=122,appearance=child)],
                    'prop':'potato_bag','prop_holder':1}
    seller=person(250,671,'watch',clip_row=18,world_height=112,appearance=seller_look)
    ask=shot('ActivityLaPazSanPedroSquare',[person(431,822),seller],.24,456,410)
    sat=plaza | {'cast':[person(761,684,'sit',seated=True),
        person(1114,798,'walk',world_height=122,appearance=child)]}
    stage['lapaz:sanpedro']={'square':beat(plaza,[plaza,gate]),
        'gate':beat(gate),'asked':beat(ask),'sat':beat(sat)}

    cabin=shot('ActivityLaPazCableCabin',[person(832,720,'sit',seated=True)],.5,648,324,full_plate=True)
    outside=shot('ActivityLaPazZonaSur',[person(842,849)],.5,648,324,full_plate=True)
    air=outside | {'cast':[person(1250,729,'sit',seated=True)]}
    mall=shot('ActivityLaPazMall',[person(864,840,'walk')],.5,648,324,full_plate=True)
    uphill=outside | {'cast':[person(841,849,'look_up')]}
    stage['lapaz:irpavi']={'cable':beat(outside,[cabin,outside]),
        'air':beat(air),'mall':beat(mall),'uphill':beat(uphill)}
    return plates,stage
