"""Measured Dakar replacement art, full depth silhouettes and native labels."""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, tube, object_, sign
from .moscow import pot, oval, board
from .hanoi import pole


def replace(row, name, obj):
    index = next(i for i, old in enumerate(row['objects']) if old['id'] == name)
    row['objects'][index] = obj


def finish(rows):
    for suffix, fn in [('Medina', medina), ('Sandaga', sandaga), ('Plateau', plateau),
                       ('Ouakam', ouakam), ('Yoff', yoff), ('Hotel', hotel),
                       ('Exchange', exchange), ('Transit', transit), ('Airport', airport)]:
        row = rows['Dakar' + suffix]
        row.update(texture=f'res://art/environments/scenes/Dakar{suffix}-retro.png',
                   pixel_art=True, art_pending=False,
                   implementation_stage='replacement_art_and_geometry')
        file = Path(__file__).resolve().parents[2] / row['texture'].removeprefix('res://')
        row['source'] = [0, 0, *struct.unpack('>II', file.read_bytes()[16:24])]
        fn(row)
    return rows


def medina(row):
    replace(row, 'west_tree', object_('west_tree', 668, [(0,640,120,28)], [
        rect(0,602,120,66), [[13,604],[17,452],[0,423],[0,380],[22,414],
        [16,334],[27,331],[38,400],[49,368],[62,370],[50,422],[65,406],
        [83,371],[100,348],[111,356],[93,394],[64,444],[48,604]]],
        foliage=[rect(0,54,219,350)], wood_branches=True))
    replace(row, 'tailor_tree', pot('tailor_tree',(424,574,68,79),(389,410,189,166),[
        tube((452,575),(451,515),12), tube((454,566),(496,508),9),
        tube((451,543),(423,518),8)]))
    table = next(o for o in row['objects'] if o['id']=='sewing_table')
    table['polygons'] += [[point(x,y) for x,y in rect(767,521,36,16)]]
    row['lettering'] = [
        sign((236,377,139,23),'HÔTEL','#00000000',size=16),
        sign((1174,389,89,18),'CHANGE','#e6d3a3','#343b36',size=12),
        sign((1485,371,139,19),'TRANSPORT','#00000000',size=14),
        sign((492,551,68,96),'COUTURE\nSUR\nMESURE','#00000000',size=11,object='west_tailor_board'),
        sign((994,563,54,80),'TISSUS\nWAX','#00000000',size=11,object='east_tailor_board')]
    row['animation_patches'] = [dict(kind='laundry',rect=[*point(344,112),*point(25,49)])]


def sandaga(row):
    for name,x,y,w,h in [('west_entrance_basket',644,575,38,48),('east_entrance_basket',1003,579,27,44)]:
        row['objects'].append(object_(name,y+h,[(x+2,y+h-14,w-4,14)],[
            [[x,y+3],[x+3,y],[x+w-3,y],[x+w,y+3],[x+w-2,y+h],[x+2,y+h]]]))
    row['lettering'][0]['background']='#00000000'


def plateau(row):
    replace(row,'west_tree',pot('west_tree',(39,637,65,31),(0,321,202,192),[
        [[54,638],[55,522],[36,491],[31,463],[41,452],[47,477],[63,490],
         [59,450],[69,442],[77,480],[103,451],[112,456],[99,484],[78,518],[80,637]]]))
    replace(row,'middle_tree',pot('middle_tree',(695,608,75,61),(619,286,224,172),[
        [[718,608],[718,485],[698,463],[687,425],[695,421],[708,451],[723,464],
         [722,420],[735,418],[739,469],[756,451],[766,420],[778,424],
         [768,462],[744,485],[745,608]]]))
    replace(row,'middle_palm',pot('middle_palm',(1071,607,73,61),(989,236,224,209),[
        [[1090,607],[1090,441],[1074,411],[1083,402],[1094,417],[1090,371],
         [1106,363],[1116,406],[1128,391],[1136,396],[1123,429],[1120,607]]]))
    replace(row,'east_palm',pot('east_palm',(1607,637,46,31),(1510,227,162,209),[
        [[1606,637],[1610,438],[1597,411],[1606,402],[1616,416],[1616,367],
         [1631,367],[1637,406],[1650,393],[1658,402],[1640,438],[1640,637]]]))
    replace(row,'cafe_menu',board('cafe_menu',515,568,75,102))
    row['lettering'] = [
        sign((1194,431,218,32),'PRESSE','#00000000',size=26,object='news_kiosk'),
        sign((527,582,45,60),'CAFÉ\nTHÉ\nJUS','#00000000',size=10,object='cafe_menu')]


def ouakam(row):
    replace(row,'door_pot',pot('door_pot',(152,614,34,37),(144,591,46,32)))
    # The complete visible net coil is traced as rings, preserving its holes.
    row['lettering']=[sign((15,408,102,17),'TRANSPORT','#00000000',size=11)]


def yoff(row):
    net=next(o for o in row['objects'] if o['id']=='hanging_fishing_net')
    net['polygons'] += [[point(x,y) for x,y in oval(cx,cy,6,8)]
                        for cx,cy in [(539,480),(554,495),(641,495),(666,481),(700,451)]]
    awning=next(o for o in row['objects'] if o['id']=='blue_beach_awning')
    awning['polygons'] += [[point(x,y) for x,y in tube(a,b,5)] for a,b in [
        ((1144,343),(1134,382)),((1134,382),(1129,412)),
        ((1550,376),(1527,429)),((1527,429),(1509,459))]]


def hotel(row):
    row['clerks']['Point']=anchor(1130,487)
    row['lettering']=[sign((1043,219,250,48),'HÔTEL DE LA MÉDINA','#00000000','#463b2f',size=23)]
    replace(row,'reception_counter',object_('reception_counter',617,[(900,590,449,27)],[
        rect(895,461,462,17),rect(904,478,446,137),rect(933,438,45,23),
        [[1260,416],[1272,375],[1305,375],[1325,416]],rect(1288,416,10,32),
        oval(1293,446,15,14),rect(1228,441,29,20)],foliage=[rect(1224,425,32,21)]))
    # Open weaving is extracted by color, so it cannot erase a rectangular
    # patch of the player's head behind a chair back.
    for name,x in [('west_lobby_chair',325),('east_lobby_chair',477)]:
        replace(row,name,object_(name,616,[(x+3,593,135,23)],[
            rect(x+21,478,114,10),rect(x+22,488,10,69),rect(x+122,487,11,69),
            rect(x,525,139,11),rect(x+13,554,119,13),rect(x+7,536,11,79),
            rect(x+124,536,11,79),rect(x+18,587,104,9)],
            foliage=[rect(x+32,490,88,63)],wood_branches=True))


def exchange(row):
    row['clerks']['Point']=anchor(800,505)
    row['lettering']=[
        sign((574,189,449,59),'BUREAU DE CHANGE','#00000000',size=34),
        sign((1115,213,184,184),'DEVISES\nUSD · EUR\nGBP · XOF\nCHANGE','#00000000','#ecd05a',size=24)]
    counter=next(o for o in row['objects'] if o['id']=='exchange_counter')
    counter['polygons'] += [[point(x,y) for x,y in rect(901,450,31,26)]]
    replace(row,'waiting_seats',object_('waiting_seats',655,[(1173,636,352,19)],
        [rect(1171,602,355,11),rect(1173,555,12,98),rect(1512,555,12,98),
         *[rect(x,497,79,79) for x in [1183,1267,1350,1435]],
         *[rect(x,589,79,13) for x in [1183,1267,1350,1435]]]))


def transit(row):
    # Information kiosk is in front of the bus, but both leave the actual
    # boarding door and the passage behind the seating available.
    replace(row,'bus_body',object_('bus_body',543,[(463,523,1120,20)],[
        rect(462,337,1122,203),rect(957,308,65,28),rect(1067,308,150,28)]))
    replace(row,'ticket_machine',object_('ticket_machine',655,[(1444,632,108,23)],[
        rect(1444,391,109,264)]))
    replace(row,'ticket_office',object_('ticket_office',650,[(884,625,369,25)],[
        rect(869,326,397,38),rect(883,518,375,17),rect(890,535,359,106),
        rect(883,363,17,156),rect(1240,363,13,155),rect(1012,374,12,144),
        rect(1155,374,13,144),rect(1053,483,77,35),rect(911,386,49,130),
        rect(1195,467,27,51),rect(986,496,12,21),oval(994,488,8,8)],
        glass=[rect(900,375,112,143),rect(1025,375,130,143),rect(1169,375,70,143)]))
    row['lettering']=[
        sign((324,187,421,54),'DAKAR · GARE ROUTIÈRE','#00000000',size=30),
        sign((879,182,426,72),'MÉDINA → SANDAGA → PLATEAU\nOUAKAM → YOFF','#00000000','#354a52',size=23),
        sign((1410,177,139,104),'BUS\nDÉPARTS\nQUAI 1','#00000000','#efd065',size=18),
        sign((889,332,353,23),'INFORMATIONS','#00000000',size=20,object='ticket_office'),
        sign((1462,399,72,13),'BILLETS','#00000000',size=10,object='ticket_machine')]
    row['motion_layers']=[dict(kind='doors',rect=[*point(784,371),*point(60,161)])]


def airport(row):
    row['clerks']['Point']=anchor(1191,609)
    row['lettering']=[
        sign((667,188,431,54),'AÉROPORT BLAISE DIAGNE','#00000000',size=29),
        sign((1168,250,448,30),'DESTINATION           DÉPART     PORTE','#00000000','#edcf57',size=19),
        sign((1175,280,437,26),'PARIS                   14:30       01','#00000000',size=18),
        sign((1175,309,437,26),'LONDRES                 15:10       02','#00000000',size=18),
        sign((1175,338,437,26),'ROME                    16:00       03','#00000000',size=18),
        sign((1175,366,437,26),'ENREGISTREMENT OUVERT','#00000000','#edcf57',size=18),
        *[sign((x+10,472,93,35),f'0{i+1}','#00000000',size=24,object=f'checkin_terminal_{i}')
          for i,x in enumerate([1051,1250,1450])]]
