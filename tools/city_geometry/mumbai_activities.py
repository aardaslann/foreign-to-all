"""All five Mumbai activities staged on measured pixel sets.

Only presentation is authored here. The existing story branches, vocabulary,
money, items and reputation stay in StreetsideEast / StreetsideEastTwo.
"""
import struct
from copy import deepcopy
from pathlib import Path
from .shapes import point
from .mumbai import sign
from .london_activities import actor, shot, beat


def person(x, y, act='watch', **extra):
    return actor(x, y, act, **(dict(world_height=124, appearance={}) | extra))


def build():
    plates = {}
    for name, floor in [('Kabutarkhana', 745), ('ChorStall', 718), ('Gateway', 705),
                        ('MountMary', 778), ('SeaWall', 648), ('MuseumGarden', 714),
                        ('MuseumHall', 770)]:
        key = 'ActivityMumbai' + name
        file = Path(__file__).resolve().parents[2] / f'art/environments/scenes/{key}-retro.png'
        dimensions = struct.unpack('>II', file.read_bytes()[16:24])
        plates[key] = dict(city='mumbai', texture=f'res://art/environments/scenes/{key}-retro.png',
            source=[0, 0, *dimensions], pixel_art=True, floor=point(0, floor)[1],
            lettering=[], motion=[], animation_patches=[])
    birds = dict(kind='pigeon_flock', rect=[*point(689, 568), *point(844, 51)], count=84)
    plates['ActivityMumbaiKabutarkhana']['animation_patches'] = [birds]
    plates['ActivityMumbaiKabutarFlight'] = deepcopy(plates['ActivityMumbaiKabutarkhana'])
    plates['ActivityMumbaiKabutarFlight']['animation_patches'][0]['takeoff'] = True
    plates['ActivityMumbaiGateway']['animation_patches'] = [
        dict(kind='water', rect=[*point(1256, 565), *point(337, 59)])]
    plates['ActivityMumbaiSeaWall']['animation_patches'] = [
        dict(kind='water', rect=[*point(669, 420), *point(999, 112)])]
    plates['ActivityMumbaiMuseumGarden']['lettering'] = [
        sign((1497, 580, 92, 70), 'DR BHAU\nDAJI LAD\nMUSEUM', '#00000000', '#354d47', size=12)]

    stage = {}
    seller_look = {'build': 'adult', 'wear': 'kurta', 'cut': 'crop', 'face': ''}
    seller = person(253, 574, 'offer', clip_row=20, appearance=seller_look)
    platform = shot('ActivityMumbaiKabutarkhana', [person(483, 831), seller],
                    .5, 648, 324, full_plate=True)
    donor = person(650, 610, 'offer', world_height=108, appearance=seller_look)
    offering = shot('ActivityMumbaiKabutarkhana', [person(401, 809), donor],
                    .51, 493, 364, prop='grain_cup', prop_holder=1)
    poured = shot('ActivityMumbaiKabutarFlight', [person(627, 612, 'offer', world_height=108),
        person(1399, 790, 'watch', appearance=seller_look)], .53, 560, 365,
        prop='grain_cup', prop_holder=0)
    crowd = shot('ActivityMumbaiKabutarkhana', [person(403, 824),
        person(640, 612, 'offer', world_height=105,
            appearance={'build': 'elder', 'wear': 'sari', 'cut': 'tied'}),
        person(910, 613, 'watch', world_height=84,
            appearance={'build': 'child', 'wear': 'tee', 'cut': 'crop'}),
        person(1101, 613, 'offer', world_height=108,
            appearance={'build': 'adult', 'wear': 'suit', 'cut': 'crop'})],
        .5, 648, 324, full_plate=True)
    stage['mumbai:bhuleshwar'] = {'platform': beat(platform, [platform, offering]),
                                 'poured': beat(poured, [poured]), 'who': beat(crowd)}

    # The shopkeeper is behind the pictured counter, with only his upper body
    # visible. The player and departing customer stay on the same sidewalk.
    dealer = person(1150, 639, 'offer', clip_row=20, appearance=seller_look)
    antiques = shot('ActivityMumbaiChorStall', [person(612, 751), dealer],
                    .52, 560, 357)
    negotiation = shot('ActivityMumbaiChorStall', [person(932, 760, 'take'), dealer],
                       .62, 429, 382, prop='brass_thing', prop_holder=1)
    departing = shot('ActivityMumbaiChorStall', [person(596, 759, 'walk'),
        dealer | {'act': 'wave'}], .54, 534, 372)
    purchased = shot('ActivityMumbaiChorStall', [person(943, 767), dealer | {'act': 'stand'}],
                     .62, 429, 382, prop='brass_thing', prop_holder=0)
    stage['mumbai:chorbazaar'] = {'lane': beat(antiques, [antiques, negotiation]),
        'walked': beat(departing, [departing]), 'paid': beat(purchased), 'bought': beat(purchased)}

    hawker = person(639, 798, 'offer', appearance={'build': 'adult', 'wear': 'openshirt', 'cut': 'crop'})
    browsing = shot('MumbaiColaba', [person(430, 809, 'walk')], .36, 489, 386)
    bid = shot('MumbaiColaba', [person(438, 810), hawker], .34, 361, 440,
               prop='brass_thing', prop_holder=1)
    pause = bid | {'cast': [person(438, 810), hawker | {'act': 'count'}]}
    deal = bid | {'cast': [person(438, 810, 'take'), hawker | {'act': 'stand'}], 'prop_holder': 0}
    walking = shot('MumbaiColaba', [person(867, 810, 'walk'), hawker | {'act': 'wave'}],
                   .49, 439, 417)
    gateway = shot('ActivityMumbaiGateway', [person(708, 841), person(1005, 826, 'watch', z=.5)],
                   .5, 648, 324, full_plate=True)
    stage['mumbai:colaba'] = {'stall': beat(browsing, [browsing, bid]),
        'paid': beat(deal), 'four': beat(pause), 'two': beat(pause),
        'quiet': beat(pause), 'silence': beat(deal), 'walked': beat(walking),
        'deal': beat(deal), 'gone': beat(walking), 'arch': beat(gateway)}

    candle_seller = person(1391, 762, 'offer', clip_row=20,
        appearance={'build': 'adult', 'wear': 'sari', 'cut': 'tied', 'face': ''})
    arrival = shot('ActivityMumbaiMountMary', [person(753, 853, 'walk')],
                   .5, 648, 324, full_plate=True)
    candles = shot('ActivityMumbaiMountMary', [person(1187, 856), candle_seller],
                   .77, 410, 455, prop='wax_leg', prop_holder=1)
    observing = shot('ActivityMumbaiMountMary', [person(1116, 865), candle_seller,
        person(1535, 855, 'watch', appearance={'build': 'adult', 'wear': 'kurta', 'cut': 'crop'})],
        .77, 438, 439, prop='wax_leg', prop_holder=1)
    fitted = shot('ActivityMumbaiMountMary', [person(1187, 856, 'take'),
        candle_seller | {'act': 'stand'}], .77, 410, 455, prop='wax_leg', prop_holder=0)
    plain = fitted | {'prop': 'wax_candle'}
    sea = shot('ActivityMumbaiSeaWall', [person(725, 786), person(982, 777, 'watch', z=.5)],
               .5, 648, 324, full_plate=True)
    stage['mumbai:bandra'] = {'steps': beat(arrival, [arrival, candles]),
        'worked': beat(observing), 'fitted': beat(fitted), 'plain': beat(plain), 'wall': beat(sea)}

    garden = shot('ActivityMumbaiMuseumGarden', [person(751, 846, 'walk')],
                  .5, 648, 324, full_plate=True)
    # Actors stand in the central aisle or in front of the cases, never in
    # the glass cabinet's footprint. The clay models remain visibly miniature.
    guide = person(840, 817, 'point', appearance={'build': 'adult', 'wear': 'blazer', 'cut': 'bob'})
    models = shot('ActivityMumbaiMuseumHall', [person(663, 836), guide],
                  .5, 648, 324, full_plate=True)
    count = shot('ActivityMumbaiMuseumHall', [person(757, 849, 'watch'),
        person(944, 831, 'point', appearance={'build': 'elder', 'wear': 'kurta', 'cut': 'crop'})],
        .64, 512, 385)
    chimney = shot('MumbaiByculla', [person(1120, 845, 'look_up')],
                   .5, 648, 324, full_plate=True)
    stage['mumbai:byculla'] = {'gate': beat(garden, [garden, models]),
        'models': beat(models), 'count': beat(count), 'chimney': beat(chimney)}
    return plates, stage
