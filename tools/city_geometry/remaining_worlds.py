"""Source-layout preparation for the final 35 world scenes.

These are executable layout drafts, not measurements of nonexistent final art.
Each complete object and its contact base is named for the final alignment pass.
"""
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import scene, pot, oval, bench, board, gate
from .seoul import box, seat, stool
from .hanoi import pole, route_post
from .tokyo import wheel
from .rome import sizes
from .london import rope_group


def plant(name, bounds, crown):
    x,y,w,h=bounds
    return pot(name,bounds,crown,[rect(x+w*.43,crown[1]+crown[3]*.55,w*.13,
                                      max(1,y-crown[1]-crown[3]*.55))])


def bin_(name,x,y,w=52,h=94):
    return object_(name,y+h,[(x+3,y+h-21,w-6,21)],
        [rect(x+3,y+13,w-6,h-17),rect(x,y,w,15),oval(x+w/2,y+5,w/2,6)])


def seats(name,x,y,n,w=89,h=112):
    result=[]
    for i in range(n): result.append(seat(name+str(i),x+i*w,y,w-4,h))
    return result


def bicycle(name,x,y,w=140,h=84):
    r=h*.3; bottom=y+h
    a=(x+r,bottom-r); b=(x+w-r,bottom-r)
    saddle=(x+w*.43,y+h*.32); crank=(x+w*.48,bottom-r)
    stem=(x+w*.71,y+h*.22)
    polys=wheel(*a,r)+wheel(*b,r)
    for p,q,width in [(a,saddle,4),(saddle,crank,4),(crank,a,4),
                       (saddle,stem,4),(stem,crank,4),(stem,b,4),
                       (saddle,(saddle[0]-5,saddle[1]-13),4),
                       (stem,(stem[0]+3,y+4),4),
                       ((stem[0]+3,y+4),(stem[0]+20,y+2),4)]:
        polys.append(tube(p,q,width))
    polys += [rect(saddle[0]-17,saddle[1]-16,26,5)]
    return object_(name,bottom,[(x,bottom-14,w,14)],polys)


def shelter(name,x,y,w,h):
    # Roof/frame are opaque, window interiors transmit the character, and
    # gaps under the seat contain no sampled rectangle of pavement.
    roof=object_(name+'_frame',y+h,[(x,y+h-15,16,15),(x+w-16,y+h-15,16,15)],
        [rect(x-8,y,w+16,19),rect(x,y+19,10,h-19),rect(x+w-10,y+19,10,h-19),
         rect(x+w/2-4,y+19,8,h-19),rect(x,y+h-57,w,6)],
        glass=[rect(x+10,y+19,w/2-14,h-25),rect(x+w/2+4,y+19,w/2-14,h-25)])
    return [roof,bench(name+'_bench',x+45,y+h-82,w-90,82)]


def trolley(name,x,y,w=125,h=230):
    return object_(name,y+h,[(x,y+h-23,w,23)],[
        rect(x,y+h-32,w,15),rect(x+8,y+28,8,h-53),rect(x+w-16,y+28,8,h-53),
        tube((x+12,y+28),(x+30,y+9),8),rect(x+30,y+5,w-60,8),
        tube((x+w-30,y+9),(x+w-12,y+28),8),
        rect(x+22,y+h-123,40,92),rect(x+68,y+h-101,32,70),
        rect(x+32,y+h-140,21,18),oval(x+18,y+h-10,11,10),oval(x+w-18,y+h-10,11,10)])


def queue(name,xs,y):
    return rope_group(name,xs,y-144,y)


def counter(name,x,y,w,h):
    # Deep cabinetry blocks its floor volume, while the top remains a
    # foreground silhouette for the correctly offset service clerk.
    return object_(name,y+h,[(x+4,y+h-45,w-8,45)],[rect(x,y,w,h)])


def row(key,floor,spawn,obs,anchors,labels=(),**extra):
    return scene(key,floor,spawn,obs,{k:anchor(*v) for k,v in anchors.items()},labels,
        interaction_sizes=sizes(*[k for k in anchors if not k.startswith(('Npc','Key','Encounter'))]),
        **extra)


def wayfind(obs,fixtures,name,x,y,text):
    obj,fixture=route_post(name,x,y,text)
    obs.append(obj); fixtures.append(fixture)


def ny():
    out={}
    obs=[box('stoop',589,512,155,190),bin_('trash_can',1325,605),
         box('dumpster',1519,594,150,102),box('delivery_boxes',1419,642,90,54)]
    for i,(x,w) in enumerate([(764,132),(926,119),(1051,66)]):
        obs.append(box('produce_'+str(i),x,607,w,91))
    fx=[];wayfind(obs,fx,'airport_route',1251,745,'AIRPORT →')
    wayfind(obs,fx,'subway_route',1573,798,'SUBWAY →')
    out['NewYorkLowerEast']=row('NewYorkLowerEast',692,(554,841),obs,{
        'AirportDoor':(1251,786),'TransitDoor':(1573,841),'LocalSpot':(999,772),
        'NpcDov':(449,826),'ExitWest':(51,850)},[
        sign((78,439,488,81),'LAUNDROMAT','#23564e',size=32),
        sign((813,450,440,75),'DELI & GROCERY','#8b352e',size=28)],fittings=fx,
        animation_patches=[dict(kind='washer',rect=[*point(x,558),*point(54,57)]) for x in [269,360]])
    obs=[]
    for i,(x,w) in enumerate([(188,131),(529,142),(872,150)]):
        obs.append(object_('stoop_'+str(i),690,[(x,526,w,164)],[rect(x,498,w,192)]))
    for i,(x,w) in enumerate([(0,170),(320,205),(676,191),(1028,165)]):
        obs.append(gate('areaway_'+str(i),x,561,w,127,20))
    obs += [plant('west_tree',(39,647,52,39),(0,285,184,270)),
            plant('east_tree',(1141,648,40,38),(1035,225,187,310)),
            pot('stoop_pot_a',(355,645,58,45),(337,525,79,126)),
            pot('stoop_pot_b',(430,648,62,45),(423,588,78,65)),
            bicycle('bicycle',711,628,139,80),seat('white_chair',1112,605,51,97),
            bin_('litter_bin',1187,653,56,90),pole('parking_meter',1454,624,744,12),
            box('hydrant',1607,668,40,72)]
    fx=[];wayfind(obs,fx,'subway_route',1326,756,'SUBWAY →')
    out['NewYorkHarlem']=row('NewYorkHarlem',674,(657,830),obs,{
        'TransitDoor':(1326,799),'LocalSpot':(620,762)},[
        sign((1222,205,436,162),'HARLEM\nMARKET','#255950',size=36),
        sign((1222,373,436,39),'COFFEE · SANDWICHES','#c9d7c7','#204743',size=18)],fittings=fx)
    obs=[box('workshop_bin',0,638,130,115),box('shipping_pallets',1429,621,115,119),
         board('cafe_menu',697,667,57,89),pot('cafe_plant',(608,705,73,50),(592,649,106,57)),
         plant('shipping_plant',(1150,703,47,49),(1138,620,71,96)),
         pot('window_trough',(1010,721,114,32),(1007,680,118,42))]
    for i,x in enumerate([424,458,1252,1623]): obs.append(pole('safety_post'+str(i),x,675,758,14))
    for i,x in enumerate([852,917]): obs.append(stool('cafe_stool'+str(i),x,700,44,48))
    fx=[];wayfind(obs,fx,'subway_route',578,787,'SUBWAY →')
    out['NewYorkWilliamsburg']=row('NewYorkWilliamsburg',737,(943,859),obs,{
        'TransitDoor':(578,833),'LocalSpot':(1040,813)},[
        sign((194,420,237,48),'BIKE REPAIR','#30343a',size=24),
        sign((709,421,368,77),'CAFÉ','#252d37',size=42),
        sign((1310,479,224,50),'SHIPPING','#343a42',size=23)],fittings=fx)
    obs=[box('west_viaduct_column',393,120,77,655),box('east_viaduct_column',1237,120,78,655),
         bin_('west_bin',15,668,58,108),bin_('market_bin',1133,633,64,128),
         board('menu',1564,633,71,91)]
    for i,(x,y,w,h) in enumerate([(492,659,54,72),(732,671,64,68),(817,679,118,71),
                                 (935,685,116,62),(1057,695,59,54)]):
        obs.append(box('market_display'+str(i),x,y,w,h))
    fx=[];wayfind(obs,fx,'subway_route',1493,792,'7 · SUBWAY →')
    out['NewYorkJacksonHeights']=row('NewYorkJacksonHeights',735,(651,859),obs,{
        'TransitDoor':(1493,837),'LocalSpot':(917,819)},[
        sign((0,334,392,112),'DOSA EXPRESS\nINDIAN CUISINE','#d5a739','#283c37',size=26),
        sign((504,334,350,112),'BAKERY\nPAN · DULCES','#9f342f',size=28),
        sign((887,334,351,112),'FRESH MARKET\nPRODUCE · HALAL','#21584b',size=25),
        sign((1320,334,346,112),'BANGLA BAZAR\nGROCERIES','#873744',size=25)],
        fittings=fx,animation_patches=[dict(kind='train',rect=[*point(0,0),*point(1672,121)])])
    obs=[trolley('luggage_cart',277,400,165,260),counter('reception',480,479,626,177),
         box('sofa',1176,511,346,141),plant('east_plant',(1568,567,61,85),(1537,305,119,260))]
    out['NewYorkHotel']=row('NewYorkHotel',621,(913,835),obs,{'Exit':(181,660),'Point':(809,723)},[
        sign((584,193,431,62),'MIDTOWN HOTEL','#b3a58e','#273236',size=30),
        sign((612,491,365,36),'RECEPTION','#76533b',size=21,object='reception')],
        clerks={'Point':point(809,498)})
    obs=[counter('exchange_counter',567,447,698,173),queue('queue_rail',[658,974,1311],727),
         bin_('bin',1483,543,62,91),plant('plant',(1582,562,61,71),(1542,398,105,169))]
    obs+=seats('waiting_seat',302,507,2,101,145)
    out['NewYorkExchange']=row('NewYorkExchange',612,(786,842),obs,{'Exit':(185,659),'Point':(964,630)},[
        sign((571,127,692,111),'CURRENCY EXCHANGE','#193966',size=34),
        sign((1300,124,248,269),'RATES\nUSD · EUR\nGBP · JPY\nCAD','#202c36',size=26)],
        clerks={'Point':point(964,441)})
    obs=[box('west_column',326,0,121,758),box('east_column',1237,0,122,758),
         bench('platform_bench',595,570,414,151),bin_('bin',1367,610,82,134),
         object_('stair_side',751,[(0,693,201,58)],
                 [[[0,520],[202,733],[202,751],[0,549]],tube((0,492),(199,682),8)])]
    fx=[dict(kind='ticket',at=point(1541,740))]
    obs.append(object_('ticket_base',740,[(1510,724,62,16)],[]))
    out['NewYorkTransit']=row('NewYorkTransit',665,(1092,854),obs,{
        'Exit':(260,784),'Machine':(1541,789),'Platform':(1111,710)},[
        sign((641,247,386,70),'42 STREET','#1d2934',size=35),
        sign((122,223,186,123),'UPTOWN\nTHE BRONX\n←','#203242',size=23)],fittings=fx,
        motion_layers=[dict(kind='doors',rect=[*point(1090,420),*point(97,228)])])
    obs=[counter('information_counter',866,728,341,93),
         object_('carousel',795,[(997,701,675,94)],[rect(997,645,675,145)]),
         box('flight_display',99,344,173,238),trolley('luggage_trolleys',627,600,212,130)]
    obs+=seats('gate_seat',74,628,4,91,153)
    for i,(p,c) in enumerate([((0,614,37,53),(0,565,51,55)),((47,618,48,49),(43,564,59,57)),
                              ((514,671,66,64),(503,597,84,80)),((895,609,56,61),(887,544,64,71)),
                              ((1595,580,63,77),(1586,505,79,84))]): obs.append(plant('plant'+str(i),p,c))
    out['NewYorkAirport']=row('NewYorkAirport',654,(681,847),obs,{'Exit':(1562,839),'Point':(1039,871)},[
        sign((288,122,467,107),'GATES A1–A8','#263745',size=38),
        sign((989,120,514,110),'BAGGAGE CLAIM →\nGROUND TRANSPORT →','#263745',size=28),
        sign((1133,341,374,105),'COFFEE','#503322',size=36)],
        clerks={'Point':point(1039,733)},prompt_overrides={'Exit':'E — Ground transport to the city'},
        animation_patches=[dict(kind='conveyor',rect=[*point(1045,651),*point(615,42)])])
    return out


def sp():
    out={}
    obs=[]
    # The lantern arms and globes belong to the same depth as their pole.
    for i,x in enumerate([215,963]):
        polys=[rect(x-12,185,24,624),rect(x-39,229,78,13),rect(x-17,794,34,16),
               tube((x-39,235),(x-63,258),10),tube((x+39,235),(x+63,258),10),
               oval(x-63,279,24,35),oval(x+63,279,24,35)]
        obs.append(object_('suzuranto_'+str(i),810,[(x-17,793,34,17)],polys))
    obs += [plant('west_tree',(484,726,91,65),(428,228,197,411)),
            plant('east_tree',(1595,726,71,66),(1491,209,181,421)),
            pot('bookshop_pot',(1031,726,34,41),(1022,650,56,82)),bin_('bin',1258,715,46,68)]
    fx=[];wayfind(obs,fx,'metro_route',1441,813,'METRÔ →')
    out['SaoPauloLiberdade']=row('SaoPauloLiberdade',760,(686,867),obs,{
        'HotelDoor':(414,805),'ExchangeDoor':(1175,805),'TransitDoor':(1441,855),
        'NpcJandira':(740,864),'LocalSpot':(579,814),'ExitEast':(1620,880)},[
        sign((254,422,204,105),'ホテル','#f1e5c5','#972f2f',size=32,font='res://art/fonts/NotoSansJP.ttf'),
        sign((644,414,209,96),'ラーメン','#eee6ca','#2e373c',size=33,font='res://art/fonts/NotoSansJP.ttf'),
        sign((1115,450,146,75),'CÂMBIO','#eee6ca','#263834',size=19),
        sign((1339,497,213,50),'PADARIA','#d6b252','#263d3d',size=24)],fittings=fx)
    obs=[pot('bakery_pot',(474,647,42,66),(458,557,73,96)),
         pot('workshop_pot',(864,647,59,67),(855,553,86,95)),
         bench('bench',1044,653,178,65),
         plant('tree',(1245,704,142,62),(1236,518,159,190)),box('crates',1573,621,97,99)]
    fx=[];wayfind(obs,fx,'metro_route',609,776,'METRÔ →');wayfind(obs,fx,'airport_route',1500,787,'AEROPORTO →')
    out['SaoPauloBixiga']=row('SaoPauloBixiga',718,(972,867),obs,{
        'AirportDoor':(1500,831),'TransitDoor':(609,824),'LocalSpot':(436,797),
        'NpcWellington':(1126,844),'KeyNeusa':(788,837),'ExitWest':(52,857)},[
        sign((75,426,432,82),'PADARIA','#235944',size=31),
        sign((592,439,209,51),'CONSERTO','#d9dbcf','#27313c',size=26),
        sign((1028,523,181,36),'CONGELADOS','#754030',size=14)],fittings=fx)
    obs=[]
    for i,(x,w) in enumerate([(23,274),(422,146),(575,235),(931,76),(1133,82),(1376,160)]):
        obs.append(box('produce_or_crates_'+str(i),x,636 if i<3 else 626,w,96 if i<3 else 113))
    obs.append(box('pallet_jack_base',1218,707,75,34))
    obs.append(object_('truck',754,[(1580,716,92,38)],[rect(1580,533,92,204),oval(1621,739,19,18)]))
    fx=[];wayfind(obs,fx,'metro_route',1466,824,'METRÔ →')
    out['SaoPauloMercadao']=row('SaoPauloMercadao',733,(697,862),obs,{
        'TransitDoor':(1466,865),'LocalSpot':(480,812)},[
        sign((729,307,181,52),'MERCADÃO','#d8c0a0','#863d31',size=25)],fittings=fx)
    obs=shelter('bus_shelter',148,497,500,240)
    obs += [plant('west_tree',(27,673,99,64),(0,196,266,440)),
            plant('center_tree',(654,692,245,52),(634,448,199,240)),bin_('bin',917,643,65,101),
            object_('metro_left',738,[(1110,714,41,24)],[rect(1110,401,41,337)]),
            object_('metro_right',738,[(1563,714,41,24)],[rect(1563,401,41,337)]),
            object_('metro_lintel',738,[(1110,714,41,24),(1563,714,41,24)],[rect(1094,398,525,116)])]
    out['SaoPauloPaulista']=row('SaoPauloPaulista',720,(1045,859),obs,{
        'TransitDoor':(1366,770),'LocalSpot':(745,811)},[
        sign((1172,430,375,64),'METRÔ','#22303c',size=38)])
    obs=[plant('west_tree',(0,698,151,61),(0,247,221,445)),
         pot('cafe_pot',(599,705,57,56),(584,625,88,88)),
         board('menu',1008,648,78,121),bicycle('bicycle',1245,640,208,123),
         pot('east_pot',(1620,705,47,56),(1612,650,60,66))]
    for i,x in enumerate([231,310,389]): obs.append(stool('cafe_stool'+str(i),x,693,53,72))
    fx=[];wayfind(obs,fx,'metro_route',1536,807,'METRÔ →')
    out['SaoPauloVilaMadalena']=row('SaoPauloVilaMadalena',753,(834,861),obs,{
        'TransitDoor':(1536,852),'LocalSpot':(976,815),'Encounter':(683,864)},[
        sign((221,423,410,71),'CAFÉ','#34684c',size=44),
        sign((1021,663,52,67),'CAFÉ\nCHÁ','#283a3b',size=13,object='menu')],fittings=fx,
        encounter_exit={'to':point(1640,864),'via':[point(1300,864)],'doorway_clearance':0})
    obs=[counter('reception',449,436,444,151),trolley('luggage_cart',66,389,92,204),
         box('suitcase',172,432,86,156),plant('lobby_tree',(293,517,72,68),(247,243,155,279)),
         plant('counter_plant',(883,521,70,67),(874,378,82,151)),
         box('armchair_left',1000,461,155,123),box('armchair_right',1286,461,155,123),
         object_('coffee_table',605,[(1168,583,113,22)],[rect(1168,539,113,14),rect(1176,553,10,50),rect(1265,553,10,50)]),
         pot('table_plant',(1185,512,62,25),(1172,469,86,50))]
    out['SaoPauloHotel']=row('SaoPauloHotel',566,(813,827),obs,{'Exit':(1630,623),'Point':(682,646)},[
        sign((47,182,255,125),'HOTEL\nSÃO PAULO','#d8c7ac','#5a3d2f',size=29),
        sign((526,455,287,35),'RECEPÇÃO','#875b37',size=24,object='reception')],clerks={'Point':point(682,446)})
    obs=[counter('exchange_counter',586,415,542,149),queue('queue',[457,672,904],632),
         plant('west_plant',(278,496,82,81),(254,349,111,153)),
         plant('east_plant',(1404,521,91,71),(1359,404,139,125))]+seats('waiting',1169,483,2,92,145)
    out['SaoPauloExchange']=row('SaoPauloExchange',550,(1042,809),obs,{'Exit':(174,613),'Point':(863,592)},[
        sign((338,99,196,238),'CÂMBIO\nEXCHANGE','#eee3cb','#293d48',size=26),
        sign((1160,102,242,197),'MOEDAS\nUSD · EUR\nGBP · JPY','#213b58',size=27)],clerks={'Point':point(863,416)})
    obs=[box('map_case',488,363,139,411),box('newsstand',650,376,207,393),
         bin_('bin',1343,567,75,206),box('right_pier',1507,0,130,776)]
    obs+=seats('platform_seat',936,584,3,103,191)
    for i,x in enumerate([138,228,324,416]): obs.append(box('gate'+str(i),x,375,53,232))
    fx=[dict(kind='ticket',at=point(836,851))];obs.append(object_('ticket_base',851,[(805,835,62,16)],[]))
    out['SaoPauloTransit']=row('SaoPauloTransit',595,(1103,855),obs,{
        'Exit':(264,664),'Machine':(836,891),'Platform':(1468,847)},[
        sign((727,175,724,206),'METRÔ\nLINHA 1 · AZUL →','#144b88',size=43),
        sign((663,390,174,54),'REVISTAS','#8a322d',size=25)],fittings=fx)
    obs=[object_('carousel',735,[(1211,658,461,77)],[rect(1211,618,461,116)]),
         box('recycling_bin',1039,590,100,116),trolley('trolleys',0,628,230,121),
         plant('cafe_west_plant',(296,643,81,81),(287,496,94,151)),
         plant('cafe_east_plant',(836,642,80,82),(813,504,112,145)),
         counter('information_counter',991,791,326,94)]
    obs+=seats('gate_left',343,780,3,94,137)+seats('gate_right',669,780,3,94,137)
    out['SaoPauloAirport']=row('SaoPauloAirport',710,(577,749),obs,{
        'Exit':(1507,786),'Point':(1156,923)},[
        sign((179,173,506,157),'← EMBARQUE\nDEPARTURES','#173967',size=34),
        sign((712,173,451,157),'DESEMBARQUE\nARRIVALS','#173967',size=34),
        sign((461,456,356,66),'CAFÉ','#433f31',size=36)],clerks={'Point':point(1156,791)},
        animation_patches=[dict(kind='conveyor',rect=[*point(1215,625),*point(448,43)])])
    return out


def syd():
    out={}
    obs=[bench('west_bench',345,670,202,84),bench('east_bench',1193,670,202,84)]
    for i,x in enumerate([134,618,1013,1480]):obs.append(bin_('quay_bin'+str(i),x,678,36,80))
    for i,x in enumerate([288,1542]):
        obs.append(object_('quay_lamp'+str(i),758,[(x-12,743,24,15)],[rect(x-6,500,12,250),oval(x,489,19,20)]))
    for i,(x,w) in enumerate([(0,334),(554,172),(990,190),(1430,242)]):obs.append(gate('quay_rail'+str(i),x,520,w,98,34))
    for i,(name,x,w) in enumerate([('hotel',16,112),('ferry',727,253),('exchange',1185,241)]):
        obs.append(box(name+'_kiosk',x,599,w,74))
    out['SydneyCircularQuay']=row('SydneyCircularQuay',672,(813,858),obs,{
        'HotelDoor':(170,721),'ExchangeDoor':(1317,718),'TransitDoor':(856,723),
        'LocalSpot':(1019,811),'NpcJen':(1095,864),'ExitEast':(1620,870)},[
        sign((19,453,155,65),'HOTEL','#345749',size=23),
        sign((374,458,276,66),'FERRIES','#1b634a',size=32),
        sign((739,455,225,66),'TICKETS','#e7ddbc','#243a4a',size=27),
        sign((1195,454,216,66),'EXCHANGE','#e7ddbc','#243a4a',size=23)],
        prompt_overrides={'HotelDoor':'E — Harbour hotel entrance','TransitDoor':'E — Ferry and train tickets'},
        animation_patches=[dict(kind='water',rect=[*point(765,335),*point(889,119)])])
    obs=[bench('west_bench',135,671,192,85),bin_('west_bin',58,664,53,90),
         plant('west_tree',(163,714,95,26),(64,371,328,312)),
         object_('map_frame',758,[(465,734,20,24),(715,734,20,24)],
                 [rect(465,556,270,21),rect(466,576,19,182),rect(715,576,20,182),rect(486,576,228,158)]),
         box('newsstand',1393,510,255,236),bin_('station_bin',1315,666,48,90),
         object_('station_west_pier',740,[(797,711,49,29)],[rect(797,420,49,320)]),
         object_('station_east_pier',740,[(1230,711,49,29)],[rect(1230,420,49,320)])]
    fx=[];wayfind(obs,fx,'airport_route',1600,817,'AIRPORT →')
    out['SydneyCBD']=row('SydneyCBD',741,(881,864),obs,{'TransitDoor':(1040,784),
        'AirportDoor':(1600,859),'LocalSpot':(655,813),'NpcThuy':(396,852),'ExitWest':(53,869)},[
        sign((855,460,382,69),'T · TOWN HALL','#254766',size=31),
        sign((1418,525,214,64),'NEWS','#e8e1cd','#293e50',size=34)],fittings=fx)
    obs=[plant('street_tree',(1097,713,73,54),(994,287,359,420)),
         plant('cafe_plant',(653,713,74,51),(637,556,112,167)),
         pot('record_pot',(101,710,65,56),(96,664,73,57)),
         bench('east_bench',1215,686,324,80),bin_('east_bin',1570,674,61,90)]
    for i,x in enumerate([69,1368]):obs.append(object_('lamp'+str(i),767,[(x-10,750,20,17)],
        [rect(x-6,495,12,259),oval(x,489,15,19)]))
    fx=[];wayfind(obs,fx,'station_route',525,815,'STATION →')
    out['SydneyNewtown']=row('SydneyNewtown',737,(950,861),obs,{'TransitDoor':(525,857),'LocalSpot':(810,811)},[
        sign((176,481,240,73),'RECORDS','#303847',size=28),
        sign((801,481,251,73),'KEBAB','#f0d9a8','#914632',size=33),
        sign((1398,255,247,232),'NEWTOWN\nGOOD\nPEOPLE','#da918e','#22364c',size=29)],fittings=fx)
    obs=[]
    for i,(x,w) in enumerate([(0,865),(1025,389),(1634,38)]):obs.append(gate('promenade_rail'+str(i),x,513,w,70,77))
    for i,x in enumerate([154,1112]):obs.append(bin_('beach_bin'+str(i),x,585,46,83))
    obs.append(box('board_rack',1437,555,193,124))
    fx=[];wayfind(obs,fx,'bus_route',1089,749,'BUSES ↑')
    out['SydneyBondi']=row('SydneyBondi',658,(774,830),obs,{'TransitDoor':(944,723),'LocalSpot':(692,775)},[
        sign((399,358,171,43),'BONDI','#e7dab6','#26364a',size=28),
        sign((1150,317,316,58),'BEACH CAFÉ','#e5d5a4','#263e4a',size=29)],fittings=fx,
        animation_patches=[dict(kind='water',rect=[*point(50,165),*point(1280,114)])])
    obs=[box('west_produce',24,543,134,119),box('middle_produce',255,553,140,112),
         box('citrus',383,587,187,77),box('east_produce',878,571,225,91),
         bin_('shop_bin',709,595,51,69),bin_('gate_bin',1617,591,54,88),
         bench('plaza_bench',1322,593,205,85),
         object_('gate_west_column',658,[(1225,630,44,28)],[rect(1225,172,44,486)]),
         object_('gate_east_column',658,[(1571,630,44,28)],[rect(1571,171,44,487)])]
    fx=[];wayfind(obs,fx,'station_route',1140,724,'STATION →')
    out['SydneyCabramatta']=row('SydneyCabramatta',654,(764,820),obs,{'TransitDoor':(1140,769),'LocalSpot':(496,732)},[
        sign((59,230,311,104),'PHỞ','#a3342d',size=45),
        sign((387,230,342,104),'TÂN PHÁT\nASIAN GROCER','#255d4b',size=32),
        sign((763,230,367,104),'金豐超市','#e6c270','#912f2d',size=40,font='res://art/fonts/NotoSansJP.ttf'),
        sign((1284,179,258,69),'CABRAMATTA','#d6ad58','#433524',size=30)],fittings=fx)
    obs=[counter('reception',513,380,802,182),trolley('luggage_trolley',42,337,184,256),
         box('umbrella_stand',338,457,81,99),plant('east_plant',(1382,448,85,101),(1322,225,184,232)),
         box('sofa',687,592,488,198),
         object_('coffee_table',791,[(506,766,183,25)],[rect(506,700,183,83)]),
         pot('table_plant',(583,681,62,37),(558,629,109,56))]
    out['SydneyHotel']=row('SydneyHotel',547,(1354,863),obs,{'Exit':(204,600),'Point':(987,620)},[
        sign((714,179,299,72),'HOTEL','#d7c19b','#283941',size=44),
        sign((365,231,139,129),'KEYS\nLUGGAGE\nTOURS','#23323e',size=22)],clerks={'Point':point(987,381)})
    obs=[counter('exchange_counter',551,519,737,122),plant('east_plant',(1561,618,93,82),(1538,498,134,133))]
    out['SydneyExchange']=row('SydneyExchange',669,(811,833),obs,{'Exit':(209,727),'Point':(920,697)},[
        sign((506,152,767,97),'CURRENCY EXCHANGE','#1e3c5c',size=40),
        sign((1057,293,203,220),'AUD\nUSD · EUR\nGBP · JPY','#273b4c',size=29)],clerks={'Point':point(920,525)})
    obs=seats('platform_seat',62,536,4,105,162)
    for i,x in enumerate([569,701,839,977,1109]):obs.append(box('ticket_gate'+str(i),x,518,64,159))
    obs += [box('left_support',198,0,49,536),box('right_wall',1430,0,242,695)]
    fx=[dict(kind='ticket',at=point(1305,817))];obs.append(object_('ticket_machine_base',817,[(1274,801,62,16)],[]))
    out['SydneyTransit']=row('SydneyTransit',673,(798,854),obs,{'Exit':(1360,737),
        'Machine':(1305,860),'Platform':(476,721)},[
        sign((589,113,531,105),'PLATFORMS 1–4 →','#326452',size=35),
        sign((1463,197,177,161),'TRAINS\nBUSES\nWAY OUT →','#283b4e',size=24)],fittings=fx,
        motion_layers=[dict(kind='doors',rect=[*point(564,355),*point(93,181)])])
    obs=seats('gate_left',212,604,5,77,119)+seats('gate_right',674,604,2,77,119)
    obs += [plant('west_plant',(47,649,102,84),(48,526,87,129)),
            object_('carousel',759,[(904,680,545,79)],[rect(902,635,547,122)]),
            counter('information_counter',674,802,323,87),box('right_wall',1446,393,226,377)]
    out['SydneyAirport']=row('SydneyAirport',708,(475,841),obs,{'Exit':(1593,817),'Point':(834,922)},[
        sign((433,84,594,179),'← DEPARTURES\n← ARRIVALS','#24384e',size=37),
        sign((1096,78,429,184),'GATES →\n1–10','#24384e',size=39)],clerks={'Point':point(834,802)},
        animation_patches=[dict(kind='conveyor',rect=[*point(922,645),*point(507,42)])])
    return out


def tor():
    out={}
    obs=shelter('ttc_shelter',821,474,432,212)
    obs += [pot('hotel_pot',(152,610,64,53),(143,560,82,63)),
            plant('hotel_tree',(372,615,192,70),(374,282,214,333)),
            pot('exchange_pot',(615,634,71,50),(606,585,91,61)),
            bin_('west_bin',731,619,57,110),bin_('east_bin',1384,610,64,114),
            pole('lamp',1307,316,723,13)]
    fx=[];wayfind(obs,fx,'streetcar_post',1425,789,'TTC →')
    out['TorontoDowntown']=row('TorontoDowntown',681,(963,835),obs,{
        'HotelDoor':(287,704),'ExchangeDoor':(688,704),'TransitDoor':(1425,829),
        'LocalSpot':(548,780),'NpcPriya':(905,838),'ExitEast':(1620,853)},[
        sign((176,352,240,89),'HOTEL','#343a32','#e9c76a',size=36),
        sign((624,361,243,72),'EXCHANGE','#273f63',size=28),
        sign((1401,372,263,64),'CONVENIENCE','#28664b',size=24)],fittings=fx)
    obs=[]
    for i,(p,c) in enumerate([((43,602,218,66),(0,521,281,105)),((384,615,160,54),(374,538,176,82)),
        ((778,615,72,50),(778,547,76,72)),((1329,610,72,51),(1330,535,77,77))]):obs.append(pot('planter'+str(i),p,c))
    for i,(x,w) in enumerate([(558,168),(913,128),(1221,114)]):obs.append(box('produce_table'+str(i),x,579,w,80))
    obs += [pole('west_utility_pole',165,44,727,25),pole('east_utility_pole',1630,37,720,21),
            bin_('litter_bin',1456,627,65,94),
            object_('clothes_rail',680,[(1069,667,16,13),(1143,667,16,13)],
                [rect(1069,530,90,7),rect(1069,537,8,140),rect(1151,537,8,140),
                 rect(1080,544,61,101)])]
    fx=[];wayfind(obs,fx,'airport_route',1515,773,'AIRPORT →');wayfind(obs,fx,'ttc_route',864,736,'TTC →')
    out['TorontoKensington']=row('TorontoKensington',667,(1071,831),obs,{
        'AirportDoor':(1515,816),'TransitDoor':(864,779),'LocalSpot':(510,748),
        'NpcWes':(671,824),'ExitWest':(52,845)},[
        sign((274,420,241,57),'BOOKS','#dec48c','#303b42',size=30),
        sign((806,420,244,57),'RECORDS','#344b44','#edda9b',size=27)],fittings=fx)
    obs=shelter('ttc_shelter',1109,480,417,219)
    obs += [pot('west_planter',(0,608,86,60),(0,552,94,61)),bin_('bin',127,618,59,101),
            pot('east_planter',(1549,611,123,62),(1548,544,124,75)),pole('street_lamp',1514,356,718,13)]
    for i,(x,w) in enumerate([(752,95),(852,72),(931,87)]):obs.append(box('grocer_display'+str(i),x,604,w,59))
    fx=[];wayfind(obs,fx,'ttc_route',1041,756,'TTC →')
    out['TorontoGerrard']=row('TorontoGerrard',668,(865,839),obs,{'TransitDoor':(1041,797),'LocalSpot':(427,749)},[
        sign((0,340,379,93),'FABRICS','#1d4770',size=38),
        sign((408,340,382,93),'JEWELLERS','#3d352c','#edcf86',size=32),
        sign((821,340,466,93),'GROCERY','#245f44',size=38)],fittings=fx)
    obs=[board('menu',77,491,87,144),bin_('west_bin',210,567,51,109),
         pot('west_planter',(278,553,92,114),(273,501,104,64)),
         pot('middle_planter',(657,597,69,69),(650,551,86,51)),
         pot('barrel_planter',(1005,580,75,79),(995,530,94,55)),
         plant('courtyard_tree',(1054,520,91,97),(1020,430,133,99)),
         pot('east_planter',(1357,600,81,58),(1349,554,98,54)),
         pot('east_box',(1451,560,68,102),(1443,499,90,67)),
         pot('far_east',(1583,600,73,66),(1571,528,94,81)),
         pole('center_lamp',1193,215,611,12),pole('bollard',1343,662,711,17),
         object_('barrel_cart',667,[(779,640,189,27)],[rect(779,613,189,23),
             oval(799,650,15,15),oval(946,650,15,15),oval(811,553,31,62),
             oval(907,535,38,48),oval(914,598,34,27),oval(842,600,30,26)])]
    fx=[];wayfind(obs,fx,'ttc_route',1221,731,'TTC →')
    out['TorontoDistillery']=row('TorontoDistillery',660,(868,823),obs,{'TransitDoor':(1221,773),'LocalSpot':(477,745)},[
        sign((727,311,279,126),'DISTILLERY\nDISTRICT','#995e42',size=32),
        sign((87,506,68,88),'CAFÉ\nCIDER','#204057',size=12,object='menu')],fittings=fx)
    obs=shelter('bus_shelter',1020,410,417,247)
    for i,(p,c) in enumerate([((0,609,263,51),(0,475,281,141)),((343,609,139,51),(336,551,154,65)),
        ((541,609,300,51),(529,524,318,93))]):obs.append(pot('planter'+str(i),p,c))
    obs.append(bin_('bin',917,574,61,111))
    for i,x in enumerate([1486,1574]):obs.append(bicycle('cycle'+str(i),x,573,72,98))
    fx=[];wayfind(obs,fx,'bus_post',884,758,'TTC →')
    out['TorontoScarborough']=row('TorontoScarborough',656,(740,828),obs,{'TransitDoor':(884,803),'LocalSpot':(520,750)},[
        sign((48,317,434,72),'BAKERY','#9f3832',size=34),
        sign((526,317,473,72),'FAMILY FOODS','#306248',size=32),
        sign((1149,317,511,72),'PHARMACY','#285582',size=34)],fittings=fx)
    obs=[counter('reception',447,420,577,160),trolley('luggage_trolley',90,372,126,223),
         box('umbrella_stand',304,489,88,91),box('armchair',1061,465,165,153),
         box('sofa',1356,455,258,161),plant('sofa_plant',(1286,491,62,103),(1240,353,136,144)),
         object_('coffee_table',640,[(1230,618,179,22)],[rect(1230,554,179,17),rect(1237,571,10,69),rect(1390,571,10,69)])]
    out['TorontoHotel']=row('TorontoHotel',566,(849,824),obs,{'Exit':(184,626),'Point':(738,638)},[
        sign((467,197,520,81),'TORONTO HOTEL','#cdb394','#2c3435',size=38),
        sign((612,432,281,33),'RECEPTION','#725237',size=22,object='reception')],clerks={'Point':point(738,419)})
    obs=[counter('exchange_counter',302,499,1044,164),queue('short_queue',[363,588],736),
         pot('counter_plant',(1245,452,45,52),(1225,388,73,72))]
    out['TorontoExchange']=row('TorontoExchange',649,(1019,843),obs,{'Exit':(167,696),'Point':(1050,718)},[
        sign((305,146,231,153),'CURRENCY\nEXCHANGE','#284a7f',size=26),
        sign((962,137,283,216),'CAD · USD\nEUR · GBP\nEXCHANGE','#233246',size=27)],clerks={'Point':point(1050,510)})
    obs=seats('platform_seat',882,651,4,96,147)
    obs += [bin_('platform_bin',1318,607,103,188),box('right_pier',1558,0,81,653),
            box('left_pier',276,0,83,524),box('ticket_machine',456,479,91,198)]
    for i,x in enumerate([87,224,351]):obs.append(box('fare_gate'+str(i),x,481,66,196))
    out['TorontoTransit']=row('TorontoTransit',636,(743,844),obs,{'Exit':(422,711),
        'Machine':(503,724),'Platform':(709,679)},[
        sign((944,95,394,50),'LINE 1','#202c35',size=23),
        sign((518,105,512,177),'SUBWAY\nYONGE–UNIVERSITY','#263442',size=32)],
        motion_layers=[dict(kind='doors',rect=[*point(941,379),*point(128,188)])])
    obs=seats('terminal_seat',112,508,4,91,125)
    obs += [trolley('trolleys',479,537,224,128),counter('information_counter',960,499,378,123),
         plant('west_plant',(7,560,63,69),(0,386,80,176)),
         object_('carousel',773,[(1198,698,474,75)],[rect(1194,636,478,133)]),
         box('west_suitcase',1392,563,83,73),box('east_suitcase',1563,554,91,79),
         bin_('bin',740,556,41,60)]
    out['TorontoAirport']=row('TorontoAirport',608,(836,825),obs,{'Exit':(1569,816),'Point':(1155,677)},[
        sign((872,123,344,140),'ARRIVALS','#253b51',size=37)],clerks={'Point':point(1155,500)},
        animation_patches=[dict(kind='conveyor',rect=[*point(1252,646),*point(408,44)])])
    return out


def build():
    rows=ny() | sp() | syd() | tor()
    from .newyork_finish import apply
    rows=apply(rows)
    from .saopaulo_finish import apply as finish_saopaulo
    rows=finish_saopaulo(rows)
    from .sydney_finish import apply as finish_sydney
    rows=finish_sydney(rows)
    from .toronto_finish import apply as finish_toronto
    rows=finish_toronto(rows)
    for key,value in rows.items():
        value.update(city=next(city for city,prefix in [('newyork','NewYork'),('saopaulo','SaoPaulo'),
                         ('sydney','Sydney'),('toronto','Toronto')] if key.startswith(prefix)),
                     implementation_stage='prepared_source_layout', art_pending=True,
                     alignment_status='final_art_required')
    return rows
