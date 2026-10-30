"""Inspected Mumbai replacement art, measured contacts and complete cutouts.

Coordinates are on the 1672x941 reference canvas. The geometry-only source
inventory is preserved when an object did not move; changed objects replace it.
Exhaustive walking/contact QA is tracked separately from this installation.
"""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, tube, object_
from .mumbai import sign, small_bin
from .moscow import pot, oval
from .seoul import box
from .hanoi import pole


def replace(row, name, obj):
    index = next(i for i, old in enumerate(row['objects']) if old['id'] == name)
    row['objects'][index] = obj


def shift(obj, dx, dy):
    # Preserve hand-authored leg/rail gaps when a complete assembly moves.
    wx, wy = point(dx, dy)
    obj['sort_y'] = round(obj['sort_y'] + wy, 2)
    for footprint in obj['footprints']:
        footprint[0] += wx
        footprint[1] += wy
    for key in ['polygons', 'foliage', 'glass']:
        for polygon in obj.get(key, []):
            for vertex in polygon:
                vertex[0] += wx
                vertex[1] += wy


def finish(rows):
    for suffix, fn in [('Bhuleshwar', bhuleshwar), ('ChorBazaar', chorbazaar),
                       ('Colaba', colaba), ('Bandra', bandra), ('Byculla', byculla),
                       ('Hotel', hotel), ('Exchange', exchange),
                       ('Transit', transit), ('Airport', airport)]:
        row = rows['Mumbai' + suffix]
        row.update(texture=f'res://art/environments/scenes/Mumbai{suffix}-retro.png',
                   pixel_art=True, art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
        texture = Path(__file__).resolve().parents[2] / row['texture'].removeprefix('res://')
        row['source'] = [0, 0, *struct.unpack('>II', texture.read_bytes()[16:24])]
        fn(row)
    return rows


def bhuleshwar(row):
    # The new visible passage replaces the former pile of parcels. Do not
    # retain an invisible parcel collider inside the station entrance.
    row['objects'] = [o for o in row['objects'] if o['id'] not in ['railway_parcels', 'railway_crate']]
    replace(row, 'lodging_parcels_high', box('lodging_parcels_high', 349, 505, 43, 139))
    row['anchors'].update(HotelDoor=anchor(478, 697), TransitDoor=anchor(1336, 698))
    row['lettering'][3] = sign((1238, 285, 271, 83), 'RAILWAY →\nBOOKS · STATIONERY', '#00000000', size=25)
    row['animation_patches'] = [dict(kind='laundry', rect=[*point(1132, 116), *point(43, 44)])]


def chorbazaar(row):
    # This replacement's antiques are twelve pixels lower, without changing
    # their useful horizontal gaps. Utility poles and route posts are separate.
    for obj in row['objects']:
        if obj['id'] not in ['west_utility_pole', 'east_utility_pole', 'airport_stop', 'station_stop']:
            shift(obj, 0, 12)
    replace(row, 'west_utility_pole', pole('west_utility_pole', 106, 121, 701, 23))
    replace(row, 'east_utility_pole', pole('east_utility_pole', 1378, 121, 702, 25))
    row['floor'] = point(0, 675)[1]
    row['lettering'] = [
        sign((465, 310, 350, 45), 'CHOR BAZAAR', '#00000000', '#242c2e', size=35),
        sign((465, 365, 351, 30), 'BUY · SELL · REPAIR', '#00000000', '#323b3c', size=22),
        sign((1430, 457, 102, 69), 'OLD IS\nGOLD', '#00000000', '#243037', size=23)]
    row['objects'].append(object_('east_floor_lantern', 664, [(1290, 648, 49, 16)], [
        rect(1290, 577, 49, 87), tube((1304, 579), (1309, 570), 3),
        tube((1309, 570), (1322, 570), 3), tube((1322, 570), (1325, 580), 3)]))


def colaba(row):
    replace(row, 'west_utility_pole', pole('west_utility_pole', 1103, 76, 692, 27))
    replace(row, 'east_utility_pole', pole('east_utility_pole', 1636, 78, 692, 27))
    replace(row, 'shelter', object_('shelter', 691,
        [(1123, 667, 26, 24), (1245, 668, 20, 23), (1499, 664, 25, 27),
         (1147, 646, 353, 17)], [
            [[1120, 463], [1139, 448], [1533, 448], [1546, 456], [1543, 466],
             [1528, 478], [1122, 478]],
            rect(1126, 478, 19, 209), rect(1248, 485, 15, 197),
            rect(1502, 477, 19, 208), rect(1144, 478, 357, 11),
            rect(1144, 646, 357, 14), rect(1461, 488, 11, 189),
            rect(1157, 502, 80, 134), rect(1316, 522, 80, 93),
            rect(1405, 637, 42, 11), rect(1409, 609, 7, 28),
            rect(1437, 609, 7, 28), rect(1416, 603, 21, 7)],
        glass=[rect(1145, 490, 103, 155), rect(1264, 490, 197, 155),
               rect(1473, 490, 28, 155)]))
    row['lettering'] = [
        sign((327, 431, 124, 31), 'BOOKS', '#00000000', size=22),
        sign((577, 431, 184, 31), 'HANDICRAFTS', '#00000000', size=22),
        sign((900, 431, 103, 31), 'SPICES', '#00000000', size=22),
        sign((1164, 510, 65, 116), 'BEST\nBUS\n\nCOLABA\nRAILWAY', '#d5e9ee', '#254967', size=12, object='shelter')]
    row['animation_patches'] = [dict(kind='water', rect=[*point(1479, 394), *point(119, 47)])]


def bandra(row):
    replace(row, 'west_gate', object_('west_gate', 647, [(114, 625, 116, 22)], [
        rect(114, 626, 116, 19), rect(114, 535, 8, 91), rect(222, 535, 8, 91),
        *[rect(x, 529, 10, 97) for x in range(129, 221, 17)]]))
    replace(row, 'bougainvillea', object_('bougainvillea', 674, [(1052, 653, 39, 21)], [
        rect(1048, 616, 47, 12), rect(1053, 628, 38, 41), rect(1049, 669, 46, 5),
        [[1062, 618], [1068, 565], [1080, 531], [1098, 515], [1113, 479],
         [1135, 450], [1150, 421], [1160, 425], [1146, 455], [1125, 487],
         [1113, 520], [1090, 546], [1081, 578], [1077, 618]]],
        foliage=[rect(1035, 285, 277, 252)], wood_branches=True, pink_blossoms=True))
    replace(row, 'scooter', object_('scooter', 659, [(851, 642, 128, 17)], [
        oval(868, 640, 19, 19), oval(957, 641, 19, 18),
        [[849, 622], [855, 607], [873, 595], [882, 574], [892, 569],
         [901, 575], [891, 600], [890, 623], [924, 623], [930, 610],
         [964, 603], [977, 615], [982, 633], [974, 637], [967, 625],
         [948, 625], [940, 638], [884, 638], [877, 620], [861, 620]],
        rect(919, 588, 53, 12), tube((889, 572), (918, 580), 5),
        tube((888, 573), (881, 557), 3), rect(877, 551, 9, 11),
        tube((916, 579), (919, 572), 3), rect(913, 567, 13, 11)]))
    row['lettering'] = [
        sign((545, 430, 229, 30), 'BANDRA BAKERY', '#00000000', '#473c2f', size=26),
        sign((727, 595, 48, 58), 'PAO\nCHAI\nOPEN', '#193039', size=11, object='bakery_menu'),
        sign((1521, 450, 105, 25), 'RAILWAY →', '#00000000', size=16)]
    row['anchors']['TransitDoor'] = anchor(1572, 701)


def byculla(row):
    replace(row, 'west_tree', object_('west_tree', 714, [(47, 688, 51, 26)], [
        [[42, 689], [48, 535], [47, 464], [32, 426], [24, 384], [0, 353],
         [0, 335], [33, 370], [56, 402], [58, 347], [46, 317], [54, 307],
         [70, 344], [73, 404], [97, 383], [125, 347], [140, 341],
         [122, 374], [97, 411], [76, 436], [88, 446], [129, 411],
         [175, 382], [193, 345], [199, 352], [185, 390], [142, 429],
         [93, 473], [82, 541], [83, 689], [97, 714], [42, 714]]],
        foliage=[rect(0, 67, 276, 375)], wood_branches=True))
    row['lettering'] = [
        sign((239, 493, 217, 31), 'IRANI CHAI', '#00000000', '#253c44', size=28),
        sign((717, 516, 147, 31), 'TAILOR', '#00000000', '#253c44', size=28),
        sign((930, 310, 255, 104), 'BYCULLA\nMILL', '#a84936', size=39),
        sign((1307, 540, 118, 121), 'WORK\nBUILDS\nMUMBAI', '#00000000', '#777468', size=24),
        sign((628, 612, 38, 26), 'RAIL', '#cecfbf', '#303c3e', size=10)]
    row['motion'] = [dict(kind='steam', rect=[*point(323, 602), *point(43, 35)])]


def hotel(row):
    row['clerks']['Point'] = anchor(796, 450)
    row['anchors']['Point'] = anchor(794, 643)
    row['lettering'] = [sign((522, 233, 160, 56), 'HOTEL SHREE', '#00000000', '#433224', size=24)]
    replace(row, 'reception', object_('reception', 592, [(454, 563, 596, 29)], [
        rect(447, 424, 610, 23), rect(456, 447, 594, 141), rect(472, 390, 209, 34),
        rect(975, 401, 46, 23)], foliage=[rect(950, 338, 93, 65)]))
    replace(row, 'plant_cabinet', object_('plant_cabinet', 577, [(1356, 551, 107, 26)], [
        rect(1353, 425, 118, 14), rect(1359, 439, 102, 126),
        rect(1360, 565, 10, 12), rect(1447, 565, 12, 12),
        [[1383, 363], [1445, 363], [1445, 376], [1434, 424], [1390, 424]]],
        foliage=[rect(1359, 229, 116, 136)], wood_branches=True))
    row['motion'] = [dict(kind='steam', rect=[*point(380, 350), *point(20, 28)])]
    row['animation_patches'] = [dict(kind='fan', clean=True, rect=[*point(680, 3), *point(320, 90)])]


def exchange(row):
    row['clerks']['Point'] = anchor(909, 502)
    row['anchors']['Point'] = anchor(909, 710)
    row['lettering'] = [
        sign((630, 77, 501, 54), 'MONEY EXCHANGE', '#00000000', '#20333b', size=37),
        sign((632, 140, 503, 30), 'FOREIGN CURRENCY · TRAVEL CARDS', '#00000000', '#43585c', size=22),
        sign((340, 160, 238, 176), 'USD\nGBP\nEUR\nAED', '#00000000', '#efcb64', size=28),
        sign((1259, 225, 149, 119), 'TRAVEL\nEXPLORE\nRETURN', '#00000000', '#254467', size=23)]
    # The countertop display and printer paper must also occlude, rather than
    # vanishing above a correctly sorted drawer base.
    replace(row, 'right_drawers', object_('right_drawers', 675, [(1293, 653, 96, 22)], [
        rect(1290, 512, 101, 11), rect(1297, 523, 91, 142),
        rect(1297, 665, 9, 10), rect(1379, 665, 9, 10), rect(1310, 458, 58, 54)]))
    replace(row, 'right_printer', object_('right_printer', 483, [(1160, 466, 97, 17)], [
        rect(1160, 444, 97, 39), rect(1167, 397, 47, 47), rect(1209, 438, 35, 9)]))
    replace(row, 'right_cabinet', object_('right_cabinet', 675, [(1395, 653, 85, 22)], [
        rect(1390, 512, 96, 13), rect(1398, 525, 76, 136),
        rect(1398, 661, 10, 14), rect(1467, 661, 10, 14), rect(1421, 483, 38, 29)],
        foliage=[rect(1390, 402, 110, 82)], wood_branches=True))


def transit(row):
    row['fittings'] = []
    for label in row['lettering']:
        label['background'] = '#00000000'
    replace(row, 'ticket_machine', object_('ticket_machine', 770, [(417, 738, 102, 32)], [
        [[417, 548], [427, 539], [507, 539], [519, 550], [519, 763],
         [509, 770], [418, 770]]]))
    row['anchors'].update(Machine=anchor(469, 815), Platform=anchor(649, 690), Exit=anchor(1157, 684))
    # The hanging platform sign belongs to the tall column, not the train.
    east = next(o for o in row['objects'] if o['id'] == 'east_column')
    east['polygons'].append([point(x, y) for x, y in rect(1284, 174, 99, 97)])
    row['lettering'] += [
        sign((1297, 185, 71, 72), '2', '#00000000', size=52, object='east_column'),
        sign((440, 574, 52, 36), 'TICKETS', '#618dad', '#182f43', size=10, object='ticket_machine')]
    row['motion_layers'] = [dict(kind='doors', rect=[*point(620, 451), *point(82, 139)])]


def airport(row):
    belt = next(o for o in row['objects'] if o['id'] == 'front_luggage_belt')
    belt['sort_y'] = point(0, 880)[1]
    belt['footprints'] = [[*point(333, 798), *point(1115, 82)]]
    belt['polygons'] += [[point(x, y) for x, y in [
        [333, 816], [347, 805], [550, 805], [550, 776], [1108, 776],
        [1108, 790], [1435, 790], [1448, 801], [1448, 867], [1286, 867],
        [1286, 873], [333, 880]]]]
    row['spawn'] = anchor(1021, 740)
    row['anchors']['Point'] = anchor(1258, 702)
    row['lettering'] += [sign((1237, 437, 80, 53), 'CHECK IN', '#233644', size=12, object='check_in_counter')]
    # Rubber insets animate independently; no luggage silhouettes are sampled.
    belt['animation_patches'] = [dict(kind='conveyor', rect=[*point(550, 833), *point(183, 24)])]
