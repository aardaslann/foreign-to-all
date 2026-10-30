"""Complete silhouettes and contacts measured on the replacement artwork.

Reference canvas: 1672 x 941. Prepared-art hashes cover these revisions.
"""
from .shapes import point, rect, tube, object_, sign
from .moscow import oval, pot
from .newyork_finish import replace
from .tokyo import wheel


def suzuranto(name,x):
    parts=[rect(x-10,216,21,504),rect(x-17,715,35,80),rect(x-19,792,39,8),
           rect(x-58,239,116,16),rect(x-65,236,14,25),rect(x+51,236,14,25)]
    for dx in [-65,52]:
        parts += [rect(x+dx,248,12,23),
                  [[x+dx-23,286],[x+dx-20,278],[x+dx-10,271],[x+dx-10,267],
                   [x+dx+20,267],[x+dx+20,271],[x+dx+31,278],[x+dx+34,286]],
                  oval(x+dx+5,313,33,35)]
    return object_(name,800,[(x-19,781,39,19)],parts)


def apply(rows):
    r=rows['SaoPauloLiberdade']
    r['floor']=point(0,711)[1]
    replace(r,suzuranto('suzuranto_0',220),suzuranto('suzuranto_1',965),
        pot('west_tree',(480,718,98,69),(438,192,187,526),[
            rect(516,393,24,245),tube((528,490),(500,409),14),tube((531,512),(563,446),14),
            tube((523,406),(491,337),13),tube((529,401),(563,327),11)]),
        pot('east_tree',(1597,714,75,58),(1511,183,161,530),[
            rect(1622,460,26,253),tube((1633,533),(1591,451),15),tube((1634,503),(1668,415),14)]),
        pot('bookshop_pot',(1030,681,43,31),(1024,607,53,75)),
        object_('bin',723,[(1258,702,46,21)],[rect(1257,643,50,26),rect(1261,668,42,54)]),
        pot('hotel_west_pot',(179,677,28,36),(173,613,45,65)),
        pot('hotel_east_pot',(426,675,32,38),(414,596,51,80)))
    r['anchors'].update(HotelDoor=point(350,757),ExchangeDoor=point(996,757))
    r['lettering']=[
        sign((255,439,188,60),'ホテル','#00000000','#972f2f',size=30,font='res://art/fonts/NotoSansJP.ttf'),
        sign((646,416,209,67),'ラーメン','#00000000','#2e373c',size=32,font='res://art/fonts/NotoSansJP.ttf'),
        sign((1129,439,90,61),'本','#00000000','#273b40',size=36,font='res://art/fonts/NotoSansJP.ttf'),
        sign((1337,509,216,29),'PADARIA','#00000000','#263d3d',size=20),
        sign((978,518,47,31),'CÂMBIO','#eee7d4','#263834',size=8)]

    r=rows['SaoPauloBixiga']
    r['floor']=point(0,718)[1]
    replace(r,pot('bakery_pot',(474,682,49,49),(460,578,77,106)),
        pot('workshop_pot',(866,683,58,48),(847,556,88,128)),
        pot('tree',(1252,733,147,55),(1240,520,166,213),[
            rect(1315,648,19,88),tube((1322,690),(1288,654),13),tube((1324,662),(1366,631),12)]),
        object_('bench',734,[(1046,715,172,19)],[rect(1044,669,173,23),rect(1041,696,179,16),
            rect(1047,711,18,23),rect(1198,711,17,23)]),
        object_('crates',732,[(1575,716,86,16)],[rect(1577,629,78,41),rect(1576,677,84,47),
            rect(1582,669,65,7),rect(1580,724,8,8),rect(1649,724,8,8)]))
    r['lettering']=[sign((98,443,366,51),'PADARIA','#00000000',size=33),
        sign((613,457,204,33),'CONSERTO','#00000000','#27313c',size=23),
        sign((1000,533,199,13),'CONGELADOS','#00000000',size=9)]

    r=rows['SaoPauloMercadao']
    r['floor']=point(0,720)[1]
    for o in r['objects']:
        if o['id'].startswith('produce_or_crates_'):o['polygons']=[]
    replace(r,
        object_('produce_or_crates_0',720,[(32,698,282,22)],[rect(32,659,283,60),rect(38,612,275,48),rect(38,573,59,39),rect(260,577,43,38),
            rect(25,532,295,14),rect(26,546,9,174),rect(310,546,11,174)]),
        object_('produce_or_crates_1',720,[(423,699,101,21)],[rect(420,661,106,58),rect(428,594,86,68),
            rect(415,532,109,15),rect(413,547,11,173),rect(517,547,11,173)]),
        object_('produce_or_crates_2',720,[(565,699,239,21)],[rect(565,661,237,58),rect(570,613,231,49),rect(665,565,55,48)]),
        object_('produce_or_crates_3',720,[(895,699,103,21)],[rect(896,664,99,51),rect(904,615,84,49),rect(897,711,100,8)]),
        object_('produce_or_crates_4',755,[(1115,734,92,21)],[rect(1117,682,89,58),rect(1129,628,65,54),rect(1113,738,97,9),rect(1119,746,9,9),rect(1191,746,9,9)]),
        object_('produce_or_crates_5',720,[(1361,699,179,21)],[rect(1362,683,178,31),rect(1369,632,69,51),rect(1452,632,79,51),rect(1378,584,53,47),rect(1467,584,56,47),rect(1364,713,174,7)]),
        object_('pallet_jack_base',756,[(1215,738,81,18)],[rect(1275,639,11,92),
            tube((1277,640),(1266,635),6),tube((1266,635),(1273,630),5),rect(1273,628,24,5),tube((1297,630),(1283,641),5),
            [[1212,746],[1227,716],[1238,694],[1245,694],[1242,726],[1265,725],[1274,739],[1258,751]],
            oval(1277,742,16,15),oval(1218,746,7,8)]),
        object_('truck',770,[(1583,733,89,37)],[rect(1583,514,89,214),rect(1582,725,90,24),oval(1666,742,31,29)]))
    r['lettering']=[sign((737,345,222,32),'MERCADÃO','#00000000','#863d31',size=25)]

    r=rows['SaoPauloPaulista']
    r['floor']=point(0,696)[1]
    replace(r,
        object_('bus_shelter_frame',738,[(137,719,508,19)],[
            rect(136,505,526,19),rect(138,523,15,221),rect(228,539,14,191),
            rect(361,539,11,177),rect(490,539,11,179),rect(568,523,15,224),
            rect(630,524,15,212),rect(151,536,489,8),rect(153,707,480,11),
            rect(157,551,68,155)],
            glass=[rect(245,545,116,162),rect(374,545,116,162),rect(503,545,64,162),rect(584,545,45,162)]),
        object_('bus_shelter_bench',741,[(284,720,283,21)],[
            rect(294,644,273,16),rect(293,665,274,14),rect(281,690,286,13),
            rect(293,702,267,9),rect(286,709,14,32),rect(550,704,14,37)]),
        pot('west_tree',(23,655,99,62),(0,213,256,443),[
            rect(57,496,28,162),tube((69,538),(22,460),19),tube((70,493),(119,421),20)]),
        pot('center_tree',(655,679,241,51),(680,420,213,259),[
            rect(771,568,17,75),tube((779,592),(747,548),11),tube((780,553),(814,512),11)]),
        object_('bin',740,[(916,721,63,19)],[rect(914,635,63,25),rect(916,660,62,80)]),
        object_('metro_left',735,[(1094,707,40,28)],[rect(1094,410,39,325)]),
        object_('metro_right',735,[(1569,707,41,28)],[rect(1569,410,39,325)]),
        object_('metro_lintel',735,[(1094,707,40,28),(1569,707,41,28)],[rect(1094,410,514,127)]),
        object_('metro_west_handrail',735,[(1170,707,73,28)],[
            [[1170,734],[1187,625],[1198,598],[1207,590],[1222,590],[1230,600],[1240,638],[1243,734]],
            tube((1134,639),(1157,621),6),rect(1150,635,5,98)]),
        object_('metro_east_handrail',735,[(1448,707,70,28)],[
            [[1448,734],[1453,625],[1463,598],[1472,590],[1488,590],[1498,601],[1511,642],[1518,734]],
            tube((1568,639),(1546,621),6),rect(1546,635,5,98)]))
    r['lettering']=[sign((1154,455,392,49),'METRÔ','#00000000','#22303c',size=38,object='metro_lintel')]

    r=rows['SaoPauloVilaMadalena']
    r['floor']=point(0,736)[1]
    replace(r,pot('west_tree',(0,700,166,65),(0,135,252,563),[
            rect(62,471,28,215),tube((74,531),(37,469),18),tube((81,487),(135,416),20),
            tube((74,411),(44,351),17),tube((82,358),(139,287),16)]),
        pot('cafe_pot',(599,698,56,48),(590,590,76,109)),
        pot('east_pot',(1618,687,50,58),(1616,607,53,80)),
        object_('menu',757,[(1000,740,98,17)],[
            [[1008,629],[1088,629],[1091,650],[1098,749],[1088,749],[1084,735],
             [1083,756],[1073,756],[1075,736],[1013,736],[1009,757],[999,757]]]))
    for i,x in enumerate([232,306,380]):
        replace(r,object_('cafe_stool'+str(i),744,[(x,728,53,16)],[rect(x+6,667,44,12),
            [[x+10,679],[x+19,679],[x+9,741],[x,741]],
            [[x+39,679],[x+46,679],[x+53,742],[x+45,742]],rect(x+11,711,34,7)]))
    polys=wheel(1283,708,41)+wheel(1372,709,40)+wheel(1441,708,39)
    for a,b,w in [((1283,708),(1305,651),6),((1305,651),(1356,650),6),
                 ((1356,650),(1324,704),6),((1324,704),(1283,708),6),((1305,651),(1324,704),6),
                 ((1356,650),(1372,709),6),((1372,709),(1392,702),6),
                 ((1392,702),(1362,653),6),((1362,653),(1415,650),6),
                 ((1415,650),(1392,702),6),((1415,650),(1441,708),6),
                 ((1305,651),(1304,637),5),((1362,653),(1358,637),5),
                 ((1356,650),(1356,630),5),((1415,650),(1414,630),5)]:polys.append(tube(a,b,w))
    polys += [rect(1288,630,30,8),rect(1340,630,29,8),rect(1403,629,33,8)]
    replace(r,object_('bicycle',751,[(1242,734,239,17)],polys,
        accents=[dict(points=[point(1357,650),point(1357,632),point(1370,632),point(1375,624)],color='#253639',width=3),
                 dict(points=[point(1414,650),point(1414,632),point(1429,632),point(1435,624)],color='#253639',width=3)]))
    r['lettering']=[sign((233,433,358,49),'CAFÉ','#00000000',size=38),
        sign((1017,649,57,68),'CAFÉ\nCHÁ','#00000000',size=13,object='menu')]

    r=rows['SaoPauloHotel']
    r['floor']=point(0,551)[1]
    replace(r,object_('reception',571,[(401,545,479,26)],[rect(398,416,482,20),rect(401,436,477,134),
            rect(462,362,89,48),rect(492,408,22,9),rect(800,377,44,39),rect(417,401,24,15),rect(424,379,8,22)]),
        object_('luggage_cart',572,[(57,551,95,21)],[rect(57,529,98,23),oval(74,559,13,11),oval(133,559,14,11),
            rect(63,392,10,137),rect(81,389,8,138),rect(119,389,8,138),rect(137,392,10,137),rect(73,446,67,9),
            [[64,394],[64,383],[71,375],[138,375],[147,384],[147,396],[136,389],[129,384],[80,384],[74,390]],oval(106,362,9,10)]),
        object_('suitcase',572,[(172,552,86,20)],[rect(173,398,86,155),rect(168,454,11,64),rect(253,454,9,63),
            oval(176,560,7,10),oval(249,560,7,10)]),
        pot('lobby_tree',(294,496,72,75),(257,292,148,205),[rect(316,440,22,59),tube((326,460),(300,425),12)]),
        pot('counter_plant',(885,496,66,74),(880,331,78,168)),
        object_('armchair_left',570,[(1007,551,146,19)],[rect(1008,435,103,92),rect(1007,482,70,69),
            rect(1109,482,43,69),rect(1075,519,38,32),rect(1009,551,12,17),rect(1065,551,13,17),rect(1140,550,14,18)]),
        object_('armchair_right',570,[(1297,551,146,19)],[rect(1345,435,97,84),rect(1297,482,47,69),
            rect(1373,482,70,69),rect(1343,519,33,32),rect(1298,551,13,17),rect(1374,551,13,18),rect(1430,551,12,17)]),
        object_('coffee_table',595,[(1169,579,113,16)],[rect(1155,526,145,20),rect(1170,546,15,46),rect(1265,546,16,47)]),
        pot('table_plant',(1200,503,48,29),(1170,413,107,91)))
    r['anchors']['Point']=point(680,628)
    r['clerks']['Point']=point(680,448)
    r['lettering']=[sign((90,181,251,108),'HOTEL\nSÃO PAULO','#00000000','#684a31',size=32),
        sign((517,447,249,37),'RECEPÇÃO','#00000000',size=24,object='reception')]

    r=rows['SaoPauloExchange']
    r['floor']=point(0,550)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('waiting')]
    replace(r,object_('exchange_counter',562,[(586,541,536,21)],[rect(583,409,542,25),rect(586,434,537,127),
            rect(585,153,538,17),rect(585,170,17,239),rect(1107,170,16,239),rect(841,170,10,237),
            rect(611,338,53,68),rect(1047,338,50,68)],glass=[rect(603,171,237,236),rect(852,171,254,236)]),
        object_('queue',626,[(418,602,519,24)],[rect(463,464,426,15),
            *[rect(x-11,453,22,151) for x in [451,675,900]],*[oval(x,613,33,12) for x in [451,675,900]]]),
        pot('west_plant',(278,501,78,69),(257,354,120,146)),
        pot('east_plant',(1392,507,83,71),(1374,379,121,128)),
        pot('exit_plant',(17,505,56,65),(10,411,76,94)),
        object_('waiting_seat',620,[(1165,601,193,19)],[rect(1165,478,91,60),rect(1265,478,93,60),
            rect(1158,543,101,27),rect(1263,543,101,27),rect(1170,571,179,9),
            rect(1167,578,17,39),rect(1336,578,18,39),rect(1240,535,8,8),rect(1274,535,7,8)]))
    r['anchors']['Point']=point(1010,596)
    r['clerks']['Point']=point(945,441)
    r['lettering']=[sign((334,164,193,154),'CÂMBIO\nEXCHANGE','#00000000','#293d48',size=24),
        sign((1173,152,225,197),'MOEDAS\nUSD · EUR\nGBP · JPY\nCAD','#00000000',size=23)]

    r=rows['SaoPauloTransit']
    r['floor']=point(0,639)[1]
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('platform_seat')]
    replace(r,object_('map_case',797,[(489,776,159,21)],[rect(489,368,159,428),rect(500,351,143,17)]),
        object_('newsstand',797,[(657,777,206,20)],[rect(657,404,206,388)]),
        object_('bin',796,[(1351,775,79,21)],[rect(1351,600,79,20),rect(1351,620,12,36),rect(1418,620,12,36),rect(1363,646,55,10),rect(1351,656,79,139)]),
        object_('right_pier',797,[(1503,775,134,22)],[rect(1503,63,134,734)]),
        object_('left_pier',797,[(0,775,105,22)],[rect(0,63,105,734)]),
        object_('platform_seat',797,[(947,776,285,21)],[
            *[rect(x,600,90,96) for x in [948,1046,1144]],
            *[rect(x-5,696,96,33) for x in [948,1046,1144]],
            rect(956,730,273,13),rect(963,743,14,43),rect(1205,743,13,44),
            rect(958,784,26,12),rect(1199,784,27,12)]))
    for i,x in enumerate([139,232,326,419]):
        replace(r,object_('gate'+str(i),635,[(x-32,615,87,20)],[rect(x,426,52,209),rect(x+5,403,46,23),
            rect(x-31,481,30,12),tube((x-21,495),(x-14,524),7),rect(x-26,492,10,8)]))
    r['lettering']=[sign((745,209,342,142),'METRÔ','#00000000',size=49),
        sign((1123,206,211,133),'LINHA 1\nAZUL','#00000000',size=32),
        sign((676,437,160,32),'REVISTAS','#00000000',size=20)]

    r=rows['SaoPauloAirport']
    r['objects']=[o for o in r['objects'] if not o['id'].startswith(('gate_left','gate_right'))]
    replace(r,object_('information_counter',894,[(984,873,375,21)],[rect(982,771,305,21),rect(984,792,374,101),
            rect(1274,720,85,153),rect(1099,732,63,34),rect(1117,765,32,12),rect(999,732,29,45)]),
        object_('carousel',741,[(1192,717,480,24)],[
            [[1191,650],[1212,637],[1251,622],[1672,622],[1672,741],[1234,741],[1205,725],[1191,706]]]),
        object_('recycling_bin',713,[(1040,690,98,23)],[rect(1040,588,98,123)]),
        pot('cafe_west_plant',(297,642,78,70),(289,494,97,150)),
        pot('cafe_east_plant',(838,641,78,71),(815,494,111,150)))
    carts=[]
    for x in [13,52,91,130,170,210]:
        carts += [rect(x-3,637,7,82),rect(x+13,641,6,78),rect(x-2,711,21,9),
                  rect(x-3,632,20,12),oval(x+6,749,14,14)]
    carts += [rect(0,726,234,12)]
    replace(r,object_('trolleys',765,[(0,745,233,20)],carts))
    for name,x in [('gate_left',338),('gate_right',660)]:
        polys=[rect(x+7,870,282,12),rect(x+5,835,13,65),rect(x+278,835,13,65),
               rect(x,902,26,15),rect(x+271,902,27,15)]
        for xx in [x+18,x+106,x+194]:
            polys += [rect(xx,775,81,77),rect(xx-4,852,85,18)]
        replace(r,object_(name,918,[(x,898,298,20)],polys))
    r['clerks']['Point']=point(1152,800)
    r['anchors']['Point']=point(1156,925)
    r['animation_patches']=[dict(kind='conveyor',rect=[*point(1250,630),*point(422,37)])]
    r['lettering']=[sign((390,198,269,113),'EMBARQUE\nDEPARTURES','#00000000',size=26),
        sign((830,203,322,106),'DESEMBARQUE\nARRIVALS','#00000000',size=24),
        sign((552,454,265,42),'CAFÉ','#00000000',size=35),
        sign((1211,189,438,162),'PORTÃO      STATUS\n01          EMBARQUE\n02          NO HORÁRIO\n03          NO HORÁRIO\n04          AGUARDE','#15243b','#e1bd56',size=19),
        sign((1455,473,56,65),'3','#00000000','#242c3b',size=43),
        sign((1007,810,249,36),'INFORMAÇÕES','#00000000',size=24,object='information_counter')]
    return rows
