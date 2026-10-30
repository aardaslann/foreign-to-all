"""Seoul source layouts, realigned to replacement plates by seoul_finish."""
from .shapes import point, anchor, rect, tube, object_, sign as base_sign
from .moscow import scene, pot, oval, board
from .rome import sizes

FONT='res://art/fonts/NotoSansKR.ttf'


def sign(bounds,text,bg,ink='#f3ebd6',size=20,**extra):
    if any('\uac00'<=c<='\ud7a3' for c in text):
        extra['font']=FONT
    return base_sign(bounds,text,bg,ink,size,**extra)


def box(name,x,y,w,h):
    return object_(name,y+h,[(x,y+h-18,w,18)],[rect(x,y,w,h)])


def stool(name,x,y,w,h):
    # A low step occupies the ground under its top as well as its front legs.
    return object_(name,y+h,[(x+2,y+2,w-4,h-2)],[
        rect(x,y,w,11),rect(x+4,y+11,7,h-11),rect(x+w-11,y+11,7,h-11),
        rect(x+11,y+h-10,w-22,6)])


def seat(name,x,y,w=79,h=99):
    return object_(name,y+h,[(x+3,y+h-15,w-6,15)],[
        [[x+9,y],[x+w-9,y],[x+w-3,y+6],[x+w-3,y+48],[x+3,y+48],[x+3,y+8]],
        [[x+3,y+48],[x+w-3,y+48],[x+w,y+57],[x+w,y+79],[x,y+79],[x,y+57]],
        rect(x+4,y+79,12,h-79),rect(x+w-16,y+79,12,h-79)])


def euljiro():
    obs=[object_('paper_boxes',731,[(17,712,144,19)],[
             rect(17,653,144,77),rect(50,578,56,74),rect(106,588,50,66)]),
         box('west_crates',187,652,84,80),box('print_cartons',285,652,57,80),
         box('middle_cartons',365,636,71,96),
         object_('blue_trolley',752,[(418,732,111,20)],[
             rect(450,622,79,74),rect(419,697,110,45),
             rect(419,742,13,10),rect(514,742,14,10)]),
         box('print_cabinet',552,595,68,135),
         pot('print_plant',(638,675,59,59),(632,588,69,90)),
         box('tool_crates',755,642,65,89),box('tool_cabinet',987,645,62,85),
         board('cafe_board',1243,650,81,104),
         pot('cafe_west_pot',(1326,689,32,44),(1325,659,38,32)),
         pot('cafe_east_pot',(1598,692,42,44),(1594,645,54,50)),
         stool('street_step',623,765,101,33),
         box('west_floor_column',0,492,18,239)]
    # The complete steel stair runs share one depth origin, including rail tops.
    stairs=[
        rect(1119,701,16,34),rect(1271,449,8,91),rect(1137,311,10,188),
        [[1119,722],[1252,569],[1288,544],[1302,554],[1170,715],[1154,735],[1120,735]],
        [[1082,369],[1132,369],[1273,491],[1273,514],[1124,395],[1082,395]],
        rect(1265,542,72,29),
        tube((1143,312),(1283,449),9),tube((1144,352),(1283,490),7),
        tube((1130,641),(1273,488),8),rect(1128,640,8,70),
        tube((1145,659),(1295,507),8),rect(1143,659,7,57)]
    for i in range(7):
        x=1152+i*18
        y=329+i*18
        stairs += [rect(x,y,5,36),tube((1147+i*19,635-i*21),(1147+i*19,669-i*21),5)]
    obs.append(object_('outside_stair',736,[(1120,712,59,24),(1264,706,24,24)],stairs))
    return scene('SeoulEuljiro',730,(947,850),obs,{
        'HotelDoor':anchor(1161,784),'ExchangeDoor':anchor(1524,776),
        'TransitDoor':anchor(572,778),'LocalSpot':anchor(864,782),
        'NpcBaek':anchor(267,849),'ExitEast':anchor(1620,857)},[
        sign((174,384,298,83),'을지인쇄','#f0e8d7','#203145',size=36),
        sign((713,383,351,93),'태광공구','#eceddf','#203a53',size=36),
        sign((1355,399,297,67),'카페 · 환전','#30322f',size=31),
        sign((1102,524,93,26),'숙박 ↑','#293e4e',size=14),
        sign((529,533,85,25),'지하철','#254936',size=13),
        sign((1256,663,52,61),'차\n커피','#e8dcc0','#3e372b',13,object='cafe_board')],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'HotelDoor':'E — Upstairs lodging','TransitDoor':'E — Passage to the metro'})


def jongno():
    obs=[pot('hall_planter',(489,721,138,56),(482,659,148,65)),
         pot('game_west_pot',(895,733,36,58),(892,664,49,74)),
         pot('game_east_pot',(1243,740,32,52),(1242,722,41,23)),
         box('stationery_cabinet',1395,728,129,27),
         object_('stationery_poster',766,[(1548,748,63,18)],[
             rect(1552,680,55,67),rect(1548,747,8,19),rect(1603,747,8,19)]),
         object_('watch_poster',762,[(243,739,63,23)],[rect(244,655,61,91),
             rect(243,745,8,17),rect(299,745,7,17)]),
         stool('west_step',360,771,53,34),stool('east_step',1288,788,57,34),
         object_('game_table',794,[(957,773,283,21)],[
             rect(957,730,283,17),rect(963,747,12,46),rect(1225,747,12,46),
             rect(1066,747,9,43),rect(1191,747,9,43),
             rect(974,727,52,5),rect(1071,719,64,13),rect(1168,727,48,5)]),
         box('watch_shop_pier',10,590,29,173),box('hall_pier',449,437,35,327),
         box('game_shop_pier',934,590,18,202),box('east_shop_pier',1630,591,24,174)]
    return scene('SeoulJongno',728,(708,856),obs,{
        'AirportDoor':anchor(783,776),'TransitDoor':anchor(387,780),
        'LocalSpot':anchor(1083,840),'ExitWest':anchor(53,861)},[
        sign((537,305,491,94),'종로상가','#e4d4bd','#172a3d',size=43),
        sign((68,498,252,74),'시계수리','#282a29',size=31),
        sign((991,497,249,74),'보드게임','#204968',size=34),
        sign((1383,498,211,74),'문구','#ece7d9','#1c2c3d',size=34),
        sign((713,532,145,24),'공항철도','#214e5d',size=14),
        sign((351,607,74,26),'지하철','#26433a',size=12),
        sign((257,668,33,63),'시계\n수리','#d8d0b5','#32434b',9,object='watch_poster'),
        sign((1559,688,42,52),'문구','#ecdfc8','#31443c',13,object='stationery_poster'),
        sign((1589,77,68,43),'차','#eee5d3','#275b45',size=21)],
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'AirportDoor':'E — Airport rail connection'})


def mangwon():
    obs=[object_('fruit_stand',694,[(43,666,337,28)],[
             [[43,621],[60,588],[89,558],[116,554],[138,568],[173,554],
              [208,556],[234,560],[253,570],[285,556],[310,563],[337,556],[365,574],
              [380,599],[380,692],[43,692]]]),
         box('juice_crates',383,552,80,71),
         box('blue_crates_west',385,622,70,72),box('blue_crates_east',459,622,71,72),
         object_('aisle_stack',687,[(522,661,44,26),(566,635,55,21),(616,598,24,33)],[
             rect(525,574,41,111),rect(522,526,60,47),
             rect(565,549,35,107),rect(555,474,33,44),rect(536,410,60,59),
             tube((587,487),(610,474),9),tube((610,474),(620,480),7),
             rect(606,521,14,119),rect(614,552,26,79)]),
         object_('banchan_counter',695,[(684,667,294,28)],[
             rect(681,617,298,14),rect(687,631,290,63),
             rect(697,588,272,30),rect(706,568,254,20)]),
         box('counter_case_stack',983,576,98,112),
         object_('counter_microwave',578,[(991,559,82,19)],[
             rect(992,517,79,58),rect(1020,504,27,13)]),
         box('home_goods_display',1106,557,91,134),
         box('detergent_crates',1208,562,144,131),
         object_('umbrella_rack',694,[(1359,674,49,20)],[
             rect(1360,532,47,159),rect(1378,515,9,17)]),
         stool('west_step',339,747,66,32),stool('east_step',995,742,57,35)]
    scooter=[
        oval(1486,654,25,26),oval(1619,655,27,26),
        [[1478,615],[1497,602],[1523,612],[1527,629],[1576,629],[1587,602],
         [1602,592],[1618,620],[1631,620],[1647,635],[1635,641],[1608,638],
         [1582,663],[1524,663],[1514,646],[1470,634]],
        rect(1473,590,80,13),rect(1450,538,68,51),rect(1594,559,17,43),
        tube((1586,543),(1600,563),6),tube((1599,563),(1604,545),6),
        oval(1568,534,6,8),oval(1585,533,5,8)]
    obs.append(object_('delivery_scooter',683,[(1462,662,50,21),(1592,662,55,21),(1512,650,81,17)],scooter))
    return scene('SeoulMangwon',688,(962,844),obs,{
        'TransitDoor':anchor(653,741),'LocalSpot':anchor(831,744),
        'NpcJiwon':anchor(1210,812)},[
        sign((596,145,478,85),'망원시장','#f6e7bf','#163343',size=45),
        sign((107,393,237,59),'청과','#f0ecdd','#28513e',size=31),
        sign((715,395,241,58),'반찬','#f3e7d5','#1e3448',size=33),
        sign((1112,392,235,61),'생활용품','#e9e9db','#204257',size=28),
        sign((619,490,48,75),'지하철\n↓','#1f4840',size=10)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hongdae():
    obs=[object_('instrument_case',754,[(45,734,71,20)],[
             rect(47,590,68,146),rect(46,736,14,17),rect(97,737,16,16)]),
         object_('guitar_case',754,[(118,734,54,20)],[
             [[119,739],[119,661],[125,641],[140,630],[158,641],[166,654],[166,738]],
             oval(125,745,8,8),oval(162,745,8,8),rect(140,622,10,15)]),
         pot('indie_pot',(371,685,47,52),(368,651,52,37)),
         pot('cafe_tree',(687,694,91,63),(642,505,188,176),[
             [[713,697],[717,650],[684,619],[689,610],[724,638],[724,604],[735,604],
              [737,638],[764,610],[771,616],[739,656],[738,697]]]),
         pot('flower_planter',(915,694,194,66),(917,649,187,49)),
         box('cafe_end_bin',1118,727,21,29),
         stool('west_step',358,771,67,32),
         stool('east_step_a',1069,770,51,33),stool('east_step_b',1120,770,49,33),
         object_('posters_stair',747,[(1173,725,82,22)],[
             [[1173,727],[1180,727],[1180,712],[1189,712],[1189,695],[1181,695],
              [1181,680],[1186,680],[1186,663],[1180,663],[1180,646],[1186,646],
              [1186,632],[1180,632],[1180,622],[1234,622],[1234,631],[1230,631],
              [1230,646],[1241,646],[1241,663],[1244,663],[1244,680],[1250,680],
              [1250,695],[1253,695],[1253,713],[1255,713],[1255,747],[1173,747]]])]
    return scene('SeoulHongdae',729,(843,857),obs,{
        'TransitDoor':anchor(232,778),'LocalSpot':anchor(1357,781)},[
        sign((92,399,249,72),'연습실 · 지하철','#254967',size=30),
        sign((428,405,255,69),'indie','#f2e3bb','#302b22',size=32),
        sign((769,416,322,62),'커피','#f2e3bb','#302b22',size=35),
        sign((1298,420,330,77),'라이브','#292c2d',size=42),
        sign((1188,495,41,47),'LIVE','#e5ddc5','#29443b',size=9),
        sign((1188,559,41,28),'오늘','#e5ddc5','#924957',size=11)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Passage to the metro'})


def seongsu():
    obs=[object_('stacked_pallets',724,[(40,704,111,20)],[
             rect(44,635,100,11),rect(45,654,100,10),rect(44,675,102,12),
             rect(42,635,11,88),rect(135,635,12,88),rect(86,635,11,81),
             rect(53,701,82,10)]),
         pot('workshop_tree',(894,639,94,69),(888,210,122,432),
             [rect(938,588,12,53)]),
         object_('shoemaker_table',692,[(1044,670,181,22)],[
             rect(1039,620,187,14),rect(1047,634,11,56),rect(1211,634,11,56),
             rect(1178,634,8,42),rect(1053,680,168,8),
             rect(1052,580,11,40),rect(1066,574,10,46),rect(1117,568,45,52),
             rect(1152,560,44,12),rect(1199,585,10,35)]),
         object_('workshop_drawers',699,[(1254,678,83,21)],[
             rect(1254,523,83,165),rect(1260,688,9,11),rect(1322,688,9,11),
             rect(1284,506,26,17),rect(1289,495,14,11)]),
         box('doorbell_post',1595,535,37,159),
         stool('west_step',345,757,60,32),stool('east_step',1329,757,57,31)]
    return scene('SeoulSeongsu',687,(919,835),obs,{
        'TransitDoor':anchor(605,740),'LocalSpot':anchor(1126,744)},[
        sign((1033,399,318,69),'구두수선','#f0e5c4','#29332d',size=35),
        sign((373,350,493,38),'카페 · 지하철 →','#234159',size=25),
        sign((390,526,137,57),'CAFE','#45605f',size=30),
        sign((39,355,152,83),'공장\n1995','#b76547',size=28)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[object_('reception',578,[(375,559,571,19)],[rect(367,456,585,20),
             rect(375,476,571,101),rect(499,436,52,20),rect(873,436,48,20)]),
         object_('luggage_trolley',580,[(274,561,86,19)],[
             rect(275,450,7,115),rect(351,450,7,115),rect(286,452,62,110),
             tube((278,451),(319,430),5),tube((319,430),(355,449),5),
             oval(282,573,7,7),oval(351,573,7,7)]),
         pot('desk_plant',(976,438,93,141),(974,351,96,89)),
         pot('floor_plant',(1325,709,60,48),(1308,603,93,112)),
         object_('front_bench',726,[(967,706,281,20)],[rect(966,643,283,19),
             rect(973,662,269,49),rect(969,711,16,14),rect(1231,711,16,14)]),
         box('window_cabinet',1411,496,160,93)]
    for i,(x,w) in enumerate([(239,82),(324,50),(377,82)]):
        obs.append(seat('lobby_seat_'+str(i),x,643,w,113))
    return scene('SeoulHotel',574,(750,826),obs,
        {'Point':anchor(669,630),'Exit':anchor(180,616)},[
        sign((578,296,260,46),'서울 호텔','#795236',size=31)],
        clerks={'Point':anchor(668,536)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('exchange_counter',591,[(467,571,510,20)],[rect(461,506,522,19),
             rect(467,525,510,65),rect(503,418,91,70),rect(538,467,19,37),
             rect(525,495,50,9)],glass=[rect(480,342,482,160)]),
         pot('waiting_plant',(1409,520,87,74),(1393,370,116,153),[rect(1447,472,15,52)]),
         box('leaflet_rack',1038,455,125,135),
         box('west_service_column',260,72,137,516),
         box('east_service_column',1513,72,73,516)]
    for i,x in enumerate([335,503,714]):
        obs.append(object_('queue_post_'+str(i),743,[(x-21,723,42,20)],[
            oval(x,632,10,11),rect(x-7,642,14,81),
            [[x-7,719],[x+7,719],[x+21,727],[x+22,740],[x-22,740],[x-22,728]]]))
    obs.append(object_('queue_belt',741,[(346,723,356,18)],[rect(345,639,358,9)]))
    return scene('SeoulExchange',577,(993,817),obs,
        {'Point':anchor(851,646),'Exit':anchor(185,624)},[
        sign((612,190,365,56),'서울 환전','#e7e6dc','#194365',size=34),
        sign((1055,141,309,225),'환전\n\nUSD · JPY\nCNY · EUR\nKRW','#142021','#9bdb9b',size=26),
        sign((303,365,63,89),'안내\n\n신분증\n영수증','#e9e8db','#37546b',size=10),
        sign((1047,464,48,45),'서울','#dde3dc','#365c77',size=13,object='leaflet_rack'),
        sign((1110,465,43,47),'지도','#4c707a',size=12,object='leaflet_rack'),
        sign((1048,539,47,41),'안내','#e1b174','#395561',size=12,object='leaflet_rack')],
        clerks={'Point':anchor(762,586)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[box('west_column',308,0,137,672),box('east_column',1524,0,135,689),
         object_('vending_machine',591,[(59,572,135,19)],[rect(59,372,135,211),
             rect(66,583,16,8),rect(171,583,16,8)])]
    for i,x in enumerate([217,302,385]):
        obs.append(seat('platform_seat_'+str(i),x,695,80,98))
    return scene('SeoulTransit',605,(908,831),obs,{
        'Machine':anchor(552,742),'Platform':anchor(817,649),'Exit':anchor(1440,786)},[
        sign((751,155,220,47),'서울역','#e0e1dc','#162630',size=32),
        sign((751,207,242,29),'Seoul Station','#e0e1dc','#162630',size=20),
        sign((1554,461,73,83),'출구\n→','#1b2431',size=22,object='east_column'),
        sign((352,394,46,53),'노선\n안내','#e8e7d1','#234334',size=10,object='west_column')],
        fittings=[dict(kind='ticket',at=point(552,696))],
        motion_layers=[dict(kind='doors',rect=[479,237,162,162]),
                       dict(kind='doors',rect=[780,237,158,162])],
        # The added ticket unit is small and does not block the platform doors.
        solids=[],interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[object_('baggage_office',677,[(27,654,306,23)],[
             rect(27,400,306,276)],glass=[rect(85,521,150,80)]),
         object_('luggage_belt',723,[(58,698,426,25)],[
             rect(58,675,426,48),rect(133,627,83,48),rect(303,626,80,52),
             rect(397,633,78,52),rect(162,580,10,47),rect(169,580,22,6),
             rect(184,586,7,39),rect(429,601,7,31),rect(434,598,7,7),
             rect(333,616,18,10)]),
         pot('west_back_planter',(314,588,215,83),(326,514,187,78)),
         pot('middle_back_tree',(577,588,478,83),(690,349,215,213),[
             [[790,590],[790,538],[760,512],[767,505],[796,526],[796,496],
              [810,496],[810,526],[838,504],[845,511],[812,541],[812,590]]]),
         pot('back_west_shrub',(577,588,116,72),(599,496,98,93)),
         pot('back_east_shrub',(945,588,110,83),(949,478,112,112)),
         pot('front_planter',(597,639,369,85),(621,575,329,65)),
         object_('check_in',677,[(1117,656,203,21)],[rect(1112,587,210,18),
             rect(1117,605,203,71),rect(1127,519,78,54),rect(1155,556,19,31),
             rect(1232,573,38,14),rect(1264,567,25,20)]),
         stool('terminal_step',1396,752,52,32)]
    for i,x in enumerate([1411,1480,1548,1617]):
        obs.append(object_('ticket_gate_'+str(i),674,[(x,656,25,18)],[
            rect(x,555,25,118)],glass=[rect(x+6,498,12,57)]))
    return scene('SeoulAirport',669,(1093,852),obs,{
        'Point':anchor(1216,729),'Exit':anchor(1449,724)},[
        sign((308,134,228,105),'국내선\nDomestic','#164b91',size=32),
        sign((814,134,280,106),'국제선\nInternational','#164b91',size=32),
        sign((1172,124,409,120),'출발 안내\n\n서울 · 도쿄 · 하노이\n베를린 · 이스탄불','#151f24','#ead46d',size=23),
        sign((49,444,221,45),'수하물','#184975',size=27),
        sign((1497,366,168,78),'철도\nTransit','#1a4c7f',size=28)],
        clerks={'Point':anchor(1235,667)},interaction_sizes=sizes('Point','Exit'),
        prompt_overrides={'Exit':'E — Back to the city train'})


def build():
    rows={'SeoulEuljiro':euljiro(),'SeoulJongno':jongno(),'SeoulMangwon':mangwon(),
          'SeoulHongdae':hongdae(),'SeoulSeongsu':seongsu(),'SeoulHotel':hotel(),
          'SeoulExchange':exchange(),'SeoulTransit':transit(),'SeoulAirport':airport()}
    from .seoul_finish import finish
    return finish(rows)
