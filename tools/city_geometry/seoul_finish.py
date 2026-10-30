"""Measured Seoul replacement plates: full silhouettes, compact ground contacts.

Native Hangul is separate from the background. These installation measurements
do not imply the deferred exhaustive walking/contact audit has been completed.
"""
from .shapes import point, anchor, rect, tube, object_, SY
from .moscow import pot, pipe, oval, board
from .seoul import sign, box, seat


def finish(rows):
    for key,row in rows.items():
        row.update(texture=f'res://art/environments/scenes/{key}-retro.png',
                   pixel_art=True,art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
    for key,fn in [('Euljiro',euljiro),('Jongno',jongno),('Mangwon',mangwon),
                   ('Hongdae',hongdae),('Seongsu',seongsu),('Hotel',hotel),
                   ('Exchange',exchange),('Transit',transit),('Airport',airport)]:
        fn(rows['Seoul'+key])
    return rows


def euljiro(row):
    row['objects']=[
        object_('paper_stack',732,[(18,714,142,18)],[
            rect(18,627,142,103),rect(52,577,49,50),rect(103,588,54,41)]),
        box('west_blue_crates',185,650,89,83),
        box('west_cartons',285,649,59,84),box('middle_cartons',368,646,57,87),
        object_('blue_trolley',741,[(433,725,75,16)],[rect(433,649,75,78),
            rect(435,727,9,14),rect(495,727,9,14)]),
        pot('print_plant',(633,677,65,58),(626,583,78,98)),
        box('tool_cabinet',755,650,68,84),box('east_tool_drawers',986,646,66,88),
        pot('cafe_west_pot',(1330,692,55,43),(1322,632,68,63)),
        pot('cafe_east_pot',(1599,693,47,43),(1590,638,65,59)),
        pipe('print_drain',625,482,731)]
    # Continuous stringers and individual rails, with the staircase's open
    # negative spaces kept transparent instead of lifting a rectangular image.
    stair=[rect(1087,370,55,26),rect(1088,389,15,98),
           [[1136,387],[1272,506],[1295,551],[1270,551],[1128,417]],
           rect(1278,542,59,29),rect(1258,568,14,167),
           [[1298,557],[1154,733],[1124,733],[1126,714],[1277,541]],
           rect(1318,569,11,157),rect(1127,640,9,81),
           tube((1137,308),(1287,453),9),tube((1137,351),(1278,492),7),
           tube((1132,641),(1277,488),9),tube((1142,663),(1298,507),7),
           rect(1133,309,8,68),rect(1276,453,8,88)]
    for i in range(7):
        stair += [tube((1156+i*18,327+i*18),(1156+i*18,388+i*18),6),
                  tube((1153+i*18,619-i*19),(1153+i*18,676-i*19),6)]
    row['objects'].append(object_('outside_stair',735,
        [(1126,715,37,20),(1258,719,14,16),(1318,711,11,15)],stair))
    row['lettering']=[
        sign((177,386,291,74),'을지인쇄','#eddfc5','#273d49',36),
        sign((723,390,337,77),'태광공구','#dfdfd2','#264153',36),
        sign((1365,411,273,54),'카페 · 환전','#292d2b',size=31),
        sign((1099,515,91,26),'숙박 ↑','#293e4e',size=14),
        sign((537,527,69,25),'지하철','#254936',size=12)]
    row['anchors'].update(TransitDoor=anchor(568,777))
    row['animation_patches']=[dict(kind='rotor_marks',rect=[*point(576,399),*point(40,39)],speed=4.0)]


def jongno(row):
    row['objects']=[
        object_('hall_planter',774,[(491,757,136,17)],
            [rect(485,720,143,12),rect(491,732,135,29),
             rect(491,761,10,13),rect(616,761,10,13),
             *[rect(x,y,9,9) for x,y in [(503,681),(532,676),(566,681),(601,682),(537,703),(580,701)]]],
            foliage=[rect(486,651,139,72)],wood_branches=True),
        pot('game_west_pot',(893,736,43,46),(887,664,56,74)),
        pot('game_east_pot',(1247,740,34,44),(1240,707,45,36)),
        box('stationery_cabinet',1392,694,166,67),
        board('stationery_poster',1557,670,60,96),
        object_('game_table',788,[(960,772,276,16)],[
            rect(956,718,283,22),rect(966,740,11,47),rect(1224,740,12,47),
            rect(1065,740,11,47),rect(972,768,259,8),
            rect(1068,704,63,14),rect(965,710,78,8),rect(1142,711,61,7)]),
        box('watch_shop_pier',10,575,28,185),
        box('hall_pier',449,437,24,324),box('game_shop_pier',938,576,17,206),
        box('east_shop_pier',1634,578,23,183)]
    row['lettering']=[
        sign((546,307,462,77),'종로상가','#e4d4bd','#172a3d',43),
        sign((47,502,264,45),'시계수리','#282a29',size=31),
        sign((993,501,202,50),'보드게임','#204968',size=31),
        sign((1383,495,210,68),'문구','#ece7d9','#1c2c3d',34),
        sign((720,515,134,24),'공항철도','#214e5d',size=14),
        sign((357,600,57,24),'지하철','#26433a',size=11),
        sign((1571,685,34,60),'문구','#ecdfc8','#31443c',13,object='stationery_poster')]
    row['anchors'].update(LocalSpot=anchor(1314,782))
    row['lettering'].append(sign((1290,566,54,31),'광장시장','#254b43',size=10))
    row.setdefault('prompt_overrides',{})['LocalSpot']='E — Gwangjang Market'


def mangwon(row):
    row['objects']=[
        object_('fruit_stand',694,[(43,674,339,20)],[
            rect(43,624,339,69),
            [[42,624],[47,593],[66,573],[96,558],[119,564],[143,555],
             [168,558],[185,547],[208,566],[234,558],[266,562],[288,555],
             [302,568],[330,561],[369,571],[382,598],[382,626]]]),
        box('juice_crates',387,548,77,74),box('blue_crates_west',386,622,70,72),
        box('blue_crates_east',461,622,69,72),
        object_('aisle_stack',688,[(532,670,28,18),(560,643,42,24),(602,594,36,43)],[
            rect(531,575,28,111),rect(550,521,47,126),rect(521,475,58,99),
            rect(537,402,58,64),rect(585,411,17,47),rect(591,519,20,92),
            rect(604,562,29,41),rect(614,599,24,22),
            tube((584,533),(613,506),8),tube((613,507),(624,512),8),
            tube((620,530),(640,551),6)]),
        object_('banchan_counter',694,[(687,676,290,18)],[rect(681,618,299,16),
            rect(687,634,290,59),rect(707,565,255,53)]),
        object_('counter_case_stack',692,[(987,673,96,19)],[rect(984,558,101,132),
            rect(1007,520,58,38),rect(1012,508,47,12)]),
        box('home_goods_display',1104,562,96,132),box('detergent_crates',1205,560,147,134),
        object_('umbrella_rack',694,[(1356,675,50,19)],[rect(1356,538,50,155),
            rect(1361,526,44,12),rect(1376,516,8,10)])]
    row['objects'].append(object_('delivery_scooter',684,
        [(1461,666,54,18),(1595,666,53,18),(1515,655,79,16)],[
        oval(1488,657,28,27),oval(1622,657,27,27),
        [[1465,635],[1472,615],[1504,602],[1536,606],[1548,619],[1568,639],
         [1586,638],[1586,612],[1594,591],[1610,591],[1613,617],[1631,617],
         [1649,632],[1649,639],[1627,638],[1611,644],[1590,660],[1523,660],[1509,637]],
        rect(1477,589,77,14),rect(1450,540,72,49),
        tube((1602,602),(1594,565),9),rect(1591,552,20,23),
        tube((1572,557),(1607,557),5),
        tube((1577,557),(1572,538),4),tube((1593,551),(1597,534),4),
        oval(1572,534,6,8),oval(1598,533,6,8)]))
    row['lettering']=[
        sign((617,154,432,70),'망원시장','#efe0b8','#163343',45),
        sign((115,396,220,50),'청과','#f0ecdd','#28513e',31),
        sign((717,397,232,50),'반찬','#f3e7d5','#1e3448',33),
        sign((1114,396,220,49),'생활용품','#e9e9db','#204257',28),
        sign((648,492,34,59),'지하철\n↓','#1f4840',size=9)]


def hongdae(row):
    row['objects']=[
        object_('instrument_case',751,[(46,734,67,17)],[rect(47,590,66,146),
            rect(47,736,12,15),rect(101,736,12,15)]),
        object_('guitar_case',751,[(119,734,50,17)],[
            [[120,739],[120,651],[127,639],[137,635],[158,638],[165,653],[165,739]],
            rect(141,621,9,16),rect(119,739,11,12),rect(158,738,11,13)]),
        pot('indie_pot',(371,687,47,49),(365,646,58,44)),
        pot('cafe_tree',(688,693,91,63),(637,499,196,195),[
            [[721,695],[721,666],[694,639],[698,633],[728,655],[728,620],
             [738,620],[739,655],[764,632],[770,637],[742,666],[742,695]]]),
        object_('flower_planter',756,[(919,739,185,17)],[
            rect(913,699,197,14),rect(919,713,185,36),
            rect(919,749,12,7),rect(1092,749,12,7),
            *[rect(x,y,8,8) for x,y in [(941,675),(969,670),(994,680),(1021,670),(1047,680),(1081,676)]]],
            foliage=[rect(916,653,193,48)],wood_branches=True),
        pot('cafe_end_pot',(1113,704,33,40),(1106,659,48,49)),
        pot('live_door_pot',(1248,695,38,39),(1245,639,43,60))]
    row['lettering']=[
        sign((94,407,239,56),'연습실 · 지하철','#254967',size=29),
        sign((435,406,244,63),'indie','#f2e3bb','#302b22',32),
        sign((777,416,304,60),'커피','#f2e3bb','#302b22',35),
        sign((1299,424,335,60),'라이브','#292c2d',size=42),
        sign((1195,531,32,31),'LIVE','#cc9b4b','#29383e',8),
        sign((1195,603,32,32),'오늘','#ce5167','#f5e9d0',10)]


def water_tap(name,x):
    return object_(name,691,[(x-7,679,14,12)],[
        rect(x-5,648,10,39),rect(x-8,683,16,8),rect(x-10,643,19,8),
        rect(x-3,632,7,12),rect(x-13,636,27,5),rect(x+9,638,9,8)])


def seongsu(row):
    row['objects']=[water_tap('west_water_tap',172),water_tap('east_water_tap',211),
        pot('workshop_tree',(895,640,88,64),(883,207,132,436),[rect(936,575,14,68)]),
        object_('shoemaker_table',694,[(1044,676,209,18)],[
            rect(1036,623,224,13),rect(1046,636,10,57),rect(1246,636,10,57),
            rect(1130,636,9,56),rect(1051,618,187,6),
            rect(1045,607,36,17),rect(1092,609,32,15),rect(1133,611,53,13),
            rect(1195,602,35,22),tube((1216,604),(1237,576),5),
            [[1202,566],[1223,566],[1236,575],[1237,583],[1203,576]]]),
        object_('workshop_drawers',699,[(1264,682,78,17)],[rect(1264,522,78,167),
            rect(1264,689,9,10),rect(1332,689,10,10),rect(1293,496,21,26)]),
        object_('work_stool',694,[(1067,680,44,14)],[rect(1063,647,48,10),
            [[1066,657],[1073,657],[1070,692],[1063,692]],
            [[1101,657],[1108,657],[1112,692],[1105,692]],rect(1069,677,36,5)]),
        object_('tool_step',691,[(1158,680,33,11)],[rect(1157,667,35,10),
            rect(1159,677,7,14),rect(1184,677,7,14)]),
        box('doorbell_post',1598,539,30,155)]
    row['lettering']=[
        sign((1040,402,300,64),'구두수선','#f0e5c4','#29332d',35),
        sign((377,355,480,36),'카페 · 지하철 →','#234159',size=25),
        sign((79,504,142,39),'공장 1995','#293c4c',size=20)]
    row['motion']=[dict(kind='motes',rect=[*point(1048,565),*point(180,73)])]


def hotel(row):
    row['floor']=point(0,574)[1]
    row['objects']=[
        object_('reception',575,[(376,557,573,18)],[rect(368,447,590,21),
            rect(376,468,573,107),rect(510,429,44,18),rect(880,429,44,18),
            rect(839,434,23,13),rect(848,429,6,5)]),
        object_('luggage_trolley',576,[(270,560,93,16)],[
            rect(270,439,7,122),rect(354,440,7,121),
            tube((273,440),(293,426),5),tube((293,426),(315,421),5),
            tube((315,421),(338,426),5),tube((338,426),(358,440),5),
            rect(315,413,8,10),rect(283,449,65,108),
            oval(277,568,7,8),oval(352,568,7,8)]),
        pot('desk_plant',(983,466,81,106),(956,317,135,151)),
        pot('floor_plant',(1322,718,68,52),(1298,595,115,128)),
        object_('front_bench',732,[(959,716,293,16)],[rect(955,642,300,28),
            rect(963,670,282,45),rect(960,669,15,62),rect(1234,669,16,62)]),
        box('window_cabinet',1406,495,165,83),
        pot('entry_plant',(54,464,30,24),(49,405,46,62)),
        box('entry_cabinet',50,488,42,88)]
    for i,x in enumerate([202,302,400]):
        row['objects'].append(object_('lobby_seat_'+str(i),771,[(x,753,98,18)],[
            rect(x+16,642,83,65),rect(x+4,707,93,37),rect(x,685,10,84),
            rect(x+89,684,10,86),rect(x+9,744,11,26),rect(x+78,744,11,26)]))
    row['clerks']={'Point':anchor(683,490)}
    row['anchors'].update(Point=anchor(683,632),Exit=anchor(180,614))
    row['lettering']=[sign((578,282,258,47),'서울 호텔','#795236',size=31)]


def exchange(row):
    row['objects']=[
        object_('exchange_counter',591,[(465,574,510,17)],[
            rect(455,505,531,20),rect(465,525,510,66),
            rect(465,326,12,179),rect(966,326,11,179),rect(465,325,512,11),
            rect(502,417,94,72),rect(541,467,16,36),rect(522,495,51,8),
            rect(603,477,29,26),rect(913,483,36,22)],
            glass=[rect(477,336,489,169)]),
        pot('waiting_plant',(1404,520,93,77),(1385,357,126,166)),
        object_('leaflet_rack',593,[(1038,577,125,16)],
            [rect(1038,454,6,138),rect(1158,458,6,134),rect(1044,460,114,130)]),
        box('west_service_column',260,72,137,517),box('east_service_column',1514,72,73,515)]
    for i,x in enumerate([334,501,713]):
        row['objects'].append(object_('queue_post_'+str(i),741,[(x-21,725,42,16)],[
            oval(x,631,11,11),rect(x-7,641,14,84),
            [[x-10,721],[x+10,721],[x+21,727],[x+22,740],[x-22,740],[x-22,727]]]))
    row['objects'].append(object_('queue_belt',739,[(345,727,357,12)],[rect(345,638,357,13)]))
    row['clerks']={'Point':anchor(784,548)}
    row['anchors'].update(Point=anchor(851,646))
    row['lettering']=[
        sign((599,192,380,56),'서울 환전','#e7e0ca','#194365',34),
        sign((1062,147,302,214),'환전\n\nUSD · JPY\nCNY · EUR\nKRW','#142021','#9bdb9b',26),
        sign((303,364,63,89),'안내\n\n신분증\n영수증','#e9e8db','#37546b',10),
        sign((1049,469,43,34),'서울','#dde3dc','#365c77',12,object='leaflet_rack'),
        sign((1110,465,43,47),'지도','#4c707a',size=12,object='leaflet_rack'),
        sign((1048,539,47,41),'안내','#e1b174','#395561',12,object='leaflet_rack')]


def transit(row):
    # Ticket interaction follows the painted machine, with no duplicate native
    # fixture or invisible leftover footprint out on the walking lane.
    row['fittings']=[]
    row['objects']=[
        box('west_column',308,0,137,674),box('east_column',1524,0,135,687),
        object_('ticket_machine',592,[(59,576,138,16)],[rect(59,373,138,211),
            rect(64,584,17,8),rect(174,584,17,8)])]
    for i,x in enumerate([218,303,385]):
        row['objects'].append(seat('platform_seat_'+str(i),x,695,80,99))
    row['anchors'].update(Machine=anchor(127,645),Platform=anchor(817,650))
    row['lettering']=[
        sign((653,160,367,46),'을지로3가','#e0e1dc','#162630',32),
        sign((653,208,367,28),'Euljiro 3(sam)-ga','#e0e1dc','#162630',19),
        sign((1559,391,64,101),'출구\n→','#1b2431',size=22,object='east_column'),
        sign((351,394,48,61),'승차권\n안내','#e8e7d1','#234334',10,object='west_column'),
        sign((1103,143,231,88),'지하철\n노선 안내','#e3decc','#245643',24)]
    row['motion_layers']=[dict(kind='doors',rect=[*point(704,344),*point(218,229)]),
                          dict(kind='doors',rect=[*point(1127,344),*point(230,229)])]


def airport(row):
    row['objects']=[
        object_('baggage_office',680,[(29,661,306,19)],[rect(29,400,306,118),
            rect(29,518,56,82),rect(235,518,100,82),rect(46,600,239,17),
            rect(53,617,225,61)],glass=[rect(85,519,150,81)]),
        object_('luggage_belt',723,[(60,704,424,19)],[rect(60,674,424,49),
            rect(132,627,86,50),rect(303,625,80,62),rect(397,631,78,53),
            rect(160,580,8,47),rect(165,577,23,8),rect(182,585,8,42),
            rect(333,612,22,13),rect(348,599,8,26),
            rect(424,600,8,31),rect(431,595,10,7),rect(439,601,7,29)]),
        pot('west_back_planter',(314,590,216,81),(326,512,187,82)),
        pot('back_west_shrub',(579,589,143,81),(594,495,114,98)),
        pot('back_east_shrub',(922,589,130,81),(942,491,120,101)),
        # The tree now grows in the front planter. Its complete crown, trunk,
        # flowers and box form one depth object, not separately sorted pieces.
        object_('garden_tree_planter',721,[(605,704,353,17)],[
            rect(598,639,366,18),rect(605,657,353,64),
            [[790,638],[790,575],[774,557],[754,547],[758,539],[782,550],
             [792,561],[792,533],[806,533],[807,561],[828,540],[833,546],
             [810,574],[810,638]],
            *[rect(x,y,7,7) for x,y in [(643,602),(661,591),(687,601),(712,614),
                                        (879,589),(894,612),(914,596),(933,617)]]],
            foliage=[rect(690,334,222,241),rect(624,578,116,62),rect(850,578,96,62),
                     rect(735,617,116,23)],wood_branches=True),
        object_('check_in',677,[(1117,660,203,17)],[rect(1112,588,210,18),
            rect(1117,606,203,71),rect(1126,520,80,54),rect(1157,555,20,33),
            rect(1231,576,57,12),rect(1264,567,25,9)])]
    for i,x in enumerate([1411,1480,1548,1617]):
        row['objects'].append(object_('ticket_gate_'+str(i),674,[(x,658,25,16)],
            [rect(x,555,25,119)],glass=[rect(x+6,498,12,57)]))
    row['clerks']={'Point':anchor(1236,630)}
    row['lettering']=[
        sign((120,136,407,93),'국내선\nDomestic','#164b91',size=32),
        sign((651,137,400,92),'국제선\nInternational','#164b91',size=32),
        sign((1172,124,409,119),'출발 안내\n\n서울 · 도쿄 · 하노이\n베를린 · 이스탄불',
             '#151f24','#ead46d',23),
        sign((58,446,207,37),'수하물','#184975',size=27,object='baggage_office'),
        sign((1377,371,242,68),'철도 · Transit','#1a4c7f',size=27)]
