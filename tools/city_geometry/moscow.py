"""Moscow source layouts, realigned to replacement art by moscow_finish.

The source-art scene helper is also used by cities still awaiting replacement
art. Only the Moscow build opts into its measured retro revisions.
"""
from math import cos, sin, tau
from .shapes import point, anchor, rect, tube, object_, sign
from .london import scene as make_scene
from .rome import sizes
from .paris import lamp


def scene(key,floor,spawn,objects,anchors,lettering=(),**extra):
    return make_scene(key,floor,spawn,objects,anchors,lettering,**extra) | dict(
        texture=f'res://art/environments/scenes/{key}.png',pixel_art=False,
        implementation_stage='geometry_on_existing_art',art_pending=True,
        signs=[],room_numbers=[],cats=[])


def oval(x,y,rx,ry):
    return [[round(x+cos(i*tau/20)*rx,2),round(y+sin(i*tau/20)*ry,2)] for i in range(20)]


def pot(name,box,crown,branches=()):
    x,y,w,h=box
    return object_(name,y+h,[(x+4,y+h-18,w-8,18)],[
        [[x,y],[x+w,y],[x+w,y+12],[x+w-5,y+h],[x+5,y+h],[x,y+12]],*branches],
        foliage=[rect(*crown)],wood_branches=True)


def pipe(name,x,top,bottom):
    return object_(name,bottom,[(x-8,bottom-14,26,14)],[rect(x-7,top,13,bottom-top-9),
        [[x-7,bottom-17],[x+5,bottom-17],[x+17,bottom-9],[x+13,bottom],
         [x-7,bottom],[x-11,bottom-7]]])


def bench(name,x,y,w,h):
    return object_(name,y+h,[(x,y+h-15,w,15)],[
        rect(x+9,y,w-18,11),rect(x+9,y+17,w-18,10),rect(x+9,y+33,w-18,10),
        rect(x+2,y+4,7,h-17),rect(x+w-9,y+4,7,h-17),
        rect(x,y+h-43,w,16),rect(x+6,y+h-27,12,27),
        rect(x+w-18,y+h-27,12,27)])


def gate(name,x,y,w,h,step=24):
    polys=[rect(x,y+18,w,8),rect(x,y+h-23,w,8)]
    for xx in range(x,x+w,step):
        polys += [rect(xx,y+10,7,h-10),[[xx-2,y+10],[xx+3,y],[xx+9,y+10]]]
    return object_(name,y+h,[(x,y+h-15,w,15)],polys)


def board(name,x,y,w,h):
    return object_(name,y+h,[(x,y+h-14,w,14)],[
        [[x+4,y],[x+w-4,y],[x+w,y+h],[x+w-8,y+h],[x+w-8,y+h-13],
         [x+8,y+h-13],[x+8,y+h],[x,y+h]]])


def kitaygorod():
    obs=[lamp('west_lamp',119,449,706,45),lamp('middle_lamp',610,440,708,44),
         pipe('bookshop_pipe',641,102,701),pipe('cafe_pipe',1244,112,701),
         pipe('east_pipe',1280,32,705),
         object_('cafe_crate',703,[(837,687,63,16)],[rect(837,656,63,47)]),
         pot('cafe_small_pot',(906,683,15,15),(903,664,21,20)),
         board('cafe_menu',1034,653,40,49),board('cafe_east_menu',1115,652,40,52),
         pot('cafe_box',(1160,644,57,59),(1158,615,63,44)),
         pot('arch_west_tree',(1288,640,67,62),(1274,508,88,136),[rect(1314,599,12,42)]),
         pot('arch_east_tree',(1600,640,69,62),(1581,503,91,142),[rect(1627,599,12,44)])]
    # Left arch leaf is a door plane. The open right half stays unobstructed.
    obs.append(object_('arch_door_leaf',693,[(1367,679,66,14)],[
        [[1367,495],[1433,481],[1433,680],[1367,693]]]))
    return scene('MoscowKitayGorod',692,(517,835),obs,{
        'HotelDoor':anchor(54,738),'ExchangeDoor':anchor(733,738),
        'TransitDoor':anchor(1504,738),'LocalSpot':anchor(975,746),
        'NpcGalina':anchor(787,840),'ExitEast':anchor(1620,852)},[
        sign((186,432,364,43),'КНИГИ','#493b31',size=30),
        sign((836,431,336,36),'СТОЛОВАЯ','#443b31',size=28),
        sign((1437,420,74,27),'МЕТРО','#343933',size=15),
        sign((8,467,65,22),'ОТЕЛЬ','#463a2c',size=12),
        sign((693,469,80,22),'ОБМЕН','#463a2c',size=12),
        sign((1041,661,25,27),'МЕНЮ','#33493d',size=7,object='cafe_menu'),
        sign((1122,660,25,31),'ОБЕД','#33493d',size=7,object='cafe_east_menu')],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def basmanny():
    obs=[pot('repair_pot',(0,658,53,46),(0,599,57,63)),
         pipe('west_downpipe',609,184,703),
         object_('gate_west_pillar',695,[(620,675,69,20)],[rect(620,455,69,240)]),
         object_('gate_east_pillar',695,[(922,675,65,20)],[rect(922,454,65,241)]),
         gate('courtyard_gate',689,461,238,233,23),
         bench('yard_bench',994,625,200,81),
         object_('litter_bin',704,[(1206,685,52,19)],[rect(1206,640,52,62),
             [[1205,626],[1248,622],[1258,630],[1258,639],[1205,639]]]),
         object_('noticeboard',641,[(1274,622,140,19)],[rect(1274,523,140,117),
             rect(1256,511,161,16)]),
         pot('flower_trough',(1304,655,149,48),(1303,641,151,24)),
         object_('east_pier',694,[(1437,677,71,17)],[rect(1437,473,71,220)]),
         gate('east_garden_fence',1499,511,173,183,25),
         object_('birch',694,[(1537,676,60,18)],[
             [[1539,692],[1543,345],[1515,291],[1516,277],[1545,319],[1549,219],
              [1531,163],[1533,124],[1556,186],[1561,60],[1571,45],[1572,185],
              [1594,146],[1600,79],[1608,77],[1602,160],[1571,211],[1567,313],
              [1590,273],[1600,203],[1608,201],[1598,285],[1568,335],[1569,692]]],
             foliage=[rect(1345,0,327,337),rect(1595,386,77,304)],wood_branches=True)]
    # Bush behind the bench is a separate rooted mass; its depth is not the seat.
    obs.append(object_('bench_shrub',694,[(1027,678,146,16)],[],
        foliage=[rect(994,443,216,251)],wood_branches=True))
    return scene('MoscowBasmanny',692,(809,848),obs,{
        'AirportDoor':anchor(460,739),'TransitDoor':anchor(803,742),
        'LocalSpot':anchor(317,741),'NpcArtyom':anchor(1158,835),
        'ExitWest':anchor(51,849)},[
        sign((76,458,280,34),'РЕМОНТ','#453b2e',size=29),
        sign((421,468,88,20),'АЭРОПОРТ','#1f3c4b',size=11),
        sign((751,570,113,30),'МЕТРО','#1f4a3d',size=16,object='courtyard_gate'),
        sign((1290,535,50,77),'РАЙОН\n\nОБЪЯВЛЕНИЯ','#e3dcc4','#35413b',7,object='noticeboard'),
        sign((1350,535,48,77),'СОСЕДЯМ\n\nИНФОРМАЦИЯ','#e6dfca','#35413b',7,object='noticeboard')],
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'AirportDoor':'E — Airport express','TransitDoor':'E — Walk to the metro'})


def arbat():
    obs=[pot('west_tree',(18,620,61,71),(10,453,79,169),[rect(42,568,12,54)]),
         pot('bookshop_pot',(509,641,46,49),(503,562,59,82)),
         pot('tall_cafe_pot',(639,622,58,70),(646,486,45,140),[rect(663,581,10,45)]),
         pot('cafe_pot',(714,647,36,44),(709,587,45,62)),
         pot('cafe_table_plant',(1065,645,33,39),(1052,593,50,55)),
         pot('east_tree',(1607,620,62,71),(1594,474,78,147),[rect(1630,567,14,55)]),
         pipe('west_pipe',580,2,681),pipe('east_pipe',1164,1,681),
         board('cafe_menu',1101,589,74,103),
         object_('postcard_west',673,[(1201,655,83,18)],[rect(1201,483,83,173),
             rect(1207,656,8,17),rect(1268,656,8,17)]),
         object_('postcard_east',673,[(1508,655,83,18)],[rect(1508,491,82,164),
             rect(1514,655,8,18),rect(1575,655,8,18)]),
         object_('book_display',691,[(421,671,74,20)],[rect(448,620,45,62),
             rect(421,621,6,69),rect(451,680,7,11),rect(486,680,7,11)])]
    obs.append(object_('double_lamp',716,[(581,697,39,19)],[
        rect(593,259,15,441),rect(583,631,32,69),rect(579,700,44,16),
        tube((600,282),(570,260),8),tube((570,260),(548,264),8),
        tube((548,264),(540,282),8),tube((604,282),(634,261),8),
        tube((634,261),(655,267),8),tube((655,267),(661,282),8),
        [[525,289],[571,289],[567,306],[560,333],[550,343],[539,334],[530,306]],
        [[629,289],[673,289],[671,306],[662,333],[651,342],[640,333],[633,306]]]))
    for i,x in enumerate([759,997]):
        obs.append(object_('cafe_table_'+str(i),689,[(x,671,125 if i==0 else 93,18)],[
            rect(x+27,626,76 if i==0 else 55,11),rect(x+55,637,7,43),
            rect(x+49,680,20,7),
            tube((x+4,622),(x+1,681),4),tube((x+4,622),(x+10,622),4),
            rect(x+8,641,25,5),rect(x+3,650,31,8),rect(x+4,658,4,30),
            rect(x+29,658,4,30),
            rect(x+43,610,7,16),
            *([tube((x+123,622),(x+117,684),4),rect(x+97,641,26,5),
               rect(x+83,653,35,7),rect(x+83,660,4,28),rect(x+113,660,4,28)] if i==0 else [])]))
    return scene('MoscowArbat',676,(747,839),obs,{
        'TransitDoor':anchor(1340,723),'LocalSpot':anchor(950,737)},[
        sign((75,408,442,40),'КНИГИ','#473b30',size=30),
        sign((749,397,364,35),'КАФЕ','#443a30',size=29),
        sign((1231,428,328,35),'СУВЕНИРЫ · МЕТРО →','#443a30',size=24),
        sign((1110,599,53,73),'КАФЕ\n\nЧАЙ\nКОФЕ','#233537',size=9,object='cafe_menu')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk through to the metro','LocalSpot':'E — Further down Arbat'})


def zamoskvorechye():
    obs=[board('bakery_menu',103,586,75,121),
         pot('bakery_small',(482,658,46,48),(486,597,37,62)),
         pot('bakery_large',(546,645,70,60),(533,541,91,109)),
         pot('gate_pot',(674,649,60,55),(655,541,95,114)),
         pot('east_door_pot',(1188,650,60,56),(1173,564,89,94)),
         pipe('bakery_pipe',626,143,701),pipe('arch_pipe',697,193,698),
         pipe('east_pipe',1151,0,701),
         gate('churchyard_gate',840,469,222,184,27),
         object_('west_door_leaf',694,[(763,674,80,20)],[
             [[763,416],[842,447],[842,660],[763,691]]]),
         object_('east_door_leaf',681,[(1057,661,46,20)],[
             [[1057,436],[1103,414],[1103,680],[1057,654]]]),
         bench('east_bench',1546,629,126,79),
         object_('east_tree',716,[(1438,694,91,22)],[
             [[1452,705],[1455,510],[1434,441],[1400,377],[1402,349],[1413,351],
              [1448,425],[1467,462],[1488,415],[1525,322],[1538,324],[1520,397],
              [1495,469],[1478,519],[1474,705]],rect(1432,703,103,12)],
             foliage=[rect(1207,13,465,426)],wood_branches=True)]
    return scene('MoscowZamoskvorechye',690,(909,841),obs,{
        'TransitDoor':anchor(54,742),'LocalSpot':anchor(945,735)},[
        sign((171,432,355,39),'ПЕКАРНЯ','#493b2e',size=31),
        sign((11,475,76,22),'МЕТРО','#264135',size=13),
        sign((114,602,51,82),'ХЛЕБ\n\nПИРОГИ\nЧАЙ','#223131',size=10,object='bakery_menu')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'LocalSpot':'E — The churchyard gate'})


def izmaylovo():
    obs=[object_('park_bin',703,[(509,685,52,18)],[
             rect(509,638,52,64),[[511,627],[551,622],[561,629],[561,638],[509,638]]]),
         bench('park_bench',626,621,198,82),
         pot('park_planter',(847,666,131,35),(845,627,135,46)),
         object_('park_notices',701,[(934,682,171,19)],[
             rect(935,491,170,152),rect(937,643,9,45),rect(1091,643,14,58)]),
         gate('west_park_fence',467,505,793,190,25),
         gate('east_park_fence',1634,505,38,189,22),
         object_('park_pillar',695,[(1260,675,55,20)],[rect(1260,494,55,201)]),
         object_('park_gate_west',695,[(1315,677,73,18)],[
             rect(1315,459,9,235),rect(1379,501,9,193),
             rect(1322,520,59,7),rect(1322,664,59,7),
             *[rect(x,503,5,164) for x in [1330,1347,1363]]]),
         object_('park_gate_east',695,[(1558,677,81,18)],[
             rect(1629,459,10,235),rect(1558,501,9,193),
             rect(1564,520,66,7),rect(1564,664,66,7),
             *[rect(x,503,5,164) for x in [1574,1592,1610]]])]
    return scene('MoscowIzmaylovo',692,(934,832),obs,{
        'TransitDoor':anchor(387,739),'LocalSpot':anchor(1471,740)},[
        sign((10,430,459,49),'ПРОДУКТЫ','#a73537',size=33),
        sign((340,517,89,22),'МЕТРО','#e7e4cf','#243929',12),
        sign((1420,419,128,35),'ПАРК','#184a40',size=25),
        sign((955,523,57,67),'РАЙОН\n\nНОВОСТИ','#e1dfc7','#33473c',8,object='park_notices'),
        sign((1030,523,45,64),'ПАРК\n\nПЛАН','#e6dfc7','#33473c',8,object='park_notices')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[object_('reception',658,[(386,637,586,21)],[
             rect(381,473,599,22),rect(392,495,574,143),rect(385,638,588,20),
             [[384,435],[399,384],[442,384],[454,435]],rect(413,435,9,37),
             rect(404,468,32,6),oval(489,470,19,8),rect(812,441,59,31),
             [[897,434],[911,385],[951,385],[966,434]],rect(928,434,9,38),
             rect(914,468,36,6)],foliage=[rect(801,365,81,79)],wood_branches=True),
         object_('radiator',656,[(1038,635,168,21)],[
             rect(1038,607,10,43),rect(1196,605,12,49),
             *[rect(x,519,16,109) for x in range(1051,1190,24)],
             rect(1044,528,154,9),rect(1050,605,146,8)]),
         object_('reading_table_plant',699,[(1255,678,134,21)],[
             rect(1255,622,134,18),rect(1258,640,11,49),rect(1374,640,12,58),
             rect(1347,640,10,36),
             [[1292,582],[1347,582],[1347,593],[1340,627],[1297,627]],
             rect(1313,545,12,39)],foliage=[rect(1270,470,98,116)],wood_branches=True),
         object_('reading_chair',699,[(1416,673,168,26)],[
             [[1418,566],[1468,566],[1495,532],[1536,529],[1549,543],
              [1562,590],[1577,595],[1584,607],[1584,678],[1575,692],[1567,692],
              [1566,677],[1468,681],[1467,696],[1455,696],[1454,680],
              [1416,659],[1413,581]]]),
         object_('coat_rack',718,[(1547,699,83,19)],[
             rect(1588,362,10,340),oval(1557,708,11,7),rect(1557,702,64,12),
             tube((1557,708),(1593,687),8),tube((1593,687),(1621,708),8),
             tube((1594,369),(1538,359),9),tube((1538,359),(1530,342),8),
             tube((1594,369),(1563,355),8),tube((1563,355),(1558,342),8),
             tube((1594,369),(1621,356),8),tube((1621,356),(1633,340),8),
             [[1570,369],[1557,382],[1549,420],[1550,551],[1619,557],
              [1610,405],[1602,375]]])]
    return scene('MoscowHotel',643,(1002,825),obs,
        {'Point':anchor(679,706),'Exit':anchor(241,695)},[
        sign((471,195,440,60),'ГОСТИНИЦА','#67452c',size=33),
        sign((1034,278,160,36),'МОСКВА','#e8e0c5','#352d27',25)],
        clerks={'Point':anchor(671,559)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('exchange_counter',659,[(494,636,575,23)],[
             rect(486,478,591,20),rect(494,498,575,160),
             rect(512,422,58,56),rect(625,416,90,61),rect(944,416,87,61),
             rect(846,451,46,27)],glass=[rect(508,266,543,149)]),
         pot('waiting_plant',(1437,593,76,74),(1424,419,106,173),[rect(1467,551,10,42)])]
    for i,x in enumerate([1156,1276]):
        obs.append(object_('waiting_chair_'+str(i),672,[(x+3,655,104,17)],[
             [[x+16,524],[x+89,524],[x+100,534],[x+100,584],[x+93,593],
              [x+10,593],[x+7,584],[x+7,534]],
             rect(x+5,607,100,21),rect(x+16,593,7,14),rect(x+87,593,7,14),
             rect(x+5,628,8,43),rect(x+96,628,8,43)]))
    xs=[408,586,768,955]
    for i,x in enumerate(xs):
        obs.append(object_('queue_post_'+str(i),758,[(x-29,739,58,19)],[
             oval(x,603,10,13),rect(x-8,610,16,131),
             [[x-8,737],[x+8,737],[x+28,744],[x+31,755],[x-30,755],[x-28,744]]]))
    obs.append(object_('queue_belt',756,[(418,739,527,17)],[rect(417,604,528,12)]))
    return scene('MoscowExchange',656,(1055,828),obs,
        {'Point':anchor(801,801),'Exit':anchor(201,706)},[
        sign((508,157,541,86),'ОБМЕН ВАЛЮТЫ','#1c3556',size=38),
        sign((1116,154,312,200),'ОБМЕН\n\nUSD · EUR\nRUB · CNY','#1c3556','#e8dbaa',27),
        sign((344,352,88,117),'ОБМЕН\n\nДОКУМЕНТЫ\nИ КВИТАНЦИИ','#e1dfc8','#30423d',9)],
        clerks={'Point':anchor(790,563)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[object_('map_board',632,[(58,615,138,17)],[rect(63,268,130,349),rect(58,616,138,16)]),
         object_('west_column',677,[(242,645,151,32)],[rect(244,33,147,610),
             rect(239,21,155,12),rect(241,641,153,35)]),
         object_('east_column',677,[(1249,645,136,32)],[rect(1252,33,132,610),
             rect(1248,20,140,13),rect(1247,641,141,35)]),
         object_('platform_bench',778,[(528,756,410,22)],[
             [[537,704],[931,704],[939,711],[939,724],[528,724],[528,713]],
             rect(531,724,15,53),rect(728,724,15,53),rect(922,724,15,53),
             tube((546,735),(561,735),5),tube((561,735),(546,752),5),
             tube((747,736),(759,732),5),tube((759,732),(747,749),5),
             tube((907,734),(922,752),5)]),
         object_('station_bin',773,[(1123,750,83,23)],[rect(1127,663,77,95),
             rect(1123,758,83,15),rect(1127,636,75,14),rect(1132,650,8,13),
             rect(1190,650,9,13),[[1127,637],[1135,631],[1159,631],[1165,626],
              [1183,630],[1202,634],[1204,641]]]),
         object_('escalator_side_left',597,[(1394,581,40,16)],[
             [[1394,590],[1468,309],[1488,309],[1429,590]]]),
         object_('escalator_divider',597,[(1528,581,38,16)],[
             [[1528,596],[1598,310],[1613,310],[1566,597]]]),
         object_('escalator_side_right',597,[(1634,581,16,16)],[rect(1634,309,16,288)])]
    # Existing machine remains a native fixture with its own compact footprint.
    at=point(1481,762)
    ticket=object_('ticket_machine',762,[(1450,744,62,18)],[])
    obs.append(ticket)
    return scene('MoscowTransit',597,(1001,864),obs,
        {'Machine':anchor(1481,805),'Platform':anchor(1080,618),'Exit':anchor(1510,644)},[
        sign((642,195,365,53),'ТЕАТРАЛЬНАЯ','#c5b79b','#172e3c',32),
        sign((1486,240,148,38),'ВЫХОД ↑','#25333d',size=23)],
        interaction_sizes=sizes('Machine','Platform','Exit'),
        fittings=[dict(kind='ticket',at=at)],
        animation_patches=[
            dict(kind='escalator',rect=[*point(1460,349),*point(58,226)],direction=1),
            dict(kind='escalator',rect=[*point(1596,349),*point(40,226)],direction=-1)])


def airport():
    obs=[object_('gate_plant',690,[(22,673,47,17)],[
             [[22,627],[66,627],[69,644],[66,688],[26,688]]],
             foliage=[rect(28,600,37,29)]),
         pot('column_tree',(787,601,67,68),(780,467,79,135),[rect(815,566,10,38)]),
         object_('structural_column',690,[(866,660,148,30)],[rect(866,64,148,625)]),
         object_('bin',663,[(1410,641,63,22)],[rect(1413,573,57,81),
             rect(1410,654,10,9),rect(1462,654,10,9),rect(1411,557,62,13),
             rect(1414,569,8,6),rect(1460,569,8,6)]),
         object_('vending_machine',669,[(1500,645,108,24)],[rect(1500,453,108,215)])]
    for prefix,x,w in [('west',449,276),('east',1056,335),('edge',1623,49)]:
        polys=[rect(x,611,w,24),tube((x+7,635),(x+3,660),7),
               tube((x+w-8,635),(x+w-3,660),7),rect(x+5,637,w-10,8)]
        for sx in range(x+7,x+w-40,66):
            polys += [[[sx+6,550],[sx+53,550],[sx+60,557],[sx+60,604],
                       [sx+55,611],[sx,611],[sx,559]],
                      rect(sx+5,604,52,7)]
        if w<60: polys.append(rect(x+5,550,w-5,63))
        obs.append(object_(prefix+'_seats',663,[(x,645,w,18)],polys))
    for i,x in enumerate([290,348]):
        obs.append(object_('cart_'+str(i),663,[(x-3,647,51,16)],[
            rect(x-2,557,6,88),rect(x+42,557,6,88),rect(x,552,48,7),
            rect(x+5,565,34,50),rect(x+4,615,6,31),rect(x+38,615,6,31),
            rect(x,642,46,7),oval(x+3,654,8,8),oval(x+42,654,8,8),
            rect(x+8,546,10,7),rect(x+27,546,10,7)]))
    return scene('MoscowAirport',656,(1078,835),obs,
        {'Point':anchor(934,738),'Exit':anchor(151,704)},[
        sign((1048,133,559,68),'ВЫЛЕТЫ','#193044',size=39),
        sign((1061,218,541,176),'МОСКВА\n\nБЕРЛИН · СТАМБУЛ\nПАРИЖ · РИМ','#193044','#ead26c',24),
        sign((910,488,51,42),'БИЛЕТЫ','#73828e','#172735',9,object='structural_column'),
        sign((76,374,143,65),'ВЫХОД','#183249',size=26)],
        clerks={},interaction_sizes=sizes('Point','Exit'),
        prompt_overrides={'Point':'E — Airport check-in terminal'},
        motion_layers=[dict(kind='doors',rect=[*point(81,464),*point(141,189)])])


def build():
    from .moscow_finish import finish
    return finish({'MoscowKitayGorod':kitaygorod(),'MoscowBasmanny':basmanny(),
            'MoscowArbat':arbat(),'MoscowZamoskvorechye':zamoskvorechye(),
            'MoscowIzmaylovo':izmaylovo(),'MoscowHotel':hotel(),
            'MoscowExchange':exchange(),'MoscowTransit':transit(),'MoscowAirport':airport()})
