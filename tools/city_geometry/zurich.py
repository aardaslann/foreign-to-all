"""Zürich: individually measured silhouettes and feet-level obstructions.

Source coordinates refer to each 1672 x 941 finished scene. Open furniture
and rail gaps stay transparent; a crown and trunk share one depth origin.
"""
from math import cos, sin, tau
from .shapes import anchor, point, object_, rect, tube, sign
from .london import scene, pole, rope_group


def planter(name, pot, crown, trunk=()):
    x,y,w,h=pot
    return object_(name,y+h,[(x+3,y+h-20,w-6,20)],
        [rect(x,y,w,h),*trunk],foliage=[rect(*crown)])


def lamp(name,x,top,bottom):
    return object_(name,bottom,[(x-18,bottom-16,36,16)],[
        [[x-18,bottom],[x+19,bottom],[x+19,bottom-10],[x+10,bottom-17],
         [x+10,top+177],[x+5,top+167],[x+5,top+78],[x+13,top+65],
         [x+20,top+30],[x+28,top+24],[x+15,top+13],[x+7,top+11],
         [x+4,top],[x-4,top],[x-7,top+11],[x-15,top+13],[x-28,top+24],
         [x-20,top+30],[x-13,top+65],[x-5,top+78],[x-5,top+167],
         [x-10,top+177],[x-10,bottom-17],[x-18,bottom-10]]])


def bench(name,x,y,w=129,h=74):
    # Three slats and separate legs, with open air underneath the seat.
    return object_(name,y+h,[(x+3,y+h-16,w-6,16)],[
        rect(x+8,y,w-16,27),rect(x+5,y+32,w-10,8),
        rect(x,y+42,w,12),rect(x+10,y+27,7,15),rect(x+w-17,y+27,7,15),
        rect(x+8,y+54,11,h-54),rect(x+w-20,y+54,11,h-54),
        rect(x+2,y+h-6,23,6),rect(x+w-26,y+h-6,23,6)])


def bicycle(name,left,right,cy,top):
    radius=(cy-top)*.45
    wheel_y=cy-radius
    polys=[]
    for cx in [left,right]:
        # Annular segments leave the wheel centres and every spoke gap open.
        outer=[(cx+radius*cos(i*tau/32),wheel_y+radius*sin(i*tau/32)) for i in range(33)]
        inner=[(cx+(radius-5)*cos(i*tau/32),wheel_y+(radius-5)*sin(i*tau/32)) for i in range(33)]
        polys += [[outer[i],outer[i+1],inner[i+1],inner[i]] for i in range(32)]
        for i in range(12):
            polys.append(tube((cx,wheel_y),(cx+(radius-6)*cos(i*tau/12),wheel_y+(radius-6)*sin(i*tau/12)),1.5))
    span=right-left
    crank=(left+span*.54,wheel_y+2)
    seat=(left+span*.40,top+16)
    stem=(right-10,top+7)
    for a,b,width in [((left,wheel_y),seat,4),(seat,crank,4),(crank,(left,wheel_y),4),
                      (seat,stem,4),(stem,crank,4),(stem,(right,wheel_y),5),
                      (seat,(seat[0]-3,top+2),4),(stem,(stem[0]-4,top-6),4),
                      ((stem[0]-4,top-6),(stem[0]+17,top-6),5),
                      ((seat[0]-14,top+2),(seat[0]+11,top+2),6)]: polys.append(tube(a,b,width))
    return object_(name,cy,[(left-radius,cy-17,right-left+2*radius,17)],polys)


def niederdorf():
    obs=[object_('cafe_tree',615,[(57,588,46,27)],[
        [[57,604],[67,604],[66,420],[43,389],[51,382],[72,401],[72,343],
         [88,343],[88,388],[111,368],[119,375],[90,406],[90,602],[103,609],[101,615],[55,615]]],
        foliage=[rect(0,160,219,334)])]
    # The terrace combines its umbrella and furniture; empty leg gaps are
    # separate polygons, never a rectangular copy of pavement behind them.
    for name,x,umbrella in [('cafe_west',-46,30),('cafe_east',181,218)]:
        obs.append(object_(name,622,[(max(0,x-14),596,126 if x>0 else 90,26)],[
            rect(x,559,87,11),rect(x+40,570,9,44),rect(x+26,613,34,7),
            rect(x-23,542,18,47),rect(x-18,588,52,10),rect(x-16,598,6,21),rect(x+23,598,6,21),
            rect(x+83,543,18,46),rect(x+61,589,37,10),rect(x+60,599,6,20),rect(x+94,599,6,20),
            [[umbrella-104,472],[umbrella-82,462],[umbrella-9,431],[umbrella,428],
             [umbrella+9,433],[umbrella+98,469],[umbrella+98,477],[umbrella-104,477]],
            rect(umbrella-4,476,8,84)]))
    obs.append(object_('menu_board',626,[(308,605,70,21)],[
        [[309,526],[371,526],[374,614],[379,624],[366,626],[361,610],[320,610],
         [317,626],[306,626]],rect(371,587,6,32)]))
    for name,pot,crown in [
        ('bakery_pot',(660,561,48,39),(648,512,67,54)),
        ('arch_pot',(839,562,47,38),(831,510,66,56)),
        ('passage_pot',(1088,554,49,42),(1078,510,66,49)),
        ('bookshop_pot',(1310,552,48,43),(1300,472,66,85)),
        ('east_pot',(1611,580,48,44),(1602,531,70,54))]:obs.append(planter(name,pot,crown))
    fountain=object_('fountain',674,[(1130,602,222,66),(1116,621,250,29)],[
        [[1117,584],[1147,576],[1214,575],[1214,550],[1220,546],[1220,504],
         [1208,495],[1210,484],[1217,478],[1225,447],[1222,429],[1226,397],
         [1229,366],[1236,353],[1243,366],[1246,397],[1250,427],[1247,447],
         [1256,478],[1263,485],[1264,496],[1255,504],[1255,546],[1261,552],
         [1261,575],[1322,576],[1354,584],[1357,605],[1352,646],[1367,652],
         [1367,665],[1334,674],[1148,674],[1116,665],[1116,653],[1127,647],[1123,607]]],
        water={'kind':'spouts','streams':[[point(1220,502),point(1200,509),point(1184,532),point(1178,581)],
                                        [point(1252,502),point(1272,510),point(1287,536),point(1291,583)]],
               'pool':[*point(1150,580),*point(183,12)]})
    obs.append(fountain)
    return scene('ZurichNiederdorf',583,(798,827),obs,
        {'HotelDoor':anchor(779,638),'ExchangeDoor':anchor(956,620),
         'TransitDoor':anchor(1055,605),'LocalSpot':anchor(1239,711),
         'NpcRuedi':anchor(763,812),'ExitEast':anchor(1617,827)},[
        sign((410,364,224,35),'BÄCKEREI','#49301c',size=27),
        sign((1381,363,259,36),'BUCHHANDLUNG','#192a3a',size=25),
        sign((319,540,43,63),'Kaffee\nTee\nGipfeli','#192a2e',size=7,object='menu_board'),
        sign((742,410,80,22),'HOTEL','#34402e',size=12),
        sign((919,385,77,22),'CHANGE','#1e3d54',size=11),
        sign((1018,456,77,19),'TRAM →','#16416c',size=10)],
        interaction_sizes={k:{'CollisionShape2D':[64,32]} for k in ['HotelDoor','ExchangeDoor','TransitDoor','LocalSpot']})


def langstrasse():
    obs=[lamp('west_lamp',70,365,676),lamp('east_lamp',1457,359,676),
         pole('bollard',383,549,676,18),
         object_('bin',675,[(1041,653,67,22)],[
             [[1048,570],[1098,570],[1107,578],[1107,667],[1099,675],[1041,675],
              [1041,582]]]),
         object_('produce',627,[(509,603,176,24)],[rect(509,576,176,49)],
             foliage=[rect(504,497,222,90)])]
    obs.append(planter('door_plant',(980,576,52,46),(969,462,81,117),[rect(1001,548,11,30)]))
    obs.append(object_('east_tree',628,[(1576,599,96,29)],
        [rect(1576,609,96,18),[[1622,612],[1622,438],[1605,420],[1610,412],
        [1626,425],[1626,360],[1642,360],[1642,426],[1665,404],[1672,413],
        [1645,444],[1646,612]]],foliage=[rect(1467,160,205,330),rect(1584,580,88,31)]))
    return scene('ZurichLangstrasse',615,(845,843),obs,
        {'AirportDoor':anchor(1236,665),'TransitDoor':anchor(351,654),'LocalSpot':anchor(778,660),
         'NpcFrauAmsler':anchor(1099,837),'KeyBeat':anchor(655,834),'ExitWest':anchor(47,835)},[
        sign((112,365,356,45),'WASCHSALON','#1759a0',size=30),
        sign((613,365,340,45),'ALIM FOOD','#a82d31',size=31),
        sign((1182,365,212,44),'KONZERT','#172132',size=28),
        sign((306,464,76,21),'TRAM →','#194269',size=11),
        sign((1191,468,154,23),'FLUGHAFENBUS →','#17395c',size=11)],
        prompt_overrides={'AirportDoor':'E — Take the airport shuttle','TransitDoor':'E — Walk to the tram stop'},
        interaction_sizes={k:{'CollisionShape2D':[68,32]} for k in ['AirportDoor','TransitDoor','LocalSpot']})


def seefeld():
    obs=[bench('bench_west',159,596),bench('bench_east',937,596),lamp('east_lamp',1566,384,698),
         object_('kiosk',682,[(319,657,270,25)],[
             rect(319,505,269,176),rect(310,487,286,19),rect(321,449,269,40)]),
         planter('front_pot',(1148,636,43,33),(1134,588,69,50))]
    obs.append(object_('west_tree',694,[(53,671,47,23)],[
        [[53,690],[61,675],[58,420],[43,394],[47,385],[62,403],[64,314],
         [81,314],[82,390],[116,359],[126,367],[83,411],[84,675],[100,685],[95,694]]],
        foliage=[rect(0,143,220,334)]))
    # Yard trees, fence and stone coping belong to the rear boundary. Their
    # upper silhouettes cannot erase a character passing in front of them.
    fence=[]
    for left,right in [(0,309),(593,872),(957,1211),(1414,1672)]:
        fence += [rect(left,618,right-left,40),rect(left,504,right-left,6),rect(left,600,right-left,6)]
        for x in range(left+9,right,19):
            fence += [rect(x-2,499,4,119),[[x-4,499],[x-4,493],[x,485],[x+4,493],[x+4,499]]]
    obs.append(object_('garden_fence',659,[(0,627,872,32),(957,627,715,32)],fence))
    return scene('ZurichSeefeld',626,(804,837),obs,
        {'TransitDoor':anchor(1301,692),'LocalSpot':anchor(466,722),'Encounter':anchor(964,827)},[
        sign((339,460,240,25),'KIOSK','#22334b',size=24),
        sign((1247,466,110,22),'TRAM →','#193b61',size=13),
        sign((365,613,172,23),'UTOQUAI →','#21394c',size=17,object='kiosk')],
        interaction_sizes={k:{'CollisionShape2D':[70,32]} for k in ['TransitDoor','LocalSpot']},
        encounter_exit={'to':anchor(1602,827),'via':[]},
        animation_patches=[dict(kind='water',rect=[*point(194,384),*point(121,50)])])


def west():
    obs=[bench('bench_west',372,570,154,68),bench('bench_east',1576,570,145,68),
         lamp('middle_lamp',985,397,682),lamp('east_lamp',1543,397,682),
         pole('bollard',216,552,682,16),
         planter('west_bed',(0,600,181,40),(0,558,186,49)),
         planter('bench_pot',(525,576,34,47),(469,509,109,75)),
         planter('middle_bed',(912,579,127,45),(900,508,141,76)),
         planter('square_pot',(1345,614,77,53),(1337,555,95,65)),
         planter('east_bed',(1452,580,133,55),(1432,403,240,178),[rect(1484,517,12,65)]),
         bicycle('bicycle_west',983,1035,675,596),bicycle('bicycle_east',1100,1159,675,595)]
    return scene('ZurichWest',612,(811,841),obs,
        {'TransitDoor':anchor(1320,661),'LocalSpot':anchor(753,652)},[
        sign((133,382,253,33),'WERKSTATT','#e0d8be','#1e2b38',25),
        sign((635,382,233,33),'MARKT','#e0d8be','#1e2b38',29),
        sign((1107,382,246,33),'ATELIER','#e0d8be','#1e2b38',26),
        sign((1292,471,62,22),'TRAM →','#1f3e5b',size=9)],
        interaction_sizes={k:{'CollisionShape2D':[70,32]} for k in ['TransitDoor','LocalSpot']},
        animation_patches=[dict(kind='viaduct_train',rect=[*point(0,92),*point(1672,88)],
            covers=[[*point(x,0),*point(w,207)] for x,w in [(174,29),(288,27),(451,13),(1039,14),(1209,30),(1346,22)]])])


def oerlikon():
    obs=[bench('bench',423,605,218,60),
         bicycle('bike_west',215,276,690,621),bicycle('bike_east',332,389,690,621),
         planter('pot',(659,603,42,41),(645,493,64,112),[rect(675,572,10,34)])]
    for name,pot,crown,trunk in [
        ('west_tree',(0,615,164,45),(0,359,170,219),[[51,615],[51,535],[27,509],[35,499],[59,521],[64,491],[78,491],[78,613]]),
        ('bench_tree',(393,605,251,51),(411,335,201,222),[[488,605],[488,529],[471,512],[477,503],[494,518],[498,463],[510,463],[510,511],[532,489],[539,496],[515,527],[514,605]]),
        ('cafe_tree',(740,605,396,52),(780,336,201,221),[[869,605],[869,522],[850,497],[858,490],[878,509],[878,467],[890,467],[890,510],[913,494],[919,501],[891,531],[891,605]])]:
        obs.append(planter(name,pot,crown,[trunk]))
    obs.append(planter('east_bed',(1545,606,127,50),(1535,556,137,55)))
    obs.append(planter('back_cafe_bed',(1386,584,143,35),(1384,550,147,40)))
    for name,x,y,base in [('canopy_west',809,306,648),('canopy_middle',1216,363,628),
                          ('canopy_east',1442,306,689),('canopy_rear',1525,307,650)]:
        obs.append(object_(name,base,[(x-3,base-18,35,18)],[rect(x,y,28,base-y-6),rect(x-4,base-6,36,6)]))
    for name,x in [('west',820),('middle',1021),('east',1407)]:obs.append(pole('bollard_'+name,x,574,697,15))
    for name,x in [('cafe',1049),('east',1507)]:
        obs.append(object_('umbrella_'+name,647,[(x-7,633,14,14)],[rect(x-4,503,8,140),
            [[x-103,497],[x-12,459],[x,454],[x+12,459],[x+108,498],
             [x+108,506],[x-104,506]]]))
    return scene('ZurichOerlikon',633,(1180,839),obs,
        {'TransitDoor':anchor(1293,670),'LocalSpot':anchor(695,702)},[
        sign((1082,158,405,51),'OERLIKON','#d4cbb6','#172c40',32),
        sign((1249,483,91,23),'S-BAHN →','#16416b',size=11),
        sign((649,457,60,24),'MFO →','#1d3e52',size=10)],
        interaction_sizes={k:{'CollisionShape2D':[68,32]} for k in ['TransitDoor','LocalSpot']})


def hotel():
    obs=[object_('reception',683,[(215,647,661,36)],[rect(205,466,675,34),rect(218,500,655,180),
        rect(520,396,102,70),rect(737,439,36,28),rect(750,412,13,30),
        [[749,414],[728,409],[722,402],[730,396],[750,400],[762,410]],
        [[211,411],[227,355],[278,355],[297,411]],rect(246,412,11,48),rect(228,460,47,7),
        rect(787,422,63,46)],foliage=[rect(768,328,111,96)]),
        object_('luggage_trolley',704,[(15,674,140,30)],[
            rect(17,656,136,18),rect(32,600,72,57),rect(108,601,24,56),rect(45,593,43,9),
            tube((22,657),(22,462),8),tube((22,462),(34,436),8),tube((34,436),(71,411),8),
            tube((71,411),(107,425),8),tube((107,425),(126,453),8),tube((126,453),(130,655),8),
            rect(76,415,9,240),rect(25,532,104,9),rect(16,676,29,24),rect(94,677,30,27),rect(128,672,22,21)]),
        object_('chair_west',708,[(1056,680,208,28)],[
            [[1061,528],[1214,528],[1222,576],[1263,578],[1263,665],[1248,671],
             [1254,698],[1240,702],[1238,671],[1166,671],[1164,708],[1150,708],
             [1145,671],[1077,669],[1074,699],[1059,699],[1062,664],[1054,655],[1054,540]]]),
        object_('chair_east',708,[(1339,682,214,26)],[
            [[1420,526],[1548,526],[1554,658],[1545,668],[1551,697],[1536,703],
             [1532,672],[1450,672],[1452,708],[1436,708],[1432,673],[1360,671],
             [1357,698],[1340,698],[1343,671],[1334,663],[1334,580],[1408,580],[1410,536]]]),
        object_('table',689,[(1273,674,46,15)],[
            [[1266,542],[1382,542],[1401,549],[1401,562],[1371,569],
             [1305,569],[1305,674],[1317,676],[1317,687],[1274,687],[1274,676],
             [1286,673],[1286,569],[1263,565]],rect(1285,554,11,12)]),
        object_('umbrella_pot',674,[(1578,653,78,21)],[rect(1577,544,79,129),
            [[1588,545],[1586,491],[1576,469],[1576,455],[1586,447],[1598,451],
             [1604,460],[1604,482],[1596,482],[1594,461],[1588,459],[1585,467],
             [1597,493],[1603,544]],rect(1606,491,13,54),
            [[1624,545],[1631,483],[1623,482],[1624,460],[1634,448],[1646,450],
             [1654,463],[1654,475],[1645,475],[1644,462],[1638,458],[1633,462],
             [1633,482],[1629,544]]])]
    return scene('ZurichHotel',634,(1011,817),obs,
        {'Point':anchor(665,724),'Exit':anchor(1000,671)},[
        sign((537,142,326,142),'HOTEL\nZÜRICH','#e4d6b7','#182b3c',33),
        sign((1299,170,213,25),'ZVV  ZÜRICH','#dfd7c6','#1b2a3b',20)],
        clerks={'Point':anchor(668,501)},interaction_sizes={'Point':{'CollisionShape2D':[84,34]},'Exit':{'CollisionShape2D':[70,34]}})


def exchange():
    obs=[object_('counter',688,[(384,652,625,36)],[rect(384,496,628,32),rect(394,528,615,155),
        rect(409,456,144,42),rect(421,404,47,51),rect(480,410,62,47),
        rect(706,411,105,69),rect(747,478,26,16),rect(919,458,83,40)],
        glass=[rect(400,275,602,222)]),
        object_('side_counter',700,[(1044,672,365,28)],[rect(1037,498,373,30),rect(1044,528,365,169),
        rect(1064,459,77,39),rect(1072,444,44,16),rect(1159,443,64,56),rect(1240,480,57,18)]),
        object_('leaflet_stand',719,[(187,695,109,24)],[
            [[185,486],[275,486],[293,648],[288,712],[279,718],[270,699],
             [202,716],[191,710]],rect(198,706,7,12)]),
        planter('plant',(106,587,88,147),(88,404,119,183),[rect(143,545,13,45)]),
        rope_group('single_queue_post',[560],530,730),rope_group('queue',[1076,1333],542,742)]
    return scene('ZurichExchange',690,(920,834),obs,
        {'Point':anchor(811,740),'Exit':anchor(1537,724)},[
        sign((462,126,492,112),'CHANGE\nZÜRICH','#dfcda7','#1a2732',31),
        sign((1102,188,254,191),'EUR   0.98\nUSD   1.12\nGBP   0.86\nCHF   1.00','#171e27','#eabd50',25)],
        clerks={'Point':anchor(641,531)},interaction_sizes={'Point':{'CollisionShape2D':[86,34]},'Exit':{'CollisionShape2D':[70,34]}})


def transit():
    obs=[object_('ticket_machine',764,[(1224,742,97,22)],[
        [[1229,530],[1314,530],[1320,539],[1320,759],[1224,759],[1224,746],[1229,741]]]),
        object_('recycling_bin',798,[(243,773,104,25)],[
            [[243,621],[269,621],[269,606],[341,606],[348,616],[348,785],
             [336,798],[243,798]]])]
    seats=[]
    for x in [398,497,594,692,787]:
        seats += [rect(x,610,94,90),rect(x-14,709,111,22),
                  rect(x+5,700,8,9),rect(x+82,700,8,9)]
    seats += [rect(382,734,508,17)]
    for x in [389,639,879]:
        seats += [rect(x-6,750,15,39),rect(x-13,788,27,12)]
    seats += [rect(383,669,12,39),rect(879,672,9,37)]
    obs.append(object_('waiting_seats',800,[(378,760,514,40)],seats))
    for name,x,w,base in [('front_column',160,39,779),('west_column',80,35,676),
                          ('middle_column',1015,35,667),('east_column',1328,31,664)]:
        obs.append(object_(name,base,[(x-10,base-19,w+21,19)],
            [rect(x,0,w,base-18),rect(x-10,base-18,w+21,18)]))
    obs.append(object_('shelter',677,[(0,647,542,30)],
        [rect(0,432,535,17),rect(0,613,530,32),
         rect(225,448,16,225),rect(378,447,15,225),rect(527,439,14,232)],
        glass=[rect(0,451,223,162),rect(242,451,134,162),rect(396,451,129,162)]))
    return scene('ZurichTransit',646,(1100,854),obs,
        {'Machine':anchor(1273,808),'Platform':anchor(1104,820),'Exit':anchor(1590,718)},[
            sign((533,109,420,44),'ZÜRICH HB','#073d79',size=31),
            sign((533,170,420,37),'S-BAHN','#073d79',size=28),
            sign((482,226,465,37),'ZVV  ·  TRAM  ·  BUS','#073d79',size=24),
            sign((1233,125,181,50),'Gleis 3','#073d79',size=26),
            sign((1238,212,175,44),'Ausgang','#073d79',size=24),
            sign((1239,539,65,14),'BILLETT','#153c65',size=8,object='ticket_machine')],
        interaction_sizes={k:{'CollisionShape2D':[70,32]} for k in ['Machine','Platform','Exit']},
        motion_layers=[dict(kind='doors',rect=[*point(x,411),*point(w,174)],period=14.0)
                       for x,w in [(1095,65),(1456,78)]])


def airport():
    obs=[object_('check_in',716,[(999,689,290,27)],
        [rect(999,582,291,22),rect(1007,604,274,87),rect(999,692,291,23),
         rect(1225,550,49,32)]),
        planter('west_tree',(193,651,79,80),(174,505,119,149),[rect(225,608,15,47)]),
        planter('desk_tree',(902,620,72,80),(876,464,124,161),[rect(932,584,12,40)])]
    for name,x,w,base in [('west_column',118,62,752),('middle_column',806,71,756)]:
        obs.append(object_(name,base,[(x-11,base-27,w+23,27)],
            [rect(x,0,w,base-27),rect(x-11,base-27,w+23,27)]))
    seats=[rect(291,699,486,12)]
    for x in [303,381,461,540,619,699]:
        seats += [rect(x,606,75,70),rect(x-13,677,90,22)]
    for x in [301,521,545,766]:
        seats += [rect(x-4,710,11,12),rect(x-7,722,19,7)]
    obs.append(object_('waiting_seats',731,[(291,711,486,20)],seats))
    carts=[]
    for x in [1330,1370,1410,1450,1481,1512,1542,1574]:
        carts += [tube((x,732),(x,631),7),tube((x,631),(x-10,619),7),
                  tube((x-10,619),(x-12,610),12),tube((x-12,610),(x+2,612),12),
                  tube((x+2,612),(x+15,624),11),tube((x+15,624),(x+18,733),7),
                  rect(x+4,652,7,75),rect(x-7,733,43,12),
                  [[x-8,745],[x+4,745],[x+8,751],[x+8,762],[x-5,765],[x-11,758]],
                  [[x+20,744],[x+31,744],[x+37,749],[x+37,759],[x+30,765],[x+18,763],[x+14,758],[x+14,750]]]
    obs.append(object_('trolleys',768,[(1320,741,294,27)],carts))
    return scene('ZurichAirport',688,(1125,838),obs,
        {'Point':anchor(1145,757),'Exit':anchor(60,756)},[
            sign((222,188,229,49),'CHECK-IN','#0d386b',size=29),
            sign((222,285,289,49),'ABFLUG','#0d386b',size=30),
            sign((901,190,221,48),'GATES','#0d386b',size=31),
            sign((901,286,221,49),'ZÜRICH HB','#0d386b',size=26),
            sign((1313,197,273,44),'ZÜRICH AIRPORT','#122337',size=24),
            sign((8,416,100,18),'AUSGANG','#123554',size=11)],
        clerks={'Point':anchor(1160,618)},
        interaction_sizes={'Point':{'CollisionShape2D':[82,34]},'Exit':{'CollisionShape2D':[48,32]}})


def build():
    from .zurich_finish import finish
    return finish({'ZurichNiederdorf':niederdorf(),'ZurichLangstrasse':langstrasse(),
            'ZurichSeefeld':seefeld(),'ZurichWest':west(),'ZurichOerlikon':oerlikon(),
            'ZurichHotel':hotel(),'ZurichExchange':exchange(),
            'ZurichTransit':transit(),'ZurichAirport':airport()})
