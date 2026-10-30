"""Sydney replacement-art measurements, in the 1672 x 941 reference canvas."""
from .shapes import point, rect, tube, object_, sign
from .moscow import oval, pot
from .newyork_finish import replace


def wood_bench(name,x,y,w,h):
    return object_(name,y+h,[(x+4,y+h-17,w-8,17)],[
        rect(x+9,y,w-18,21),rect(x+9,y+24,w-18,19),
        rect(x,y+46,w,19),rect(x+6,y+65,13,h-65),
        rect(x+w-19,y+65,13,h-65),rect(x+4,y-3,6,49),rect(x+w-10,y-3,6,49)])


def lamp(name,x,globe,base):
    return object_(name,base,[(x-16,base-22,32,22)],[
        oval(x,globe,18,19),rect(x-11,globe+15,22,12),
        rect(x-7,globe+25,14,base-globe-105),rect(x-16,base-80,32,80)])


def apply(rows):
    r=rows['SydneyCircularQuay']
    r['floor']=point(0,659)[1]
    # All entrances open onto the new level paving; no foreground wall.
    r['objects']=[o for o in r['objects'] if not o['id'].startswith(('quay_rail','hotel_kiosk','ferry_kiosk','exchange_kiosk'))]
    replace(r,wood_bench('west_bench',343,673,207,85),wood_bench('east_bench',1191,673,207,85),
        lamp('quay_lamp0',287,469,757),lamp('quay_lamp1',1542,411,757))
    for i,x in enumerate([119,600,994,1464]):
        replace(r,object_('quay_bin'+str(i),756,[(x,736,39,20)],[rect(x,674,39,82),rect(x+5,670,31,6)]))
    r['anchors'].update(HotelDoor=point(516,699),ExchangeDoor=point(1270,699),TransitDoor=point(853,700))
    r['lettering']=[sign((399,473,238,35),'HARBOUR HOTEL','#00000000','#273e3c',size=24),
        sign((745,472,220,37),'TICKETS','#00000000','#273e3c',size=26),
        sign((1211,470,185,38),'EXCHANGE','#00000000','#273e3c',size=23),
        sign((1358,561,34,94),'$\n€\n£','#00000000','#e3c65b',size=20)]
    r['animation_patches']=[dict(kind='water',rect=[*point(1201,360),*point(318,79)])]

    r=rows['SydneyCBD']
    r['floor']=point(0,730)[1]
    replace(r,wood_bench('west_bench',131,672,201,83),
        object_('west_bin',755,[(57,735,57,20)],[rect(57,652,57,103)]),
        object_('west_tree',670,[(212,652,26,18)],
            [rect(212,507,26,161),tube((224,566),(169,491),15),tube((227,528),(272,468),15)],
            foliage=[rect(96,350,244,248)],wood_branches=True),
        lamp('west_lamp',420,474,755),
        object_('map_frame',755,[(468,736,18,19),(545,736,20,19),(593,736,19,19),(720,736,18,19)],[
            rect(458,545,293,19),rect(468,564,18,191),rect(545,564,20,191),
            rect(593,564,19,191),rect(720,564,18,191),rect(484,576,62,124),
            rect(612,571,108,105),rect(596,713,132,12)],glass=[rect(567,565,27,147),rect(612,679,108,33)]),
        object_('newsstand',741,[(1395,723,241,18)],[rect(1394,566,243,175),rect(1391,493,257,74)]),
        object_('station_bin',751,[(1311,732,56,19)],[rect(1311,657,56,94)]),
        object_('station_west_pier',755,[(770,735,28,20),(814,712, 40,19)],
            [rect(770,505,28,250),rect(690,482,107,24),rect(813,437,41,294)]),
        object_('station_east_pier',755,[(1281,735,25,20),(1217,712, 30,19)],
            [rect(1281,506,25,249),rect(1250,483,117,26),rect(1217,437,30,294)]),
        object_('station_lintel',755,[(814,712,40,19),(1217,712,30,19)],
            [rect(799,391,545,32),rect(814,423,511,35),rect(854,458,363,81)]))
    r['lettering']=[sign((866,472,338,55),'T · TOWN HALL','#00000000',size=31,object='station_lintel'),
        sign((1410,511,226,42),'NEWS','#00000000','#293e50',size=34,object='newsstand')]

    r=rows['SydneyNewtown']
    r['floor']=point(0,727)[1]
    replace(r,object_('street_tree',759,[(1154,741,45,18)],
        [rect(1165,521,25,237),tube((1176,619),(1115,543),14),tube((1178,592),(1236,527),16),
         tube((1175,555),(1151,475),12),tube((1174,516),(1116,452),10)],
        foliage=[rect(966,283,365,337)],wood_branches=True),
        pot('tree_planter',(1080,710,69,50),(1072,669,82,43)),
        pot('cafe_plant',(652,708,75,52),(643,570,95,139)),
        pot('record_pot',(109,711,62,45),(100,657,80,56)),
        object_('east_bench',754,[(1211,737,324,17)],[rect(1212,680,319,9),rect(1212,698,319,7),
            rect(1211,731,324,9),rect(1210,685,7,69),rect(1525,685,8,69),
            *[rect(x,688,5,43) for x in range(1225,1522,17)]]),
        object_('east_bin',754,[(1568,734,62,20)],[rect(1568,655,62,99)]),
        object_('bollard',757,[(431,740, 20,17)],[rect(431,673,20,84)]),
        lamp('lamp0',69,482,757),lamp('lamp1',1367,467,757))
    r['lettering']=[sign((156,485,241,46),'RECORDS','#00000000',size=29),
        sign((799,492,217,39),'KEBAB','#00000000','#914632',size=33),
        sign((1469,355,181,184),'NEWTOWN\nGOOD\nPEOPLE','#00000000','#22364c',size=29)]

    r=rows['SydneyBondi']
    r['floor']=point(0,560)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('promenade_rail')]
    for i,(x,w,posts) in enumerate([(0,839,[46,110,201,233,285,416,496,593,675,805]),
                                  (1000,410,[1000,1066,1138,1205,1276,1348]),(1633,39,[])]):
        polys=[rect(x,591,w,67),rect(x,525,w,8),rect(x,545,w,7),rect(x,561,w,7)]
        for xx in posts:polys.append(rect(xx,524,10,66))
        replace(r,object_('promenade_rail'+str(i),658,[(x,594,w,64)],polys))
    replace(r,object_('stair_west_cheek',660,[(840,592,37,68)],[rect(840,584,37,76)]),
        object_('stair_east_cheek',660,[(1011,592,35,68)],[rect(1011,584,35,76)]))
    for i,x in enumerate([150,1093]):replace(r,object_('beach_bin'+str(i),670,[(x,651,45,19)],[rect(x,584,45,86)]))
    rack=[rect(1409,510,13,150),rect(1618,512,11,148),rect(1419,637,200,12)]
    for x,w,top in [(1432, 50,469),(1491,43,479),(1539,42,474),(1588,33,503)]:
        rack.append([[x+w*.5,top],[x+w*.7,top+7],[x+w*.9,top+29],[x+w,top+ 70],
                     [x+w,642],[x+w*.75,661],[x+w*.25,661],[x,642],[x,top+70],[x+w*.15,top+27]])
    replace(r,object_('board_rack',662,[(1409,645,220,17)],rack))
    r['lettering']=[sign((399,358,171,40),'BONDI','#00000000','#26364a',size=28),
        sign((1150,326,257, 30),'BEACH CAFÉ','#00000000','#263e4a',size=29)]
    r['animation_patches']=[dict(kind='water',rect=[*point(154,150),*point(1062,141)])]

    r=rows['SydneyCabramatta']
    r['floor']=point(0,600)[1]
    r['objects']=[o for o in r['objects'] if o['id'] not in ['citrus']]
    replace(r,pot('west_produce',(21,558,130,72),(12,486,141,73)),
        pot('middle_produce',(241,559,140,71),(236,484,151,75)),
        object_('citrus',631,[(385,610,179,21)],
            [rect(385,575,179,56),[[386,575],[395,548],[415,540],[423,518],[446,517],[462,529],
             [480,516],[503,520],[514,540],[550,541],[563,558],[564,575]]]),
        object_('east_produce',638,[(938,618,158,20)],
            [rect(938,591,158,47),[[938,591],[947,550],[964,536],[981,542],[992,529],[1010,540],
             [1026,532],[1041,542],[1060,532],[1080,542],[1095,567],[1096,591]]]),
        pot('east_shop_plant',(1098,589,79,49),(1091,515,94,75)),
        object_('shop_bin',631,[(709,613,49,18)],[rect(708,542,51,89)]),
        object_('gate_bin',646,[(1609,626,61,20)],[rect(1609,546,61,100)]),
        object_('small_gate_bin',651,[(1537,633,38,18)],[rect(1536,590,40,61)]),
        wood_bench('plaza_bench',1310,576,181,78),
        lamp('plaza_lamp',1222,326,648),
        object_('gate_west_column',620,[(1238,596,81,24)],
            [rect(1238,541,81,79),rect(1256,176,29,267),rect(1236,526,76,15)],
            foliage=[],wood_branches=False),
        object_('gate_east_column',620,[(1528,596,80,24)],
            [rect(1528,540,80,80),rect(1552,177,28,268),rect(1531,526,71,14)]),
        object_('west_guardian',620,[(1238,596,81,24)],
            [[[1240,526],[1245,503],[1258,491],[1257,477],[1250,467],[1260,448],[1274,440],
              [1294,444],[1306,455],[1305,477],[1297,487],[1302,511],[1307,526]]]),
        object_('east_guardian',620,[(1528,596,80,24)],
            [[[1530,526],[1537,505],[1540,488],[1531,479],[1533,456],[1545,443],[1563,441],
              [1580,453],[1585,472],[1577,485],[1591,506],[1598,526]]]))
    r['lettering']=[sign((65,249,291,65),'PHỞ','#00000000',size=45),
        sign((397,249,309,65),'TÂN PHÁT\nASIAN GROCER','#00000000',size=28),
        sign((783,250,354,65),'金豐超市','#00000000','#912f2d',size=40,font='res://art/fonts/NotoSansJP.ttf'),
        sign((1301,203,231,40),'CABRAMATTA','#00000000','#433524',size=29)]

    r=rows['SydneyHotel']
    r['floor']=point(0,552)[1]
    replace(r,object_('reception',581,[(514,551,790,30)],[rect(510,394,798,21),rect(516,415,786,143),rect(514,558,790,23),
            rect(558,373,328,20),rect(585,348,52,46),rect(690,326,73,51),rect(928,327,62,49),
            rect(1034,329,35,65),[[1015,325],[1033,270],[1072,270],[1091,325]],rect(1190,362,52,30)]),
        pot('reception_plant',(585,348,52,46),(561,255,97,93)),
        object_('luggage_trolley',616,[(32,595,203,21)],[
            rect(32,578,203,14),rect(37,365,10,214),rect(165,365,10,215),rect(46,350,119,11),
            tube((40,365),(49,354),8),tube((162,354),(171,365),8),rect(52,463,98,112),
            rect(86,445,8,20),rect(115,445,8,20),rect(88,442,32,7),rect(152,494,68,83),
            rect(175,478,8,17),rect(198,478,8,17),rect(176,476,28,6),
            *[rect(x,592,19,23) for x in [ 50,82,154,191]]]),
        object_('umbrella_stand',563,[(335,545,85,18)],[rect(335,458,85,105),
            rect(344,425,9,34),rect(376,423,8,38),rect(407,432,8,28),
            tube((334,434),(335,423),6),tube((335,423),(346,418),6),tube((346,418),(355,425),6),
            tube((376,426),(383,419),6),tube((383,419),(392,424),6),rect(390,425,6,12),
            tube((409,432),(416,425),6),tube((416,425),(425,431),6),rect(424,431,6,10)]),
        pot('east_plant',(1384,470,87,94),(1330,243,183,228),[rect(1420,398,18,73)]),
        object_('sofa',819,[(689,800,478,19)],[
            rect(691,610,436,92),[[691,702],[1127,702],[1174,724],[1174,755],[686,755],[686,725]],
            rect(686,756,487,20),rect(691,776,21,43),rect(1146,776, 20,43)]),
        object_('coffee_table',823,[(505,803,174,20)],[rect(502,725,177,26),rect(505,751,174,72)]),
        pot('table_plant',(591,706,55,23),(570,643,92,64)))
    r['anchors'].update(Exit=point(282,602),Point=point(985,625))
    r['clerks']['Point']=point(1140,426)
    r['lettering']=[sign((706,188,310,63),'HARBOUR HOTEL','#00000000','#283941',size=32),
        sign((380,247,110,117),'KEYS\nLUGGAGE\nTOURS','#00000000',size=19)]

    r=rows['SydneyExchange']
    r['floor']=point(0,674)[1]
    replace(r,object_('exchange_counter',674,[(484,644,839,30)],
        [rect(484,638,839,36),rect(543,508,752,130),rect(549,247,13,261),rect(1031,247,12,261),
         rect(549,247,494,12),rect(747,399,116,82),rect(790,434,29,69),rect(628,483,43,19),
         tube((641,483),(641,416),7),tube((641,416),(684,379),7),
         [[684,374],[702,380],[717,395],[691,410],[672,394]],rect(691,453,45,51),rect(953,437,55,66)],
        glass=[rect(562,259,469,244)]),
        pot('east_plant',(1549,610,95,84),(1527,482,144,129)))
    r['anchors']['Point']=point(921,708)
    r['clerks']['Point']=point(926,537)
    r['lettering']=[sign((544,165,674,63),'CURRENCY EXCHANGE','#00000000',size=40),
        sign((334,311,168,141),'CURRENCY\nTRAVEL CARD\nMONEY TRANSFER','#00000000','#2b3847',size=18),
        sign((1056,281,204,211),'AUD\nUSD\nEUR\nGBP\nJPY','#20364e',size=23)]

    r=rows['SydneyTransit']
    r['floor']=point(0,648)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('platform_seat')]
    seat_parts=[rect(47,630,448,18),rect(62,648,420,12),rect(62,660,13,44),rect(473,651,14,45)]
    for x in [62,166,270,374]:seat_parts += [rect(x,536,95,79),rect(x-7,615,103,18),rect(x-8,540,7,80)]
    replace(r,object_('platform_seat',705,[(59,687,431,18)],seat_parts),
        object_('left_support',541,[(197,520,51,21)],[rect(197,0,51,541)]),
        object_('right_wall',679,[(1424,658,248,21)],[rect(1424,132,248,547)]),
        object_('gate_bank',671,[(562,651,607,20)],
            [*[rect(x,519,32,118) for x in [731,869,1007,1141]],
             *[rect(x,519,43,117) for x in [789,929,1071]]]))
    for i,x in enumerate([563,682,823,963,1105]):
        replace(r,object_('ticket_gate'+str(i),671,[(x,651,50 if i else 67,20)],
            [rect(x,516,50 if i else 67,155),rect(x+4,494,61,22)]))
    r['lettering']=[sign((597,128,495,66),'T · PLATFORMS 1–4 →','#00000000',size=35),
        sign((1460,204,166,132),'TRAINS\nBUSES\nWAY OUT →','#00000000',size=23)]
    r['motion_layers']=[dict(kind='doors',rect=[*point(553,364),*point(109,157)])]

    r=rows['SydneyAirport']
    r['floor']=point(0,669)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith(('gate_left','gate_right'))]
    for name,x,n in [('gate_left',208,5),('gate_right',671,2)]:
        parts=[rect(x,670,n*76+7,17)]
        for i in range(n):
            xx=x+i*76
            parts += [rect(xx+9,602,65,63),rect(xx+3,643,6,24),rect(xx+5,687,12,28),rect(xx,712,20,5)]
        parts += [rect(x+n*76-10,687,12,28),rect(x+n*76-15,712,21,5)]
        replace(r,object_(name,717,[(x,699,n*76+7,18)],parts))
    replace(r,pot('west_plant',(37,645,116,67),(33,500,129,146)),
        object_('carousel',760,[(897,731,552,29)],
            [[[895,674],[913,660],[967,641],[1017,625],[1449,625],[1449,760],[926,760],[900,741]]]),
        object_('information_counter',879,[(416,855,405,24)],[rect(410,755,416,28),rect(416,783,405,96),
            rect(414,750,68,9),rect(523,716,75,40),rect(548,743,26,20),rect(626,738,134,16)]),
        pot('counter_plant',(757,730,43,30),(745,677,64,54)),
        object_('right_wall',749,[(1443,728,55,21)],[rect(1443,603,55,146)]))
    r['anchors']['Point']=point(670,916)
    r['clerks']['Point']=point(670,775)
    r['lettering']=[sign((694,100,278,50),'DEPARTURES','#00000000',size=31),
        sign((694,184,278,46),'ARRIVALS','#00000000',size=31),
        sign((1223, 90,170,141),'GATES\n1–10','#00000000',size=34),
        sign((1329,303,343,164),'GATE     STATUS\n01       BOARDING\n02       ON TIME\n03       ON TIME\n04       WAIT','#19293f','#e0bc53',size=17),
        sign((468,800,302,33),'INFORMATION','#00000000',size=24,object='information_counter')]
    r['animation_patches']=[dict(kind='conveyor',rect=[*point(1014,633),*point(422,42)])]
    return rows
