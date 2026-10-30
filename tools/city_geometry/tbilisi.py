"""Tbilisi: complete source-measured silhouettes, feet-level footprints and native signs.

The source canvas is 1672x941. Collision is ground contact, never image bounds.
Furniture gaps remain transparent; plants include both pots and entire crowns.
"""
from .shapes import anchor, point, object_, rect, tube, sign as base_sign
from .london import scene
from .rome import plant, sizes

FONT='res://art/fonts/NotoSansGeorgian.ttf'


def sign(bounds,text,background,ink='#f1eddf',size=18,**extra):
    if any('\u10a0' <= c <= '\u10ff' for c in text):
        extra['font']=FONT
    return base_sign(bounds,text,background,ink,size,**extra)


def bollard(name,x,top,bottom):
    return object_(name,bottom,[(x-14,bottom-13,28,13)],[
        [[x-14,bottom],[x+14,bottom],[x+14,bottom-9],[x+7,bottom-15],
         [x+7,top+10],[x+5,top],[x-5,top],[x-8,top+10],
         [x-8,bottom-15],[x-14,bottom-9]]])


def chair(name,x,y,w,h):
    # Individual back slats, side uprights, seat and legs rather than a rectangle.
    return object_(name,y+h,[(x,y+h-16,w,16)],[
        rect(x+5,y,w-10,9),rect(x+6,y+16,w-12,9),
        rect(x+5,y+30,w-10,8),rect(x+2,y,6,h-10),rect(x+w-8,y,6,h-10),
        rect(x,y+h-35,w,9),rect(x+4,y+h-26,7,26),rect(x+w-11,y+h-26,7,26)])


def rail(name,x,y,w,h):
    polys=[rect(x,y+12,w,7),rect(x,y+h-30,w,6)]
    for px in range(x,x+w,24):
        polys.append(rect(px,y,6,h))
    return object_(name,y+h,[(x,y+h-13,w,13)],polys)


def sololaki():
    obs=[object_('west_bin',734,[(0,713,50,21)],[rect(0,630,50,102)]),
         object_('pension_crate',702,[(384,685,63,17)],[rect(384,646,63,56)]),
         bollard('pension_bollard',457,650,752),
         bollard('bookshop_bollard',1012,664,751),
         object_('arch_drainpipe',708,[(879,691,27,17)],[rect(883,439,14,260),rect(879,694,27,14)]),
         plant('arch_small_pot',(482,665,49,45),(480,624,58,46)),
         plant('arch_citrus',(545,671,38,39),(520,548,93,123),[rect(560,627,10,46)]),
         chair('courtyard_chair',916,626,56,88),
         object_('bench',711,[(1144,695,151,16)],[
             rect(1144,665,151,12),rect(1152,677,9,34),rect(1277,677,9,34)]),
         plant('east_pot',(1303,664,59,47),(1292,575,82,93)),
         object_('east_lamp',752,[(1390,735,38,17)],[
             rect(1399,20,18,721),rect(1390,740,38,12)])]
    # Open arch leaves: the arch itself remains a real, clear approach.
    obs.append(object_('arch_gate',700,[(626,687,53,13)],[
        rect(626,477,8,219),rect(672,477,7,219),rect(630,495,43,6),
        rect(630,576,43,7),rect(630,662,43,7),
        *[rect(x,498,4,191) for x in [641,653,663]]]))
    return scene('TbilisiSololaki',697,(800,840),obs,{
        'HotelDoor':anchor(250,744),'ExchangeDoor':anchor(1077,745),
        'TransitDoor':anchor(743,745),'LocalSpot':anchor(1546,750),
        'NpcZurab':anchor(986,842),'ExitEast':anchor(1625,860)},[
        sign((205,419,255,49),'სასტუმრო','#8c3f30',size=29),
        sign((1044,429,242,52),'ვალუტა','#d1b881','#26392e',29),
        sign((689,423,111,28),'მეტრო','#1c403b',size=14)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro','LocalSpot':'E — The open hallway'})


def chugureti():
    obs=[plant('bakery_pot',(27,701,69,49),(22,613,74,92)),
         object_('bread_crate',741,[(115,724,112,17)],[rect(115,696,112,45)]),
         object_('bakery_board',751,[(388,736,74,15)],[
             [[393,634],[453,634],[462,750],[454,750],[451,732],[398,732],
              [395,750],[386,750]]]),
         chair('passage_chair',936,657,52,94),
         object_('tailor_chest',746,[(1164,726,146,20)],[rect(1164,680,146,66)]),
         plant('tailor_pot',(1339,704,52,47),(1331,641,65,64)),
         bollard('east_bollard',1426,701,795),
         object_('utility_box',738,[(1636,724,36,14)],[rect(1636,623,36,113)])]
    for name,x,w in [('left',579,97),('right',812,109)]:
        obs.append(object_('passage_leaf_'+name,736,[(x,722,w,14)],[
            rect(x,496,w,238),rect(x,430,8,66),rect(x+w-9,426,9,70),
            rect(x,428,w,8),rect(x+8,481,w-17,7),
            *[tube((xx,433),(xx,481),4) for xx in range(x+16,x+w-8,15)]]))
    return scene('TbilisiChugureti',734,(799,868),obs,{
        'TransitDoor':anchor(1500,780),'LocalSpot':anchor(744,784)},[
        sign((89,405,341,65),'პური','#d2b689','#3c3828',39),
        sign((1008,425,311,49),'სამკერვალო','#447273',size=27),
        sign((401,647,46,75),'პური\nBREAD','#293f35',size=8,object='bakery_board'),
        sign((1449,515,112,25),'მეტრო →','#294940',size=12)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro','LocalSpot':'E — Through the courtyard'})


def avlabari():
    obs=[plant('west_tree',(0,739,61,48),(0,337,119,190),[
             rect(20,513,14,233),tube((27,554),(59,516),10)]),
         plant('west_shrub',(0,739,61,48),(0,675,75,73)),
         plant('book_flowers',(201,747,71,35),(202,721,70,29)),
         plant('book_pot',(441,750,38,32),(437,718,47,35)),
         plant('door_pot',(492,743,61,44),(491,671,66,75)),
         plant('wall_pot',(778,748,68,40),(776,714,75,39)),
         plant('east_long_pot',(1236,748,94,40),(1234,726,97,27)),
         bollard('stair_bollard',1573,757,826)]
    # Closed domestic courtyard gate; opaque lower panels, separated upper ironwork.
    obs.append(object_('garden_gate',784,[(999,769,170,15)],[
        rect(999,583,170,200),rect(999,525,8,58),rect(1161,525,8,58),
        tube((1003,530),(1084,507),7),tube((1084,507),(1165,530),7),
        rect(1000,572,166,7),*[rect(x,527,5,48) for x in range(1016,1160,18)]]))
    return scene('TbilisiAvlabari',778,(845,883),obs,{
        'TransitDoor':anchor(629,824),'LocalSpot':anchor(414,827)},[
        sign((100,552,331,47),'წიგნები','#37645f',size=28),
        sign((595,553,94,26),'მეტრო','#46452f',size=12)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'LocalSpot':'E — Walk to the bath quarter','TransitDoor':'E — Walk to the metro'})


def dezerter():
    obs=[object_('west_crates',752,[(0,727,82,25)],[
             rect(0,510,57,94),rect(0,604,82,148)]),
         plant('market_herbs',(100,688,82,63),(100,627,101,66)),
         object_('cabbage_stack',753,[(191,729,145,24)],[
             [[191,640],[205,622],[228,602],[283,602],[294,617],[321,620],
              [336,641],[336,752],[191,752]]]),
         object_('yellow_crates',742,[(340,723,51,19)],[rect(340,640,51,101)]),
         object_('west_arcade_column',742,[(430,722,70,20)],[rect(430,339,70,403)]),
         object_('east_arcade_column',742,[(1147,722,66,20)],[rect(1147,339,66,403)]),
         object_('front_fruit_counter',767,[(535,742,202,25)],[
             [[535,638],[554,625],[602,620],[643,628],[681,620],[715,630],
              [737,644],[737,766],[535,766]]]),
         object_('back_produce_desk',716,[(686,695,190,21)],[
             rect(686,588,190,128),rect(733,536,41,52),rect(739,523,29,13),
             rect(815,537,37,51),rect(810,530,48,8)]),
         object_('back_crates',712,[(1038,694,74,18)],[rect(1038,540,74,171)]),
         object_('handtruck',754,[(1012,736,105,18)],[
             tube((1025,638),(1025,723),7),tube((1093,624),(1093,724),7),
             tube((1025,638),(1093,624),7),tube((1025,690),(1093,690),7),
             rect(1011,720,106,10),
             [[1012,732],[1017,720],[1033,716],[1045,724],[1048,740],[1040,751],
              [1024,754],[1013,743]],
             [[1080,722],[1097,718],[1109,725],[1116,741],[1107,752],[1090,751],[1081,741]]]),
         object_('lemon_crates',773,[(1224,747,84,26)],[
             rect(1224,590,61,112),rect(1224,703,84,69)]),
         object_('watermelon_stall',776,[(1307,750,171,26)],[
             [[1307,687],[1315,661],[1350,647],[1385,655],[1410,640],
              [1453,653],[1478,681],[1478,775],[1307,775]]]),
         object_('east_back_boxes',705,[(1420,688,65,17)],[rect(1420,577,65,127)])]
    return scene('TbilisiDezerter',712,(883,851),obs,{
        'AirportDoor':anchor(1578,757),'TransitDoor':anchor(957,747),
        'NpcNino':anchor(1150,837),'LocalSpot':anchor(637,821),'ExitWest':anchor(50,854)},[
        sign((517,225,630,59),'დეზერტირების ბაზარი','#466c58',size=34),
        sign((909,567,92,27),'მეტრო','#264a40',size=12),
        sign((1518,537,120,36),'აეროპორტი','#1b4356',size=12)],
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def saburtalo():
    obs=[object_('west_tree',752,[(38,728,55,24)],[
             rect(44,585,39,160),tube((67,640),(27,582),17),tube((67,625),(112,564),15)],
             foliage=[rect(0,350,224,273),rect(0,681,156,71)],wood_branches=True),
         object_('west_lamp',825,[(26,809,39,16)],[
             rect(40,299,10,510),rect(26,809,39,16),rect(19,278,57,27),
             rect(36,246,22,34)]),
         rail('west_garden_rail',0,746,371,47),
         plant('west_door_pot',(151,694,49,39),(140,646,67,52)),
         object_('book_kiosk',787,[(504,766,197,21)],[
             rect(504,603,197,183),rect(513,593,32,10),rect(558,590,58,13)]),
         plant('entry_pot',(1084,700,57,45),(1079,633,79,72)),
         plant('west_garden_planter',(1134,751,161,54),(1129,684,171,74)),
         plant('east_garden_planter',(1297,751,161,54),(1284,696,181,62)),
         object_('east_tree',754,[(1643,728,29,26)],[rect(1650,591,22,163)],
             foliage=[rect(1570,326,102,311),rect(1559,666,113,88)],wood_branches=True),
         rail('east_garden_rail',1517,744,155,48)]
    return scene('TbilisiSaburtalo',720,(844,874),obs,{
        'TransitDoor':anchor(882,768),'LocalSpot':anchor(447,830)},[
        sign((228,495,422,41),'წიგნები','#9c5933',size=29),
        sign((1139,501,391,33),'მომსახურება','#426555',size=24),
        sign((814,535,134,26),'მეტრო','#39463a',size=14)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the metro','LocalSpot':'E — Into the residential yard'})


def hotel():
    obs=[chair('hall_chair',283,456,101,138),
         object_('chair_cloth',594,[(295,578,73,16)],[rect(303,508,58,48)]),
         plant('hall_plant',(402,542,64,52),(391,466,89,79)),
         object_('reception',649,[(785,621,564,28)],[
             rect(777,456,581,29),rect(785,485,564,134),
             rect(785,619,17,30),rect(1330,619,19,30),
             rect(818,428,60,37),rect(1288,397,9,59),rect(1265,358,69,39),
             rect(1273,451,48,7)],
             foliage=[rect(810,365,79,67)],wood_branches=True),
         object_('luggage_trolley',631,[(1377,609,210,22)],[
             rect(1380,350,15,219),rect(1560,347,15,223),rect(1387,350,178,11),
             rect(1384,480,187,14),rect(1368,564,219,26),
             [[1377,595],[1383,587],[1397,587],[1407,598],[1407,617],[1398,627],
              [1383,627],[1374,615]],
             [[1547,595],[1558,587],[1572,590],[1581,603],[1577,619],[1567,628],
              [1551,624],[1545,612]],
             rect(1420,410,106,70),rect(1407,499,139,60),
             rect(1453,398,37,7),rect(1453,405,6,5),rect(1484,405,6,5)])]
    return scene('TbilisiHotel',570,(731,823),obs,
        {'Point':anchor(1088,705),'Exit':anchor(187,621)},[
        sign((985,520,158,54),'სასტუმრო','#6d472d',size=18,object='reception')],
        clerks={'Point':anchor(1063,540)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[plant('west_tree',(15,615,89,92),(0,248,179,222),[rect(12,441,20,180)]),
         plant('window_plant',(388,616,89,91),(374,485,108,139)),
         object_('exchange_counter',668,[(491,649,536,19)],[
             rect(491,525,536,141),rect(491,516,536,9),
             rect(896,459,68,51),rect(922,510,10,15)],
             glass=[rect(788,333,214,183)]),
         bollard('queue_left',713,550,707),bollard('queue_right',952,550,707),
         object_('queue_belt',707,[(723,689,218,18)],[
             tube((722,565),(935,565),7)]),
         bollard('east_bollard',1574,622,746)]
    return scene('TbilisiExchange',664,(1048,845),obs,
        {'Point':anchor(836,759),'Exit':anchor(243,713)},[
        sign((500,167,724,79),'ვალუტის გადაცვლა','#306257',size=38),
        sign((541,345,193,148),'GEL\nEUR · USD\nGBP','#232c29',size=24)],
        clerks={'Point':anchor(875,593)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[object_('ticket_machine',710,[(224,686,107,24)],[rect(224,497,107,212)]),
         object_('west_turnstile',712,[(69,688,155,24)],[rect(69,530,78,181),
             rect(198,511,15,155),tube((145,607),(201,607),7)]),
         object_('east_turnstile',712,[(331,688,230,24)],[
             rect(396,534,70,177),rect(347,511,15,156),rect(551,511,10,156),
             tube((361,607),(396,607),7),tube((466,607),(557,607),7)]),
         object_('escalator_west_post',674,[(603,657,47,17)],[rect(603,529,47,144)]),
         object_('escalator_east_post',674,[(1070,657,47,17)],[rect(1070,529,47,144)]),
         object_('bench',697,[(1210,673,257,24)],[
             rect(1199,531,275,25),rect(1199,566,275,24),rect(1199,600,275,24),
             rect(1199,633,275,17),rect(1210,650,64,45),rect(1396,650,71,45)]),
         object_('station_bin',694,[(1544,672,75,22)],[rect(1544,533,75,159)])]
    return scene('TbilisiTransit',670,(846,831),obs,
        {'Machine':anchor(277,756),'Platform':anchor(858,712),'Exit':anchor(70,814)},[
        sign((685,160,297,52),'თბილისი','#566b6c',size=31),
        sign((310,323,208,70),'გასასვლელი\n← EXIT','#276654',size=19),
        sign((236,505,83,23),'ბილეთი','#706a57',size=10,object='ticket_machine')],
        interaction_sizes=sizes('Machine','Platform','Exit'),
        animation_patches=[dict(kind='escalator',rect=[*point(741,344),*point(58,235)],direction=1),
                           dict(kind='escalator',rect=[*point(920,344),*point(58,235)],direction=-1)])


def airport():
    obs=[plant('terminal_tree',(50,727,87,78),(7,554,151,165),[
            rect(83,682,21,47),tube((96,697),(119,671),12)]),
         plant('desk_plant',(710,698,56,49),(697,623,86,78)),
         object_('check_in',778,[(774,754,255,24)],[rect(773,670,257,108),
             rect(894,627,55,35),rect(916,662,10,8),rect(787,651,38,19),
             rect(984,635,22,35)]),
         bollard('queue_post',1164,689,798),
         object_('terminal_bin',753,[(1223,728,87,25)],[rect(1223,643,87,106),rect(1229,630,68,13)]),
         object_('carousel',779,[(1310,755,362,24)],[rect(1310,700,362,78),
             rect(1330,651,64,49),rect(1421,636,129,64),
             rect(1350,641,23,6),rect(1350,647,6,4),rect(1367,647,6,4),
             rect(1475,622,34,7),rect(1475,629,6,7),rect(1503,629,6,7)])]
    # The nested luggage carts keep the gaps between handles, rails and wheels.
    for i,x in enumerate([195,235,274,311]):
        obs.append(object_('cart_'+str(i),766,[(x-2,747,30,19)],[
            tube((x,663),(x+9,738),6),rect(x-7,655,30,7),
            rect(x+19,664,6,74),rect(x+2,738,27,8),
            [[x-2,748],[x+3,742],[x+11,743],[x+15,751],[x+12,762],[x+3,765],[x-3,759]],
            [[x+17,748],[x+23,743],[x+29,746],[x+31,755],[x+25,764],[x+18,761]]]))
    return scene('TbilisiAirport',730,(1080,859),obs,
        {'Point':anchor(904,827),'Exit':anchor(504,775)},[
        sign((345,320,540,71),'გამგზავრება · DEPARTURES','#172f4d',size=31),
        sign((1136,320,518,71),'ბარგი · BAGGAGE','#172f4d',size=32),
        sign((719,450,272,132),'TBILISI\nDEPARTURES\n\nBERLIN · ISTANBUL\nROME · PARIS','#14272b','#e1c762',15)],
        clerks={'Point':anchor(857,754)},interaction_sizes=sizes('Point','Exit'),
        motion_layers=[dict(kind='doors',rect=[*point(398,439),*point(205,289)])])


def build():
    return {'TbilisiSololaki':sololaki(),'TbilisiChugureti':chugureti(),
            'TbilisiAvlabari':avlabari(),'TbilisiDezerter':dezerter(),
            'TbilisiSaburtalo':saburtalo(),'TbilisiHotel':hotel(),
            'TbilisiExchange':exchange(),'TbilisiTransit':transit(),'TbilisiAirport':airport()}
