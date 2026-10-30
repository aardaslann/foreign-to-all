"""Measured replacement Tokyo plates, retaining all gameplay entry points.

Foot contact and full visual silhouettes are separate. Installation does not
certify the exhaustive movement/contact pass deferred by the user.
"""
from .shapes import point, anchor, rect, tube, object_, SY
from .moscow import pot, board, oval
from .seoul import box, stool
from .tokyo import sign, wheel, chair


def finish(rows):
    implementations={'Yanaka':yanaka,'Jinbocho':jinbocho,'Asakusa':asakusa,
                     'Ueno':ueno,'Shinbashi':shinbashi,'Hotel':hotel,
                     'Exchange':exchange,'Transit':transit,'Airport':airport}
    for name,fn in implementations.items():
        row=rows['Tokyo'+name]
        row.update(texture=f'res://art/environments/scenes/Tokyo{name}-retro.png',
                   pixel_art=True,art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
        fn(row)
    return rows


def yanaka(row):
    row['objects']=[
        pot('west_pot',(29,642,65,51),(15,540,93,105)),
        pot('menu_pot',(308,648,23,28),(299,615,36,39)),
        pot('lodging_pot',(496,643,67,51),(475,540,113,106)),
        board('menu_board',336,570,94,128),
        pot('stair_tree',(1139,624,53,66),(1120,461,100,167),[rect(1161,524,12,102)]),
        pot('stair_small_pot',(1194,654,25,24),(1190,631,33,27)),
        pot('stair_east_pot',(1407,650,45,43),(1374,478,88,175),[rect(1425,573,10,79)]),
        pot('east_trough',(1483,635,100,55),(1470,565,124,73)),
        object_('bench',691,[(114,674,159,17)],[rect(114,610,160,18),
            rect(122,628,9,28),rect(257,628,9,28),
            *[rect(x,631,7,23) for x in [138,157,175,194,212,231,248]],
            rect(114,655,158,17),rect(118,671,11,18),rect(257,671,10,18)]),
        object_('shop_banner',698,[(979,683,32,15)],[rect(989,412,13,281),
            rect(938,445,112,12),rect(941,457,107,201),rect(979,689,32,9)]),
        object_('utility_pole',700,[(1088,682,40,18)],[rect(1093,43,31,644),
            rect(1087,686,45,11),rect(1100,36,25,30),
            tube((1119,69),(1147,43),8),rect(1143,42,11,62),
            rect(1135,101,25,10),rect(1136,112,26,8),
            [[1105,137],[1122,124],[1137,138],[1145,146],[1146,198],[1103,198]],
            rect(1093,109,29,15),rect(1127,170,9,220)])]
    row['lettering']=[
        sign((570,296,405,60),'やなか','#ead8b4','#29342f',size=40),
        sign((954,472,75,161),'甘\n味','#203965',size=38,object='shop_banner'),
        sign((349,583,64,89),'お茶\n甘味\n営業中','#1e2934',size=15,object='menu_board'),
        sign((502,556,84,33),'宿泊','#cda77c','#32312c',size=18),
        sign((780,581,103,26),'両替','#263b48',size=17),
        sign((1240,389,72,24),'駅 →','#354339',size=14)]


def jinbocho(row):
    bike=wheel(1433,673,40)+wheel(1567,675,40)
    for a,b,w in [((1433,673),(1459,601),6),((1459,601),(1474,591),5),
                 ((1459,601),(1454,588),4),((1454,588),(1462,581),4),
                 ((1462,581),(1480,589),6),((1453,612),(1477,642),6),
                 ((1477,642),(1517,660),6),((1517,660),(1535,622),6),
                 ((1450,626),(1464,663),6),((1464,663),(1502,685),6),
                 ((1502,685),(1532,629),6),((1532,629),(1567,675),6),
                 ((1567,675),(1502,685),6),((1532,629),(1532,615),5),
                 ((1563,648),(1564,724),4),((1502,685),(1507,707),4)]:
        bike.append(tube(a,b,w))
    bike += [rect(1515,611,28,9),rect(1519,624,64,7),
             rect(1420,590,35,5),rect(1416,593,4,26),rect(1450,594,4,24),
             rect(1420,617,30,5),oval(1503,684,9,10),rect(1501,703,13,6)]
    for x in range(1422,1450,6):bike.append(tube((x,595),(x+2,617),1.5))
    for y in range(599,616,6):bike.append(rect(1421,y,29,1.5))
    row['objects']=[
        pot('west_pot',(8,623,53,72),(9,583,57,44)),
        object_('west_books',700,[(81,684,217,16)],[rect(81,646,217,50),rect(89,615,200,33)]),
        object_('middle_books',702,[(508,686,107,16)],[rect(508,660,107,37),rect(517,624,92,36)]),
        pot('bookshop_pot',(620,659,39,40),(613,615,48,48)),
        board('coffee_menu',953,593,81,115),
        pot('east_tree',(1603,649,63,67),(1493,270,179,291),[
            [[1627,653],[1622,574],[1601,550],[1581,519],[1587,511],
             [1613,542],[1625,550],[1627,488],[1638,488],[1640,552],
             [1666,525],[1672,533],[1643,572],[1643,650]]]),
        object_('bicycle',725,[(1393,707,214,18)],bike)]
    row['lettering']=[
        sign((190,303,360,59),'古書','#f4e6c7','#222c2d',size=40),
        sign((1159,367,222,52),'書房','#f3e5c9','#222c2d',size=36),
        sign((752,388,185,31),'COFFEE','#decaae','#35332b',size=28),
        sign((1579,178,81,140),'空港\nバス','#253b5c',size=23),
        sign((964,607,58,74),'喫茶\n珈琲\n営業中','#263139',size=13,object='coffee_menu'),
        sign((324,582,64,26),'駅 →','#283b4a',size=13)]


def asakusa(row):
    obs=[]
    for name,x,y,w,h in [('front_west',441,39,39,678),('front_east',1190,39,40,679),
                        ('middle_west',597,192,24,481),('middle_east',1053,192,26,481),
                        ('rear_west',684,286,23,354),('rear_east',968,285,23,357)]:
        obs.append(object_(name+'_column',y+h,[(x,y+h-20,w,20)],[rect(x,y,w,h)]))
    obs += [object_('west_display',693,[(26,675,73,18)],[rect(26,526,70,99),
                rect(32,625,10,64),rect(82,625,11,65),rect(43,669,40,10)]),
            object_('west_fans',698,[(340,680,78,18)],[rect(341,572,77,113),
                rect(348,685,8,12),rect(408,685,8,12),oval(381,533,34,21)]),
            box('west_basket',132,667,38,27),box('west_basket_east',183,672,40,22),
            object_('front_goods',688,[(538,671,56,17)],[rect(538,642,56,42),rect(537,613,48,29)]),
            pot('front_goods_plant',(502,654,31,35),(493,617,43,41)),
            box('rear_west_cartons',623,608,58,35),box('rear_east_cartons',993,603,54,44),
            object_('east_menu',700,[(1078,682,93,18)],[
                [[1099,571],[1148,570],[1137,697],[1128,697],[1130,680],
                 [1090,676],[1087,693],[1078,691]],tube((1148,579),(1168,685),7)]),
            object_('east_books',698,[(1260,681,111,17)],[rect(1260,654,111,40),rect(1269,621,94,33)]),
            pot('east_plant',(1613,646,48,45),(1598,570,74,80)),
            object_('west_shop_floor',684,[(0,626,439,58)],[]),
            object_('east_shop_floor',684,[(1235,626,437,58)],[])]
    row['objects']=obs
    row['lettering']=[
        sign((796,264,74,124),'浅\n草','#00000000','#efddb9',size=39),
        sign((1337,417,212,58),'仲見世','#243b61',size=32),
        sign((1101,591,31,63),'お品書き','#f1e2be','#4b3d2c',size=10,object='east_menu'),
        sign((1379,583,49,24),'駅 →','#293b44',size=10)]


def ueno(row):
    row['objects']=[
        object_('park_sign',696,[(118,676,280,20)],[rect(118,422,280,274),rect(133,326,121,97)]),
        pot('park_planter',(397,631,76,63),(384,522,102,112)),
        pot('steps_west_planter',(490,601,43,36),(477,528,57,76)),
        pot('steps_east_planter',(675,603,28,39),(666,534,38,69)),
        object_('vending_machine',706,[(1088,688,128,18)],[rect(1088,466,128,228),
            rect(1096,694,11,12),rect(1200,694,11,12)]),
        object_('station_bench',718,[(1305,701,191,17)],[
            rect(1314,627,167,14),rect(1318,646,160,10),
            rect(1321,641,10,27),rect(1468,641,10,27),rect(1305,668,191,17),
            [[1310,685],[1326,685],[1320,716],[1307,716]],
            [[1470,685],[1484,685],[1494,716],[1480,716]]]),
        box('station_west_column',1228,214,57,483),
        object_('west_fence',689,[(0,671,118,18)],
            [rect(0,530,118,7),rect(0,578,118,6),rect(0,600,118,89),
             *[rect(x,510,7,90) for x in [4,35,67,98]],
             *[oval(x+3,504,6,9) for x in [4,35,67,98]]]),
        object_('stair_west_rail',641,[(534,624,14,17)],[rect(537,523,9,115),tube((537,523),(551,516),7)]),
        object_('stair_east_rail',641,[(666,624,10,17)],[rect(667,524,8,116)]),
        object_('park_lamp',633,[(423,616,25,17)],[rect(430,291,13,339),
            oval(437,285,8,10),tube((436,317),(414,300),6),tube((436,317),(460,300),6),
            [[397,318],[414,302],[430,318],[426,352],[406,352]],
            [[444,318],[461,302],[478,318],[473,352],[452,352]]])]
    row['lettering']=[
        sign((168,466,176,129),'上野公園\n→','#594a3a',size=32,object='park_sign'),
        sign((742,446,325,53),'おみやげ','#24395e',size=34),
        sign((1470,264,199,54),'上野駅','#eee4ce','#233336',size=38),
        sign((772,534,99,28),'アメ横 →','#dec6a0','#33423b',size=14)]
    row['anchors']['LocalSpot']=anchor(794,747)
    row.setdefault('prompt_overrides',{})['LocalSpot']='E — Walk to Ameyoko'


def shinbashi(row):
    row['objects']=[
        pot('west_bamboo',(19,599,66,130),(6,448,89,155),[rect(42,526,9,76)]),
        pot('bar_pot',(109,698,37,29),(106,643,44,58)),
        box('west_bottle_crates',558,632,60,94),box('middle_bottle_crates',726,631,59,94),
        box('middle_red_crate',739,597,41,33),box('white_cabinet',1259,593,60,135),
        box('blue_crates',1317,634,36,92),box('east_yellow_crates',1569,630,47,96),
        pot('east_pot',(1609,692,60,36),(1600,644,72,59)),
        object_('east_meter',717,[(1613,700,22,17)],[rect(1617,546,10,168),rect(1587,563,72,79)]),
        object_('east_red_crates',727,[(1095,710,53,17)],[rect(1095,631,53,94),
            [[1105,631],[1108,620],[1111,607],[1110,599],[1118,599],[1118,608],[1123,623],[1123,631]]])]
    for i,x in enumerate([201,296,369,466,993]):
        row['objects'].append(stool('bar_stool_'+str(i),x,659 if i<4 else 652,43,66 if i<4 else 73))
    row['lettering']=[
        sign((199,445,312,55),'やきとり','#1e3b65',size=38),
        sign((794,437,279,47),'立ち飲み','#eddcbd','#32392e',size=37),
        sign((141,509,28,36),'酒','#00000000',size=23),
        sign((540,511,25,37),'酒','#00000000',size=23),
        sign((1102,543,27,40),'串\n酒','#e9ddbd','#36352e',size=12),
        sign((1332,434,252,26),'新橋駅 →','#193552',size=23)]
    row['anchors']['TransitDoor']=anchor(1460,764)
    row['motion_layers']=[dict(rect=[*point(0,20),*point(1672,113)],
        texture='res://art/environments/scenes/TokyoShinbashiTrain-retro.png',
        occluders=[[*point(x,20),*point(w,113)] for x,w in [(20,53),(467,25),(649,55),(1304,55)]] )]
    row['animation_patches']=[dict(kind='rotor_marks',rect=[*point(1268,609),*point(41,42)],speed=4.0)]


def hotel(row):
    row['objects']=[
        object_('reception',613,[(681,595,420,18)],[rect(674,442,432,21),
            rect(681,463,420,146),rect(768,417,38,25),rect(902,422,20,18),
            rect(977,435,41,8),rect(990,395,13,40),
            [[977,337],[1023,337],[1034,394],[963,394]],
            rect(1040,411,43,31)],foliage=[rect(1025,298,88,116)],wood_branches=True),
        pot('lobby_tree',(246,513,78,91),(224,333,120,183),[rect(276,454,17,63)]),
        object_('luggage_shelf',659,[(365,642,270,17)],[
            rect(361,440,290,18),rect(366,458,17,193),rect(625,458,13,196),
            rect(416,458,16,199),rect(379,516,246,24),rect(379,619,246,26),
            rect(437,485,52,42),rect(448,476,31,9),rect(499,518,52,10),rect(557,509,54,17),
            rect(434,563,56,73),rect(498,563,57,73),rect(559,563,56,73),
            rect(449,552,28,11),rect(512,552,28,11),rect(574,552,28,11)]),
        object_('drinks_machine',574,[(1121,557,142,17)],[rect(1121,284,142,279),
            rect(1127,563,14,11),rect(1243,563,13,11)]),
        box('west_bin',0,480,33,141),
        object_('garden_glass',613,[(1269,595,403,18)],[rect(1269,129,71,483),
            rect(1607,132,12,480),rect(1339,601,333,12),rect(1339,234,268,11)],
            glass=[rect(1341,139,265,95),rect(1341,247,265,353)])]
    row['clerks']['Point']=anchor(885,479)
    row['anchors']['Point']=anchor(885,660)
    row['lettering']=[sign((357,306,282,49),'東京ホテル','#d7c6a5','#37352d',size=32)]


def linked_seat(name,x,y,w,h):
    back=h*.53
    return object_(name,y+h,[(x,y+h-15,w,15)],[
        rect(x+8,y,w-14,back),rect(x+3,y+back,w-4,14),
        rect(x,y+back-7,6,21),rect(x+w-5,y+back-7,5,21),
        rect(x+3,y+back+14,w-4,9),rect(x+9,y+back+23,8,h-back-23),
        rect(x+w-18,y+back+23,8,h-back-23),
        rect(x+3,y+h-6,19,6),rect(x+w-23,y+h-6,19,6)])


def exchange(row):
    row['objects']=[
        object_('counter',614,[(601,596,434,18)],[rect(601,466,434,23),
            rect(601,489,434,123),rect(658,418,68,48),
            rect(599,209,11,257),rect(1024,209,11,257),rect(610,209,414,12),
            rect(973,447,24,17)],glass=[rect(611,222,412,243)],
            foliage=[rect(954,389,59,60)],wood_branches=True),
        pot('waiting_tree',(250,538,65,86),(222,365,119,177),[rect(278,482,12,59)]),
        box('west_bin',0,479,35,146)]
    for i,x in enumerate([1074,1167,1259]):
        row['objects'].append(linked_seat('waiting_seat_'+str(i),x,493,97,150))
    row['clerks']['Point']=anchor(815,508)
    row['lettering']=[
        sign((589,115,535,65),'外貨両替','#223b69',size=40),
        sign((1075,252,253,159),'両替\n\nUSD · EUR · GBP\n日本円','#222c39','#eed567',size=26)]


def transit(row):
    row['fittings']=[]
    row['objects']=[box('west_column',145,0,56,660),box('east_column',1053,0,54,660),
        object_('ticket_machine',823,[(655,805,109,18)],[rect(657,566,103,242),rect(655,808,109,15)]),
        object_('ticket_gate_west',645,[(1307,627,132,18)],[
            [[1307,482],[1355,482],[1367,510],[1367,642],[1320,642],[1307,615]]],
            glass=[rect(1367,513,72,68)]),
        object_('ticket_gate_middle',646,[(1439,628,133,18)],[
            [[1439,483],[1483,483],[1502,507],[1502,642],[1452,642],[1439,615]]],
            glass=[rect(1503,513,69,68)]),
        object_('ticket_gate_east',646,[(1569,628,72,18)],[
            [[1575,483],[1623,483],[1640,508],[1640,643],[1581,643],[1569,615]]])]
    # Flaps share each gate's ground contact; the exit is on the near side.
    for i,x in enumerate([141,240,338]):
        row['objects'].append(linked_seat('platform_seat_'+str(i),x,720,101,149))
    row['anchors'].update(Machine=anchor(710,870),Platform=anchor(887,650),Exit=anchor(1404,700))
    row['lettering']=[
        sign((436,187,363,45),'東京','#eee4ce','#233336',size=39),
        sign((437,240,363,32),'Tokyo','#eee4ce','#233336',size=24),
        sign((1343,202,175,65),'出口\nExit','#1d2934','#eed76a',size=27),
        sign((674,578,65,24),'きっぷ','#d7ddd4','#263b48',size=12,object='ticket_machine')]
    row['motion_layers']=[dict(kind='doors',rect=[*point(429,364),*point(129,217)]),
                          dict(kind='doors',rect=[*point(835,365),*point(124,216)])]


def airport(row):
    row['fittings']=[]
    row['objects']=[box('west_column',95,52,111,563),box('east_column',1386,50,73,590),
        pot('west_plant',(29,627,61,65),(11,526,103,105)),
        object_('check_in_kiosk',673,[(668,655,64,18)],[rect(671,528,57,129),rect(668,657,64,16)]),
        object_('loose_suitcase',659,[(1305,642,71,17)],[rect(1306,598,68,56),
            rect(1325,588,29,10),oval(1311,653,6,6),oval(1368,653,6,6)]),
        object_('front_belt',849,[(1118,825,554,24)],[
            [[1113,738],[1121,722],[1137,713],[1672,713],[1672,849],[1137,849],[1123,843],[1118,832]],
            rect(1219,705,93,80),rect(1244,694,44,12),
            rect(1342,742,96,43),rect(1373,731,31,12),
            rect(1475,704,95,81),rect(1503,693,33,12)])]
    for i,x in enumerate([119,191,263,335,407,479,551]):
        row['objects'].append(linked_seat('terminal_seat_'+str(i),x,563,77,120))
    for i,x in enumerate([1362,1425,1488,1551]):
        polys=[rect(x,525,69,12),rect(x+7,537,7,100),rect(x+59,537,7,100),
               rect(x+8,574,51,8),rect(x+8,620,51,10),rect(x+10,636,51,7),
               oval(x+14,647,7,8),oval(x+59,647,7,8),
               tube((x+20,574),(x+21,561),4),rect(x+21,558,27,5),rect(x+46,561,4,13)]
        for xx in range(x+18,x+59,10):polys.append(rect(xx,582,2,36))
        row['objects'].append(object_('luggage_cart_'+str(i),655,[(x+8,639,61,16)],polys))
    row['anchors'].update(Point=anchor(700,724),Exit=anchor(841,689))
    row['lettering']=[
        sign((796,190,360,67),'出発 →','#243957',size=40),
        sign((934,402,273,38),'売店','#f5da9a','#3b3d31',size=29),
        sign((682,535,37,17),'搭乗手続','#253c57',size=9,object='check_in_kiosk'),
        sign((1505,399,104,88),'手荷物','#243957',size=26),
        sign((751,552,110,30),'← 市内バス','#293e52',size=15)]
    row['animation_patches']=[dict(kind='conveyor',rect=[*point(1139,745),*point(73,35)])]
