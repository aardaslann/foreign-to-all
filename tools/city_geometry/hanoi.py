"""Hanoi source layouts, activated individually by measured hanoi_finish art."""
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import scene, pot, oval
from .seoul import box, stool
from .tokyo import wheel, chair
from .rome import sizes


def pole(name,x,top,bottom,width=19):
    return object_(name,bottom,[(x-width/2-5,bottom-17,width+10,17)],[
        rect(x-width/2,top,width,bottom-top-8),rect(x-width/2-5,bottom-8,width+10,8)])


def route_post(name,x,y,text):
    return (object_(name,y,[(x-10,y-15,20,15)],[]),
            dict(kind='wayfinding_post',at=point(x,y),text=text))


def plastic_stool(name,x,y,w=35,h=37):
    return object_(name,y+h,[(x+2,y+2,w-4,h-2)],[
        [[x+4,y],[x+w-4,y],[x+w,y+h],[x+w-7,y+h],[x+w-10,y+14],
         [x+11,y+14],[x+7,y+h],[x,y+h]],rect(x+8,y+25,w-16,5)])


def tree(name,x,bottom,crown,branches):
    return object_(name,bottom,[(x-22,bottom-21,44,21)],branches,
        foliage=[rect(*crown)],wood_branches=True)


def phoco():
    obs=[pot('west_tree',(24,594,54,52),(0,389,105,206),[
             [[46,596],[46,515],[32,497],[27,477],[33,475],[42,490],
              [47,493],[47,463],[56,463],[56,497],[71,481],[77,485],
              [56,511],[57,596]]]),
         pot('west_small_pot',(110,608,28,32),(96,542,49,69)),
         pot('middle_tree',(491,591,56,51),(474,473,88,123),[rect(515,556,9,38)]),
         pot('station_tree',(1007,593,53,52),(985,471,88,128),[rect(1029,558,9,38)]),
         pot('station_east_pot',(1294,596,36,43),(1299,558,32,42)),
         pot('east_tree',(1348,593,48,54),(1321,499,82,98),[rect(1367,560,9,37)]),
         box('lodging_left_display',162,578,49,53),box('lodging_right_display',266,578,48,53),
         box('exchange_left_display',575,575,56,57),box('exchange_right_display',686,573,52,59),
         box('middle_display',813,520,53,116),box('drinks_display',868,524,47,112),
         box('station_counter',1161,573,92,60)]
    for i,(x,y) in enumerate([(409,618),(460,618),(547,617),(591,618),(692,617),
                               (738,618),(1172,618),(1219,618)]):
        obs.append(plastic_stool('street_stool_'+str(i),x,y))
    for i,x in enumerate([414,1169]):
        obs.append(object_('street_table_'+str(i),642,[(x,621,58,21)],[
            rect(x,602,58,10),rect(x+4,612,7,29),rect(x+48,612,7,29)]))
    for name,x,top,bottom,w in [('west',335,286,650,19),('middle',797,280,650,17),
                                 ('station',1289,258,650,17),('east',1455,301,635,17)]:
        obj=pole(name+'_utility_pole',x,top,bottom,w)
        for yy in [top+21,top+53,top+80]:
            obj['polygons'].append([point(a,b) for a,b in rect(x-32,yy,64,8)])
        obs.append(obj)
    for i,(x,w,base,goods) in enumerate([(1418,53,633,567),(1483,47,634,568),
                                       (1542,57,634,570),(1610,47,635,564)]):
        obs.append(object_('east_market_'+str(i),base,[(x,base-20,w,20)],
            [rect(x,581,w,base-581)],foliage=[rect(x,goods,w,582-goods)],wood_branches=False))
    return scene('HanoiPhoCo',635,(778,790),obs,{
        'HotelDoor':anchor(235,684),'ExchangeDoor':anchor(656,684),
        'TransitDoor':anchor(1123,689),'LocalSpot':anchor(880,691),
        'NpcHien':anchor(510,768),'ExitEast':anchor(1620,792)},[
        sign((151,417,167,48),'NHÀ NGHỈ','#ecdcad','#242c35',size=26),
        sign((570,401,178,49),'ĐỔI TIỀN','#e9d9a9','#232c35',size=26),
        sign((1088,400,176,49),'GA','#ecdcad','#25313b',size=31),
        sign((905,357,48,44),'PHỞ','#27362f',size=18),
        sign((813,498,105,18),'BIA HƠI','#2e5b42',size=11)],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'))


def longbien():
    obs=[pot('west_pot',(61,621,52,57),(50,533,72,92)),
         tree('west_tree',127,659,(84,384,86,158),[
             [[119,654],[121,543],[106,524],[101,498],[107,496],[117,519],
              [124,525],[124,484],[133,484],[133,525],[143,510],[149,514],
              [134,539],[131,655]]]),
         pole('west_utility_pole',173,319,690,20),
         pole('east_utility_pole',1610,289,690,20),
         object_('drinks_display',677,[(651,656,43,21)],[rect(651,607,43,68),
             rect(654,673,7,5),rect(683,673,7,5)])]
    # Every display includes its produce silhouette, not only the lower cabinet.
    for name,x,y,w,h,fruit in [
        ('west_one',142,615,61,60,(142,603,61,15)),('west_two',207,614,51,59,(207,590,51,26)),
        ('cabbages',276,617,58,59,(273,591,65,28)),('west_cartons',347,611,57,67,(350,584,42,28)),
        ('red_fruit',444,613,90,64,(445,573,88,41)),('green_fruit',537,615,89,63,(537,574,86,43)),
        ('back_red',717,608,30,64,(716,595,32,15)),('yellow_fruit',750,635,115,42,(750,607,111,29)),
        ('middle_green',908,636,32,44,(909,611,30,26)),('melon_stall',941,624,90,54,(938,591,95,34)),
        ('pink_basket',1034,620,48,23,(1034,596,47,25)),('middle_cartons',1090,614,56,64,(1094,573,45,42)),
        ('east_oranges',1199,614,87,63,(1195,579,91,36)),('east_fruit',1291,615,80,62,(1291,579,70,36)),
        ('far_yellow',1444,613,46,65,(1446,579,40,36)),('far_green',1526,615,50,64,(1522,593,58,24)),
        ('far_cartons',1590,615,55,64,(1597,609,38,9))]:
        fx,fy,fw,fh=fruit
        obs.append(object_(name,y+h,[(x,y+h-22,w,22)],[rect(x,y,w,h),
            [[fx,fy+fh],[fx,fy+7],[fx+fw*.17,fy+2],[fx+fw*.28,fy+6],
             [fx+fw*.44,fy],[fx+fw*.60,fy+5],[fx+fw*.75,fy+1],[fx+fw,fy+8],
             [fx+fw,fy+fh]]]))
    for i,(x,y,w,h) in enumerate([(404,646,25,31),(901,649,29,31),(1156,643,23,33),
                                  (1382,641,41,35),(1497,650,25,29)]):
        obs.append(box('floor_crate_'+str(i),x,y,w,h))
    obs += [plastic_stool('red_stool',1040,648,38,37),plastic_stool('blue_stool',1387,647,39,34)]
    # Travel stops stand on the pavement and have their own depth and collision.
    metro,metro_fitting=route_post('station_stop',719,719,'GA\nLONG BIÊN')
    airport,airport_fitting=route_post('airport_stop',1353,719,'XE BUÝT\nSÂN BAY')
    obs += [metro,airport]
    return scene('HanoiLongBien',675,(859,809),obs,{
        'AirportDoor':anchor(1353,770),'TransitDoor':anchor(719,770),
        'LocalSpot':anchor(492,728),'NpcDuc':anchor(996,817),'ExitWest':anchor(53,805)},[
        sign((13,439,31,26),'CHỢ','#e4d2a3','#463c2d',size=8)],
        fittings=[metro_fitting,airport_fitting],
        prompt_overrides={'AirportDoor':'E — The airport bus','TransitDoor':'E — Towards Long Biên station'},
        interaction_sizes=sizes('AirportDoor','TransitDoor','LocalSpot'))


def dongda():
    obs=[pot('cafe_flowers',(138,648,120,39),(127,579,139,72)),
         pot('workshop_pot',(574,611,56,42),(559,535,85,80)),
         pot('east_pot',(1609,611,49,42),(1613,553,47,64)),
         pole('west_utility_pole',340,154,674,19),
         tree('workshop_tree',598,673,(518,261,183,287),[
             [[581,668],[588,652],[588,524],[571,505],[564,477],[570,473],
              [585,498],[587,453],[598,454],[598,492],[609,464],[616,466],
              [607,502],[607,653],[615,669]]]),
         tree('grocery_tree',1160,676,(1070,209,190,324),[
             [[1140,673],[1148,657],[1149,517],[1137,499],[1135,457],[1142,455],
              [1151,487],[1150,426],[1162,422],[1164,477],[1181,448],[1188,452],
              [1177,489],[1169,517],[1169,657],[1183,673]]]),
         tree('east_tree',1601,674,(1510,244,162,282),[
             [[1584,670],[1591,657],[1592,502],[1578,482],[1577,457],[1585,456],
              [1594,479],[1593,436],[1604,434],[1605,478],[1623,447],[1630,453],
              [1611,502],[1610,657],[1618,670]]]),
         object_('cafe_front_rail',650,[(0,624,315,26)],[rect(0,547,315,8),
             *[rect(x,554,5,24) for x in range(11,314,24)],rect(0,578,315,72)],
             foliage=[rect(0,519,315,33)]),
         object_('workshop_board',651,[(379,632,49,19)],[rect(379,588,49,53),
             rect(380,641,5,10),rect(421,641,5,10)]),
         box('grocery_counter',934,597,196,26),
         box('grocery_crates_left',1000,620,46,29),box('grocery_crates_right',1049,609,33,40),
         plastic_stool('grocery_stool',1087,626,35,28),
         box('drink_machine',1186,517,58,136)]
    for i,x in enumerate([444,495,681,725,769,810,850]):
        # Body panels and tyres are separate from the handlebar gaps.
        obs.append(object_('scooter_'+str(i),643,[(x-2,624,29,19)],[
            [[x+2,589],[x+19,589],[x+25,599],[x+24,620],[x+19,631],
             [x+2,631],[x-3,619],[x-1,600]],rect(x+5,620,14,22),
            oval(x+10,585,6,5),tube((x+9,588),(x-8,579),3),
            tube((x+12,588),(x+28,579),3),rect(x-11,577,7,3),rect(x+24,577,7,3)]))
    return scene('HanoiDongDa',650,(859,794),obs,{
        'TransitDoor':anchor(1471,697),'LocalSpot':anchor(657,700),'NpcLan':anchor(1120,803)},[
        sign((94,350,193,43),'CÀ PHÊ','#e8d7ab','#24313a',size=30),
        sign((664,450,218,44),'SỬA XE','#293338',size=29),
        sign((945,450,177,37),'TẠP HÓA','#e1cb9a','#303634',size=26),
        sign((1384,397,173,44),'GA','#e6d6aa','#243139',size=30),
        sign((385,594,35,40),'SỬA\nXE','#eee8d5','#25352c',size=9,object='workshop_board')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def badinh():
    obs=[box('newspaper_kiosk',190,491,281,179),
         pot('west_flowers',(96,614,84,53),(84,527,113,90)),
         pot('middle_flowers',(466,612,69,54),(461,532,77,83)),
         pot('right_flowers',(765,613,94,54),(751,548,119,67)),
         object_('street_bin',670,[(1419,646,58,24)],[rect(1419,580,62,16),
             rect(1424,596,51,70),rect(1424,666,8,4),rect(1467,666,8,4)]),
         pole('east_utility_pole',1543,42,688,31)]
    # Closed compound gates and stone piers share the street boundary. The
    # foliage behind them is background scenery, never a second front cutout.
    for i,(a,b) in enumerate([(0,119),(170,518),(566,705),(750,916),(966,1253),
                               (1296,1386),(1432,1585),(1633,1672)]):
        polys=[rect(a,548,b-a,100),rect(a,475,b-a,7),rect(a,530,b-a,7)]
        for x in range(a+7,b-4,16):
            polys += [rect(x,470,4,79),[[x-3,470],[x+2,458],[x+7,470]]]
        obs.append(object_('compound_fence_'+str(i),650,[(a,630,b-a,20)],polys))
    for i,x in enumerate([119,518,705,916,1253,1386,1585]):
        obs.append(object_('compound_pier_'+str(i),650,[(x,626,49,24)],
            [rect(x,440,49,210),oval(x+24,431,8,8)]))
    for i,(x,w) in enumerate([(568,137),(1297,86)]):
        obs.append(object_('compound_gate_'+str(i),649,[(x,629,w,20)],[rect(x,478,w,170)]))
    bicycles=[]
    for x in [953,1045,1126,1213]:bicycles+=wheel(x,636,29)
    for x in [953,1126]:
        for a,b in [((x,636),(x+19,585)),((x+19,585),(x+52,636)),
                    ((x,636),(x+52,636)),((x+19,594),(x+77,594)),
                    ((x+52,636),(x+77,594)),((x+77,594),(x+90,636)),
                    ((x+19,594),(x+13,582)),((x+77,594),(x+72,585))]:
            bicycles.append(tube(a,b,4))
        bicycles += [rect(x+4,581,26,6),rect(x+59,584,27,6)]
    for x in [995,1080,1175,1226]:
        bicycles += [rect(x,621,5,49),tube((x,622),(x+8,610),5),rect(x+8,608,11,5),rect(x+17,613,5,56)]
    obs.append(object_('bicycles_and_racks',671,[(923,650,313,21)],bicycles))
    return scene('HanoiBaDinh',650,(747,812),obs,{
        'TransitDoor':anchor(1341,696),'LocalSpot':anchor(636,696)},[
        sign((238,449,187,33),'BÁO','#a83132',size=31),
        sign((1306,503,69,25),'GA →','#285548',size=13,object='compound_gate_1')],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def tayho():
    obs=[tree('lakeside_tree',31,700,(0,0,276,405),[
             [[13,697],[18,683],[17,411],[4,394],[0,375],[0,357],[11,388],
              [20,389],[20,327],[8,311],[0,284],[7,280],[21,304],[27,271],
              [36,270],[35,324],[44,328],[58,283],[71,264],[75,270],
              [66,298],[62,321],[83,324],[99,298],[107,300],[102,327],
              [82,348],[71,409],[53,443],[47,680],[52,697]]]),
         pot('west_flowers',(61,666,149,51),(53,593,166,76)),
         pot('middle_flowers',(609,666,147,51),(597,590,165,79)),
         pot('east_flowers',(1452,666,152,51),(1437,590,178,80))]
    for i,(a,b) in enumerate([(48,385),(434,744),(790,1068),(1115,1672)]):
        polys=[rect(a,597,b-a,7),rect(a,664,b-a,8)]
        for x in range(a+6,b-3,24):polys.append(rect(x,604,4,60))
        for x in range(a+20,b-24,85):
            polys += [tube((x,642),(x+15,622),4),tube((x+15,622),(x+30,642),4),
                      tube((x+30,642),(x+15,656),4),tube((x+15,656),(x,642),4)]
        obs.append(object_('lake_rail_'+str(i),676,[(a,658,b-a,18)],polys))
    for i,x in enumerate([8,385,744,1068]):
        obs.append(object_('lake_pier_'+str(i),683,[(x,661,47,22)],[rect(x,580,47,103),
             rect(x-2,577,51,11),oval(x+24,560,10,11)]))
    stop,fixture=route_post('city_bus_stop',947,715,'XE BUÝT\nTRUNG TÂM')
    obs.append(stop)
    return scene('HanoiTayHo',678,(819,816),obs,{
        'TransitDoor':anchor(947,765),'LocalSpot':anchor(473,729)},[
        sign((1403,307,241,58),'CÀ PHÊ','#ead8aa','#293137',size=35)],
        fittings=[fixture],prompt_overrides={'TransitDoor':'E — The city bus'},
        # Ripples are limited to unobstructed water, away from trees and rails.
        animation_patches=[dict(kind='water',rect=[*point(245,429),*point(827,106)])],
        interaction_sizes=sizes('TransitDoor','LocalSpot'))


def hotel():
    obs=[object_('reception',682,[(359,650,648,32)],[rect(357,493,652,22),
             rect(368,515,630,139),rect(359,654,648,28),rect(393,471,65,22),
             rect(484,436,69,57),rect(494,466,38,26),rect(819,410,65,83),
             rect(909,483,30,10),oval(924,483,11,8),rect(942,453,46,40)],
             foliage=[rect(920,381,87,75)],wood_branches=True),
         pot('west_lobby_tree',(1062,530,61,98),(1051,355,91,179),[rect(1088,474,13,59)]),
         pot('east_lobby_tree',(1378,543,62,86),(1363,382,88,163),[rect(1402,495,11,51)]),
         object_('umbrella_stand',685,[(279,663,60,22)],[rect(279,555,60,129),
             tube((287,554),(283,522),10),tube((327,555),(330,528),10),
             tube((284,520),(285,500),9),tube((285,500),(294,491),9),
             tube((294,491),(308,496),9),tube((308,496),(311,514),9),
             tube((329,529),(331,508),8),tube((331,508),(322,503),8),
             tube((322,503),(313,512),8)]),
         object_('garden_bench',630,[(1145,605,202,25)],[rect(1145,544,202,20),
             rect(1145,564,202,17),rect(1152,581,20,47),rect(1320,581,20,47),
             rect(1172,606,148,13)]),
         object_('garden_box',602,[(1143,579,221,23)],[rect(1143,491,221,111)])]
    return scene('HanoiHotel',622,(773,818),obs,{
        'Point':anchor(680,732),'Exit':anchor(160,724)},[
        sign((509,244,338,62),'KHÁCH SẠN HÀ NỘI','#cdbb94','#303b3c',size=29),
        sign((941,195,49,139),'AN\nKHANG','#a03229','#e8c055',size=17)],
        clerks={'Point':anchor(682,615)},interaction_sizes=sizes('Point','Exit'))


def exchange():
    obs=[object_('exchange_counter',676,[(369,649,870,27)],[rect(369,523,870,18),
             rect(370,541,868,132),rect(359,215,9,308),rect(1230,214,9,309),
             rect(479,422,103,80),rect(516,483,25,32),rect(497,514,66,8),
             rect(404,459,49,62),rect(449,496,27,25),rect(601,506,21,14),
             rect(746,452,57,70),rect(871,459,57,63),rect(1055,478,53,43),
             rect(1144,489,44,34)],glass=[rect(371,214,857,306)],
             foliage=[rect(1132,435,68,58)]),
         object_('leaflet_rack',690,[(275,668,76,22)],[
             [[282,483],[345,483],[350,491],[350,686],[275,688],[277,537]],
             rect(280,668,72,21)])]
    return scene('HanoiExchange',665,(849,774),obs,{
        'Point':anchor(814,722),'Exit':anchor(1442,716)},[
        sign((552,75,560,77),'THU ĐỔI NGOẠI TỆ','#193f70',size=38),
        sign((615,157,433,43),'MONEY EXCHANGE','#193f70',size=28),
        sign((963,249,222,162),'USD   •••\nEUR   •••\nJPY   •••\nSGD   •••','#1e2830',size=24)],
        clerks={'Point':anchor(815,625)},interaction_sizes=sizes('Point','Exit'),
        walk_bottom=point(0,818)[1])


def transit():
    obs=[box('west_column',77,0,52,613),box('middle_column',693,0,51,614),
         box('east_column',1568,0,51,735),
         object_('platform_bench',742,[(75,714,265,28)],[rect(92,619,242,15),
             rect(94,640,237,14),rect(75,660,265,22),rect(91,682,18,57),
             rect(292,682,18,57),rect(110,721,22,10),rect(309,720,20,10)]),
         box('platform_bin',414,558,78,161),
         object_('gate_west',742,[(569,708,76,34)],[
             [[569,592],[599,557],[643,557],[643,698],[615,740],[569,740]]]),
         object_('gate_middle',742,[(759,708,74,34)],[
             [[759,592],[791,557],[831,557],[831,699],[804,740],[759,740]]]),
         object_('stair_ticket_gate',745,[(911,709,59,36)],[
             [[911,546],[932,530],[975,530],[966,546],[966,744],[911,744]]]),
         object_('stair_glass',741,[(967,715,230,26)],[rect(1044,535,10,200),
             rect(970,533,228,8),rect(1192,540,8,195),
             rect(1136,608,20,106),tube((1136,713),(1103,737),9)],
             glass=[rect(970,542,73,190),rect(1055,542,136,190)]),
         object_('stair_east_rail',739,[(1460,711,204,28)],[
             [[1460,733],[1502,587],[1519,555],[1547,548],[1565,558],
              [1564,737],[1554,737],[1554,566],[1537,560],[1523,569],
              [1514,591],[1475,733]],rect(1570,721,94,15)],
             glass=[[[1480,726],[1518,594],[1541,572],[1547,723]]]),
         object_('stair_opening',739,[(1198,631,474,108)],[]),
         object_('native_ticket_machine',743,[(661,717,61,26)],[])]
    return scene('HanoiTransit',607,(881,804),obs,{
        'Machine':anchor(691,789),'Platform':anchor(870,656),'Exit':anchor(1400,791)},[
        sign((270,187,258,45),'GA HÀ NỘI','#203f70',size=30),
        sign((269,239,263,41),'Hanoi Metro','#203f70',size=28)],
        fittings=[dict(kind='ticket',at=point(691,743))],
        interaction_sizes=sizes('Machine','Platform','Exit'),walk_bottom=point(0,840)[1])


def airport():
    obs=[box('west_column',97,0,52,626),box('east_column',1310,0,53,627),
         pot('west_plant',(44,587,57,48),(28,504,91,86)),
         pot('middle_plant',(784,586,59,49),(771,521,84,68)),
         object_('luggage_belt',737,[(1055,663,617,74)],[
             [[1055,641],[1071,627],[1144,607],[1672,605],[1672,737],
              [1126,737],[1070,725],[1055,709]],
             rect(1292,540,65,67),rect(1369,539,85,68),
             rect(1415,513,24,6),rect(1433,518,6,21)],
             animation_patches=[dict(kind='conveyor',rect=[*point(1466,621),*point(206,31)])]),
         object_('check_in_kiosk',714,[(937,688,62,26)],[])]
    for i,x in enumerate([172,236,301,366,461,525,589,653]):
        obs.append(chair('terminal_seat_'+str(i),x,552,59,92))
    return scene('HanoiAirport',625,(850,773),obs,{
        'Point':anchor(968,763),'Exit':anchor(1023,670)},[
        sign((184,199,220,42),'SẢNH ĐẾN','#1b3e6b',size=30),
        sign((184,250,220,34),'Arrivals','#1b3e6b',size=26),
        sign((1354,200,180,82),'NỘI BÀI\nHAN','#1e416e',size=31),
        sign((962,190,244,112),'KHỞI HÀNH\nHÀ NỘI · SEOUL\nTOKYO · PARIS','#1b252a','#eed263',size=18)],
        fittings=[dict(kind='ticket',at=point(968,714))],clerks={},
        prompt_overrides={'Point':'E — The check-in terminal','Exit':'E — Back to the city bus'},
        interaction_sizes=sizes('Point','Exit'),walk_bottom=point(0,837)[1])


def build():
    from .hanoi_finish import finish
    return finish({'HanoiPhoCo':phoco(),'HanoiLongBien':longbien(),'HanoiDongDa':dongda(),
            'HanoiBaDinh':badinh(),'HanoiTayHo':tayho(),'HanoiHotel':hotel(),
            'HanoiExchange':exchange(),'HanoiTransit':transit(),'HanoiAirport':airport()})
