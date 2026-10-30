"""Moscow replacement-art alignment, measured on the inspected pixel plates.

Ground contact remains independent of the full-height opaque silhouette. Gates
keep their open passage; plants include crowns; furniture keeps its leg gaps.
These are installation measurements, not a completed exhaustive movement audit.
"""
from .shapes import point, anchor, rect, tube, object_, sign, SY
from .moscow import pot, pipe, bench, board, oval
from .paris import lamp


def replace(row, *objects, remove=()):
    revisions = {o['id']: o for o in objects}
    row['objects'] = [revisions.pop(o['id'], o) for o in row['objects']
                      if o['id'] not in remove]
    row['objects'].extend(revisions.values())


def iron_leaf(name, x, width, top, bottom, reverse=False):
    # Open leaves are traced bars. A broad colour mask would also retain the
    # green shrubs visible through them and cut holes out of nearby people.
    shapes=[]
    for part in range(5):
        ratio=part/4
        back=1-ratio if reverse else ratio
        xx=x+ratio*width
        yy=top+back*20
        end=bottom-back*14
        shapes += [rect(xx-3,yy+9,6,end-yy-9),
                   [[xx-5,yy+9],[xx,yy],[xx+5,yy+9]]]
    for offset in [36,bottom-top-28]:
        a=(x,top+offset+(20 if reverse else 0))
        b=(x+width,top+offset+(0 if reverse else 20))
        shapes.append(tube(a,b,7))
    return object_(name,bottom,[(x-3,bottom-12,width+6,12)],shapes)


def fence(name, xs, top, bottom):
    shapes=[rect(xs[0],top+27,xs[-1]-xs[0],8),
            rect(xs[0],bottom-25,xs[-1]-xs[0],7)]
    for x in xs:
        shapes += [rect(x-3,top+12,6,bottom-top-12),
                   [[x-6,top+5],[x-3,top],[x+3,top],[x+6,top+5],
                    [x+6,top+10],[x+3,top+14],[x-3,top+14],[x-6,top+10]]]
    return object_(name,bottom,[(xs[0]-4,bottom-14,xs[-1]-xs[0]+8,14)],shapes)


def finish(scenes):
    for key, row in scenes.items():
        row.update(texture=f'res://art/environments/scenes/{key}-retro.png',
                   pixel_art=True, art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
    kitaygorod(scenes['MoscowKitayGorod'])
    basmanny(scenes['MoscowBasmanny'])
    arbat(scenes['MoscowArbat'])
    zamoskvorechye(scenes['MoscowZamoskvorechye'])
    izmaylovo(scenes['MoscowIzmaylovo'])
    hotel(scenes['MoscowHotel'])
    exchange(scenes['MoscowExchange'])
    transit(scenes['MoscowTransit'])
    airport(scenes['MoscowAirport'])
    return scenes


def kitaygorod(row):
    replace(row,
        lamp('west_lamp',120,427,708,46),lamp('middle_lamp',598,428,708,47),
        pipe('bookshop_pipe',630,94,700),pipe('cafe_pipe',1237,122,701),
        pipe('east_pipe',1286,20,705),
        object_('cafe_crate',704,[(838,688,62,16)],[rect(837,659,63,45)],
                foliage=[rect(836,638,68,24)],wood_branches=True),
        board('cafe_menu',1026,655,44,49),board('cafe_east_menu',1119,655,41,49),
        pot('cafe_box',(1163,662,53,42),(1158,610,66,54)),
        pot('arch_west_tree',(1298,650,48,55),(1282,514,78,140),[rect(1318,602,9,49)]),
        pot('arch_east_tree',(1606,650,57,55),(1590,496,82,158),[rect(1632,592,9,61)]),
        object_('arch_door_leaf',695,[(1365,681,70,14)],[
            [[1365,497],[1435,511],[1435,680],[1365,695]]]))
    row['lettering']=[
        sign((185,432,365,39),'КНИГИ','#493b31',size=30),
        sign((832,432,340,37),'СТОЛОВАЯ','#443b31',size=28),
        sign((1426,419,88,29),'МЕТРО','#343933',size=15),
        sign((19,465,55,23),'ОТЕЛЬ','#463a2c',size=10),
        sign((699,465,59,23),'ОБМЕН','#cabb97','#352d28',10),
        sign((1033,662,31,31),'МЕНЮ','#33493d',size=7,object='cafe_menu'),
        sign((1126,662,28,31),'ОБЕД','#33493d',size=7,object='cafe_east_menu')]


def basmanny(row):
    # Open leaves, never an invisible solid across the courtyard opening.
    replace(row,
        pipe('west_downpipe',602,181,705),
        object_('gate_west_pillar',699,[(620,681,69,18)],[rect(620,455,69,244)]),
        object_('gate_east_pillar',699,[(918,681,69,18)],[rect(918,455,69,244)]),
        iron_leaf('gate_leaf_west',694,52,461,695),
        iron_leaf('gate_leaf_east',852,59,461,695,True),
        bench('yard_bench',993,622,193,85),
        object_('litter_bin',705,[(1200,688,47,17)],[
            rect(1200,641,47,64),rect(1197,629,51,12),
            [[1197,629],[1203,622],[1239,622],[1248,629]]]),
        object_('flower_trough',707,[(1469,694,162,13)],[
            rect(1468,662,164,10),rect(1478,672,144,22),
            rect(1468,670,10,36),rect(1622,670,10,36)],
            foliage=[rect(1460,631,173,35)],wood_branches=True),
        object_('bench_shrub',695,[(1027,681,146,14)],[],
                foliage=[rect(994,433,216,262)],wood_branches=True),
        object_('east_pier',695,[(1435,678,68,17)],[rect(1435,466,68,229)]),
        fence('east_garden_fence',[1510,1534,1558,1582,1606,1630,1654,1671],510,695),
        object_('birch',695,[(1538,682,43,13)],[
            [[1544,692],[1544,357],[1520,301],[1517,281],[1525,283],
             [1547,329],[1551,204],[1531,156],[1531,128],[1538,128],
             [1557,179],[1564,60],[1573,47],[1573,191],[1590,160],
             [1594,110],[1603,108],[1600,174],[1572,220],[1571,329],
             [1590,297],[1600,213],[1609,212],[1601,307],[1570,358],[1570,692]]],
            foliage=[rect(1347,0,325,337),rect(1600,343,72,347)],wood_branches=True),
        remove=['courtyard_gate','noticeboard'])
    row['anchors'].update(AirportDoor=anchor(1327,739),TransitDoor=anchor(799,741))
    row['lettering']=[
        sign((77,459,280,31),'РЕМОНТ','#453b2e',size=29),
        sign((1241,487,170,28),'АЭРОПОРТ','#1f3c4b',size=18)]


def arbat(row):
    replace(row,
        pot('west_tree',(19,627,57,65),(0,465,86,166),[rect(43,568,10,61)]),
        pot('east_tree',(1609,628,55,64),(1594,480,78,151),[rect(1630,569,12,61)]),
        pot('small_shop_pot',(1178,653,29,32),(1174,598,34,57)),
        object_('book_display',691,[(444,674,49,17)],[
            rect(445,622,48,7),rect(446,633,47,6),rect(446,644,46,6),
            rect(448,654,44,6),rect(445,662,47,9),
            rect(444,671,6,20),rect(486,671,6,20)]),
        object_('postcard_west',679,[(1207,664,79,15)],[
            rect(1207,493,79,170),rect(1211,663,7,16),rect(1273,663,7,16)]),
        object_('postcard_east',679,[(1511,664,80,15)],[
            rect(1511,494,80,167),rect(1517,661,7,18),rect(1578,661,7,18)]),
        iron_leaf('passage_gate',637,18,483,679),
        remove=['tall_cafe_pot'])
    # The double lantern silhouette follows the new, lower hanging heads.
    replace(row,object_('double_lamp',721,[(579,704,43,17)],[
        rect(593,274,15,366),rect(585,635,31,69),rect(579,704,43,17),
        oval(601,270,7,8),tube((594,310),(579,282),7),
        tube((579,282),(562,274),8),tube((562,274),(554,284),8),
        tube((607,310),(623,281),7),tube((623,281),(642,274),8),
        tube((642,274),(650,284),8),
        [[534,306],[541,299],[552,290],[559,287],[568,296],[578,305],
         [578,312],[572,312],[568,343],[560,356],[552,353],[544,343],[539,312],[534,312]],
        [[621,306],[629,298],[640,289],[648,288],[656,298],[666,306],
         [666,312],[661,312],[657,345],[648,355],[639,352],[630,343],[626,312],[621,312]]]))
    row['anchors']['TransitDoor']=anchor(674,723)
    row['lettering']=[
        sign((75,409,431,40),'КНИГИ','#473b30',size=30),
        sign((749,398,364,35),'КАФЕ','#443a30',size=29),
        sign((1231,429,328,35),'СУВЕНИРЫ','#443a30',size=26),
        sign((628,430,75,24),'МЕТРО','#493e34',size=13),
        sign((1110,600,53,73),'КАФЕ\n\nЧАЙ\nКОФЕ','#233537',size=9,object='cafe_menu')]


def zamoskvorechye(row):
    replace(row,
        board('bakery_menu',104,589,74,118),
        pot('bakery_small',(482,662,44,44),(480,587,44,79)),
        pot('bakery_large',(544,654,68,52),(532,542,89,114)),
        object_('west_door_leaf',693,[(763,677,75,16)],[
            [[763,416],[838,444],[838,667],[763,693]]]),
        object_('east_door_leaf',693,[(1047,677,53,16)],[
            [[1047,437],[1100,417],[1100,693],[1047,670]]]),
        object_('east_tree',720,[(1431,704,104,16)],[
            rect(1431,704,104,16),
            [[1454,704],[1463,527],[1444,460],[1414,404],[1400,364],
             [1405,345],[1414,370],[1437,408],[1468,469],[1495,411],
             [1518,340],[1528,323],[1539,322],[1530,381],[1508,450],
             [1486,503],[1477,565],[1477,704]]],
            foliage=[rect(1220,0,452,455),rect(1433,685,98,24)],wood_branches=True),
        remove=['churchyard_gate'])
    row['lettering']=[
        sign((171,432,355,39),'ПЕКАРНЯ','#493b2e',size=31),
        sign((34,479,40,14),'МЕТРО','#264135',size=8),
        sign((114,602,51,82),'ХЛЕБ\n\nПИРОГИ\nЧАЙ','#223131',size=10,object='bakery_menu')]


def izmaylovo(row):
    replace(row,
        bench('park_bench',623,620,200,87),
        object_('park_planter',706,[(847,691,126,15)],[
            rect(847,667,126,39)],foliage=[rect(840,623,145,47)],wood_branches=True),
        object_('park_notices',704,[(935,687,168,17)],[
            rect(932,489,172,157),rect(936,646,10,58),rect(1089,646,14,58)]),
        fence('west_park_fence',list(range(474,1251,23)),504,696),
        fence('east_park_fence',[1644,1665],501,696),
        fence('park_gate_west',[1316,1335,1357,1374],502,696),
        fence('park_gate_east',[1568,1589,1608,1628],502,696),
        object_('park_gate_arch',696,[(1310,682,17,14),(1620,682,16,14)],[
            [[1318,442],[1353,421],[1408,405],[1453,396],[1487,396],
             [1530,402],[1580,418],[1627,442],[1627,499],[1580,478],
             [1530,461],[1490,453],[1455,453],[1408,461],[1355,480],[1318,499]],
            rect(1309,435,16,261),rect(1619,435,16,261)]))
    # White blossoms are not leaves: include only their small opaque clusters.
    planter=next(o for o in row['objects'] if o['id']=='park_planter')
    planter['polygons'] += [[point(x,y) for x,y in rect(a,b,5,5)]
        for a,b in [(855,641),(869,633),(892,644),(910,634),(939,645),(951,633),(927,651)]]
    row['lettering']=[
        sign((16,427,450,48),'ПРОДУКТЫ','#a73537',size=33),
        sign((344,514,87,22),'МЕТРО','#e7e4cf','#243929',12),
        sign((1420,419,128,26),'ПАРК','#184a40',size=21,object='park_gate_arch'),
        sign((959,525,37,34),'РАЙОН','#e1dfc7','#33473c',6,object='park_notices'),
        sign((1036,525,37,33),'ПАРК','#e6dfc7','#33473c',6,object='park_notices')]


def hotel(row):
    row['source']=[0,0,1671,941]
    row['floor']=round(653*SY,2)
    replace(row,
        object_('reception',672,[(382,652,579,20)],[
            rect(378,475,588,22),rect(386,497,568,152),rect(382,649,579,23),
            [[383,434],[399,383],[437,383],[453,434]],rect(414,434,9,37),
            rect(400,468,40,7),oval(488,470,19,8),rect(811,445,51,29),
            [[890,433],[903,383],[940,383],[955,433]],rect(917,433,10,36),
            rect(903,468,37,7)],foliage=[rect(789,361,94,87)],wood_branches=True),
        object_('radiator',664,[(1019,644,184,20)],[
            rect(1019,609,16,55),rect(1185,609,17,55),rect(1031,531,160,8),
            *[rect(x,518,16,115) for x in [1045,1069,1092,1114,1139,1162]],
            rect(1030,608,163,10)]),
        object_('reading_table_plant',704,[(1253,686,134,18)],[
            rect(1253,622,134,23),rect(1259,645,11,43),rect(1280,645,12,58),
            rect(1372,645,12,59),rect(1345,645,11,43),
            [[1290,581],[1345,581],[1345,593],[1340,626],[1297,626]],
            rect(1311,544,9,40)],foliage=[rect(1266,468,108,117)],wood_branches=True),
        object_('reading_chair',709,[(1418,690,171,19)],[
            [[1417,579],[1496,579],[1503,547],[1515,538],[1558,539],
             [1578,547],[1584,567],[1584,595],[1591,604],[1591,678],
             [1583,688],[1582,703],[1567,703],[1567,690],[1480,690],
             [1480,708],[1465,708],[1465,688],[1417,674]],
            rect(1418,674,13,12)]))
    row['anchors']['Point']=anchor(672,719)
    row['clerks']['Point']=anchor(672,514)
    row['lettering']=[
        sign((472,168,440,66),'ГОСТИНИЦА','#67452c',size=33),
        sign((1013,265,169,29),'МОСКВА','#e8e0c5','#352d27',25)]


def exchange(row):
    replace(row,
        object_('exchange_counter',663,[(493,645,577,18)],[
            rect(480,478,598,19),rect(491,497,579,166),
            rect(510,422,59,56),rect(630,418,87,60),rect(949,417,85,61),
            rect(854,444,46,34)],glass=[rect(510,262,542,216)]),
        pot('waiting_plant',(1433,591,78,82),(1409,406,125,188),[rect(1466,548,13,47)]),
        remove=['queue_post_0','queue_post_1','queue_post_2','queue_post_3','queue_belt'])
    for i,x in enumerate([600,881]):
        row['objects'].append(object_('queue_post_'+str(i),735,[(x-30,719,61,16)],[
            [[x-6,584],[x+5,584],[x+11,591],[x+11,614],[x+6,618],
             [x+6,716],[x+27,721],[x+31,727],[x+31,735],[x-30,735],
             [x-30,725],[x-6,716],[x-6,618],[x-11,614],[x-11,591]]]))
    row['objects'].append(object_('queue_belt',735,[(611,719,259,16)],[rect(611,600,259,13)]))
    row['anchors']['Point']=anchor(945,712)
    row['clerks']['Point']=anchor(788,510)
    row['lettering']=[
        sign((509,158,539,81),'ОБМЕН ВАЛЮТЫ','#1c3556',size=38),
        sign((1110,151,325,208),'ОБМЕН\n\nUSD · EUR\nRUB · CNY','#1c3556','#e8dbaa',27),
        sign((345,352,86,111),'ОБМЕН\n\nДОКУМЕНТЫ\nИ КВИТАНЦИИ','#e1dfc8','#30423d',9)]


def transit(row):
    replace(row,object_('ticket_machine',631,[(62,615,134,16)],[
        rect(64,319,130,58),rect(65,378,125,240),rect(59,615,138,16)]),
        remove=['map_board'])
    row['anchors']['Machine']=anchor(127,678)
    row['fittings']=[]
    row['lettering']=[
        sign((638,220,369,34),'ТЕАТРАЛЬНАЯ','#c5b79b','#172e3c',27),
        sign((1480,235,150,36),'ВЫХОД ↑','#25333d',size=23),
        sign((77,331,101,36),'БИЛЕТЫ','#ded8c5','#263747',14,object='ticket_machine')]
    row['motion_layers']=[dict(kind='doors',rect=[*point(539,382),*point(111,187)]),
                          dict(kind='doors',rect=[*point(1036,383),*point(115,187)])]


def airport(row):
    replace(row,object_('check_in_desk',667,[(445,650,309,17)],[
        rect(445,555,54,94),rect(493,571,262,24),rect(497,595,254,54),
        rect(446,649,307,9),rect(446,658,12,9),rect(739,658,12,9),
        rect(505,540,31,31),rect(689,523,46,45),rect(705,568,21,4)]),
        remove=['west_seats'])
    row['anchors']['Point']=anchor(624,714)
    row['clerks']={'Point':anchor(620,603)}
    row['prompt_overrides']['Point']='E — Airport check-in'
    row['lettering']=[
        sign((1049,130,567,62),'ВЫЛЕТЫ','#193044',size=39),
        sign((1061,213,541,178),'МОСКВА\n\nБЕРЛИН · СТАМБУЛ\nПАРИЖ · РИМ','#193044','#ead26c',24),
        sign((78,377,133,48),'ВЫХОД','#183249',size=26)]
