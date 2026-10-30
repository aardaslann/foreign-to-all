"""Hanoi's original five branching encounters on eight measured pixel sets.

Presentation only: dialogue, decisions, prices, vocabulary, reputation and
inventory changes remain in StreetsideEast and StreetsideEastTwo.
"""
from .shapes import point, sign
from .london_activities import actor, shot, beat


def person(x, y, act='watch', **extra):
    # Explicit empty appearance prevents an old reel's guard override from
    # leaking into new crowd members at that same cast index.
    return actor(x, y, act, **(dict(world_height=128, appearance={}) | extra))


def build():
    plates = {}
    for name, floor in [('BiaHoi', 620), ('LongBienNight', 688), ('BaDinhQueue', 680),
                        ('OnePillar', 705), ('TayHoFood', 794),
                        ('TranQuocCourtyard', 757), ('TempleSteles', 696), ('Graduates', 677)]:
        key = 'ActivityHanoi' + name
        plates[key] = dict(city='hanoi', texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0, 0, 1672, 941], pixel_art=True, floor=point(0, floor)[1],
            lettering=[], motion=[], animation_patches=[])
    plates['ActivityHanoiBiaHoi']['lettering'] = [
        sign((740, 130, 264, 43), 'BIA HƠI', '#00000000', '#304f40', size=32)]
    plates['ActivityHanoiBaDinhQueue']['lettering'] = [
        sign((675, 156, 322, 29), 'HỒ CHÍ MINH', '#00000000', '#34434b', size=22)]
    plates['ActivityHanoiTayHoFood']['lettering'] = [
        sign((1250, 217, 323, 43), 'BÁNH TÔM', '#00000000', '#304b42', size=33)]
    plates['ActivityHanoiTayHoFood']['motion'] = [
        dict(kind='steam', rect=[*point(1297, 394), *point(95, 53)])]
    plates['ActivityHanoiTayHoFood']['animation_patches'] = [
        dict(kind='water', rect=[*point(216, 346), *point(259, 72)])]
    plates['ActivityHanoiLongBienNight']['animation_patches'] = [
        dict(kind='water', rect=[*point(743, 451), *point(182, 26)])]
    plates['ActivityHanoiOnePillar']['animation_patches'] = [
        dict(kind='water', rect=[*point(887, 582), *point(164, 42)])]
    plates['ActivityHanoiTranQuocCourtyard']['motion'] = [
        dict(kind='incense', rect=[*point(704, 526), *point(39, 60)])]
    # Explicit classical-character headings, not generated imitation writing.
    # These are titles, not fabricated transcriptions of individual names.
    for x in [838, 1254]:
        plates['ActivityHanoiTempleSteles']['lettering'].append(
            sign((x-17, 401, 34, 112), '進\n士\n題\n名', '#00000000', '#454844', size=18,
                 font='res://art/fonts/NotoSansJP.ttf'))

    stage = {}
    # Seats are placed against their actual top surfaces. The game renders
    # the seated coat at this contact; the painted stool supplies the legs.
    server_look = {'build': 'adult', 'wear': 'marketapron', 'cut': 'tied', 'face': ''}
    server = person(1143, 632, 'offer', world_height=101, appearance=server_look)
    neighbor = person(846, 564, 'sit', seated=True, world_height=96)
    corner = shot('ActivityHanoiBiaHoi', [person(553, 667, world_height=101), server, neighbor],
                  .53, 480, 294)
    offered = shot('ActivityHanoiBiaHoi', [person(631, 564, 'sit', seated=True, world_height=101),
        server, neighbor], .54, 398, 300, prop='glass', prop_holder=0)
    seated = shot('ActivityHanoiBiaHoi', [person(631, 564, 'drink', seated=True, world_height=101),
        server | {'act': 'stand'}, neighbor], .51, 398, 302, prop='glass', prop_holder=0)
    tally = shot('ActivityHanoiBiaHoi', [person(631, 564, 'watch', seated=True, world_height=101),
        server | {'act': 'count'}, neighbor], .61, 430, 294)
    stage['hanoi:phoco'] = {'corner': beat(corner, [corner, offered]),
                          'sat': beat(seated, [seated]), 'tally': beat(tally, [tally])}

    # The carrying lane is genuinely empty. The pole and baskets follow the
    # carrier and settle after arrival; nothing shakes the market backdrop.
    carrier = person(1080, 823, 'haul', kit='shoulder_pole', appearance=server_look)
    porter = person(437, 727, 'carry', world_height=92, z=.35,
                    appearance={'build': 'adult', 'wear': 'openshirt', 'cut': 'crop'})
    market_vendor = person(1231, 703, 'watch', world_height=100, z=.4,
                            appearance={'build': 'adult', 'wear': 'marketapron', 'cut': 'bob'})
    market = shot('ActivityHanoiLongBienNight', [person(704, 837), carrier, porter, market_vendor],
                  .5, 648, 324, full_plate=True)
    pole = shot('ActivityHanoiLongBienNight', [person(658, 849), carrier, porter], .54, 488, 417)
    wholesale = shot('ActivityHanoiLongBienNight', [person(1001, 829, 'point'),
        person(1258, 821, 'offer', appearance=server_look)], .67, 467, 410)
    crate = shot('ActivityHanoiLongBienNight', [person(997, 837, 'carry'),
        person(1237, 823, 'watch', appearance=server_look), person(1458, 827, 'watch')],
        .71, 475, 411, prop='fruit_crate', prop_holder=0)
    stage['hanoi:longbien'] = {'arrive': beat(market, [market, pole]),
        'pole': beat(pole), 'wholesale': beat(wholesale, [wholesale]), 'crate': beat(crate)}

    guard_look = {'build': 'adult', 'wear': 'suit', 'cut': 'cap', 'face': '',
        'pal': {'C': 'eeeade', 'D': 'c6c9c1', 'B': 'deded3', 'P': 'ece8d9',
                'p': 'aa974f', 'g': 'bf4334', 'a': 'e5e2d6'}}
    guard = person(1442, 813, 'stand', appearance=guard_look)
    queue_front = [person(x, 822, 'queue', world_height=108, z=.65)
                   for x in [625, 816, 1007, 1198]]
    queue_back = [person(x, 716, 'wait', world_height=93, z=.35)
                  for x in [619, 808, 997, 1186]]
    square = shot('ActivityHanoiBaDinhQueue', [person(412, 842)], .5, 648, 324, full_plate=True)
    queue = shot('ActivityHanoiBaDinhQueue', [person(403, 847), *queue_back, *queue_front, guard],
                 .5, 648, 324, full_plate=True)
    joined = shot('ActivityHanoiBaDinhQueue', [person(622, 822, 'queue', world_height=108),
        *queue_back, *queue_front[1:], guard], .54, 591, 352)
    corrected = shot('ActivityHanoiBaDinhQueue', [person(622, 833, 'recoil', world_height=108),
        person(823, 830, 'point', world_height=111, appearance=guard_look),
        person(1092, 829, 'wait', world_height=108)], .48, 442, 414)
    copied = shot('ActivityHanoiBaDinhQueue', [person(622, 822, 'stand', world_height=108),
        *queue_back, *[who | {'act': 'stand'} for who in queue_front[1:]], guard], .53, 568, 361)
    left = shot('ActivityHanoiBaDinhQueue', [person(359, 804), *queue_back,
        *[who | {'act': 'wait'} for who in queue_front], guard], .48, 622, 337)
    one_pillar = shot('ActivityHanoiOnePillar', [person(448, 823), person(1208, 809, 'watch', z=.5)],
                      .5, 648, 324, full_plate=True)
    stage['hanoi:badinh'] = {'square': beat(square, [square, queue]),
        'watched': beat(queue), 'clean': beat(joined), 'raw': beat(corrected),
        'copied': beat(copied), 'left': beat(left), 'pagoda': beat(one_pillar)}

    cook = person(1165, 547, 'cut', clip_row=20, appearance=server_look)
    diner = person(844, 685, 'eat', seated=True)
    guest = person(1291, 685, 'watch', seated=True,
                   appearance={'build': 'adult', 'wear': 'openshirt', 'cut': 'crop'})
    lake = shot('HanoiTayHo', [actor(799, 812)], .5, 648, 324, full_plate=True)
    food = shot('ActivityHanoiTayHoFood', [person(397, 685, 'sit', seated=True), cook, diner, guest],
                .56, 648, 324, full_plate=True)
    served = shot('ActivityHanoiTayHoFood', [person(397, 685, 'watch', seated=True), cook, diner],
                  .41, 409, 374, prop='shrimp_fritter', prop_holder=0)
    learned = shot('ActivityHanoiTayHoFood', [person(397, 685, 'watch', seated=True), cook,
        diner | {'act': 'interact'}], .43, 432, 360, prop='shrimp_wrap', prop_holder=2)
    right = shot('ActivityHanoiTayHoFood', [person(397, 685, 'eat', seated=True), cook,
        diner | {'act': 'watch'}], .43, 432, 360, prop='shrimp_wrap', prop_holder=0)
    wrong = shot('ActivityHanoiTayHoFood', [person(397, 685, 'watch', seated=True),
        person(563, 802, 'offer', appearance=server_look), diner | {'act': 'watch'}],
        .43, 487, 386, prop='shrimp_wrap', prop_holder=1)
    bodhi = shot('ActivityHanoiTranQuocCourtyard', [person(682, 840), person(1049, 816, 'watch')],
                 .5, 648, 324, full_plate=True)
    stage['hanoi:tayho'] = {'shore': beat(lake, [lake, food]), 'served': beat(served),
        'learned': beat(learned), 'right': beat(right), 'wrong': beat(wrong), 'pagoda': beat(bodhi)}

    entrance = shot('ActivityHanoiGraduates', [person(773, 812, 'walk')], .5, 648, 324, full_plate=True)
    turtles = shot('ActivityHanoiTempleSteles', [person(858, 818), person(1059, 806, 'point')],
                   .62, 510, 384)
    grandmother = person(1133, 811, 'point', appearance={'build': 'elder', 'wear': 'housecoat', 'cut': 'tied'})
    child = person(1320, 814, 'watch', appearance={'build': 'child', 'wear': 'tee', 'cut': 'crop'})
    reading = shot('ActivityHanoiTempleSteles', [person(887, 824), grandmother, child],
                   .66, 499, 389, prop='card', prop_holder=1)
    fence = shot('ActivityHanoiTempleSteles', [person(1030, 808, 'watch')], .67, 432, 376)
    graduate_look = {'build': 'adult', 'wear': 'coat', 'cut': 'tied', 'face': '',
        'pal': {'C': '30343e', 'D': '252934', 'P': '242833', 'p': '171f2a'}}
    # Gowns and mortarboards use game-drawn character parts. The father and
    # photographer remain on the pavement, clear of the stone stair treads.
    grads = shot('ActivityHanoiGraduates', [person(379, 828),
        person(806, 790, 'stand', kit='graduation', appearance=graduate_look),
        person(1047, 805, 'point', appearance={'build': 'adult', 'wear': 'openshirt', 'cut': 'crop'}),
        person(1253, 816, 'watch', kit='camera', appearance={'build': 'adult', 'wear': 'blazer', 'cut': 'bob'}),
        person(1430, 816, 'stand', kit='graduation', appearance=graduate_look)],
        .5, 648, 324, full_plate=True)
    stage['hanoi:dongda'] = {'gate': beat(entrance, [entrance, turtles]),
        'court': beat(turtles), 'read': beat(reading), 'fence': beat(fence), 'grads': beat(grads)}
    return plates, stage
