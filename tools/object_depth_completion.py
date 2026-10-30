"""Complete whole-object silhouettes after comparing the source and depth layers.

Coordinates use source pixels unless explicitly marked as world coordinates.
The original illustrations remain unchanged.
"""


def complete_depth(data, object_, rect, tube, wheel):
    sx, sy = 1152 / 1672, 648 / 941

    def obj(scene, name):
        return next(o for o in data[scene]['objects'] if o['id'] == name)

    def points(poly):
        return [[round(x*sx, 2), round(y*sy, 2)] for x, y in poly]

    def shapes(scene, name, polygons, replace=False):
        item = obj(scene, name)
        if replace:
            item['polygons'] = []
        item['polygons'] += [points(p) for p in polygons]

    def feet(scene, name, boxes):
        obj(scene, name)['footprints'] = [
            [round(x*sx, 2), round(y*sy, 2), round(w*sx, 2), round(h*sy, 2)]
            for x, y, w, h in boxes]

    # The notice shelter has an opaque back panel, not three floating posters.
    # Stop feet at its ground plane across the panel's width, including the
    # spaces between the supporting legs. Both pavement approaches stay open.
    shapes('MitteOst', 'shelter', [rect(8, 512, 307, 134)])
    obj('MitteOst', 'shelter').pop('glass', None)
    feet('MitteOst', 'shelter', [(0, 681, 335, 14)])

    # A glass shelter also has a continuous rear plane. Its bench is forward
    # of this plane; the pavement behind it is a separate, accessible route.
    feet('Mitte', 'shelter', [(998, 660, 293, 6), (998, 666, 19, 29),
                            (1271, 666, 20, 29), (1030, 673, 219, 23)])

    # Every bar and both opaque stair-side panels belong to the railing.
    # Formerly only four bars were present, with the character covering the
    # others and the stairs showing through the character's lower body.
    rail = [rect(830, 307, 84, 82), rect(867, 386, 15, 313),
            rect(779, 601, 165, 9), rect(783, 616, 158, 5),
            rect(785, 650, 154, 6),
            [[762, 592], [775, 592], [785, 609], [781, 696],
             [783, 700], [779, 705], [757, 705], [757, 696]],
            [[939, 592], [950, 592], [955, 600], [954, 646],
             [969, 691], [977, 696], [977, 706], [951, 706], [943, 646]],
            [[788, 656], [865, 656], [865, 696], [787, 696]],
            [[887, 656], [943, 656], [943, 696], [887, 696]],
            tube((778, 611), (807, 654), 5),
            tube((779, 629), (803, 663), 4),
            tube((949, 612), (935, 655), 5)]
    for x in [789, 800, 811, 823, 835, 847, 858, 883, 895, 907, 919, 931]:
        rail.append(rect(x, 608, 5, 48))
    for x, y in [(783, 635), (790, 645), (798, 656), (938, 651), (945, 636)]:
        rail.append(rect(x, y, 4, 695-y))
    shapes('Mitte', 'stairs', rail, True)

    # The Han display is one assembled fixture. Its plant, pot, carpet and
    # boxes share its depth; open air under the front bench stays transparent.
    shapes('IstanbulHan', 'rugs', [
        [[1456, 730], [1483, 730], [1483, 708], [1527, 708], [1527, 736],
         [1546, 736], [1546, 558], [1598, 554], [1598, 741], [1607, 695],
         [1640, 691], [1650, 750], [1668, 748], [1668, 835], [1615, 835],
         [1615, 800], [1551, 800], [1551, 837], [1527, 837], [1527, 820],
         [1499, 820], [1499, 811], [1475, 811], [1475, 797], [1456, 794]]], True)
    obj('IstanbulHan', 'rugs')['foliage'] = [points(rect(1466, 632, 80, 80))]
    shapes('IstanbulHan', 'rugs', [tube((1505, 686), (1507, 712), 6)])
    feet('IstanbulHan', 'rugs', [(1457, 759, 70, 39), (1484, 797, 43, 23),
                              (1527, 774, 141, 63)])

    # Green-keyed leaf clusters cannot include brown branches. Explicit wood
    # joins the trunk to the crown so a head never punches through that join.
    branches = [
        ('Mitte', 'tree_west', [((36, 518), (36, 373), 6),
                               ((36, 525), (8, 490), 5), ((36, 518), (72, 473), 5)]),
        ('MitteOst', 'tree_east', [((1650, 545), (1650, 282), 12),
                                  ((1650, 500), (1604, 465), 7),
                                  ((1650, 481), (1672, 451), 7)]),
        ('BerlinPrenzlberg', 'tree_west', [((58, 521), (58, 348), 7),
                                          ((58, 495), (27, 463), 5), ((58, 486), (90, 452), 5)]),
        ('BerlinPrenzlberg', 'tree_mid', [((336, 525), (336, 359), 7),
                                         ((336, 501), (302, 466), 5), ((336, 493), (371, 449), 5)]),
        ('BerlinPrenzlberg', 'tree_market', [((967, 526), (967, 356), 7),
                                            ((967, 499), (930, 455), 5), ((967, 491), (998, 458), 5)]),
    ]
    for scene, name, strokes in branches:
        shapes(scene, name, [tube(a, b, w) for a, b, w in strokes])

    # The crown narrows above the Spati window. Do not key the green bottles
    # beside it into the tree's foreground layer.
    obj('Mitte', 'tree_west')['foliage'] = [
        points(rect(0, 300, 114, 200)), points(rect(0, 500, 87, 29))]

    # Two entire trees in Mitte had never been registered. The one behind
    # the glass sits behind the shelter's plane and retains that depth.
    for name, base, crown, trunk in [
        ('tree_shelter', (1081, 643, 39, 18), (1004, 283, 183, 247),
         [((1096, 653), (1096, 354), 8), ((1096, 531), (1067, 500), 7),
          ((1096, 525), (1131, 496), 7)]),
        ('tree_east', (1620, 638, 52, 19), (1554, 235, 118, 276),
         [((1646, 645), (1646, 338), 12), ((1646, 508), (1616, 473), 7),
          ((1646, 494), (1672, 457), 7)])]:
        object_('Mitte', name, base[1]+base[3], [base],
                [rect(*base)] + [tube(a, b, w) for a, b, w in trunk])
        obj('Mitte', name)['foliage'] = [points(rect(*crown))]

    # Produce, baskets and hanging bags form the upper part of market stalls.
    # The old mask retained the awning and crates but omitted the countertop.
    for name, x, right in [('market_0', 434, 674), ('market_1', 701, 907)]:
        shapes('BerlinPrenzlberg', name, [
            [[x, 585], [x+5, 564], [x+22, 557], [x+35, 567],
             [x+49, 553], [x+77, 559], [x+81, 540], [x+103, 540],
             [x+117, 554], [x+135, 546], [x+157, 558], [right-25, 558],
             [right, 578], [right, 630], [x, 630]]])

    # The remaining inventory was reviewed at the game's 1152x648 viewport.
    # Keep these measured coordinates in that space to avoid rounding them
    # through source pixels twice.
    def world(scene, name, polygons, replace=False):
        item = obj(scene, name)
        if replace:
            item['polygons'] = []
        item['polygons'] += [[[round(x, 2), round(y, 2)] for x, y in p] for p in polygons]

    def world_leaves(scene, name, bounds):
        obj(scene, name).setdefault('foliage', []).append(rect(*bounds))

    def world_object(scene, name, depth, base, polygons):
        data[scene]['objects'].append(dict(id=name, sort_y=depth,
                                         footprints=[list(base)], polygons=polygons))

    # Items resting on a counter must not be behind someone behind that
    # counter. Include monitors, papers, bottles and displays in its layer.
    tops = [
        ('Airport', 'checkin', [(570, 322, 32, 22), (608, 289, 39, 57), (758, 290, 37, 55), (802, 322, 28, 22)]),
        ('Hospital', 'reception', [(623, 286, 71, 41), (645, 327, 27, 12), (852, 260, 79, 80), (946, 299, 23, 41), (944, 293, 27, 7)]),
        ('Police', 'desk', [(333, 272, 39, 59), (377, 300, 36, 31), (615, 265, 71, 53), (634, 317, 41, 15), (702, 299, 38, 33), (742, 285, 45, 46)]),
        ('Exchange', 'counter', [(452, 323, 51, 37), (863, 320, 53, 40), (925, 340, 23, 20), (812, 337, 33, 24)]),
        ('HotelLobby', 'counter', [(803, 297, 14, 26), (806, 288, 6, 11), (650, 300, 12, 22), (612, 304, 15, 17)]),
        ('HotelLobby', 'luggage', [(959, 338, 30, 10), (962, 348, 5, 13), (984, 348, 5, 13)]),
        ('HotelFloor', 'linen_trolley', [(957, 236, 22, 29), (964, 221, 10, 15), (983, 238, 25, 27), (990, 226, 13, 12)]),
        ('Room01', 'meeting_table', [(464, 229, 46, 45), (622, 229, 46, 45), (549, 339, 28, 70)]),
        ('IstanbulOtel', 'reception', [(353, 288, 28, 12), (413, 257, 31, 44), (649, 290, 30, 12), (658, 281, 10, 9), (727, 269, 32, 34), (759, 275, 55, 27)]),
        ('IstanbulDoviz', 'counter', [(529, 264, 37, 25), (533, 223, 30, 42), (797, 251, 53, 38), (732, 267, 59, 22)]),
        ('IstanbulKarakol', 'desk', [(279, 276, 54, 47), (275, 322, 65, 8), (580, 268, 51, 48), (585, 315, 47, 15), (362, 311, 34, 19), (178, 307, 26, 22), (670, 308, 32, 21)]),
        ('IstanbulHastane', 'reception', [(163, 275, 58, 30), (257, 258, 51, 44), (362, 269, 48, 36), (485, 287, 64, 17), (505, 254, 27, 35), (434, 258, 33, 24)]),
        ('IstanbulHavalimani', 'information_desk', [(137, 336, 50, 65), (211, 358, 119, 43), (343, 336, 60, 65)]),
        ('IstanbulLokanta', 'counter', [(330, 238, 58, 41), (405, 211, 51, 68), (624, 172, 43, 106), (465, 245, 70, 34), (858, 264, 79, 36)]),
        ('Restaurant', 'bar', [(685, 234, 280, 69), (633, 233, 44, 68), (969, 222, 70, 81), (809, 211, 49, 24)]),
        ('IstanbulYusuf', 'work_cabinet', [(526, 213, 58, 92), (613, 284, 39, 23), (526, 239, 59, 8), (521, 304, 68, 5)]),
        ('IstanbulYusuf', 'workbench', [(817, 202, 58, 105), (684, 291, 28, 15), (779, 278, 22, 29)]),
        ('IstanbulCarsi', 'bakery_counter', [(456, 323, 102, 95)]),
        ('IstanbulBeyoglu', 'lamp_east', [(847, 195, 27, 14)]),
    ]
    for scene, name, boxes in tops:
        world(scene, name, [rect(*r) for r in boxes])
    world_leaves('IstanbulOtel', 'reception', (351, 234, 36, 57))
    world_leaves('IstanbulHastane', 'reception', (411, 181, 81, 80))
    world('IstanbulYusuf', 'work_cabinet', [tube((600, 302), (595, 254), 6),
        tube((595, 254), (620, 229), 6), [[619, 218], [625, 220], [644, 241], [615, 251], [613, 239]]])

    # Wooden branches are not green. They need explicit coverage inside the
    # foliage layer, including the crowns where a tall character can overlap.
    for scene, name, strokes in [
        ('BerlinKreuzberg', 'tree_west', [((36, 375), (36, 147), 7), ((36, 363), (11, 324), 5), ((36, 335), (66, 282), 5)]),
        ('BerlinKreuzberg', 'tree_east', [((1133, 380), (1133, 154), 7), ((1133, 334), (1104, 296), 5)]),
        ('Police', 'plant_342', [((260, 348), (260, 265), 5), ((260, 314), (246, 290), 4)]),
        ('Police', 'plant_1353', [((949, 381), (949, 345), 4)]),
        ('Exchange', 'planter', [((1066, 388), (1066, 331), 4)]),
        ('Room01', 'plant', [((149, 326), (149, 261), 4)]),
        ('Room01', 'cabinet_side', [((1092, 316), (1092, 299), 4)]),
        ('IstanbulDoviz', 'planter', [((275, 332), (275, 260), 4)]),
        ('IstanbulOtel', 'planter', [((864, 312), (864, 262), 4)]),
        ('IstanbulKarakol', 'plant_back', [((1060, 385), (1060, 337), 5)]),
        ('IstanbulKarakol', 'plant_front', [((980, 550), (980, 497), 5)]),
        ('IstanbulHastane', 'plant', [((565, 545), (565, 503), 4)]),
        ('IstanbulHavalimani', 'plant_41', [((51, 373), (51, 293), 6)]),
        ('IstanbulHavalimani', 'plant_620', [((444, 414), (444, 366), 5)]),
        ('IstanbulBeyoglu', 'plant_east', [((749, 419), (749, 381), 4)]),
        ('IstanbulKadikoy', 'plant', [((676, 383), (676, 330), 4)]),
        ('HotelLobby', 'planter_left', [((294, 338), (294, 303), 4)]),
        ('HotelLobby', 'planter_right', [((906, 371), (906, 253), 5)]),
        ('HotelFloor', 'plant', [((1127, 314), (1127, 254), 5)]),
    ]:
        world(scene, name, [tube(a, b, w) for a, b, w in strokes])

    # Kadikoy's tree grows from the counter's central wooden planter. Its
    # canopy, trunk, fish display and fruit all share that fixture's depth.
    world_leaves('IstanbulKadikoy', 'fish_counter', (14, 70, 221, 244))
    world('IstanbulKadikoy', 'fish_counter', [
        [[103, 383], [103, 310], [96, 286], [83, 268], [88, 264],
         [110, 291], [115, 266], [115, 204], [121, 205], [122, 286],
         [145, 263], [151, 265], [127, 307], [127, 383]],
        [[231, 330], [344, 326], [373, 376], [373, 387], [242, 387]],
        rect(156, 350, 36, 38), rect(209, 377, 38, 18), rect(60, 376, 38, 18)])
    world_leaves('IstanbulKadikoy', 'fish_counter', (192, 349, 56, 38))
    world('IstanbulKadikoy', 'fruit_crate', [
        [[407, 369], [418, 365], [418, 352], [433, 349], [442, 354],
         [455, 352], [463, 361], [469, 359], [469, 383], [407, 383]]])
    world_object('IstanbulKadikoy', 'plant_east', 410, (1101, 395, 37, 15), [rect(1099, 365, 40, 45)])
    world_leaves('IstanbulKadikoy', 'plant_east', (1094, 308, 51, 59))

    # Cafe sets include four chair backs and legs, not only a tabletop crop.
    for name, center, left, right in [('cafe_0', 754, 722, 765), ('cafe_1', 834, 811, 845), ('cafe_2', 933, 901, 949)]:
        world('IstanbulKadikoy', name, [rect(center-19, 353, 38, 22),
            rect(left, 365, 8, 66), rect(left+8, 393, 22, 8), rect(left+24, 399, 5, 32),
            rect(right, 366, 8, 65), rect(right-19, 392, 20, 8), rect(right-19, 398, 5, 31)])

    world('BerlinKreuzberg', 'produce_stall', [
        [[122, 459], [122, 436], [135, 425], [151, 430], [158, 418],
         [170, 422], [181, 413], [198, 422], [213, 417], [229, 424],
         [244, 414], [260, 422], [277, 417], [296, 426], [311, 418],
         [330, 424], [348, 419], [365, 426], [371, 459]],
        rect(519, 447, 21, 15)])
    world('BerlinKreuzberg', 'shop_crates', [rect(513, 446, 40, 16), rect(563, 445, 29, 23)])

    # Room 304's suitcase handle and coat racks have open gaps, not slabs
    # of the wallpaper around their narrow stems.
    world('HotelRoom', 'suitcase', [
        [[176, 262], [200, 262], [204, 266], [204, 278], [214, 282],
         [219, 288], [219, 371], [213, 377], [204, 377], [204, 372],
         [176, 372], [176, 377], [163, 377], [163, 287], [169, 280], [176, 278]],
        rect(179, 267, 20, 4)], True)
    world('Exchange', 'coat_stand', [
        rect(379, 237, 7, 182), rect(360, 418, 40, 9),
        tube((360, 240), (366, 250), 6), tube((366, 250), (399, 251), 6), tube((399, 251), (409, 240), 6),
        tube((384, 281), (401, 278), 6), tube((401, 278), (403, 272), 5),
        [[346, 253], [359, 254], [372, 270], [375, 351], [368, 356], [350, 355], [349, 350], [331, 350], [333, 282]]], True)
    world('IstanbulHastane', 'coat_stand', [rect(1050, 181, 8, 163), rect(1038, 342, 35, 32),
        tube((1034, 179), (1037, 188), 6), tube((1037, 188), (1069, 188), 6), tube((1069, 188), (1073, 179), 6),
        [[1028, 200], [1038, 200], [1045, 210], [1048, 230], [1047, 303], [1041, 315], [1027, 315], [1026, 310], [1013, 310], [1013, 245], [1020, 215]]], True)

    # Seat banks have shared beams and measured legs. The generic per-chair
    # approximation left stripes of floor and omitted the real support feet.
    for scene, name, backs, seat, legs, arms in [
        ('Airport', 'gate_seats', [(249,356,47,35),(300,356,46,35),(351,356,47,35),(402,356,47,35)],
         (245,390,207,16), [(251,405,10,16),(289,405,10,16),(303,405,10,16),(339,405,10,16),(354,405,10,16),(390,405,10,16),(405,405,10,16),(443,405,10,16)], []),
        ('Hospital', 'waiting', [(105,437,65,57),(181,438,66,57),(258,438,65,57),(334,438,65,57),(411,438,65,57)],
         (95,493,386,22), [(105,515,9,20),(160,515,9,20),(104,535,15,7),(158,535,16,7),(278,515,9,20),(331,515,9,20),(276,535,16,7),(329,535,16,7)], []),
        ('Police', 'waiting', [(83,488,78,64),(171,488,81,64),(259,488,80,64),(346,488,81,64)],
         (77,551,355,35), [(85,585,9,30),(252,585,10,30),(417,585,10,30),(80,615,20,11),(246,615,21,11),(410,615,20,11)],
         [(71,534,16,10),(153,534,16,11),(251,534,13,10),(334,534,13,10),(423,534,17,10)]),
        ('IstanbulHastane', 'waiting_left', [(138,458,53,55),(202,458,53,55),(266,458,53,55),(329,458,53,55)],
         (134,513,250,19), [(143,532,9,29),(181,532,9,29),(205,532,10,29),(246,532,10,29),(267,532,10,29),(307,532,10,29),(330,532,10,29),(369,532,10,29)], []),
        ('IstanbulHastane', 'waiting_right', [(713,458,54,55),(777,458,54,55),(841,458,54,55),(905,458,54,55)],
         (708,513,253,19), [(716,532,9,29),(756,532,9,29),(779,532,9,29),(819,532,9,29),(843,532,9,29),(883,532,9,29),(907,532,9,29),(947,532,9,29)], []),
        ('IstanbulKarakol', 'waiting', [(155,468,53,55),(218,468,57,55),(282,468,57,55),(347,468,57,55)],
         (148,522,260,18), [(154,540,9,33),(197,540,9,33),(220,540,9,33),(260,540,9,33),(284,540,9,33),(326,540,9,33),(350,540,9,33),(391,540,9,33)], []),
        ('IstanbulHavalimani', 'seats_back', [(552,382,46,42),(610,382,46,42),(665,382,48,42),(719,382,45,42)],
         (542,421,229,18), [(548,438,10,16),(597,438,10,16),(653,438,10,16),(710,438,10,16),(758,438,10,16)],
         [(542,405,8,20),(600,405,7,20),(656,405,6,20),(712,405,6,20),(765,404,8,21)]),
        ('IstanbulHavalimani', 'seats_front', [(543,479,50,48),(606,479,50,48),(668,479,51,48),(731,479,49,48)],
         (530,527,264,18), [(535,545,10,17),(596,545,10,17),(657,545,10,17),(720,545,10,17),(780,545,10,17)],
         [(532,502,9,29),(595,502,9,29),(658,502,9,29),(720,502,9,29),(783,502,9,29)]),
    ]:
        polys = []
        for x,y,w,h in backs:
            polys.append([[x+3,y],[x+w-3,y],[x+w,y+3],[x+w,y+h],[x,y+h],[x,y+3]])
        polys += [rect(*r) for r in [seat]+legs+arms]
        world(scene, name, polys, True)

    # Preserve the actual iron pattern, including its irregular rounded
    # junctions. Warm paving in the openings is rejected by the metal key.
    obj('BerlinKreuzberg', 'canal_rail')['polygons'] = []
    obj('BerlinKreuzberg', 'canal_rail')['foliage'] = [rect(0, 545, 396, 93), rect(476, 545, 676, 93)]
    obj('BerlinKreuzberg', 'canal_rail')['painted_metal'] = True

    # A bicycle outside a shop needs its own wheels and frame in depth.
    # Use the same ring construction as the other bicycle, in world pixels.
    bike = wheel(855,400,20,20,4)+wheel(916,400,20,20,4)
    bike += [tube(a,b,w) for a,b,w in [((855,400),(871,361),3),((863,380),(897,380),3),
        ((871,400),(898,380),3),((855,400),(871,400),3),((871,400),(863,380),3),
        ((898,380),(916,400),3),((898,380),(905,365),3),((886,358),(913,358),5)]]
    world_object('IstanbulKarakoy', 'bicycle', 422, (835,411,102,11), bike)
    world('IstanbulKarakoy', 'rope', [
        [[570,383],[582,379],[594,384],[604,395],[603,409],[592,423],[575,425],[559,416],[555,402],[560,390]]], True)
    world('IstanbulKarakoy', 'mooring', [
        [[729,348],[747,350],[757,365],[756,383],[768,382],[778,391],
         [778,408],[766,423],[749,425],[736,416],[736,397],[718,391],
         [707,379],[710,362]], rect(777,390,15,34)])
    world('IstanbulKarakoy', 'cylinders', [
        rect(438,374,64,51), rect(444,366,12,9), rect(462,365,12,9), rect(480,365,12,9)])

    # Luggage trolley handles are curved blue loops, with transparent centres.
    # Key their exact blue paint inside the handle band; trace the silver
    # uprights, baskets, crossbar and individual wheels separately.
    for scene, bounds in [('Airport', (46,604,267,44)), ('IstanbulHavalimani', (1289,546,365,22))]:
        obj(scene, 'trolleys')['foliage'] = [points(rect(*bounds))]
        obj(scene, 'trolleys')['blue_handles'] = True
    carts = [rect(58,738,249,10)]
    for x in [60,99,140,178,218,258]:
        carts += [rect(x,624,10,114), rect(x+11,652,28,65),
                  rect(x+11,733,29,6), rect(x+35,652,5,83)]
    for x in [71,114,151,185,236,274]:
        carts += wheel(x,759,13,13,13)
    shapes('Airport', 'trolleys', carts, True)
    carts = [rect(1290,650,364,11), rect(1264,635,30,9)]
    for x in [1292,1332,1372,1412,1452,1493,1533,1573,1613]:
        carts += [rect(x,565,14,85), rect(x+13,573,27,6),
                  rect(x+13,588,27,46)]
    for x in [1279,1317,1357,1397,1437,1478,1518,1558,1598,1638]:
        carts += wheel(x,670 if x>1280 else 661,13,13,13)
    shapes('IstanbulHavalimani', 'trolleys', carts, True)

    # The park has round-topped posts at irregular spacings. The old regular
    # triangular pickets sampled the paving above/beside the real iron and
    # punched little notches into a person behind it.
    gate = obj('BerlinPrenzlberg', 'park_fence')['polygons'][58:]
    fence = [tube((980,602),(1199,606),8), rect(981,683,218,8),
             rect(1340,637,332,8), rect(1340,682,332,9)]
    for cx, top, half in [
        (992,582,7),(1014,595,5),(1032,588,5),(1053,588,5),(1073,588,5),
        (1097,586,5),(1120,586,5),(1141,586,5),(1161,585,5),(1184,588,5),(1200,586,5)
    ] + [(x,625 if x!=1550 else 632,4) for x in
         [1360,1379,1397,1415,1433,1452,1469,1485,1500,1516,1534,1550,1566,1583,1600,1620,1641,1664]]:
        fence.append([[cx-half,top+3],[cx-2,top],[cx+2,top],[cx+half,top+3],
                      [cx+half+1,top+9],[cx+half-1,top+13],[cx+half-1,704],
                      [cx-half+1,704],[cx-half+1,top+13],[cx-half-1,top+9]])
    shapes('BerlinPrenzlberg','park_fence',fence,True)
    # Reject gray paving at the rounded post edges while retaining the
    # authored iron pixels. The gate's paper poster remains opaque.
    obj('BerlinPrenzlberg','park_fence')['foliage'] = obj('BerlinPrenzlberg','park_fence')['polygons']
    obj('BerlinPrenzlberg','park_fence')['painted_metal'] = True
    obj('BerlinPrenzlberg','park_fence')['polygons'] = gate

    # These four round bollards and the taller post beside the park are
    # different drawings. The old shared cap template copied empty wall
    # above the tall post and omitted the tops of the short ones.
    for x in [179,338,528,814]:
        c = x+12.5
        shapes('BerlinPrenzlberg', 'bollard_'+str(x), [[
            [c-4,619],[c+4,619],[c+8,623],[c+9,629],[c+6,634],
            [c+6,636],[c+8,637],[c+8,643],[c+7,645],[c+7,695],
            [c+11,696],[c+13,700],[c+12,703],[c+9,705],
            [c-10,705],[c-13,702],[c-13,699],[c-10,696],[c-7,695],
            [c-7,645],[c-8,643],[c-8,637],[c-6,636],[c-6,634],
            [c-9,630],[c-9,626],[c-7,622]]], True)
    shapes('BerlinPrenzlberg', 'bollard_940', [[
        [945,612],[950,612],[954,616],[955,621],[953,625],
        [955,626],[955,631],[953,633],[953,705],[955,708],
        [955,721],[941,721],[941,708],[942,705],[942,633],
        [940,631],[940,626],[943,625],[941,621],[942,616]]], True)
    feet('BerlinPrenzlberg', 'bollard_940', [(940,708,16,14)])
    obj('BerlinPrenzlberg', 'bollard_940')['sort_y'] = round(722*sy,2)
