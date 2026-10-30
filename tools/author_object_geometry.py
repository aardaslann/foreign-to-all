"""Authored outlines in source-image pixels; emits the renderer's world units.

This is geometry, not a segmentation filter. Empty areas and glass never sample
the opaque background plate. Keep each footprint separate from its silhouette.
"""
import json
from math import cos, sin, tau, hypot
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = {}

def rect(x, y, w, h):
    return [[x,y],[x+w,y],[x+w,y+h],[x,y+h]]

def tube(a, b, width):
    dx,dy=b[0]-a[0],b[1]-a[1]
    length=hypot(dx,dy)
    ox,oy=-dy*width/(2*length),dx*width/(2*length)
    return [[a[0]+ox,a[1]+oy],[b[0]+ox,b[1]+oy],
            [b[0]-ox,b[1]-oy],[a[0]-ox,a[1]-oy]]

def wheel(cx,cy,rx,ry,thickness):
    # A ring is a set of thin quads, keeping the spoke gaps transparent.
    polys=[]
    for i in range(24):
        a,b=tau*i/24,tau*(i+1)/24
        polys.append([[cx+cos(a)*rx,cy+sin(a)*ry],[cx+cos(b)*rx,cy+sin(b)*ry],
                      [cx+cos(b)*(rx-thickness),cy+sin(b)*(ry-thickness)],
                      [cx+cos(a)*(rx-thickness),cy+sin(a)*(ry-thickness)]])
    for i in range(8):
        a=tau*i/8
        polys.append(tube((cx,cy),(cx+cos(a)*(rx-4),cy+sin(a)*(ry-4)),1.3))
    return polys

def object_(scene, name, floor, footprints, polygons=(), glass=(), water=None):
    def points(poly):
        return [[round(x*1152/1672,2), round(y*648/941,2)] for x,y in poly]
    row = dict(id=name, sort_y=round(floor*648/941,2),
        footprints=[[round(x*1152/1672,2),round(y*648/941,2),round(w*1152/1672,2),round(h*648/941,2)] for x,y,w,h in footprints],
        polygons=[points(poly) for poly in polygons])
    if glass: row['glass']=[points(poly) for poly in glass]
    if water: row['water']={'at': points([water])[0]}
    DATA.setdefault(scene, {'objects': []})['objects'].append(row)

def box(scene, name, bounds, foot):
    object_(scene,name,foot[1]+foot[3],[foot],[rect(*bounds)])

def bollard(scene, name, x, y, w, h, foot, head=16, shaft=0.57, base=8):
    # Trace the cap, narrow shaft and flared foot independently. A bounding
    # rectangle includes pavement beside the shaft and erases the actor.
    c=x+w/2
    sh=w*shaft/2
    cap=w*.38
    ring=y+head
    bottom=y+h
    poly=[[c-cap*.5,y],[c+cap*.5,y],[c+cap,y+4],
          [c+cap,ring-5],[c+cap*.6,ring-2],[c+cap*.6,ring],
          [c+sh+1,ring],[c+sh+1,ring+4],[c+sh,ring+5],
          [c+sh,bottom-base],[x+w-2,bottom-base],[x+w,bottom-base+3],
          [x+w,bottom-2],[x+w-2,bottom],[x+2,bottom],[x,bottom-2],
          [x,bottom-base+3],[x+2,bottom-base],[c-sh,bottom-base],
          [c-sh,ring+5],[c-sh-1,ring+4],[c-sh-1,ring],
          [c-cap*.6,ring],[c-cap*.6,ring-2],[c-cap,ring-5],[c-cap,y+4]]
    object_(scene,name,foot[1]+foot[3],[foot],[poly])

def bench(scene,name,x,y,w,h,count):
    polys=[]
    stride=w/count
    for i in range(count):
        a=x+i*stride
        polys.append([[a+8,y],[a+stride-8,y],[a+stride-3,y+6],[a+stride-3,y+h*.67],
                      [a+stride-13,y+h*.67],[a+stride-13,y+h],[a+stride-22,y+h],
                      [a+stride-22,y+h*.72],[a+22,y+h*.72],[a+22,y+h],[a+12,y+h],
                      [a+12,y+h*.72],[a,y+h*.72],[a,y+h*.58],[a+8,y+h*.50]])
    object_(scene,name,y+h,[(x,y+h*.61,w,h*.39)],polys)

def table(scene,name,x,y,w,h):
    polys=[[[x+5,y],[x+w-5,y],[x+w,y+8],[x+w,y+h*.34],[x,y+h*.34],[x,y+8]],
           rect(x+12,y+h*.34,15,h*.66),rect(x+w-27,y+h*.34,15,h*.66)]
    object_(scene,name,y+h,[(x,y+h*.34,w,h*.66)],polys)

def counter(scene,name,bounds,foot,clerk=None,glass=None):
    box(scene,name,bounds,foot)
    if glass: DATA[scene]['objects'][-1]['glass']=[[[round(x*1152/1672,2),round(y*648/941,2)] for x,y in rect(*glass)]]
    if clerk:
        node,x,y=clerk
        DATA[scene].setdefault('clerks',{})[node]=[round(x*1152/1672,2),round(y*648/941,2)]

# Mitte: roof, posts, posters and bench are solid; the panes are tinted glass.
object_('Mitte','shelter',697,[(1000,665,21,30),(1266,665,27,30),(1030,663,221,33)],
    [rect(990,463,311,28),rect(998,488,19,205),rect(1271,486,20,209),
     rect(1027,544,55,85),rect(1197,524,60,104),rect(1014,630,235,14),
     rect(1047,643,13,44),rect(1226,643,13,46)],
    [rect(1017,494,254,136),rect(1017,644,254,18)])
object_('Mitte','stairs',705,[(768,613,204,91)],
    [rect(830,307,80,81),rect(867,385,14,302),
     [[764,591],[778,591],[784,698],[757,704],[757,692]],
     [[941,590],[953,594],[970,692],[974,704],[948,704]],
     rect(778,602,166,11),rect(779,630,164,8),rect(800,612,6,28),rect(827,612,6,42),
     rect(882,612,6,63),rect(915,612,6,49),
     [[779,639],[790,641],[790,695],[945,695],[945,704],[777,704]]])
object_('Mitte','bollard_west',704,[(73,691,19,13)],
    [[[80,584],[84,584],[86,588],[86,596],[89,598],[92,604],
      [92,612],[89,615],[89,696],[92,699],[92,703],[73,703],
      [73,699],[77,696],[77,615],[74,612],[74,604],[77,598],[78,596],[78,588]]])
object_('Mitte','bollard_east',704,[(326,695,28,9)],
    [[[336,622],[343,622],[347,626],[348,630],[346,634],[346,695],
      [351,696],[354,698],[354,702],[351,704],[329,704],[326,702],
      [326,698],[330,696],[333,695],[333,634],[331,630],[332,626]]])
object_('Mitte','bus_pole',697,[(950,685,25,12)],
    [rect(956,490,12,195),rect(950,685,25,12)])
box('Mitte','exchange_board',(1578,594,79,111),(1578,675,79,29))
object_('Mitte','bicycle',701,[(670,666,89,34)],
    wheel(702,668,32,32,5)+[tube(a,b,w) for a,b,w in [
        ((702,668),(721,615),5),((718,629),(751,675),6),
        ((717,641),(747,640),5),((747,640),(751,675),5),
        ((702,668),(750,675),4),((715,612),(721,620),5)]]+
    [rect(705,605,24,7),rect(740,635,18,7),rect(745,673,13,7)])

# Alexanderplatz: individual chair backs, arms, beam and feet, with open air
# between and under them. The old crop started ABOVE the chair backs.
seat_polys=[]
for x,w in [(257,110),(381,109),(507,107),(629,108)]:
    seat_polys.append([[x+5,674],[x+w-4,674],[x+w,683],[x+w,780],[x,780],[x,682]])
seat_polys += [rect(249,778,499,35),rect(239,743,20,47),rect(734,743,20,47),
               rect(362,739,20,51),rect(487,739,20,51),rect(611,739,19,51),
               [[252,813],[266,813],[266,855],[276,855],[276,869],[242,869],[242,855],[252,855]],
               [[712,813],[729,813],[729,855],[740,855],[740,869],[703,869],[703,855],[712,855]]]
object_('UBahnStation','platform_seats',870,[(241,789,511,80)],seat_polys)
box('UBahnStation','bin',(847,675,100,185),(847,827,100,35))
box('UBahnStation','column_west',(321,0,163,646),(321,595,163,51))
box('UBahnStation','column_east',(1507,0,155,646),(1507,595,155,51))
object_('UBahnStation','ticket_machine',793,[(1173,734,195,60)],
    [[[1174,402],[1365,402],[1370,408],[1370,793],[1172,793]]])
DATA['UBahnStation']['clerks']={'LostProperty':[995,511]}

# Han: complete octagonal silhouette including the water jet. The rim never
# carries an opaque rectangle of courtyard paving with it.
object_('IstanbulHan','fountain',869,[(700,748,253,92),(663,776,327,58)],
    [[[815,664],[823,654],[825,649],[839,650],[849,665],[851,706],
      [916,709],[960,733],[993,765],[993,801],[1011,824],[975,846],
      [917,869],[737,869],[636,826],[655,803],[658,765],[691,730],[755,707],[815,706]]],
    water=(832,759))
box('IstanbulHan','tree_planter',(59,736,172,70),(60,750,171,56))
box('IstanbulHan','crate_left',(604,618,94,90),(604,680,94,28))
box('IstanbulHan','crates_right',(1139,611,81,97),(1139,679,81,29))
box('IstanbulHan','sacks',(1220,645,83,64),(1220,680,83,29))
object_('IstanbulHan','rugs',839,[(1461,759,203,77)],
    [[[1457,729],[1484,729],[1484,692],[1550,692],[1550,554],[1598,554],[1598,704],
      [1640,691],[1647,746],[1667,745],[1667,834],[1637,834],[1637,793],
      [1560,793],[1560,836],[1526,836],[1499,817],[1473,809],[1457,794]]])
for name,x,y,w,h in [('plant_left',13,674,62,42),('plant_door',438,670,42,38),('plant_mid',1100,683,43,38),('plant_right',1366,670,47,42)]:
    box('IstanbulHan',name,(x,y,w,h),(x,y+h-25,w,25))

# A mattress has depth all the way back to the headboard. Desks and chairs
# keep separate outlines, so the space between their legs remains visible.
object_('HotelRoom','bed',685,[(400,519,335,165)],
    [[[409,355],[727,355],[738,367],[738,683],[718,683],[718,665],[420,665],
      [420,683],[397,683],[398,368]]])
box('HotelRoom','bedside',(760,421,105,140),(759,532,107,29))
box('HotelRoom','suitcase',(237,379,84,167),(237,516,84,30))
object_('HotelRoom','desk',648,[(1370,568,166,78),(1540,615,70,34)],
    [rect(1368,396,242,61),rect(1370,456,19,135),rect(1590,456,18,108),
     [[1392,430],[1471,437],[1471,547],[1513,563],[1514,648],[1494,648],[1494,582],
      [1408,578],[1408,648],[1389,648]],
     [[1542,558],[1610,558],[1606,648],[1547,648]]])
# The previously drawn door was never reached: its old destination lay
# behind the new WorldBorder. Author a reachable threshold and route.
DATA['HotelRoom'].update(floor=359, anchors={'BedRest':[392,512],'Encounter':[864,531],'ExitToCorridor':[101,388]},
    encounter_exit={'to':[101,373],'via':[[760,506],[235,506],[101,410]],'doorway_clearance':28},exit_door=[52,116,97,258])

object_('HotelLobby','counter',627,[(861,550,392,77)],
    [[[858,473],[869,466],[1250,466],[1255,475],[1255,492],[1248,492],[1248,625],
      [865,625],[865,492],[858,492]],rect(1016,414,55,54),rect(1080,439,68,31)])
object_('HotelLobby','armchair',648,[(478,579,168,67)],
    [[[491,464],[503,451],[618,451],[631,464],[631,521],[646,528],[646,625],
      [631,625],[631,647],[614,647],[614,627],[511,627],[511,647],[493,647],
      [493,626],[478,621],[478,530],[491,521]]])
object_('HotelLobby','side_table',649,[(665,575,122,74)],
    [[[670,546],[781,546],[792,561],[792,579],[778,579],[778,648],[763,648],
      [763,582],[690,582],[690,648],[675,648],[675,581],[660,578],[660,561]]])
box('HotelLobby','luggage',(1364,493,95,138),(1364,599,95,32))
box('HotelLobby','planter_left',(397,491,61,109),(397,572,61,28))
box('HotelLobby','planter_right',(1287,540,59,64),(1287,576,59,28))
# Her soles are behind the desk, her hands and shoulders above its top.
DATA['HotelLobby']['anchors']={'Elevator':[1037,454],'ExitToStreet':[150,447],'Receptionist':[782,346]}

object_('IstanbulYusuf','tea_table',801,[(620,718,247,82)],
    [[[632,683],[671,676],[821,676],[854,684],[871,695],[871,711],[858,721],
      [812,731],[812,800],[793,800],[793,735],[701,735],[701,800],[681,800],
      [681,731],[631,723],[617,711],[617,695]],rect(700,642,28,42),rect(760,642,29,42)])
for name,x,y,w in [('red_stool',547,733,112),('blue_stool',833,733,111)]:
    object_('IstanbulYusuf',name,825,[(x,y+28,w,64)],
        [[[x+5,y],[x+w-5,y],[x+w,y+8],[x+w,y+32],[x+w-7,y+32],[x+w-7,y+91],
          [x+w-22,y+91],[x+w-22,y+35],[x+21,y+35],[x+21,y+91],[x+7,y+91],
          [x+7,y+32],[x,y+32],[x,y+8]]])
box('IstanbulYusuf','packing_crates',(156,727,191,116),(156,803,191,40))
box('IstanbulYusuf','display_cabinet',(229,483,475,112),(229,560,475,35))
box('IstanbulYusuf','work_cabinet',(709,445,268,155),(709,567,268,33))
box('IstanbulYusuf','fridge',(1304,294,251,371),(1304,620,251,45))
box('IstanbulYusuf','plant_pot',(1498,599,85,99),(1498,666,85,32))
object_('IstanbulYusuf','workbench',626,[(988,560,302,66)],
    [rect(983,444,307,36),rect(989,478,23,136),rect(1178,479,104,136),
     rect(1054,517,86,19),rect(1054,535,16,91),rect(1122,535,17,91),rect(1069,584,54,10)])

# Canal rail: posts, two rails and diagonal ironwork, never the gaps between.
rails=[]
for a,b in [(0,575),(692,1672)]:
    rails += [rect(a,817,b-a,16),rect(a,889,b-a,12)]
for x,w in [(27,26),(172,18),(367,27),(545,26),(696,27),(792,12),(860,12),(937,23),(1029,12),(1092,12),(1166,20),(1300,11),(1386,24),(1608,18)]:
    rails.append(rect(x,805,w,117))
for x in [0,55,114,191,260,397,459,490,730,808,879,967,1043,1113,1200,1323,1421,1495,1540]:
    rails += [[[x,847],[x+8,845],[x+47,867],[x+45,873]],[[x,888],[x+47,862],[x+49,868],[x+8,892]]]
object_('BerlinKreuzberg','canal_rail',926,[(0,886,574,40),(692,886,980,40)],rails)
# Stage activities on the pavement with space between soles and canal rail.
DATA['BerlinKreuzberg']['activity_floor_max']=785*648/941

counter('Airport','checkin',(796,500,433,103),(798,567,430,36),('CheckIn',1042,540))
bench('Airport','gate_seats',356,518,301,93,4)
object_('Airport','queue_barrier',742,[(813,723,773,19)],
    [rect(829,653,733,13)]+[rect(x,648,14,82) for x in [828,1014,1205,1393,1552]]+
    [rect(x-14,723,45,19) for x in [828,1014,1205,1393,1552]])
box('Airport','luggage',(293,691,70,83),(293,749,70,25))
# Nested trolleys: mesh baskets are open between the handles and wheel rails.
object_('Airport','trolleys',772,[(57,740,231,30)],
    [rect(56,611,243,12),rect(68,652,211,68),rect(69,738,211,9)] +
    [rect(x,620,8,121) for x in [60,101,143,185,226,275]])
for x,y,w,h in [(206,535,41,44),(701,515,47,57),(1245,535,41,45),(1600,594,51,50)]:
    box('Airport','plant_'+str(x),(x,y,w,h),(x,y+h-23,w,23))

counter('Hospital','reception',(826,494,600,116),(832,571,591,39),('Reception',1140,532))
bench('Hospital','waiting',138,635,562,152,5)
box('Hospital','planter',(1449,551,53,50),(1449,579,53,22))
box('Hospital','coat_stand',(625,363,92,221),(643,563,66,27))
object_('Hospital','wheelchair',612,[(1532,583,118,29)],
    [rect(1586,485,46,68),rect(1540,537,61,27),rect(1535,527,64,10),rect(1579,550,11,35),
     rect(1541,556,9,40),rect(1568,558,7,43)]+
    wheel(1617,579,33,31,6)+wheel(1540,600,9,10,4))
counter('Police','desk',(443,478,746,158),(449,590,733,47),('Desk',850,515),(461,285,709,192))
bench('Police','waiting',109,707,518,200,4)
box('Police','filing',(1193,339,120,298),(1193,601,120,36))
box('Police','bin',(1091,562,63,90),(1091,625,63,27))
for x,y,w,h in [(342,507,62,99),(1353,552,55,85)]: box('Police','plant_'+str(x),(x,y,w,h),(x,y+h-28,w,28))
object_('Police','leaflet_stand',698,[(1539,666,91,32)],
    [rect(1539,402,91,252),rect(1542,653,13,44),rect(1615,653,14,44)])

counter('IstanbulHastane','reception',(235,443,660,125),(236,532,659,38),('Triage',600,480))
bench('IstanbulHastane','waiting_left',194,665,363,149,4)
bench('IstanbulHastane','waiting_right',1028,665,368,149,4)
box('IstanbulHastane','plant',(783,788,76,75),(783,830,76,34))
box('IstanbulHastane','bin',(970,437,56,115),(970,524,56,28))
box('IstanbulHastane','water_cooler',(1338,284,73,270),(1338,524,73,30))
box('IstanbulHastane','coat_stand',(1492,245,74,299),(1505,498,51,45))

counter('Exchange','counter',(583,522,892,146),(587,624,880,44),('Counter',1030,559),(610,367,840,155))
box('Exchange','planter',(1514,561,64,63),(1514,598,64,26))
box('Exchange','coat_stand',(520,348,79,270),(520,598,64,21))
counter('IstanbulDoviz','counter',(457,419,854,175),(458,553,852,41),('Booth',959,454),(793,194,315,225))
box('IstanbulDoviz','planter',(362,484,77,96),(362,548,77,32))

counter('Restaurant','bar',(477,437,1060,153),(481,553,1052,39),('Kitchen',965,476))
for index,x in enumerate([224,800,1331]):
    table('Restaurant','table_'+str(index),x,645,236 if index==0 else 221,242)
    # Booth backs and bases touch the floor as solid upholstered forms.
    for j,cx in enumerate([x-152,x+243]):
        object_('Restaurant','booth_'+str(index)+'_'+str(j),889,[(cx,786,150,102)],
            [[[cx,631],[cx+34,590],[cx+59,590],[cx+59,735],[cx+149,735],[cx+149,803],
              [cx+136,803],[cx+136,887],[cx,887]]])
counter('IstanbulLokanta','counter',(451,409,901,156),(458,525,893,41),('Counter',998,447))
box('IstanbulLokanta','fridge',(1376,259,162,288),(1376,517,162,30))
for index,x in enumerate([115,685,1235]):
    table('IstanbulLokanta','table_'+str(index),x,575,254 if index==0 else 234,210)
    for j,(cx,cy,cw,ch) in enumerate([(x+19,609,126,199),(x-42,568,27,194),(x+297,568,27,194),(x+132,523,95,53)]):
        box('IstanbulLokanta','chair_'+str(index)+'_'+str(j),(cx,cy,cw,ch),(cx,cy+ch-45,cw,45))

object_('Kiez','wreck',699,[(195,599,386,96)],
    [[[287,428],[353,424],[463,434],[538,469],[571,492],[571,514],[606,540],[602,570],
      [577,596],[582,639],[553,663],[492,683],[326,688],[204,664],[193,634],[168,608],
      [157,575],[177,543],[175,519],[171,492],[226,460]]])
object_('Kiez','lukas_stall',727,[(918,699,309,43)],
    [rect(914,655,314,30),rect(921,685,305,57),
     rect(929,548,14,106),rect(1192,549,17,106),
     [[910,494],[1230,494],[1235,542],[1228,554],[1215,558],[1202,550],[1188,558],[1173,550],
      [1158,558],[1144,550],[1129,558],[1113,550],[1098,558],[1083,550],[1067,558],[1052,550],
      [1037,558],[1022,550],[1007,558],[992,550],[977,558],[962,550],[947,558],[932,550],[917,558],[906,548]]])
box('Kiez','delivery_crates',(1153,714,93,40),(1153,735,93,19))
# The user-designated stone PATH is ground, not a foreground wall. Keep
# every pixel of the original strip and restrict collision to the fence
# behind it. Never sample ground back over a character standing on it.
object_('Kiez','garden_fence',739,[(942,730,730,12)],[])
box('Kiez','garden_notice',(1356,576,134,166),(1356,711,134,33))
object_('Kiez','mailbox',866,[(1548,852,16,23)],
    [[[1544,731],[1549,725],[1568,725],[1574,733]],
     [[1531,734],[1590,734],[1595,739],[1595,755],[1589,762],[1531,760],[1526,754],[1526,740]],
     rect(1549,759,13,113)])
DATA['Kiez']['anchors'] = {'CoinPouch':[471,604],'CrateJob':[852,566],
    'ExitToMitte':[1115,538],'JobSpot1':[173,590],'JobSpot2':[933,583],
    'LocalSpot':[548,541],'NPC':[737,454],'WreckSite':[311,512]}
DATA['Kiez']['interaction_offsets'] = {'NPC':{'InteractionArea':[0,94],'Prompt':[-42,-8]},
    'ExitToMitte':{'Prompt':[-221,-108]}}
DATA['Kiez']['interaction_sizes'] = {'LocalSpot':{'CollisionShape2D':[76,44]},
    'CrateJob':{'CollisionShape2D':[70,40]}}
# The apple crate is native artwork, but needs the same collision/depth
# contract as sampled scenery. Coordinates here are source pixels.
object_('Kiez','apple_crate',759,[(750,741,91,21)],[])

object_('MitteOst','shelter',695,[(0,656,14,39),(312,656,23,39),(87,664,45,27),(266,662,16,31)],
    [rect(0,468,333,28),rect(0,499,12,194),rect(315,491,18,204),rect(86,506,12,185),
     rect(10,517,76,129),rect(98,518,69,126),rect(238,517,68,128),rect(124,644,9,45),rect(269,644,11,45)],
    [rect(13,498,301,146)])
object_('MitteOst','bus_pole',704,[(390,694,26,10)],
    [rect(396,488,15,206),rect(390,694,26,10)])
object_('MitteOst','tram_pole',703,[(1197,693,29,10)],
    [rect(1204,207,12,486),rect(1197,693,29,10)])
object_('MitteOst','street_pole',699,[(1536,687,22,12)],
    [rect(1541,544,13,143),rect(1536,687,22,12)])

for x in [179,338,528,814,940]:
    if x==940:
        bollard('BerlinPrenzlberg','bollard_'+str(x),x,601,25,111,(x,699,26,13),head=17)
    else:
        bollard('BerlinPrenzlberg','bollard_'+str(x),x,625,25,80,(x,692,26,13),head=18)
for index,(x,w) in enumerate([(410,267),(683,243)]):
    object_('BerlinPrenzlberg','market_'+str(index),684,[(x+12,630,w-18,54)],
        [rect(x+3,455,w-3,57),rect(x+13,508,12,174),rect(x+w-15,508,12,174),
         rect(x+18,584,w-26,45),rect(x+34,639,61,42),rect(x+w-86,639,64,42)])
# Bollards and stalls, rather than one giant picture rectangle, define the path.
DATA['IstanbulCarsi']={'objects':[]}
for x in [213,368,820,1005,1428,1635]:
    box('IstanbulCarsi','planter_'+str(x),(x,634,42,37),(x,644,42,28))
box('IstanbulCarsi','bakery_counter',(660,601,153,69),(660,643,153,28))
box('IstanbulCarsi','lokanta_counter',(429,572,143,92),(429,636,143,28))

for index,x in enumerate([421,666,914,1158]):
    box('IstanbulMetro','turnstile_'+str(index),(x,611,63,188),(x,754,63,45))
box('IstanbulMetro','column',(1470,0,149,754),(1470,705,149,49))
object_('IstanbulMetro','ticket_machine',637,[(1280,597,57,40)],
    [rect(1238,451,157,128),rect(1280,579,57,57)])
object_('IstanbulMetro','stairwell',831,[(0,536,214,295),(214,718,19,112)],
    [rect(0,509,313,15),[[301,511],[318,512],[231,723],[231,831],[216,831],[216,711]],
     rect(245,667,8,125),rect(269,607,9,146),rect(291,554,10,148)])
for name,bounds,foot in [
    ('crate',(535,533,75,71),(535,580,75,26)),('cylinders',(636,533,94,85),(636,592,94,26)),
    ('rope',(815,548,67,70),(815,594,67,24)),('bottles',(933,448,74,170),(933,590,74,28)),
    ('mooring',(1115,559,47,59),(1115,589,47,29)),
    ('red_cart',(555,708,138,126),(555,784,138,53)),('grey_cart',(1001,714,126,123),(1001,784,126,53))]:
    box('IstanbulKarakoy',name,bounds,foot)
for x in [134,836,1498]:
    bollard('IstanbulKarakoy','bollard_'+str(x),x,680,32,75,(x,742,32,13),head=20,shaft=.66,base=12)
object_('IstanbulKarakoy','lamp',631,[(476,610,51,21)],
    [[[497,246],[505,246],[509,253],[507,261],[516,266],[519,276],[526,280],
      [526,285],[518,286],[514,319],[509,329],[509,339],[505,343],[505,572],
      [513,576],[513,582],[521,585],[521,619],[526,622],[526,631],[476,631],
      [476,622],[481,619],[481,585],[489,582],[489,576],[495,572],[495,343],
      [491,339],[491,329],[486,319],[482,286],[476,285],[476,280],[482,276],
      [485,266],[494,261],[492,253]]])
# Preserve the functional card reader and gate footprints at the ferry berth.
object_('IstanbulKarakoy','ferry_gate',643,[(174,579,135,64),(306,576,69,67)],[])
for name,bounds,foot in [
    ('fish_counter',(82,552,465,82),(82,594,465,40)),('fruit_crate',(589,559,99,69),(589,598,99,30)),
    ('plant',(950,551,61,60),(950,583,61,28)),('menu',(1419,510,82,128),(1419,610,82,28))]:
    box('IstanbulKadikoy',name,bounds,foot)
object_('IstanbulKadikoy','signpost',598,[(1533,578,39,20)],
    [[[1473,189],[1627,189],[1632,194],[1632,441],[1628,445],
      [1563,445],[1563,577],[1571,580],[1571,598],[1533,598],
      [1533,580],[1539,577],[1539,445],[1470,445],[1467,440],
      [1467,195]]])
for index,x in enumerate([1054,1171,1312]): table('IstanbulKadikoy','cafe_'+str(index),x,541,79,85)
for x in [94,369,683,924,1158,1454]:
    bollard('IstanbulBeyoglu','bollard_'+str(x),x,689,27,70,(x,749,27,10),head=16,shaft=.65)
for name,x,y,w,h in [('lamp_west',429,603,51,151),('lamp_east',1226,594,47,162),
                     ('plant_mid',831,607,48,58),('plant_east',1063,607,52,63),('plant_passage',1370,606,58,65)]:
    box('IstanbulBeyoglu',name,(x,y,w,h),(x,y+h-32,w,32))
for obj in DATA['IstanbulBeyoglu']['objects']:
    # Full posts continue above their flared bases. Stopping the mask at the
    # base let heads cut through the shaft while walking behind these lamps.
    if obj['id']=='lamp_west':
        obj['polygons']=[]
        polys=[[[443,600],[465,600],[465,608],[474,609],[474,624],[466,629],
                [466,732],[478,734],[478,750],[430,750],[430,734],[442,731],
                [442,629],[433,624],[433,609],[443,608]],rect(447,403,15,198),
               [[451,269],[462,269],[464,286],[485,315],[477,329],[468,388],
                [466,405],[443,405],[442,389],[432,330],[425,319],[443,287]]]
    elif obj['id']=='lamp_east':
        obj['polygons']=[]
        polys=[[[1235,594],[1262,594],[1263,604],[1270,607],[1270,621],[1260,628],
                [1260,734],[1271,736],[1271,753],[1227,753],[1227,736],[1238,733],
                [1238,628],[1229,622],[1229,607],[1235,604]],
               rect(1240,296,17,299),rect(1238,130,21,163),rect(1257,130,48,11),
               [[1244,84],[1255,88],[1255,110],[1267,119],[1267,131],[1230,131],[1230,117],[1241,107]],
               [[1294,121],[1308,121],[1312,140],[1326,152],[1321,167],
                [1312,199],[1305,221],[1295,221],[1289,203],[1279,169],[1276,151],[1292,141]]]
    else: continue
    obj['polygons'] += [[[round(x*1152/1672,2),round(y*648/941,2)] for x,y in poly] for poly in polys]

counter('IstanbulOtel','reception',(501,437,687,177),(507,578,680,36),('Desk',853,475))
box('IstanbulOtel','luggage',(371,470,109,154),(371,582,109,42))
box('IstanbulOtel','cabinet',(295,428,140,164),(295,557,140,35))
box('IstanbulOtel','planter',(1221,450,68,118),(1221,538,68,30))
object_('IstanbulHavalimani','information_desk',705,[(146,641,466,64)],
    [[[146,561],[161,551],[601,551],[613,563],[613,688],[565,705],[194,705],[146,688]]])
DATA['IstanbulHavalimani']['clerks']={'BagDrop':[265,403]}
bench('IstanbulHavalimani','seats_back',785,551,332,108,4)
bench('IstanbulHavalimani','seats_front',770,694,383,122,4)
object_('IstanbulHavalimani','queue',850,[(130,823,506,28)],
    [rect(151,768,461,9)]+[rect(x,757,17,82) for x in [143,257,439,604]]+
    [rect(x-13,835,44,16) for x in [143,257,439,604]])
object_('IstanbulHavalimani','trolleys',681,[(1271,640,379,40)],
    [rect(1275,637,372,16)]+[rect(x,554,10,90) for x in range(1294,1648,40)])
for x,y,w,h in [(41,558,67,66),(620,600,55,56)]: box('IstanbulHavalimani','plant_'+str(x),(x,y,w,h),(x,y+h-29,w,29))
counter('IstanbulKarakol','desk',(236,479,823,148),(237,584,819,43),('Desk',670,516))
bench('IstanbulKarakol','waiting',217,680,375,152,4)
box('IstanbulKarakol','bin',(1334,489,56,103),(1334,564,56,28))
box('IstanbulKarakol','plant_back',(1513,554,60,55),(1513,581,60,28))
box('IstanbulKarakol','plant_front',(1386,795,75,65),(1386,831,75,29))
box('HotelFloor','linen_trolley',(1355,383,129,165),(1355,515,129,34))
box('HotelFloor','plant',(1612,455,50,67),(1612,493,50,29))
table('Room01','meeting_table',577,398,478,197)
bench('Room01','chair_left',631,437,87,158,1)
bench('Room01','chair_right',917,437,90,158,1)
box('Room01','cabinet_back',(1197,366,149,132),(1197,465,149,33))
box('Room01','cabinet_side',(1400,503,241,139),(1400,607,241,36))
box('Room01','plant',(191,472,58,71),(191,514,58,29))

def save():
    (ROOT/'art/environments/object-geometry.json').write_text(json.dumps(DATA,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

from object_audit_geometry import apply_audit
apply_audit(DATA, object_, rect, tube, wheel)
from object_depth_completion import complete_depth
complete_depth(DATA, object_, rect, tube, wheel)

if __name__ == '__main__': save()
