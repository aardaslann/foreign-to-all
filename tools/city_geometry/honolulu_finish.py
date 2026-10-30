"""Honolulu replacement art, complete silhouettes and actual service fixtures."""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import pot, oval
from .dakar_finish import replace


def finish(rows):
    for suffix, fn in [('Waikiki',waikiki),('Chinatown',chinatown),('Kakaako',kakaako),
                       ('Manoa',manoa),('NorthShore',northshore),('Hotel',hotel),
                       ('Exchange',exchange),('Transit',transit),('Airport',airport)]:
        row=rows['Honolulu'+suffix]
        row.update(texture=f'res://art/environments/scenes/Honolulu{suffix}-retro.png',
                   pixel_art=True,art_pending=False,implementation_stage='replacement_art_and_geometry')
        file=Path(__file__).resolve().parents[2]/row['texture'].removeprefix('res://')
        row['source']=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])]
        fn(row)
    return rows


def shelter(name,x,y,w,h,posts):
    # A thin continuous footprint under glass, separate from the bench.
    polys=[rect(x,y,w,8),rect(x,y,8,h),rect(x+w-8,y,8,h),rect(x,y+h-7,w,7)]
    for xx in posts:polys.append(rect(xx,y,7,h))
    return object_(name,y+h,[(x,y+h-10,w,10)],polys,
                   glass=[rect(x+8,y+8,w-16,h-15)])


def bench(name,x,y,w,h):
    return object_(name,y+h,[(x+3,y+h-15,w-6,15)],[
        rect(x,y,w,10),rect(x,y+22,w,10),
        rect(x+4,y+10,7,h-10),rect(x+w-12,y+10,7,h-10),
        rect(x+w*.48,y+10,7,h-10)])


def waikiki(row):
    replace(row,'hotel_tree_box',pot('hotel_tree_box',(462,718,123,60),(345,292,602,411),[
        [[518,719],[520,633],[496,608],[476,574],[484,569],[508,599],
         [526,611],[529,564],[541,558],[543,603],[567,567],[578,576],
         [550,621],[548,719]]]))
    row['objects'].append(shelter('bus_rear_glass',1092,598,211,187,[1176,1256]))
    row['objects'].append(bench('bus_bench',1103,725,151,61))
    row['lettering']=[
        sign((149,378,229,75),'HOTEL','#00000000','#253a3e',size=36),
        sign((676,493,204,63),'EXCHANGE','#00000000','#253a3e',size=27,object='exchange_frame'),
        sign((1105,494,175,59),'TheBus','#00000000','#253a3e',size=31,object='bus_frame'),
        sign((1459,626,87,61),'AÇAÍ','#00000000','#334d3c',size=26,object='acai_stand')]


def chinatown(row):
    row['objects'].append(shelter('bus_rear_glass',1194,472,219,161,[1241,1342]))
    row['objects'].append(bench('bus_bench',1236,591,113,43))
    row['lettering']=[
        sign((481,392,181,43),'SUN KEE','#00000000',size=30),
        sign((1188,369,219,48),'TheBus','#00000000','#253a3e',size=30,object='bus_stop'),
        sign((1584,393,88,42),'BUS','#00000000','#ae3f32',size=24)]


def kakaako(row):
    row['objects'].append(shelter('bus_rear_glass',1362,480,204,153,[1396,1506]))
    row['objects'].append(bench('bus_bench',1411,576,95,60))
    row['lettering']=[
        sign((305,374,184,31),'WORKS','#00000000','#253a3e',size=24),
        sign((627,443,222,30),'PLATE LUNCH','#00000000','#253a3e',size=22),
        sign((1356,378,210,45),'TheBus','#00000000','#253a3e',size=29,object='bus_stop')]


def manoa(row):
    row['lettering']=[sign((1380,401,230,33),'MĀNOA MART','#00000000','#263d37',size=27)]
    gate=next(o for o in row['objects'] if o['id']=='garden_gate')
    gate['polygons'] += [[point(x,y) for x,y in rect(817,660,112,9)]]
    bike=next(o for o in row['objects'] if o['id']=='mart_bicycle')
    bike['polygons'] += [[point(x,y) for x,y in poly] for poly in [
        tube((1180,581),(1176,573),5),rect(1168,568,21,6),
        tube((1226,582),(1229,573),5),rect(1218,569,24,6)]]
    plant=next(o for o in row['objects'] if o['id']=='mart_flower_box')
    plant['polygons'] += [[point(x,y) for x,y in oval(cx,cy,7,6)]
        for cx,cy in [(1353,575),(1375,580),(1393,563),(1412,600),(1430,580)]]


def northshore(row):
    row['animation_patches']=[dict(kind='water',rect=[*point(1110,398),*point(139,65)])]
    row['lettering']=[
        sign((40,420,263,33),'SURF SUPPLY','#00000000','#284653',size=27),
        sign((431,419,211,34),'SHAVE ICE','#00000000','#ad3d32',size=26),
        sign((1380,417,215,41),'TheBus','#00000000','#253a3e',size=30,object='bus_shelter_frame'),
        sign((345,613,32,48),'RENT\nREPAIR','#00000000',size=8,object='surf_board')]
    replace(row,'shelter_bench',object_('shelter_bench',675,[(1409,656,166,19)],[
        rect(1410,590,158,9),rect(1410,608,158,9),rect(1404,625,174,11),
        rect(1409,599,8,75),rect(1565,599,8,75),rect(1479,617,8,53)]))
    plant=next(o for o in row['objects'] if o['id']=='food_truck_flowers')
    plant['pink_blossoms']=True
    row['objects'].append(object_('west_red_surfboard',663,[(17,643,17,20)],[
        [[23,527],[28,537],[33,560],[31,641],[24,663],[18,652],[16,561],[19,538]]]))


def hotel(row):
    row['clerks']['Point']=anchor(638,454)
    row['lettering']=[
        sign((492,239,281,39),'ALOHA HOTEL','#00000000','#563e28',size=28),
        sign((1401,228,151,25),'OʻAHU','#00000000','#344c4d',size=20)]
    replace(row,'lobby_west_plant',pot('lobby_west_plant',(260,523,141,83),(276,257,121,268)))
    replace(row,'coffee_table',object_('coffee_table',617,[(1292,596,99,21)],[
        rect(1280,534,119,19),rect(1292,553,12,64),rect(1377,553,12,64),
        rect(1304,552,73,60)]))
    for name,x,backx in [('west_chair',1115,1115),('east_chair',1416,1463)]:
        replace(row,name,object_(name,617,[(x+3,598,142,19)],[
            rect(backx,474,109,10),rect(backx,484,10,88),rect(backx+98,484,10,88),
            rect(x+2,518,144,12),rect(x+5,530,10,87),rect(x+137,530,10,87),
            rect(x+17,552,122,24),rect(x+47,578,10,39)],
            foliage=[rect(backx+10,485,87,65),rect(x+17,577,121,22)],wood_branches=True))


def exchange(row):
    row['clerks']['Point']=anchor(748,454)
    replace(row,'exchange_tree',pot('exchange_tree',(537,526,71,70),(516,324,108,202),[
        rect(565,433,13,95)]))
    replace(row,'postcard_rack',object_('postcard_rack',603,[(324,584,157,19)],[
        [[335,415],[478,415],[481,603],[468,603],[468,578],[337,578],
         [337,603],[324,603],[324,479]]]))
    replace(row,'recycling_bin',object_('recycling_bin',602,[(1463,583,92,19)],[
        rect(1463,414,90,188)]))
    row['lettering']=[
        sign((653,163,531,53),'CURRENCY EXCHANGE','#00000000','#233e43',size=35),
        sign((1281,186,225,163),'CURRENCIES\nUSD · JPY\nEUR · CAD','#00000000',size=26),
        sign((334,337,113,22),'OʻAHU','#00000000','#275068',size=18)]


def transit(row):
    # Boarding follows the real double doors. The former floating gate is
    # absent from the replacement artwork and must not leave an invisible wall.
    row['objects']=[o for o in row['objects'] if o['id']!='platform_gate']
    row['anchors']['Platform']=anchor(700,657)
    row['lettering']=[
        sign((420,197,125,41),'SKYLINE','#00000000','#253c48',size=25,object='central_column'),
        sign((424,254,121,190),'HONOLULU\n\nPLATFORM 1\n\n→ BOARD','#00000000','#253c48',size=17,object='central_column'),
        sign((1360,265,218,124),'ALOHA\nMOVES YOU','#00000000','#253c48',size=29,object='station_poster')]
    row['motion_layers']=[dict(kind='doors',rect=[*point(650,381),*point(92,200)])]


def airport(row):
    replace(row,'luggage_carousel',object_('luggage_carousel',750,[(947,726,711,24)],[
        [[978,676],[1080,670],[1080,647],[1566,647],[1566,674],[1641,679],
         [1658,688],[1658,725],[1647,749],[959,749],[947,726],[947,690]],
        rect(1134,613,29,37),rect(1167,613,57,37),rect(1334,613,66,37),
        rect(1424,613,64,37),rect(1172,603,36,10),rect(1358,601,23,12),
        rect(1447,600,14,13)],
        animation_patches=[dict(kind='conveyor',rect=[*point(1096,673),*point(453,16)])]))
    trough=next(o for o in row['objects'] if o['id']=='middle_flower_trough')
    trough['polygons'] += [[point(x,y) for x,y in oval(cx,cy,8,7)]
        for cx,cy in [(644,594),(680,595),(719,589),(736,584),(777,578),(801,589),(829,601)]]
    row['lettering']=[
        sign((447,177,346,58),'BAGGAGE CLAIM','#00000000',size=32),
        sign((1086,177,125,58),'GATES','#00000000',size=30),
        sign((1164,340,311,173),'DEPARTURES\nSYDNEY     14:20\nTOKYO      15:10\nTORONTO  16:00\nSEOUL      16:45','#182b37','#ead064',size=19,object='departures_board')]
