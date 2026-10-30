"""London geometry measured against the approved individual pixel backgrounds."""
from .shapes import anchor, object_, point, rect, sign, tube, SY


def scene(scene_id, floor, spawn, objects, anchors, lettering=(), **extra):
    return dict(texture=f'res://art/environments/scenes/{scene_id}-retro.png',
                source=[0, 0, 1672, 941], pixel_art=True, floor=round(floor*SY, 2),
                spawn=anchor(*spawn), objects=objects, anchors=anchors,
                lettering=list(lettering), foreground=[], solids=[], portals=[],
                motion=[], animation_patches=[], desks=[], fittings=[], motion_layers=[]) | extra


def rope_group(name, xs, top, bottom):
    polygons = []
    for x in xs:
        polygons += [[[x-7,top],[x+5,top],[x+9,top+5],[x+9,top+11],
                      [x+4,top+16],[x+4,bottom-9],[x+12,bottom-6],
                      [x+12,bottom-1],[x-12,bottom-1],[x-12,bottom-6],
                      [x-4,bottom-9],[x-4,top+16],[x-9,top+11],[x-9,top+5]]]
    for a, b in zip(xs, xs[1:]):
        points = [(a+5,top+17),(a+(b-a)*.25,top+26),
                  ((a+b)/2,top+31),(b-(b-a)*.25,top+26),(b-5,top+17)]
        polygons += [tube(a,b,4) for a,b in zip(points,points[1:])]
    return object_(name,bottom,[(xs[0]-11,bottom-13,xs[-1]-xs[0]+22,13)],polygons)


def soho():
    objects = [rope_group('vinyl_ropes',[318,372],614,701),
               rope_group('venue_west_rope',[543,636],617,691),
               rope_group('venue_east_rope',[849,904],615,703)]
    objects.append(object_('street_lamp',724,[(1000,708,33,16)],[
        [[1000,708],[1008,700],[1008,324],[1003,315],[993,305],[988,280],
         [976,280],[976,272],[993,263],[1003,247],[1009,242],[1009,229],
         [1017,221],[1023,231],[1023,242],[1030,247],[1038,263],[1054,273],
         [1054,281],[1045,282],[1037,307],[1026,317],[1024,329],[1024,700],
         [1033,708],[1033,722],[1000,722]]]))
    objects.append(object_('menu_board',734,[(1369,717,79,17)],[
        [[1368,617],[1450,617],[1450,731],[1440,731],[1440,715],
         [1375,715],[1375,731],[1365,731]],rect(1359,686,6,43)],
        ))
    objects.append(object_('east_tree_planter',701,[(1558,680,114,21)],[
        rect(1558,648,114,52),
        [[1606,650],[1606,507],[1592,487],[1580,469],[1588,466],[1613,492],
         [1613,454],[1627,454],[1631,489],[1657,459],[1664,466],[1631,507],
         [1631,650]]],foliage=[rect(1496,194,176,324),rect(1570,521,102,129)]))
    objects.append(object_('cafe_left',677,[(1038,651,175,26)],[
        rect(1084,591,81,14),rect(1118,603,10,59),rect(1102,662,43,6),
        rect(1036,573,15,52),rect(1043,625,51,11),rect(1042,635,8,29),
        rect(1081,635,8,27),rect(1184,573,15,49),rect(1146,625,52,10),
        rect(1149,635,7,28),rect(1190,635,7,30),
        rect(1091,585,10,7),rect(1108,573,9,20),rect(1122,578,11,15),
        rect(1140,581,9,11)]))
    objects.append(object_('cafe_right',678,[(1236,650,164,28)],[
        rect(1278,591,82,15),rect(1314,605,9,58),rect(1298,662,43,6),
        rect(1245,575,13,53),rect(1252,626,47,10),rect(1250,636,8,29),
        rect(1292,636,7,28),rect(1382,581,12,44),rect(1353,629,37,9),
        rect(1382,638,8,28),rect(1288,581,10,11),rect(1301,575,11,18),
        rect(1320,577,10,16),rect(1340,584,8,9)]))
    objects.append(object_('cafe_front_chair',701,[(1230,680,67,21)],[
        [[1238,614],[1290,614],[1297,691],[1303,697],[1292,699],[1282,675],
         [1242,675],[1233,699],[1222,699],[1228,691]],
        rect(1241,624,42,34)]))
    return scene('LondonSoho',665,(390,810),objects,
        {'TransitDoor':anchor(1528,695),'LocalSpot':anchor(713,724)},[
            sign((86,362,215,64),'VINYL','#182635',size=28),
            sign((608,345,211,79),'THE LEX','#202b3b',size=27),
            sign((1090,340,232,82),'CAFÉ','#681d22',size=30),
            sign((1376,627,63,77),'TEA\nCOFFEE\nCAKE','#202c32',size=9,object='menu_board'),
            sign((1498,515,66,19),'UNDERGROUND','#26374c',size=7)],
        interaction_sizes={'TransitDoor':{'CollisionShape2D':[48,34]},
                           'LocalSpot':{'CollisionShape2D':[72,36]}})


def build():
    from .london_finish import finish
    return finish({'LondonSoho':soho(), 'LondonExchange':exchange(),
            'LondonHospital':hospital(), 'LondonPolice':police(),
            'LondonAirport':airport(), 'LondonHotel':hotel(),
            'LondonCaff':caff(), 'LondonUnderground':underground(),
            'LondonTerrace':terrace(), 'LondonHighStreet':highstreet(),
            'LondonBrixton':brixton(), 'LondonDocklands':docklands()})


def pole(name,x,top,bottom,width=17):
    return object_(name,bottom,[(x-width,bottom-14,width*2,14)],[
        rect(x-width/2,top,width,bottom-top-8),
        [[x-width,bottom-10],[x+width,bottom-10],[x+width,bottom-2],
         [x+width-4,bottom],[x-width+4,bottom],[x-width,bottom-2]]])


def terrace():
    objects=[]
    for name,left,right in [('west',0,237),('middle',377,735),('east',864,1208),('far_east',1345,1580)]:
        polys=[rect(left,592,right-left,9)]
        polys += [rect(x,598,5,87) for x in range(left+11,right-6,23)]
        polys += [rect(right-11,550,15,137)]
        objects.append(object_('fence_'+name,687,[(left,675,right-left,12)],polys))
    objects.append(object_('tree_middle',704,[(422,684,58,20)],[
        rect(422,650,58,52),
        [[441,650],[441,536],[425,518],[410,492],[417,484],[443,513],
         [443,487],[454,475],[465,480],[465,511],[483,488],[491,491],
         [467,530],[466,650]]],foliage=[rect(346,280,212,226)]))
    objects.append(object_('tree_east',694,[(1585,675,87,19)],[
        [[1600,680],[1600,529],[1582,505],[1590,497],[1609,516],[1610,483],
         [1630,483],[1630,516],[1651,490],[1660,495],[1632,530],[1631,680]]],
        foliage=[rect(1511,143,161,376)]))
    for name,x,top in [('west_lamp',179,304),('east_lamp',1451,186)]:
        p=pole(name,x,top+99,727,18)
        p['polygons'].append([point(a,b) for a,b in [
            [x-39,top+72],[x-28,top+64],[x-12,top+45],[x-6,top+18],
            [x-2,top],[x+4,top],[x+9,top+20],[x+13,top+46],
            [x+31,top+66],[x+40,top+72],[x+27,top+76],[x+17,top+107],
            [x+8,top+115],[x-8,top+115],[x-17,top+107],[x-27,top+76]]])
        objects.append(p)
    objects += [object_('postbox',730,[(1580,709,55,21)],[
        [[1575,585],[1587,575],[1628,575],[1639,585],[1639,595],
         [1631,599],[1631,709],[1637,712],[1637,726],[1578,726],[1578,711],
         [1584,707],[1584,599],[1575,595]]]),
        object_('notice_stand',697,[(1084,681,52,16)],[
            [[1088,575],[1133,575],[1136,589],[1130,593],[1130,680],
             [1136,689],[1136,696],[1124,696],[1124,686],[1096,686],
             [1096,696],[1084,696],[1084,687],[1090,680],[1090,593],[1083,589]]])]
    for name,x,y in [('green_bin_west',601,622),('green_bin_east',945,622),('black_bin',28,578)]:
        bottom=723 if 'green' in name else 687
        objects.append(object_(name,bottom,[(x,y+bottom-y-23,54,23)],[
            [[x+4,y],[x+49,y],[x+54,y+6],[x+55,y+14],[x+50,y+18],
             [x+48,bottom-15],[x+53,bottom-14],[x+53,bottom-2],
             [x+43,bottom-2],[x+41,bottom-11],[x+13,bottom-11],
             [x+11,bottom-2],[x+1,bottom-2],[x+1,bottom-14],[x+6,bottom-15],
             [x+4,y+18],[x,y+14],[x,y+6]]]))
    return scene('LondonTerrace',646,(780,808),objects,
        {'HotelEntrance':anchor(307,701),'HospitalEntrance':anchor(1280,700),
         'UndergroundEntrance':anchor(796,701),'TransitEntrance':anchor(796,701),
         'ExitToHighStreet':anchor(1630,818),'LocalSpot':anchor(627,756),
         'KeyNadia':anchor(1060,817),'Encounter':anchor(1210,798)},[
            sign((359,510,52,18),'HOTEL','#2d251e','#e6c873',10),
            sign((844,474,70,14),'UNDERGROUND','#182b5e',size=6),
            sign((1330,481,45,22),'A&E','#16346a',size=13)],
        encounter_exit={'to':anchor(1610,798),'via':[]},
        interaction_sizes={key:{'CollisionShape2D':[64,36]} for key in ['HotelEntrance','HospitalEntrance','UndergroundEntrance','LocalSpot']})


def highstreet():
    objects=[]
    for name,x,w in [('produce_west',486,134),('produce_east',716,114)]:
        polys=[rect(x,656,w,22),rect(x+2,678,9,23),rect(x+w-13,678,9,23),rect(x+15,677,w-29,9)]
        # Fruit and the table form one fixture, with the gaps under it kept open.
        polys.append([[x,656],[x+5,642],[x+13,645],[x+14,632],[x+25,624],
                      [x+35,632],[x+49,625],[x+61,631],[x+75,623],
                      [x+88,630],[x+w-15,632],[x+w-5,644],[x+w,656]])
        objects.append(object_(name,702,[(x,679,w,23)],polys))
    objects.append(object_('donation_box',691,[(428,671,35,20)],[rect(428,639,35,51)]))
    objects.append(object_('shelter',735,[(1090,710,205,8),(1090,718,18,17),(1277,718,18,17),(1122,718,145,17)],[
        rect(1075,519,239,23),rect(1090,542,17,190),rect(1277,542,17,190),
        rect(1104,638,175,9),rect(1110,712,169,8),rect(1125,669,139,22),
        rect(1120,684,145,13),rect(1133,697,12,36),rect(1244,697,11,36)],
        glass=[rect(1107,542,170,96),rect(1107,647,170,66)]))
    objects.append(object_('shelter_notice',734,[(1413,718,15,16)],[
        rect(1320,578,61,78),rect(1294,654,126,9),rect(1413,531,14,201)]))
    objects.append(object_('bin',735,[(1422,716,75,19)],[
        [[1425,618],[1489,618],[1496,626],[1496,639],[1490,642],
         [1490,721],[1496,728],[1496,733],[1420,733],[1420,728],[1425,721],
         [1425,642],[1418,639],[1418,626]]]))
    objects.append(object_('postbox',736,[(1554,716,59,20)],[
        [[1550,611],[1580,598],[1614,611],[1617,621],[1610,626],
         [1610,716],[1614,719],[1614,734],[1553,734],[1553,719],
         [1557,716],[1557,626],[1550,621]]]))
    lamp=pole('lamp',1533,303,725,17)
    lamp['polygons'] += [[point(x,y) for x,y in [
        [1496,308],[1512,299],[1522,278],[1525,262],[1531,252],[1537,262],
        [1540,277],[1552,299],[1565,308],[1560,315],[1546,315],[1541,333],
        [1522,333],[1516,315],[1497,315]]]]
    lamp['polygons'] += [[point(x,y) for x,y in rect(1485,529,89,86)],
                          [point(x,y) for x,y in rect(1486,519,10,213)]]
    objects.append(lamp)
    return scene('LondonHighStreet',684,(770,823),objects,
        {'CaffEntrance':anchor(267,719),'ExchangeEntrance':anchor(659,719),
         'PoliceEntrance':anchor(945,719),'LocalSpot':anchor(385,719),
         'ExitToTerrace':anchor(40,820),'NpcDot':anchor(520,804),
         'NpcKai':anchor(1110,814),'NpcAggarwal':anchor(780,775)},[
            sign((86,402,215,62),'CAFF','#ede6cf','#173848',30),
            sign((344,400,115,64),'CHARITY\nSHOP','#164731',size=17),
            sign((500,405,324,57),'BUREAU DE CHANGE','#174431',size=20),
            sign((1033,406,224,57),'POLICE','#174270',size=29),
            sign((1327,586,48,63),'LOCAL\nMAP','#e4e4d6','#245779',9,object='shelter_notice')],
        interaction_sizes={key:{'CollisionShape2D':[60,35]} for key in ['CaffEntrance','ExchangeEntrance','PoliceEntrance','LocalSpot']})


def brixton():
    objects=[]
    for name,x,w,y in [('west_stall',202,256,748),('inner_west',626,111,732),
                       ('inner_east',971,114,731),('east_stall',1125,143,748),('far_east',1370,100,748)]:
        top=y-54
        objects.append(object_(name,y,[(x,top+29,w,25)],
            [rect(x,top,w,17),rect(x+3,top+17,9,37),rect(x+w-12,top+17,9,37),
             rect(x+16,top+27,w-32,10),
             [[x,top],[x+8,top-24],[x+22,top-27],[x+24,top-41],
              [x+37,top-34],[x+w*.45,top-38],[x+w*.55,top-29],
              [x+w*.72,top-43],[x+w-12,top-30],[x+w,top-12]]]))
    objects += [plant('west_plant_box',(546,694,49,54),(546,650,49,45),[rect(566,681,9,14)]),
        object_('small_crates',748,[(1038,724,51,24)],[
            [[1040,687],[1043,674],[1091,674],[1091,703],[1086,703],[1086,747],
             [1077,747],[1077,735],[1047,735],[1047,748],[1035,748],[1035,705]]]),
        object_('postbox',805,[(81,778,61,27)],[
            [[76,650],[86,644],[127,641],[143,648],[143,659],[136,663],
             [136,778],[143,780],[143,801],[81,801],[81,780],[87,778],
             [87,663],[76,659]]]),
        object_('wheelie_bin',757,[(1610,734,62,23)],[
            [[1616,648],[1660,648],[1668,655],[1668,668],[1661,670],[1664,734],
             [1672,741],[1671,755],[1658,755],[1652,746],[1621,746],[1617,756],
             [1606,756],[1606,740],[1615,734],[1614,670],[1609,667]]]),
        object_('delivery_trolley',764,[(1570,738,40,26)],
            [rect(1579,651,5,86),rect(1598,651,5,86),rect(1579,645,24,6),
             rect(1572,730,36,9),rect(1575,692,25,6),rect(1578,738,15,20),rect(1598,739,11,20)])]
    return scene('LondonBrixton',720,(802,822),objects,
        {'LocalSpot':anchor(366,786),'TransitDoor':anchor(850,753)},[
            sign((653,327,399,43),'BRIXTON MARKET','#173d60',size=29),
            sign((240,488,328,43),'CARIBBEAN FOOD','#f1ce4d','#18221d',23),
            sign((1164,488,300,43),'FRESH PRODUCE','#187848',size=23)],
        interaction_sizes={'LocalSpot':{'CollisionShape2D':[80,37]},'TransitDoor':{'CollisionShape2D':[86,36]}})


def docklands():
    objects=[object_('west_tree_planter',754,[(0,730,440,24)],
        [rect(0,664,440,90),rect(0,591,14,73),rect(135,571,13,94)],
        foliage=[rect(0,353,224,312)]),
        plant('middle_planter',(464,706,246,89),(470,603,231,104),[]),
        plant('east_planter',(1147,706,250,89),(1155,606,234,102),[]),
        object_('shelter',797,[(124,778,271,19)],[
            [[91,510],[432,510],[407,546],[391,560],[123,560]],
            rect(124,557,14,232),rect(377,557,14,232),rect(125,789,21,8),
            rect(371,789,23,8),rect(140,743,237,13)],
            glass=[rect(139,561,238,182)]),
        object_('luggage_cart',821,[(1018,799,95,22)],[
            tube((1025,745),(1025,796),6),tube((1101,739),(1101,798),6),
            tube((1026,736),(1102,736),6),tube((1024,735),(1047,720),6),
            tube((1046,720),(1053,728),6),rect(1020,793,88,12),
            rect(1018,804,14,16),rect(1098,804,14,16)])]
    # Foreground chains frame the quay. The open access between x310 and x561
    # is kept clear; chain collision follows the ground plane, not its height.
    for name,xs in [('west_mooring',[88,284]),('east_mooring',[578,744,929,1083,1236,1410,1604])]:
        p=rope_group(name,xs,847,941)
        p['footprints']=[[point(xs[0]-14,925)[0],point(0,925)[1],point(xs[-1]-xs[0]+28,0)[0],point(0,16)[1]]]
        objects.append(p)
    return scene('LondonDocklands',705,(861,848),objects,
        {'TransitEntrance':anchor(930,748),'LocalSpot':anchor(808,759)},[
            sign((791,350,302,54),'CANARY WHARF','#286083',size=25),
            sign((1370,431,234,190),'Offices  ↑\nShops    →\nDLR      →','#18283e',size=26)],
        interaction_sizes={'TransitEntrance':{'CollisionShape2D':[64,34]},
                           'LocalSpot':{'CollisionShape2D':[64,34]}})


def seats(name, xs, top, width, seat_y, bottom):
    polys=[]
    for x in xs:
        polys += [[[x+5,top],[x+width-5,top],[x+width,top+5],
                   [x+width,seat_y-12],[x+width-4,seat_y-8],
                   [x+4,seat_y-8],[x,seat_y-12],[x,top+5]],
                  [[x,seat_y],[x+width,seat_y],[x+width+4,seat_y+7],
                   [x+width+4,seat_y+27],[x-4,seat_y+27],[x-4,seat_y+7]]]
    left, right=xs[0]-4, xs[-1]+width+4
    polys.append(rect(left,seat_y+34,right-left,6))
    for x in [left+4,(left+right)/2-5,right-14]:
        polys += [rect(x,seat_y+27,11,bottom-seat_y-27),rect(x-2,bottom-5,16,5)]
    return object_(name,bottom,[(left,seat_y+24,right-left,bottom-seat_y-24)],polys)


def plant(name,pot,leaves,stem):
    x,y,w,h=pot
    return object_(name,y+h,[(x+3,y+h-17,w-6,17)],
        [[[x,y],[x+w,y],[x+w-7,y+h],[x+7,y+h]],*stem],foliage=[rect(*leaves)])


def exchange():
    objects=[object_('counter',659,[(617,630,807,29)],
        [rect(616,517,810,142),rect(1036,435,52,72),rect(990,466,54,51),
         rect(1283,439,49,77),rect(1372,485,20,31),rect(1180,491,21,20)],
        glass=[rect(967,184,456,333)]),
        plant('plant',(229,598,74,85),(211,439,110,159),[rect(258,534,15,65)]),
        seats('chair',[395],572,77,642,730),
        object_('queue_post',768,[(1313,750,53,18)],[
            [[1328,618],[1324,611],[1324,599],[1331,591],[1345,591],[1353,601],
             [1353,610],[1346,619],[1346,747],[1364,750],[1365,764],[1313,766],
             [1312,753],[1330,747],[1330,619]]]),
        object_('validator',756,[(1530,742,55,14)],[
            [[1536,548],[1576,548],[1580,555],[1580,742],[1586,747],
             [1584,753],[1530,753],[1530,746],[1536,741]],rect(1470,552,65,10)])]
    return scene('LondonExchange',651,(830,816),objects,
        {'Booth':anchor(1150,699),'Exit':anchor(103,683)},[
            sign((570,96,558,63),'BUREAU DE CHANGE','#e6ddc8','#17202c',29),
            sign((287,214,310,165),'NO COMMISSION\nBetter rates\nFor a fairer world','#e6ddc8','#17202c',20),
            sign((710,224,219,55),'GBP   1.00','#192e37',size=20),
            sign((710,300,219,52),'USD   1.27','#192e37',size=20),
            sign((710,369,219,56),'EUR   1.16','#192e37',size=20),
            sign((710,438,219,55),'CNY   9.12','#192e37',size=20)],
        clerks={'Booth':anchor(1150,625)},
        interaction_sizes={'Booth':{'CollisionShape2D':[92,38]},'Exit':{'CollisionShape2D':[65,36]}})


def hospital():
    objects=[object_('reception',637,[(425,610,480,27)],
        [rect(425,505,480,132),rect(425,295,13,211),rect(892,295,13,211),
         rect(425,295,480,17),rect(794,365,61,139),rect(648,467,110,37),
         rect(458,399,17,45),rect(481,398,20,46),rect(511,407,24,38),
         rect(838,457,42,47)],glass=[rect(438,312,454,193)]),
        seats('waiting_west',[305,424,543,660],607,95,699,775),
        seats('waiting_east',[927,1042,1158,1274],607,91,699,775),
        plant('plant',(1203,567,70,76),(1188,341,104,226),[rect(1231,472,15,96)]),
        object_('water_cooler',646,[(1332,626,85,20)],[
            [[1333,491],[1343,485],[1343,426],[1350,413],[1395,413],[1404,425],
             [1404,485],[1416,492],[1416,645],[1332,645]]]),
        object_('cabinet',671,[(1536,649,89,22)],[rect(1536,410,89,260)])]
    return scene('LondonHospital',636,(823,837),objects,
        {'Triage':anchor(812,680),'Exit':anchor(93,669)},[
            sign((753,96,358,49),'Accident & Emergency','#e5ebef','#131a48',22),
            sign((235,140,122,208),'A104\nB218\nC093\nC094','#0d1725','#47bade',25),
            sign((1360,138,250,216),'Triage  ←\nConsultations  →\nPharmacy  →\nToilets  →','#17273e',size=21)],
        clerks={'Triage':anchor(665,609)},
        interaction_sizes={'Triage':{'CollisionShape2D':[80,40]},'Exit':{'CollisionShape2D':[64,35]}})


def police():
    objects=[object_('counter',557,[(775,530,576,27)],
        [rect(770,427,584,19),rect(778,446,565,110),rect(904,371,70,50),
         rect(999,402,109,24),rect(782,204,17,222),rect(1325,202,19,227),rect(781,202,562,19)],
        glass=[rect(799,221,526,205)]),
        object_('bin',571,[(251,554,84,17)],[
            [[249,475],[335,475],[337,493],[332,493],[332,568],[252,568],[252,493],[249,491]]]),
        plant('plant',(1597,497,75,62),(1584,358,88,143),[rect(1629,432,12,66)]),
        seats('waiting',[112,233,350],697,95,758,828)]
    # These belts are straight, unlike the sagging ropes outside the Soho venue.
    poles=rope_group('queue_barrier',[559,795,1061],744,881)
    poles['polygons']=poles['polygons'][:3]+[
        [point(x,y) for x,y in rect(568,769,218,15)],
        [point(x,y) for x,y in rect(804,769,248,15)]]
    objects.append(poles)
    return scene('LondonPolice',549,(706,672),objects,
        {'Counter':anchor(1060,600),'Exit':anchor(128,580)},[
            sign((740,116,220,48),'POLICE','#203c66',size=31),
            sign((1380,216,182,23),'INTERVIEW','#233c58',size=14),
            sign((287,242,108,81),'A SAFER\nLONDON\nTOGETHER','#ede5d8','#1c314c',14),
            sign((604,331,127,43),'COMMUNITY\nSUPPORT','#ede5d8','#1c314c',13)],
        clerks={'Counter':anchor(1080,528)},
        interaction_sizes={'Counter':{'CollisionShape2D':[100,38]},'Exit':{'CollisionShape2D':[65,36]}})


def airport():
    objects=[object_('check_in',584,[(697,558,465,26)],
        [rect(696,518,548,64),rect(871,471,59,49),rect(951,499,89,19),
         rect(1092,484,69,33)]),
        object_('check_in_bin',595,[(1164,580,64,15)],[rect(1162,492,65,102)]),
        plant('west_plant',(163,640,57,54),(143,555,96,88),[rect(183,610,10,31)]),
        plant('window_plant',(511,541,49,48),(502,493,65,51),[rect(531,523,7,20)]),
        seats('waiting_west',[150,240,331,418,508,576],764,76,837,894),
        seats('waiting_east',[945,1034,1125,1214,1305],764,76,837,894)]
    queue=rope_group('queue',[282,490,697,907,1113],609,707)
    queue['polygons']=queue['polygons'][:5]+[[point(x,y) for x,y in rect(a+5,627,b-a-10,10)] for a,b in zip([282,490,697,907],[490,697,907,1113])]
    objects.append(queue)
    trolley_polys=[]
    for x in [1500,1540,1586,1630]:
        trolley_polys += [rect(x-5,693,6,86),rect(x-11,682,25,9),
                         rect(x-10,778,21,13)]
    for a,b in [(1500,1540),(1540,1586),(1586,1630)]:
        trolley_polys += [rect(a+2,698,b-a-7,4),rect(a+2,764,b-a-7,5)]
    objects.append(object_('trolleys',793,[(1489,772,152,21)],trolley_polys))
    return scene('LondonAirport',582,(816,747),objects,
        {'BagDrop':anchor(972,618),'Exit':anchor(1610,645)},[
            sign((601,176,286,71),'Departures','#073267',size=30),
            sign((771,323,376,47),'CHECK-IN','#682836',size=24),
            sign((1373,401,243,186),'Gates 1–24  →\nBaggage  →\nToilets  ↑','#073267',size=23)],
        clerks={'BagDrop':anchor(1010,561)},
        interaction_sizes={'BagDrop':{'CollisionShape2D':[100,37]},'Exit':{'CollisionShape2D':[70,40]}})


def hotel():
    objects=[object_('reception',570,[(716,543,515,27)],
        [rect(712,417,520,151),rect(982,360,61,59),rect(1118,382,68,36),
         rect(752,402,32,15)]),
        plant('plant_west',(373,493,55,52),(355,344,85,151),[rect(392,431,11,63)]),
        plant('plant_desk',(1254,509,63,60),(1234,397,111,114),[rect(1280,460,9,50)]),
        plant('plant_front',(1309,741,85,61),(1283,615,139,129),[rect(1343,687,13,55)]),
        object_('armchair',558,[(447,520,161,38)],[
            [[463,386],[594,386],[594,449],[610,452],[613,535],[599,535],
             [599,557],[583,557],[583,539],[467,539],[467,557],[450,557],
             [450,535],[443,535],[443,454],[460,448]]]),
        object_('side_table_lamp',553,[(623,530,91,23)],[
            rect(625,468,84,15),rect(627,482,10,63),rect(692,482,11,61),
            rect(639,450,48,17),rect(696,365,9,103),
            [[656,365],[674,314],[727,314],[743,365]],rect(687,538,30,11)]),
        object_('ottoman',797,[(173,760,217,37)],[
            [[175,705],[190,679],[393,680],[393,752],[172,752]],
            rect(174,753,17,43),rect(370,753,17,42)]),
        object_('coffee_table',796,[(420,756,205,40)],[
            [[419,708],[623,708],[629,728],[629,744],[415,744],[415,729]],
            rect(423,744,13,49),rect(610,744,14,49),rect(451,666,69,58),
            rect(550,706,43,16)]),
        object_('luggage',563,[(1517,535,141,28)],[
            rect(1535,435,59,99),rect(1592,431,56,105),rect(1539,420,30,21),
            rect(1515,533,147,17),rect(1522,549,19,13),rect(1631,549,20,13),
            rect(1522,403,7,132),rect(1651,403,7,132),
            tube((1527,404),(1541,381),7),tube((1541,381),(1570,367),7),
            tube((1570,367),(1612,367),7),tube((1612,367),(1640,381),7),
            tube((1640,381),(1654,404),7),rect(1585,351,10,17)])]
    return scene('LondonHotel',543,(906,682),objects,
        {'Desk':anchor(965,610),'Exit':anchor(123,580)},[
            sign((827,149,361,46),'RECEPTION','#162235',size=28),
            sign((1390,104,184,57),'ROOMS 1–6\nFIRST FLOOR','#162235',size=16),
            sign((462,674,47,39),'WELCOME','#e6e2d2','#24302d',7,object='coffee_table')],
        clerks={'Desk':anchor(970,535)},
        interaction_sizes={'Desk':{'CollisionShape2D':[100,38]},'Exit':{'CollisionShape2D':[64,35]}})


def caff():
    objects=[object_('kitchen_counter',600,[(586,573,913,27)],
        [rect(587,406,913,194),rect(601,310,138,95),rect(962,319,49,86),
         rect(834,399,55,87),rect(775,368,31,37),rect(1000,368,35,35),
         rect(1110,354,218,124),rect(1335,310,43,95)]),
        object_('banquette_left',766,[(214,648,565,118)],
            [rect(216,500,564,213),rect(213,713,22,52),rect(759,711,21,52),rect(237,713,523,20)]),
        object_('banquette_right',766,[(947,648,690,118)],
            [rect(949,500,688,213),rect(946,713,22,52),rect(1615,711,21,52),rect(969,713,646,20)]),
        plant('counter_plant',(1530,424,64,84),(1517,315,94,141),[rect(1554,391,15,35)])]
    for label,x in [('left',307),('right',1340)]:
        objects.append(object_(label+'_table',800,[(x+17,763,185,37)],[
            [[x,615],[x+215,615],[x+221,662],[x+221,680],[x-6,680],[x-6,663]],
            rect(x+17,680,20,117),rect(x+177,680,20,117),
            rect(x+39,578,19,55),rect(x+64,569,23,63),rect(x+89,596,18,38),
            rect(x+140,626,18,20)]))
    for label,x in [('left',601),('right',1143)]:
        objects.append(object_(label+'_chair',791,[(x-6,766,89,25)],[
            rect(x+8,607,67,104),rect(x,704,84,20),
            tube((x+7,721),(x,788),11),tube((x+73,721),(x+82,788),11),
            rect(x+13,724,8,60),rect(x+65,724,8,59)]))
    objects.append(object_('west_wall',640,[(0,595,211,45)],[]))
    return scene('LondonCaff',599,(851,834),objects,
        {'Hatch':anchor(859,628),'Exit':anchor(107,670)},[
            sign((646,83,380,61),'THE DAILY CUP','#dec39a','#171811',29),
            sign((267,162,252,206),'Tea       2.00\nCoffee   2.50\nLatte     2.80\nPastry   2.20','#1b2228',size=21)],
        clerks={'Hatch':anchor(943,565)},
        interaction_sizes={'Hatch':{'CollisionShape2D':[85,38]},'Exit':{'CollisionShape2D':[70,40]}})


def underground():
    objects=[seats('bench',[360,429,498,567],471,62,520,568)]
    for index,x in enumerate([476,789,1088]):
        objects.append(object_('validator_'+str(index),870,[(x,839,87,31)],
            [[[x+3,684],[x+84,684],[x+87,689],[x+87,868],[x,868],[x,689]]]))
    return scene('LondonUnderground',568,(696,710),objects,
        {'Exit':anchor(176,599),'Machine':anchor(1131,904),
         'Platform':anchor(1184,621),'ToAirport':anchor(1584,688)},[
            sign((97,246,151,42),'Way out ↑','#1c242d',size=20),
            sign((451,261,330,48),'ALDGATE EAST','#e9dfcc','#132238',26),
            sign((1513,297,138,102),'A\nBRIGHTER\nLONDON','#ece4d4','#172b43',18),
            sign((1099,763,64,51),'TICKETS\nTOUCH','#18242f',size=9,object='validator_2')],
        motion_layers=[{'kind':'doors','rect':[*point(1087,340),*point(163,194)]}],
        interaction_sizes={'Exit':{'CollisionShape2D':[72,38]},
                           'Machine':{'CollisionShape2D':[76,34]},
                           'Platform':{'CollisionShape2D':[100,40]},
                           'ToAirport':{'CollisionShape2D':[70,38]}})
