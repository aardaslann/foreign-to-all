"""Honolulu source geometry; replacement artwork measured by honolulu_finish."""
from math import sin, cos, pi
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import scene, pot, oval, board
from .seoul import box, stool
from .hanoi import pole, route_post
from .tokyo import wheel
from .rome import sizes


def picnic(name,x,y,w=143,h=62):
    return object_(name,y+h,[(x,y+h-23,w,23)],[rect(x+10,y,w-20,10),
        rect(x,y+27,w,10),tube((x+37,y+9),(x+18,y+h),10),
        tube((x+w-36,y+9),(x+w-20,y+h),10),rect(x+32,y+46,w-64,6)])


def metal_seats(name,x,y,n,w=79,h=114,back=61,seat=72,seat_h=17):
    polys=[rect(x,y+seat+seat_h,n*w+5,7)]
    for i in range(n):
        xx=x+5+i*w
        polys += [rect(xx,y,w-5,back),rect(xx-2,y+seat,w,seat_h),
                  rect(xx+4,y+back,5,seat-back),rect(xx+w-13,y+back,5,seat-back)]
    for xx in [x,x+n*w/2-4,x+n*w-8]:
        polys += [rect(xx,y+seat+seat_h+7,8,h-seat-seat_h-7),rect(xx-3,y+h-4,14,5)]
    return object_(name,y+h,[(x,y+h-25,n*w+5,25)],polys)


def waikiki():
    obs=[object_('west_palm',784,[(13,753,44,31)],[
             [[13,781],[29,585],[44,459],[70,439],[76,455],[57,583],[53,752],[58,782]]],
             foliage=[rect(0,289,188,281)],wood_branches=True),
         pot('hotel_tree_box',(462,718,123,58),(343,272,397,358),[
             [[504,716],[504,631],[480,610],[465,574],[475,568],[495,600],
              [515,611],[525,573],[539,566],[545,609],[567,574],[577,579],
              [552,627],[549,716]]]),
         object_('bus_palm',783,[(1006,756,31,27)],[
             [[1008,781],[1012,545],[1018,502],[1036,501],[1039,539],[1032,782]]],
             foliage=[rect(944,369,173,196)],wood_branches=True),
         pot('east_tree_box',(1587,715,69,67),(1549,405,123,312),[
             rect(1622,590,14,128),tube((1627,641),(1608,609),8)]),
         object_('front_flower_box',875,[(944,851,121,24)],[rect(944,817,121,20),
             rect(948,837,11,37),rect(1041,837,11,37),rect(958,838,83,7)],
             foliage=[rect(944,775,119,45)]),
         box('street_bin',554,776,43,98),
         object_('exchange_frame',815,[(648,795,18,20),(887,795,21,20)],[
             rect(651,480,249,92),rect(652,569,9,235),rect(893,569,9,235),
             rect(647,803,20,11),rect(887,803,22,11),
             [[672,576],[884,576],[892,626],[891,639],[664,638],[667,624]]]),
         object_('bus_frame',875,[(1065,851,18,24),(1300,851,22,24)],[
             rect(1088,477,207,95),rect(1068,543,10,324),rect(1304,541,11,326),
             rect(1062,866,21,9),rect(1298,866,24,9),
             [[1090,581],[1247,581],[1260,637],[1081,637]]]),
         object_('acai_stand',817,[(1333,790,239,27)],[rect(1334,550,242,10),
             [[1342,543],[1565,543],[1577,589],[1323,589]],
             rect(1333,592,9,218),rect(1553,592,12,221),rect(1451,714,117,67),
             rect(1447,613,111,86),rect(1459,782,10,32)],
             foliage=[rect(1445,698,115,17)])]
    for i,(x,y,h,w) in enumerate([(1337,606,210,38),(1375,608,206,37),(1413,606,206,36)]):
        obs.append(object_('surfboard_'+str(i),y+h,[(x+8,y+h-19,w-16,19)],[
            [[x+w/2,y],[x+w/2+6,y+7],[x+w-2,y+55],[x+w,y+h-49],
             [x+w-7,y+h-8],[x+w/2,y+h],[x+7,y+h-8],[x,y+h-48],[x+3,y+49],[x+w/2-6,y+7]]]))
    for i,x in enumerate([1455,1504]):obs.append(stool('acai_stool_'+str(i),x,746,32,72))
    return scene('HonoluluWaikiki',770,(851,837),obs,{
        'HotelDoor':anchor(268,815),'ExchangeDoor':anchor(774,825),
        'TransitDoor':anchor(1183,829),'LocalSpot':anchor(1455,853),
        'NpcKimo':anchor(434,819),'ExitEast':anchor(1620,845)},[
        sign((148,378,232,77),'HOTEL','#f1e7d2','#202b2d',size=36),
        sign((671,492,212,67),'EXCHANGE','#f1e7d2','#202b2d',size=29,object='exchange_frame'),
        sign((1101,490,180,68),'TheBus','#f1e7d2','#202b2d',size=29,object='bus_frame'),
        sign((1457,623,91,66),'AÇAÍ','#f1e7d2','#202b2d',size=26,object='acai_stand')],
        walk_bottom=point(0,890)[1],interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def chinatown():
    obs=[pole('street_post',152,384,654,11),
         pot('west_shop_plant',(343,573,36,40),(333,450,53,125)),
         pot('east_shop_plant',(766,574,37,40),(755,445,64,132)),
         pot('bus_stop_plant',(1119,569,43,45),(1119,502,45,70)),
         object_('left_market_cart',614,[(248,592,81,22)],[
             rect(247,543,84,10),rect(251,553,8,51),rect(322,553,7,51),
             rect(258,577,64,27),rect(251,552,74,24),
             oval(253,607,5,7),oval(286,607,5,7),oval(326,607,5,7)]),
         object_('produce_display',611,[(482,590,89,21)],[rect(482,567,89,44),
             rect(491,505,79,24),rect(492,544,77,23)],
             foliage=[rect(485,539,86,29)],painted_metal=True),
         box('fruit_display',629,538,87,73),box('shop_bin',727,581,34,73),
         object_('delivery_pallet',612,[(859,594,110,18)],[rect(864,513,46,40),
             rect(862,554,51,44),rect(917,533,45,29),rect(916,565,46,34),
             rect(857,599,110,7),rect(861,606,13,6),rect(953,606,13,6)]),
         object_('hand_truck',610,[(995,592,59,18)],[rect(999,584,55,14),
             rect(1026,529,6,59),rect(1028,527,25,6),
             tube((1039,552),(1053,538),4),oval(1004,604,7,6),oval(1044,604,6,6)]),
         object_('bus_stop',656,[(1168,636,19,20),(1418,636,21,20)],[
             rect(1169,352,261,76),rect(1170,427,11,219),rect(1422,427,11,220),
             rect(1164,646,24,10),rect(1418,646,23,10),
             [[1184,439],[1409,439],[1422,466],[1420,475],[1178,475]]])]
    post,fixture=route_post('airport_bus_stop',1577,656,'AIRPORT\nBUS')
    obs.append(post)
    return scene('HonoluluChinatown',612,(839,781),obs,{
        'AirportDoor':anchor(1577,709),'TransitDoor':anchor(1300,699),
        'LocalSpot':anchor(599,663),'NpcLani':anchor(581,774),'ExitWest':anchor(52,789)},[
        sign((478,391,182,47),'SUN KEE','#24754b',size=30),
        sign((1184,363,230,52),'TheBus','#f0e9da','#182228',size=29,object='bus_stop'),
        sign((1586,399,86,43),'BUS','#f0e9da','#af3a35',size=25)],
        fittings=[fixture],interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def kakaako():
    obs=[pot('cafe_west_plant',(549,592,47,47),(536,510,69,86)),
         pot('cafe_east_plant',(877,592,50,47),(871,496,61,98)),
         pot('east_palm_box',(1588,598,79,50),(1504,245,168,173),[
             [[1632,599],[1621,418],[1627,370],[1642,373],[1650,440],[1658,600]]]),
         picnic('picnic_west',974,584,154,59),picnic('picnic_east',1167,584,141,59),
         object_('street_bin',652,[(1262,631,41,21)],[rect(1262,580,41,70)]),
         object_('bus_stop',654,[(1338,633,20,21),(1565,633,20,21)],[
             rect(1334,364,253,73),rect(1340,437,11,208),rect(1571,437,10,208),
             rect(1335,645,24,9),rect(1566,645,21,9),
             [[1352,444],[1566,444],[1567,475],[1346,476]]])]
    for i,x in enumerate([6,97,163]):
        obs.append(object_('recycling_bin_'+str(i),645,[(x+6,625,77,20)],[
            rect(x,552,86,14),rect(x+6,566,74,72),rect(x+6,638,8,7),rect(x+72,638,8,7)]))
    for i,x in enumerate([730,771,812]):obs.append(stool('lunch_stool_'+str(i),x,590,33,51))
    return scene('HonoluluKakaako',631,(912,786),obs,{
        'TransitDoor':anchor(1462,696),'LocalSpot':anchor(1050,706)},[
        sign((303,372,190,35),'WORKS','#f0e6d1','#283135',size=26),
        sign((621,439,232,34),'PLATE LUNCH','#f0e6d1','#283135',size=24),
        sign((1349,376,215,47),'TheBus','#f0e6d1','#283135',size=27,object='bus_stop')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def manoa():
    obs=[object_('west_garden_wall',673,[(0,650,757,23)],[
             rect(0,561,251,111),rect(247,538,40,133),rect(393,539,39,134),
             rect(431,562,326,111),rect(285,563,109,9),rect(285,653,109,10)],
             foliage=[rect(0,468,197,95),rect(290,515,104,48)]),
         object_('garden_gate',673,[(756,649,354,24)],[rect(755,526,57,147),
             rect(937,526,59,147),rect(996,563,112,110),
             [[813,541],[840,527],[874,522],[909,527],[938,541],[938,550],
              [909,536],[879,532],[879,664],[874,664],[874,532],[841,536],[813,550]],
             rect(812,543,8,129),rect(929,543,8,129),rect(812,665,125,8)]),
         pole('utility_pole',209,62,702,24),
         object_('porch_posts',674,[(1122,651,16,23),(1291,651,14,23)],[
             rect(1122,455,16,219),rect(1291,454,14,220),rect(1132,455,160,12)]),
         pot('mart_flower_box',(1341,620,98,51),(1340,551,103,70)),
         pot('mart_east_planter',(1559,619,106,55),(1568,531,90,91))]
    # Gate rods and bicycle wheels preserve the air between them.
    for obj,x0,x1 in [(obs[0],294,394),(obs[1],824,929)]:
        obj['polygons'] += [[point(*p) for p in rect(x,566 if x<400 else 546,6,91 if x<400 else 116)]
                            for x in range(x0,x1,19)]
    obs[2]['polygons'] += [[point(*p) for p in poly] for poly in [
        rect(174,93,76,11),rect(175,136,80,10),rect(193,168,31,63)]]
    bike=[]
    for cx in [1166,1251]:bike += wheel(cx,631,31)
    for a,b,w in [((1166,631),(1190,590),5),((1190,590),(1200,634),5),
                  ((1200,634),(1166,631),5),((1190,590),(1223,590),5),
                  ((1223,590),(1251,631),5),((1200,634),(1223,590),5),
                  ((1190,590),(1183,576),5),((1223,590),(1230,575),5),
                  ((1230,575),(1239,575),6)]:bike.append(tube(a,b,w))
    bike += [rect(1169,570,22,6),oval(1200,634,9,9)]
    obs.append(object_('mart_bicycle',664,[(1137,647,145,17)],bike))
    # White flowers in the planter must occlude along with its green leaves.
    obs[4]['polygons'] += [[point(*p) for p in oval(x,y,6,4)] for x,y in
                          [(1362,564),(1384,558),(1412,558),(1406,575),(1371,584)]]
    post,fixture=route_post('valley_bus_stop',1049,717,'TheBus')
    obs.append(post)
    return scene('HonoluluManoa',665,(913,806),obs,{
        'TransitDoor':anchor(1049,769),'LocalSpot':anchor(876,716)},[
        sign((1380,401,230,33),'MĀNOA MART','#f0e8d8','#202d31',size=27)],
        fittings=[fixture],interaction_sizes=sizes('TransitDoor','LocalSpot'))


def northshore():
    obs=[pot('surf_shop_plant',(373,620,40,42),(365,500,64,122)),
         board('surf_board',338,601,51,88),
         pot('food_truck_flowers',(1297,638,43,50),(1287,580,66,65)),
         pot('east_pot',(1626,614,40,45),(1619,578,53,39)),
         picnic('umbrella_table_west',622,622,141,61),picnic('umbrella_table_east',830,622,141,61),
         object_('pergola',662,[(774,638,18,24),(1008,638,17,24)],[
             rect(775,457,18,203),rect(1008,453,17,207),rect(744,451,282,19),
             [[715,400],[1011,400],[1048,437],[1043,453],[713,453]]]),
         object_('food_truck',660,[(1052,629,275,31)],[
             [[1074,474],[1311,474],[1330,495],[1333,509],[1331,523],[1343,573],
              [1342,625],[1336,642],[1316,645],[1110,645],[1064,637],[1049,631],
              [1048,621],[1059,616],[1054,500]],oval(1160,638,23,23),oval(1297,638,22,23)]),
         object_('bus_shelter_frame',698,[(1358,677,21,21),(1601,677,23,21)],[
             rect(1355,398,264,77),rect(1359,474,12,215),rect(1606,474,11,216),
             rect(1354,689,22,9),rect(1601,689,24,9),
             [[1369,479],[1605,479],[1605,517],[1371,517]]]),
         object_('bus_shelter_glass',663,[(1367,646,239,17)],[
             rect(1374,522,232,8),rect(1441,529,8,125),rect(1509,529,8,125),rect(1595,529,8,125)],
             glass=[rect(1376,530,218,123)]),
         object_('shelter_bench',666,[(1407,642,167,24)],[rect(1412,591,153,30),
             rect(1405,622,172,11),rect(1410,633,10,32),rect(1560,633,10,32)])]
    for i,x in enumerate([621,832]):
        obs.append(object_('cafe_umbrella_'+str(i),673,[(x+63,651,16,22)],[
            [[x,552],[x+30,534],[x+66,516],[x+70,511],[x+78,516],[x+114,535],
             [x+143,552],[x+143,563],[x,563]],rect(x+68,563,7,105)]))
    for i,x in enumerate([516,563,610]):
        obj=stool('shave_ice_stool_'+str(i),x,615,40,48)
        obj['foliage']=[[point(*p) for p in rect(x-2,597,44,20)]]
        obs.append(obj)
    for i,x in enumerate([36,77,115]):
        obs.append(object_('surfboard_'+str(i),663,[(x+4,644,29,19)],[
            [[x+16,499],[x+23,505],[x+31,543],[x+32,619],[x+25,650],
             [x+16,662],[x+6,650],[x,619],[x+1,543],[x+9,505]]]))
    return scene('HonoluluNorthShore',653,(864,795),obs,{
        'TransitDoor':anchor(1487,713),'LocalSpot':anchor(583,714)},[
        sign((32,420,274,43),'SURF SUPPLY','#397ea1',size=29),
        sign((436,418,209,44),'SHAVE ICE','#f0e3ce','#bd3935',size=29),
        sign((1371,410,232,52),'TheBus','#f0e3ce','#1d282d',size=30,object='bus_shelter_frame')],
        animation_patches=[dict(kind='water',rect=[*point(1157,400),*point(97,69)])],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[pot('lobby_west_plant',(260,523,143,83),(275,254,130,270)),
         pot('lobby_east_plant',(863,520,90,85),(855,303,111,219),[
             rect(898,421,16,101)]),
         object_('reception_counter',605,[(405,576,443,29)],[rect(402,426,450,16),
             rect(407,442,440,161),rect(460,379,73,47),rect(437,409,9,16),
             rect(571,418,47,8),oval(593,411,16,9),rect(691,408,51,17),
             [[754,380],[762,337],[810,337],[820,380]],rect(781,380,10,37),rect(770,416,38,9)]),
         object_('coffee_table',616,[(1289,592,107,24)],[rect(1284,534,121,17),
             rect(1295,551,92,63),rect(1289,551,9,65),rect(1385,551,11,65)])]
    for name,x,mirrored in [('west_chair',1122,False),('east_chair',1420,True)]:
        # The broad woven back is solid; the space under the seat stays open.
        shift=43 if mirrored else 0
        obs.append(object_(name,616,[(x,590,145,26)],[rect(x+shift,475,102,120),
            rect(x+15,550,120,24),rect(x+6,518,140,12),rect(x+2,530,11,85),
            rect(x+133,530,11,85),rect(x+46,578,10,36)]))
    arc=[(267+62*cos(pi+i*pi/24),429+63*sin(pi+i*pi/24)) for i in range(25)]
    cart=[tube(a,b,9) for a,b in zip(arc,arc[1:])]+[
        rect(202,429,9,148),rect(325,429,9,148),rect(194,576,149,14),
        oval(218,603,15,14),oval(319,603,15,14),rect(262,357,11,20),oval(268,353,8,8)]
    obs.append(object_('luggage_trolley',617,[(193,590,150,27)],cart))
    return scene('HonoluluHotel',594,(830,734),obs,{
        'Point':anchor(629,655),'Exit':anchor(119,642)},[
        sign((532,204,166,94),'ALOHA\nHOTEL','#755236','#f0e4c8',size=29),
        sign((1395,232,158,48),'BUS MAP','#e8e4d4','#223641',size=28)],
        clerks={'Point':anchor(629,560)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[pot('exchange_tree',(541,521,68,66),(531,338,88,185),[
             rect(568,436,12,87)]),box('recycling_bin',1463,420,91,171),
         object_('postcard_rack',591,[(333,565,139,26)],[rect(335,423,133,151),
             rect(333,574,9,17),rect(463,574,9,17)]),
         object_('exchange_counter',591,[(634,564,568,27)],[rect(632,424,573,15),
             rect(635,439,567,151),rect(875,374,89,47),oval(920,366,16,16),
             rect(1067,361,67,58)],glass=[rect(650,247,537,176)]),
         object_('counter_window_frame',591,[(635,574,567,17)],[rect(638,238,558,9),
             rect(640,247,10,177),rect(1187,247,10,177),rect(813,247,6,177),rect(1017,247,6,177)])]
    return scene('HonoluluExchange',579,(899,741),obs,{
        'Point':anchor(918,643),'Exit':anchor(180,627)},[
        sign((652,156,534,70),'CURRENCY EXCHANGE','#eee4d2','#202d33',size=36),
        sign((1272,180,236,177),'CURRENCIES\nUSD · JPY\nEUR · CAD','#202729','#eee9d8',size=28),
        sign((336,159,109,37),'TRAVEL\nHONOLULU','#eee5d1','#38677b',size=14),
        sign((333,320,116,35),'DISCOVER OʻAHU','#eee5d1','#34494c',size=10)],
        clerks={'Point':anchor(918,546)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[metal_seats('platform_west_seats',62,475,3,74,105,60,70,12),
         metal_seats('foreground_seats',154,624,4,104,162,70,94,24),
         object_('central_column',716,[(394,681,177,35)],[rect(394,0,177,716)]),
         object_('west_column',579,[(287,554,79,25)],[rect(287,104,79,475)]),
         object_('east_column',655,[(1629,628,43,27)],[rect(1629,0,43,655)]),
         object_('station_bins',659,[(1341,632,172,27)],[rect(1343,501,171,158)]),
         object_('station_poster',655,[(1340,635,12,20)],[rect(1338,237,269,186),
             rect(1342,423,10,230)]),
         object_('platform_gate',592,[(640,575,101,17)],[rect(640,488,101,104)]),
         object_('train',583,[(573,554,766,29)],[rect(573,321,766,263)])]
    return scene('HonoluluTransit',613,(1018,768),obs,{
        'Machine':anchor(789,742),'Platform':anchor(848,657),'Exit':anchor(1574,746)},[
        sign((420,215,130,60),'ROUTES','#eee6d4','#293b47',size=27),
        sign((1470,276,125,111),'Aloha\nmoves\nyou','#eee6d4','#293b47',size=21),
        sign((145,182,129,38),'EXIT','#e8e0ce','#293b47',size=25)],
        fittings=[dict(kind='ticket',at=point(789,695))],clerks={},
        interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[pot('west_airport_plant',(21,663,69,69),(13,596,92,70)),
         pot('middle_flower_trough',(626,619,228,53),(623,575,232,49)),
         metal_seats('arrivals_seats',242,646,4,82,114),
         box('west_bin',142,609,56,85),box('east_bin',1628,609,44,97),
         object_('west_column',721,[(34,688,108,33)],[rect(34,132,109,588)]),
         object_('middle_column',674,[(1029,648,76,26)],[rect(1029,274,76,400)]),
         object_('east_column',679,[(1531,652,105,27)],[rect(1531,131,105,548)]),
         object_('luggage_carousel',750,[(947,685,711,65)],[
             [[976,676],[1083,670],[1083,651],[1112,648],[1538,648],[1566,653],
              [1566,673],[1643,679],[1658,689],[1658,725],[1650,730],[1648,746],
              [958,746],[955,732],[947,728],[947,689]],
             rect(1135,611,89,38),rect(1334,613,67,36),rect(1424,613,63,36),
             rect(1171,602,17,12),rect(1362,602,18,12),rect(1456,600,9,14)],
             animation_patches=[dict(kind='conveyor',rect=[*point(1096,673),*point(453,16)])]),
         object_('departures_board',671,[(1328,647,13,24)],[rect(1150,329,336,198),
             rect(1330,527,11,86)])]
    return scene('HonoluluAirport',659,(888,795),obs,{
        'Point':anchor(782,776),'Exit':anchor(1517,801)},[
        sign((447,177,346,58),'BAGGAGE CLAIM','#233542',size=34),
        sign((1086,177,125,58),'GATES','#233542',size=33),
        sign((1164,345,308,165),'DEPARTURES\n\nSYDNEY · TOKYO\nTORONTO · SEOUL','#192a34','#ead064',size=23,object='departures_board')],
        fittings=[dict(kind='ticket',at=point(782,729))],clerks={},
        prompt_overrides={'Point':'E — The check-in terminal'},interaction_sizes=sizes('Point','Exit'))


def build():
    from .honolulu_finish import finish
    return finish({'HonoluluWaikiki':waikiki(),'HonoluluChinatown':chinatown(),
            'HonoluluKakaako':kakaako(),'HonoluluManoa':manoa(),'HonoluluNorthShore':northshore(),
            'HonoluluHotel':hotel(),'HonoluluExchange':exchange(),
            'HonoluluTransit':transit(),'HonoluluAirport':airport()})
