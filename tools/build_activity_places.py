"""Author explorable activity locations. Coordinates refer to 1672 x 941 plates.

This builds world data/scenes, never rewrites the approved art or film staging.
Footprints describe ground occupied; polygons describe complete visible objects.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
PLACES = {}
ENTRIES = {}

def pt(x, y): return [round(x * 1152 / 1672, 2), round(y * 648 / 941, 2)]
def rect(x, y, w, h): return pt(x,y) + pt(w,h)
def poly(points): return [pt(x,y) for x,y in points]
def box(x,y,w,h): return [(x,y),(x+w,y),(x+w,y+h),(x,y+h)]
def path(name): return f'res://scenes/world/activities/{name}.tscn'
def street(name): return f'res://scenes/world/{name}.tscn'

def place(name, city, region, parent, title, floor, action, back=(70,820), indoor=False):
    row = dict(city=city,region=region,title=title,parent=parent,
        ambience='interior' if indoor else 'street', action=pt(*action),
        geometry=dict(floor=pt(0,floor)[1],walk_bottom=640,objects=[],
            spawn=pt(250,810)),
        exits=[dict(target=parent,at=pt(*back),label='E - Back to '+title_for(parent))])
    PLACES[name]=row
    return name

def title_for(target):
    name=target.rsplit('/',1)[-1].replace('.tscn','')
    return PLACES.get(name,{}).get('title','the neighbourhood')

def root_entry(parent, name, text, at=None):
    row=dict(place=name,prompt='E - '+text)
    if at: row['at']=pt(*at)
    ENTRIES.setdefault(street(parent),{})['LocalSpot']=row

def connect(parent, child, at, label=None):
    PLACES[parent]['exits'].append(dict(target=path(child),at=pt(*at),label='E - '+(label or PLACES[child]['title'])))

def obj(scene, name, base, polygons=(), depth=None, **extra):
    footprints=[base] if base and isinstance(base[0],(int,float)) else (base or [])
    if depth is None: depth=max((r[1]+r[3] for r in footprints),default=640)
    row=dict(id=name,sort_y=pt(0,depth)[1],footprints=[rect(*r) for r in footprints],polygons=[poly(p) for p in polygons])
    row.update(extra)
    PLACES[scene]['geometry']['objects'].append(row)
    return row

def solid(scene,name,x,y,w,h): return obj(scene,name,[x,y,w,h])
def plant(scene,name,x,y,w,h):
    # A foliage shader removes wall/sky between leaves AND brown branches.
    return obj(scene,name,[x+w*.28,y+h-28,w*.48,28],
        [box(x+w*.21,y+h-55,w*.62,55)],wood_branches=True,
        foliage=[poly(box(x,y,w,h-48))])

def bench(scene,name,x,y,w,h):
    # Open air between the legs is never copied from the photograph.
    return obj(scene,name,[x+8,y+h-23,w-16,23],
        [box(x,y,w,h*.62),box(x+8,y+h*.55,9,h*.45),box(x+w-17,y+h*.55,9,h*.45)],depth=y+h)

def resident(scene,id,feet,**appearance):
    PLACES[scene].setdefault('residents',[]).append(dict(id=id,feet=pt(*feet),appearance=appearance))

# Berlin: the door matches the existing Spati frontage in Mitte.
s=place('ActivityBerlinSpati','berlin','mitte',street('Mitte'),'the Späti',640,(1160,780),(170,698),True)
root_entry('Mitte',s,'Enter the Späti')
obj(s,'counter_register_and_crate',[925,600,596,105],[[(925,475),(971,475),(971,429),(1001,429),(1001,374),(1063,374),(1063,412),(1107,420),(1118,473),(1308,473),(1310,405),(1499,405),(1499,475),(1521,475),(1521,705),(925,705)]])
solid(s,'right_shelves',1543,0,129,730)
resident(s,'Rika',(1210,480),wear='shopcoat',cut='crop',build='adult',face='',pal={'C':'#736546','D':'#51462f','R':'#3b302b'})

# Istanbul already exposes the Han's workshop and all other street settings.
# The ferry was the one separate setting that could only be watched.
s=place('ActivityFerryDeck','istanbul','kadikoy',street('IstanbulKadikoy'),'the ferry deck',654,(1120,790),(65,765))
root_entry('IstanbulKadikoy',s,'Follow the quay to the ferry',(1495,794))
resident(s,'ferry_passenger',(1200,710),wear='coat')

# London. The bin-lid shot is the existing, already walkable LondonTerrace.
s=place('ActivityLondonPub','london','soho',street('LondonSoho'),'the pub',602,(980,760),(143,650),True)
root_entry('LondonSoho',s,'Enter the pub')
obj(s,'bar',[689,598,983,52],[box(689,399,983,251)])
bench(s,'left_chair',277,467,92,190);bench(s,'right_chair',513,466,94,191)
obj(s,'round_table',[362,622,143,41],[[(350,506),(360,493),(434,486),(535,501),(543,515),(526,528),(450,535),(450,632),(484,650),(480,659),(435,645),(384,661),(378,651),(424,630),(424,536),(361,529)]])
for x in [1110,1240,1367,1497]: bench(s,'stool_'+str(x),x,520,75,139)
resident(s,'pub_keeper',(1028,427),wear='shirt')
s=place('ActivityLondonCharity','london','highstreet',street('LondonHighStreet'),'the charity shop',560,(1090,792),(1100,612),True)
root_entry('LondonHighStreet',s,'Enter the charity shop')
obj(s,'till',[1160,622,450,40],[[(1160,433),(1255,433),(1255,401),(1312,401),(1312,431),(1504,431),(1504,398),(1565,398),(1565,436),(1611,436),(1611,662),(1160,662)]])
obj(s,'left_books_and_plant',[0,672,220,67],[box(0,563,203,173)],foliage=[poly(box(92,396,155,160))],wood_branches=True)
solid(s,'clothes_rail',203,531,691,55)
resident(s,'charity_volunteer',(1350,453),wear='jumper')
s=place('ActivityLondonDLRPlatform','london','docklands',street('LondonDocklands'),'the DLR platform',689,(895,815))
root_entry('LondonDocklands',s,'Go up to the DLR platform')
obj(s,'left_column',[214,680,89,54],[box(232,0,52,683),box(214,644,89,90)])
obj(s,'right_column',[1340,680,92,54],[box(1358,0,51,680),box(1340,647,92,87)])
bench(s,'platform_bench',1435,636,237,100)
t=place('ActivityLondonDLRFront','london','docklands',path(s),'the front carriage',712,(832,815),(1510,804),True)
connect(s,t,(945,698),'Board the front carriage')
solid(t,'front_seats',283,620,1110,123)
obj(t,'left_pole',[210,865,27,28],[box(212,0,14,890)])
obj(t,'right_pole',[1431,865,26,28],[box(1433,0,14,890)])
s=place('ActivityLondonBrixtonMural','london','brixton',street('LondonBrixton'),'Tunstall Road',699,(850,798))
root_entry('LondonBrixton',s,'Walk to Tunstall Road')
solid(s,'flowers_at_wall',560,650,505,50)
obj(s,'lamp',[1565,676,28,47],[box(1573,97,13,579),box(1565,672,29,53)])

# Paris: neighbouring squares and paths join the street rather than teleporting
# between unrelated districts. Portrait is another camera on Place du Tertre.
s=place('ActivityParisRosiers','paris','marais',street('ParisMarais'),'Rue des Rosiers',656,(1100,790))
root_entry('ParisMarais',s,'Walk along Rue des Rosiers')
plant(s,'door_plant',1474,492,100,188)
t=place('ActivityParisVosges','paris','marais',path(s),'Place des Vosges',602,(950,798))
connect(s,t,(1595,814),'Continue to Place des Vosges')
bench(t,'arcade_bench',278,605,296,116)
solid(t,'left_arcade',0,0,208,725);solid(t,'right_arcade',1425,0,247,731)
solid(t,'garden_border',510,560,328,41)
s=place('ActivityParisTertre','paris','montmartre',street('ParisMontmartre'),'Place du Tertre',675,(1280,819))
root_entry('ParisMontmartre',s,'Walk into Place du Tertre')
obj(s,'artist_chair',[624,752,130,35],[box(624,596,67,27),box(629,615,14,72),box(677,615,13,72),box(638,658,46,14),[(639,683),(714,680),(751,689),(751,706),(639,709)],box(627,705,13,72),box(683,705,13,82),box(734,705,14,69),box(641,736,101,12)])
obj(s,'easel',[[809,747,29,44],[925,747,29,44]],
    [box(897,462,18,44),[(831,505),(939,503),(940,638),(819,638)],box(814,637,131,11),[(830,646),(850,646),(826,779),(806,779)],[(911,646),(930,646),(943,783),(925,783)],box(829,725,105,12)])
obj(s,'paint_stool',[1005,760,109,36],[[(999,666),(1037,658),(1057,658),(1057,632),(1083,632),(1083,663),(1110,668),(1110,680),(998,680)],box(1060,614,4,18),box(1072,619,4,13),[(1012,679),(1029,679),(1020,785),(1003,785)],[(1075,679),(1094,679),(1115,788),(1097,788)],box(1039,680,12,114),box(1051,688,46,12),[(1077,681),(1098,681),(1105,744),(1088,751),(1073,741)]])
solid(s,'left_display',0,584,207,193);solid(s,'right_display',1444,566,228,247)
resident(s,'portrait_artist',(1320,751),wear='coat')
t=place('ActivityParisVines','paris','montmartre',path(s),'the vineyard lane',728,(960,817))
connect(s,t,(1595,860),'Continue to the vineyard lane')
solid(t,'vineyard_fence',0,655,1672,65)
plant(t,'right_planter',1500,605,160,139)
s=place('ActivityParisBellevilleView','paris','belleville',street('ParisBelleville'),'the Belleville terrace',699,(817,829))
root_entry('ParisBelleville',s,'Follow the path to the viewpoint')
bench(s,'view_bench',1237,703,303,129)
solid(s,'terrace_rail',0,639,1672,64)
s=place('ActivityParisDefenseAxis','paris','ladefense',street('ParisLaDefense'),'the Esplanade',581,(862,803))
root_entry('ParisLaDefense',s,'Continue along the Esplanade')
solid(s,'left_planters',0,580,293,148);solid(s,'right_planters',1385,570,287,160)
s=place('ActivityParisChampLawn','paris','champdemars',street('ParisChampDeMars'),'the Champ-de-Mars lawn',688,(1050,831))
root_entry('ParisChampDeMars',s,'Step onto the lawn')
obj(s,'picnic_basket',[554,811,68,35],[box(554,789,68,57)])

# Moscow.
s=place('ActivityMoscowStolovaya','moscow','kitaygorod',street('MoscowKitayGorod'),'the stolovaya',664,(1090,806),(1540,700),True)
root_entry('MoscowKitayGorod',s,'Enter the stolovaya')
obj(s,'serving_counter',[270,592,1360,58],[[(270,488),(294,467),(300,362),(954,362),(968,457),(1371,457),(1371,402),(1448,402),(1448,458),(1627,490),(1627,650),(270,650)]])
solid(s,'left_dining_tables',0,575,257,108)
resident(s,'canteen_server',(1230,481),wear='apron')
s=place('ActivityMoscowRemont','moscow','basmanny',street('MoscowBasmanny'),'the repair booth',742,(1000,819))
root_entry('MoscowBasmanny',s,'Visit the repair booth',(317,704))
obj(s,'bollard',[177,781,59,42],[[(187,606),(215,606),(227,625),(220,765),(239,788),(239,815),(177,815),(177,788),(194,765),(188,625)]])
plant(s,'repair_planter',1390,480,134,290)
s=place('ActivityMoscowVernisazh','moscow','izmaylovo',street('MoscowIzmaylovo'),'Vernisazh',741,(865,817))
root_entry('MoscowIzmaylovo',s,'Browse the Vernisazh stalls')
solid(s,'stall_counter',320,678,1110,51)
t=place('ActivityMoscowIzmaylovoKremlin','moscow','izmaylovo',path(s),'the Izmaylovo courtyard',757,(1000,839))
connect(s,t,(1597,829),'Follow the lane to the courtyard')
solid(t,'left_shops',0,640,545,158);solid(t,'right_shops',1118,640,554,159)
s=place('ActivityMoscowTsoyWall','moscow','arbat',street('MoscowArbat'),'the Tsoy wall',686,(867,811))
root_entry('MoscowArbat',s,'Follow the lane to the Tsoy wall')
obj(s,'guitar_case',[1246,678,253,27],[[(1246,672),(1268,653),(1410,636),(1437,613),(1478,613),(1497,629),(1497,688),(1469,705),(1260,699)]])
s=place('ActivityMoscowChurchyard','moscow','zamoskvorechye',street('MoscowZamoskvorechye'),'the churchyard',608,(800,808),(826,866))
root_entry('MoscowZamoskvorechye',s,'Walk into the churchyard')
solid(s,'left_gate_pier',0,577,414,254);solid(s,'right_gate_pier',1392,577,280,261)
t=place('ActivityMoscowGallery','moscow','zamoskvorechye',path(s),'the gallery',659,(650,824),(200,709),True)
connect(s,t,(1250,763),'Follow the lane to the gallery')
bench(t,'gallery_bench',821,656,457,117)
obj(t,'bust_and_pedestal',[1398,669,61,51],[[(1396,472),(1410,455),(1440,457),(1460,477),(1448,514),(1468,528),(1468,720),(1392,720),(1392,528),(1409,514)]])
plant(t,'gallery_plant',1540,476,132,301)

# Mumbai. The pigeon flight is an animation in this same courtyard.
s=place('ActivityMumbaiKabutarkhana','mumbai','bhuleshwar',street('MumbaiBhuleshwar'),'Kabutarkhana',704,(900,842))
root_entry('MumbaiBhuleshwar',s,'Walk to Kabutarkhana')
obj(s,'raised_pigeon_platform',[[414,580,1110,117],[550,697,861,45]],
    [[(413,576),(540,552),(1310,552),(1558,611),(1568,684),(1374,744),(641,744),(418,690)]])
solid(s,'grain_stall',0,610,376,94)
s=place('ActivityMumbaiChorStall','mumbai','chorbazaar',street('MumbaiChorBazaar'),'the antiques shop',711,(920,827))
root_entry('MumbaiChorBazaar',s,'Browse the antiques shop')
solid(s,'antique_cabinets',755,627,558,86)
plant(s,'left_pot',317,563,84,141);plant(s,'right_pot',1350,486,107,221)
s=place('ActivityMumbaiGateway','mumbai','colaba',street('MumbaiColaba'),'the Gateway promenade',674,(984,820))
root_entry('MumbaiColaba',s,'Walk to the Gateway promenade')
solid(s,'seaward_chain',0,642,1672,24)
s=place('ActivityMumbaiMountMary','mumbai','bandra',street('MumbaiBandra'),'Mount Mary forecourt',752,(831,837))
root_entry('MumbaiBandra',s,'Follow the lane to Mount Mary')
solid(s,'left_candle_stall',0,653,470,131);solid(s,'right_candle_stall',1100,653,572,131)
t=place('ActivityMumbaiSeaWall','mumbai','bandra',path(s),'the sea promenade',623,(1040,814))
connect(s,t,(1598,860),'Follow the lane down to the sea')
solid(t,'sea_wall',0,561,1672,76)
s=place('ActivityMumbaiMuseumGarden','mumbai','byculla',street('MumbaiByculla'),'the museum garden',658,(988,797))
root_entry('MumbaiByculla',s,'Enter the museum garden')
bench(s,'garden_bench',25,653,270,104)
solid(s,'left_flowerbed',307,620,277,108);solid(s,'right_flowerbed',1131,620,408,108)
obj(s,'museum_notice',[1500,741,64,23],[box(1484,572,110,122),box(1534,686,11,78)])
t=place('ActivityMumbaiMuseumHall','mumbai','byculla',path(s),'the museum hall',624,(850,820),(782,659),True)
connect(s,t,(831,665),'Enter the museum')
# This plate is 1603 x 981, unlike the other activity illustrations. Use its
# actual pixels, including open space between the legs and transparent glass.
def museum_case(name,x,right,top,bottom):
    def mp(x,y): return [round(x*1152/1603,2),round(y*648/981,2)]
    def mb(x,y,w,h): return [mp(a,b) for a,b in box(x,y,w,h)]
    width=right-x
    PLACES[t]['geometry']['objects'].append(dict(id=name,sort_y=mp(0,bottom)[1],
        footprints=[mp(x,700)+mp(width,bottom-700)],
        polygons=[mb(x-6,top,width+12,31),mb(x,top+31,17,224),mb(right-18,top+31,18,224),
                  mb(x-6,680,width+12,55),mb(x,733,40,bottom-733),mb(right-40,733,40,bottom-733),mb(x+38,758,width-76,17)],
        glass=[mb(x+17,top+31,width-35,680-top-31)],glass_tint='#26383830'))
museum_case('left_display',50,558,438,788)
museum_case('right_display',1043,1547,438,788)
PLACES[t]['geometry']['objects'].extend([
    dict(id='left_rear_case',sort_y=457,footprints=[[400,429,69,29]],polygons=[]),
    dict(id='right_rear_case',sort_y=457,footprints=[[687,429,65,29]],polygons=[])])

# Tokyo.
s=place('ActivityTokyoMenchi','tokyo','yanaka',street('TokyoYanaka'),'the menchi shop',679,(950,805))
root_entry('TokyoYanaka',s,'Follow the lane to the menchi shop')
plant(s,'left_planter',518,554,100,140);plant(s,'right_planter',1459,537,113,160)
t=place('ActivityTokyoYanakaCemetery','tokyo','yanaka',path(s),'the cemetery path',640,(963,810))
connect(s,t,(1598,829),'Continue along the cemetery path')
solid(t,'left_graves',0,536,765,115);solid(t,'right_graves',1323,536,349,115)
s=place('ActivityTokyoBookshop','tokyo','jinbocho',street('TokyoJinbocho'),'the secondhand bookshop',688,(1050,814))
root_entry('TokyoJinbocho',s,'Browse the bookshop')
obj(s,'book_trolley',[513,650,210,53],[box(502,416,232,274),box(518,686,14,20),box(701,686,14,20)])
plant(s,'blue_pot',77,526,123,175);plant(s,'right_pot',1540,548,132,171)
s=place('ActivityTokyoKaminarimon','tokyo','asakusa',street('TokyoAsakusa'),'Kaminarimon',688,(820,823))
root_entry('TokyoAsakusa',s,'Walk to Kaminarimon')
solid(s,'left_gate',268,550,394,153);solid(s,'right_gate',1045,550,386,153)
t=place('ActivityTokyoSensojiIncense','tokyo','asakusa',path(s),'the Sensō-ji forecourt',657,(875,841))
connect(s,t,(832,694),'Through the gate to the forecourt')
obj(t,'incense_burner',[[1052,670,180,43],[1028,713,236,48]],
    [[(990,433),(1028,417),(1130,386),(1150,367),(1167,389),(1247,416),(1288,423),(1272,444),(1260,453),(1246,452),(1246,738),(1230,747),(1224,452),(1050,452),(1050,740),(1030,747),(1030,451),(1006,447)],[(1066,647),(1222,647),(1210,693),(1186,717),(1169,729),(1106,729),(1102,713),(1080,703)]])
u=place('ActivityTokyoOmikuji','tokyo','asakusa',path(t),'the omikuji counter',697,(850,816))
connect(t,u,(1578,820),'Visit the omikuji counter')
solid(u,'fortune_counter',163,610,778,77);solid(u,'right_column',1450,610,104,87)
s=place('ActivityTokyoAmeyoko','tokyo','ueno',street('TokyoUeno'),'Ameyoko market',713,(983,831))
root_entry('TokyoUeno',s,'Browse Ameyoko market')
solid(s,'market_counters',477,642,1040,74)
s=place('ActivityTokyoShinbashiSquare','tokyo','shinbashi',street('TokyoShinbashi'),'Shinbashi square',688,(940,813))
root_entry('TokyoShinbashi',s,'Walk to the square')
solid(s,'locomotive_border',0,591,909,98)
t=place('ActivityTokyoTachinomi','tokyo','shinbashi',path(s),'the standing bar',697,(950,820))
connect(s,t,(1086,705),'Visit the bar under the tracks')
solid(t,'bar_counter',648,647,861,54)

# Mexico City.
s=place('ActivityMexicoMercedAisle','mexico','merced',street('MexicoMerced'),'the Merced market aisle',526,(855,813),(807,880),True)
root_entry('MexicoMerced',s,'Enter the market aisle')
# Perspective stock narrows towards the loading door; the central aisle stays
# continuous instead of reducing the whole room to one horizontal floor strip.
for side,rects in [('left',[(0,500,492,127),(0,627,408,140),(0,767,340,174)]),('right',[(1180,500,492,127),(1264,627,408,140),(1351,767,321,174)])]:
    for i,r in enumerate(rects): solid(s,side+'_stock_'+str(i),*r)
t=place('ActivityMexicoMercedLoading','mexico','merced',path(s),'the loading courtyard',636,(1010,814),(506,637))
connect(s,t,(839,534),'Continue through the loading door')
obj(t,'delivery_van',[1279,614,353,51],[[(1281,359),(1585,359),(1587,391),(1625,391),(1653,614),(1624,645),(1614,657),(1584,657),(1577,639),(1346,639),(1338,658),(1305,658),(1296,640),(1268,606)]])
solid(t,'loading_crates',685,550,240,91)
s=place('ActivityMexicoRomaPlaza','mexico','roma',street('MexicoRoma'),'Plaza Río de Janeiro',686,(1010,811))
root_entry('MexicoRoma',s,'Walk into the plaza')
bench(s,'plaza_bench',107,645,375,112)
solid(s,'fountain_garden',592,630,641,70);solid(s,'construction_fence',1261,575,411,178)
s=place('ActivityMexicoCoyoacanMarket','mexico','coyoacan',street('MexicoCoyoacan'),'the Coyoacán market',719,(984,831),(140,789),True)
root_entry('MexicoCoyoacan',s,'Enter the market')
solid(s,'food_counter',232,675,1261,59)
t=place('ActivityMexicoCoyoacanCoyotes','mexico','coyoacan',path(s),'the coyote fountain',563,(1300,830))
connect(s,t,(1601,840),'Continue outside to the fountain')
# Basin occupies real ground; the complete sculpture, spray and basin share
# one depth, never just the low wall with a statue painted behind the player.
obj(t,'coyote_fountain',[[551,601,584,23],[449,624,784,52],[512,676,677,23]],
    [# Basin and rocks, traced in the plate's actual 1672 x 941 pixels.
     [(438,665),(451,651),(451,622),(466,607),(561,590),(711,584),(714,570),(733,548),(752,546),(772,523),(792,518),(817,528),(827,548),(858,546),(872,553),(904,548),(928,558),(952,554),(972,568),(993,595),(1106,591),(1209,608),(1230,624),(1230,657),(1247,667),(1247,680),(1186,693),(1100,699),(593,699),(482,685),(438,676)],
     # Howling coyote, with open air preserved between all four legs.
     [(771,443),(758,416),(754,390),(746,375),(747,361),(751,358),(758,370),(776,381),(786,383),(790,389),(778,391),(795,419),(816,433),(838,445),(850,465),(854,484),(863,495),(857,500),(846,487),(832,467),(824,456),(802,452),(784,448)],
     [(765,436),(778,446),(777,505),(784,516),(779,522),(771,519),(769,510)],
     [(781,450),(790,455),(787,506),(793,516),(789,522),(780,519)],
     [(815,452),(827,454),(824,483),(837,502),(840,519),(831,526),(823,523),(831,516),(827,505),(813,489)],
     # Walking coyote and its legs. Its head and ears are part of the object.
     [(844,501),(862,485),(891,480),(934,469),(969,466),(971,453),(977,455),(980,466),(985,454),(989,466),(1005,472),(1018,476),(1018,482),(1009,487),(995,485),(976,503),(952,516),(925,511),(906,506),(891,515),(874,526),(856,537),(850,533),(863,517),(867,506),(853,519),(841,522)],
     [(883,506),(896,508),(888,530),(875,541),(875,551),(867,557),(858,553),(866,548),(865,539)],
     [(952,507),(963,504),(965,545),(970,551),(968,558),(957,557)],
     [(938,513),(947,514),(948,546),(955,552),(950,558),(941,554)]],depth=699)
s=place('ActivityMexicoCondesaPark','mexico','condesa',street('MexicoCondesa'),'Parque México',662,(1100,842),(210,706))
root_entry('MexicoCondesa',s,'Follow the park path')
solid(s,'central_planting',183,598,1230,95)
obj(s,'lower_left_bed',[[0,719,130,77],[0,796,198,62],[0,858,302,83]],
    [[(78,724),(122,730),(168,749),(193,771),(195,793),(184,810),(215,826),(241,853),(304,882),(312,897),(278,941),(260,941),(292,899),(254,890),(229,864),(194,842),(167,817),(163,793),(163,773),(134,753),(99,743)]],
    foliage=[poly([(0,678),(61,680),(93,716),(139,743),(161,768),(161,814),(248,839),(284,876),(299,916),(286,941),(0,941)])],pink_blossoms=True)
obj(s,'lower_right_bed',[[1518,652,154,107],[1548,759,124,25],[1445,785,227,112],[1365,897,307,44]],
    [[(1552,620),(1542,655),(1564,670),(1634,692),(1672,695),(1672,674),(1610,665),(1561,648)],
     [(1544,765),(1544,784),(1490,810),(1448,847),(1438,884),(1364,919),(1364,941),(1391,941),(1391,926),(1461,902),(1471,861),(1512,825),(1583,797),(1583,780)]],
    foliage=[poly([(1549,748),(1618,698),(1672,690),(1672,941),(1370,941),(1382,899),(1434,864),(1478,815)])],pink_blossoms=True)
s=place('ActivityMexicoJuarezOrgan','mexico','juarez',street('MexicoJuarez'),'the Juárez café corner',708,(990,829))
root_entry('MexicoJuarez',s,'Walk to the café corner')
solid(s,'left_cafe_tables',0,614,747,97)
resident(s,'organ_listener',(1260,791),wear='coat')

# Tell the player what the optional interaction concerns. The original
# authored choices still own the encounter and its once-only rewards.
ACTIVITY_PROMPTS = {
    'berlin:mitte':'Talk with Rika at the counter',
    'istanbul:kadikoy':'Spend time on the crossing',
    'london:soho':'Order at the bar', 'london:highstreet':'Browse and visit the till',
    'london:docklands':'Ride at the front', 'london:brixton':'Look around the neighbourhood',
    'paris:marais':'Explore the neighbourhood', 'paris:montmartre':'Sit for a portrait',
    'paris:belleville':'Take in the view', 'paris:ladefense':'Watch the Esplanade',
    'paris:champdemars':'Join the picnic',
    'moscow:kitaygorod':'Choose lunch', 'moscow:basmanny':'Ask about a repair',
    'moscow:izmaylovo':'Browse the market', 'moscow:arbat':'Spend time at the wall',
    'moscow:zamoskvorechye':'Explore the churchyard and gallery',
    'mumbai:bhuleshwar':'Watch the pigeons', 'mumbai:chorbazaar':'Browse the objects',
    'mumbai:colaba':'Explore the promenade', 'mumbai:bandra':'Explore the neighbourhood',
    'mumbai:byculla':'Visit the museum',
    'tokyo:yanaka':'Visit the shop and cemetery lane', 'tokyo:jinbocho':'Browse the books',
    'tokyo:asakusa':'Explore the temple forecourt', 'tokyo:ueno':'Browse the market',
    'tokyo:shinbashi':'Visit the standing bar',
    'mexico:merced':'Spend time in the market', 'mexico:roma':'Spend time in the plaza',
    'mexico:coyoacan':'Order at the market', 'mexico:condesa':'Explore the park',
    'mexico:juarez':'Listen to the organillero',
}
for row in PLACES.values():
    row['activity_prompt']=ACTIVITY_PROMPTS[row['city']+':'+row['region']]

# Retain labels from the original location; case changes must not turn DLR
# into Dlr or drop the capital letters in proper place names.
for row in PLACES.values():
    row['title']=row['title'][0].upper()+row['title'][1:]


def write_scene(name,row):
    def v(p): return 'Vector2('+', '.join(str(a) for a in p)+')'
    def q(s): return json.dumps(s,ensure_ascii=False)
    lines=['[gd_scene format=3]',
        '[ext_resource type="Script" path="res://scenes/world/ActivityPlace.gd" id="root"]',
        '[ext_resource type="Script" path="res://scenes/world/ActivityBackground.gd" id="bg"]',
        '[ext_resource type="Script" path="res://scenes/world/WorldBorder.gd" id="border"]',
        '[ext_resource type="Script" path="res://scenes/world/Solids.gd" id="solids"]',
        '[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn" id="player"]',
        '[ext_resource type="PackedScene" path="res://scenes/world/SceneExit.tscn" id="exit"]',
        '[ext_resource type="PackedScene" path="res://scenes/world/ServicePoint.tscn" id="service"]',
        '[ext_resource type="PackedScene" path="res://scenes/ui/UILayer.tscn" id="ui"]',
        '[sub_resource type="RectangleShape2D" id="reach"]\nsize = Vector2(76, 64)',
        f'[node name="{name}" type="Node2D"]\nscript = ExtResource("root")\nplace_id = {q(name)}',
        f'[node name="Background" type="Node2D" parent="."]\nz_index = -2\nscript = ExtResource("bg")\nscene_id = {q(name)}',
        '[node name="WorldBorder" type="StaticBody2D" parent="."]\nscript = ExtResource("border")',
        '[node name="Player" parent="." instance=ExtResource("player")]']
    for i,e in enumerate(row['exits']):
        n='WayBack' if i==0 else f'Path{i}'
        lines += [f'[node name="{n}" parent="." instance=ExtResource("exit")]\nposition = {v(e["at"])}\ntarget_scene = {q(e["target"])}\nprompt_text = {q(e["label"])}',
          f'[node name="CollisionShape2D" parent="{n}" index="0"]\nshape = SubResource("reach")',
          f'[node name="Prompt" parent="{n}" index="1"]\nz_index = 10\nposition = Vector2(-85, -120)\ntheme_override_font_sizes/font_size = 16']
    lines += [f'[node name="LocalSpot" parent="." instance=ExtResource("service")]\nposition = {v(row["action"])}\nservice = "local"\nprompt_text = {q("E - " + row.get("activity_prompt","Join in here"))}',
        '[node name="CollisionShape2D" parent="LocalSpot" index="0"]\nshape = SubResource("reach")',
        '[node name="Prompt" parent="LocalSpot" index="1"]\nz_index = 10\nposition = Vector2(-130, -120)\ntheme_override_font_sizes/font_size = 16',
        '[node name="Solids" type="StaticBody2D" parent="."]\nscript = ExtResource("solids")',
        '[node name="UILayer" parent="." instance=ExtResource("ui")]']
    dest=ROOT/'scenes/world/activities'/f'{name}.tscn'
    dest.parent.mkdir(exist_ok=True)
    dest.write_text('\n\n'.join(lines)+'\n',encoding='utf-8')

if __name__=='__main__':
    for name,row in PLACES.items(): write_scene(name,row)
    (ROOT/'art/environments/activity-world.json').write_text(json.dumps(dict(places=PLACES,entries=ENTRIES),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'{len(PLACES)} explorable locations; {len(ENTRIES)} street entrances')
