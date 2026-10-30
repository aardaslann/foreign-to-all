"""Mexico's five encounters on measured pixel sets, preserving their branches."""
import struct
from pathlib import Path
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=122,appearance={},z=y/1000) | extra))


def build():
    plates={}
    for name,floor in [('MercedAisle',716),('MercedLoading',690),('RomaPlaza',758),
                       ('CoyoacanMarket',717),('CoyoacanCoyotes',696),('CondesaPark',701),
                       ('JuarezOrgan',719)]:
        key='ActivityMexico'+name
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        plates[key]=dict(city='mexico',texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],pixel_art=True,
            floor=point(0,floor)[1],lettering=[],motion=[],animation_patches=[])
    plates['ActivityMexicoRomaPlaza']['lettering']=[
        sign((1450,528,147,65),'19 · 09 · 1985\n19 · 09 · 2017',
             '#00000000','#3a3b37',size=12)]
    plates['ActivityMexicoRomaPlaza']['animation_patches']=[
        dict(kind='water',rect=[*point(633,609),*point(380,10)])]
    plates['ActivityMexicoCoyoacanMarket']['lettering']=[
        sign((473,146,718,72),'TOSTADAS · COYOACÁN','#00000000','#74432c',size=40)]
    plates['ActivityMexicoCoyoacanCoyotes']['animation_patches']=[
        dict(kind='water',rect=[*point(590,601),*point(535,11)])]
    plates['ActivityMexicoJuarezOrgan']['lettering']=[
        sign((206,451,440,37),'CAFÉ JUÁREZ','#00000000',size=29),
        sign((1256,440,280,42),'LIBRERÍA','#00000000',size=30),
        sign((931,459,177,27),'TALLER','#00000000',size=22),
        sign((109,632,56,67),'CAFÉ\nTÉ\nPAN','#183640',size=10)]

    stage={}
    porter_look={'build':'adult','wear':'shirt','cut':'crop','face':''}
    porter=person(936,854,'push',appearance=porter_look,kit='market_cart')
    aisle=shot('ActivityMexicoMercedAisle',[person(657,848)],.5,648,324,full_plate=True)
    pass_by=aisle | {'cast':[person(661,852,'recoil'),porter,person(1182,828,'watch')]}
    shoulder=shot('ActivityMexicoMercedAisle',
        [person(736,855,'recoil'),porter | {'world_at':point(854,854)}],.52,481,407)
    learned=pass_by | {'cast':[person(655,850),porter | {'act':'watch'},person(1240,851)]}
    loading=shot('ActivityMexicoMercedLoading',
        [person(723,853),person(987,839,'push',appearance=porter_look,kit='market_cart_empty')],
        .5,648,324,full_plate=True)
    stage['mexico:merced']={'aisle':beat(aisle,[aisle,pass_by]),
        'clipped':beat(shoulder,[shoulder]),'word':beat(learned),'follow':beat(loading)}

    uniform={'build':'adult','wear':'jacket','cut':'crop','face':'',
             'pal':{'C':'#b29b70','D':'#8d7854','O':'#67573e'}}
    musician=person(882,837,'turn_organ',appearance=uniform,kit='organ_cap')
    collector=person(1056,856,'offer',appearance=uniform,kit='organ_collection_cap')
    corner=shot('ActivityMexicoJuarezOrgan',[person(568,865),musician,collector],.5,648,324,
        full_plate=True,object='organ',object_world_at=point(750,840),
        object_world_unit=2.4)
    crank=corner | {'cam':[.5,435],'cam_y':440,'full_plate':False}
    hat=crank | {'cast':[person(1220,869),musician,collector]}
    coin=hat | {'cast':[person(1220,869,'hand_over'),musician,collector | {'act':'bow'}],
                  'prop':'coin','prop_holder':0,'prop_world_to':point(1088,788),'prop_end_unit':2}
    stage['mexico:juarez']={'corner':beat(corner,[corner,crank]),
        'hat':beat(hat,[hat]),'coin':beat(coin,[coin])}

    plaza=shot('ActivityMexicoRomaPlaza',[person(799,851,'walk')],.5,648,324,full_plate=True)
    assembly=[person(800,850),person(1023,817,'walk'),person(1192,839,'walk'),
              person(1344,852),person(598,808),person(434,854,'walk')]
    drill=plaza | {'cast':assembly}
    plaque=shot('ActivityMexicoRomaPlaza',[person(1438,846,'look_up')],.84,388,430)
    bench=plaza | {'cast':[person(319,692,'sit',seated=True),*assembly[1:4]]}
    ran=drill | {'cast':[person(790,850,'recoil'),
        person(954,844,'reach'),*assembly[2:]]}
    stage['mexico:roma']={'plaza':beat(plaza,[plaza,drill]),'plaque':beat(plaque),
        'sit':beat(bench),'drill':beat(drill),'ran':beat(ran)}

    cook={'build':'adult','wear':'blouse','cut':'tied','face':''}
    cooks=[person(x,583,act,world_height=118,clip_row=18,appearance=cook)
           for x,act in [(538,'count'),(737,'watch'),(948,'offer'),(1165,'watch')]]
    market=shot('ActivityMexicoCoyoacanMarket',[person(738,841),*cooks,
        person(523,851,'queue',appearance={'wear':'shirt'}),
        person(358,862,'queue',appearance={'wear':'blouse','cut':'bob'})],
        .5,648,324,full_plate=True)
    order=shot('ActivityMexicoCoyoacanMarket',[person(953,817),*cooks],.54,498,395)
    tall=order | {'cast':[person(953,817,'take'),*cooks],'prop':'tostada','prop_holder':0}
    small=order | {'cast':[person(953,817,'eat'),*cooks],'prop':'tostada_small','prop_holder':0}
    coyotes=shot('ActivityMexicoCoyoacanCoyotes',[person(1341,823,'watch')],
        .5,648,324,full_plate=True)
    stage['mexico:coyoacan']={'market':beat(market,[market,order]),'watched':beat(order),
        'built':beat(tall),'plain':beat(small),'coyotes':beat(coyotes)}

    oval=shot('ActivityMexicoCondesaPark',[person(585,847,'walk')],
        .5,648,324,full_plate=True)
    walker=person(841,780,'walk',appearance={'build':'adult','wear':'shirt','cut':'crop','face':''},
                  kit='dog_pack')
    pack=oval | {'cast':[person(503,844),walker],'cam':[.56,500],'cam_y':392,'full_plate':False}
    watch=pack | {'cast':[person(503,844),walker | {'act':'watch'}]}
    whistle=pack | {'cast':[person(503,844,'wave'),
        walker | {'act':'watch','kit':'dog_pack_look'}]}
    shape=oval | {'cast':[person(716,841,'look_up')]}
    stage['mexico:condesa']={'oval':beat(oval,[oval,pack]),'watched':beat(watch),
        'tried':beat(whistle),'shape':beat(shape)}
    return plates,stage
