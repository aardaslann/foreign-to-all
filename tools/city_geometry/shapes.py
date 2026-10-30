"""Geometry helpers only: every position is measured against a scene's artwork.

Coordinates use the 1672 x 941 reference canvas, independently of texture size.
Opaque silhouettes, ground footprints and glass remain separate.
"""
from math import hypot

SX, SY = 1152 / 1672, 648 / 941


def point(x, y):
    return [round(x * SX, 2), round(y * SY, 2)]


def rect(x, y, w, h):
    return [[x, y], [x+w, y], [x+w, y+h], [x, y+h]]


def tube(a, b, width):
    dx, dy = b[0]-a[0], b[1]-a[1]
    length = hypot(dx, dy)
    if not length:
        raise ValueError('A silhouette stroke needs two different endpoints')
    ox, oy = -dy*width/(2*length), dx*width/(2*length)
    return [[a[0]+ox, a[1]+oy], [b[0]+ox, b[1]+oy],
            [b[0]-ox, b[1]-oy], [a[0]-ox, a[1]-oy]]


def object_(name, depth, footprints, polygons=(), foliage=(), glass=(), **extra):
    result = dict(id=name, sort_y=round(depth*SY, 2),
                  footprints=[[round(x*SX, 2), round(y*SY, 2),
                               round(w*SX, 2), round(h*SY, 2)]
                              for x, y, w, h in footprints],
                  polygons=[[point(x, y) for x, y in poly] for poly in polygons])
    for key, value in [('foliage', foliage), ('glass', glass)]:
        if value:
            result[key] = [[point(x, y) for x, y in poly] for poly in value]
    result.update(extra)
    return result


def sign(bounds, text, background, ink='#f1eddf', size=18, **extra):
    x, y, w, h = bounds
    return dict(rect=[*point(x, y), *point(w, h)], text=text,
                background=background, ink=ink, size=size, **extra)


def anchor(x, y):
    return point(x, y)
