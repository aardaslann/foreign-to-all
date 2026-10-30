"""All 19 remaining encounter directions, ready for their authored set images.

Plate coordinates are design contracts for the art, not assertions
about the temporary source-world images used by the tool-only preview.
"""
from copy import deepcopy
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x,y,act='watch',**extra):
    return actor(x,y,act,**(dict(world_height=118,appearance={},z=y/1000) | extra))


def walk_to(who,x,y,secs=2.8,pose='walk'):
    return who | {'motion_path':dict(to=point(x,y),secs=secs,delay=.25,pose=pose)}


def wide(bg,cast,**extra):
    return shot(bg,cast,.5,648,324,full_plate=True,**extra)


def close(bg,cast,focus=.52,**extra):
    return shot(bg,cast,focus,475,410,**extra)


def plate(city,name,fallback,description,labels=(),patches=(),floor=710):
    key='Activity'+name
    return key,dict(city=city,texture=f'res://art/environments/scenes/{fallback}.png',
        source=[0,0,1672,941],pixel_art=False,floor=point(0,floor)[1],lettering=list(labels),
        motion=[],animation_patches=list(patches),asset_pending=True,
        source_fallback=fallback,asset_contract=description)


def water(x,y,w,h):
    return dict(kind='water',rect=[*point(x,y),*point(w,h)])


def newyork():
    plates=dict([
        plate('newyork','NewYorkBodega','NewYorkLowerEast',
            'Narrow Lower East Side bodega interior, shelves of tins and drinks, a deli griddle at rear right. '
            'Back counter front occupies x850–1500, top y590, base y720. Clear customer floor y735–920. '
            'Cook is added by engine at x1060,y605 behind counter; keep that zone blank. '
            'Newspapers and a sleeping cat shelf at left x240,y660; leave the cat to the engine. '
            'Old erased board above griddle has no readable prices. Warm fluorescent light, tiled floor.'),
        plate('newyork','NewYorkRoofWork','NewYorkWilliamsburg',
            'Brooklyn brick roof at close range. Complete wooden stave water tank x975–1400,y210–625, '
            'hoops, legs, ladder x854–914 from y775 to y400, spare staves stacked at left. '
            'Roof walking surface y730–925, clear x420–850. Thin water leak below tank at x1260,y590. '
            'No person on ladder. Keep both ladder rails and spaces between rungs legible.'),
        plate('newyork','NewYorkRoofView','NewYorkWilliamsburg',
            'Brooklyn rooftop facing East River, bridge at left and Manhattan skyline across water, '
            'warm windows without bloom. Parapet top y630, full deck y715–930. '
            'Clear seat on parapet x600 and clear standing deck x940. Tank at far-right edge. '
            'City scale and skyline dominate the upper two thirds.',patches=[water(350,451,797,31)]),
        plate('newyork','NewYorkRooseveltCart','NewYorkJacksonHeights',
            'Roosevelt Avenue under green elevated steel. Silver train only in y0–118. '
            'Four culturally specific shopfronts behind an arepa cart at x845–1375,y568–733. '
            'Vendor zone x1080,y598 stays empty behind counter; queue at x520–740,y830. '
            'Clear customer forecourt to y930, complete cart wheels and legs. No baked train supports '
            'inside the moving train band. Blank fascia panels.',
            [sign((74,344,319,80),'DOSA · SWEETS','#00000000','#283941',size=24),
             sign((480,344,330,80),'PANADERÍA','#00000000',size=29),
             sign((879,344,342,80),'FRESH MARKET','#00000000',size=26),
             sign((1331,347,307,80),'BANGLA BAZAR','#00000000',size=23)],
            [dict(kind='train',rect=[*point(0,0),*point(1672,100)])])])
    plates['ActivityNewYorkRoofView']['animation_patches']=[water(697,502,329,100)]
    stage={}
    cook=person(1097,491,'cut',clip_row=18,appearance={'wear':'shirt','cut':'crop','face':''})
    queue=person(608,843,'queue',appearance={'wear':'jacket','cut':'bob','face':''})
    bodega=close('ActivityNewYorkBodega',[person(791,839),cook,queue],
                 object='sleeping_cat',object_world_at=point(241,425),object_world_unit=1.8)
    ordered=bodega | {'cast':[person(905,839),cook | {'act':'offer'},walk_to(queue,310,843,3.2)]}
    take=ordered | {'cast':[person(905,839,'take'),cook | {'act':'hand_over'}],'prop':'bec','prop_holder':0}
    outside=close('NewYorkLowerEast',[person(993,783,'eat')],.59,prop='bec',prop_holder=0)
    stage['newyork:lowereast']={'door':beat(bodega,[bodega,ordered]),
        'copied':beat(outside),'stalled':beat(bodega | {'cast':[person(791,839,'look_up'),cook,queue]}),
        'pointed':beat(take)}
    residents=[person(610,606,'sit',seated=True,world_height=96,appearance={'build':'elder','wear':'shirt','cut':'crop'}),
               person(960,599,'sit',seated=True,world_height=96,appearance={'wear':'blouse','cut':'tied'})]
    street=wide('NewYorkHarlem',[person(777,758),*residents])
    pass_by=close('NewYorkHarlem',[person(771,758,'walk'),*residents],.47)
    nodded=pass_by | {'cast':[person(771,758,'nod'),residents[0] | {'act':'nod'},residents[1]]}
    sat=close('NewYorkHarlem',[person(589,655,'sit',seated=True,world_height=96),*residents],.43)
    stage['newyork:harlem']={'street':beat(pass_by,[street,pass_by]),'nodded':beat(nodded),
        'sat':beat(sat),'past':beat(pass_by | {'cast':[person(771,758,'walk_away'),*residents]})}
    worker=person(1003,715,'climb',world_height=106,kit='wood_staves',
                  appearance={'wear':'shirt','cut':'crop','face':''})
    roof=wide('ActivityNewYorkRoofWork',[person(594,840,'look_up'),walk_to(worker,1003,437,3.3,'climb')])
    tank=close('ActivityNewYorkRoofWork',[person(740,840,'look_up'),worker | {'world_at':point(1003,437),'act':'watch'}],.65)
    view=wide('ActivityNewYorkRoofView',[person(702,816,'look_up')])
    stage['newyork:williamsburg']={'yard':beat(tank,[wide('NewYorkWilliamsburg',[person(887,799,'look_up')]),roof]),
                                 'why':beat(tank),'up':beat(view)}
    seller=person(1003,651,'offer',world_height=96,clip_row=18,appearance={'wear':'blouse','cut':'tied','face':''})
    cart=close('ActivityNewYorkRooseveltCart',[person(784,849),seller,
        person(580,849,'queue',appearance={'wear':'tee','cut':'crop'})],.56)
    serve=cart | {'cast':[person(936,849,'take'),seller | {'act':'hand_over'}],'prop':'arepa','prop_holder':0}
    stage['newyork:jacksonheights']={'under':beat(cart,[wide('NewYorkJacksonHeights',[person(743,822,'recoil')]),cart]),
        'listened':beat(cart),'guessed':beat(serve),
        'english':beat(serve | {'cast':[person(936,849,'eat'),seller | {'act':'watch'}]})}
    return plates,stage


def saopaulo():
    plates=dict([
        plate('saopaulo','SaoPauloFeira','SaoPauloLiberdade',
            'Liberdade Sunday square with distinctive red suzuranto lamps. Frying stall at right '
            'x905–1410,y575–720, large frying pan top at y571; vendor zone x1110,y588. '
            'Three folding tables of manga, seeds and crockery across left background. '
            'Clear customer square y755–925, Portuguese and Japanese fascia left blank.'),
        plate('saopaulo','SaoPauloFlea','SaoPauloBixiga',
            'Praça Dom Orione antiques fair in Bixiga, intimate square and low Italianate houses. '
            'Cloths with old keys, button tins, photos, books and small brass pieces on ground '
            'x590–1040,y770–850. Vendor chair x1110,y705, seat surface y740. '
            'Keep approach x460–580 clear and walking aisle below y870.'),
        plate('saopaulo','SaoPauloCantina','SaoPauloBixiga',
            'Bixiga cantina with long shared tables, red-white checked cloths, wood chairs, '
            'plaster walls, family pictures and an Italian surname blank panel on window. '
            'Nearest table x660–1300,y680–755, seat locations x605,y792 and x1350,y792. '
            'Clear serving aisle x240–490 from y660–910. No people or food server baked in.',
            [sign((932,366,345,52),'CANTINA BELLINI','#00000000','#644737',size=27)]),
        plate('saopaulo','SaoPauloMarketHall','SaoPauloMercadao',
            'Inside Mercado Municipal: distinctive tall arches, stained-glass windows, iron roof, '
            'fruit crates in deep stalls. Central aisle x570–1010 clear all the way to y940. '
            'Right fruit counter x1030–1540, top y590 and front base y724. '
            'Vendor at x1210,y612 and customers at x903,y826, empty for engine actors.'),
        plate('saopaulo','SaoPauloSandwich','SaoPauloMercadao',
            'Mercadão mezzanine sandwich counter: wood counter x845–1450, top y580, base y733, '
            'slicer and mortadella behind it, stained glass and ironwork visible over the hall. '
            'Empty cook zone x1120,y590, standing customer zone x750–900,y830. '
            'Blank modest menu panel, no prices or text.',
            [sign((894,309,388,54),'SANDUÍCHE DE MORTADELA','#6a4935',size=23)]),
        plate('saopaulo','SaoPauloVao','SaoPauloPaulista',
            'View from the open public space under Lina Bo Bardi MASP. Monumental red supports at '
            'the far edges, underside of suspended museum high above, open skyline beyond. '
            'The architecture creates public space, no wall closing its sides. Clear plaza '
            'y680–930 with a low sitting ledge left at y721. Small coffee bicycle on right '
            'x1270,y715; do not bake people or demonstration placards.'),
        plate('saopaulo','SaoPauloMASPGallery','SaoPauloPaulista',
            'MASP collection gallery: individual glass easels in concrete feet on an open floor, '
            'each holding one small painting. Clear paths between them, no partitions. '
            'Easels at x420,y690, x795,y660, x1320,y650; middle foreground x940–1160,y810 clear. '
            'Include visible backs of some frames and blank rear labels. No replicas of specific artworks.'),
        plate('saopaulo','SaoPauloMuralAlley','SaoPauloVilaMadalena',
            'Beco do Batman alley: close textured walls with layered vivid independent murals and '
            'distant low roofs. Narrow angular black pixo band high on wall left blank for native marks. '
            'Mural contours remain stepped pixels. Clear cobbled walking band y710–930. '
            'No invented smooth graffiti letters.',
            [sign((626,204,241,108),'ZONA\nLIVRE','#00000000','#24252b',size=29)])])
    stage={}
    cook=person(1329,706,'cut',clip_row=18,appearance={'wear':'blouse','cut':'tied','face':''})
    fair=close('ActivitySaoPauloFeira',[person(1119,844),cook,
        person(887,849,'queue',appearance={'wear':'shirt','cut':'crop'})],.67)
    fried=fair | {'cast':[person(1248,844,'take'),cook | {'act':'hand_over'}],'prop':'pastel','prop_holder':0,'handheld_scale':.55}
    tables=wide('ActivitySaoPauloFeira',[person(477,840,'watch'),cook])
    stage['saopaulo:liberdade']={'lamps':beat(fair,[wide('SaoPauloLiberdade',[person(687,843,'look_up')]),fair]),
        'tables':beat(tables),'fried':beat(fried,[fried])}
    vendor=person(1165,714,'read',seated=True,seat=False,clip_row=90,appearance={'build':'elder','wear':'shirt','cut':'crop'})
    flea=wide('ActivitySaoPauloFlea',[person(461,859),vendor],prop='book',prop_holder=1)
    dig=close('ActivitySaoPauloFlea',[person(702,866,'kneel'),vendor],.55,prop='brass_thing',prop_holder=0)
    bought=dig | {'cast':[person(720,866,'take'),vendor | {'act':'count'}]}
    cantina=wide('ActivitySaoPauloCantina',[person(582,653,'sit',seated=True,clip_row=90,world_height=96),
        person(1291,653,'sit',seated=True,clip_row=90,world_height=96,appearance={'wear':'shirt','cut':'crop'}),
        walk_to(person(405,839,'carry',appearance={'wear':'blouse','cut':'tied'}),465,801,3.2,'carry')],prop='food_tray',prop_holder=2)
    stage['saopaulo:bixiga']={'praca':beat(flea,[flea,flea]),'dig':beat(dig,[dig]),
        'bought':beat(bought),'cantina':beat(cantina,[cantina])}
    seller=person(1255,650,'offer',clip_row=18,appearance={'wear':'shirt','cut':'crop','face':''})
    hall=wide('ActivitySaoPauloMarketHall',[person(794,849,'walk'),seller])
    offered=close('ActivitySaoPauloMarketHall',[person(1039,839),seller],.65,prop='fruit_slice',prop_holder=1)
    watched=offered | {'cast':[person(723,847),seller,person(985,839,'take')],'prop_holder':2}
    trapped=offered | {'cast':[person(937,839,'take'),seller | {'act':'count'},person(744,848,'queue')],'prop_holder':0}
    refused=offered | {'cast':[person(937,839,'hand_over'),seller | {'act':'take'}],'prop_holder':1}
    sandwich=close('ActivitySaoPauloSandwich',[person(951,847),
        person(1316,649,'offer',clip_row=18,appearance={'wear':'shirt','cut':'crop','face':''})],.64,
        prop='mortadela',prop_holder=1,handheld_scale=.55)
    eaten=sandwich | {'cast':[person(951,847,'eat'),sandwich['cast'][1] | {'act':'watch'}],'prop_holder':0}
    stage['saopaulo:mercadao']={'floor':beat(offered,[hall,offered]),'watched':beat(watched),
        'trap':beat(trapped),'paid':beat(trapped | {'prop':'bag'}),'refused':beat(refused),
        'clear':beat(offered | {'cast':[person(937,839,'walk_away'),seller | {'act':'watch'}],'prop':''}),
        'sand':beat(sandwich),'eaten':beat(eaten)}
    vao=wide('ActivitySaoPauloVao',[walk_to(person(702,849,'walk'),805,849,3.1),person(973,837,'watch'),
        person(1338,701,'offer',clip_row=18,world_height=100)])
    stay=vao | {'cast':[person(425,715,'sit',seated=True,clip_row=90),*vao['cast'][1:]]}
    gallery=wide('ActivitySaoPauloMASPGallery',[person(1133,810,'watch'),
        walk_to(person(526,802,'walk'),533,855,2.7)])
    reverse=close('ActivitySaoPauloMASPGallery',[person(1339,746,'read',world_height=96)],.79)
    stage['saopaulo:paulista']={'avenue':beat(vao,[wide('SaoPauloPaulista',[person(990,810,'look_up')]),vao]),
        'vao':beat(vao),'stay':beat(stay),'inside':beat(gallery),'noorder':beat(reverse)}
    alley=wide('ActivitySaoPauloMuralAlley',[person(650,843,'walk')])
    pixo=close('ActivitySaoPauloMuralAlley',[person(776,843,'look_up')],.51)
    asked=pixo | {'cast':[person(688,843),person(964,839,'point',appearance={'wear':'blouse','cut':'tied'})]}
    stage['saopaulo:vilamadalena']={'alley':beat(pixo,[alley,pixo]),'murals':beat(alley | {'cast':[person(650,843)]}),
        'pixo':beat(pixo),'asked':beat(asked)}
    from .saopaulo_activities_finish import apply
    apply(plates)
    return plates,stage


def sydney():
    plates=dict([
        plate('sydney','SydneyFerryDeck','SydneyCircularQuay',
            'Inside a green-yellow Sydney ferry saloon. Broad windows frame harbour and bridge, '
            'cream bulkheads, timber trim, blue bench seats. Left seat surface x500,y728, '
            'right seat x1060,y728; clear central aisle x700–960,y765–920. '
            'Separate distant sea through windows y210–495 from fixed interior.',patches=[water(236,391,1196,26)]),
        plate('sydney','SydneyRocksLane','SydneyCircularQuay',
            'Narrow sandstone passage in The Rocks, worn stone steps and rock-cut opening. '
            'Warm amber stone and slate-blue shadows in stepped pixel clusters. Clear continuous '
            'walking floor y735–925, full stair treads near rear only, no foreground fencing.'),
        plate('sydney','SydneyMartinPlace','SydneyCBD',
            'Martin Place pedestrian plaza, sandstone bank facades, cenotaph long low stone '
            'at x520–1160,y540–683, bronze figures at its ends. Sydney Tower distant skyline. '
            'Clear respectful walking lane y755–915 in front of the stone; no scattered street props. '
            'Memorial inscription left blank for restrained engine typography.',
            [sign((688,580,320,44),'LEST WE FORGET','#00000000','#4e5354',size=20)]),
        plate('sydney','SydneyTowerDeck','SydneyCBD',
            'Sydney Tower observation deck looking over the harbour: large window wall, '
            'fixed thin mullions, distant coastline and low urban grid, curved observation rail '
            'at y615. Clear indoor floor y735–925. The harbour is the subject, no giant foreground tower.'),
        plate('sydney','SydneyNewtownPub','SydneyNewtown',
            'King Street pub interior: timber bar at back right x930–1520,y540–701, '
            'pool table at left x185–520,y590–735, empty small band area rear left. '
            'Nearest communal table x628–978,y694–751, left seat x561,y785, right seat x1030,y785. '
            'Dog location beneath pool table x352,y730 left blank. Clear bar approach x840–990,y825. '
            'No baked musicians or dogs; no written logos.'),
        plate('sydney','SydneyNewtownMural','SydneyNewtown',
            'King Street street-corner mural: respectful painted portrait of Martin Luther King Jr. '
            'on brick shop wall, local iron lace balcony beside it. Blank four-word caption strip '
            'x720–1300,y515–583 for native lettering. Clear sidewalk y738–925. '
            'Portrait rendered as deliberate pixel clusters, no smooth airbrush.',
            [sign((720,515,580,68),'I HAVE A DREAM','#00000000','#eadfb8',size=32)]),
        plate('sydney','SydneyBondiSurf','SydneyBondi',
            'Bondi seen from sand toward the water. Open sand y725–941, active breaking surf '
            'band y440–718. Two red-yellow patrol flags at x515 and x1085 rooted at y735; '
            'clear central swimming area between them. Calm-looking unpatrolled water toward far right. '
            'No swimmers or rescuers baked in. All flag poles complete. Pixel waves only.',
            patches=[water(90,451,1480,262)]),
        plate('sydney','SydneyBondiPool','SydneyBondi',
            'Ocean pool at Bondi, pale rock ledge around blue lap lanes, open sea and spray beyond. '
            'Pool rectangle x225–1420,y475–800, pool wall at y811, dry walking apron y847–930. '
            'No swimmers. Ladder at far left only, kept clear of the central swimming zone.',
            patches=[water(239,493,1165,284)]),
        plate('sydney','SydneyCabramattaBakery','SydneyCabramatta',
            'Vietnamese-Australian bakery with crisp bread rolls, glass ingredient case and stainless '
            'workbench at right x905–1480,y545–718. Seller zone x1120,y583 empty. '
            'Customer queue from x420–810,y836. Rear shelves of bread, low awning glimpsed through '
            'left doorway. Blank sign x695–1350,y243–317.',
            [sign((695,243,655,74),'BÁNH MÌ · BAKERY','#e0cf9c','#2a5448',size=32)])])
    stage={}
    worker=person(1031,807,'wave',appearance={'wear':'jacket','cut':'tied','face':'',
        'pal':{'C':'#dfb94d','D':'#ad843d','O':'#414b43'}})
    quay=wide('SydneyCircularQuay',[person(805,816),worker])
    greet=close('SydneyCircularQuay',[person(805,816),worker],.58)
    answered=greet | {'cast':[person(805,816,'point'),worker | {'act':'watch'}]}
    bounced=greet | {'cast':[person(805,816,'nod'),worker | {'act':'nod'},person(1243,813,'walk')]}
    passenger=person(1205,655,'read',seated=True,clip_row=90,appearance={'build':'elder','wear':'shirt','cut':'crop'})
    ferry=wide('ActivitySydneyFerryDeck',[person(472,655,'sit',seated=True,clip_row=90),passenger],prop='book',prop_holder=1)
    lookout=ferry | {'cast':[person(810,845,'look_up'),passenger | {'act':'point'}]}
    stage['sydney:circularquay']={'wharf':beat(greet,[quay,greet]),'answered':beat(answered),
        'bounced':beat(bounced),'long':beat(answered),'ferry':beat(ferry),'looked':beat(lookout),
        'rocks':beat(wide('ActivitySydneyRocksLane',[person(807,842,'walk')]))}
    suits=[person(1052,837,'walk',appearance={'wear':'jacket','cut':'crop'}),
           person(1266,845,'walk',appearance={'wear':'jacket','cut':'crop'})]
    plaza=wide('ActivitySydneyMartinPlace',[person(533,849),*suits])
    quiet=plaza | {'cast':[person(755,849,'stand'),suits[0] | {'act':'stand'},suits[1] | {'act':'stand'}]}
    stage['sydney:cbd']={'plaza':beat(plaza,[wide('SydneyCBD',[person(829,813,'look_up')]),plaza]),
        'watched':beat(quiet),'quiet':beat(quiet),
        'tower':beat(wide('ActivitySydneyTowerDeck',[person(774,839,'look_up')]))}
    barman=person(1265,462,'watch',clip_row=18,appearance={'wear':'shirt','cut':'crop','face':''})
    band=[person(462,477,'strum',world_height=83,kit='guitar',appearance={'wear':'tee','cut':'tied'}),
          person(692,477,'watch',world_height=83,kit='microphone',appearance={'wear':'blouse','cut':'bob'})]
    pub=wide('ActivitySydneyNewtownPub',[person(700,746,'sit',seated=True,clip_row=90,world_height=100),barman,*band],
             object='sleeping_dog',object_world_at=point(305,693),object_world_unit=2)
    bar=close('ActivitySydneyNewtownPub',[person(1232,648,'take'),barman | {'act':'offer'},*band],.71,
              prop='glass',prop_holder=0)
    group=pub | {'cast':[person(700,746,'sit',seated=True,clip_row=90,world_height=100),barman,*band,
        person(1117,746,'sit',seated=True,clip_row=90,world_height=100),person(1316,823,'drink')],'prop':'glass','prop_holder':5}
    stage['sydney:newtown']={'street':beat(pub,[wide('SydneyNewtown',[person(906,815,'walk')]),pub]),
        'bar':beat(pub),'waited':beat(pub),'counter':beat(bar),'round':beat(group),
        'mural':beat(wide('ActivitySydneyNewtownMural',[person(991,843,'look_up')]))}
    swimmers=[person(736,548,'swim',world_height=82,clip_row=16,appearance={'barefoot':True}),
              person(958,581,'swim',world_height=85,clip_row=16,appearance={'barefoot':True})]
    beach=wide('ActivitySydneyBondiSurf',[person(701,849),*swimmers],plate_swimming=True)
    safe=wide('ActivitySydneyBondiSurf',[person(820,594,'swim',clip_row=16),*swimmers],plate_swimming=True)
    rescue=person(1485,566,'swim',clip_row=16,kit='paddle_board',appearance={'wear':'tee','cut':'crop','barefoot':True,
        'pal':{'C':'#d5a843','D':'#ae3934','O':'#74362f'}})
    rip=wide('ActivitySydneyBondiSurf',[person(1338,521,'swim',clip_row=16),rescue],plate_swimming=True)
    shore=wide('ActivitySydneyBondiSurf',[person(1203,845,'sit',seated=True),
        rescue | {'world_at':point(1373,846),'act':'watch','clip_row':99,'kit':''}],plate_swimming=True)
    stage['sydney:bondi']={'sand':beat(beach,[beach,beach]),'worked':beat(beach,
        choices={'between':{'staging':safe}}),'safe':beat(safe),'rip':beat(rip),'float':beat(shore),
        'hauled':beat(shore),'pool':beat(wide('ActivitySydneyBondiPool',
            [person(848,547,'swim',clip_row=16)],plate_swimming=True))}
    baker=person(1155,621,'cut',clip_row=18,appearance={'wear':'blouse','cut':'tied','face':''})
    bakery=close('ActivitySydneyCabramattaBakery',[person(796,737,'queue'),baker,
        person(515,737,'queue',appearance={'wear':'shirt','cut':'bob'})],.55)
    order=bakery | {'cast':[person(1195,747,'take'),baker | {'act':'hand_over'}],'prop':'banh_mi','prop_holder':0,'handheld_scale':.6}
    stage['sydney:cabramatta']={'arch':beat(bakery,[wide('SydneyCabramatta',[person(1334,733,'walk')]),bakery]),
        'read':beat(close('SydneyCabramatta',[person(1395,733,'look_up')],.8)),
        'queue':beat(bakery),'point':beat(order),
        'copy':beat(order | {'cast':[person(1195,747,'point'),baker | {'act':'nod'}]})}
    from .sydney_activities_finish import apply
    apply(plates)
    return plates,stage


def toronto():
    plates=dict([
        plate('toronto','TorontoStreetcarStop','TorontoDowntown',
            'Toronto streetcar stop at a downtown intersection. Red-and-white streetcar stopped '
            'in its tracks at back x555–1610,y345–678; open doorway x1080–1220. '
            'A clearly marked boarding strip at y735–830 between curb and vehicle; stopped road traffic '
            'well behind the waiting zone. CN Tower in distant skyline. No pedestrians.'),
        plate('toronto','TorontoStreetcarInterior','TorontoTransit',
            'Long Toronto red-and-white streetcar interior, yellow poles, red upholstered seats. '
            'Driver far left behind cab partition, rear exit at x1290–1450. '
            'Clear aisle x490–1130,y710–925, seats at x384,y740 and x1160,y740. '
            'No people, no labels; outside view remains fixed except subtle light.'),
        plate('toronto','TorontoMarketRoom','TorontoKensington',
            'Kensington produce shop inside a converted Victorian house front room. '
            'Shop window shows crates on porch; old domestic trim and wooden floor. '
            'Scale and cash counter x850–1400,y565–720, seller zone x1100,y601; '
            'customer x749,y842. Bananas, plantain and produce shelves. No people.'),
        plate('toronto','TorontoFabricShop','TorontoGerrard',
            'Gerrard India Bazaar textile shop interior: bolts of sari cloth on back shelves '
            'and fabrics hanging at window, teal, maroon, gold and cream palette. '
            'Keep central foreground x525–1160,y620–905 completely clear: the game draws the '
            'working cloth table and unfurling fabric there. No baked table in this reserved area.'),
        plate('toronto','TorontoBluffsTop','TorontoScarborough',
            'Scarborough Bluffs from a public lookout: pale stratified cliffs descend to Lake Ontario, '
            'water all the way to horizon. Safe observation lawn and path y760–941. '
            'Protective fence behind actors at y692, with a marked opening far left leading to safe path. '
            'No dramatic sheer foreground edge under the actor zones. Sediment bands legible, no labels.',
            [sign((210,583,210,78),'STAY ON\nMARKED PATHS','#314b3f',size=20)],
            [water(753,357,878,150)]),
        plate('toronto','TorontoBluffsBeach','TorontoScarborough',
            'At the shore below Scarborough Bluffs, pale banded sediment face rises at left, '
            'Lake Ontario and stony beach at right. No city visible. Clear dry stones '
            'x400–1040,y760–925, flat sitting rock x624,y748. No precarious overhang above actors.',
            patches=[water(1060,490,601,240)])])
    stage={}
    stop=wide('ActivityTorontoStreetcarStop',[person(831,819),person(1050,819,'queue'),person(628,819,'queue')])
    passengers=[person(527,636,'sit',seated=True,clip_row=90),
                person(1158,636,'sit',seated=True,clip_row=90)]
    inside=wide('ActivityTorontoStreetcarInterior',[person(834,840,'walk'),*passengers])
    thank=close('ActivityTorontoStreetcarInterior',[person(1270,840,'wave'),*passengers],.69)
    leave=thank | {'cast':[walk_to(person(1270,840),1430,745),*passengers]}
    stage['toronto:downtown']={'stop':beat(stop,[wide('TorontoDowntown',[person(784,800,'look_up')]),stop,inside]),
        'watched':beat(stop),'thanked':beat(thank),'on':beat(leave)}
    market=close('TorontoKensington',[person(608,748,'reach'),person(952,749,'walk')],.41,
                 prop='bag',prop_holder=0)
    seller=person(1053,545,'count',clip_row=18,appearance={'wear':'blouse','cut':'bob','face':''})
    paid=close('ActivityTorontoMarketRoom',[person(1060,767,'take'),seller],.62,prop='bag',prop_holder=0)
    waited=market | {'cast':[person(608,748,'watch'),person(952,749,'walk_away')],'prop':''}
    stage['toronto:kensington']={'street':beat(market,[wide('TorontoKensington',[person(608,748,'walk')]),market]),
        'paid':beat(paid),'waited':beat(waited)}
    merchant=person(1041,830,'unroll_cloth',appearance={'wear':'shirt','cut':'crop','face':''})
    fabric=close('ActivityTorontoFabricShop',[person(601,842),merchant],.51,
                 object='fabric_unroll',object_world_at=point(848,845),object_world_unit=2.9,
                 object_foreground=True)
    stayed=fabric | {'cast':[person(601,842,'drink'),merchant,person(1253,837,'point')],'prop':'glass','prop_holder':0}
    folded=fabric | {'cast':[person(601,842),merchant | {'act':'watch'}],'object':'fabric_folded'}
    bought=folded | {'cast':[person(601,842,'take'),merchant | {'act':'hand_over'}],
                     'prop':'fabric_roll','prop_holder':0,'handheld_scale':.65}
    stage['toronto:gerrard']={'window':beat(fabric,[fabric,fabric]),'stayed':beat(stayed),
        'stopped':beat(folded),'bought':beat(bought)}
    lane=wide('TorontoDistillery',[person(665,770,'walk')])
    trestle=close('TorontoDistillery',[person(760,810),person(1070,796,'offer')],.55,
        object='copperpot',object_world_at=point(926,827),object_world_unit=2.5)
    pot=trestle | {'cast':[person(760,810,'drink'),person(1070,796,'watch')],'prop':'cider','prop_holder':0}
    stage['toronto:distillery']={'lane':beat(trestle,[lane,trestle]),
        'walked':beat(lane),'pot':beat(pot)}
    top=wide('ActivityTorontoBluffsTop',[walk_to(person(700,818),858,818)])
    look=top | {'cast':[person(921,814,'recoil')]}
    # Show the risky choice through a recoil and retreat on the safe-side
    # mark; do not stage a character hovering in front of a cliff texture.
    edge=look | {'cast':[walk_to(person(921,814,'recoil'),786,823,2.8)]}
    beach=wide('ActivityTorontoBluffsBeach',[person(850,852,'watch')])
    stage['toronto:scarborough']={'top':beat(look,[top,look]),'read':beat(top | {'cast':[person(1120,819,'look_up')]}),
        'edge':beat(edge),'down':beat(beach)}
    from .toronto_activities_finish import apply
    apply(plates)
    return plates,stage


def build():
    plates,stage={},{}
    for fn in [newyork,saopaulo,sydney,toronto]:
        p,s=fn();plates.update(p);stage.update(s)
    return plates,stage
