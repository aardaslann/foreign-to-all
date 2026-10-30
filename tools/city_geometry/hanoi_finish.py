"""Hanoi replacements: measured contacts, complete silhouettes and actual doors.

Each scene is activated only when its replacement has been viewed and aligned.
The later exhaustive movement audit is deliberately tracked separately.
"""
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import pot, oval
from .seoul import box
from .hanoi import pole, plastic_stool, route_post
from .tokyo import wheel


def replace(row, name, replacement):
    index = next(i for i, obj in enumerate(row['objects']) if obj['id'] == name)
    row['objects'][index] = replacement


def finish(rows):
    implementations = {'PhoCo': phoco, 'LongBien': longbien, 'DongDa': dongda,
                       'BaDinh': badinh, 'TayHo': tayho, 'Hotel': hotel,
                       'Exchange': exchange, 'Transit': transit, 'Airport': airport}
    for name, fn in implementations.items():
        row = rows['Hanoi' + name]
        row.update(texture=f'res://art/environments/scenes/Hanoi{name}-retro.png',
                   pixel_art=True, art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
        fn(row)
    return rows


def phoco(row):
    row['floor'] = point(0, 620)[1]
    row['objects'] = [
        pot('west_tree', (19, 597, 63, 56), (0, 381, 126, 224),
            [rect(45, 505, 11, 94), tube((52, 554), (26, 521), 8),
             tube((52, 537), (83, 508), 9)]),
        pot('west_small_pot', (107, 614, 32, 31), (93, 537, 61, 82)),
        pot('middle_tree', (491, 597, 58, 53), (470, 462, 106, 141),
            [rect(514, 553, 13, 48)]),
        pot('station_tree', (1007, 598, 48, 54), (973, 454, 114, 150),
            [rect(1023, 540, 13, 62)]),
        pot('station_small_pot', (1099, 623, 23, 24), (1090, 573, 44, 53)),
        pot('station_east_pot', (1299, 602, 29, 45), (1293, 526, 57, 79)),
        pot('east_tree', (1344, 597, 55, 54), (1326, 407, 111, 193),
            [rect(1367, 488, 15, 110), tube((1373, 516), (1335, 473), 8),
             tube((1375, 506), (1405, 472), 8)]),
        pot('door_flower', (298, 630, 18, 16), (287, 584, 39, 49)),
        pot('far_west_pot', (4, 633, 15, 15), (0, 596, 27, 38)),
        box('lodging_left_display', 160, 576, 54, 66),
        box('lodging_right_display', 260, 577, 50, 64),
        box('exchange_left_display', 575, 570, 58, 75),
        box('exchange_right_display', 686, 571, 52, 73),
        box('middle_display', 810, 526, 54, 121),
        box('drinks_display', 865, 530, 44, 116)]
    # Rows of low plastic stools keep open triangular leg gaps; their small
    # contact areas do not claim the whole height as an impassable block.
    for i, x in enumerate([402, 453, 541, 585, 687, 734, 1201, 1246]):
        row['objects'].append(plastic_stool('street_stool_' + str(i), x, 627, 40, 42))
    for i, x in enumerate([416, 1209]):
        row['objects'].append(object_('street_table_' + str(i), 654,
            [(x+3, 636, 47, 18)], [rect(x, 610, 52, 9),
             rect(x+4, 619, 6, 33), rect(x+43, 619, 6, 33), rect(x+10, 641, 33, 4)]))
    for name, x, top, bottom, width, bars in [
        ('west', 333, 273, 662, 23, [(296, 79), (358, 70)]),
        ('middle', 790, 283, 663, 21, [(287, 55), (350, 69)]),
        ('station', 1291, 269, 664, 23, [(273, 70), (335, 62)]),
        ('east', 1455, 306, 663, 19, [(323, 61), (349, 59)])]:
        obj = pole(name + '_utility_pole', x, top, bottom, width)
        for y, w in bars:
            obj['polygons'].append([point(a, b) for a, b in rect(x-w/2, y, w, 14)])
        row['objects'].append(obj)
    for i, (x, w, goods_top) in enumerate([(1420, 67, 559), (1494, 40, 552),
                                         (1549, 53, 548), (1610, 54, 550)]):
        row['objects'].append(object_('east_market_' + str(i), 644,
            [(x+3, 625, w-6, 19)], [rect(x, 589, w, 55),
             [[x, 589], [x+3, goods_top+8], [x+w*.3, goods_top],
              [x+w*.7, goods_top+3], [x+w-3, goods_top+9], [x+w, 589]]]))
    row['anchors'].update(HotelDoor=anchor(235, 693), ExchangeDoor=anchor(656, 694),
                          TransitDoor=anchor(1175, 702), LocalSpot=anchor(875, 704))
    row['lettering'] = [
        sign((152, 414, 159, 42), 'NHÀ NGHỈ', '#e8d6a8', '#29393e', size=26),
        sign((570, 402, 174, 37), 'ĐỔI TIỀN', '#e8d6a8', '#29393e', size=26),
        sign((1087, 401, 174, 39), 'GA →', '#e8d6a8', '#29393e', size=29),
        sign((824, 486, 91, 22), 'BIA HƠI', '#285142', size=13)]


def longbien(row):
    # Most crates intentionally retain the previous positions. Only changed
    # surfaces are replaced; every original measured display remains listed.
    replace(row, 'west_tree', object_('west_tree', 676, [(119, 657, 24, 19)],
        [rect(123, 511, 13, 160), tube((129, 547), (108, 518), 7),
         tube((128, 522), (143, 494), 7)],
        foliage=[[[86, 326], [91, 276], [151, 225], [221, 215], [266, 276],
                  [251, 332], [225, 342], [250, 443], [216, 496], [192, 518],
                  [157, 561], [102, 542], [83, 477]]], wood_branches=True))
    replace(row, 'west_pot', pot('west_pot', (57, 624, 56, 56), (37, 520, 104, 108)))
    replace(row, 'west_utility_pole', pole('west_utility_pole', 167, 320, 691, 25))
    replace(row, 'east_utility_pole', pole('east_utility_pole', 1611, 302, 692, 28))
    replace(row, 'red_stool', plastic_stool('red_stool', 1039, 647, 39, 38))
    replace(row, 'blue_stool', plastic_stool('blue_stool', 1384, 638, 43, 41))
    # Whole produce tops cover characters naturally; empty canopy supports
    # remain thin strokes rather than rectangular pasted pieces of backdrop.
    for i, x in enumerate([209, 398, 440, 631, 698, 883, 929, 1142, 1191, 1370, 1458]):
        row['objects'].append(object_('stall_upright_' + str(i), 678,
            [(x-2, 662, 9, 16)], [rect(x, 536 if x < 413 else 519, 4,
                                        141 if x < 413 else 158)]))
    row['lettering'] = [sign((9, 438, 36, 25), 'CHỢ', '#e3d0a0', '#3a3b33', size=10)]
    row['motion'] = [dict(kind='water', rect=[*point(780, 449), *point(330, 14)])]


def dongda(row):
    row['objects'] = [o for o in row['objects'] if not o['id'].startswith('scooter_')]
    for name, x, crown in [('workshop_tree', 597, (510, 257, 194, 294)),
                            ('grocery_tree', 1169, (1050, 203, 235, 321)),
                            ('east_tree', 1604, (1512, 263, 160, 274))]:
        replace(row, name, object_(name, 678, [(x-27, 657, 54, 21)],
            [rect(x-27, 671, 54, 7), rect(x-10, 497, 22, 175),
             tube((x, 535), (x-31, 501), 12), tube((x, 517), (x+28, 484), 11)],
            foliage=[rect(*crown), rect(x-28, 635, 56, 39)], wood_branches=True))
    replace(row, 'drink_machine', box('drink_machine', 1184, 517, 58, 137))
    replace(row, 'cafe_flowers', pot('cafe_flowers', (138, 650, 115, 36), (124, 584, 143, 70)))
    replace(row, 'workshop_pot', pot('workshop_pot', (574, 611, 59, 45), (555, 542, 91, 78)))
    replace(row, 'east_pot', pot('east_pot', (1621, 622, 48, 32), (1620, 544, 52, 81)))
    # The smaller silhouettes were remeasured on each actual parked scooter.
    for i, (x, y, w, h) in enumerate([(445, 578, 32, 66), (492, 576, 37, 71),
        (679, 577, 32, 69), (721, 577, 35, 70), (766, 579, 32, 68),
        (808, 579, 31, 68), (848, 578, 33, 69)]):
        cx = x + w/2
        row['objects'].append(object_('scooter_' + str(i), y+h, [(x+3, y+h-16, w-6, 16)],
            [[[x+4, y+9], [x+w-4, y+9], [x+w, y+28], [x+w-4, y+h-18],
              [x+w-10, y+h-9], [x+8, y+h-9], [x, y+h-22], [x, y+29]],
             rect(cx-5, y+h-19, 10, 18), oval(cx, y+5, 6, 7),
             tube((cx-1, y+6), (x-3, y-3), 3), tube((cx+1, y+6), (x+w+3, y-3), 3),
             oval(x-3, y-4, 4, 2), oval(x+w+3, y-4, 4, 2)]))
    row['floor'] = point(0, 622)[1]
    row['anchors'].update(TransitDoor=anchor(1471, 704), LocalSpot=anchor(652, 708))
    row['lettering'] = [
        sign((97, 352, 189, 41), 'CÀ PHÊ', '#e6d5ae', '#293b40', size=29),
        sign((673, 449, 209, 34), 'SỬA XE', '#293b45', size=27),
        sign((941, 450, 181, 34), 'TẠP HÓA', '#e8d6a7', '#293b40', size=25),
        sign((1387, 402, 175, 37), 'GA →', '#e8d6a7', '#293b40', size=30),
        sign((385, 600, 31, 32), 'SỬA\nXE', '#eee5ca', '#283b3b', size=9,
             object='workshop_board')]


def badinh(row):
    row['objects'] = [o for o in row['objects'] if o['id'] not in
                      ['compound_gate_1', 'bicycles_and_racks']]
    # Open leaves are thin side silhouettes, leaving the central path clear.
    row['objects'] += [
        object_('station_gate_left', 651, [(1292, 635, 24, 16)],
            [[[1292, 479], [1316, 470], [1316, 633], [1292, 650]]]),
        object_('station_gate_right', 651, [(1362, 635, 24, 16)],
            [[[1362, 469], [1386, 477], [1386, 649], [1362, 633]]])]
    for i, (x1, x2) in enumerate([(953, 1044), (1125, 1206)]):
        polys = wheel(x1, 637, 28) + wheel(x2, 637, 28)
        # These bicycles face left. Extract their actual blue frame, rather
        # than drawing an assumed frame across its empty triangles.
        polys += [rect(x1+2, 579, 30, 7), rect(x2-32, 581, 29, 7)]
        row['objects'].append(object_('bicycle_' + str(i), 670,
            [(x1-30, 650, x2-x1+60, 20)], polys,
            foliage=[rect(x1-3, 584, x2-x1+9, 64)], blue_handles=True))
    for i, (x, y) in enumerate([(996, 623), (1079, 611), (1173, 629), (1227, 617)]):
        row['objects'].append(object_('bike_rack_' + str(i), 674,
            [(x-2, 658, 23, 16)], [rect(x, y, 4, 674-y),
             tube((x+2, y), (x+10, y-12), 4), tube((x+10, y-12), (x+21, y), 4),
             rect(x+19, y, 4, 674-y)]))
    row['anchors'].update(TransitDoor=anchor(1341, 710))
    row['lettering'] = [
        sign((240, 450, 184, 28), 'BÁO', '#ac3533', size=29),
        sign((980, 171, 94, 21), 'HỒ CHÍ MINH', '#87949b', '#35434b', size=11)]
    # Direction marker is attached to the solid pier beside the open gate.
    row['lettering'].append(sign((1400, 542, 18, 58), 'GA\n→', '#e2cd9b',
        '#294b40', size=10, object='compound_pier_5'))


def flowerbox(name, bounds, crown, blooms):
    obj = pot(name, bounds, crown)
    # Color masks retain leaves. These small petal silhouettes additionally
    # retain the warm-colored blossoms without copying the pale wall behind.
    for x, y, radius in blooms:
        obj['polygons'].append([point(a, b) for a, b in oval(x, y, radius, radius)])
    return obj


def tayho(row):
    for i, (a, b) in enumerate([(48, 385), (434, 744), (790, 1068), (1115, 1672)]):
        bars = [rect(a, 596, b-a, 7), rect(a, 609, b-a, 5), rect(a, 665, b-a, 8)]
        for cx in range(a+35, b-20, 69):
            ring = oval(cx, 638, 19, 21)
            bars += [tube(ring[j], ring[(j+1) % len(ring)], 4) for j in range(len(ring))]
            bars += [rect(cx-32, 612, 5, 52), rect(cx+30, 612, 4, 52),
                     rect(cx-2, 629, 5, 17), rect(cx-7, 635, 15, 5)]
        replace(row, 'lake_rail_' + str(i), object_('lake_rail_' + str(i), 676,
            [(a, 663, b-a, 13)], bars))
    replace(row, 'west_flowers', flowerbox('west_flowers', (62, 668, 149, 48),
        (51, 588, 169, 82), [(82, 618, 7), (105, 631, 8), (80, 648, 7),
        (130, 649, 9), (151, 626, 8), (180, 651, 8), (197, 634, 7)]))
    replace(row, 'middle_flowers', flowerbox('middle_flowers', (610, 668, 145, 48),
        (596, 585, 170, 86), [(622, 622, 8), (640, 645, 8), (662, 632, 8),
        (681, 647, 7), (702, 619, 8), (720, 640, 9), (741, 619, 7)]))
    replace(row, 'east_flowers', flowerbox('east_flowers', (1455, 668, 148, 48),
        (1439, 585, 177, 88), [(1466, 636, 8), (1489, 618, 8), (1498, 650, 8),
        (1528, 630, 8), (1551, 649, 8), (1575, 620, 8), (1590, 638, 7)]))
    replace(row, 'lakeside_tree', object_('lakeside_tree', 700, [(14, 681, 39, 19)],
        [[[17, 697], [19, 448], [5, 420], [0, 390], [0, 365], [20, 407],
          [24, 332], [13, 306], [15, 284], [33, 315], [47, 281], [59, 286],
          [45, 326], [44, 403], [70, 368], [89, 317], [101, 319], [83, 379],
          [54, 424], [45, 484], [45, 682], [52, 699]]],
        foliage=[rect(0, 0, 292, 353)], wood_branches=True))
    row['lettering'] = [sign((1394, 306, 245, 53), 'CÀ PHÊ', '#ead8ad', '#2b3b3f', size=34)]
    row['animation_patches'] = [dict(kind='water', rect=[*point(259, 432), *point(789, 107)])]


def hotel(row):
    row['objects'] = [
        object_('reception', 690, [(356, 670, 655, 20)], [rect(350, 498, 669, 24),
            rect(360, 522, 650, 147), rect(356, 669, 655, 21),
            rect(391, 460, 73, 38), rect(477, 438, 74, 60), rect(487, 470, 41, 28),
            rect(821, 411, 68, 87), rect(906, 489, 33, 9), oval(923, 487, 12, 11),
            rect(941, 462, 59, 36)], foliage=[rect(914, 381, 111, 84)], wood_branches=True),
        pot('west_lobby_tree', (1057, 538, 72, 105), (1045, 381, 106, 163),
            [rect(1088, 476, 12, 66)]),
        pot('east_lobby_tree', (1372, 542, 74, 104), (1356, 382, 113, 163),
            [rect(1403, 477, 12, 67)]),
        object_('umbrella_stand', 691, [(277, 674, 63, 17)], [rect(277, 563, 63, 126),
            rect(282, 535, 51, 30), tube((287, 552), (285, 517), 8),
            tube((285, 517), (285, 498), 9), tube((285, 498), (294, 487), 9),
            tube((294, 487), (304, 492), 9), tube((304, 492), (308, 516), 9),
            tube((323, 564), (330, 520), 8), tube((330, 520), (328, 508), 8),
            tube((328, 508), (320, 505), 8), tube((320, 505), (314, 515), 8)]),
        object_('garden_bench', 642, [(1153, 626, 196, 16)], [rect(1151, 558, 201, 32),
            rect(1158, 590, 18, 50), rect(1325, 590, 18, 50), rect(1176, 611, 149, 15)]),
        object_('garden_box', 608, [(1142, 590, 222, 18)], [rect(1142, 499, 222, 109)])]
    row['clerks']['Point'] = anchor(686, 524)
    row['anchors']['Point'] = anchor(686, 742)
    row['lettering'] = [
        sign((516, 254, 365, 49), 'KHÁCH SẠN HÀ NỘI', '#00000000', '#455244', size=30),
        sign((946, 169, 48, 160), 'AN\nKHANG', '#a03229', '#e8c055', size=18)]


def exchange(row):
    row['objects'] = [
        object_('exchange_counter', 674, [(366, 654, 866, 20)], [rect(360, 515, 878, 22),
            rect(366, 537, 866, 137), rect(361, 199, 11, 316), rect(1226, 198, 11, 317),
            rect(482, 410, 108, 81), rect(518, 453, 24, 52), rect(496, 505, 74, 9),
            rect(402, 444, 56, 71), rect(458, 481, 21, 33), rect(743, 445, 55, 68),
            rect(866, 446, 61, 68), rect(1053, 467, 47, 47), rect(1141, 489, 60, 24),
            rect(601, 499, 39, 14), rect(674, 499, 48, 14), rect(938, 496, 38, 17)],
            glass=[rect(373, 202, 849, 312)], foliage=[rect(1116, 417, 100, 76)], wood_branches=True),
        object_('leaflet_rack', 690, [(273, 674, 75, 16)], [rect(275, 473, 72, 204),
            rect(273, 677, 75, 13)])]
    row['clerks']['Point'] = anchor(832, 530)
    row['lettering'] = [
        sign((481, 67, 634, 70), 'THU ĐỔI NGOẠI TỆ', '#193f70', size=39),
        sign((581, 144, 433, 34), 'MONEY EXCHANGE', '#193f70', size=27),
        sign((962, 240, 228, 147), 'USD · EUR\nJPY · SGD\nVND', '#1e2830', '#ead78d', size=27)]


def transit(row):
    row['fittings'] = []
    row['objects'] = [
        box('west_column', 48, 65, 42, 624), box('middle_column', 461, 65, 42, 626),
        box('east_column', 1459, 66, 44, 647),
        object_('platform_bench', 806, [(56, 788, 250, 18)], [rect(74, 688, 231, 18),
            rect(74, 710, 231, 17), rect(52, 732, 259, 22), rect(69, 754, 15, 48),
            rect(276, 754, 15, 49), rect(60, 798, 40, 8), rect(265, 798, 33, 8)]),
        box('platform_bin', 368, 641, 74, 156),
        object_('gate_west', 805, [(520, 787, 73, 18)], [
            [[520, 664], [548, 637], [589, 637], [590, 774], [565, 803], [520, 803]]]),
        object_('gate_middle', 805, [(664, 787, 64, 18)], [
            [[665, 663], [688, 637], [723, 637], [725, 776], [705, 803], [665, 803]]]),
        object_('stair_ticket_gate', 805, [(858, 787, 49, 18)], [
            [[858, 660], [875, 639], [901, 639], [907, 653], [907, 794], [899, 803], [858, 803]]]),
        object_('ticket_machine', 800, [(746, 782, 82, 18)], [
            rect(749, 599, 76, 184), rect(746, 783, 82, 17)]),
        object_('stair_glass', 798, [(910, 780, 231, 18)], [rect(909, 612, 233, 8),
            rect(912, 620, 8, 171), rect(950, 620, 10, 170), rect(1031, 620, 11, 172),
            rect(1136, 620, 7, 174), rect(914, 788, 10, 10), rect(949, 788, 16, 10),
            rect(1029, 788, 17, 10), rect(1066, 685, 14, 109),
            tube((1073, 684), (1074, 676), 8), rect(1080, 684, 11, 109)],
            glass=[rect(921, 621, 28, 165), rect(961, 621, 69, 165), rect(1043, 621, 92, 165)]),
        object_('stair_east_rail', 803, [(1394, 785, 278, 18)], [
            tube((1396, 793), (1435, 650), 9), tube((1435, 650), (1445, 639), 9),
            tube((1445, 639), (1475, 645), 9), rect(1467, 646, 12, 73),
            tube((1471, 716), (1482, 777), 9), rect(1475, 782, 12, 17),
            rect(1519, 615, 9, 179), rect(1616, 616, 8, 179), rect(1517, 611, 155, 8),
            rect(1516, 791, 17, 12), rect(1611, 791, 19, 12)],
            glass=[rect(1529, 620, 85, 169), rect(1626, 620, 46, 169)]),
        object_('stair_opening', 799, [(1142, 716, 376, 83)], [])]
    # Rear rail is a physical platform edge, with individually open bars.
    rail = [rect(91, 580, 469, 9), rect(91, 666, 469, 7)]
    rail += [rect(x, 589, 7, 79) for x in [99, 138, 240, 337, 435, 549]]
    row['objects'].append(object_('rear_platform_rail', 678, [(91, 663, 469, 15)], rail))
    row.update(floor=point(0, 663)[1], walk_bottom=point(0, 890)[1], spawn=point(876, 862))
    row['anchors'].update(Machine=anchor(786, 853), Platform=anchor(627, 731), Exit=anchor(1320, 858))
    row['lettering'] = [
        sign((125, 302, 365, 45), 'GA HÀ NỘI', '#203f70', size=34),
        sign((125, 350, 365, 27), 'Hanoi Metro', '#203f70', size=22),
        sign((944, 307, 430, 61), 'CÁT LINH — HÀ ĐÔNG', '#eee3cd', '#29463e', size=28),
        sign((767, 621, 32, 21), 'VÉ', '#214269', size=12, object='ticket_machine')]
    row['motion_layers'] = [dict(kind='doors', rect=[*point(x, 521), *point(w, 109)])
                            for x, w in [(672, 77), (939, 73), (1248, 76), (1538, 77)]]


def airport(row):
    row['fittings'] = []
    row['objects'] = [box('west_column', 95, 0, 63, 633), box('east_column', 1314, 0, 50, 609),
        pot('west_plant', (38, 591, 68, 49), (14, 502, 113, 94)),
        pot('middle_plant', (829, 592, 65, 47), (814, 511, 98, 85)),
        object_('check_in_kiosk', 699, [(739, 682, 78, 17)], [rect(745, 541, 64, 57),
            rect(743, 598, 69, 25), rect(748, 623, 60, 59), rect(739, 682, 78, 17)]),
        object_('luggage_belt', 743, [(1054, 663, 618, 80)], [
            [[1054, 642], [1067, 630], [1154, 605], [1672, 605], [1672, 743],
             [1121, 741], [1074, 725], [1054, 696]],
            rect(1291, 540, 63, 73), rect(1369, 540, 84, 73), rect(1410, 517, 27, 7),
            rect(1410, 522, 6, 18), rect(1431, 522, 6, 18)])]
    # Shared rails are narrow; each seat retains its own open arm and leg gaps.
    for i, x in enumerate([171, 233, 298, 372, 456, 520, 581, 644]):
        row['objects'].append(object_('terminal_seat_' + str(i), 646,
            [(x-6, 631, 65, 15)], [rect(x+4, 551, 52, 56), rect(x-3, 608, 66, 14),
            rect(x-10, 596, 7, 22), rect(x+57, 596, 7, 22), rect(x-8, 621, 75, 8),
            rect(x-4, 629, 7, 12), rect(x+56, 629, 7, 12),
            rect(x-8, 641, 14, 5), rect(x+54, 641, 14, 5)]))
    row['anchors'].update(Point=anchor(778, 748), Exit=anchor(1021, 691))
    row['lettering'] = [
        sign((174, 199, 230, 44), 'SẢNH ĐẾN', '#1b3e6b', size=31),
        sign((174, 253, 230, 29), 'Arrivals', '#1b3e6b', size=24),
        sign((1309, 200, 195, 82), 'NỘI BÀI\nHAN', '#1e416e', size=31),
        sign((962, 193, 240, 108), 'KHỞI HÀNH\nHÀ NỘI · SEOUL\nTOKYO · PARIS', '#1b252a', '#eed263', size=18),
        sign((752, 550, 48, 16), 'LÀM THỦ TỤC', '#233c59', size=8, object='check_in_kiosk')]
    row['animation_patches'] = [dict(kind='conveyor', rect=[*point(1144, 626), *point(125, 26)])]
