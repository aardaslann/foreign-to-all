"""Material and silhouette corrections authored from the finished Zürich art."""
from math import cos, sin, tau
from .shapes import point, rect, tube, object_, sign


def p(poly):
    return [point(x,y) for x,y in poly]


def cycle(name, wheels, radius, strokes):
    bottom=wheels[0][1]+radius
    polys=[]
    for x,y in wheels:
        for i in range(48):
            a,b=i*tau/48,(i+1)*tau/48
            polys.append([(x+radius*cos(a),y+radius*sin(a)),
                          (x+radius*cos(b),y+radius*sin(b)),
                          (x+(radius-5)*cos(b),y+(radius-5)*sin(b)),
                          (x+(radius-5)*cos(a),y+(radius-5)*sin(a))])
        for i in range(16):
            a=i*tau/16
            polys.append(tube((x,y),(x+(radius-5)*cos(a),y+(radius-5)*sin(a)),1.5))
        polys.append(rect(x-4,y-4,8,8))
    polys += [tube(a,b,w) for a,b,w in strokes]
    return object_(name,bottom,[(wheels[0][0]-radius,bottom-13,
                               wheels[1][0]-wheels[0][0]+2*radius,13)],polys)


def finish(rows):
    def obj(scene,name):
        return next(o for o in rows['Zurich'+scene]['objects'] if o['id']==name)
    # Columns sit behind the high station boards; a sampled column strip
    # must not redraw the unlettered source through the native lettering.
    o=obj('Transit','east_column')
    o['polygons']=[p(rect(1328,0,31,100)),p(rect(1328,279,31,367)),p(rect(1318,646,52,18))]
    # Small branches are part of the crown, as are leaves above the trunk.
    for row in rows.values():
        for o in row['objects']:
            if o.get('foliage'): o['wood_branches']=True
    obj('Niederdorf','cafe_tree')['foliage']=[p([
        [0,153],[88,153],[151,222],[177,297],[203,350],[204,409],
        [176,428],[151,454],[91,463],[0,439]])]
    # Fruit is opaque, with its complete coloured outline, not a green key.
    o=obj('Langstrasse','produce')
    o['foliage']=[p(rect(500,487,87,99))]
    o['polygons']=[p(rect(523,592,154,33)),p(rect(509,576,19,46)),p([
        [531,592],[531,570],[538,566],[538,557],[550,554],[556,548],
        [566,548],[566,556],[577,550],[585,550],[591,557],[602,550],
        [612,555],[621,547],[631,545],[638,538],[649,541],[653,547],
        [663,546],[670,552],[678,551],[684,560],[684,591]])]
    # Include the low shrubs rooted in each long planter.
    for name,bounds in [('west_tree',(0,551,164,67)),('bench_tree',(392,550,252,62)),
                        ('cafe_tree',(740,554,396,57))]:
        obj('Oerlikon',name)['foliage'].append(p(rect(*bounds)))
    for letter in rows['ZurichSeefeld']['lettering']:
        if letter['text']=='KIOSK': letter['object']='kiosk'
    # The branch tops and tyres are measured directly, not scaled from a
    # generic bicycle template. Every wheel centre and frame gap stays open.
    west=[cycle('bicycle_west',[(977,648),(1035,647)],28,[
        ((994,611),(1011,653),5),((1011,653),(977,648),5),
        ((994,611),(1035,606),5),((1035,606),(1011,653),5),
        ((1035,598),(1035,647),6),((1035,598),(1047,587),5),
        ((1047,587),(1063,587),6),((983,609),(1003,609),7)]),
        cycle('bicycle_east',[(1098,647),(1161,647)],29,[
        ((1097,602),(1128,647),5),((1128,647),(1161,647),5),
        ((1161,647),(1145,611),5),((1145,611),(1097,602),5),
        ((1145,611),(1128,647),5),((1097,602),(1098,647),6),
        ((1097,602),(1101,590),5),((1081,590),(1118,590),7),
        ((1145,611),(1150,593),6),((1137,591),(1165,591),8),
        ((1149,613),(1168,613),6)])]
    rows['ZurichWest']['objects']=[o for o in rows['ZurichWest']['objects'] if not o['id'].startswith('bicycle_')]+west
    cycles=[]
    for name,left,right in [('bike_west',215,274),('bike_east',332,391)]:
        cycles.append(cycle(name,[(left,661),(right,661)],27,[
            ((left,661),(left+14,620),6),((left+14,620),(left+32,659),5),
            ((left+32,659),(right,661),5),((right,661),(right-10,626),6),
            ((right-10,626),(left+14,620),5),((right-10,626),(left+32,659),5),
            ((left+14,620),(left+14,614),6),((left+4,613),(left+25,613),8),
            ((right-10,626),(right-10,618),5),((right-21,618),(right+8,618),7)]))
    rows['ZurichOerlikon']['objects']=[o for o in rows['ZurichOerlikon']['objects'] if not o['id'].startswith('bike_')]+cycles
    # Brass queue bases are considerably wider than the earlier rope helper.
    for name,xs,top,bottom in [('single_queue_post',[560],530,730),('queue',[1076,1333],542,742)]:
        o=obj('Exchange',name)
        o['polygons']=[]
        for x in xs:
            o['polygons'] += [p(rect(x-12,top+19,24,bottom-top-36)),p([
                [x-10,top],[x+9,top],[x+14,top+6],[x+14,top+17],[x+9,top+23],
                [x-10,top+23],[x-14,top+17],[x-14,top+7]]),p([
                [x-13,bottom-20],[x+13,bottom-20],[x+30,bottom-14],
                [x+34,bottom-7],[x+30,bottom],[x-30,bottom],[x-34,bottom-7],[x-30,bottom-14]])]
        if len(xs)>1:
            knots=[(xs[0]+14,top+27),(1133,578),(1207,582),(1280,579),(xs[1]-14,top+27)]
            o['polygons'] += [p(tube(a,b,8)) for a,b in zip(knots,knots[1:])]
        o['footprints']=[[*point(xs[0]-34,bottom-18),*point(xs[-1]-xs[0]+68,18)]]
    # Foliage above the clerk's counter planter must share the same depth.
    obj('Exchange','counter')['foliage']=[p(rect(920,410,82,49))]
    obj('Exchange','counter')['wood_branches']=True
    return rows
