"""Corrections from full-height matte and contact reviews, in source pixels."""
from .shapes import point, rect, tube, sign, anchor


def polygons(obj, shapes):
    obj['polygons'] = [[point(x,y) for x,y in p] for p in shapes]


def finish(scenes):
    furniture(scenes)
    terrace=scenes['LondonTerrace']
    # Keep the required neighbour's straight approach clear of the key NPC.
    terrace['anchors']['KeyNadia']=point(960,850)
    scenes['LondonSoho']['anchors']['NpcEsme']=point(1100,807)
    scenes['LondonDocklands']['anchors'].update(NpcFemi=point(1010,855),NpcTrish=point(1485,824))
    objects={o['id']:o for o in terrace['objects']}
    # The eastern lamp has a smaller square lantern than its western partner.
    polygons(objects['east_lamp'], [
        rect(1443,257,16,453),rect(1434,710,35,15),
        [[1441,257],[1462,257],[1463,245],[1459,238],[1463,224],
         [1470,209],[1470,202],[1462,198],[1459,187],[1454,181],
         [1448,181],[1443,187],[1440,196],[1437,200],[1432,203],
         [1433,209],[1437,212],[1441,234],[1438,245]],
        rect(1420,314,25,7),rect(1419,305,12,12)])
    # Fence caps and diagonal gate jambs are part of the same physical fixture.
    for key,left,right in [('west',0,237),('middle',377,735),('east',864,1208),('far_east',1345,1580)]:
        obj=objects['fence_'+key]
        obj['polygons']=[]
        obj['foliage']=[[point(x,y) for x,y in p] for p in
            [rect(left,590,right-left,98),rect(max(left,right-44),551,min(44,right-left),137),
             rect(left,550,min(23,right-left),137)]]
        obj['painted_metal']=True
    # Trees keep their wood as well as their leaves. Trim wall slivers at roots.
    east=objects['tree_east']
    east['foliage']=[[point(x,y) for x,y in p] for p in [rect(1511,0,161,519)]]
    polygons(east,[[[1602,675],[1602,531],[1586,507],[1592,505],[1610,523],
                    [1611,487],[1627,487],[1627,522],[1647,500],[1653,504],
                    [1629,535],[1629,675]]])
    brixton=scenes['LondonBrixton']
    post=next(o for o in brixton['objects'] if o['id']=='postbox')
    post['polygons'] += [[point(x,y) for x,y in p] for p in [
        rect(99,196,17,446),rect(100,16,13,122),rect(82,106,50,9),
        [[88,167],[95,184],[100,196],[115,196],[122,180],[129,166],
         [126,159],[90,159]],rect(99,137,17,23),rect(84,110,8,17),rect(122,110,8,18)]]
    brixton['lettering'].append(sign((798,533,103,28),'TO UNDERGROUND','#183b58',size=8))
    # The stalls contain solid crates beneath their tops. Preserve the crate
    # faces as well as each fruit silhouette instead of cutting them away.
    for obj in brixton['objects']:
        if obj['id'] in ['west_stall','inner_west','inner_east','east_stall','far_east']:
            xs={'west_stall':(202,256,748),'inner_west':(626,111,732),
                'inner_east':(971,114,731),'east_stall':(1125,143,748),'far_east':(1370,100,748)}
            x,w,b=xs[obj['id']]
            obj['polygons'].append([point(a,c) for a,c in rect(x+4,b-48,w-8,38)])
    west=next(o for o in brixton['objects'] if o['id']=='west_stall')
    west['polygons'][4]=[point(x,y) for x,y in [
        [203,694],[209,674],[220,676],[225,648],[238,647],[245,659],
        [260,650],[270,659],[279,656],[281,644],[294,638],[304,644],
        [310,655],[325,674],[336,653],[344,649],[350,658],[356,648],
        [366,659],[372,646],[384,650],[389,665],[403,657],[418,663],
        [436,670],[439,682],[455,678],[458,694]]]
    # London Underground bench: preserve both yellow arms and the real seat
    # upholstery, not the generic separated chair template used initially.
    bench=scenes['LondonUnderground']['objects'][0]
    polygons(bench,[rect(356,470,277,67),rect(346,502,10,35),rect(633,502,11,35),
                    rect(350,535,287,12),rect(358,546,12,21),rect(616,546,12,21)])
    dock=scenes['LondonDocklands']
    for o in dock['objects']:
        if not o['id'].endswith('mooring'): continue
        xs=[88,284] if o['id']=='west_mooring' else [578,744,929,1083,1236,1410,1604]
        shapes=[]
        for x in xs:
            width=20 if x in [88,284,744,1410] else 12
            shapes += [[[x-width,859],[x-width+4,849],[x+width-4,849],[x+width,859],
                        [x+width,870],[x+width-6,875],[x+width-6,931],
                        [x+width,934],[x+width,940],[x-width,940],[x-width,934],
                        [x-width+6,931],[x-width+6,875],[x-width,870]]]
        for a,b in zip(xs,xs[1:]):
            points=[(a+12,878),(a+(b-a)*.22,900),((a+b)/2,907),
                    (b-(b-a)*.22,900),(b-12,878)]
            shapes += [tube(p,q,9) for p,q in zip(points,points[1:])]
        if o['id']=='east_mooring': shapes.append(rect(1145,878,35,45))
        polygons(o,shapes)
    # Avoid double arrows left over from the original diagram-like wayfinding.
    dock['lettering'][-1]=sign((1328,423,293,207),'Offices  ↑\nShops    →\nDLR      →','#18283e',size=26)
    # Active job markers sit beside usable work surfaces and outside the hiring
    # prompt. The two piles were previously left at legacy floor coordinates.
    caff=scenes['LondonCaff']
    caff['anchors'].update(JobSpot1=point(517,820),JobSpot2=point(917,623))
    caff['interaction_sizes']['JobSpot1']={'CollisionShape2D':[44,32]}
    caff['interaction_sizes']['JobSpot2']={'CollisionShape2D':[34,32]}
    caff['interaction_sizes']['Hatch']={'CollisionShape2D':[42,34]}
    hotel_plant=next(o for o in scenes['LondonHotel']['objects'] if o['id']=='plant_west')
    hotel_plant['foliage']=[[point(x,y) for x,y in rect(360,344,80,151)]]
    trolley=next(o for o in scenes['LondonAirport']['objects'] if o['id']=='trolleys')
    bars=[]
    for x in [1500,1540,1586,1630]:
        bars += [[[x-13,682],[x+13,682],[x+14,689],[x+5,693],[x+5,766],
                  [x+12,773],[x+12,786],[x+6,791],[x-7,791],[x-13,786],
                  [x-13,774],[x-5,766],[x-5,693],[x-13,690]]]
    for a,b in [(1500,1540),(1540,1586),(1586,1630)]:
        bars += [rect(a+4,697,b-a-8,5),rect(a+4,710,b-a-8,4),rect(a+4,763,b-a-8,6)]
    polygons(trolley,bars)
    return scenes


def furniture(scenes):
    """Trace the pictured seat supports, leaving every opening transparent."""
    def get(scene, name):
        return next(o for o in scenes[scene]['objects'] if o['id']==name)
    polygons(get('LondonExchange','chair'),[
        [[396,568],[466,568],[475,576],[475,629],[470,635],[397,635],[391,628],[391,577]],
        [[388,641],[480,641],[485,651],[485,662],[374,662],[374,652]],
        rect(378,625,9,29),rect(385,620,9,7),rect(476,621,9,34),
        rect(377,661,10,59),rect(472,661,10,59),rect(374,719,16,9),rect(469,719,17,9)])
    polygons(get('LondonSoho','east_tree_planter'),[
        rect(1558,648,114,52),
        [[1611,647],[1611,482],[1601,474],[1590,460],[1581,443],[1581,430],
         [1587,432],[1597,454],[1611,466],[1611,415],[1632,415],
         [1632,459],[1643,445],[1657,418],[1665,410],[1665,425],
         [1654,452],[1641,470],[1632,483],[1632,647]]])
    # NHS banks have individual backs, small arms, a single low crossbar and
    # four shared legs. These are not a repeated three-leg chair template.
    for name,backs,legs in [
        ('waiting_west',[(307,96),(424,100),(543,96),(660,96)],[300,478,593,750]),
        ('waiting_east',[(927,90),(1039,99),(1159,89),(1271,89)],[919,1073,1188,1352])]:
        polys=[]
        for x,w in backs:
            polys += [[[x+6,605],[x+w-6,605],[x+w,612],[x+w,677],
                       [x+w-4,683],[x+3,683],[x,678],[x,612]],
                      [[x-5,695],[x+w+3,695],[x+w+9,704],[x+w+9,724],
                       [x+w+4,730],[x-10,730],[x-14,725],[x-14,704]],
                      rect(x-12,674,9,24),rect(x+w,674,9,24),
                      rect(x+2,728,7,13),rect(x+w-7,728,7,13)]
        polys += [rect(backs[0][0]-2,738,backs[-1][0]+backs[-1][1]-backs[0][0],7)]
        for x in legs: polys += [rect(x,728,12,43),rect(x-4,770,23,6)]
        polygons(get('LondonHospital',name),polys)
    # Airport seats share alternating high rear feet and low front feet.
    for name,backs,front,rear in [
        ('waiting_west',[(150,80),(240,77),(328,74),(413,73),(497,71),(579,71)],
         [148,274,357,441,523,638],[218,306,391,474,557]),
        ('waiting_east',[(944,80),(1037,78),(1126,77),(1214,80),(1305,79)],
         [942,1067,1157,1247,1369],[1015,1104,1193,1284])]:
        polys=[]
        for x,w in backs:
            polys += [[[x+6,761],[x+w-5,761],[x+w,767],[x+w,821],
                       [x+w-4,828],[x+3,828],[x,822],[x,768]],
                      [[x,834],[x+w-1,834],[x+w+5,841],[x+w+5,858],
                       [x+w-1,863],[x-3,863],[x-6,858],[x-6,841]],
                      rect(x-3,823,6,15),rect(x+w-3,823,6,15)]
        for x in front: polys += [rect(x,861,10,28),rect(x-3,889,17,5)]
        for x in rear: polys += [rect(x+5,860,8,11),rect(x,871,29,7)]
        polygons(get('LondonAirport',name),polys)
    polys=[]
    for x in [112,231,349]:
        polys += [[[x+6,693],[x+91,693],[x+99,700],[x+99,747],[x+94,754],
                   [x+2,754],[x,750],[x,701]],
                  [[x+1,756],[x+93,756],[x+105,766],[x+105,782],[x+99,786],
                   [x-5,786],[x-9,781],[x-9,768]],rect(x+1,786,14,45),
                  rect(x+79,786,14,45),rect(x+16,786,62,7)]
    polygons(get('LondonPolice','waiting'),polys)
    # Replace the complete wayfinding faces, including inconsistent old arrows.
    scenes['LondonHospital']['lettering'][-1]=sign((1310,130,313,231),
        'Triage  ←\nConsultations  →\nPharmacy  →\nToilets  →','#17273e',size=22)
    scenes['LondonAirport']['lettering'][-1]=sign((1317,394,314,193),
        'Gates 1–24  →\nBaggage  →\nToilets  ↑','#073267',size=26)

    for scene, service, x, y in [
        ('LondonExchange','Booth',1150,552),('LondonHospital','Triage',617,540),
        ('LondonPolice','Counter',1140,462),('LondonHotel','Desk',910,452),
        ('LondonCaff','Hatch',1060,441),('LondonAirport','BagDrop',1010,553)]:
        scenes[scene]['clerks'][service]=anchor(x,y)
