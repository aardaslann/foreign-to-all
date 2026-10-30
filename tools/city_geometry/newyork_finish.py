"""New York masks measured on the September replacement images (1672x941).

Consumed by preparation export so image/layout hashes cover these revisions.
Floor contacts exclude visual height; gaps are never rectangles of pavement.
"""
from .shapes import point, rect, tube, object_, sign
from .moscow import oval, pot
from .hanoi import pole


def replace(row, *objects):
    by_id={o['id']:o for o in objects}
    row['objects']=[by_id.pop(o['id'],o) for o in row['objects']]+list(by_id.values())


def slat_crate(name,x,y,w,h):
    p=[rect(x,y,w,8),rect(x,y+h-11,w,9),rect(x+2,y,8,h),rect(x+w-10,y,8,h)]
    for yy in range(int(y+20),int(y+h-12),19):p.append(rect(x,yy,w,8))
    return object_(name,y+h,[(x,y+h-23,w,23)],p)


def stoop(name,x,y,w,h,rail_top):
    return object_(name,y+h,[(x,y+2,w,h-2)],[rect(x,y,w,h),
        [[x-28,y+h],[x-28,y+h-22],[x-20,rail_top+9],[x-17,rail_top],
         [x-8,rail_top],[x-7,rail_top+7],[x-7,y+h-22],[x-1,y+h-22],[x-1,y+h]],
        [[x+w+1,y+h],[x+w+1,y+h-22],[x+w+4,rail_top+7],[x+w+7,rail_top],
         [x+w+15,rail_top],[x+w+17,rail_top+8],[x+w+20,y+h-22],[x+w+25,y+h-22],[x+w+25,y+h]]])


def iron(name,x,y,w,bottom):
    p=[rect(x,y+19,w,7),rect(x,bottom-23,w,7)]
    for xx in range(x+2,x+w,17):
        p += [rect(xx,y+12,5,bottom-y-12),oval(xx+2,y+8,4,5)]
    return object_(name,bottom,[(x,bottom-15,w,15)],p)


def apply(rows):
    r=rows['NewYorkLowerEast']
    replace(r,stoop('stoop',598,540,125,160,485),
        object_('trash_can',699,[(1326,679,57,20)],[
            rect(1327,628,55,61),oval(1355,689,28,10),oval(1353,611,34,15),rect(1323,612,63,13)]),
        object_('dumpster',697,[(1530,679,116,18)],[
            [[1522,603],[1543,578],[1657,579],[1657,681],[1526,681]],
            rect(1529,681,10,14),rect(1634,681,11,14)]),
        object_('delivery_boxes',695,[(1427,673,83,22)],
            [rect(1426,650,85,43),rect(1443,615,59,38)]))
    # Split the open wooden stands from their goods instead of sampling floor.
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('produce_')]
    for i,(x,y,w,h) in enumerate([(757,641,55,66),(816,650,46,55),(864,655,49,50),(1040,651,57,56)]):
        crate=slat_crate('produce_'+str(i),x,y,w,h)
        crate['foliage']=[[point(a,b) for a,b in rect(x,y-29,w,30)]]
        r['objects'].append(crate)
    r['objects'].append(object_('fruit_table',705,[(922,687,99,18)],
        [rect(921,674,97,10),rect(923,684,8,20),rect(1007,684,8,20)],
        foliage=[rect(923,646,90,29)]))
    r['animation_patches']=[dict(kind='washer',rect=[*point(x,590),*point(52,51)]) for x in [261,337]]

    r=rows['NewYorkHarlem']
    replace(r,*[stoop('stoop_'+str(i),x,521 if i else 541,w,160 if i else 141,458)
                for i,(x,w) in enumerate([(186,130),(532,136),(880,136)])],
        *[iron('areaway_'+str(i),x,551,w,678) for i,(x,w) in enumerate([(0,162),(337,175),(693,157),(1037,166)])],
        object_('west_tree',658,[(68,641,25,17)],[
            [[69,657],[71,547],[42,516],[44,508],[75,537],[77,484],[87,484],
             [85,535],[111,506],[117,510],[87,548],[83,657]]],foliage=[rect(0,294,181,240)],wood_branches=True),
        object_('east_tree',673,[(1149,657,27,16)],[
            [[1151,673],[1154,503],[1134,478],[1139,472],[1156,491],[1157,422],
             [1167,422],[1166,493],[1187,469],[1191,475],[1166,507],[1164,673]]],
             foliage=[rect(1037,214,204,286)],wood_branches=True),
        pot('stoop_pot_a',(353,651,61,37),(350,612,69,43)),
        pot('stoop_pot_b',(440,647,46,40),(436,612,56,40)),
        object_('white_chair',691,[(1123,676,50,15)],[
            tube((1124,610),(1128,686),5),tube((1166,610),(1173,686),5),
            rect(1125,606,40,5),rect(1125,635,44,5),rect(1124,646,50,11),
            rect(1132,659,5,28),rect(1162,659,5,28),
            *[rect(x,613,4,20) for x in [1132,1142,1152,1161]]]),
        pole('parking_meter',1454,617,737,16),
        object_('hydrant',737,[(1611,721,35,16)],[
            rect(1614,679,24,43),oval(1626,722,20,10),rect(1618,663,15,18),
            oval(1626,662,8,8),oval(1609,693,9,11),oval(1644,693,9,11)]))
    r['objects'].append(pot('tall_stoop_plant',(341,639,34,37),(324,426,81,214)))
    r['lettering'][0]=sign((1214,191,445,143),'HARLEM MARKET','#07554d',size=35)

    r=rows['NewYorkWilliamsburg']
    r['opaque_plate']=True
    replace(r,object_('workshop_bin',737,[(4,716,128,21)],[
            [[0,639],[10,619],[137,619],[138,638],[132,644],[132,722],[0,722]],
            rect(6,721,12,14),rect(117,721,11,14)]),
        object_('shipping_pallets',726,[(1427,705,120,21)],
            [rect(1426,y,123,10) for y in range(599,724,22)]+
            [rect(x,599,11,126) for x in [1436,1484,1525]]),
        object_('cafe_menu',740,[(694,724,67,16)],[
            [[700,651],[753,651],[758,729],[751,729],[749,726],[700,726],[699,739],[692,739]],
            rect(751,720,8,19)]),
        pot('cafe_plant',(615,693,63,40),(603,638,87,57)),
        pot('shipping_plant',(1147,684,47,47),(1140,600,66,85)),
        object_('window_trough',735,[(1015,720,103,15)],[rect(1012,697,109,12),
            rect(1016,709,9,24),rect(1107,709,10,24)],foliage=[rect(1013,665,108,34)]),
        *[pole('safety_post'+str(i),x,648 if i<3 else 671,733 if i<3 else 775,19)
          for i,x in enumerate([427,463,1249,1625])],
        *[object_('cafe_stool'+str(i),721,[(x,699,54,22)],[rect(x,653,54,10),
            tube((x+6,663),(x+1,720),7),tube((x+46,663),(x+53,720),7),rect(x+6,691,40,6)])
          for i,x in enumerate([836,925])])
    r['objects'] += [object_('pallet_jack',719,[(1312,701,86,18)],[
        rect(1310,700,78,8),rect(1347,691,39,15),rect(1361,674,31,21),
        rect(1384,631,7,51),oval(1381,708,12,10),
        tube((1387,635),(1378,622),5),tube((1378,622),(1383,613),5),
        tube((1383,613),(1396,613),5),tube((1396,613),(1400,623),5),tube((1400,623),(1387,635),5)]),
        pole('parking_meter',1590,658,775,13)]

    r=rows['NewYorkJacksonHeights']
    replace(r,*[object_(name,774,[(x,749,78,25)],[rect(x+10,253,55,449),rect(x,702,78,71),
        [[x-60,226],[x+129,226],[x+94,249],[x+65,291],[x+10,291],[x-15,252]]])
        for name,x in [('west_viaduct_column',396),('east_viaduct_column',1236)]],
        object_('market_bin',756,[(1137,736,73,20)],[rect(1135,652,77,91),oval(1173,744,38,11),
            rect(1135,637,76,15),oval(1174,635,39,7)]))
    r['objects']=[o for o in r['objects'] if not o['id'].startswith('market_display')]
    r['objects'] += [object_('bakery_boxes',718,[(499,691,70,27)],
        [rect(499,658,33,59),rect(538,630,32,87),rect(505,631,30,28)]),
        object_('fruit_displays',733,[(722,710,374,23)],[
            rect(723,676,89,39),rect(815,686,39,43),rect(858,697,120,23),
            rect(859,638,117,15),rect(869,591,218,39),rect(990,670,104,15),
            rect(992,695,102,8),rect(992,725,101,7),rect(990,685,9,48),rect(1082,685,11,48),
            rect(860,717,10,14),rect(966,717,9,14),rect(867,650,8,48),rect(970,650,8,48)],
            foliage=[rect(721,621,133,66),rect(858,642,125,56)])]
    r['animation_patches']=[dict(kind='train',rect=[*point(0,0),*point(1672,113)])]

    r=rows['NewYorkHotel']
    replace(r,object_('reception',652,[(486,610,627,42)],
        [rect(478,472,642,17),rect(486,489,627,163)]),
        object_('sofa',665,[(1186,644,347,21)],[rect(1188,506,333,117),
            rect(1177,551,23,74),rect(1518,551,19,74),rect(1187,624,15,40),rect(1517,623,14,41)]),
        pot('east_plant',(1562,568,64,76),(1543,368,102,204),[rect(1588,488,9,80)]),
        object_('luggage_cart',657,[(278,636,160,21)],[
            rect(270,610,174,16),rect(279,451,9,160),rect(428,451,9,160),
            *[tube(a,b,8) for a,b in zip([(283,455),(293,435),(311,422),(351,420),(405,422),(426,437)],
                                        [(293,435),(311,422),(351,420),(405,422),(426,437),(432,455)])],
            rect(347,401,14,27),rect(300,540,32,70),rect(339,501,74,110),
            rect(311,512,7,31),rect(309,509,15,6),rect(359,490,40,11),
            oval(300,640,17,17),oval(414,640,19,18)]))
    r['clerks']['Point']=point(804,528)
    r['lettering'][0]=sign((590,211,423,56),'MIDTOWN HOTEL','#00000000','#2f3038',size=29)

    r=rows['NewYorkExchange']
    replace(r,object_('exchange_counter',641,[(573,604,676,37)],
        [rect(565,454,690,17),rect(573,471,676,169),rect(590,276,11,177),rect(832,276,19,177)],
        glass=[rect(601,277,231,177),rect(851,277,386,177)]),
        object_('queue_rail',736,[(622,714,714,22)],[
            rect(666,529,623,15),*[rect(x-10,550,18,167) for x in [654,973,1303]],
            *[rect(x-13,517,26,36) for x in [654,973,1303]],
            *[rect(x-33,717,66,17) for x in [654,973,1303]]]),
        pot('plant',(1551,570,58,74),(1522,374,111,198),[rect(1572,499,10,71)]),
        object_('bin',644,[(1455,625,67,19)],[rect(1453,541,68,102),rect(1450,526,76,21)]))
    for i,x in enumerate([300,411]):
        replace(r,object_('waiting_seat'+str(i),664,[(x,647,97,17)],[rect(x+3,506,93,84),
            rect(x,596,97,25),rect(x+3,622,12,40),rect(x+85,622,11,40)]))
    # Approach from the open left side, then along the counter's front.
    r['anchors']['Point']=point(886,675)
    r['clerks']['Point']=point(896,497)
    r['floor']=point(0,600)[1]

    r=rows['NewYorkTransit']
    replace(r,*[object_(name,754,[(x-8,717,137,37)],[rect(x+10,31,99,681),rect(x,712,121,23),rect(x-8,735,137,18)])
        for name,x in [('west_column',323),('east_column',1223)]],
        object_('platform_bench',723,[(598,696,411,27)],[
            rect(616,564,376,21),rect(617,590,375,14),rect(617,607,375,22),
            rect(592,610,17,53),rect(995,610,17,53),rect(592,643,418,19),rect(602,662,407,15),
            rect(601,677,18,43),rect(989,676,20,45)]),
        object_('bin',741,[(1355,722,81,19)],[rect(1355,631,80,99),rect(1357,729,75,10),
            rect(1355,595,82,26),rect(1360,620,7,13),rect(1426,620,8,13)]),
        object_('stair_side',742,[(0,696,203,46)],[
            [[0,578],[202,718],[202,741],[0,741]],tube((0,426),(199,607),9),
            tube((0,468),(194,644),9),*[rect(x,491+x*.9,6,93-x*.14) for x in range(8,197,18)]]))
    r['anchors']['Platform']=point(1127,690)
    r['motion_layers']=[dict(kind='doors',rect=[*point(1000,402),*point(173,239)])]

    r=rows['NewYorkAirport']
    replace(r,object_('information_counter',851,[(653,808,333,43)],[rect(651,744,337,103),
        rect(697,725,243,121),rect(856,680,64,44),rect(879,718,20,11)],
        foliage=[rect(942,678,43,61)]),
        object_('carousel',786,[(1006,737,666,49)],[
            [[1006,681],[1078,632],[1672,632],[1672,784],[1030,783],[1005,755]]]),
        object_('flight_display',649,[(167,627,19,22)],[rect(99,337,166,248),rect(167,585,19,65)]))
    # The original trolley approximation was a hotel bell cart. These are
    # nested airport trolleys: hollow rails, individual wheels, open handles.
    r['objects']=[o for o in r['objects'] if o['id']!='luggage_trolleys']
    polys=[]
    for x in range(621,817,28):
        polys += [rect(x,605,26,6),rect(x+4,612,5,74),rect(x+22,612,5,73),
                  rect(x+4,685,25,7),oval(x+11,714,12,12)]
    r['objects'].append(object_('luggage_trolleys',727,[(623,708,213,19)],polys))
    r['anchors']['Point']=point(818,893)
    r['anchors']['Exit']=point(1570,865)
    r['spawn']=point(548,852)
    r['clerks']['Point']=point(817,773)
    r['animation_patches']=[dict(kind='conveyor',rect=[*point(1090,650),*point(582,41)])]
    # The replacement images already contain crafted sign frames; draw only
    # native lettering inside them instead of covering them with flat slabs.
    for row in rows.values():
        if row.get('texture','').split('/')[-1].startswith('NewYork'):
            for label in row['lettering']:label['background']='#00000000'
    rows['NewYorkHarlem']['lettering']=[
        sign((1223,202,428,123),'HARLEM\nMARKET','#00000000',size=32),
        sign((1220,346,432,32),'COFFEE · SANDWICHES','#00000000','#204743',size=17)]
    rows['NewYorkExchange']['lettering']=[
        sign((587,146,646,80),'CURRENCY EXCHANGE','#00000000',size=32),
        sign((1297,145,210,255),'RATES\nUSD · EUR\nGBP · JPY\nCAD','#00000000',size=22)]
    rows['NewYorkAirport']['lettering']=[
        sign((289,142,449,80),'GATES A1–A8','#00000000',size=32),
        sign((995,141,486,135),'BAGGAGE CLAIM →\nGROUND TRANSPORT →','#00000000',size=25),
        sign((1145,361,340,74),'COFFEE','#00000000',size=32),
        sign((719,773,204,40),'INFORMATION','#00000000','#61472f',size=16,object='information_counter')]
    rows['NewYorkHotel']['clerks']['Point']=point(804,499)
    rows['NewYorkHotel']['lettering'][1]=sign((652,508,305,26),'RECEPTION','#00000000',size=17,object='reception')
    rows['NewYorkTransit']['lettering'][0]=sign((642,264,349,44),'42 STREET','#00000000',size=30)
    return rows
