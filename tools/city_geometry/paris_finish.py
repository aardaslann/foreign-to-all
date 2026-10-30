"""Corrections from the 1152 x 648 runtime silhouette contact sheets.

These points are already in world coordinates, so narrow rail gaps and the
true outer edges can be measured without a second reference-scale conversion.
"""
from .shapes import rect, anchor


def obj(name, depth, footprints, polygons, **extra):
    return dict(id=name, sort_y=depth, footprints=footprints, polygons=polygons) | extra


def replace(row, spec):
    row['objects'] = [spec if old['id'] == spec['id'] else old for old in row['objects']]


def street_posts(row, xs, top, bottom, rounded=True):
    row['objects'] = [old for old in row['objects'] if not old['id'].startswith('bollard_')]
    for i,x in enumerate(xs):
        if rounded:
            outline=[[x-3,top],[x+3,top],[x+5,top+3],[x+5,top+7],
                     [x+3,top+9],[x+3,bottom-3],[x+7,bottom-3],[x+7,bottom],
                     [x-7,bottom],[x-7,bottom-3],[x-3,bottom-3],[x-3,top+9],
                     [x-5,top+7],[x-5,top+3]]
        else:
            outline=[[x-6,top],[x+6,top],[x+6,bottom-2],[x+7,bottom-2],
                     [x+7,bottom],[x-7,bottom],[x-7,bottom-2],[x-6,bottom-2]]
        row['objects'].append(obj('bollard_'+str(i),bottom,[[x-7,bottom-9,14,9]],[outline]))


def finish(rows):
    marais=rows['ParisMarais']
    street_posts(marais,[12,135,244,437,636,754,804,927,1099],480,515)
    # A short Metro fascia must still be legible at the game's real scale.
    marais['lettering'][0].update(size=9)

    mont=rows['ParisMontmartre']
    for old in mont['objects']:
        if old['id']=='grocer_plant':
            old['foliage']=[[[405,375],[420,383],[434,400],[435,423],
                             [426,438],[399,438],[389,424],[391,400],[400,395]]]
        elif old['id']=='west_tree':
            # Exclude trailing ivy hanging from the wall above this tree.
            old['foliage']=[rect(7,274,70,118)]

    belle=rows['ParisBelleville']
    street_posts(belle,[44,220,508,626,734,817,939,1107],479,515)
    for old in belle['objects']:
        if old['id']=='flower_planter':
            # Orange flowers are opaque too; the shop frame is outside the mask.
            old['foliage']=[]
            old['polygons'] += [[[527,403],[535,405],[540,416],[549,413],
                                 [558,422],[555,434],[561,441],[553,451],
                                 [515,452],[506,444],[509,435],[505,425],
                                 [514,422],[515,412],[524,414]]]

    champ=rows['ParisChampDeMars']
    street_posts(champ,[70,199,305,412,757,899,981,1092],497,536,False)
    champ['anchors']['ExchangeDoor']=anchor(1603,704)
    champ['animation_patches']=[]
    for old in champ['objects']:
        if old['id']=='drinking_fountain':
            old['water']=dict(kind='drinking',at=[587,435],height=34)
    # The foreground contains the metal fence, not the distant shrubs visible
    # between its rails. Keep each post and rail as an independent silhouette.
    for side,x0,x1,pier in [('west',145,488,386),('east',684,881,785)]:
        key='park_fence_'+side
        old=next(o for o in champ['objects'] if o['id']==key)
        old.pop('foliage',None)
        old.pop('painted_metal',None)
        stone=[p for p in old['polygons']]
        for y in [357,375,402]: stone.append(rect(x0,y,x1-x0,4))
        posts=list(range(x0+3,x1,15))
        for x in posts:
            if abs(x-pier)<25: continue
            stone += [rect(x-2,351,4,66),[[x-3,350],[x,344],[x+3,350],[x+3,355],[x-3,355]]]
        old['polygons']=stone
    # Metro jambs include the complete curled posts beside the stairs.
    replace(champ,obj('metro_west_jamb',461,[[875,449,13,12]],
        [rect(878,353,7,105),rect(875,457,13,4),rect(876,346,11,8),
         [[878,346],[878,341],[884,340],[888,346],[888,353],[878,353]]]))
    replace(champ,obj('metro_east_jamb',461,[[1032,449,12,12]],
        [rect(1035,355,6,103),rect(1032,457,12,4)]))

    defense=rows['ParisLaDefense']
    street_posts(defense,[244,385,552,735,999,1095],497,536,False)

    airport=rows['ParisAirport']
    airport['objects']=[o for o in airport['objects'] if not o['id'].startswith('seat_')]
    for i,x in enumerate([-11,41,93,145,197,249]):
        airport['objects'].append(obj('seat_'+str(i),479,[[x+22,468,18,11]],
            [[[x+7,399],[x+48,399],[x+53,406],[x+53,443],
              [x+57,448],[x+57,454],[x-2,454],[x-2,448],[x+3,443],[x+3,405]],
             rect(x+25,455,9,18),rect(x+19,473,21,6),rect(x+55,432,5,16)]))
    # Complete curved trolley handles and side panels, with open air only in
    # the narrow space between the carts, rather than missing handle tops.
    polys=[rect(1024,527,128,9)]
    for x in [1031,1062,1093,1124]:
        polys += [[[x,528],[x,480],[x+4,469],[x+13,464],[x+27,464],
                   [x+27,471],[x+16,471],[x+8,480],[x+8,528]],rect(x+10,482,20,45)]
    for x in [1030,1060,1091,1122,1152]:
        polys.append([[x-6,536],[x+6,536],[x+9,540],[x+9,547],
                      [x+5,551],[x-5,551],[x-9,547],[x-9,540]])
    replace(airport,obj('trolleys',552,[[1022,532,130,20]],polys))
    # A counter hides the lower torso; its staff remain visible above the slab.
    for scene, service, x, y in [('ParisHotel','Point',851,467),
                                 ('ParisExchange','Point',881,479),
                                 ('ParisAirport','Point',1196,612)]:
        rows[scene]['clerks'][service]=anchor(x,y)
    next(o for o in airport['objects'] if o['id']=='carousel')['animation_patches']=airport['animation_patches']
    return rows
