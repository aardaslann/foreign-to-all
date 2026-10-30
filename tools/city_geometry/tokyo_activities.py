"""Tokyo's five cultural encounters on nine measured, stationary pixel sets.

Only presentation is overridden. The original story, prices, learned words,
fortune draw, rewards and recovery choices remain in the Streetside tables.
"""
from .shapes import point
from .tokyo import sign
from .london_activities import actor, shot, beat


def person(x, y, act='watch', **extra):
    return actor(x, y, act, **(dict(world_height=128) | extra))


def build():
    plates = {}
    for name, floor in [('Menchi', 699), ('YanakaCemetery', 680),
                        ('Bookshop', 685), ('Kaminarimon', 722),
                        ('SensojiIncense', 767), ('Omikuji', 695),
                        ('Ameyoko', 710), ('ShinbashiSquare', 693),
                        ('Tachinomi', 704)]:
        key = 'ActivityTokyo' + name
        plates[key] = dict(city='tokyo', texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0, 0, 1672, 941], pixel_art=True, floor=point(0, floor)[1],
            lettering=[], motion=[], animation_patches=[])
    plates['ActivityTokyoMenchi']['lettering'] = [
        sign((689, 225, 665, 62), '谷中のお肉屋さん', '#eee1be', '#263b49', size=38),
        sign((1358, 406, 72, 142), 'メ\nン\nチ', '#213f68', size=25),
        sign((618, 419, 30, 75), '揚げたて', '#eee1be', '#263b49', size=11)]
    plates['ActivityTokyoMenchi']['motion'] = [
        dict(kind='steam', rect=[*point(1225, 479), *point(26, 55)])]
    plates['ActivityTokyoBookshop']['lettering'] = [
        sign((597, 43, 480, 57), '神保町 古書', '#eee1be', '#253b4a', size=38),
        sign((1344, 323, 44, 51), '古書', '#eee1be', '#253b4a', size=18)]
    # Transparent label preserves the lantern's curved, ribbed construction.
    plates['ActivityTokyoKaminarimon']['lettering'] = [
        sign((790, 341, 83, 136), '雷\n門', '#00000000', '#202d36', size=41)]
    plates['ActivityTokyoSensojiIncense']['motion'] = [
        dict(kind='incense', rect=[*point(1133, 496), *point(83, 88)])]
    plates['ActivityTokyoOmikuji']['lettering'] = [
        sign((301, 103, 549, 43), 'おみくじ', '#e8d8b5', '#293b46', size=34),
        sign((72, 489, 69, 145), '百円\nおみくじ', '#eee1be', '#263b49', size=17)]
    # These are real drawer numbers, rather than invented glyph textures.
    for row in range(5):
        for col in range(8):
            plates['ActivityTokyoOmikuji']['lettering'].append(
                sign((270+82*col, 231+48*row, 26, 14), str(row*8+col+1),
                     '#eadbbc', '#3c3a32', size=9))
    plates['ActivityTokyoAmeyoko']['lettering'] = [
        sign((680, 224, 670, 61), 'アメ横 菓子問屋', '#eedeb9', '#254339', size=37),
        sign((1520, 269, 43, 127), '特\n売', '#ae483b', size=27),
        sign((879, 548, 34, 17), '500円', '#eedeb9', '#263b49', size=9)]
    plates['ActivityTokyoAmeyoko']['motion_layers'] = [dict(
        rect=[*point(499, 44), *point(1173, 88)],
        sample=[*point(846, 44), *point(351, 88)],
        occluders=[[*point(x, 44), *point(w, 88)]
                   for x, w in [(565, 62), (814, 20), (1204, 23), (1410, 67)]])]
    plates['ActivityTokyoShinbashiSquare']['lettering'] = [
        sign((319, 613, 58, 16), 'C11 292', '#58616a', size=8),
        sign((977, 432, 185, 38), '立呑み', '#25456d', size=26),
        sign((1368, 430, 180, 25), '小料理', '#253f62', size=22),
        sign((913, 571, 25, 43), '営業中', '#e7d8b7', '#263b49', size=10)]
    plates['ActivityTokyoShinbashiSquare']['motion_layers'] = [dict(
        rect=[*point(969, 131), *point(703, 93)],
        sample=[*point(974, 131), *point(433, 93)],
        occluders=[[*point(x, 131), *point(w, 93)]
                   for x, w in [(1164, 7), (1410, 37), (1635, 27)]])]
    plates['ActivityTokyoTachinomi']['lettering'] = [
        sign((263, 350, 122, 55), '立呑み', '#25456d', size=24),
        sign((511, 353, 44, 97), '本日の\nおすすめ', '#ecd9b5', '#28343a', size=11)]
    for x, text in [(862, '生ビール'), (900, 'お酒'), (938, '冷奴'),
                    (976, '煮込み'), (1175, '焼き鳥'), (1212, '漬物'), (1250, '枝豆')]:
        plates['ActivityTokyoTachinomi']['lettering'].append(
            sign((x, 326, 18, 45), '\n'.join(text), '#e5cda7', '#2e3435', size=8))

    stage = {}
    cook_look = {'build': 'adult', 'cut': 'bob', 'wear': 'apron'}
    cook = person(1203, 599, 'cut', clip_row=20, appearance=cook_look)
    steps = shot('TokyoYanaka', [actor(1055, 810, 'watch')], .5, 648, 324, full_plate=True)
    queue = shot('ActivityTokyoMenchi', [person(1020, 801, 'queue'), cook,
        person(823, 808, 'queue'), person(639, 809, 'queue'), person(454, 814, 'queue')],
        .58, 540, 381)
    hot = shot('ActivityTokyoMenchi', [person(1020, 801, 'recoil'), cook,
        person(809, 810), person(649, 810)], .60, 450, 396,
        prop='menchi', prop_holder=0)
    standing = shot('ActivityTokyoMenchi', [person(950, 813, 'eat'), cook,
        person(733, 812, 'eat'), person(536, 815, 'watch')], .54, 490, 401,
        prop='menchi', prop_holder=0)
    cats = shot('ActivityTokyoYanakaCemetery', [person(820, 845)],
        .55, 480, 407, object='cats', object_at=[.74, .78], object_unit=2.0)
    stage['tokyo:yanaka'] = {'steps': beat(steps, [{}, queue]),
        'hot': beat(hot, [{}]), 'standing': beat(standing, [{}]), 'cats': beat(cats)}

    clerk_look = {'build': 'elder', 'cut': 'crop', 'wear': 'shopcoat'}
    clerk = person(1210, 572, 'watch', clip_row=20, appearance=clerk_look)
    browse = shot('ActivityTokyoBookshop', [person(785, 717, 'read'), clerk],
        .55, 472, 361, prop='book', prop_holder=0)
    row = shot('TokyoJinbocho', [actor(877, 812)], .5, 648, 324, full_plate=True)
    north = shot('TokyoJinbocho', [actor(888, 812, 'look_up'), actor(1078, 818)],
        .56, 498, 388)
    cart = shot('ActivityTokyoBookshop', [person(785, 717, 'reach'), clerk],
        .53, 407, 353, prop='book', prop_holder=0)
    bought = shot('ActivityTokyoBookshop', [person(1053, 757, 'take'),
        person(1210, 572, 'offer', clip_row=20, appearance=clerk_look)],
        .65, 396, 362, prop='book', prop_holder=0)
    stage['tokyo:jinbocho'] = {'row': beat(browse, [{}, row]),
        'north': beat(north, [{}]), 'cart': beat(cart, [{}]), 'bought': beat(bought)}

    gate = shot('ActivityTokyoKaminarimon', [person(682, 813)],
        .5, 648, 324, full_plate=True)
    watched = shot('ActivityTokyoKaminarimon', [person(644, 815), person(975, 807, 'bow')],
        .5, 480, 374)
    bowed = shot('ActivityTokyoKaminarimon', [person(744, 814, 'bow'), person(1008, 824, 'bow')],
        .5, 480, 374)
    incense = shot('ActivityTokyoSensojiIncense', [person(936, 774),
        person(1440, 789, 'reach', appearance={'build': 'elder', 'cut': 'crop'})],
        .67, 466, 390)
    smoke = shot('ActivityTokyoSensojiIncense', [person(936, 774, 'reach'),
        person(1440, 789, 'reach', appearance={'build': 'elder', 'cut': 'crop'})],
        .67, 426, 403)
    fortune = shot('ActivityTokyoOmikuji', [person(657, 748, 'read'),
        person(868, 760, 'watch', appearance={'build': 'adult', 'cut': 'bob'})],
        .48, 460, 376, prop='fortune_good', prop_holder=0)
    bad = shot('ActivityTokyoOmikuji', [person(657, 748, 'read'),
        person(868, 760, 'point', appearance={'build': 'adult', 'cut': 'crop'})],
        .53, 460, 376, prop='fortune_bad', prop_holder=0)
    tied = shot('ActivityTokyoOmikuji', [person(1255, 726, 'hand_over')],
        .74, 359, 356, prop='fortune_bad', prop_holder=0,
        prop_world_to=point(1285, 530), prop_end_unit=1.6)
    pocket = shot('ActivityTokyoOmikuji', [person(812, 797, 'carry'),
        person(1039, 778, 'watch', appearance={'build': 'adult', 'cut': 'crop'})],
        .57, 446, 388, prop='fortune_bad', prop_holder=0)
    stage['tokyo:asakusa'] = {'gate': beat(gate, [{}, watched, incense]),
        'watched': beat(watched), 'bowed': beat(bowed), 'inner': beat(incense),
        'smoke': beat(smoke), 'good': beat(fortune), 'bad': beat(bad),
        'tied': beat(tied), 'pocket': beat(pocket)}

    vendor_look = {'build': 'adult', 'cut': 'crop', 'wear': 'marketapron'}
    vendor = person(1067, 615, 'point', clip_row=20, appearance=vendor_look)
    lane = shot('ActivityTokyoAmeyoko', [person(675, 823, 'walk'), vendor],
        .5, 648, 324, full_plate=True)
    shouting = shot('ActivityTokyoAmeyoko', [person(847, 810, 'recoil'), vendor],
        .57, 480, 400)
    listened = shot('ActivityTokyoAmeyoko', [person(847, 810), vendor,
        person(639, 820), person(1259, 821), person(1480, 829)], .62, 519, 392)
    bargain = shot('ActivityTokyoAmeyoko', [person(847, 810, 'take'),
        person(1067, 615, 'offer', clip_row=20, appearance=vendor_look),
        person(639, 820, 'queue'), person(1259, 821, 'queue'), person(1480, 829)],
        .62, 519, 392, prop='parcel', prop_holder=0)
    full = shot('ActivityTokyoAmeyoko', [person(847, 810, 'take'), vendor,
        person(1259, 821)], .61, 468, 404, prop='parcel', prop_holder=0)
    stage['tokyo:ueno'] = {'lane': beat(lane, [{}, shouting]),
        'listened': beat(listened), 'waited': beat(bargain), 'full': beat(full)}

    square = shot('ActivityTokyoShinbashiSquare', [person(679, 824)],
        .5, 648, 324, full_plate=True)
    doors = shot('ActivityTokyoShinbashiSquare', [person(875, 819), person(1060, 729, 'walk')],
        .70, 450, 391)
    shut = shot('ActivityTokyoShinbashiSquare', [person(1434, 744, 'recoil')],
        .80, 404, 375)
    barman_look = {'build': 'adult', 'cut': 'crop', 'wear': 'apron'}
    barman = person(1315, 574, 'offer', clip_row=20, appearance=barman_look)
    neighbor = person(998, 757, 'drink', appearance={'build': 'adult', 'cut': 'crop', 'wear': 'suit'})
    bar = shot('ActivityTokyoTachinomi', [person(791, 756), barman, neighbor],
        .62, 441, 370, prop='glass', prop_holder=2)
    same = shot('ActivityTokyoTachinomi', [person(791, 756, 'drink'), barman, neighbor],
        .62, 420, 371, prop='glass', prop_holder=0)
    stuck = shot('ActivityTokyoTachinomi', [person(791, 756, 'look_up'), barman, neighbor],
        .62, 459, 364, prop='glass', prop_holder=0)
    tv = shot('ActivityTokyoShinbashiSquare', [person(804, 841),
        person(1068, 821, 'point', kit='microphone', appearance={'build': 'adult', 'cut': 'bob', 'wear': 'blazer'}),
        person(1475, 821, 'watch', kit='camera', appearance={'build': 'adult', 'cut': 'crop', 'wear': 'blazer'}),
        person(1255, 874, 'watch', appearance={'build': 'adult', 'cut': 'crop', 'wear': 'suit'})],
        .67, 480, 409)
    stage['tokyo:shinbashi'] = {'square': beat(square, [{}, doors]),
        'watched': beat(doors), 'shut': beat(shut), 'inside': beat(bar),
        'same': beat(same), 'stuck': beat(stuck), 'tv': beat(tv)}
    return plates, stage
