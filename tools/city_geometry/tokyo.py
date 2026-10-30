"""Tokyo source layouts, realigned to installed replacement art by tokyo_finish.

All measurements use the 1672x941 reference canvas. The later exhaustive walking
and contact audit remains separate from installation.
"""
from math import cos, sin, tau
from .shapes import point, anchor, rect, tube, object_, sign as base_sign
from .moscow import scene, pot, oval, board
from .rome import sizes
from .seoul import box, stool

FONT = 'res://art/fonts/NotoSansJP.ttf'


def sign(bounds,text,bg,ink='#f1ead9',size=22,**extra):
    if any('\u3040'<=c<='\u9fff' for c in text):
        extra['font']=FONT
    return base_sign(bounds,text,bg,ink,size,**extra)


def wheel(x,y,r):
    # Separate tyre strips and spokes preserve the pavement between spokes.
    rim=[(x+cos(i*tau/36)*r,y+sin(i*tau/36)*r) for i in range(36)]
    return [tube(rim[i],rim[(i+1)%36],5) for i in range(36)]+[
        tube((x,y),(x+cos(i*tau/12)*(r-4),y+sin(i*tau/12)*(r-4)),1.4)
        for i in range(12)]


def chair(name,x,y,w=89,h=149):
    return object_(name,y+h,[(x+3,y+h-25,w-6,25)],[
        [[x+9,y],[x+w-9,y],[x+w-3,y+6],[x+w-3,y+83],[x+3,y+83],[x+3,y+7]],
        [[x+3,y+81],[x+w-3,y+81],[x+w,y+95],[x+w,y+108],[x,y+108],[x,y+96]],
        rect(x+5,y+108,13,h-108),rect(x+w-18,y+108,13,h-108),
        rect(x+1,y+h-8,22,8),rect(x+w-23,y+h-8,22,8)])


def yanaka():
    obs=[pot('west_pot',(29,643,65,47),(20,541,85,106)),
         pot('menu_pot',(310,650,20,27),(307,622,29,32)),
         pot('lodging_pot',(498,643,62,49),(484,542,91,106)),
         board('menu_board',337,571,95,127),
         pot('stair_tree',(1140,625,57,63),(1133,444,92,184),[rect(1163,548,14,78)]),
         pot('stair_small_pot',(1198,650,18,26),(1197,628,27,24)),
         pot('stair_east_pot',(1407,646,43,42),(1390,541,64,109),[rect(1423,607,10,43)]),
         pot('east_trough',(1480,633,100,55),(1481,567,101,67)),
         object_('cat_bench',690,[(117,662,159,28)],[
             rect(118,614,158,15),rect(128,630,8,30),rect(170,630,7,29),
             rect(210,630,7,29),rect(257,630,8,31),rect(117,657,160,17),
             rect(120,674,10,14),rect(258,674,10,14),
             [[166,616],[169,589],[167,582],[168,572],[174,577],[180,571],
              [181,581],[178,588],[197,588],[204,583],[204,575],[209,573],
              [212,578],[210,590],[204,597],[211,613],[207,617],[201,601],
              [191,599],[186,615],[181,616],[183,600],[176,603],[173,617]]]),
         object_('shop_banner',698,[(979,682,38,16)],[
             rect(991,414,12,279),rect(979,692,38,6),rect(938,452,112,207)]),
         object_('utility_pole',698,[(1091,681,40,17)],[
             rect(1096,60,28,627),rect(1090,687,41,10),
             tube((1121,89),(1148,72),6),rect(1145,67,10,40),
             [[1142,108],[1158,108],[1165,119],[1160,125],[1140,125],[1135,120]],
             tube((1120,107),(1125,141),5),
             [[1123,132],[1130,140],[1154,155],[1151,163],[1146,164],
              [1141,202],[1109,202],[1104,163],[1099,162],[1098,155]]])]
    return scene('TokyoYanaka',672,(755,846),obs,{
        'HotelDoor':anchor(577,729),'ExchangeDoor':anchor(832,729),
        'TransitDoor':anchor(1310,726),'LocalSpot':anchor(1230,767),
        'NpcSora':anchor(940,837),'ExitEast':anchor(1620,858)},[
        sign((570,298,408,66),'やなか','#f4ead7','#20242a',size=40),
        sign((949,468,88,179),'甘\n味','#213965',size=40,object='shop_banner'),
        sign((350,584,65,88),'お茶\n甘味\n本日営業','#182330',size=15,object='menu_board'),
        sign((505,553,85,33),'宿泊','#eed8ad','#413f35',size=18),
        sign((778,580,107,28),'両替','#253345',size=17),
        sign((1239,389,73,26),'駅 →','#343a35',size=14)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'ExchangeDoor':'E — Currency exchange inside','TransitDoor':'E — Steps to the station'})


def jinbocho():
    obs=[pot('west_pot',(13,615,44,80),(11,591,50,34)),
         object_('west_books',698,[(81,678,217,20)],[rect(81,645,217,51),
             rect(89,617,199,28)]),
         object_('middle_books',701,[(508,682,107,19)],[rect(508,656,108,42),
             rect(518,625,91,33)]),
         pot('bookshop_pot',(620,658,38,41),(613,616,49,45)),
         board('coffee_menu',952,591,82,112),
         pot('east_tree',(1601,648,60,66),(1513,327,159,248),[
             [[1610,651],[1621,635],[1621,584],[1606,559],[1591,548],[1583,525],
              [1589,521],[1601,539],[1616,549],[1609,515],[1613,508],[1625,545],
              [1625,497],[1629,466],[1637,467],[1635,532],[1642,552],[1658,529],
              [1663,533],[1642,571],[1637,585],[1638,634],[1650,649]]])]
    bike_polys=[]
    for x,y,r in [(1406,682,39),(1475,682,35),(1492,682,36),(1573,682,39)]:
        bike_polys+=wheel(x,y,r)
    for a,b in [((1406,682),(1434,637)),((1434,637),(1465,682)),
                ((1406,682),(1465,682)),((1434,637),(1479,643)),
                ((1465,682),(1479,643)),((1479,643),(1492,682)),
                ((1475,682),(1504,641)),((1504,641),(1534,682)),
                ((1475,682),(1534,682)),((1504,641),(1554,641)),
                ((1534,682),(1554,641)),((1554,641),(1573,682)),
                ((1434,637),(1413,627)),((1413,627),(1408,619)),
                ((1504,641),(1512,627)),((1554,641),(1537,626))]:
        bike_polys.append(tube(a,b,5))
    bike_polys += [rect(1454,620,23,7),rect(1520,619,33,8),
                   rect(1406,619,26,6),rect(1456,627,39,8),
                   tube((1458,636),(1462,652),4),tube((1462,652),(1490,652),4),
                   tube((1490,652),(1495,635),4)]
    for x in range(1462,1494,6): bike_polys.append(rect(x,635,2,16))
    obs.append(object_('bicycles',724,[(1366,706,248,18)],bike_polys))
    return scene('TokyoJinbocho',680,(786,844),obs,{
        'AirportDoor':anchor(1601,768),'TransitDoor':anchor(399,729),
        'LocalSpot':anchor(226,750),'NpcIwata':anchor(659,835),
        'ExitWest':anchor(54,856)},[
        sign((188,300,368,72),'古書','#f6ebd6','#192026',size=41),
        sign((1154,361,235,67),'書房','#f4ead8','#192026',size=38),
        sign((752,383,185,51),'COFFEE','#ebdfc9','#342f27',size=29),
        sign((1577,177,82,146),'空港\nバス','#243f6d',size=24),
        sign((961,605,61,76),'喫茶\n珈琲\n営業中','#182430',size=13,object='coffee_menu'),
        sign((322,584,65,27),'駅 →','#243b4d',size=13)],
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'AirportDoor':'E — The airport bus','TransitDoor':'E — Station passage inside'})


def asakusa():
    obs=[]
    for name,x,y,w,h in [('front_west',443,37,36,679),('front_east',1195,35,38,681),
                        ('middle_west',598,193,24,480),('middle_east',1055,193,26,480),
                        ('rear_west',683,282,24,359),('rear_east',969,279,24,363)]:
        obs.append(object_(name+'_column',y+h,[(x,y+h-25,w,25)],[rect(x,y,w,h)]))
    obs += [object_('west_display',695,[(26,673,73,22)],[rect(26,530,70,97),
                rect(32,627,10,64),rect(83,627,11,65),rect(43,669,40,10)]),
            object_('west_display_books',698,[(340,679,79,19)],[rect(341,572,77,111),
                rect(348,683,8,14),rect(409,683,8,14)]),
            box('west_shelf',119,639,208,47),box('west_tray',130,672,44,22),
            box('west_basket',187,666,43,29),
            object_('front_goods',689,[(502,666,95,23)],[rect(502,641,94,43),
                rect(511,614,74,27),rect(515,684,8,5),rect(585,683,8,6)]),
            object_('rear_west_cartons',646,[(627,627,58,19)],[rect(627,601,58,44),
                rect(632,577,42,24)]),
            object_('rear_east_cartons',648,[(991,629,56,19)],[rect(991,600,56,47),
                rect(999,575,35,25)]),
            object_('east_menu',701,[(1078,681,95,20)],[
                [[1099,573],[1153,574],[1137,697],[1128,697],[1130,681],
                 [1090,677],[1087,694],[1078,692]],
                tube((1151,581),(1171,686),7)]),
            object_('east_books',699,[(1265,680,110,19)],[rect(1265,655,110,40),
                rect(1273,621,91,35),rect(1268,694,8,5),rect(1363,694,8,5)]),
            # Shop floors are closed; the central arcade remains a walkable lane.
            object_('west_shop_floor',684,[(0,626,440,58)],[]),
            object_('east_shop_floor',684,[(1235,626,437,58)],[])]
    return scene('TokyoAsakusa',625,(839,835),obs,{
        'TransitDoor':anchor(1406,728),'LocalSpot':anchor(836,701)},[
        sign((787,260,101,140),'雷\n門','#cc3430','#202126',size=42),
        sign((1383,411,112,79),'仲見世','#203f71',size=30),
        sign((498,175,38,56),'浅草','#d93931',size=16),
        sign((1141,173,38,55),'浅草','#d73930',size=16),
        sign((625,274,37,38),'市','#d23830',size=16),
        sign((1018,273,28,36),'市','#d33830',size=16),
        sign((1103,588,30,64),'お品書き','#eee4cf','#5b4030',size=10,object='east_menu'),
        sign((1380,584,48,24),'駅 →','#253541',size=10)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def ueno():
    obs=[box('park_sign',119,422,279,274),
         pot('park_planter',(396,630,77,63),(387,542,96,92)),
         pot('steps_west_planter',(484,600,47,35),(480,535,55,68)),
         pot('steps_east_planter',(674,599,32,38),(666,536,39,66)),
         object_('vending_machine',706,[(1087,681,131,25)],[rect(1087,466,131,234),
             rect(1096,698,10,8),rect(1201,698,10,8)]),
         object_('station_bench',717,[(1306,685,191,32)],[
             rect(1316,629,166,13),rect(1322,647,155,12),
             rect(1325,641,8,27),rect(1470,641,8,27),rect(1305,667,191,15),
             [[1312,682],[1327,682],[1321,715],[1307,715]],
             [[1472,682],[1487,682],[1495,714],[1481,714]]]),
         object_('station_west_column',697,[(1229,675,58,22)],[rect(1229,211,58,486)]),
         object_('west_fence',684,[(0,664,119,20)],[rect(0,530,119,7),
             *[rect(x,536,5,60) for x in range(13,113,23)],rect(0,592,119,5),rect(0,599,119,85)]),
         object_('stair_west_rail',644,[(534,622,17,22)],[rect(537,523,9,115),
             tube((537,523),(551,515),8)]),
         object_('stair_east_rail',644,[(665,620,12,24)],[rect(666,525,8,117)]),
         object_('park_lamp',633,[(422,613,28,20)],[rect(429,281,15,349),
             rect(420,294,32,14),tube((430,307),(414,313),6),
             tube((441,306),(460,315),6),
             [[435,274],[442,281],[442,297],[430,297],[430,282]],
             [[413,300],[429,325],[423,327],[421,356],[404,356],[401,329],[395,326]],
             [[461,301],[479,325],[472,330],[469,357],[452,357],[448,328],[443,325]]])]
    return scene('TokyoUeno',638,(831,842),obs,{
        'TransitDoor':anchor(1571,724),'LocalSpot':anchor(593,696)},[
        sign((167,466,176,129),'上野公園\n→','#615443',size=32,object='park_sign'),
        sign((742,445,325,54),'おみやげ','#243860',size=35),
        sign((1464,253,207,71),'上野駅','#ecece4','#1c2c37',size=39)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def shinbashi():
    obs=[pot('west_bamboo',(18,599,67,130),(8,447,89,156),[
             rect(36,523,7,78),rect(53,524,6,78),rect(43,498,7,101)]),
         pot('bar_pot',(108,697,39,31),(107,642,39,62)),
         box('west_bottle_crates',558,630,61,95),box('middle_bottle_crates',726,631,61,94),
         box('middle_red_crate',737,596,45,36),
         object_('east_red_crates',726,[(1094,705,58,21)],[rect(1094,632,58,93),
             [[1106,632],[1105,621],[1111,606],[1110,599],[1116,599],
              [1117,607],[1121,623],[1121,632]]]),
         box('white_cabinet',1259,596,65,132),box('blue_crates',1330,630,61,95),
         box('east_yellow_crates',1546,630,62,96),
         pot('east_pot',(1607,681,63,44),(1608,641,61,48)),
         object_('east_meter',716,[(1613,697,24,19)],[rect(1616,546,13,162),
             rect(1586,565,73,76)])]
    for i,x in enumerate([202,297,370,466,994]):
        obs.append(stool('bar_stool_'+str(i),x,665,42,58))
    return scene('TokyoShinbashi',716,(866,850),obs,{
        'TransitDoor':anchor(1501,764),'LocalSpot':anchor(900,766)},[
        sign((193,436,319,67),'やきとり','#193b70',size=42),
        sign((791,434,289,56),'立ち飲み','#f1eee3','#161b20',size=39),
        sign((139,511,31,37),'酒','#d53e29',size=24),
        sign((536,511,31,38),'酒','#d83a26',size=24),
        sign((884,554,46,43),'酒','#eee7ce','#364654',size=26),
        sign((1099,537,31,50),'串\nお茶','#eeeada','#34312c',size=12),
        sign((1383,496,136,31),'駅 →','#343d47',size=21)],
        motion_layers=[dict(rect=[0,14,1152,78],
            texture='res://art/environments/motion/TokyoShinbashi.png',
            occluders=[[12,14,43,78],[448,14,34,78],[914,14,45,78],
                       [318,14,27,78],[880,14,22,78]])],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[object_('reception',614,[(680,581,421,33)],[rect(676,443,429,20),
             rect(681,463,420,147),rect(766,417,42,26),rect(905,426,18,17),
             rect(984,437,35,6),rect(993,393,17,45),
             [[978,339],[1024,339],[1034,391],[968,391]]],
             foliage=[rect(1025,300,87,117)],wood_branches=True),
         pot('reception_plant_pot',(1043,411,39,32),(1028,305,81,109)),
         pot('lobby_tree',(253,514,65,91),(229,355,113,162),[rect(276,475,16,42)]),
         object_('luggage_shelf',661,[(366,631,268,30)],[
             rect(364,442,285,18),rect(367,461,16,192),rect(626,459,13,194),
             rect(419,527,204,15),rect(417,542,14,117),rect(380,619,38,14),
             rect(429,635,196,13),rect(382,524,38,9),
             rect(439,484,51,43),tube((450,482),(458,477),3),rect(458,477,20,4),
             rect(500,521,48,7),rect(560,514,49,13),rect(563,502,35,12),
             rect(438,566,54,70),rect(499,565,54,72),rect(559,566,55,70),
             rect(451,558,28,6),rect(511,557,26,7),rect(573,558,28,6)]),
         object_('drinks_machine',574,[(1121,551,143,23)],[rect(1121,282,143,280),
             rect(1128,562,13,11),rect(1244,562,13,11)]),
         box('west_bin',0,480,34,141),
         object_('garden_glass',612,[(1268,584,404,28)],[rect(1268,129,73,481),
             rect(1608,130,11,481),rect(1335,602,337,10)],glass=[rect(1342,141,264,459)])]
    return scene('TokyoHotel',582,(856,812),obs,
        {'Point':anchor(883,664),'Exit':anchor(136,640)},[
        sign((356,306,284,52),'東京ホテル','#e7d8bc','#352f29',size=32)],
        clerks={'Point':anchor(884,571)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('counter',613,[(601,585,434,28)],[rect(601,466,434,23),
             rect(601,489,434,121),rect(658,416,71,49),
             rect(599,209,11,258),rect(1024,209,11,258),rect(610,209,414,12)],
             glass=[rect(611,222,412,243)]),
         pot('waiting_tree',(253,539,66,85),(233,373,107,169),[rect(277,489,14,53)]),
         box('west_bin',0,479,35,146)]
    for i,x in enumerate([1076,1169,1261]): obs.append(chair('waiting_seat_'+str(i),x,496,94,147))
    return scene('TokyoExchange',602,(828,817),obs,
        {'Point':anchor(816,665),'Exit':anchor(137,649)},[
        sign((589,115,535,65),'外貨両替','#223b69',size=40),
        sign((1075,252,253,159),'両替\n\nUSD · EUR · GBP\n日本円','#222c39','#eed567',size=26)],
        clerks={'Point':anchor(815,570)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[box('west_column',145,0,55,660),box('east_column',1053,0,53,659),
         object_('ticket_gate_west',645,[(1307,618,61,27)],[
             [[1306,483],[1356,483],[1367,507],[1367,641],[1320,641],[1306,615]]]),
         object_('ticket_gate_middle',646,[(1438,618,64,28)],[
             [[1439,483],[1484,483],[1500,508],[1500,641],[1452,641],[1438,617]]]),
         object_('ticket_gate_east',646,[(1568,618,72,28)],[
             [[1575,483],[1622,484],[1639,508],[1639,644],[1581,644],[1568,615]]]),
         object_('gate_glass_west',644,[(1367,618,72,26)],[],glass=[rect(1367,513,72,76)]),
         object_('gate_glass_east',644,[(1500,618,69,26)],[],glass=[rect(1500,513,69,76)]),
         object_('ticket_machine',729,[(726,703,61,26)],[])]
    for i,x in enumerate([143,242,340]):obs.append(chair('platform_seat_'+str(i),x,723,99,146))
    return scene('TokyoTransit',610,(932,838),obs,{
        'Machine':anchor(757,776),'Platform':anchor(887,651),'Exit':anchor(1240,701)},[
        sign((562,182,175,66),'東京','#f0eadb','#151b21',size=39),
        sign((589,250,164,33),'Tokyo','#f0eadb','#151b21',size=25),
        sign((1344,202,175,65),'出口\nExit','#1b2938','#efd840',size=27)],
        fittings=[dict(kind='ticket',at=point(757,729))],
        motion_layers=[dict(rect=[0,198,847,208],
            texture='res://art/environments/motion/TokyoTransit.png',
            occluders=[[98,198,40,208],[723,198,39,208]])],
        interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[box('west_column',97,54,108,561),box('east_column',1388,52,68,590),
         pot('west_plant',(29,628,64,68),(14,529,99,104)),
         object_('loose_suitcase',659,[(1312,641,66,18)],[rect(1312,597,66,57),
             rect(1330,591,6,8),rect(1335,589,21,5),rect(1352,593,5,8),
             oval(1318,652,5,5),oval(1369,652,5,5)]),
         object_('front_belt',848,[(1112,768,560,80)],[
             [[1117,727],[1131,716],[1672,713],[1672,847],[1137,847],[1119,839],[1113,797]],
             rect(1221,709,97,75),rect(1342,744,97,42),rect(1476,704,94,81),
             rect(1245,696,6,15),rect(1250,694,31,7),rect(1276,700,6,11),
             rect(1374,734,6,11),rect(1380,731,22,6),rect(1398,736,5,9),
             rect(1504,695,6,11),rect(1509,692,23,6),rect(1527,698,6,9)]),
         object_('check_in_kiosk',702,[(738,675,62,27)],[])]
    for i,x in enumerate([139,207,274,342,409,477]):
        obs.append(chair('terminal_seat_'+str(i),x,564,66,118))
    obs.append(chair('bag_seat',552,579,59,96))
    for i,x in enumerate([1372,1434,1497,1560]):
        p=[rect(x,526,58,9),rect(x+3,535,6,103),rect(x+51,535,6,102),
           rect(x+3,574,51,7),rect(x+5,618,48,10),rect(x+5,632,48,6),
           oval(x+7,644,6,7),oval(x+52,644,6,7),
           tube((x+12,574),(x+15,559),3),tube((x+15,559),(x+38,559),3),
           tube((x+38,559),(x+41,574),3)]
        for xx in range(x+13,x+50,10):p.append(rect(xx,581,2,36))
        obs.append(object_('luggage_cart_'+str(i),653,[(x+2,631,57,22)],p))
    return scene('TokyoAirport',619,(765,838),obs,
        {'Point':anchor(769,750),'Exit':anchor(650,675)},[
        sign((878,190,265,65),'出発','#213b68',size=42),
        sign((994,410,201,37),'売店','#fff1ce','#293138',size=29),
        sign((736,599,67,23),'チェックイン','#233b50',size=10),
        sign((632,548,112,31),'← 市内バス','#273d57',size=15)],
        fittings=[dict(kind='ticket',at=point(769,702))],clerks={},
        prompt_overrides={'Point':'E — The check-in terminal','Exit':'E — Back to the city bus'},
        interaction_sizes=sizes('Point','Exit'))


def build():
    from .tokyo_finish import finish
    return finish({'TokyoYanaka':yanaka(),'TokyoJinbocho':jinbocho(),'TokyoAsakusa':asakusa(),
            'TokyoUeno':ueno(),'TokyoShinbashi':shinbashi(),'TokyoHotel':hotel(),
            'TokyoExchange':exchange(),'TokyoTransit':transit(),'TokyoAirport':airport()})
