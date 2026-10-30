"""Paris: individual object silhouettes measured against the new scene plates.

Coordinates describe the reference canvas; feet, silhouettes and readable
sign faces are separate so no floor rectangle is used as an occluder.
"""
from .shapes import point, anchor, rect, tube, object_, sign, SY
from .london import scene, plant


def bollard(name,x,y=698,bottom=750,width=15):
    return object_(name,bottom,[(x-width/2-2,bottom-10,width+4,10)],
        [[[x-width/2+3,y],[x+width/2-3,y],[x+width/2,y+5],
          [x+width/2,y+12],[x+width/2-2,y+14],[x+width/2-2,bottom-5],
          [x+width/2+3,bottom-4],[x+width/2+3,bottom],
          [x-width/2-3,bottom],[x-width/2-3,bottom-4],[x-width/2+2,bottom-5],
          [x-width/2+2,y+14],[x-width/2,y+12],[x-width/2,y+5]]])


def lamp(name,x,top,bottom,head=44):
    return object_(name,bottom,[(x-15,bottom-16,30,16)],[
        [[x-17,bottom],[x+17,bottom],[x+17,bottom-12],[x+9,bottom-17],
         [x+9,top+80],[x+16,top+67],[x+head/2-4,top+43],
         [x+head/2,top+39],[x+head/2,top+31],[x+10,top+21],
         [x+5,top+12],[x+5,top+5],[x,top],[x-5,top+5],
         [x-5,top+12],[x-10,top+21],[x-head/2,top+31],
         [x-head/2,top+39],[x-head/2+4,top+43],[x-16,top+67],
         [x-9,top+80],[x-9,bottom-17],[x-17,bottom-12]]])


def marais():
    obs=[bollard('bollard_'+str(i),x) for i,x in enumerate([18,197,355,524,922,1094,1168,1345,1594])]
    obs += [lamp('west_lamp',100,438,702,44),
        plant('west_tree',(8,644,45,38),(0,488,85,157),[rect(27,564,12,80)]),
        plant('west_shrub',(127,644,44,39),(107,517,74,129),[rect(142,602,11,43)]),
        plant('arch_west',(431,645,43,36),(409,548,81,100),[rect(448,592,9,54)]),
        plant('arch_east',(712,644,45,37),(694,545,78,104),[rect(729,594,10,51)]),
        object_('book_display',681,[(985,661,83,20)],[
            rect(985,634,82,21),rect(987,655,7,25),rect(1058,655,8,25),
            rect(994,605,15,30),rect(1011,601,19,34),rect(1035,611,16,24)]),
        object_('airport_shuttle_post',738,[(1637,724,18,14)],[
            rect(1639,482,16,241),rect(1633,722,26,15),rect(1625,483,39,80)])]
    return scene('ParisMarais',671,(1305,829),obs,
        {'TransitDoor':anchor(236,700),'AirportDoor':anchor(1595,786),
         'LocalSpot':anchor(592,708),'ExitWest':anchor(45,839),
         'NpcKarim':anchor(380,845),'KeyOdile':anchor(830,839),'Encounter':anchor(1190,841)},[
            sign((204,496,69,24),'MÉTRO','#193929',size=13),
            sign((802,439,259,51),'LIBRAIRIE','#17476c',size=27),
            sign((1100,494,158,46),'CAFÉ','#8c2d31',size=24),
            sign((1336,425,270,46),'BOULANGERIE','#e2cc9e','#3e2417',25)],
        encounter_exit={'to':anchor(1610,865),'via':[]},
        interaction_sizes={k:{'CollisionShape2D':[57,34]} for k in ['TransitDoor','AirportDoor','LocalSpot']})


def montmartre():
    obs=[bollard('bollard_'+str(i),x) for i,x in enumerate([88,163,974,1073,1237,1481,1608])]
    obs += [bollard('stair_bollard_'+str(i),x,599,678,15) for i,x in enumerate([808,869,930])]
    obs += [lamp('west_lamp',113,433,693,43),lamp('grocer_lamp',647,432,693,43),
        lamp('stair_lamp',1037,441,599,36),
        plant('grocer_plant',(576,633,45,47),(548,535,87,99),[rect(594,586,10,48)]),
        object_('west_tree',663,[(46,646,38,17)],[
            [[55,662],[55,573],[43,564],[32,546],[37,541],[60,560],[60,520],
             [73,520],[73,558],[91,540],[96,545],[77,573],[77,662]]],foliage=[rect(10,380,101,192)]),
        object_('produce_west',681,[(223,664,110,17)],[rect(222,634,113,46),
            [[219,634],[228,603],[239,614],[251,600],[258,614],[271,603],[279,614],
             [289,603],[300,612],[313,604],[326,622],[334,634]]]),
        object_('produce_east',681,[(436,662,104,19)],[rect(435,628,105,52),
            [[435,628],[442,612],[455,607],[467,612],[476,601],[490,605],
             [502,612],[516,607],[530,615],[540,628]]]),
        object_('east_map',674,[(1588,659,44,15)],[rect(1576,587,59,67),rect(1586,654,6,20),rect(1622,654,6,20)])]
    # Stairs lead to the Place du Tertre activity. Their solid side wall is
    # behind the walkable apron; the posts at the foot retain separate gaps.
    return scene('ParisMontmartre',669,(719,833),obs,
        {'TransitDoor':anchor(1350,710),'LocalSpot':anchor(748,711)},[
            sign((202,438,348,48),'ALIMENTATION','#255138',size=27),
            sign((1227,444,273,51),'MÉTRO','#e6d6b6','#112842',31),
            sign((805,541,35,20),'PLACE\nDU TERTRE','#ead8ad','#3c2f1e',6)],
        interaction_sizes={k:{'CollisionShape2D':[70,34]} for k in ['TransitDoor','LocalSpot']})


def belleville():
    obs=[bollard('bollard_'+str(i),x) for i,x in enumerate([65,321,588,737,908,1073,1186,1362,1606])]
    obs += [lamp('park_lamp',1406,433,694,44),
        plant('metro_plant',(209,650,31,33),(201,605,45,46),[rect(221,631,6,20)]),
        plant('restaurant_plant',(1150,654,43,29),(1136,585,75,70),[rect(1165,622,7,34)]),
        object_('grocer_crates',683,[(511,660,152,23)],[rect(510,635,155,48),
            [[503,635],[513,613],[528,614],[538,602],[551,606],[562,594],
             [577,603],[588,616],[603,610],[618,617],[635,610],[651,617],[665,635]]]),
        plant('flower_planter',(735,654,70,29),(727,581,88,75),[rect(765,620,8,35)]),
        object_('red_produce_table',744,[(434,727,105,17)],[
            rect(430,683,118,38),rect(436,720,9,23),rect(527,720,9,23),
            [[430,683],[436,674],[449,676],[459,668],[472,674],[484,663],
             [496,670],[509,664],[517,673],[535,670],[548,683]]]),
        object_('handcart',731,[(1444,707,106,24)],[
            rect(1451,697,101,17),rect(1518,665,33,32),
            [[1437,614],[1511,614],[1517,622],[1517,635],[1508,638],[1508,697],
             [1443,697],[1443,636],[1437,633]],
            [[1456,699],[1477,699],[1487,710],[1487,721],[1477,731],
             [1458,731],[1448,721],[1448,711]],
            rect(1526,713,14,13),tube((1545,698),(1545,654),6),
            tube((1545,654),(1560,644),6),rect(1557,638,17,7)]),
        object_('restaurant_table',690,[(842,674,289,16)],[
            rect(1028,628,68,11),rect(1055,639,9,42),rect(1041,681,37,6),
            rect(843,615,17,42),rect(840,656,37,9),rect(839,665,7,21),rect(867,665,7,21),
            rect(993,615,18,36),rect(993,651,47,9),rect(997,660,7,27),rect(1032,660,7,27),
            rect(1113,615,20,41),rect(1087,656,40,9),rect(1088,665,7,22),rect(1120,665,7,22)])]
    return scene('ParisBelleville',683,(790,833),obs,
        {'TransitDoor':anchor(146,712),'LocalSpot':anchor(1267,717)},[
            sign((94,490,98,23),'MÉTRO','#1e3d67',size=16),
            sign((279,479,141,34),'ATELIER','#cfc4ac','#283544',24),
            sign((523,439,256,54),'PRIMEURS','#31533b',size=27),
            sign((836,431,294,49),'RESTAURANT','#8d3030',size=25),
            sign((1171,578,36,14),'PARC →','#173b60',size=6)],
        interaction_sizes={k:{'CollisionShape2D':[68,34]} for k in ['TransitDoor','LocalSpot']})


def hotel():
    obs=[object_('reception',583,[(539,556,599,27)],[rect(533,432,613,151),
        rect(568,385,30,47),rect(602,398,40,34),rect(898,397,43,36),rect(1006,387,55,45)]),
        plant('west_plant',(20,451,70,93),(0,284,117,169),[rect(54,376,11,78)]),
        object_('welcome_board',589,[(328,571,169,18)],[
            rect(328,369,164,201),rect(328,569,19,19),rect(476,569,20,19)]),
        object_('west_sideboard',540,[(489,517,46,23)],[rect(490,399,155,139)]),
        plant('sideboard_plant',(510,365,48,33),(479,250,108,119),[rect(529,321,10,45)]),
        object_('east_sideboard',552,[(1145,530,66,22)],[rect(1144,457,69,94)]),
        plant('east_plant',(1151,421,48,39),(1126,307,97,114),[rect(1171,364,10,59)]),
        object_('armchair',585,[(1250,555,182,30)],[
            [[1302,423],[1422,423],[1434,436],[1434,552],[1411,561],
             [1404,582],[1389,582],[1389,563],[1271,563],[1271,583],
             [1255,583],[1253,562],[1249,553],[1249,479],[1256,469],
             [1298,464]]]),
        object_('bin',583,[(1420,565,55,18)],[
            [[1423,498],[1435,494],[1465,494],[1474,500],[1474,573],
             [1464,580],[1427,580],[1419,573],[1419,507]]]),
        object_('luggage_trolley',586,[(1507,564,131,22)],[
            rect(1508,552,130,13),rect(1514,565,19,20),rect(1611,565,20,20),
            tube((1518,552),(1518,423),8),tube((1518,423),(1532,404),8),
            tube((1532,404),(1557,390),8),tube((1557,390),(1590,390),8),
            tube((1590,390),(1616,404),8),tube((1616,404),(1628,424),8),
            tube((1628,424),(1628,552),8),rect(1567,373,12,17),
            rect(1534,491,27,61),rect(1563,486,29,66),rect(1595,479,21,74)])]
    return scene('ParisHotel',537,(836,745),obs,{'Point':anchor(884,625),'Exit':anchor(210,561)},[
        sign((730,96,272,63),'HÔTEL','#e0c59b','#3d2416',36),
        sign((349,404,128,127),'Bienvenue\nWelcome\nBienvenidos','#1b2e42',size=16,object='welcome_board')],
        clerks={'Point':anchor(851,551)},interaction_sizes={'Point':{'CollisionShape2D':[90,36]},'Exit':{'CollisionShape2D':[72,36]}})


def exchange():
    obs=[object_('counter',568,[(479,538,686,30)],[rect(478,444,688,123),
        rect(527,387,69,58),rect(649,397,36,48),rect(720,416,53,29),
        rect(785,417,62,28),rect(984,367,65,78),rect(1071,365,49,80)],
        glass=[rect(510,190,154,253),rect(691,190,236,253),rect(948,190,186,253)]),
        plant('west_plant',(5,489,60,78),(0,324,80,167),[rect(27,414,10,76)]),
        plant('east_plant',(1293,509,69,70),(1279,349,100,162),[rect(1319,440,10,70)]),
        object_('leaflet_stand',577,[(291,558,110,19)],[
            [[304,396],[401,396],[402,562],[390,575],[376,575],[376,558],
             [306,558],[306,575],[291,575],[291,515]],rect(309,552,67,12)]),
        object_('bin',570,[(1448,550,100,20)],[rect(1449,405,98,164)])]
    polys=[rect(444,641,413,15)]
    for x in [436,607,866]:
        polys += [[[x-9,605],[x+9,605],[x+14,612],[x+14,623],[x+8,630],
                   [x+8,750],[x+25,752],[x+26,774],[x-26,774],
                   [x-25,752],[x-8,750],[x-8,630],[x-14,623],[x-14,612]]]
    obs.append(object_('queue',775,[(409,751,483,24)],polys))
    return scene('ParisExchange',568,(1045,816),obs,{'Point':anchor(924,617),'Exit':anchor(177,588)},[
        sign((757,80,292,77),'CHANGE','#17375c','#efc345',38),
        sign((1389,145,232,213),'EUR   1.00\nUSD   1.08\nGBP   0.86\nJPY   159.0','#172237',size=26)],
        clerks={'Point':anchor(881,539)},interaction_sizes={'Point':{'CollisionShape2D':[90,36]},'Exit':{'CollisionShape2D':[70,36]}})


def transit():
    obs=[object_('ticket_machine',754,[(0,731,154,23)],[
        [[5,389],[145,389],[154,399],[154,743],[147,752],[2,752],[0,401]]]),
        object_('bin',763,[(949,743,70,20)],[
            [[948,603],[958,589],[1008,589],[1021,602],[1021,619],
             [1015,628],[1015,758],[950,758],[950,628],[944,620],[944,606]]])]
    for i,x in enumerate([519,607,693,780]):
        obs.append(object_('seat_'+str(i),754,[(x+14,739,40,15)],[
            [[x+7,574],[x+59,574],[x+67,582],[x+67,654],[x+73,658],
             [x+73,687],[x+66,693],[x-4,693],[x-8,687],[x-8,662],
             [x,655],[x,582]],rect(x+25,693,18,48),rect(x+15,740,39,13)]))
    r=scene('ParisTransit',751,(1310,844),obs,
        {'Machine':anchor(82,790),'Platform':anchor(1174,870),'Exit':anchor(1584,782)},[
            sign((30,425,91,24),'BILLETS','#13283b',size=17,object='ticket_machine'),
            sign((718,254,269,98),'PARIS','#133d73',size=44),
            sign((1446,291,187,60),'Sortie →','#153961',size=28)],
        interaction_sizes={k:{'CollisionShape2D':[72,34]} for k in ['Machine','Platform','Exit']})
    r['source'][2]=1671
    return r


def champdemars():
    obs=[bollard('bollard_'+str(i),x,722,779,15)
         for i,x in enumerate([102,291,439,598,945,1099,1423])]
    obs += [lamp('west_lamp',381,218,597,45),
        object_('park_fence_west',653,[(207,626,501,16)],[
            rect(208,602,320,49),rect(529,401,65,204),rect(525,590,69,62),
            [[531,399],[531,383],[547,380],[547,369],[557,359],[569,358],
             [578,366],[583,378],[591,382],[591,399]]],
            foliage=[rect(209,493,319,113),rect(594,505,115,100)],painted_metal=True),
        object_('park_fence_east',654,[(984,627,287,16)],[
            rect(1110,403,63,199),rect(1103,590,72,63),rect(1175,605,95,48),
            [[1111,401],[1111,383],[1123,379],[1125,366],[1133,360],
             [1147,361],[1157,368],[1157,379],[1170,384],[1170,402]]],
            foliage=[rect(980,499,123,109),rect(1173,492,99,115)],painted_metal=True),
        plant('hotel_plant',(140,613,57,59),(129,515,82,101),[rect(164,574,10,40)]),
        plant('west_front_plant',(342,667, 60,34),(332,597,85,74),[rect(366,636,8,32)]),
        plant('bench_west_plant',(433,634,59,35),(419,547,86,89),[rect(456,590,9,45)]),
        plant('bench_east_plant',(685,637,60,37),(676,557,82,82),[rect(707,597,9,42)]),
        plant('fountain_east_plant',(958,636,65,37),(949,558,83,81),[rect(983,599,9,38)]),
        plant('wide_east_planter',(1088,668,109,32),(1073,590,130,81),[rect(1137,633,10,37)]),
        plant('exchange_plant',(1541,611,54,57),(1524,529,80,84),[rect(1560,575,9,39)]),
        object_('notice_case',696,[(252,678,81,18)],[
            [[252,537],[249,531],[256,519],[274,510],[280,494],[284,485],
             [300,485],[309,493],[311,510],[328,518],[337,531],[331,537],
             [331,694],[320,694],[320,656],[263,656],[263,694],[252,694]]]),
        object_('bench',674,[(522,652,141,22)],[
            rect(523,592,140,16),rect(523,628,140,14),rect(518,642,146,10),
            rect(525,651,10,22),rect(647,651,11,22),rect(526,608,7,20),rect(650,608,7,20)]),
        object_('drinking_fountain',702,[(811,680,78,22)],[
            [[811,701],[889,701],[889,682],[881,677],[881,662],[875,657],
             [875,564],[888,559],[888,549],[878,546],[878,535],[883,531],
             [883,521],[863,519],[863,510],[842,507],[834,511],[834,520],
             [821,521],[821,533],[826,538],[826,547],[815,550],[815,560],
             [824,564],[824,658],[817,663],[817,677],[811,681]]]),
        bollard('metro_west_jamb',1280,499,672,16),bollard('metro_east_jamb',1507,497,672,17)]
    return scene('ParisChampDeMars',652,(901,847),obs,
        {'HotelDoor':anchor(73,685),'ExchangeDoor':anchor(1640,697),
         'TransitDoor':anchor(1401,711),'LocalSpot':anchor(769,727),
         'ExitEast':anchor(1624,845),'NpcElodie':anchor(1167,833)},[
            sign((20,315,116, 30),'HÔTEL','#5b3921','#e3c074',20),
            sign((1564,332,101,43),'CHANGE','#183c60',size=18),
            sign((1292,424,219, 30),'MÉTRO','#e3d5b6','#13253d',25)],
        animation_patches=[{'kind':'water','rect':[*point(844,582),*point(15,56)]}],
        interaction_sizes={k:{'CollisionShape2D':[68,34]} for k in ['HotelDoor','ExchangeDoor','TransitDoor','LocalSpot']})


def ladefense():
    obs=[bollard('bollard_'+str(i),x,722,779,15) for i,x in enumerate([355,1224,1450,1590])]
    obs += [object_('tall_bollard_'+str(i),695,[(x-14,677,28,18)],
            [rect(x-14,612,28,81)]) for i,x in enumerate([534,746,900,1086])]
    obs += [object_('west_wayfinding',716,[(62,699,217,17)],
            [rect(22,458,304,176),rect(63,634,18,81),rect(260,634,18,81)]),
        plant('west_planter',(83,638,391, 70),(320,537,147,104),[]),
        plant('east_planter',(1468,666,204,46),(1471,563,201,104),[]),
        object_('concrete_bench',704,[(1127,684,166,20)],
            [[[1123,638],[1286,638],[1293,646],[1293,703],[1138,703],[1123,695]]]),
        object_('west_light',459,[(160,438,34,21)],
            [rect(161,263,32,193),rect(154,240,48,18),rect(158,258,41,7)]),
        object_('metro_light',469,[(1247,448,34,21)],
            [rect(1247,285,35,181),rect(1238,260,53,20),rect(1241,280,46,6)]),
        object_('metro_west_jamb',605,[(1276,587,33,18)],[rect(1275,482,33,122)]),
        object_('metro_east_jamb',605,[(1548,587,20,18)],[rect(1548,482,20,122)])]
    return scene('ParisLaDefense',585,(849,833),obs,
        {'TransitDoor':anchor(1423,642),'LocalSpot':anchor(858,616)},[
            sign((32,466,279,162),'← Bureaux\n← Esplanade\n← La Défense','#183d6b',size=26,object='west_wayfinding'),
            sign((1309,406,240, 30),'MÉTRO','#e8dab8','#16324e',26)],
        interaction_sizes={k:{'CollisionShape2D':[72,34]} for k in ['TransitDoor','LocalSpot']})


def airport():
    obs=[object_('check_in',680,[(1018,653,387,27)],[rect(1017,577,389,101),
        rect(1068,545,61,33),rect(1235,545,21,32),rect(1285,570,83,22),rect(1320,544,33,28)]),
        object_('carousel',829,[(466,749,733,80)],[
            [[481,720],[505,711],[1165,711],[1197,722],[1207,737],
             [1207,800],[1194,817],[1172,828],[492,828],[470,818],[459,802],
             [459,743],[466,729]]]),
        object_('trolleys',802,[(1484,773,188,29)],[
            rect(1489,763,183,13),rect(1494,704,8,58),rect(1498,690,10,14),
            rect(1506,679,20,11),rect(1534,704,8,57),rect(1544,683,23,12),
            rect(1574,704,8,57),rect(1586,680,21,13),rect(1615,703,8,58),
            rect(1628,680,19,12),rect(1656,701,8,62),
            rect(1510,698,22,63),rect(1550,699,23,62),rect(1593,697,22,64),rect(1633,696,23,65),
            [[1489,777],[1503,777],[1513,786],[1513,792],[1504,801],[1490,801],[1482,793],[1482,786]],
            [[1531,777],[1547,777],[1555,785],[1555,792],[1547,801],[1532,801],[1524,793],[1524,785]],
            [[1574,777],[1588,777],[1597,785],[1597,793],[1589,801],[1573,801],[1566,793],[1566,785]],
            [[1615,777],[1629,777],[1638,785],[1638,793],[1630,801],[1614,801],[1608,793],[1608,785]],
            rect(1651,779,21,21)])]
    for i,x in enumerate([498,768]): obs.append(object_('validator_'+str(i),668,[(x-15,649,30,19)],[rect(x-16,552,32,114)]))
    for i,x in enumerate([0,74,148,220,294,369]):
        obs.append(object_('seat_'+str(i),698,[(x+24,682,28,16)],[
            [[x,580],[x+56,580],[x+60,587],[x+60,642],[x+63,647],[x+60,661],
             [x-9,661],[x-12,651],[x-8,642],[x-8,587]],
            rect(x-8,624,8,23),rect(x+58,624,8,23),rect(x+28,661,14,31),rect(x+22,691,27,6)]))
    r=scene('ParisAirport',674,(1300,842),obs,
        {'Point':anchor(1304,717),'Exit':anchor(1455,702)},[
            sign((729,177,350, 40),'Enregistrement','#183a64',size=27),
            sign((749,251,207, 40),'Départs','#183a64',size= 30),
            sign((752,327,172, 40),'Train','#183a64',size= 30),
            sign((1336,246,286,39),'AÉROPORT','#e4dcc9','#102f4e', 30),
            sign((1440,494,190, 30),'Sortie → Paris','#173450',size=19)],
        clerks={'Point':anchor(1196,648)},
        animation_patches=[{'kind':'conveyor','rect':[*point(496,723),*point(660,39)]}],
        interaction_sizes={'Point':{'CollisionShape2D':[ 80,34]},'Exit':{'CollisionShape2D':[54, 30]}})
    r['source'][2]=1671
    return r


def build():
    from .paris_finish import finish
    return finish({'ParisMarais':marais(),'ParisMontmartre':montmartre(),
            'ParisBelleville':belleville(),'ParisHotel':hotel(),
            'ParisExchange':exchange(),'ParisTransit':transit(),
            'ParisChampDeMars':champdemars(),'ParisLaDefense':ladefense(),'ParisAirport':airport()})
