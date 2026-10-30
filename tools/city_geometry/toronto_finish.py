"""Final Toronto world-art measurements on the 1672 x 941 reference canvas."""
from math import sin, cos, pi
from .shapes import point, rect, tube, object_, sign
from .moscow import pot, oval
from .newyork_finish import replace


def ring(cx,cy,rx,ry,width=5):
    # Metal bicycle parking loops: holes stay open, no sampled pavement box.
    pts=[(cx+rx*cos(i*pi/12),cy+ry*sin(i*pi/12)) for i in range(25)]
    return [tube(pts[i],pts[i+1],width) for i in range(24)]


def lantern(name,x,top,base):
    return object_(name,base,[(x-16,base-15,32,15)],[
        rect(x-7,top+66,14,base-top-66),rect(x-16,base-15,32,15),
        rect(x-21,top+11,42,54),rect(x-8,top,16,12)])


def display(name,x,y,w,h,crown):
    return object_(name,y+h,[(x,y+h-16,w,16)],[
        rect(x,y,w,13),rect(x+5,y+13,8,h-13),rect(x+w-13,y+13,8,h-13),
        rect(x+13,y+19,w-26,32),rect(x+5,y+h-16,w-10,8)],foliage=[rect(*crown)])


def apply(rows):
    r=rows['TorontoDowntown'];r['floor']=point(0,636)[1]
    replace(r,object_('ttc_shelter_frame',694,[(815,674,438,20)],[
        rect(811,480,447,32),rect(816,512,18,181),rect(952,508,18,185),
        rect(1091,511,18,182),rect(1238,509,17,184),rect(1210,516,13,177)],
        glass=[rect(834,519,118,155),rect(970,519,121,155),rect(1109,519,101,155),rect(1223,519,15,155)]),
        object_('ttc_shelter_bench',693,[(848,676,229,17)],[
            rect(840,635,108,11),rect(980,635,105,11),rect(852,646,16,47),
            rect(918,646,13,47),rect(997,646,13,47),rect(1057,646,13,47)]),
        pot('hotel_pot',(143,607,84,50),(137,553,102,57)),
        pot('hotel_tree',(360,616,204,41),(353,558,218,61),[
            rect(464,477,20,106),tube((475,524),(448,480),9),tube((475,518),(506,470),10)]),
        object_('hotel_tree_crown',657,[(362,640,201,17)],[],foliage=[rect(405,280,183,251)],wood_branches=True),
        pot('exchange_pot',(618,600,64,50),(608,552,84,50)),
        object_('west_bin',699,[(731,681,55,18)],[rect(731,625,55,74),*ring(758,626,22,16,6)]),
        object_('east_bin',694,[(1374,675,71,19)],[rect(1374,596,71,98),rect(1399,576,24,21)]),
        lantern('lamp',1307,329,694),lantern('west_lamp',587,461,694),
        pot('east_tree_planter',(1254,591,122,51),(1250,550,132,44),[
            rect(1334,467,21,124),tube((1341,534),(1314,499),12),tube((1346,521),(1363,485),10)]),
        object_('east_tree_crown',642,[(1255,624,120,18)],[],foliage=[rect(1202,271,174,268)],wood_branches=True))
    replace(r,object_('cycle_parking',701,[(393,686,169,15)],[rect(398,624,155,9),rect(397,624,12,72),rect(544,624,12,72),
        rect(391,695,24,6),rect(538,695,23,6),*ring(439,669,16,28),*ring(478,669,16,28),*ring(516,669,16,28)]))
    r['anchors'].update(HotelDoor=point(287,675),ExchangeDoor=point(690,675))
    r['lettering']=[sign((188,364,210,50),'HOTEL','#00000000','#e9c76a',size=34),
        sign((632,374,215,43),'EXCHANGE','#00000000',size=28),
        sign((1402,375,257,52),'CONVENIENCE','#00000000',size=23)]

    r=rows['TorontoKensington'];r['floor']=point(0,644)[1]
    for i,(p,c) in enumerate([((65,611,200,56),(0,498,279,114)),((384,610,164,48),(375,490,178,122)),
        ((776,610,63,47),(774,571,66, 40)),((1326,611,82,47),(1319,554,98,58))]):
        replace(r,pot('planter'+str(i),p,c))
    replace(r,display('produce_table0',557,580,141,77,(557,522,141,59)),
        display('produce_table1',909,580,147,76,(909,527,147,55)),
        display('produce_table2',1210,580,106,76,(1210,509,106,73)),
        display('small_produce_table',706,580,59,77,(706,528,59,53)),
        object_('west_utility_pole',696,[(143,680,40,16)],[rect(153,27,24,654),rect(143,680,40,16),
            rect(111,63,97,18),rect(110,102,98,18),rect(162,141,13,179)]),
        object_('east_utility_pole',670,[(1611,651,41,19)],[rect(1622,31,24,622),rect(1611,651,41,19),
            rect(1592,84,80,20),rect(1592,123,80,20)]),
        object_('litter_bin',693,[(1449,675,75,18)],[rect(1452,607,70,73),rect(1449,680,76,13),
            rect(1459,589,54,10),rect(1459,599,7,9),rect(1506,599,7,9)]),
        pot('bin_side_plant',(1517,610,34,58),(1512,578,42,33)),
        object_('clothes_rail',657,[(1063,640,14,17),(1135,640,14,17)],[rect(1064,515,94,10),
            rect(1066,525,8,115),rect(1142,525,8,115),rect(1063,640,14,17),rect(1135,640,14,17),
            rect(1076,541,24,63),rect(1100,544,14,65),rect(1115,542,14,70),rect(1130,540,25,66),
            *[rect(x,527,3,16) for x in [1087,1105,1120,1141]]]))
    r['lettering']=[sign((336,397,165,34),'BOOKS','#00000000','#303b42',size=29),
        sign((853,404,170,36),'RECORDS','#00000000','#edda9b',size=26)]

    r=rows['TorontoGerrard'];r['floor']=point(0,639)[1]
    replace(r,object_('ttc_shelter_frame',694,[(1098,676,432,18)],[
        rect(1100,471,458,34),rect(1099,505,15,178),rect(1174,506,16,186),
        rect(1314,507,17,185),rect(1437,507,16,185),rect(1510,504,19,178),
        rect(1090,681,34,14),rect(1499,682,35,13),rect(1327,642,114,8),rect(1108,639,66,8)],
        glass=[rect(1115,513,59,127),rect(1190,514,124,130),rect(1331,514,106,127),rect(1453,514,56,161)]),
        object_('ttc_shelter_bench',693,[(1209,676,90,17)],[rect(1198,634,106,13),rect(1210,647,14,46),rect(1282,647,14,46)]),
        pot('west_planter',(0,607,77,54),(0,553,85,55)),
        pot('east_planter',(1558,609,114,53),(1547,555,125,55)),
        object_('bin',699,[(134,682, 60,17)],[rect(134,619,60,80),rect(142,607,42,11),rect(143,601,41,7)]),
        lantern('street_lamp',1515,324,697),
        display('grocer_display0',754,603,100,50,(747,539,107,65)),
        object_('grocer_display1',653,[(864,638,67,15)],[rect(864,611,67,31),rect(866,642,9,11),rect(920,642,9,11)],foliage=[rect(866,582,64,30)]),
        object_('grocer_display2',640,[(864,624,111,16)],[rect(864,575,111,11),rect(864,525,111,10),
            rect(862,485,9,156),rect(970,482,10,160)],foliage=[rect(867,479,105,45),rect(867,536,105,39)]),
        object_('cycle_parking',701,[(279,686,63,15)],[*ring(292,669,15,29),*ring(332,668,15,29),
            rect(287,623,8,16),rect(327,622,8,17)]),
        object_('fabric_box',641,[(77,625,51,16)],[rect(75,558,55,83)]))
    r['lettering']=[sign((20,336,350,62),'FABRICS','#00000000',size=36),
        sign((435,340,339,58),'JEWELLERS','#00000000','#edcf86',size=31),
        sign((838,338,434,60),'GROCERY','#00000000',size=36)]

    r=rows['TorontoDistillery'];r['floor']=point(0,614)[1]
    replace(r,object_('menu',664,[(73,646,17,18),(161,646,17,18)],[rect(73,500,17,164),rect(161,500,17,164),rect(90,506,71,124)]),
        object_('west_bin',706,[(206,686,49,20)],[rect(206,578,49,128),oval(231,577,24,12)]),
        pot('west_planter',(272,569,94,83),(265,500,103,70)),
        pot('middle_planter',(654,592,73,57),(648,536,85,57)),
        pot('barrel_planter',(1000,592,73,57),(993,525,88,69)),
        pot('courtyard_tree',(1021,521,96,70),(1012,433,143,92)),
        pot('east_planter',(1355,576,76,64),(1346,524,92,54)),
        pot('east_box',(1448,554,79,88),(1442,491,89,65)),
        pot('far_east',(1588,591,73,58),(1577,489,92,104)),
        object_('center_lamp',599,[(1171,583,39,16)],[rect(1179,251,26,333),rect(1171,583,39,16)]),
        object_('bollard',706,[(1325,690,29,16)],[rect(1329,647,21,43),oval(1339,646,11,7),rect(1325,690,29,16)]),
        object_('east_bollard',706,[(1553,690,29,16)],[rect(1557,647,21,43),oval(1567,646,11,7),rect(1553,690,29,16)]),
        object_('barrel_cart',647,[(769,629,199,18)],[rect(764,592,210,22),rect(773,614,17,31),rect(949,614,16,31),
            oval(824,621,23,15),oval(875,628,19,18),oval(925,621,19,15),
            oval(805,511,30,31),oval(893,511, 40,33),oval(862,566,35,31),oval(929,565,31,31),rect(775,539,53,54)]))
    r['lettering']=[sign((733,314,232,111),'DISTILLERY\nDISTRICT','#00000000','#f0d7a5',size=31),
        sign((93,527,63,70),'CAFÉ\nCIDER','#00000000',size=13,object='menu')]

    r=rows['TorontoScarborough'];r['floor']=point(0,582)[1]
    replace(r,object_('bus_shelter_frame',652,[(1015,634,413,18)],[rect(1014,406,419,39),rect(1018,444,14,204),
        rect(1040,445,8,178),rect(1105,445,10,135),rect(1283,445,15,203),rect(1410,444,17,206),
        rect(1036,618,383,11),rect(1310,457,87,135)],glass=[rect(1048,447,57,171),rect(1115,447,168,171),
        rect(1298,447,111,10),rect(1298,592,111,26),rect(1298,457,12,135),rect(1397,457,12,135)]),
        object_('bus_shelter_bench',651,[(1085,635,165,16)],[rect(1079,580,176,12),rect(1079,593,176,13),
            rect(1073,611,189,14),rect(1086,625,11,26),rect(1160,625,12,26),rect(1237,625,12,26)]),
        pot('planter0',(0,612,280,57),(0,474,281,140)),
        pot('planter1',(345,612,149,57),(352,532,117,81)),
        pot('planter2',(543,612,302,57),(552,541,292,72)),
        object_('bin',680,[(910,662,55,18)],[rect(911,604,53,76),rect(909,579,57,13),rect(918,592,8,12),rect(954,592,8,12)]))
    # These are four parking rings, not unfinished bicycles.
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('cycle')]
    for i,x in enumerate([1483,1520,1570,1614]):
        replace(r,object_('cycle_ring'+str(i),659,[(x-16,645,32,14)],[*ring(x,622,17,35,5),rect(x-4,579,8,16),rect(x-9,570,18,7)]))
    r['lettering']=[sign((72,343,399,39),'BAKERY','#00000000',size=34),
        sign((541,343,433,39),'FAMILY FOODS','#00000000',size=32),
        sign((1170,343,480,39),'PHARMACY','#00000000',size=34)]

    r=rows['TorontoHotel'];r['floor']=point(0,569)[1]
    replace(r,object_('reception',579,[(451,553,568,26)],[rect(437,419,592,21),rect(451,440,568,139),
        rect(559,366,67,53),rect(851,365,77,55),rect(774,390,37,28),
        rect(492,363,42,55),rect(954,364,38,54),[[481,364],[489,309],[541,309],[546,364]],
        [[941,364],[949,309],[999,309],[1009,364]]]),
        object_('luggage_trolley',592,[(12,572,121,20)],[rect(12,542,120,17),rect(23,389,10,153),rect(109,389,10,153),
            tube((29,389),(41,371),9),rect(41,366,61,10),tube((102,371),(114,389),9),
            rect(54,375,8,164),oval(71,354,10,10),oval(29,575,17,15),oval(107,575,17,15)]),
        object_('umbrella_stand',581,[(301,565,103,16)],[rect(302,483,103,98),
            *[rect(x,449,10,114) for x in [309,332,357,383]],
            *[tube((x,449),(x+4,437),6) for x in [309,332,357,383]],
            *[tube((x+4,437),(x+13,439),6) for x in [309,332,357,383]],
            *[rect(x+10,439,6,12) for x in [309,332,357,383]]]),
        object_('armchair',615,[(1058,595,184,20)],[rect(1064,468,140,93),rect(1058,482,25,103),rect(1200,514,45,71),
            rect(1083,530,117,56),rect(1060,582,181,10),rect(1058,588,15,25),rect(1120,591,17,24),rect(1230,585,12,19)]),
        object_('sofa',631,[(1341,610,272,21)],[
            [[1375,438],[1391,432],[1606,451],[1615,464],[1615,594],[1340,579],[1338,490],[1373,488]],
            rect(1351,585,242,15),rect(1526,596,17,35),rect(1596,592,17,28)]),
        pot('sofa_plant',(1280,468,76,89),(1273,341,98,130),[rect(1317,418,13,51)]),
        pot('rear_planter',(1089,456,192,87),(1082,373,211,84)),
        object_('coffee_table',639,[(1230,620,185,19)],[oval(1323,563,93,17),rect(1232,568,18,62),
            rect(1317,574,19,65),rect(1395,568,18,63),rect(1247,611,148,11)]))
    r['anchors'].update(Exit=point(205,616),Point=point(738,623));r['clerks']['Point']=point(738,455)
    r['lettering']=[sign((485,209,483,57),'TORONTO HOTEL','#00000000','#2c3435',size=37),
        sign((614,459,278,30),'RECEPTION','#00000000','#e3d5b8',size=22,object='reception')]

    r=rows['TorontoExchange'];r['floor']=point(0,641)[1]
    replace(r,object_('exchange_counter',678,[(289,621,427,20),(716,652,603,26)],[rect(284,516,434,21),rect(291,537,426,104),
        rect(714,517,610,22),rect(718,539,602,139),rect(721,358,8,159),rect(1306,358,13,159),rect(729,358,577,7),
        rect(929,445,78,68),rect(1041,480,24,33),rect(1103,401,80,78),rect(1126,452,20,41),rect(1080,411,23,69),
        rect(791,475,49,37),rect(321,349,12,151),rect(544,349,14,155),rect(333,349,212,7),
        rect(349,374,50,40),rect(354,407,18,15),rect(341,422,62,76),rect(410,397,83,99),rect(449,368,19,29),
        rect(588,451,86,40),rect(603,426,58,26)],glass=[rect(729,365,577,149),rect(333,356,211,137)]),
        pot('counter_plant',(1233,462,44, 50),(1222,373,79,90)))
    r['anchors'].update(Exit=point(169,695),Point=point(1040,714));r['clerks']['Point']=point(1040,531)
    r['lettering']=[sign((309,166,216,111),'CURRENCY\nEXCHANGE','#00000000',size=26),
        sign((971,160,256,155),'CAD · USD\nEUR · GBP\nEXCHANGE','#00000000',size=27)]

    r=rows['TorontoTransit'];r['floor']=point(0,577)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('platform_seat')]
    polys=[rect(882,677,17,73),rect(1282,677,17,73),rect(897,741,386,10),
        *[rect(x,750,19,29) for x in [928,1083,1234]]]
    for x in [899,995,1092,1188]:polys += [rect(x,645,95,69),rect(x,715,95,27)]
    replace(r,object_('platform_seat',779,[(883,761,416,18)],polys),
        object_('platform_bin',774,[(1323,754,112,20)],[rect(1323,625,112,149),rect(1321,609,114,19),
            [[1321,609],[1340,597],[1419,597],[1435,609]]]),
        object_('right_pier',631,[(1559,612,88,19)],[rect(1561,0,85,596),rect(1559,595,88,36)]),
        object_('left_pier',505,[(277,486,91,19)],[rect(277,0,91,505)]),
        object_('ticket_machine',652,[(451,635,129,17)],[rect(451,489,129,163),rect(451,469,80,20),rect(540,467, 30,23)]),
        object_('fare_gate_rails',652,[(40,634,411,18)],[rect(40,505,411,10),rect(40,570,411,11)]))
    for i,x in enumerate([85,224,348]):replace(r,object_('fare_gate'+str(i),652,[(x,634,64,18)],[rect(x,487,64,165),
        [[x,487],[x+10,470],[x+55,470],[x+64,482],[x+64,487]]]))
    r['anchors'].update(Exit=point(422,704),Machine=point(516,696),Platform=point(709,648))
    r['lettering']=[sign((1050,82,279,30),'LINE 1 →','#00000000',size=24),
        sign((530,98,258,142),'SUBWAY\nYONGE\nUNIVERSITY','#1d2634',size=25),
        sign((828,107,182,132),'PLATFORM\nEXIT ←\nTICKETS','#1d2634',size=21)]
    r['motion_layers']=[dict(kind='doors',rect=[*point(940,350),*point(109,165)])]

    r=rows['TorontoAirport'];r['floor']=point(0,611)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('terminal_seat')]
    for i,x in enumerate([129,210,293,377]):
        replace(r,object_('terminal_seat'+str(i),633,[(x-10,618,89,15)],[rect(x,512,76,71),rect(x-7,583,87,18),
            rect(x-9,554,6,28),rect(x+72,554,7,28),rect(x+2,601,11,32)]))
    # Nested airport carts: complete handles, basket faces, rails and wheels.
    polys=[rect(480,513,229,9),rect(699,513,9,34),rect(480,519,9,17)]
    for x in [480,514,547,581,614,647,680]:
        polys += [rect(x,548,23,7),tube((x+23,551),(x+31,561),6),rect(x+28,560,6, 80),
            rect(x+10,562,17,73),rect(x+8,638,26,6),oval(x+10,653,12,12),oval(x+30,651,10,11)]
    replace(r,object_('trolleys',666,[(480,647,243,19)],polys),
        object_('information_counter',619,[(974,600,364,19)],[rect(970,500,372,22),rect(974,522,364,97),
            rect(1031,414,74,64),rect(1052,478,20,21),rect(1154,414,90,63),rect(1190,477,14,22),rect(985,475,33,24)]),
        pot('west_plant',(4,554,62,69),(0,377,82,136),[rect(28,500,16,54)]),
        object_('carousel',768,[(1192,742,480,26)],[
            [[1189,665],[1211,648],[1279,624],[1672,624],[1672,768],[1250,763],[1204,748],[1189,736]]]),
        object_('west_suitcase',627,[(1391,610,83,17)],[rect(1391,570,83,57),rect(1409,549,7,20),rect(1440,549,8,20),rect(1412,546,34,7)]),
        object_('east_suitcase',627,[(1562,610,88,17)],[rect(1562,568,88,59),rect(1589,548,8,20),rect(1618,548,8,20),rect(1593,545,28,7)]),
        object_('bin',615,[(752,601, 40,14)],[rect(752,555,40,60),rect(762,548, 20,7)]),
        object_('steel_bin',612,[(831,594, 40,18)],[rect(831,495,40,117)]))
    r['anchors']['Point']=point(1150,664);r['clerks']['Point']=point(1120,522)
    r['lettering']=[sign((875,126,315,101),'ARRIVALS','#00000000',size=37),
        sign((1249,126,327,152),'FLIGHT   STATUS\n01       ARRIVED\n02       ARRIVED\n03       ON TIME\n04       ON TIME','#1d2938','#e3c45d',size=19)]
    r['animation_patches']=[dict(kind='conveyor',rect=[*point(1276,637),*point(396,44)])]
    return rows
