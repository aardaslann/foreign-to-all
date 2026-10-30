"""New York encounters on installed art; retain original choices and rewards."""
from .london_activities import actor, shot, beat


def person(x, y, act='watch', **extra):
    return actor(x, y, act, **(dict(world_height=94, appearance={}, z=y/1000) | extra))


def build():
    # This existing world plate includes its native lettering. All feet stay
    # on the pavement, ahead of scaffold posts and clear of the food cart.
    commuter_look = {'build': 'adult', 'wear': 'jacket', 'cut': 'crop', 'face': ''}
    commuter = person(865, 752, appearance=commuter_look)
    player = person(674, 752)
    skyline = shot('NewYorkMidtown', [player | {'act': 'look_up'}],
                   .5, 648, 324, full_plate=True)
    passing = shot('NewYorkMidtown', [player | {'act': 'look_up'},
        person(936, 750, 'walk', appearance=commuter_look),
        person(1179, 750, 'walk', appearance={'build': 'adult', 'wear': 'shirt',
                                            'cut': 'bob', 'face': ''})],
        .55, 450, 407)
    asking = shot('NewYorkMidtown', [player, commuter | {'act': 'point'}],
                  .47, 316, 411)
    # Departing actors start at their conversation marks and leave once.
    # A separate action avoids replaying the normal walking-in animation.
    went = asking | {'cast': [player | {'act': 'walk_away'}, commuter]}
    finished = asking | {'cast': [player | {'act': 'point'}, commuter]}
    thanked = asking | {'cast': [player | {'act': 'wave'},
                                 commuter | {'act': 'walk_away'}]}
    stage = {'newyork:midtown': {
        'corner': beat(asking, [skyline, passing, asking], choices={
            'go': {'staging': went},
            'finish': {'staging': finished},
            'thanks': {'staging': thanked}}),
        'went': beat(went),
        'finished': beat(finished),
        'thanked': beat(thanked)}}
    from .prepared import activity_build
    plates, pending = activity_build('newyork')
    stage.update(pending)
    return plates, stage
