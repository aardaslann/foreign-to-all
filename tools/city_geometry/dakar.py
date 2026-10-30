"""Dakar source inventory, realigned to the installed replacement pixel art.

Coordinates describe the 1672x941 paintings. Real doors and front approaches
retain their services; beach/market transit links receive a visible bus stop.
"""
from math import cos, sin, tau
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import scene, pot, oval, board
from .seoul import box, stool
from .hanoi import pole, route_post
from .rome import sizes


def barrel(name,x,y,w,h):
    return object_(name,y+h,[(x+4,y+h-18,w-8,18)],[
        [[x+5,y],[x+w-5,y],[x+w-2,y+7],[x+w-8,y+14],
         [x+w-3,y+25],[x+w,y+38],[x+w,y+h-15],[x+w-9,y+h],
         [x+9,y+h],[x,y+h-15],[x,y+38],[x+3,y+25],[x+8,y+14],[x+2,y+7]]])


def seat_row(name,x,y,n,w=83):
    polys=[rect(x,y+103,n*w+16,8)]
    for i in range(n):
        xx=x+10+i*w
        polys += [rect(xx,y,w-6,71),rect(xx-2,y+73,w-2,12)]
    for xx in [x,x+n*w/2,x+n*w+6]:
        polys += [rect(xx,y+48,8,78),rect(xx-2,y+123,14,6)]
    return object_(name,y+129,[(x,y+105,n*w+14,24)],polys)


def wicker_chair(name,x,y,w=134,h=135):
    return object_(name,y+h,[(x+3,y+h-24,w-6,24)],[
        rect(x+22,y,w-34,80),rect(x,y+48,w,11),rect(x+10,y+78,w-16,14),
        rect(x+3,y+59,12,h-59),rect(x+w-25,y+59,12,h-59),
        rect(x+16,y+102,w-36,10)])


def medina():
    obs=[object_('west_tree',666,[(0,637,122,29)],[
            rect(0,605,122,61),[[17,606],[21,449],[2,412],[0,384],[8,393],
            [28,423],[26,325],[42,316],[53,396],[78,376],[87,335],[99,336],
            [89,389],[65,422],[57,605]]],foliage=[rect(0,76,195,325)],wood_branches=True),
         pot('tailor_tree',(426,574,67,79),(396,414,179,158),[
             tube((458,574),(466,483),12),tube((465,526),(504,489),9),
             tube((459,559),(428,521),7)]),
         pot('east_plant',(1623,594,49,56),(1601,498,71,101)),
         board('west_tailor_board',483,541,95,120),board('east_tailor_board',984,549,85,111),
         barrel('west_barrels',136,504,59,130),barrel('blue_barrel',1279,528,55,114),
         barrel('small_jar',1358,569,45,78),barrel('east_barrel',1404,527,70,119),
         object_('west_cloth_rack',644,[(612,621,142,23)],[
             rect(614,438,139,10),rect(613,429,12,210),rect(738,428,13,214),
             rect(626,437,107,139),rect(632,611,82,32),
             rect(628,533,109,9),rect(612,632,18,11),rect(734,633,20,10),
             oval(661,605,26,14),oval(701,607,34,13)]),
         object_('east_cloth_rack',639,[(1097,615,113,24)],[
             rect(1097,429,12,210),rect(1195,430,12,209),rect(1105,436,98,10),
             rect(1111,438,85,102),rect(1108,584,89,11),
             [[1113,538],[1122,538],[1122,579],[1113,589]],rect(1099,631,20,8),rect(1191,632,20,7)]),
         object_('sewing_table',646,[(765,622,161,24)],[
             rect(758,537,169,14),rect(773,550,17,95),rect(895,550,15,95),
             rect(790,550,105,13),rect(772,527,30,11),rect(820,527,75,11),
             [[828,531],[828,499],[841,499],[842,506],[859,505],[864,499],
              [880,499],[886,506],[882,518],[851,518],[850,529]],
             rect(888,497,5,32),oval(888,507,6,14)]),
         stool('tailor_stool',813,584,62,63)]
    for name,x,top,bottom,w in [('west',536,300,650,21),('middle',953,299,654,20),
                                 ('east',1344,145,658,24)]:
        obs.append(pole(name+'_awning_post',x,top,bottom,w))
    # The canopy belongs to the posts' ground plane, not to a rectangular crop.
    obs.append(object_('tailor_awning',650,[(529,635,18,15),(944,635,18,15)],[[
        [514,316],[950,317],[943,349],[923,369],[855,378],[762,385],
        [659,374],[611,359],[546,332]]]))
    obs.append(object_('blue_awning',655,[(947,640,18,15),(1335,640,18,15)],[[
        [960,318],[1036,331],[1151,338],[1245,332],[1341,315],[1321,340],
        [1280,365],[1205,375],[1127,377],[1048,368],[984,344]]]))
    return scene('DakarMedina',636,(790,801),obs,{
        'HotelDoor':anchor(312,681),'ExchangeDoor':anchor(1240,687),
        'TransitDoor':anchor(1550,685),'LocalSpot':anchor(835,706),
        'NpcOusmane':anchor(410,790),'ExitEast':anchor(1620,820)},[
        sign((237,377,137,23),'HÔTEL','#7d3e37',size=16),
        sign((1171,388,90,18),'CHANGE','#e6d3a3','#343b36',size=12),
        sign((1488,370,134,20),'TRANSPORT','#23675d',size=14)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def sandaga():
    obs=[box('west_cart_boxes',1,479,75,154),box('west_green_boxes',190,481,65,148),
         box('east_boxes',1593,522,63,116),
         object_('west_handcart',657,[(0,634,148,23)],[rect(0,630,148,9),
             oval(17,646,11,11),oval(94,646,11,11),oval(135,646,11,11),
             rect(87,518,7,114),rect(135,518,7,113),rect(85,516,65,8),
             rect(95,559,36,71),tube((94,555),(135,526),5)]),
         object_('delivery_van',644,[(1443,620,136,24)],[
             [[1447,472],[1572,472],[1578,480],[1578,558],[1581,564],
              [1579,626],[1573,632],[1573,643],[1552,643],[1548,625],
              [1468,625],[1466,643],[1445,643],[1443,624],[1440,606],
              [1443,560],[1443,478]],rect(1430,537,11,19),rect(1578,536,10,21)])]
    for i,(x,w,top) in enumerate([(265,140,474),(433,188,503),(1055,184,501),(1269,138,474)]):
        # Produce has its own scalloped upper edge above the cabinet outline.
        shape=[[x,top+48],[x+8,top+31],[x+11,top+12],[x+25,top+1],
               [x+37,top+8],[x+51,top+3],[x+66,top+17],[x+80,top+9],
               [x+99,top+16],[x+w-17,top+9],[x+w-3,top+22],[x+w-4,top+48]]
        obs.append(object_('produce_stall_'+str(i),633,[(x,611,w,22)],[shape,
            rect(x,top+48,w,17),rect(x,top+64,9,631-top-64),
            rect(x+w-9,top+64,9,631-top-64),rect(x+8,555,w-16,68)]))
    for i,x in enumerate([769,889]):obs.append(pole('entrance_bollard_'+str(i),x+7,501,606,14))
    post,fixture=route_post('airport_bus_stop',1480,716,'AÉROPORT\nBUS')
    obs.append(post)
    return scene('DakarSandaga',610,(835,812),obs,{
        'AirportDoor':anchor(1480,768),'TransitDoor':anchor(840,652),
        'LocalSpot':anchor(519,686),'NpcAwa':anchor(1104,778),'ExitWest':anchor(53,801)},[
        sign((714,241,246,60),'SANDAGA','#eed8a8','#292923',size=34)],
        fittings=[fixture],interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def plateau():
    obs=[pot('west_tree',(40,638,64,29),(0,328,197,184),[
             [[52,638],[60,500],[37,477],[42,466],[66,484],[79,460],[89,469],[81,637]]]),
         pot('west_pot',(104,620,41,47),(101,571,46,54)),
         pot('middle_tree',(697,608,73,61),(620,291,224,157),[
             rect(719,425,25,185),tube((727,454),(685,417),13),tube((737,467),(777,415),12)]),
         pot('middle_palm',(1072,609,72,60),(1000,237,206,201),[
             [[1092,610],[1095,409],[1104,376],[1118,390],[1119,610]]]),
         pot('east_palm',(1607,639,43,28),(1510,230,162,209),[
             [[1606,639],[1609,420],[1617,373],[1636,376],[1641,637]]]),
         pot('white_planter',(1450,628,80,41),(1438,560,99,70)),
         pot('black_planter',(1547,627,60,42),(1535,578,74,52)),
         board('cafe_menu',518,566,67,104),
         object_('news_kiosk',669,[(1166,643,267,26)],[rect(1166,478,267,190),
             rect(1163,420,275,59)]),pole('glass_entry_bollard',894,568,670,24)]
    for i,x in enumerate([158,339]):
        obs.append(object_('cafe_umbrella_'+str(i),664,[(x+53,641,87,23)],[
            [[x,544],[x+29,520],[x+72,503],[x+112,503],[x+157,520],[x+190,544]],
            rect(x+91,544,8,70),rect(x+52,611,88,11),rect(x+92,622,10,36),rect(x+78,655,38,8)]))
        for j,cx in enumerate([x+17,x+116]):
            obs.append(object_('cafe_chair_'+str(i)+'_'+str(j),669,[(cx,649,52,20)],[
                rect(cx+4,603,44,30),rect(cx,633,52,8),rect(cx+3,641,7,28),
                rect(cx+42,641,7,28)]))
    return scene('DakarPlateau',647,(940,813),obs,{
        'TransitDoor':anchor(943,693),'LocalSpot':anchor(634,694)},[
        sign((1192,432,215,31),'PRESSE','#233c44',size=24,object='news_kiosk'),
        sign((524,578,52,69),'CAFÉ\nTHÉ\nJUS','#243a38',size=9,object='cafe_menu')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def ouakam():
    obs=[pole('utility_pole',219,163,646,18),pot('door_pot',(152,613,31,38),(148,575,36,40)),
         box('small_teal_can',484,609,28,46),box('net_crate',698,603,56,50),
         object_('float_crate',656,[(772,636,72,20)],[rect(772,606,72,50),
             oval(796,589,17,19),oval(822,586,20,20)]),
         object_('folded_cloth',653,[(701,634,51,19)],[rect(703,594,48,10)]),
         object_('boat',662,[(1296,623,317,39)],[
             [[1249,551],[1301,554],[1417,551],[1507,547],[1600,528],[1659,525],
              [1666,535],[1646,568],[1630,601],[1598,627],[1530,641],[1436,643],
              [1338,624],[1298,600],[1271,572]],
             tube((1319,622),(1301,654),17),tube((1320,623),(1341,650),14),
             rect(1507,624,17,36),tube((1520,635),(1546,650),14),
             tube((1594,634),(1605,654),18)],
             foliage=[rect(1249,474,85,82)],blue_handles=True),
         object_('round_floats',655,[(1172,633,57,22)],[
             oval(1196,566,24,24),oval(1198,600,26,22),oval(1198,632,25,23)])]
    for i,(x,y,w,h) in enumerate([(377,568,58,86),(437,570,51,84),(636,563,58,89),
                                  (882,543,66,111),(955,557,70,97),(1031,543,72,112),(1108,551,63,105)]):
        obs.append(barrel('fishing_barrel_'+str(i),x,y,w,h))
    # The coiled net surrounds a visible gap; trace the rings, not their box.
    rings=[]
    for rx,ry in [(31,80),(23,71),(15,60)]:
        pts=[(570+rx*cos(i*tau/32),573+ry*sin(i*tau/32)) for i in range(33)]
        rings += [tube(a,b,7) for a,b in zip(pts,pts[1:])]
    obs.append(object_('coiled_net',655,[(537,631,66,24)],rings))
    return scene('DakarOuakam',643,(1015,803),obs,{
        'TransitDoor':anchor(64,691),'LocalSpot':anchor(283,691)},[
        sign((15,404,102,16),'TRANSPORT','#533b2a',size=11)],
        animation_patches=[dict(kind='water',rect=[*point(718,239),*point(570,35)]),
                           dict(kind='water',rect=[*point(1190,334),*point(482,44)])],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def yoff():
    obs=[object_('west_pirogue',660,[(0,614,410,46)],[
             [[0,515],[96,531],[233,529],[364,513],[469,478],[537,460],
              [537,472],[513,501],[491,545],[456,584],[414,610],[354,633],
              [226,639],[121,629],[0,596]],
             tube((363,609),(358,653),18),tube((379,611),(399,641),18)]),
         object_('middle_pirogue',660,[(813,622,388,38)],[
             [[691,422],[704,420],[717,427],[735,439],[854,481],[990,517],
              [1111,525],[1216,515],[1259,510],[1257,522],[1246,550],
              [1223,584],[1184,615],[1120,632],[966,637],[867,622],[803,594],
              [753,551],[724,495],[707,450]],
             tube((833,620),(824,644),18),rect(867,610,25,41),oval(879,650,16,9)]),
         object_('east_pirogue',659,[(1487,624,185,35)],[
             [[1389,482],[1406,480],[1424,492],[1497,514],[1590,527],
              [1672,528],[1672,637],[1596,637],[1518,620],[1462,591],[1425,551],[1403,512]],
             tube((1506,621),(1495,644),18),rect(1522,610,22,42),oval(1532,650,14,8)]),
         box('west_crate',450,601,98,65),box('blue_box',737,603,67,60),
         box('red_box',1159,605,99,62),box('back_crate',1261,544,107,54),
         barrel('small_cyan_barrel',1399,592,65,67),
         object_('west_floats',664,[(95,644,89,20)],[oval(119,642,24,23),oval(159,633,26,30)]),
         pole('awning_west_post',1159,301,666,22),pole('awning_east_post',1569,317,633,23),
         object_('blue_beach_awning',666,[(1149,650,23,16),(1558,617,23,16)],[[
             [1120,323],[1132,322],[1189,332],[1315,345],[1454,350],[1583,336],
             [1606,332],[1599,343],[1573,349],[1539,384],[1481,410],
             [1402,417],[1323,411],[1234,391],[1160,350],[1120,333]],
             tube((1148,346),(1130,399),4)])]
    for i,(x,y,w,h) in enumerate([(0,547,56,117),(59,547,70,116),(1010,546,66,113),(1078,547,67,112)]):
        obs.append(barrel('beach_barrel_'+str(i),x,y,w,h))
    obs.append(object_('hanging_fishing_net',638,[(542,617,173,21)],[],foliage=[[
        [533,477],[551,481],[586,491],[634,481],[689,447],[705,447],[716,586],
        [708,610],[676,631],[640,638],[586,627],[562,607],[550,574]]],painted_metal=True))
    post,fixture=route_post('beach_bus_stop',1353,714,'BUS\nDAKAR')
    obs.append(post)
    return scene('DakarYoff',651,(927,801),obs,{
        'TransitDoor':anchor(1353,766),'LocalSpot':anchor(624,714)},[],
        fittings=[fixture],animation_patches=[dict(kind='water',rect=[*point(721,243),*point(750,58)])],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[pot('west_lobby_plant',(10,551,94,94),(0,356,140,198)),
         pot('desk_floor_plant',(1360,551,64,66),(1334,419,108,136)),
         wicker_chair('west_lobby_chair',328,479),wicker_chair('east_lobby_chair',478,479),
         object_('reception_counter',615,[(898,588,455,27)],[rect(897,458,455,14),
             rect(906,472,443,142),rect(1230,441,26,14),rect(936,436,41,21),
             [[1264,418],[1277,379],[1309,379],[1327,418]],rect(1289,418,9,15),
             oval(1294,442,10,13)],foliage=[rect(1223,428,37,17)]),
         object_('water_table',648,[(1519,622,132,26)],[rect(1518,476,133,15),
             rect(1521,491,15,155),rect(1634,491,15,155),rect(1544,561,86,78),
             rect(1537,554,96,11),rect(1554,523,17,30),rect(1590,521,16,32),
             [[1547,474],[1540,462],[1540,369],[1553,358],[1607,358],[1623,370],
              [1623,461],[1616,474]]])]
    return scene('DakarHotel',602,(822,742),obs,{
        'Point':anchor(1128,666),'Exit':anchor(232,650)},[
        sign((1041,211,259,56),'HÔTEL','#e7d3ac','#342b28',size=29)],
        clerks={'Point':anchor(1128,570)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[pot('exchange_plant',(66,570,77,80),(25,397,155,177)),
         box('west_bin',445,539,65,106),barrel('east_bin',1593,582,55,81),
         seat_row('waiting_seats',1180,502,4,81),
         object_('exchange_counter',635,[(551,610,501,25)],[rect(551,476,501,159),
             rect(762,439,78,37),rect(940,414,69,61),rect(594,418,54,55)],
             glass=[rect(578,292,451,181)]),
         object_('exchange_window_frame',635,[(551,618,501,17)],[
             rect(565,278,474,14),rect(565,291,12,186),rect(1027,291,12,186),
             rect(709,290,11,187),rect(883,290,10,187)])]
    return scene('DakarExchange',635,(800,752),obs,{
        'Point':anchor(801,687),'Exit':anchor(249,684)},[
        sign((678,190,251,57),'CHANGE','#204d76',size=35),
        sign((1111,207,193,193),'DEVISES\n\nUSD · EUR\nGBP · XOF','#192633','#ecd05a',size=23)],
        clerks={'Point':anchor(800,590)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[object_('west_column',651,[(198,625,48,26)],[rect(198,132,48,519),
             [[197,132],[141,0],[191,0],[245,132]]]),
         object_('east_column',651,[(1583,625,51,26)],[rect(1583,132,51,519),
             [[1583,132],[1518,0],[1567,0],[1633,132]]]),
         object_('route_map',651,[(23,628,161,23)],[rect(25,327,155,256),
             rect(26,583,15,67),rect(161,583,17,67),rect(22,643,22,8),rect(157,643,28,8)]),
         seat_row('station_seats',275,523,4,83),pole('station_bollard',670,548,651,26),
         box('station_bin',1365,531,58,120),box('ticket_machine',1445,386,107,265),
         object_('ticket_office',646,[(889,618,364,28)],[rect(889,516,364,120),
             rect(873,319,394,38),rect(889,359,13,157),rect(1240,359,13,157),
             rect(1013,370,10,146),rect(1158,370,10,146),rect(1053,485,76,30),
             rect(904,380,61,131),rect(1200,470,26,44)],
             glass=[rect(903,371,337,143)]),
         object_('bus_body',543,[(461,520,1123,23)],[rect(461,325,1123,218)])]
    return scene('DakarTransit',543,(806,732),obs,{
        'Machine':anchor(1498,701),'Platform':anchor(811,589),'Exit':anchor(119,704)},[
        sign((407,183,350,61),'DAKAR TRANSIT','#183b5b',size=29),
        sign((1402,169,157,124),'BUS\nDÉPARTS\nQUAI 1','#1a2834','#efd065',size=18),
        sign((882,323,376,29),'INFORMATIONS','#204465',size=21,object='ticket_office'),
        sign((55,587,91,22),'SORTIE','#263b49',size=13,object='route_map')],
        clerks={},interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[pot('airport_plant',(45,602,70,79),(25,422,119,181)),
         seat_row('airport_seats',126,565,3,81),box('airport_bin',404,576,50,83),
         pole('west_bollard',854,566,654,17),
         object_('checkin_desks',668,[(1028,643,607,25)],[rect(1029,584,605,84)])]
    for i,x in enumerate([1051,1250,1450]):
        obs.append(object_('checkin_terminal_'+str(i),667,[(x,648,115,19)],[
            rect(x,462,115,59),rect(x+56,521,6,23),rect(x+46,563,43,21)]))
    # These queue rails have open air below them; only their belt and poles occlude.
    railpolys=[rect(933,589,485,10)]
    for x in [931,965,1139,1334]:
        railpolys += [rect(x-5,585,10,97),rect(x-18,682,36,9),oval(x,589,9,8)]
    obs.append(object_('checkin_queue',692,[(915,674,438,18)],railpolys))
    cartpolys=[]
    for x in range(1420,1660,40):
        cartpolys += [rect(x-4,574,5,102),rect(x+27,574,5,102),rect(x-3,670,35,8),
                     rect(x,627,31,31),rect(x-5,566,36,9),oval(x+6,692,12,12)]
    obs.append(object_('luggage_carts',705,[(1416,681,238,24)],cartpolys))
    post,fixture=route_post('city_bus_stop',532,682,'BUS\nDAKAR')
    obs.append(post)
    return scene('DakarAirport',641,(740,766),obs,{
        'Point':anchor(1140,743),'Exit':anchor(532,736)},[
        sign((782,187,208,61),'DÉPARTS','#143653',size=31),
        sign((1165,249,451,140),'DESTINATIONS\nPARIS · LONDRES · DAKAR\nENREGISTREMENT','#172938','#edcf57',size=22),
        sign((1061,471,97,38),'01','#204d76',size=24,object='checkin_terminal_0'),
        sign((1260,471,97,38),'02','#204d76',size=24,object='checkin_terminal_1'),
        sign((1460,471,97,38),'03','#204d76',size=24,object='checkin_terminal_2')],
        fittings=[fixture],clerks={'Point':anchor(1140,610)},
        interaction_sizes=sizes('Point','Exit'))


def build():
    from .dakar_finish import finish
    return finish({'DakarMedina':medina(),'DakarSandaga':sandaga(),'DakarPlateau':plateau(),
            'DakarOuakam':ouakam(),'DakarYoff':yoff(),'DakarHotel':hotel(),
            'DakarExchange':exchange(),'DakarTransit':transit(),'DakarAirport':airport()})
