"""La Paz layouts, realigned to inspected pixel artwork by lapaz_finish."""
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import scene, pot, oval, board, bench
from .seoul import box, stool
from .hanoi import pole, route_post
from .paris import lamp
from .honolulu import metal_seats
from .rome import sizes


def flowers(name,base,crown,petals=(),branches=()):
    obj=pot(name,base,crown,branches)
    obj['polygons'] += [[point(*p) for p in oval(x,y,5,5)] for x,y in petals]
    return obj


def elalto():
    obs=[object_('west_flower_shelf',675,[(49,650,103,25)],[rect(49,633,104,11),
             rect(51,644,9,28),rect(104,644,9,29),rect(60,645,37,29),rect(112,645,37,29)],
             foliage=[rect(47,575,107,62)]),board('lodging_notice',490,613,65,64),
         pot('change_door_plant',(671,669,30,14),(647,568,38,69),[rect(682,622,8,47)]),
         box('station_bin',1170,636,39,58),bench('station_bench',1542,629,67,47),
         lamp('foreground_lamp',1618,577,873,34),
         object_('fruit_stall',691,[(925,670,210,21)],[
             [[916,541],[946,514],[1121,514],[1140,542],[1137,555],[919,555]],
             rect(926,555,8,132),rect(1125,555,8,132),rect(932,658,193,24),
             rect(947,632,48,27),rect(947,626,65,10),rect(968,610,32,17),
             rect(954,575,37,39),rect(1018,629,27,27),
             [[1048,657],[1056,637],[1064,630],[1071,633],[1064,650],[1084,647],
              [1090,635],[1107,630],[1120,638],[1127,657]]],
             foliage=[rect(937,640,185,20)],painted_metal=True),
         object_('street_vendor_trolley',869,[(1495,846,104,23)],[rect(1497,778,100,52),
             rect(1496,831,103,10),rect(1503,841,8,14),rect(1590,840,7,14),
             oval(1506,860,8,9),oval(1591,860,8,9),rect(1561,811,40,19)])]
    return scene('LaPazElAlto',667,(801,823),obs,{
        'HotelDoor':anchor(300,713),'ExchangeDoor':anchor(755,714),
        'TransitDoor':anchor(1321,714),'LocalSpot':anchor(1024,741),
        'NpcRemedios':anchor(610,812),'ExitEast':anchor(1580,772)},[
        sign((169,433,264,52),'ALOJAMIENTO','#096b99',size=29),
        sign((616,433,270,52),'CAMBIO','#096b99',size=34),
        sign((1171,433,307,52),'TELEFÉRICO','#086b92',size=31)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def rodriguez():
    # Upper terraces remain background architecture. The central stair mouth is
    # the visible station approach; the front market objects stand on its terrace.
    obs=[object_('west_tree',699,[(0,670,29,29)],[rect(0,670,29,28),
             [[0,672],[5,581],[29,558],[33,542],[43,546],[35,572],[21,588],[19,671]]],
             foliage=[rect(0,438,111,133)],wood_branches=True),
         pot('west_small_pot',(32,641,38,56),(24,623,49,22)),
         object_('west_red_stall',701,[(88,677,215,24)],[
             [[88,573],[129,534],[292,534],[323,568],[318,588],[91,588]],
             rect(91,588,8,114),rect(298,588,8,112),rect(96,632,201,67),
             [[98,632],[106,614],[117,605],[137,607],[148,623],[160,626],
              [170,612],[187,605],[200,614],[215,624],[227,606],[244,600],
              [257,612],[271,609],[289,622],[292,632]]]),
         object_('west_blue_stall',699,[(328,674,282,25)],[
             [[325,539],[363,499],[583,499],[619,540],[615,555],[328,555]],
             rect(328,555,8,141),rect(606,555,9,138),rect(337,621,270,71),
             [[343,621],[348,608],[356,596],[369,590],[382,604],[389,615],
              [401,608],[423,594],[439,598],[450,612],[467,606],[490,590],
              [507,595],[517,613],[533,603],[550,606],[559,591],[572,594],[591,611],[601,621]]]),
         object_('middle_right_stall',698,[(966,674,104,24)],[
             [[963,507],[988,474],[1097,474],[1117,507],[1116,519],[965,519]],
             rect(967,519,8,172),rect(974,589,87,104),rect(977,566,71,25)]),
         object_('right_blue_stall',703,[(1082,680,224,23)],[
             [[1060,572],[1090,535],[1286,535],[1320,572],[1316,588],[1064,588]],
             rect(1085,587,8,116),rect(1094,663,145,36),rect(1302,587,8,111),
             [[1095,663],[1104,645],[1119,635],[1136,644],[1155,633],[1167,639],
              [1183,632],[1198,632],[1217,643],[1236,659]]]),
         object_('east_red_stall',769,[(1360,742,237,27)],[
             [[1350,612],[1373,578],[1571,578],[1600,613],[1598,628],[1350,628]],
             rect(1354,628,9,110),rect(1589,628,9,128),rect(1362,709,227,41),
             rect(1380,683,65,26),rect(1446,686,65,23),rect(1533,688,52,20)]),
         pot('center_flower_pot',(918,674,46,38),(914,637,67,42)),
         box('front_apple_box',968,679,51,22),box('west_fruit_box',154,683,60,26),
         object_('market_sacks',704,[(616,681,53,23)],[oval(629,686,16,18),oval(650,690,17,14),
             rect(622,660,9,13),rect(647,666,7,13)]),
         object_('east_sacks',703,[(1243,682,63,21)],[oval(1259,670,18,30),oval(1288,670,18,30),
             oval(1258,634,13,9),oval(1287,634,13,9)]),
         object_('blue_handcart',798,[(1420,776,83,22)],[rect(1440,725,62,50),
             tube((1439,773),(1353,713),8),rect(1332,708,30,7),
             oval(1430,785,12,13),oval(1489,786,11,13)]),
         object_('red_market_sack',796,[(1512,776,53,20)],[
             [[1519,739],[1537,733],[1554,737],[1558,749],[1552,766],[1566,791],
              [1557,796],[1517,796],[1509,790],[1520,767],[1516,751]]])]
    post,fixture=route_post('airport_bus_stop',83,775,'AEROPUERTO\nBUS')
    obs.append(post)
    return scene('LaPazRodriguez',700,(815,833),obs,{
        'AirportDoor':anchor(83,827),'TransitDoor':anchor(798,747),
        'LocalSpot':anchor(467,751),'ExitWest':anchor(53,894)},[],
        fittings=[fixture],interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def sopocachi():
    obs=[object_('garden_wall',674,[(0,650,1016,24)],[rect(0,525,1015,148)],
             foliage=[rect(0,447,1000,82),rect(181,490,243,73),rect(891,492,126,96)]),
         pole('west_lamp',49,328,709,10),pole('middle_lamp',540,354,709,14),
         flowers('lamp_flower_pot',(415,653,46,49),(412,605,52,49),[(439,622)]),
         board('cafe_menu',1134,589,73,100),
         flowers('cafe_flower_box',(1437,643,134,34),(1430,542,147,106),
             [(1453,614),(1466,599),(1490,631),(1506,585),(1520,628),(1533,616),(1459,638)])]
    for i,(x,w) in enumerate([(1265,41),(1320,70)]):
        obs.append(object_('cafe_table_'+str(i),666,[(x,645,w,21)],[
            oval(x+w/2,615,w/2,7),rect(x+w/2-4,620,8,40),rect(x+w/2-13,660,26,5)]))
    for i,(x,backtop) in enumerate([(1235,606),(1302,608),(1371,604)]):
        obs.append(object_('cafe_chair_'+str(i),666,[(x,646,48,20)],[
            [[x,backtop],[x+10,backtop-3],[x+17,backtop+7],[x+18,634],[x+42,634],
             [x+44,641],[x+48,664],[x+42,664],[x+36,644],[x+14,644],[x+9,665],[x+2,665],
             [x+9,639],[x+5,626]]]))
    return scene('LaPazSopocachi',671,(863,820),obs,{
        'TransitDoor':anchor(1072,720),'LocalSpot':anchor(1305,718),
        'NpcMauricio':anchor(674,794)},[
        sign((1203,392,315,49),'CAFÉ','#444856',size=39),
        sign((1144,604,51,67),'CAFÉ\nTÉ\nJUGOS','#1b292d',size=10,object='cafe_menu')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def sanpedro():
    obs=[pot('west_pot',(284,647,42,48),(283,625,43,24)),
         pot('plaza_west_tree',(618,651,59,29),(483,291,277,206),[
             [[635,650],[635,541],[607,509],[585,477],[593,470],[620,499],
              [640,517],[639,467],[650,444],[660,447],[659,517],[688,489],
              [700,461],[707,467],[699,501],[662,541],[659,650]]]),
         pot('plaza_middle_tree',(782,651,61,29),(721,341,184,186),[
             [[800,652],[804,552],[779,524],[767,492],[775,489],[791,518],
              [809,534],[809,478],[820,478],[821,533],[842,507],[851,510],[823,550],[821,652]]]),
         pot('station_tree',(1241,654,68,27),(1176,331,211,190),[
             [[1265,654],[1265,565],[1239,524],[1246,517],[1273,549],[1287,519],
              [1293,483],[1301,486],[1297,534],[1284,567],[1287,654]]]),
         bench('plaza_west_bench',541,629,216,51),bench('plaza_middle_bench',780,639,85,41),
         lamp('plaza_lamp',714,513,737,35),lamp('station_lamp',1321,515,737,35),
         object_('west_fountain_tap',732,[(151,708,29,24)],[
             rect(158,648,15,76),oval(166,726,15,6),rect(146,622,7,22),
             rect(184,622,7,22),rect(151,644,35,7),rect(163,606,7,20)]),
         object_('plaza_food_stall',690,[(880,666,352,24)],[
             [[875,532],[903,493],[1205,493],[1237,531],[1235,547],[876,547]],
             rect(880,547,352,142)]),
         board('station_menu',1600,629,46,57)]
    for i,x in enumerate([994,1053,1112,1169]):
        obj=stool('counter_stool_'+str(i),x,650,40,51)
        obj['polygons'][0]=[point(*p) for p in oval(x+20,656,18,7)]
        obs.append(obj)
    return scene('LaPazSanPedro',671,(923,799),obs,{
        'TransitDoor':anchor(1509,714),'LocalSpot':anchor(615,728)},[
        sign((1389,435,260,46),'TELEFÉRICO','#087a91',size=28),
        sign((309,480,156,35),'PLAZA SAN PEDRO','#343952',size=17)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def irpavi():
    obs=[pole('west_utility_pole',307,185,709,13),pole('east_utility_pole',982,174,709,16),
         flowers('west_flower_box',(0,678,116,26),(0,634,109,47),[(29,657),(56,663),(70,653)]),
         flowers('west_middle_flower_box',(147,678,141,27),(156,638,124,44),
                 [(180,661),(196,650),(219,663),(239,653),(254,664)]),
         flowers('tree_left_flower_box',(337,679,174,31),(337,638,106,45),
                 [(362,663),(386,649),(401,664),(416,651)]),
         flowers('tree_right_flower_box',(507,678,98,28),(498,638,101,45),
                 [(516,660),(530,651),(544,665),(563,649),(580,660)]),
         object_('front_tree',708,[(441,677,49,31)],[
             [[448,680],[450,592],[422,568],[394,540],[400,529],[427,550],
              [453,570],[453,515],[464,486],[472,490],[471,567],[496,543],
              [517,515],[525,521],[509,550],[479,586],[480,678]]],
             foliage=[rect(336,279,271,301)],wood_branches=True),
         flowers('shop_flower_trough',(1023,627,194,54),(1022,552,190,77),
                 [(1039,608),(1065,592),(1074,611),(1088,582),(1109,613),(1148,607),(1175,612)]),
         board('shop_drinks_rack',1243,604,70,89)]
    for obj,x,top in [(obs[0],307,185),(obs[1],982,174)]:
        obj['polygons'] += [[point(*p) for p in rect(x-28,y,56,7)] for y in [top+60,top+91]]
    post,fixture=route_post('irpavi_station_post',1519,712,'TELEFÉRICO')
    obs.append(post)
    return scene('LaPazIrpavi',677,(849,814),obs,{
        'TransitDoor':anchor(1519,765),'LocalSpot':anchor(787,724)},[
        sign((1300,450,251,45),'TIENDA','#1b5693',size=34)],
        fittings=[fixture],interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[pot('counter_plant',(1080,555,49,49),(1064,438,89,120)),
         object_('reception_counter',601,[(594,575,461,26)],[rect(595,471,458,21),
             rect(594,492,461,106),rect(621,439,43,32),rect(976,433,48,39)]),
         object_('water_cooler',600,[(278,572,63,28)],[rect(278,443,63,149),
             [[286,363],[331,363],[339,373],[339,430],[332,441],[287,441],[280,431],[280,374]]]),
         object_('luggage_rack',601,[(364,578,133,23)],[rect(364,432,12,168),rect(485,432,12,168),
             rect(374,480,111,12),rect(374,583,112,13),rect(379,541,45,39),rect(429,541,49,39),
             oval(403,530,17,18),oval(453,530,17,18),rect(381,439,43,43),rect(432,439,45,43),
             rect(397,423,22,6),rect(397,429,5,10),rect(414,429,5,10),
             rect(438,423,24,6),rect(438,429,5,10),rect(457,429,5,10)]),
         box('lobby_bin',517,540,51,64),
         object_('lobby_sofa',640,[(1186,615,230,25)],[
             [[1202,519],[1397,519],[1399,550],[1414,550],[1419,561],[1418,617],
              [1411,619],[1415,638],[1406,638],[1401,619],[1200,619],[1194,638],
              [1187,638],[1191,618],[1183,612],[1183,559],[1190,550],[1201,550]]]),
         object_('sofa_side_table',641,[(1443,615,68,26)],[rect(1442,585,72,18),
             rect(1448,603,9,35),rect(1498,603,8,35),rect(1462,574,29,15)],
             foliage=[rect(1457,539,36,37)]),
         object_('front_coffee_table',740,[(317,710,140,30)],[rect(315,675,144,22),
             rect(324,697,10,43),rect(441,697,11,43),rect(334,701,107,12),
             rect(348,654,50,26),rect(411,662,17,17)],foliage=[rect(336,617,68,40)])]
    return scene('LaPazHotel',595,(836,692),obs,{
        'Point':anchor(824,648),'Exit':anchor(184,642)},[
        sign((743,237,191,52),'HOTEL','#e6c590','#202723',size=38)],
        clerks={'Point':anchor(824,556)},walk_bottom=point(0,761)[1],
        interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[pot('east_exchange_plant',(1509,553,54,56),(1510,463,58,93)),
         object_('brochure_rack',606,[(1212,584,126,22)],[rect(1212,433,11,173),
             rect(1328,433,11,173),rect(1222,438,106,162)]),
         object_('exchange_counter',593,[(563,572,608,21)],[rect(564,467,604,126),
             rect(583,441,37,22),rect(711,442,30,21),rect(1042,416,40,47)],
             foliage=[rect(575,378,56,66),rect(698,393,57,54),rect(1123,393,36,62)],
             glass=[rect(580,258,578,205)]),
         object_('exchange_window_frame',593,[(565,575,604,18)],[rect(565,243,600,14),
             rect(565,257,12,209),rect(1157,257,11,210),rect(762,255,10,211),
             rect(959,255,10,211),rect(577,389,580,5)]),
         pole('west_queue_post',532,594,689,12)]
    polys=[rect(744,597,379,11)]
    for x in [744,936,1120]:polys += [rect(x-6,597,12,82),oval(x,596,7,7),rect(x-17,678,34,11)]
    obs.append(object_('exchange_queue',689,[(728,675,410,14)],polys))
    return scene('LaPazExchange',595,(861,723),obs,{
        'Point':anchor(646,648),'Exit':anchor(209,641)},[
        sign((737,160,239,64),'CAMBIO','#20578a',size=39),
        sign((321,256,197,194),'DIVISAS\nDÓLAR · EURO\nREAL · PESO\nSOL','#202a35',size=22),
        sign((1382,403,136,39),'BOLIVIA','#e3e8ed','#233543',size=27)],
        clerks={'Point':anchor(646,548)},walk_bottom=point(0,766)[1],
        interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[metal_seats('station_seats',27,601,4,78,127,66,75,15),
         box('station_bin',390,624,62,96),box('west_ticket_box',112,497,65,84),
         box('ticket_machine',1110,479,84,205),
         object_('station_map',683,[(1338,658,312,25)],[rect(1343,375,300,247),
             rect(1343,622,11,58),rect(1628,622,13,59),rect(1338,675,26,8),rect(1622,675,28,8)]),
         object_('west_boundary',678,[(480,647,28,31)],[rect(480,539,28,140)]),
         pole('east_gate_post',963,511,680,12),pole('ramp_post',1070,541,680,10)]
    for i,x in enumerate([558,703,845]):
        obs.append(box('gate_reader_'+str(i),x,543,57,140))
    for i,x in enumerate([519,656,796]):
        w=38 if i==0 else 46
        obs.append(object_('gate_glass_'+str(i),680,[(x,659,w,21)],[],glass=[rect(x,572,w,74)]))
    obs.append(object_('east_gate_glass',680,[(902,660,47,20)],
        [rect(943,574,5,106)],glass=[rect(902,573,40,74)]))
    return scene('LaPazTransit',647,(894,799),obs,{
        'Machine':anchor(1146,730),'Platform':anchor(652,729),'Exit':anchor(1267,793)},[
        sign((568,167,252,73),'TELEFÉRICO','#172d4f',size=34)],
        clerks={},walk_bottom=point(0,863)[1],interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[pot('west_pot',(8,637,44,46),(0,528,64,114)),
         pot('west_tree',(89,625,49,49),(74,513,85,115)),
         pot('seat_tree',(558,626,47,49),(542,521,77,108)),
         pot('tall_snake_plant',(681,591,36,82),(681,524,36,70)),
         pot('rear_snake_plant',(316,557,29,44),(317,521,27,41)),
         metal_seats('airport_seats',170,582,5,61,102,48,55,13),
         object_('baggage_belt',803,[(600,760,594,43)],[
             [[618,714],[1177,714],[1194,724],[1194,788],[1188,799],
              [1163,803],[620,801],[600,792],[599,726]],
             rect(619,685,59,44),rect(781,670,76,59),rect(872,668,76,61),rect(1040,668,75,61),
             rect(805,655,27,5),rect(803,660,6,9),rect(828,660,6,9),
             rect(895,655,28,6),rect(894,661,5,7),rect(922,661,5,7),
             rect(1064,655,24,6),rect(1063,661,5,7),rect(1087,661,5,7)],
             animation_patches=[dict(kind='conveyor',rect=[*point(957,715),*point(73,12)])]),
         pole('queue_rear_post',1284,652,710,7),
         object_('right_queue_gate',845,[(1452,816,60,29),(1583,827,89,18)],[
             rect(1453,740,57,101),rect(1508,755,164,10),rect(1596,750,10,84),
             rect(1585,833,30,12),rect(1450,835,62,10),oval(1601,753,7,7)])]
    cartpolys=[]
    for i in range(7):
        x=1360+i*36;y=540+i*3
        cartpolys += [rect(x,y,29,9),rect(x+6,y+9,5,91),rect(x+30,y+9,5,91),
                     rect(x+10,y+26,21,65),rect(x-4,y+99,43,9),
                     oval(x+7,y+118,11,12),oval(x+36,y+119,11,12)]
    obs.append(object_('luggage_carts',702,[(1356,675,280,27)],cartpolys))
    return scene('LaPazAirport',595,(1253,782),obs,{
        'Point':anchor(861,647),'Exit':anchor(1390,819)},[
        sign((572,120,439,83),'AEROPUERTO\nINTERNACIONAL EL ALTO','#202c3d',size=27),
        sign((1113,171,141,40),'LLEGADAS','#202c3d',size=23),
        sign((1376,129,250,291),'SALIDAS\n\nLONDRES\nTORONTO\nSÃO PAULO\nCIUDAD DE MÉXICO','#192739','#ebd260',size=21)],
        fittings=[dict(kind='ticket',at=point(861,600))],clerks={},
        prompt_overrides={'Point':'E — The check-in terminal'},interaction_sizes=sizes('Point','Exit'))


def build():
    from .lapaz_finish import finish
    return finish({'LaPazElAlto':elalto(),'LaPazRodriguez':rodriguez(),'LaPazSopocachi':sopocachi(),
            'LaPazSanPedro':sanpedro(),'LaPazIrpavi':irpavi(),'LaPazHotel':hotel(),
            'LaPazExchange':exchange(),'LaPazTransit':transit(),'LaPazAirport':airport()})
