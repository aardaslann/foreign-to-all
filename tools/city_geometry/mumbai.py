"""Mumbai source layouts; replacement art alignment lives in mumbai_finish."""
from .shapes import point, anchor, rect, tube, object_, sign as base_sign
from .moscow import scene, pot, oval, board
from .seoul import box, stool
from .hanoi import pole, route_post, plastic_stool, tree
from .rome import sizes

FONT='res://art/fonts/NotoSansDevanagari.ttf'


def sign(bounds,text,bg,ink='#f3edda',size=23,**extra):
    if any('\u0900'<=c<='\u097f' for c in text):extra['font']=FONT
    return base_sign(bounds,text,bg,ink,size,**extra)


def small_bin(name,x,y,w,h):
    return object_(name,y+h,[(x+3,y+h-17,w-6,17)],[rect(x,y,w,10),
        rect(x+3,y+10,w-6,h-16),rect(x+4,y+h-6,7,6),rect(x+w-11,y+h-6,7,6)])


def seats(name,x,y,n,w=65):
    polys=[]
    for i in range(n):
        xx=x+i*w
        polys += [[[xx+9,y],[xx+w-7,y],[xx+w-4,y+6],[xx+w-4,y+51],
                   [xx+4,y+51],[xx+4,y+7]],
                  [[xx+4,y+51],[xx+w-4,y+51],[xx+w,y+61],[xx+w,y+72],[xx,y+72],[xx,y+62]]]
    polys.append(rect(x+5,y+72,n*w-10,7))
    for xx in [x+5,x+n*w/2-3,x+n*w-12]:
        polys += [rect(xx,y+79,8,17),rect(xx-3,y+94,16,5)]
    return object_(name,y+99,[(x+2,y+74,n*w-4,25)],polys)


def bhuleshwar():
    obs=[object_('west_lamp',683,[(51,652,48,31)],[
             rect(65,201,21,437),rect(52,637,44,43),rect(54,614,38,23),
             rect(84,209,74,8),tube((153,210),(156,192),7),
             [[148,200],[159,203],[171,220],[163,227],[158,249],[141,249],[138,227],[129,220]]]),
         object_('middle_lamp',687,[(832,653,48,34)],[
             rect(846,215,18,424),rect(833,639,45,47),rect(837,621,37,18),
             rect(858,221,71,7),tube((918,224),(934,208),6),
             [[929,199],[937,202],[944,215],[955,225],[948,233],[943,259],
              [927,259],[923,234],[914,226],[925,215]]]),
         box('lodging_parcels_west',148,577,87,72),box('lodging_parcels_middle',236,524,59,125),
         box('lodging_parcels_blue',295,522,51,99),box('lodging_parcels_high',349,504,43,139),
         small_bin('orange_trolley',278,588,72,83),small_bin('west_bin',459,617,46,62),
         object_('market_counter',657,[(574,631,117,26)],[rect(574,600,117,46),
             rect(578,646,8,10),rect(681,646,8,10),rect(581,530,58,70),
             rect(592,501,32,29),rect(641,570,43,30)]),
         object_('east_market_table',654,[(738,631,90,23)],[rect(738,613,90,10),
             rect(744,623,11,30),rect(813,623,11,30),rect(756,539,66,74),
             rect(766,499,47,40)]),
         object_('paper_stacks',652,[(908,630,79,22)],[rect(908,578,79,72),
             rect(917,536,66,42)]),
         box('exchange_cabinet',1098,600,51,70),box('railway_crate',1178,569,43,82),
         box('railway_parcels',1352,511,65,126),box('east_parcel',1433,600,48,52),
         small_bin('east_bin',1472,599,49,72),small_bin('far_east_bin',1580,600,44,69)]
    return scene('MumbaiBhuleshwar',645,(845,806),obs,{
        'HotelDoor':anchor(433,695),'ExchangeDoor':anchor(1046,691),
        'TransitDoor':anchor(1321,692),'LocalSpot':anchor(681,705),
        'NpcSunita':anchor(595,805),'ExitEast':anchor(1620,816)},[
        sign((239,283,223,76),'LODGE','#125c93',size=34),
        sign((592,303,205,63),'भुलेश्वर','#bc3530',size=38),
        sign((916,302,234,72),'EXCHANGE','#086570',size=32),
        sign((1236,286,274,82),'RAILWAY\nBOOKS · STATIONERY','#075a65',size=26)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def chorbazaar():
    obs=[pole('west_utility_pole',106,52,692,21),pole('east_utility_pole',1377,53,693,21),
         pot('west_plant',(15,628,54,47),(0,503,88,128)),
         pot('east_plant',(1410,630,55,47),(1403,557, 70,76)),
         pot('far_east_plant',(1582,637,64,48),(1560,519,112,123))]
    for name,x,y,w,h in [('west_drawers',141,586,75,86),('grey_drawers',181,509,83,149),
                        ('fan_cabinet',392,528,83,125),('small_grey',480,557,72,98),
                        ('blue_drawers',853,424,106,233),('mesh_cupboard',936,490,95,168),
                        ('gramophone_base',1043,541,104,122),('tall_grey',1157,505,89,158),
                        ('top_grey',1167,418,66,87),('right_drawers',1488,568,83,100),
                        ('orange_box',891,630,59,45),('red_box',1265,613,54,58)]:
        obs.append(box(name,x,y,w,h))
    obs += [object_('frame_stack',668,[(267,639,97,29)],[rect(281,478,83,190),rect(267,574,83,92)]),
            object_('red_cylinder',679,[(353,657,39,22)],[
                [[353,648],[359,637],[364,629],[364,621],[374,621],[374,630],
                 [383,638],[389,648],[389,674],[353,674]]]),
            box('floor_parcel',395,632,64,36),
            object_('floor_bench',658,[(561,635,75,23)],[rect(556,584,104,13),
                rect(562,597,9,61),rect(646,598,10,51),rect(575,614,57,29)]),
            object_('wood_chair',651,[(641,624,60,27)],[rect(642,528,59,9),
                rect(644,537,7,66),rect(692,537,7,112),rect(656,537,5,49),
                rect(675,537,5,48),rect(639,585,60,13),rect(642,598,8,51)]),
            object_('center_table',656,[(718,631,119,25)],[rect(714,549,126,10),
                rect(719,559,9,97),rect(829,559,9,97),rect(729,607,98,9),
                rect(731,626,96,8),rect(757,581,63,26),rect(748,538,33,11),
                rect(796,512,44,26)]),
            stool('red_stool',632,630,40,53),stool('orange_stool',956,631,51,47),
            object_('silver_can',674,[(1107,649,36,25)],[
                [[1108,615],[1117,605],[1117,590],[1126,590],[1126,603],
                 [1138,612],[1143,624],[1143,667],[1107,667]]]),
            object_('gramophone_horn',539,[(1076,523,39,16)],[
                [[1074,500],[1088,487],[1099,465],[1108,459],[1121,470],
                 [1131,493],[1131,505],[1110,496],[1092,504],[1086,519],
                 [1109,521],[1110,532],[1077,532]]]),
            object_('table_fan',528,[(426,518,45,10)],[oval(449,482,36,39),
                rect(443,517,12,6),rect(426,523,46,5)])]
    airport,airport_fitting=route_post('airport_stop',149,730,'AIRPORT\nBUS')
    station,station_fitting=route_post('station_stop',1471,730,'RAILWAY\n→')
    obs += [airport,station]
    return scene('MumbaiChorBazaar',664,(794,807),obs,{
        'AirportDoor':anchor(197,785),'TransitDoor':anchor(1450,783),
        'LocalSpot':anchor(753,710),'NpcFarid':anchor(1007,805),'ExitWest':anchor(53,807)},[
        sign((460,291,351,53),'CHOR BAZAAR','#f0e2c5','#151e24',size=38),
        sign((463,350,351,39),'BUY · SELL · REPAIR','#f0e2c5','#151e24',size=25),
        sign((1424,438,108,82),'OLD IS\nGOLD','#f4efdb','#1b2529',size=25)],
        fittings=[airport_fitting,station_fitting],
        prompt_overrides={'AirportDoor':'E — The airport bus','TransitDoor':'E — Towards the railway'},
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def colaba():
    obs=[pot('west_plant',(0,615,38,53),(0,491,44,127)),
         pot('bookshop_flowers',(203,642,68,39),(187,585,101,62)),
         pot('shelter_west_plant',(1072,638,27,33),(1058,561,50,80)),
         pot('shelter_east_plant',(1580,633,43,44),(1567,548,67,88)),
         pole('west_utility_pole',1105,73,691,20),pole('east_utility_pole',1637,73,692,20),
         small_bin('bookshop_bin',481,614,42,64),
         object_('bookstall',661,[(66,637,146,24)],[rect(66,600,67,59),
             rect(151,600,61,60)]),
         object_('books_counter',664,[(301,639,91,25)],[rect(299,592,93,10),
             rect(304,602,8,61),rect(381,602,9,61),rect(314,628,63,29),
             rect(308,560,65,33),rect(315,540,49,20),rect(328,504,20,36),
             rect(349,510,13,30),rect(337,483,8,22)]),
         box('small_cabinet',436,591,51,70),box('small_crate',393,608,28,54),
         box('handicraft_drawers',639,591,70,68),box('craft_floor_boxes',563,632,66,37),
         box('red_craft_crate',719,631,51,39),box('spice_counter',860,575,62,86),
         box('tea_boxes',937,631,64,39),box('east_spice_boxes',991,589,66,77),
         object_('craft_table',659,[(574,638,64,21)],[rect(571,591,68,10),
             rect(576,601,8,36),rect(630,601,8,39),rect(575,572,55,19),
             rect(590,550,29,22)]),
         object_('shelter',690,[(1140,650,364,13),(1123,665,20,25),(1248,667,17,23),
                              (1504,665,20,25)],[
             [[1120,458],[1134,447],[1537,447],[1548,453],[1548,464],
              [1536,466],[1528,477],[1121,477]],
             rect(1124,477,18,210),rect(1249,485,16,202),rect(1505,476,18,212),
             rect(1139,643,366,19),rect(1140,479,365,11),rect(1465,487,8,188),
             rect(1144,492,102,157),rect(1323,523,69,54),
             [[1409,605],[1434,605],[1442,613],[1442,641],[1434,641],
              [1434,613],[1416,613],[1416,641],[1407,641]],
             rect(1404,641,41,8)],glass=[rect(1266,491,198,152),rect(1474,491,29,152)])]
    return scene('MumbaiColaba',660,(805,808),obs,{
        'TransitDoor':anchor(1349,736),'LocalSpot':anchor(400,712)},[
        sign((333,433,120,31),'BOOKS','#08796e',size=24),
        sign((577,432,184,32),'HANDICRAFTS','#195ca4',size=23),
        sign((900,432,102,30),'SPICES','#cf462f',size=24),
        sign((1158,507,72,115),'BEST\nBUS\n\nCOLABA\nRAILWAY','#e5ede2','#20506a',size=13,object='shelter')],
        prompt_overrides={'TransitDoor':'E — The bus to the station'},
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def bandra():
    obs=[pole('west_utility_pole',264,57,687,19),pole('middle_utility_pole',1027,48,656,18),
         pole('east_utility_pole',1420,81,689,18),
         pot('west_tree',(287,610,67,56),(269,529,100,85),[
             [[313,613],[312,579],[302,565],[306,560],[316,572],[320,551],
              [326,551],[326,577],[340,563],[344,570],[326,588],[326,613]]]),
         pot('bakery_pot',(489,624,46,37),(483,571,60,57)),
         pot('east_tree',(1451,611,64,41),(1441,524,92,90)),
         pot('far_east_pot',(1623,611,45,42),(1610,534,62,80)),
         pot('garden_pot',(1269,595,50,60),(1260,528,68,72)),
         board('bakery_menu',715,584,72,90),
         object_('scooter',657,[(851,635,125,22)],[oval(870,638,17,18),oval(952,638,17,18),
             [[851,623],[857,612],[871,605],[878,590],[875,575],[883,565],
              [897,568],[893,590],[890,610],[910,612],[916,594],[964,592],
              [974,610],[973,628],[960,631],[945,621],[931,632],[884,632],
              [877,618],[864,619],[859,631]],rect(918,584,48,12),
             tube((884,568),(903,574),5),tube((885,568),(879,558),4),rect(877,558,10,5)]),
         pot('bougainvillea',(1049,615,46,58),(1036,280,273,230),[
             [[1067,617],[1069,555],[1082,520],[1091,479],[1103,453],[1110,457],
              [1104,479],[1129,458],[1164,426],[1171,430],[1138,469],[1111,499],
              [1088,555],[1080,617]]]),
         object_('west_gate',647,[(114,624,117,23)],[rect(115,522,114,123)]),
         object_('garden_fence',655,[(1095,630,171,25)],[rect(1095,600,171,54),
             *[rect(x,530,7,70) for x in range(1103,1240,16)],rect(1103,542,140,7)]),
         object_('garden_pier',654,[(1236,631,34,23)],[rect(1236,520,34,134)])]
    # Retain the saturated pink blooms that a green-only leaf matte excludes.
    blooms=[(1163,399,25,12),(1180,371,20,18),(1202,345,19,17),(1234,323,18,15),
            (1246,364,19,26),(1258,388,22,16),(1277,404,20,15),(1231,436,25,15),
            (1212,453,22,18),(1153,374,17,14),(1118,400,15,14)]
    flower_obj=next(o for o in obs if o['id']=='bougainvillea')
    flower_obj['polygons'] += [[point(x,y) for x,y in oval(cx,cy,rx,ry)] for cx,cy,rx,ry in blooms]
    return scene('MumbaiBandra',647,(825,798),obs,{
        'TransitDoor':anchor(1570,700),'LocalSpot':anchor(667,703)},[
        sign((635,430,135,36),'BAKERY','#f2dbad','#372d20',size=26),
        sign((725,595,49,59),'PAO\nCHAI\nOPEN','#193039',size=11,object='bakery_menu'),
        sign((1520,445,105,28),'RAILWAY →','#176396',size=15)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def byculla():
    obs=[tree('west_tree',70,711,(0,94,265,350),[
             [[47,708],[56,687],[52,463],[35,433],[25,393],[13,367],[0,351],[0,335],
              [26,350],[41,379],[51,390],[51,351],[32,322],[25,295],[32,292],
              [48,322],[62,334],[67,377],[85,404],[106,389],[123,356],[146,329],
              [153,333],[137,361],[131,385],[165,361],[198,343],[202,349],
              [165,373],[126,413],[103,448],[87,486],[83,687],[93,708]]]),
         pot('tree_base_plant',(31,683,66,46),(9,618,102,69)),
         pot('cafe_tree',(125,672,54,46),(104,487,88,188),[rect(149,599,11,76)]),
         pot('cafe_east_pot',(559,669,41,39),(554,598,55,75)),
         pot('east_pot',(1468,651,55,50),(1464,590,62,65)),
         object_('cafe_counter',710,[(269,684,173,26)],[rect(267,650,176,12),
             rect(270,662,171,46),rect(280,620,33,30),rect(323,627,44,22),
             rect(404,611,22,40)]),
         small_bin('cafe_bin',452,636,61,77),
         object_('tailor_table',721,[(728,697,133,24)],[rect(727,663,137,12),
             rect(733,675,10,45),rect(850,675,10,45),rect(739,695,111,8),
             rect(773,653,42,9),rect(824,645,22,18)]),
         object_('lamp',738,[(534,710,32,28)],[rect(543,413,15,299),
             rect(536,711,29,24),rect(479,486,66,9),rect(473,478,18,9),
             [[473,492],[494,492],[495,521],[473,521]]]),
         object_('fire_hydrant',736,[(1584,708,66,28)],[rect(1584,669,66,15),
             rect(1591,684,50,46),rect(1586,730,58,6),rect(1602,650,50,19),
             rect(1620,638,19,12),rect(1579,675,12,17),rect(1640,681,15,15)]),
         object_('mill_gate',701,[(946,676,294,25)],[rect(946,461,18,239),rect(1220,462,20,238),
             rect(962,474,259,7),rect(967,678,250,13),
             *[rect(x,515,5,163) for x in range(974,1084,14)],
             *[rect(x,518,5,160) for x in range(1104,1214,14)],
             tube((966,506),(1089,536),8),tube((966,529),(1089,554),7),
             tube((1094,536),(1219,507),8),tube((1094,553),(1219,528),7),
             rect(1087,533,9,154),
             *[[[x-4,474],[x,458],[x+5,474]] for x in range(973,1214,13)]])]
    for i,(x,y) in enumerate([(225,660),(280,663),(408,663),(770,672),(876,666)]):
        obs.append(plastic_stool('street_stool_'+str(i),x,y,39,55))
    return scene('MumbaiByculla',705,(908,830),obs,{
        'TransitDoor':anchor(655,750),'LocalSpot':anchor(1090,749)},[
        sign((235,490,233,39),'IRANI CHAI','#d8edf3','#182e41',size=29),
        sign((713,514,165,39),'TAILOR','#e8edef','#172e41',size=30),
        sign((923,307,275,120),'BYCULLA\nMILL','#a94430',size=42),
        sign((1298,539,141,122),'WORK\nBUILDS\nMUMBAI','#ece6d6','#626263',size=27),
        sign((628,611,39,24),'RAIL','#cccaba','#303c3e',size=10)],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[object_('reception',592,[(455,562,592,30)],[rect(450,427,601,24),
             rect(456,451,590,139),rect(476,392,229,34),rect(975,402,41,24)],
             foliage=[rect(953,345,87,60)]),
         object_('water_dispenser',576,[(214,551, 70,25)],[rect(215,413,69,158),
             [[226,347],[272,347],[275,354],[275,399],[268,410],[229,410],[224,401],[224,354]]]),
         object_('tea_cabinet',575,[(292,551,113,24)],[rect(285,415,130,12),
             rect(292,427,113,138),rect(294,565,11,10),rect(393,565,11,10),
             rect(298,378,20,37),rect(325,389,19,27),rect(378,374,24,41)]),
         object_('luggage_bench',576,[(1110,551,182,25)],[rect(1104,514,194,13),
             rect(1113,527,16,49),rect(1273,527,16,49),rect(1129,550,144,11),
             rect(1119,458,74,55),rect(1213,459,65,54),
             tube((1144,457),(1145,449),4),rect(1146,447,18,4),rect(1163,450,4,8),
             rect(1233,452,22,5)]),
         object_('plant_cabinet',574,[(1357,548,103,26)],[rect(1354,424,109,12),
             rect(1358,436,101,127),rect(1360,563,11,11),rect(1445,563,11,11),
             [[1373,361],[1434,361],[1432,374],[1427,423],[1378,423],[1375,375]]],
             foliage=[rect(1362,240, 90,124)],wood_branches=True)]
    return scene('MumbaiHotel',575,(793,795),obs,{
        'Point':anchor(748,644),'Exit':anchor(118,634)},[
        sign((510,218,132,90),'HOTEL\nSHREE','#e6cf9f','#392c1e',size=27)],
        clerks={'Point':anchor(750,553)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('exchange_counter',654,[(626,625,519,29)],[rect(626,481,519,174),
             rect(628,207,9,275),rect(832,207,7,274),rect(1132,207,9,275),
             rect(677,396, 80,85),rect(656,444,20,37),rect(788,447,51,35),
             rect(1010,260,123,221)],glass=[rect(638,211,193,270),rect(840,211,169,270)]),
         object_('back_counter',651,[(275,628,351,23)],[rect(276,481,350,170),
             rect(509,449,100,32),rect(543,414,54,35),rect(368,458,45,22)],
             foliage=[rect(338,386,102,74)]),
         box('right_drawers',1295,512,91,157),
         object_('right_cabinet',669,[(1395,646, 80,23)],[rect(1392,512,89,12),
             rect(1397,524,78,130),rect(1397,654,10,15),rect(1466,654,9,15),
             rect(1423,480,33,32)],foliage=[rect(1394,412,78,71)]),
         object_('right_printer',481,[(1166,462,87,19)],[rect(1166,436,87,45),
             rect(1169,387,40,49),rect(1207,425,31,11)])]
    for i,x in enumerate([316,411,505]):
        obs.append(object_('waiting_seat_'+str(i),681,[(x+10,653,78,28)],[
            [[x+15,543],[x+81,543],[x+87,549],[x+87,602],[x+15,602],[x+11,596],[x+11,550]],
            rect(x,612,93,20),rect(x+13,632,12,47),rect(x+77,632,12,47)]))
    return scene('MumbaiExchange',655,(846,804),obs,{
        'Point':anchor(879,706),'Exit':anchor(130,718)},[
        sign((637,80,495,64),'MONEY EXCHANGE','#f0e8d4','#142536',size=40),
        sign((639,153,491,37),'FOREIGN CURRENCY · TRAVEL CARDS','#f0e8d4','#576970',size=24),
        sign((342,160,242,189),'USD\nGBP\nEUR\nAED','#202a38','#eed461',size=30),
        sign((1259,225,150,117),'TRAVEL\nEXPLORE\nRETURN','#72b4de','#194778',size=25)],
        clerks={'Point':anchor(882,608)},interaction_sizes=sizes('Point','Exit'))


def transit():
    obs=[object_('west_column',795,[(195,765,128,30)],[rect(224,0,68,619),
             rect(219,619,80,146),rect(195,765,128,29),rect(221,347,74,136)]),
         object_('east_column',795,[(1471,765,128,30)],[rect(1507,0, 60,619),
             rect(1497,619,78,146),rect(1471,765,128,29)]),
         object_('west_bin',784,[(60,752,86,32)],[
             [[61,618],[69,605],[132,605],[145,616],[145,645],[141,648],
              [141,761],[137,761],[137,782],[126,782],[126,762],
              [79,762],[79,782],[66,782],[66,762],[60,762]],rect(58,642,90,8)]),
         small_bin('rear_bin',919,560,49,79),
         pole('middle_column',1003,269,674,37),pole('sign_post',795,269,648,14),
         object_('platform_seats',785,[(687,756,429,29)],[
             *[rect(x+12,643,84,58) for x in [692,796,900,1005]],
             *[rect(x,701,104,21) for x in [687,796,902,1015]],
             rect(701,723,14,61),rect(815,723,14,61),rect(917,723,14,61),rect(1087,723,14,61)]),
         object_('station_stair',624,[(1106,596,565,28)],[
             [[1106,612],[1506,311],[1506,351],[1179,594],[1295,594],[1295,623],[1106,623]],
             rect(1296,483,30,140),rect(1356,490,52,131),
             tube((1108,512),(1506,214),8),tube((1108,541),(1506,244),7),
             *[rect(x,512-(x-1108)*.75,5,102) for x in range(1108,1505,18)] ]),
         object_('ticket_machine',750,[(501,724,61,26)],[])]
    return scene('MumbaiTransit',624,(1280,804),obs,{
        'Machine':anchor(532,798),'Platform':anchor(647,672),'Exit':anchor(1146,673)},[
        sign((739,122,208,85),'मुंबई','#1d365e',size=47),
        sign((757,210,199,43),'MUMBAI','#1d365e',size=32),
        sign((231,361,53,106),'MIND\nTHE\nGAP','#f0bf39','#172a32',size=21,object='west_column')],
        fittings=[dict(kind='ticket',at=point(532,750))],
        interaction_sizes=sizes('Machine','Platform','Exit'),walk_bottom=point(0,876)[1])


def airport():
    obs=[pot('west_tree',(18,552,73,94),(0,276,154,279),[rect(40,466,12,88)]),
         pot('west_middle_tree',(386,601, 50,51),(367,498,95,107)),
         pot('middle_tree',(964,617,35,35),(942,494, 80,126)),
         pot('right_tree',(1079,613,48,39),(1049,489,106,127)),
         object_('terminal_west_column',643,[(199,621,96,22)],[rect(199,229,96,413),
             [[199,233],[56,0],[139,0],[236,182],[341,0],[417,0],[295,229]]]),
         object_('terminal_east_column',650,[(1473,628,96,22)],[rect(1473,367,96,283)]),
         object_('check_in_counter',660,[(1219,633,321,27)],[
             rect(1217,554,112,95),rect(1227,424,99,76),rect(1236,500,68,54),
             rect(1266,595,70,63),rect(1381,592,159,67),rect(1386,552,143,40),
             rect(1336,584,41,71),rect(1345,576,26,8)],
             foliage=[rect(1324,488,142,69)]),
         object_('front_luggage_belt',869,[(408,828,879,41)],[rect(410,826,877,42),
             rect(449,753,93,72),rect(419,768,60,72),rect(743,761,82,62),
             rect(836,762,76,63),rect(960,757,55,68),rect(1109,702,91,117),
             rect(1215,736,51,83),rect(1153,652,41,51),
             rect(471,744,6,9),rect(475,741,34,5),rect(506,745,6,10),
             rect(767,750,31,6),rect(846,752,56,6),rect(973,748,30,6)]),
         object_('queue_rail',776,[(501,754,474,22)],[rect(504,707,467,11),
             rect(504,718,7,45),rect(712,718,7,54),rect(966,718,7,43),
             oval(505,711,6,8),oval(716,711,7,8),oval(969,711,7,8)]),
         object_('west_queue_reader',766,[(449,747,36,19)],[rect(454,705,31,53),rect(449,702,38,5)]),
         object_('east_queue_reader',738,[(1219,720,46,18)],[rect(1220,700,43,7),rect(1226,707,31,31)])]
    for name,x,n,w in [('west',85,4,68),('middle',469,3,61),('right',684,4,61)]:
        obs.append(seats(name+'_seats',x,565,n,w))
    return scene('MumbaiAirport',649,(1018,739),obs,{
        'Point':anchor(1266,704),'Exit':anchor(1563,691)},[
        sign((539,211,192,121),'Departures\nArrivals','#19232e','#efd154',size=29),
        sign((1084,199,215,164),'Baggage\nInformation\nExit','#19232e',size=29),
        sign((1440,193,231,153),'DEPARTURES\n\nMUMBAI · LONDON\nSEOUL · ISTANBUL','#19232e','#eed462',size=20)],
        clerks={},prompt_overrides={'Point':'E — The check-in terminal'},
        interaction_sizes=sizes('Point','Exit'))


def build():
    from .mumbai_finish import finish
    return finish({'MumbaiBhuleshwar':bhuleshwar(),'MumbaiChorBazaar':chorbazaar(),
            'MumbaiColaba':colaba(),'MumbaiBandra':bandra(),'MumbaiByculla':byculla(),
            'MumbaiHotel':hotel(),'MumbaiExchange':exchange(),'MumbaiTransit':transit(),
            'MumbaiAirport':airport()})
