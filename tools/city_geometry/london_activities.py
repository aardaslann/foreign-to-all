"""London activity staging anchored to the pictured pavement and furniture."""
from copy import deepcopy
from .shapes import point, sign


def actor(x,y,act='watch',**extra):
    return dict(world_at=point(x,y),world_height=94,act=act,z=.62,seat=False) | extra


def shot(bg,cast,focus=.5,height=320,y=490,**extra):
    return dict(bg_scene=bg,set='courtyard',object='',prop='',cast=cast,
                cam=[focus,height],cam_y=y,ground=[.80,.94],full_plate=False,
                authored_plate=True) | extra


def beat(stage,shots=(),**extra):
    return dict(staging=stage,shots=list(shots),**extra)


def build():
    plates={}
    for name,floor in [('Pub',660),('Charity',650),('DLRPlatform',704),
                       ('DLRFront',748),('BrixtonMural',709)]:
        scene='ActivityLondon'+name
        plates[scene]=dict(city='london',texture=f'res://art/environments/scenes/{scene}-retro.png',
            source=[0,0,1672,941],pixel_art=True,floor=point(0,floor)[1],
            lettering=[],motion=[],animation_patches=[])
    plates['ActivityLondonPub']['lettering']=[
        sign((372,163,133,188),'AT THE BAR\n\nALE\nCIDER\nTEA','#20252a',size=13),
        sign((1567,222,72,121),'HOUSE\nALES','#20252a',size=10)]
    plates['ActivityLondonCharity']['lettering']=[
        sign((657,169,240,62),'CHARITY SHOP','#dec3a0','#1d352e',22),
        sign((314,120,145,59),'DONATIONS\nWELCOME','#dec3a0','#1d352e',12)]
    plates['ActivityLondonDLRPlatform']['lettering']=[
        sign((660,175,350,50),'CANARY WHARF','#183762',size=25)]
    plates['ActivityLondonDLRFront']['lettering']=[
        sign((653,64,369,33),'DOCKLANDS LIGHT RAILWAY','#183762',size=19),
        sign((1198,324,103,23),'CANARY WHARF','#2b5875',size=8)]
    plates['ActivityLondonDLRFront']['animation_patches']=[
        dict(kind='rail_view',rect=[*point(678,434),*point(279,82)])]
    plates['ActivityLondonBrixtonMural']['lettering']=[
        sign((19,127,406,64),'MORLEYS','#ddc39b','#20322c',30),
        sign((1217,354,73,109),'TUNSTALL\nROAD','#ddc39b','#263631',10)]
    plates['ActivityLondonBinLid']=dict(city='london',pixel_art=True,
        texture='res://art/environments/scenes/LondonTerrace-retro.png',
        source=[0,0,1672,941],floor=point(0,730)[1],
        animation_patches=[dict(kind='bin_lid',rect=[*point(601,622),*point(55,15)])])
    stage={}
    outside=shot('LondonSoho',[actor(713,769),actor(798,775,'drink'),actor(899,770)],.47,300,499)
    bar=shot('ActivityLondonPub',[actor(975,697,'take',world_height=150),actor(1080,536,'offer',clip_row=18,world_height=150)],.62,310,335,
             prop='glass',prop_holder=0)
    seated=shot('ActivityLondonPub',[actor(340,590,'sit',seated=True,world_height=138)],.29,290,316)
    group=shot('LondonSoho',[actor(704,770,'drink'),actor(808,768,'stand'),actor(900,775,'drink'),
                            actor(1007,777,'watch')],.51,330,495,prop='glass',prop_holder=0)
    stage['london:soho']={
        'pavement':beat(outside,[{},bar]),
        'waited':beat(seated), 'served':beat(outside),
        'round':beat(group),
        'took':beat(shot('LondonSoho',[actor(706,772,'carry'),actor(818,772,'take'),
            actor(917,772,'drink'),actor(1008,772,'watch')],.53,330,495,prop='glass',prop_holder=0))}
    bins=shot('LondonTerrace',[actor(545,803),actor(716,800,'point')],.4,310,506)
    stage['london:terrace']={
        'wheelie':beat(bins,[{'cast':[actor(544,802)]},{'cast':[actor(546,802),actor(719,802,'point')]}]),
        'counted':beat(shot('LondonTerrace',[actor(778,794,'point')],.49,350,499)),
        'leaflet':beat(shot('ActivityLondonBinLid',[actor(711,779,'read')],.40,218,479,
                          prop='card',prop_holder=0))}
    browse=shot('ActivityLondonCharity',[actor(730,671,'watch',world_height=144)],.47,320,373)
    purchase=shot('ActivityLondonCharity',[actor(1080,699,'take',world_height=144),actor(1370,540,'offer',clip_row=18,world_height=144)],.74,330,350,
                  prop='bag',prop_holder=0)
    stage['london:highstreet']={
        'window':beat(browse,[{},dict(cast=[actor(729,671,'reach',world_height=144)])]),
        'rail':beat(shot('ActivityLondonCharity',[actor(754,665,'reach',world_height=144)],.48,310,360)),
        'till':beat(purchase,[dict(cast=[actor(986,733,'watch',world_height=144),actor(1370,540,'take',clip_row=18,world_height=144),
                                actor(1196,699,'hand_over',world_height=144)],prop_holder=2)]),
        'bought':beat(purchase)}
    market=shot('LondonBrixton',[actor(480,803),actor(341,721,'offer',clip_row=14)],.26,320,503,
                prop='bag',prop_holder=0)
    stage['london:brixton']={
        'road':beat(market,[dict(cast=[actor(480,804,'walk')]),{}]),
        'walked':beat(shot('LondonBrixton',[actor(816,806,'walk')],.52,350,500)),
        'bought':beat(market),
        'mural':beat(shot('ActivityLondonBrixtonMural',[actor(480,805,'look_up')],.50,430,390))}
    child=actor(431,675,'sit',seated=True,world_height=144,appearance={'build':'child','cut':'bob','wear':'jumper'})
    seat=shot('ActivityLondonDLRFront',[actor(1194,675,'sit',seated=True,world_height=144),child],.5,410,354)
    platform=shot('ActivityLondonDLRPlatform',[actor(929,794,'queue')],.60,365,427)
    stage['london:docklands']={
        'platform':beat(platform,[{},seat]),
        'nobody':beat(shot('ActivityLondonDLRFront',[actor(962,839,'watch',world_height=144),
                          actor(701,829,'walk',world_height=144,appearance={'wear':'jacket','cut':'crop'})],.5,410,413)),
        'front':beat(seat,[{},{}])}
    # Give the choice/result states the same physical staging as their film;
    # story, language, currency and item rewards remain in StreetsideNorthWest.
    return plates,stage
