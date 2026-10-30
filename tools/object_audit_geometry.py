"""Corrections from the complete 28-scene artwork/collider inventory, 2026-09-13.

Coordinates here are original 1672x941 art pixels, not enlarged screenshots.
Architecture beyond the world boundary is deliberately kept as background.
"""
from math import ceil, floor


def apply_audit(data, object_, rect, tube, wheel):
    sx, sy = 1152/1672, 648/941

    def points(poly):
        return [[round(x*sx,2),round(y*sy,2)] for x,y in poly]

    def item(scene, name):
        return next(o for o in data[scene]['objects'] if o['id']==name)

    def shapes(scene, name, polygons, replace=False):
        obj=item(scene,name)
        if replace: obj['polygons']=[]
        obj['polygons'] += [points(p) for p in polygons]

    def feet(scene, name, boxes):
        item(scene,name)['footprints']=[[round(x*sx,2),round(y*sy,2),round(w*sx,2),round(h*sy,2)] for x,y,w,h in boxes]

    def polygon_feet(scene, name, poly):
        # Small adjoining horizontal bands preserve an octagonal/sloping
        # footprint while retaining the Rect2 contract used by crowds/spawns.
        boxes=[]
        for y in range(floor(min(p[1] for p in poly)),ceil(max(p[1] for p in poly)),4):
            bottom=min(y+4,max(p[1] for p in poly))
            samples=[]
            for scan in (y+.01,(y+bottom)*.5,bottom-.01):
                hits=[]
                for a,b in zip(poly,poly[1:]+poly[:1]):
                    if min(a[1],b[1])<=scan<max(a[1],b[1]):
                        hits.append(a[0]+(scan-a[1])*(b[0]-a[0])/(b[1]-a[1]))
                samples += hits
            if samples: boxes.append((min(samples),y,max(samples)-min(samples),bottom-y))
        feet(scene,name,boxes)

    def leaves(scene, name, bounds, trunk=()):
        item(scene,name)['foliage']=[points(rect(*bounds))]
        if trunk: shapes(scene,name,[trunk])

    # The stairwell is below pavement level, not walkable floor. Its back
    # ground edge is below the tall rail in the picture; leave the pavement
    # behind that edge reachable from the left without crossing the hole.
    feet('Mitte','stairs',[(757,663,217,42)])
    # The handle existed in the plate but the foreground omitted its drops.
    shapes('Mitte','bicycle',[
        [[708,605],[729,605],[732,608],[729,613],[723,613],[723,619],
         [719,621],[715,619],[714,613],[709,613],[706,609]],
        tube((715,612),(721,628),4)])
    item('Mitte','bicycle')['accents']=[
        {'points':points([(715,620),(713,614),(709,611),(708,607),(711,605),(728,605),(731,607),(729,611),(725,611)]),'width':round(4*sx,2),'color':'#182833'},
        {'points':points([(712,606),(727,606),(729,607)]),'width':round(1.5*sx,2),'color':'#94a5ab'}]

    # The park fence was absent from the geometry inventory. Front bars are
    # narrow masks, not a solid rectangle of lawn. The open gate stays open.
    front=[]
    for a,b,top in [(981,1199,584),(1339,1672,620)]:
        front += [rect(a,top+23,b-a,8),rect(a,685,b-a,7)]
        for x in range(a,b,21):
            front += [rect(x,top+6,6,109 if top==584 else 76),
                      [[x-1,top+6],[x+3,top],[x+7,top+6],[x+7,top+12],[x-1,top+12]]]
    # The tall gate is swung to the right. Its narrow foot does not seal
    # the passage between x=1200 and x=1330.
    front += [rect(1208,507,10,201),rect(1332,480,13,228),
              tube((1218,548),(1333,503),9),rect(1217,674,119,9),
              rect(1238,566,78,98)]
    for x in [1230,1254,1280,1307]:
        front += [rect(x,550-(x-1230)*.35,6,145+(x-1230)*.35)]
    object_('BerlinPrenzlberg','park_fence',708,
            [(981,688,218,20),(1333,690,339,19),(1207,687,13,21)],front)
    # The lawn remains reachable through the open gate. Only the swing's
    # feet and rear rail are solid, not a rectangular patch of garden.
    object_('BerlinPrenzlberg','swing',647,[(1394,634,43,15),(1600,634,46,15)],
        [tube((1399,645),(1458,450),9),tube((1458,450),(1482,643),8),
         tube((1596,450),(1639,645),9),tube((1596,450),(1582,643),8),
         tube((1458,450),(1596,450),13),
         tube((1481,461),(1481,594),4),tube((1550,461),(1550,594),4),
         rect(1477,591,77,13)])

    # Entire fountain rim/step, not two central rectangles with exposed ends.
    polygon_feet('IstanbulHan','fountain',
        [[753,728],[916,728],[975,758],[993,800],[1011,826],
         [917,869],[737,869],[636,826],[655,800],[668,758]])
    # Sort at the basin's ground centreline (through its wide side corners),
    # not the furthest front step. Otherwise a person beside either front
    # corner is erased by the bowl even though their feet are outside it.
    item('IstanbulHan','fountain')['sort_y']=round(826*sy,2)
    feet('IstanbulHan','tree_planter',[(59,738,172,68)])
    leaves('IstanbulHan','tree_planter',(0,46,379,444),
        [[117,739],[102,735],[115,721],[124,696],[123,543],[111,513],
         [99,474],[106,448],[118,463],[143,506],[143,451],[156,451],
         [158,499],[185,448],[223,388],[237,389],[212,452],[173,527],
         [167,568],[165,697],[174,725],[195,740]])

    # A street-tree trunk is an object even when its crown is high overhead.
    def street_tree(scene,name,x,y,w,h,base):
        bx,by,bw,bh=base
        object_(scene,name,by+bh,[base],
                [rect(x,y,w,h),rect(bx,by,bw,bh)])

    for n,x,y,w,h,base in [
        ('tree_west',49,451,17,201,(25,647,67,14)),
        ('tree_mid',327,452,19,198,(308,646,56,17)),
        ('tree_market',957,450,20,203,(943,640,42,16))]:
        street_tree('BerlinPrenzlberg',n,x,y,w,h,base)
    for n,x,y,w,h,base in [
        ('tree_west',44,541,19,202,(9,735,91,14)),
        ('tree_east',1630,529,20,214,(1598,738,74,13))]:
        street_tree('BerlinKreuzberg',n,x,y,w,h,base)
    street_tree('Mitte','tree_west',28,498,15,151,(1,639,68,14))
    street_tree('MitteOst','tree_east',1640,530,20,127,(1619,653,53,16))

    # Independent street furniture missed by the old small object list.
    object_('Mitte','cat_poster',657,[(1320,650,71,7)],
            [rect(1320,510,69,84),rect(1322,594,6,62),rect(1382,594,6,62)])
    for n,x,y,w,h in [('menu_board',1419,638,61,96),('station_board',1040,578,58,156)]:
        object_('BerlinKreuzberg',n,y+h,[(x,y+h-15,w,15)],
                [[[x+10,y],[x+w-10,y],[x+w-14,y+h-20],[x+13,y+h-20]],
                 tube((x+10,y+3),(x+4,y+h),7),
                 tube((x+w-10,y+3),(x+w-4,y+h),7)])
    object_('Kiez','loose_rock',846,[(760,827,42,19)],
            [[[770,805],[784,802],[796,810],[802,825],[801,840],
              [791,846],[767,845],[758,836],[758,824]]])

    # Correct mirrored booth backs, and include objects on the table tops.
    for index,x in enumerate([224,800,1331]):
        right=item('Restaurant','booth_'+str(index)+'_1')
        origin=x+243
        right['polygons']=[points([[origin+149,631],[origin+115,590],
            [origin+90,590],[origin+90,735],[origin,735],[origin,803],
            [origin+13,803],[origin+13,887],[origin+149,887]])]
    for index,mx in enumerate([335,896]):
        shapes('Restaurant','table_'+str(index),[rect(mx,587,44,75),rect(mx+5,640,24,35),rect(mx+49,657,38,38)])
    shapes('Restaurant','table_2',[rect(1428,631,26,44),rect(1470,661,39,34)])
    shapes('IstanbulYusuf','packing_crates',
        [[[194,646],[321,646],[321,664],[315,664],[315,744],[200,744],[200,664],[194,664]]])

    # Filled coat/planter crops are harmless behind an inaccessible wall, but
    # reachable floor plants need their foliage and trunk above the pot too.
    for scene,name,bounds in [
        ('IstanbulHastane','plant',(759,673,120,116)),
        ('IstanbulKarakol','plant_front',(1355,672,133,126)),
        ('IstanbulKarakol','plant_back',(1477,438,112,118)),
        ('IstanbulYusuf','plant_pot',(1470,416,144,185)),
        ('IstanbulHavalimani','plant_620',(602,467,92,134)),
        ('IstanbulHavalimani','plant_41',(12,332,127,227)),
        ('HotelLobby','planter_right',(1255,281,133,259)),
        ('HotelLobby','planter_left',(381,358,91,133)),
        ('HotelFloor','plant',(1595,286,77,169)),
        ('Room01','plant',(182,291,88,181)),
        ('IstanbulOtel','planter',(1211,331,87,121))]:
        leaves(scene,name,bounds)

    # Tall trunks below foliage remain opaque; the shader only cuts leaf gaps.
    shapes('IstanbulYusuf','plant_pot',[tube((1541,513),(1546,601),9)])
    shapes('IstanbulHavalimani','plant_620',[tube((646,551),(646,600),8)])
    shapes('IstanbulHavalimani','plant_41',[tube((70,491),(71,559),13)])
    shapes('HotelLobby','planter_right',[tube((1313,386),(1313,543),10)])
    shapes('HotelLobby','planter_left',[tube((426,428),(427,492),7)])
    shapes('HotelFloor','plant',[tube((1642,363),(1642,455),8)])

    # Stand tops, shelves, bags and legs that touch the walking strip.
    for scene,name,x,y,w,h in [
        ('Mitte','hotel_plant_west',475,543,49,83),
        ('Mitte','hotel_plant_east',635,538,49,85),
        ('BerlinKreuzberg','produce_stall',175,664,371,68),
        ('BerlinKreuzberg','shop_crates',740,667,124,70),
        ('Hospital','iv_stand',774,401,54,208),
        ('Police','side_table',1430,479,120,144),
        ('Airport','bin_back',1548,519,77,104),
        ('IstanbulCarsi','plant_edge',0,637,32,36),
        ('IstanbulBeyoglu','plant_edge',0,625,42,44),
        ('IstanbulLokanta','plant_back',1563,446,81,99)]:
        # These objects are against the wall. Their full bodies are opaque;
        # small, independently bounded feet stop contact at the visible base.
        object_(scene,name,y+h,[(x,y+h-16,w,16)],[rect(x,y,w,h)])

    # Do not copy an entire rectangle around the IV pole or side table legs.
    shapes('Hospital','iv_stand',[
        rect(797,408,5,190),rect(775,401,47,5),
        rect(786,434,20,23),tube((801,597),(778,605),5),
        tube((801,597),(822,605),5)],True)
    shapes('Police','side_table',[rect(1430,479,120,13),
        rect(1433,492,8,131),rect(1539,492,8,131)],True)

    # The floor-standing carts need their wheels and curved handles, while
    # preserving the gaps around the wheels and between the frame rails.
    for scene,name,x,y,w,h in [
        ('IstanbulKarakoy','red_cart',555,708,138,126),
        ('IstanbulKarakoy','grey_cart',1001,714,126,123)]:
        body_y=y if name=='red_cart' else y+33
        shapes(scene,name,[rect(x+2,body_y,w-4,h-31-(body_y-y)),
            rect(x+10,y+h-34,w-20,8),
            *wheel(x+27,y+h-16,15,16,15),
            *wheel(x+w-28,y+h-16,15,16,15)],True)
        if name=='grey_cart':
            shapes(scene,name,[rect(x+4,y,14,35),rect(x+w-18,y,14,35),
                rect(x+14,y+2,w-28,5)])
    for scene,name,x,y,count,step in [
        ('Airport','trolleys',57,611,6,42),
        ('IstanbulHavalimani','trolleys',1271,551,9,40)]:
        polygons=[]
        for i in range(count):
            a=x+i*step
            if scene=='Airport':
                polygons += [tube((a+2,y+5),(a+26,y+5),6),
                    tube((a+26,y+5),(a+32,y+12),6),tube((a+32,y+12),(a+23,y+31),5),
                    rect(a+9,y+13,7,115),rect(a+7,y+41,29,68),
                    rect(a+1,y+127,39,8),*wheel(a+17,y+149,13,13,13)]
            else:
                polygons += [rect(a+4,y+1,20,9),rect(a+4,y+10,6,80),
                    rect(a+24,y+7,6,83),rect(a+8,y+30,32,5),rect(a+8,y+42,32,5),
                    rect(a,y+89,39,10),*wheel(a+13,y+118,12,12,12)]
        shapes(scene,name,polygons,True)

    # Room 01's side cabinet includes its printer cartons and potted plant.
    shapes('Room01','cabinet_side',[
        [[1400,438],[1475,460],[1637,503],[1641,642],[1400,606]],
        rect(1434,419,85,48),rect(1461,405,59,60),rect(1563,455,49,47)],True)
    leaves('Room01','cabinet_side',(1544,383,86,74))

    # Side-chair outlines differ from the face-on seats. Avoid broad crops
    # across the open area between legs or masks in empty gaps beside a table.
    for index,(front,left,right,back) in enumerate([
        (141,74,414,246),(784,633,947,745),(1336,1178,1572,1307)]):
        for j in [0,1,2,3]:
            name='chair_%d_%d'%(index,j)
            if j==0:
                shapes('IstanbulLokanta',name,[rect(front,609,115,68),
                    rect(front+2,677,13,131),rect(front+98,677,15,131),
                    rect(front+15,695,83,40)],True)
                feet('IstanbulLokanta',name,[(front,737,115,71)])
            elif j==3:
                shapes('IstanbulLokanta',name,[rect(back,523,95,53)],True)
                feet('IstanbulLokanta',name,[(back,551,95,25)])
            else:
                cx=left if j==1 else right
                seat_x=cx+14 if j==1 else cx-59
                shapes('IstanbulLokanta',name,[rect(cx,568,20,194),
                    rect(seat_x,659,60,37),
                    rect(seat_x+(48 if j==1 else 0),696,11,50)],True)
                feet('IstanbulLokanta',name,[(min(cx,seat_x),701,80,61)])

    # Actual tabletop items, rather than a floating rectangular crop above it.
    for index,(napkin,pepper,cups) in enumerate([
        (172,222,[(239,565,17,31),(269,573,15,24)]),
        (748,None,[(817,561,24,36)]),
        (1317,1394,[(1380,563,26,37),(1436,562,27,36)])]):
        polys=[rect(napkin,560,27,41) if index==0 else rect(napkin,567,31,41)]
        if pepper is not None: polys.append(rect(pepper,542,16,56))
        polys += [rect(*r) for r in cups]
        shapes('IstanbulLokanta','table_'+str(index),polys)

    # These furnishings project beyond the wall boundary into Room 304.
    object_('HotelRoom','wardrobe',546,[(61,510,167,36)],
        [[[61,142],[219,142],[233,152],[233,535],[223,546],[61,546]]])
    shapes('HotelRoom','bedside',[
        [[782,333],[820,333],[831,380],[775,380]],rect(798,380,10,44),rect(788,421,31,11)])
    shapes('HotelRoom','desk',[
        [[1436,375],[1471,390],[1497,375],[1519,376],[1519,435],[1486,432],[1435,432]],
        rect(1537,373,34,42),rect(1571,382,13,25)])
    # A person cannot stand underneath the desk between its painted legs.
    # Its back touches the wall; the chair/bin remain separate front footprints.
    feet('HotelRoom','desk',[(1368,515,242,79),(1370,568,166,78),(1540,615,70,34)])

    # Plant crowns above reachable pots must sort with those pots, including
    # positions beside them where only the actor's head overlaps the leaves.
    for scene,name,bounds in [
        ('Mitte','tree_west',(0,320,118,225)),
        ('Mitte','hotel_plant_west',(469,500,76,117)),
        ('Mitte','hotel_plant_east',(624,506,64,111)),
        ('BerlinPrenzlberg','tree_west',(0,287,158,241)),
        ('BerlinPrenzlberg','tree_mid',(244,296,196,227)),
        ('BerlinPrenzlberg','tree_market',(878,292,173,239)),
        ('BerlinKreuzberg','tree_west',(0,100,137,447)),
        ('BerlinKreuzberg','tree_east',(1516,102,156,440)),
        ('MitteOst','tree_east',(1555,144,117,356)),
        ('IstanbulHan','plant_left',(0,614,84,62)),
        ('IstanbulHan','plant_door',(431,620,55,52)),
        ('IstanbulHan','plant_mid',(1094,640,49,44)),
        ('IstanbulHan','plant_right',(1354,619,71,53)),
        ('IstanbulBeyoglu','plant_mid',(819,530,67,78)),
        ('IstanbulBeyoglu','plant_east',(1048,490,76,117)),
        ('IstanbulBeyoglu','plant_passage',(1347,423,104,184)),
        ('IstanbulBeyoglu','plant_edge',(0,579,47,48)),
        ('IstanbulCarsi','plant_edge',(0,559,33,80)),
        ('IstanbulKadikoy','plant',(940,414,79,138)),
        ('Airport','plant_206',(181,437,90,99)),
        ('Airport','plant_701',(686,404,84,111)),
        ('Airport','plant_1245',(1224,419,87,115)),
        ('Airport','plant_1600',(1585,476,74,121)),
        ('Hospital','planter',(1435,456,77,95)),
        ('Police','plant_342',(318,302,107,206)),
        ('Police','plant_1353',(1338,454,77,99)),
        ('Exchange','planter',(1493,425,106,137)),
        ('IstanbulDoviz','planter',(350,307,97,179)),
        ('IstanbulLokanta','plant_back',(1540,277,116,171))]:
        leaves(scene,name,bounds)
    for x in [213,368,820,1005,1428,1635]:
        leaves('IstanbulCarsi','planter_'+str(x),(x-8,559,62,76))
    shapes('IstanbulBeyoglu','plant_passage',[tube((1396,563),(1397,608),12)])
    shapes('IstanbulBeyoglu','plant_east',[tube((1086,578),(1086,607),9)])
    shapes('IstanbulLokanta','plant_back',[tube((1604,357),(1604,446),11)])
