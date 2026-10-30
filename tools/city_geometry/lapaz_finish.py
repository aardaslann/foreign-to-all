"""Measured replacement artwork, service positions and local detail for La Paz."""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, object_, sign
from .moscow import pot, oval
from .dakar_finish import replace
from .honolulu import metal_seats


def finish(rows):
    for suffix,fn in [('ElAlto',elalto),('Rodriguez',rodriguez),('Sopocachi',sopocachi),
                      ('SanPedro',sanpedro),('Irpavi',irpavi),('Hotel',hotel),
                      ('Exchange',exchange),('Transit',transit),('Airport',airport)]:
        row=rows['LaPaz'+suffix]
        row.update(texture=f'res://art/environments/scenes/LaPaz{suffix}-retro.png',
                   pixel_art=True,art_pending=False,implementation_stage='replacement_art_and_geometry')
        file=Path(__file__).resolve().parents[2]/row['texture'].removeprefix('res://')
        row['source']=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])]
        fn(row)
    return rows


def elalto(row):
    # The exchange plant bends left; both its stem and leaf crown belong to it.
    replace(row,'change_door_plant',pot('change_door_plant',(670,670,32,14),
        (637,562,64,76),[rect(681,623,8,49)]))
    row['lettering']=[
        sign((167,435,267,50),'ALOJAMIENTO','#00000000',size=30),
        sign((617,435,263,50),'CAMBIO','#00000000',size=35),
        sign((1171,435,307,50),'TELEFÉRICO','#00000000',size=32),
        sign((498,621,42,28),'HAY\nCUARTOS','#e4e1ce','#324655',size=7,object='lodging_notice')]


def rodriguez(row):
    # Fruit outlines are preserved. Hands and bodies may appear through the
    # open frame above produce, never through its real counter or post bases.
    row['lettering']=[]


def sopocachi(row):
    row['lettering']=[
        sign((1203,391,315,51),'CAFÉ','#00000000',size=39),
        sign((1144,604,51,67),'CAFÉ\nTÉ\nJUGOS','#1b292d',size=10,object='cafe_menu')]
    plant=next(o for o in row['objects'] if o['id']=='cafe_flower_box')
    plant['foliage']=[[point(x,y) for x,y in rect(1427,536,158,112)]]


def sanpedro(row):
    # Include low leaves and branches through to the trunk. The background
    # church tree remains part of the architecture, not the foreground trees.
    for name,bounds in [('plaza_west_tree',(483,291,278,229)),
                        ('plaza_middle_tree',(718,346,190,213)),
                        ('station_tree',(1174,331,214,224))]:
        obj=next(o for o in row['objects'] if o['id']==name)
        obj['foliage']=[[point(x,y) for x,y in rect(*bounds)]]
    row['lettering']=[
        sign((1389,437,260,44),'TELEFÉRICO','#00000000',size=28),
        sign((309,480,156,35),'PLAZA SAN PEDRO','#343952',size=16),
        *[sign((x,568,w,45),text,'#00000000','#5f3428',size=size,object='plaza_food_stall')
          for x,w,text,size in [(995,32,'API',13),(1038,29,'TÉ',13),
                                 (1075,29,'PAN',12),(1113,26,'API',12),(1150,58,'SALTEÑAS',10)]]]


def irpavi(row):
    tree=next(o for o in row['objects'] if o['id']=='front_tree')
    tree['foliage']=[[point(x,y) for x,y in rect(327,315,288,292)]]
    row['lettering']=[sign((1300,450,251,45),'TIENDA','#00000000',size=34)]


def hotel(row):
    row['clerks']['Point']=anchor(824,498)
    row['lettering']=[sign((715,210,244,57),'ALOJAMIENTO','#00000000','#342f31',size=29)]
    # New coffee table is six pixels wider to the left; its entire surface,
    # small plant and mug sort together, with space visible between the legs.
    replace(row,'front_coffee_table',object_('front_coffee_table',742,[(311,723,147,19)],[
        rect(309,677,150,21),rect(317,699,13,41),rect(442,699,11,41),
        rect(330,701,112,11),rect(346,657,51,27),rect(410,661,19,20)],
        foliage=[rect(332,616,71,43)],wood_branches=True))


def exchange(row):
    row['clerks']['Point']=anchor(840,495)
    row['anchors']['Point']=anchor(646,648)
    row['lettering']=[
        sign((737,160,239,64),'CAMBIO','#00000000',size=39),
        sign((317,255,204,194),'DIVISAS\nDÓLAR · EURO\nREAL · PESO\nSOL','#1a2531',size=23),
        sign((1382,403,136,39),'BOLIVIA','#00000000','#233543',size=27)]


def transit(row):
    replace(row,'station_seats',metal_seats('station_seats',26,607,4,78,127,66,75,15))
    replace(row,'station_bin',object_('station_bin',731,[(390,713,62,18)],[rect(390,628,62,103)]))
    replace(row,'ticket_machine',object_('ticket_machine',692,[(1110,674,84,18)],[
        rect(1110,488,84,204)]))
    for i,x in enumerate([558,703,845]):
        replace(row,'gate_reader_'+str(i),object_('gate_reader_'+str(i),690,
            [(x,672,57,18)],[rect(x,544,57,146)]))
    # Full pictured panes, including their very narrow metal frames. Using
    # only the right half of a pane left an invisible passage through glass.
    for i,(x,w) in enumerate([(514,44),(620,82),(762,83)]):
        replace(row,'gate_glass_'+str(i),object_('gate_glass_'+str(i),690,
            [(x,672,w,18)],[rect(x,576,w,3),rect(x,651,w,3),rect(x,579,3,72),
                          rect(x+w-3,579,3,72)],glass=[rect(x+3,579,w-6,72)]))
    replace(row,'east_gate_glass',object_('east_gate_glass',690,[(902,672,47,18)],[
        rect(902,576,47,3),rect(902,651,47,3),rect(946,579,3,75)],
        glass=[rect(902,579,44,72)]))
    row['anchors']['Platform']=anchor(652,737)
    row['anchors']['Machine']=anchor(1146,742)
    row['lettering']=[sign((451,166,368,73),'MI TELEFÉRICO','#00000000',size=32)]
    row['animation_patches']=[
        dict(kind='rotor_marks',rect=[*point(1202,190),*point(346,51)],speed=.7),
        dict(kind='rotor_marks',rect=[*point(1128,114),*point(37,39)],speed=1.4),
        dict(kind='rotor_marks',rect=[*point(1203,117),*point(34,37)],speed=1.4)]


def airport(row):
    row['lettering']=[
        sign((477,123,527,78),'AEROPUERTO INTERNACIONAL\nEL ALTO','#00000000',size=28),
        sign((1090,144,213,63),'LLEGADAS','#00000000',size=28),
        sign((1380,139,239,257),'SALIDAS\n\nSANTA CRUZ   12:20\nCOCHABAMBA 13:10\nLIMA             14:40\nBOGOTÁ         16:00','#00000000','#ebd260',size=18)]
    belt=next(o for o in row['objects'] if o['id']=='baggage_belt')
    # Ground contact is the plinth, not the projected top surface.
    belt['footprints']=[[*point(600,783),*point(594,20)]]
