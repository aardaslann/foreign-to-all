"""Rome: source-measured complete silhouettes, floor footprints and entrances.

Coordinates are on the 1672x941 art, not copied from the old scene positions.
Every freestanding plant includes its crown; holes under furniture stay open.
"""
from .shapes import anchor, point, object_, rect, tube, sign
from .london import scene


def plant(name, pot, crown, trunk=()):
    x,y,w,h=pot
    return object_(name,y+h,[(x+3,y+h-21,w-6,21)],
        [[[x,y],[x+w,y],[x+w,y+12],[x+w-5,y+h],[x+5,y+h],[x,y+12]],*trunk],
        foliage=[rect(*crown)],wood_branches=True)


def sizes(*names):
    return {name:{'CollisionShape2D':[74,34]} for name in names}


def trastevere():
    obs=[]
    for i,x in enumerate([141,365]):
        obs.append(object_('terrace_'+str(i),698,[(x-29,676,180,22)],[
            [[x+5,609],[x+115,609],[x+128,650],[x+120,664],[x+112,652],
             [x+7,651],[x+2,664],[x-4,651]],
            rect(x+11,650,9,45),rect(x+108,650,9,45),
            rect(x+55,651,9,34),rect(x+44,686,31,8),
            [[x-31,592],[x-15,588],[x-6,647],[x+4,647],[x+8,656],
             [x-7,658],[x-8,698],[x-16,698],[x-17,658],[x-24,658],[x-25,696],
             [x-32,696],[x-29,650]],
            [[x+135,590],[x+148,594],[x+148,646],[x+155,697],[x+145,697],
             [x+140,659],[x+124,659],[x+123,696],[x+114,696],[x+114,649],[x+133,648]],
            rect(x+58,582,10,29),rect(x+83,597,8,13)]))
    obs += [plant('west_tree',(29,620,73,65),(0,462,122,161),[rect(53,574,13,51)]),
        plant('window_pot',(558,625,69,61),(550,565,89,66)),
        plant('fountain_pot',(773,622,60,62),(767,568,71,58)),
        plant('laundry_tree',(1152,615,72,70),(1120,418,131,191),[
            [[1175,619],[1175,579],[1148,553],[1155,545],[1180,566],[1180,526],
             [1194,526],[1194,570],[1215,544],[1222,551],[1195,588],[1195,619]]]),
        plant('east_tree',(1591,615,70,70),(1568,364,104,239),[
            [[1617,619],[1617,574],[1592,542],[1599,534],[1621,555],[1621,506],
             [1635,506],[1635,555],[1661,529],[1668,537],[1637,577],[1637,619]]])]
    obs.append(object_('nasone',726,[(662,702,49,24)],[
        [[662,724],[662,704],[669,698],[669,623],[665,619],[665,611],[671,605],
         [680,602],[680,596],[684,590],[690,590],[695,596],[695,602],[704,606],
         [709,612],[709,621],[703,625],[703,634],[718,634],[725,640],[725,650],
         [718,650],[718,644],[703,644],[703,699],[711,704],[711,724]]],
        water=dict(kind='drinking',at=point(722,715),height=point(0,65)[1])))
    return scene('RomeTrastevere',665,(928,834),obs,
        {'TransitDoor':anchor(978,712),'LocalSpot':anchor(745,753)},[
            sign((146,379,376,43),'TRATTORIA','#513727',size=30),
            sign((1270,354,278,49),'LAVANDERIA','#e3d2ab','#304438',27),
            sign((925,567,86,23),'METRO →','#563123',size=11)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro'},
        animation_patches=[dict(kind='laundry',rect=[*point(1290,213),*point(40,64)]),
                           dict(kind='laundry',rect=[*point(1354,213),*point(39,71)]),
                           dict(kind='washer',rect=[*point(1420,579),*point(49,50)]),
                           dict(kind='washer',rect=[*point(1485,579),*point(45,50)])])


def monti():
    obs=[plant('west_shrub',(19,570,74,68),(0,421,126,151)),
         plant('artisan_shrub',(336,570,93,67),(322,447,116,126)),
         plant('wall_shrub_west',(735,567,82,60),(723,517,100,53)),
         plant('wall_shrub_east',(817,563,80,61),(817,477,88,89)),
         plant('fountain_tree',(1317,590,76,69),(1260,278,156,312),[
             rect(1341,535,17,59),tube((1350,553),(1380,524),9),tube((1351,555),(1321,523),9)])]
    obs.append(object_('east_tree',659,[(1549,627,83,32)],[
        [[1561,645],[1561,470],[1528,444],[1503,399],[1513,393],[1545,428],
         [1571,441],[1571,402],[1587,401],[1587,443],[1621,415],[1645,380],
         [1655,388],[1634,423],[1595,463],[1598,646]]],
        foliage=[rect(1428,207,244,250),rect(1394,524,278,135)],wood_branches=True))
    obs.append(object_('stone_bench',684,[(1392,661,200,23)],[
        [[1376,609],[1597,609],[1597,631],[1570,637],[1570,682],[1534,682],
         [1534,634],[1430,634],[1430,682],[1393,682],[1393,634],[1376,632]]]))
    obs.append(object_('fountain',678,[(970,601,222,57),(953,620,253,39),(973,659,215,20)],[
        [[957,583],[988,575],[1041,574],[1041,466],[1037,466],[1037,445],
         [1070,435],[1070,420],[1076,412],[1086,412],[1094,420],[1094,434],
         [1124,446],[1124,466],[1117,466],[1117,574],[1180,575],[1202,583],
         [1202,604],[1193,611],[1193,649],[1208,655],[1208,672],[1185,678],
         [974,678],[951,672],[951,654],[966,648],[966,608],[957,604]]],
        water=dict(kind='spouts',streams=[
            [point(1079,526),point(1079,546),point(1079,566),point(1079,590)],
            [point(1040,541),point(1034,546),point(1033,568),point(1033,589)],
            [point(1123,541),point(1130,546),point(1131,568),point(1131,589)]],
            pool=[*point(992,582),*point(170,9)])))
    return scene('RomeMonti',620,(770,820),obs,
        {'TransitDoor':anchor(225,674),'LocalSpot':anchor(1037,750)},[
            sign((463,316,227,47),'BOTTEGA','#164b3d',size=30),
            sign((181,512,91,26),'METRO →','#24523c',size=12)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro'})


def esquilino():
    obs=[]
    for i,(x,w) in enumerate([(0,40),(289,73),(607,74),(933,80),(1286,79),(1630,42)]):
        obs.append(object_('arcade_pier_'+str(i),695,[(x,659,w,36)],[
            rect(x,397,w,247),rect(max(0,x-7),373,min(w+15,1672-max(0,x-7)),23),
            rect(x,644,w,49)]))
    obs += [object_('market_front',679,[(133,652,142,27)],[
        [[129,621],[139,581],[268,581],[275,588],[270,639],[270,676],[137,676],[137,637]]]),
        object_('market_crate',693,[(44,670,69,23)],[
        [[43,635],[69,618],[78,593],[104,579],[112,581],[125,591],[111,629],
         [112,641],[105,646],[105,692],[44,692]]]),
        plant('arcade_plant',(367,649,23,31),(366,603,29,57)),
        object_('terminal_bin',685,[(1567,660,44,25)],[
            [[1566,587],[1606,587],[1611,594],[1611,682],[1567,682]]])]
    return scene('RomeEsquilino',655,(1190,831),obs,
        {'AirportDoor':anchor(1477,718),'TransitDoor':anchor(787,718),
         'LocalSpot':anchor(177,734),'NpcLucia':anchor(949,829),'ExitWest':anchor(47,835)},[
            sign((73,442,193,30),'ALIMENTARI','#175236',size=19),
            sign((392,442,197,29),'EMPORIO','#782920',size=23),
            sign((721,425,139,22),'METRO','#22473e',size=19),
            sign((1062,433,199,33),'TABACCHI','#22466b',size=23),
            sign((1392,431,152,28),'TERMINAL','#263c49',size=18)],
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'AirportDoor':'E — Take the airport train','TransitDoor':'E — Walk to the metro'})


def testaccio():
    obs=[object_('hotel_crates_west',680,[(351,656,65,24)],[
        [[350,677],[350,613],[355,577],[375,578],[375,526],[410,526],
         [410,576],[417,583],[410,620],[410,677]]]),
        object_('hotel_crates_east',685,[(484,657,98,28)],[
        [[484,676],[484,600],[489,594],[489,528],[529,528],[529,591],
         [536,601],[536,619],[573,623],[581,633],[581,682],[532,682],[532,676]]])]
    for i,(x,w) in enumerate([(615,128),(760,114),(953,118),(1080,129)]):
        obs.append(object_('produce_'+str(i),678,[(x+3,650,w-6,28)],[
            [[x,615],[x+7,584],[x+11,571],[x+w-8,571],[x+w,582],[x+w,621],
             [x+w-4,621],[x+w-4,676],[x+2,676],[x+2,623]]]))
    obs.append(object_('east_tree',691,[(1548,666,77,25)],[
        [[1546,685],[1558,661],[1558,508],[1533,483],[1497,469],[1454,442],
         [1437,417],[1450,412],[1472,438],[1510,454],[1546,467],[1561,481],
         [1561,444],[1574,422],[1585,431],[1576,451],[1576,476],[1600,452],
         [1614,421],[1625,426],[1614,460],[1595,484],[1587,505],[1595,656],[1624,686]]],
        foliage=[rect(1270,156,402,299),rect(1546,578,75,38)],wood_branches=True))
    obs.append(object_('east_bench',700,[(1505,678,155,22)],[
        rect(1508,614,147,15),rect(1511,635,139,13),rect(1503,655,158,13),
        rect(1514,648,8,8),rect(1642,648,8,8),
        rect(1508,668,10,24),rect(1521,668,8,24),rect(1640,667,10,26),
        rect(1502,692,27,7),rect(1635,692,24,7)]))
    # The stairwell is a hole reached through its travel interaction. Its
    # complete mouth is solid, not just two narrow rail-post collisions.
    obs.append(object_('metro_stairwell',679,[(1281,655,210,24)],[
        tube((1309,609),(1318,609),6),tube((1318,609),(1338,665),6),rect(1306,610,7,62),
        tube((1452,609),(1443,609),6),tube((1443,609),(1423,665),6),rect(1451,610,7,62)]))
    obs.append(plant('west_edge_pot',(0,623,24,62),(0,487,44,137)))
    return scene('RomeTestaccio',665,(711,833),obs,
        {'HotelDoor':anchor(449,721),'ExchangeDoor':anchor(258,721),
         'TransitDoor':anchor(1382,718),'LocalSpot':anchor(753,728),
         'NpcNando':anchor(932,830),'ExitEast':anchor(1619,836)},[
            sign((54,431,249,29),'CAMBIO','#1f4a48',size=26),
            sign((361,473,186,26),'PENSIONE','#164b39',size=20),
            sign((632,478,225,24),'MERCATO','#194d38',size=23),
            sign((1302,474,166,23),'METRO','#275952',size=23)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def garbatella():
    obs=[]
    for i,(x,w,y) in enumerate([(0,190,625),(532,185,555),(918,454,555),(1452,220,625)]):
        obs.append(object_('garden_wall_'+str(i),676,[(x,660,w,16)],[rect(x,y,w,676-y)]))
    for name,left,right,top,bottom in [('west',0,178,549,625),('east',1476,1672,549,625),
                                     ('middle',557,712,505,556),('middle_east',922,990,505,556)]:
        polys=[rect(left,top+7,right-left,6)]
        for x in range(left+5,right,23):
            polys += [rect(x,top+13,5,bottom-top-13),
                      [[x-2,top+4],[x-2,top],[x+2,top-5],[x+6,top],[x+6,top+4]]]
        obs.append(object_('rail_'+name,bottom,[(left,bottom-8,right-left,8)],polys))
    gate=[rect(711,510,13,153),rect(906,510,14,154),rect(726,558,178,6),rect(726,644,178,7)]
    for x,top in [(745,522),(770,510),(796,500),(820,496),(843,501),(868,510),(891,523)]:
        gate.append(rect(x,top,6,658-top))
    curve=[(726,549),(742,533),(769,517),(795,507),(818,504),(842,508),(867,518),(890,534),(906,548)]
    gate += [tube(a,b,6) for a,b in zip(curve,curve[1:])]
    obs.append(object_('closed_garden_gate',668,[(711,653,211,15)],gate))
    for name,pot,crown in [('west_planter',(190,606,86,69),(170,452,144,157)),
                            ('stairs_planter',(461,606,73,69),(453,496,94,113)),
                            ('east_planter',(1370,606,82,69),(1348,451,121,161))]:
        obs.append(plant(name,pot,crown))
    obs.append(object_('street_bench',691,[(1045,671,255,20)],[
        rect(1042,585,256,20),rect(1045,608,250,19),rect(1039,635,262,15),
        rect(1048,625,8,10),rect(1285,625,8,10),
        rect(1049,650,10,34),rect(1283,650,10,34),rect(1043,681,29,9),rect(1274,681,25,9)]))
    return scene('RomeGarbatella',659,(808,828),obs,
        {'TransitDoor':anchor(379,714),'LocalSpot':anchor(822,721)},[
            sign((333,291,95,28),'METRO →','#d8c098','#45392d',12),
            sign((556,584,43,35),'24','#56606a','#e5dec9',17,object='garden_wall_1')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro','LocalSpot':'E — The courtyards'},
        animation_patches=[dict(kind='laundry',rect=[*point(1500,241),*point(55,59)]),
                           dict(kind='laundry',rect=[*point(1584,241),*point(34,53)])])


def hotel():
    obs=[object_('reception_desk',650,[(568,610,530,40)],[
        rect(563,405,538,31),rect(575,434,517,176),rect(569,610,529,38),
        [[624,354],[706,354],[716,404],[634,404]],
        rect(921,391,46,13),rect(928,384,32,9),rect(940,371,7,15),
        [[1013,320],[1043,320],[1068,368],[1033,368],[1033,398],[1045,398],
         [1045,405],[1011,405],[1011,398],[1023,398],[1023,368],[990,368]]]),
        object_('luggage_trolley',633,[(356,609,190,24)],[
            rect(358,599,188,15),rect(362,455,8,145),rect(529,455,9,145),
            tube((365,455),(386,440),8),rect(383,437,134,10),tube((517,440),(533,454),8),
            rect(377,500,73,100),rect(394,482,32,7),rect(394,488,7,12),rect(419,488,7,12),
            rect(454,498,74,102),rect(477,483,33,7),rect(478,489,6,9),rect(504,489,7,9),
            [[358,617],[365,611],[375,615],[379,623],[374,632],[363,632],[356,625]],
            [[519,615],[529,612],[538,619],[538,628],[529,632],[520,628]]]),
        plant('entrance_plant',(9,559,76,70),(0,437,111,125)),
        plant('luggage_plant',(381,491,70,103),(340,348,157,142)),
        object_('bin',613,[(1117,590,68,23)],[
            [[1117,460],[1184,460],[1186,469],[1184,611],[1118,611]]]),
        object_('reading_table',702,[(1352,658,294,44)],[
            rect(1348,503,298,36),rect(1354,539,289,38),rect(1416,572,227,26),
            rect(1357,578,20,100),rect(1416,598,25,99),rect(1620,573,24,126),
            rect(1502,599,108,62),rect(1519,660,15,18),rect(1582,660,14,18),
            rect(1409,511,109,19),rect(1419,503,105,14),rect(1424,494,77,10),
            [[1535,411],[1589,411],[1615,468],[1575,468],[1575,517],[1585,517],
             [1585,528],[1550,528],[1550,517],[1558,517],[1558,468],[1518,468]]])]
    return scene('RomeHotel',598,(839,823),obs,
        {'Point':anchor(835,705),'Exit':anchor(225,657)},[],
        clerks={'Point':anchor(830,490)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('exchange_counter',647,[(474,622,582,25)],[
        rect(468,470,592,22),rect(479,492,572,154),
        rect(917,423,73,49),rect(536,425,73,47),rect(664,435,55,37),rect(827,437,71,35)],
        glass=[rect(490,232,290,237),rect(788,232,261,237)]),
        plant('door_plant',(272,582,80,78),(241,394,142,192),[rect(303,542,13,44)]),
        object_('archive_cabinet',670,[(1369,646,262,24)],[rect(1368,548,262,121),
            rect(1384,523,112,29),rect(1390,501,103,24),rect(1385,473,97,28),
            rect(1530,468,88,87),rect(1508,522,16,33)])]
    # Each post has its actual broad circular foot. The straps connect only
    # the queue span and leave both side approaches to the counter open.
    polys=[]
    for x in [539,775,999]:
        polys += [rect(x-11,542,22,32),rect(x-9,574,18,127),
                  [[x-32,705],[x-23,700],[x+23,700],[x+32,706],[x+32,715],
                   [x+22,720],[x-24,720],[x-32,715]]]
    polys += [rect(550,550,214,16),rect(786,550,202,16)]
    obs.append(object_('queue',720,[(507,698,524,22)],polys))
    return scene('RomeExchange',631,(1160,812),obs,
        {'Point':anchor(1123,692),'Exit':anchor(162,692)},[
            sign((483,124,700,77),'CAMBIO VALUTA','#183e39',size=40),
            sign((1088,265,209,194),'CAMBIO\n\nEUR · GBP\nUSD · CHF\n\nALLO SPORTELLO','#153c39',size=16),
            sign((372,295,60,100),'DOCUMENTO\n\nPASSAPORTO','#dacaaa','#374536',7)],
        clerks={'Point':anchor(892,546)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[]
    for i,x in enumerate([30,185]):
        obs.append(object_('ticket_machine_'+str(i),641,[(x,615,153,26)],[
            [[x+6,333],[x+141,333],[x+152,341],[x+152,636],[x,636],[x,344]]]))
    obs += [object_('bench',652,[(392,629,338,23)],[rect(395,531,330,23),
        rect(396,558,328,23),rect(386,591,343,18),rect(403,581,8,10),rect(710,581,8,10),
        rect(395,609,14,42),rect(555,609,13,40),rect(707,609,14,42)]),
        object_('bin',640,[(795,614,75,26)],[rect(795,499,75,137)]),
        object_('stairwell',650,[(909,626,676,24)],[
            rect(949,531,9,96),rect(1535,531,9,96),
            tube((953,531),(961,519),9),tube((961,519),(976,518),9),
            tube((976,518),(1037,625),9),tube((1539,531),(1531,519),9),
            tube((1531,519),(1517,518),9),tube((1517,518),(1456,625),9)])]
    return scene('RomeTransit',631,(821,824),obs,
        {'Machine':anchor(181,693),'Platform':anchor(1244,703),'Exit':anchor(1588,754)},[
            sign((784,111,686,53),'METROPOLITANA','#aa2425',size=36),
            sign((1080,245,384,55),'BINARI ↓','#163735',size=31),
            sign((50,341,111,23),'BIGLIETTI','#aa2724',size=14,object='ticket_machine_0'),
            sign((208,341,111,23),'BIGLIETTI','#aa2724',size=14,object='ticket_machine_1'),
            sign((1450,412,111,25),'USCITA →','#184841',size=12)],
        prompt_overrides={'Exit':'E — Exit to the street'},
        interaction_sizes=sizes('Machine','Platform','Exit'))


def airport():
    obs=[object_('cafe_counter',683,[(0,651,445,32)],[
        rect(0,552,315,129),rect(315,617,129,64),rect(314,549,130,68),
        rect(188,491,111,62),rect(206,482,77,9),rect(31,466,71,85),rect(122,524,52,28)]),
        plant('check_in_plant',(458,609,61,87),(438,452,92,160)),
        object_('check_in',718,[(526,690,296,28)],[
            rect(525,581,298,45),rect(529,626,290,90),
            [[742,536],[794,536],[797,572],[778,572],[778,581],[754,581],[754,574],[738,574]]]),
        object_('window_bin',671,[(925,647,55,24)],[rect(925,558,54,109)]),
        object_('baggage_carousel',678,[(1027,648,414,30)],[
            [[1026,607],[1037,596],[1431,596],[1442,607],[1442,645],[1436,677],
             [1030,677],[1030,645],[1026,645]],
            rect(1060,576,58,31),rect(1089,551,109,56),rect(1124,539,28,7),
            rect(1124,545,7,6),rect(1146,545,7,6),
            rect(1234,558,80,49),rect(1262,548,24,6),rect(1262,554,7,5),rect(1280,554,6,5),
            rect(1341,551,80,56),rect(1367,540,27,7),rect(1367,546,7,6),rect(1388,546,6,6)])]
    for i,x in enumerate([26,141,255]):
        obs.append(object_('terminal_seat_'+str(i),783,[(x,758,114,25)],[
            [[x+21,637],[x+108,637],[x+111,645],[x+106,716],[x+108,722],
             [x+114,726],[x+110,744],[x-4,744],[x-4,730],[x+15,724],[x+17,716]],
            rect(x,744,10,30),rect(x+14,744,9,30),rect(x+99,744,11,30),
            rect(x-3,774,16,8),rect(x+96,774,19,8)]))
    return scene('RomeAirport',669,(1009,837),obs,
        {'Point':anchor(675,767),'Exit':anchor(1553,717)},[
            sign((526,135,223,57),'PARTENZE','#263343',size=31),
            sign((1247,140,185,47),'BAGAGLI','#253544',size=27),
            sign((20,318,403,57),'BAR','#593a24',size=39),
            sign((332,424,80,112),'CAFFÈ\nACQUA\nCORNETTO','#202c30',size=10),
            sign((1231,321,184,135),'ROMA\nPARTENZE\n\nBERLINO\nISTANBUL\nPARIGI','#22303a',size=13),
            sign((1480,351,148,22),'USCITA · TRENI','#1b474d',size=11)],
        clerks={'Point':anchor(675,658)},interaction_sizes=sizes('Point','Exit'),
        motion=[dict(kind='steam',rect=[*point(247,460),*point(30,33)])],
        motion_layers=[dict(kind='doors',rect=[*point(1476,392),*point(169,270)])])


def build():
    return {'RomeTrastevere':trastevere(),'RomeMonti':monti(),'RomeEsquilino':esquilino(),
            'RomeTestaccio':testaccio(),'RomeGarbatella':garbatella(),
            'RomeHotel':hotel(),'RomeExchange':exchange(),'RomeTransit':transit(),
            'RomeAirport':airport()}
