"""Mexico City: measured whole objects, separate ground contact and open gaps."""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, tube, object_, sign
from .london import scene
from .moscow import pot, oval, board, bench
from .paris import lamp, bollard
from .hanoi import pole, route_post
from .tokyo import wheel
from .seoul import box
from .rome import sizes
from .honolulu import metal_seats


def cafe_table(name,x,y,w=68,h=70,umbrella=None):
    polys=[rect(x,y,w,10),rect(x+w/2-4,y+10,8,h-16),
           rect(x+w/2-18,y+h-6,36,6)]
    if umbrella:
        ux,uy,uw,uh=umbrella
        polys += [[[ux,uy+uh],[ux+uw*.48,uy],[ux+uw*.53,uy],
                    [ux+uw,uy+uh],[ux+uw,uy+uh+6],[ux,uy+uh+6]],
                  rect(ux+uw/2-4,uy+uh,8,y+h-uy-uh)]
    return object_(name,y+h,[(x+w/2-21,y+h-15,42,15)],polys)


def cafe_chair(name,x,y,w=44,h=73,flip=False):
    # Separate back, seat and legs; no copied floor between them.
    polys=[rect(x+(w-12 if flip else 0),y,12,45),rect(x,y+40,w,8),
           tube((x+7,y+47),(x+2,y+h),6),
           tube((x+w-7,y+47),(x+w-2,y+h),6)]
    return object_(name,y+h,[(x,y+h-12,w,12)],polys)


def plain_tree(name,base,crown,trunk,blossoms=False):
    x,y,w,h=base
    return object_(name,y+h,[base],[trunk],foliage=[rect(*crown)],
                   wood_branches=True,pink_blossoms=blossoms)


def rail(name,x,y,w,h,spacing=26):
    polys=[rect(x,y+22,w,6),rect(x,y+h-26,w,6)]
    for xx in range(x,x+w,spacing):
        polys += [rect(xx,y+6,6,h-6),oval(xx+3,y+5,4,5)]
    return object_(name,y+h,[(x,y+h-12,w,12)],polys)


def merced():
    obs=[lamp('market_lamp',326,333,724,45),
         bollard('west_bollard',134,679,738,20),bollard('east_bollard',1590,679,738,19)]
    for i,x in enumerate([14,236]):
        obs.append(pot('lodging_pot_'+str(i),(x,647,30,31),(x-8,564,43,85)))
    obs += [object_('blue_handcart',713,[(1096,694,86,19)],[
                rect(1098,597,84,95),rect(1094,609,7,73),
                oval(1120,701,12,12),oval(1168,701,12,12)]),
            object_('green_handcart',713,[(1281,692,90,21)],[
                rect(1293,590,65,95),rect(1281,578,8,111),rect(1359,578,9,104),
                rect(1287,578,75,8),rect(1284,682,91,11),
                oval(1307,701,13,13),oval(1353,701,13,13)]),
            object_('central_market_goods',677,[(626,650,417,27)],[
                [[625,676],[625,497],[647,494],[660,499],[678,496],[696,529],
                 [732,538],[744,571],[755,578],[781,542],[797,552],[813,535],
                 [836,554],[855,566],[870,610],[909,610],[909,533],[929,527],
                 [934,497],[953,483],[975,488],[992,479],[1005,491],[1025,490],
                 [1044,503],[1045,674]]]),
            object_('east_produce',677,[(1395,652,267,25)],[
                [[1395,675],[1395,550],[1414,554],[1429,560],[1443,545],
                 [1461,555],[1478,572],[1494,558],[1518,564],[1534,556],
                 [1552,565],[1573,552],[1599,558],[1616,570],[1645,560],
                 [1658,577],[1659,676]]])]
    return scene('MexicoMerced',650,(731,828),obs,{
        'HotelDoor':anchor(184,715),'ExchangeDoor':anchor(456,715),
        'TransitDoor':anchor(1225,733),'LocalSpot':anchor(830,731),
        'NpcPilar':anchor(654,820),'ExitEast':anchor(1609,819)},[
        sign((705,215,268,59),'MERCADO LA MERCED','#00000000','#443b32',size=23),
        sign((21,417,230,41),'HOTEL','#00000000','#463c34',size=29),
        sign((378,418,149,30),'CAMBIO','#00000000','#343e40',size=22),
        sign((1154,414,144,34),'METRO','#00000000','#332d28',size=22),
        sign((1398,417,257,42),'FRUTAS Y VERDURAS','#00000000','#463c34',size=23),
        sign((497,519,36,80),'USD\nEUR\nCAD\nMXN','#1d3549','#e8db9e',size=7),
        sign((753,475,58,21),'CHILES','#bda354','#40382c',size=8),
        sign((827,475,61,21),'SEMILLAS','#bda354','#40382c',size=8)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def juarez():
    obs=[pot('west_tree_pot',(13,649,58,61),(0,292,177,356),[
        [[31,650],[31,543],[7,515],[7,504],[39,529],[47,448],
         [59,448],[54,522],[105,471],[115,477],[57,544],[54,650]]]),
        pot('cafe_little_pot',(217,691,32,36),(210,646,48,47)),
        pot('workshop_west_pot',(814,649,59,62),(799,524,82,127),[rect(835,591,11,60)]),
        pot('workshop_east_pot',(1166,649,51,62),(1155,518,75,135),[rect(1184,580,10,72)]),
        pot('bookshop_planter',(1526,684,66,40),(1510,628,92,59)),
        board('cafe_menu',94,614,90,113),pole('cafe_post',787,510,708,14),
        bollard('workshop_bollard',1106,593,695,13),
        plain_tree('east_tree',(1630,703,42,21),(1542,342,130,210),
                   [[1631,723],[1643,561],[1607,525],[1595,496],[1602,488],
                    [1625,519],[1652,540],[1656,485],[1671,485],[1672,720]])]
    obs += [cafe_table('west_table',300,646),
            cafe_chair('west_left_chair',277,647,40,65),
            cafe_chair('west_right_chair',347,638,44,75,True),
            cafe_table('umbrella_table',647,646,68,75,(570,514,199,45)),
            cafe_table('middle_table',584,646,46,75),
            cafe_chair('middle_chair',554,637,51,84),
            cafe_chair('east_chair',696,638,50,84,True)]
    bicycle=[*wheel(954,660,33),*wheel(1051,660,32)]
    for a,b,w in [((954,659),(976,613),4),((976,613),(1030,613),4),
                   ((1030,613),(997,659),4),((997,659),(954,659),4),
                   ((976,613),(997,659),4),((1028,604),(1051,659),4),
                   ((1029,606),(1038,600),4),((1025,598),(1040,598),5),
                   ((974,617),(971,603),5),((965,601),(987,601),5)]:
        bicycle.append(tube(a,b,w))
    obs.append(object_('workshop_bicycle',693,[(921,680,163,13)],bicycle))
    fittings=[]
    for name,x,text in [('metro_post',1500,'METRO'),('airport_post',917,'BUS\nAEROPUERTO')]:
        obj,fixture=route_post(name,x,740,text);obs.append(obj);fittings.append(fixture)
    return scene('MexicoJuarez',665,(1223,828),obs,{
        'TransitDoor':anchor(1432,766),'AirportDoor':anchor(931,799),
        'LocalSpot':anchor(473,772),'NpcChuy':anchor(782,816),
        'ExitWest':anchor(48,816)},[
        sign((206,451,440,37),'CAFÉ JUÁREZ','#00000000',size=29),
        sign((1256,440,280,42),'LIBRERÍA','#00000000',size=30),
        sign((931,459,177,27),'TALLER','#00000000',size=22),
        sign((109,632,56,67),'CAFÉ\nTÉ\nPAN','#183640',size=10,object='cafe_menu')],
        fittings=fittings,interaction_sizes=sizes('TransitDoor','AirportDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro','AirportDoor':'E — Airport bus'})


def coyoacan():
    obs=[plain_tree('west_tree',(0,645,43,26),(0,0,387,332),
                  [[0,669],[14,488],[52,367],[22,297],[0,269],[0,245],[40,291],
                   [64,341],[91,268],[88,231],[100,222],[109,277],[82,372],
                   [47,487],[34,647],[42,669]]),
         pot('west_pot',(62,624,50,53),(44,540,83,85)),
         pot('blue_door_pot',(318,614,50,55),(305,548,80,70)),
         pot('middle_pot',(579,621,52,54),(570,552,67,72)),
         pot('gate_tree_pot',(923,610,49,61),(909,445,81,170),[rect(943,522,10,89)]),
         pot('east_little_pot',(1237,653,54,23),(1230,621,68,35)),
         pot('cafe_pot',(1461,611,50,60),(1442,501,86,113)),
         box('west_bin',200,611,48,67),box('wooden_bin',685,603,48,70),
         lamp('middle_lamp',898,326,730,46),lamp('east_lamp',1371,304,730,47),
         board('cafe_board',1526,594,104,135),
         rail('courtyard_gate',1023,466,178,171,24)]
    obs += [bollard('bollard_'+str(i),x,685,738,17) for i,x in enumerate([64,529,1067])]
    # The tall bougainvillea grows from the wall; it does not acquire a
    # foreground footprint that would block the open pavement below it.
    fittings=[]
    obj,fixture=route_post('metro_direction',1137,726,'METRO')
    obs.append(obj);fittings.append(fixture)
    return scene('MexicoCoyoacan',646,(779,817),obs,{
        'TransitDoor':anchor(1150,782),'LocalSpot':anchor(433,716)},[
        sign((1541,609,75,94),'CAFÉ','#223540',size=22,object='cafe_board')],
        fittings=fittings,interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro'})


def roma():
    obs=[lamp('west_lamp',67,295,735,45),lamp('east_lamp',1652,285,705,43),
         board('bookshop_board',276,578,89,116),
         pot('bookshop_pot',(530,673,73,47),(521,613,86,65)),
         pot('arch_pot',(771,626,61,39),(775,591,52,38)),
         pot('gate_planter',(1185,574,66,96),(1154,321,186,255),[
             [[1212,575],[1213,498],[1187,468],[1194,460],[1221,486],
              [1223,425],[1233,425],[1233,478],[1266,435],[1274,440],
              [1240,489],[1232,575]]]),
         pot('station_flowers',(1335,615,133,38),(1325,555,163,65)),
         bollard('front_bollard',1310,673,735,19),
         plain_tree('jacaranda',(861,682,86,25),(581,0,660,461),
                    [[847,435],[865,454],[868,635],[863,675],[845,703],[880,709],
                     [942,708],[951,699],[934,664],[932,524],[941,450],[962,423],
                     [944,413],[922,441],[890,458],[869,434]],True),
         plain_tree('west_tree',(0,673,40,23),(0,111,101,261),
                    [[0,695],[7,450],[0,404],[0,376],[18,422],[37,368],[44,370],
                     [29,448],[25,636],[39,695]],True),
         rail('garden_west_rail',801,499,76,101,25),
         rail('garden_middle_rail',932,499,91,101,25),
         rail('garden_gate',1024,432,84,222,21),
         rail('garden_east_rail',1248,491,90,106,25)]
    # The subway stair opening stays unobstructed. Rails occupy only the
    # back/side edges, never the entire rectangle in front of the entrance.
    obs += [rail('station_rear_rail',1357,431,76,141,23),
            rail('station_front_rail',1478,507,178,187,27),
            box('station_small_notice',1498,635,97,62),
            object_('station_sign_frame',701,[(1474,684,24,17),(1645,684,25,17)],[
                rect(1476,471,13,222),rect(1648,471,13,222),rect(1494,476,145,65)])]
    return scene('MexicoRoma',646,(741,827),obs,{
        'TransitDoor':anchor(1555,761),'LocalSpot':anchor(702,719)},[
        sign((340,425,243,37),'LIBRERÍA','#00000000',size=28),
        sign((290,591,62,77),'LIBROS\nUSADOS','#293535',size=10,object='bookshop_board'),
        sign((1501,485,132,50),'METRO','#243747',size=26,object='station_sign_frame'),
        sign((1506,642,78,42),'ENTRADA','#dfd9c8','#343b3e',size=11,object='station_small_notice')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def condesa():
    obs=[board('cafe_menu',87,571,90,115),
         pot('west_box',(0,621,40,44),(0,574,42,51)),
         pot('cafe_tree',(168,609,36,56),(133,467,76,145),[rect(175,542,11,69)]),
         pot('door_tree',(710,617,61,55),(690,508,95,114)),
         pot('gate_pot',(1310,609,40,49),(1284,555,80,58)),
         box('cafe_bin',362,602,49,77),box('park_bin',1125,598,48,68),
         lamp('cafe_lamp',865,170,710,46),lamp('park_east_lamp',1398,314,711,34),
         bench('park_bench',1449,641,154,72),
         rail('west_park_fence',781,420,259,184,27),
         rail('east_park_fence',1412,419,260,221,26),
         object_('park_gate_posts',658,[(1044,640,34,18),(1360,640,32,18)],[
             rect(1044,311,28,340),rect(1360,311,30,340),rect(1119,331,240,99),
             tube((1070,356),(1119,332),5),tube((1359,342),(1382,360),5)]),
         box('west_gate_stone',1066,548,53,122),box('east_gate_stone',1354,548,29,122),
         box('west_park_wall',776,598,294,76),
         cafe_table('west_cafe_table',252,615,68,72,(199,460,194,49)),
         cafe_table('east_cafe_table',594,615,68,72,(521,471,199,41)),
         cafe_chair('west_cafe_left',212,605,52,82),cafe_chair('west_cafe_right',304,605,45,82,True),
         cafe_chair('east_cafe_left',558,605,51,82),cafe_chair('east_cafe_right',649,605,50,82,True)]
    for i,x in enumerate([944,997,1050]):
        polys=[rect(x,644,8,65),rect(x+26,644,8,65)]
        top=[(x,644),(x+1,636),(x+5,631),(x+10,627),(x+18,627),(x+27,633),(x+33,644)]
        polys += [tube(a,b,8) for a,b in zip(top,top[1:])]
        obs.append(object_('bike_rack_'+str(i),709,[(x-1,695,36,14)],polys))
    # A native travel direction is beside the gate, away from the activity.
    obj,fixture=route_post('metro_direction',1588,768,'METRO')
    obs.append(obj)
    return scene('MexicoCondesa',640,(916,828),obs,{
        'TransitDoor':anchor(1544,819),'LocalSpot':anchor(1213,717)},[
        sign((255,382,398,48),'CAFÉ CONDESA','#00000000',size=30),
        sign((1140,348,199,64),'PARQUE\nMÉXICO','#00000000',size=26,object='park_gate_posts'),
        sign((108,588,48,77),'CAFÉ\nTÉ\nPAN','#23343b',size=10,object='cafe_menu')],
        fittings=[fixture],interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro'})


def hotel():
    obs=[pot('west_door_pot',(21,461,63,63),(0,316,115,147),[rect(43,415,14,48)]),
         pot('east_door_pot',(414,461,62,63),(390,317,111,146),[rect(438,406,13,57)]),
         pot('desk_pot',(1564,461,63,63),(1534,350,119,113)),
         pot('floor_pot',(627,745,38,36),(601,667,88,81)),
         object_('reception',527,[(1052,509,489,18)],[
             rect(1048,415,499,17),rect(1054,432,488,95),
             rect(1426,371,58,44),rect(1436,409,39,9),rect(1080,397,36,22)],
             foliage=[rect(1050,339,87,59)]),
         box('front_counter',1115,608,415,128),
         object_('luggage_trolley',848,[(351,826,130,22)],[
             rect(351,816,130,12),oval(373,837,11,11),oval(459,837,11,11),
             rect(358,733,60,84),rect(426,746,37,71),
             rect(376,724,27,6),rect(376,729,5,7),rect(399,729,5,7),
             rect(436,739,18,6),rect(436,744,4,5),rect(450,744,4,5),
             rect(364,681,8,135),rect(462,681,8,135),
             tube((368,682),(394,646),8),tube((394,646),(416,632),8),
             tube((421,632),(444,650),8),tube((444,650),(466,682),8),
             rect(411,613,13,35),oval(417,613,6,5)])]
    for i,x in enumerate([138,204,271]):
        obs.append(object_('lobby_chair_'+str(i),784,[(x,769,62,15)],[
            rect(x+7,678,49,37),rect(x,714,61,33),rect(x,747,8,36),rect(x+54,747,8,36)]))
    # The inner garden is architecture behind the lobby; its fountain water
    # moves locally without shifting the stone rim, plants or lobby floor.
    return scene('MexicoHotel',502,(825,818),obs,{
        'Exit':anchor(244,568),'Point':anchor(1309,576)},[
        sign((172,209,151,53),'HOTEL','#00000000','#e9cd87',size=30),
        sign((1155,453,288,44),'RECEPCIÓN','#00000000','#dfc27e',size=25,object='reception')],
        clerks={'Point':anchor(1321,444)},interaction_sizes=sizes('Exit','Point'),
        animation_patches=[dict(kind='water',rect=[*point(746,424),*point(100,8)])])


def exchange():
    obs=[pot('west_plant',(33,530,62,50),(13,451,98,82)),
         box('brochure_rack',1464,320,181,262),
         box('east_terminal',1224,399,70,182),
         object_('service_counter',570,[(541,549,577,21)],[
             rect(540,438,579,17),rect(543,454,570,116),
             rect(579,379,66,57),rect(880,398,67,39),rect(989,344,101,93)]),
         object_('security_glass',567,[(554,550,553,17)],[
             rect(554,230,553,5),rect(698,231,6,206),rect(842,232,5,205),
             rect(992,232,5,205)],
             glass=[rect(559,236,139,200),rect(704,236,138,200),
                    rect(847,236,145,200),rect(997,236,108,200)]),
         object_('queue_terminal',569,[(467,549,57,20)],[
             rect(472,362,69,77),rect(465,439,62,130)])]
    # Belts are continuous barriers at ground level, but their empty visual
    # gaps remain transparent; the service entrance is to the RIGHT.
    bars=[]
    for x in [184,335,516,724]:
        bars += [rect(x-9,446,19,155),oval(x,608,30,11)]
    bars += [rect(194,457,312,12),rect(526,474,188,12)]
    obs.append(object_('queue_belts',619,[(155,599,599,20)],bars))
    return scene('MexicoExchange',549,(908,782),obs,{
        'Exit':anchor(1372,610),'Point':anchor(947,629)},[
        sign((572,135,515,56),'CASA DE CAMBIO','#00000000','#263445',size=38),
        sign((110,177,301,230),'TIPO DE CAMBIO\n\nUSD     COMPRA / VENTA\nEUR     COMPRA / VENTA\nCAD     COMPRA / VENTA',
             '#172b3b','#e8d09a',size=22),
        sign((484,380,42,42),'TURNO','#e6e0c6','#2e4048',size=9,object='queue_terminal')],
        clerks={'Point':anchor(775,467)},interaction_sizes=sizes('Exit','Point'))


def transit():
    obs=[box('west_column',58,0,91,541),box('east_column',1480,0,83,534),
         box('newspaper_box',518,500,113,148),box('platform_bin',1476,468,77,104),
         box('information_stand',1320,360,87,212)]
    for i,x in enumerate([29,128,227,327]):
        obs.append(object_('platform_seat_'+str(i),791,[(x,775,97,16)],[
            rect(x+2,650,84,56),rect(x+1,714,88,31),
            rect(x,704,9,70),rect(x+85,704,9,70),
            rect(x,773,11,17),rect(x+85,773,11,17)]))
    return scene('MexicoTransit',513,(887,808),obs,{
        'Exit':anchor(1620,593),'Platform':anchor(719,573),'Machine':anchor(1204,733)},[
        sign((193,111,130,94),'M','#e85c18',size=66),
        sign((352,114,180,97),'CDMX','#00000000',size=39),
        sign((573,111,367,98),'DIRECCIÓN\nUNIVERSIDAD  →','#00000000',size=32),
        sign((1070,111,360,94),'LÍNEA 3\nINDIOS VERDES · UNIVERSIDAD','#00000000','#31433c',size=21),
        sign((1334,387,56,150),'RED\nMETRO\n\nLÍNEAS\n1 · 2 · 3\n5 · 8 · 9','#e6e2d0','#294352',size=9,object='information_stand')],
        fittings=[dict(kind='ticket',at=point(1205,686))],clerks={},
        interaction_sizes=sizes('Exit','Platform','Machine'),
        motion_layers=[dict(kind='doors',rect=[*point(601,329),*point(234,169)])])


def airport():
    obs=[pot('west_plant',(27,602,78,83),(8,468,135,137)),
         pot('front_plant',(307,700,67,64),(284,598,108,109)),
         box('left_suitcase',136,638,49,87),
         object_('information_counter',749,[(411,727,529,22)],[rect(410,613,530,136)]),
         metal_seats('west_seats',177,499,7,w=55,h=88,back=43,seat=47,seat_h=12),
         metal_seats('east_seats',994,499,3,w=57,h=88,back=43,seat=47,seat_h=12),
         object_('baggage_carousel',743,[(1113,690,559,53),(1082,672,64,43)],[
             [[1078,647],[1096,626],[1134,614],[1190,606],[1672,606],
              [1672,743],[1159,743],[1114,733],[1090,717],[1078,695]],
             rect(1195,581,49,82),rect(1207,576,19,6),
             rect(1285,558,28,49),rect(1294,551,11,9),
             rect(1341,542,90,64),rect(1368,532,25,10),
             rect(1466,560,56,46),rect(1481,552,24,9),
             rect(1269,620,78,53),rect(1288,612,30,8),
             rect(1468,627,60,45),rect(1486,619,24,9)])]
    return scene('MexicoAirport',550,(807,837),obs,{
        'Exit':anchor(173,817),'Point':anchor(673,797)},[
        sign((93,105,446,106),'← LLEGADAS\nArrivals','#00000000',size=39),
        sign((598,105,434,106),'SALIDAS ↑\nDepartures','#00000000',size=37),
        sign((1092,105,485,106),'EQUIPAJE →\nBaggage','#00000000',size=39),
        sign((465,645,425,73),'INFORMACIÓN\nInformation','#00000000','#225994',size=29,object='information_counter'),
        sign((1240,284,375,150),'SALIDAS\n\nOAXACA       12:20\nGUADALAJARA 13:10\nMONTERREY    14:00\nMÉRIDA       15:30',
             '#152330','#f1d15b',size=18)],
        clerks={'Point':anchor(684,645)},interaction_sizes=sizes('Exit','Point'),
        animation_patches=[dict(kind='conveyor',rect=[*point(1360,627),*point(90,28)])])


def build():
    rows={}
    for suffix,fn in [('Merced',merced),('Juarez',juarez),('Coyoacan',coyoacan),
                      ('Roma',roma),('Condesa',condesa),('Hotel',hotel),
                      ('Exchange',exchange),('Transit',transit),('Airport',airport)]:
        key='Mexico'+suffix
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        if not file.exists(): continue
        row=fn()
        row.update(source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],
                   implementation_stage='replacement_art_and_geometry',art_pending=False,
                   signs=[],room_numbers=[],cats=[])
        rows[key]=row
    return rows
