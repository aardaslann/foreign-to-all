"""New York: complete object silhouettes and separate measured ground contact."""
import struct
from pathlib import Path
from .shapes import point, anchor, rect, tube, object_, sign
from .london import scene
from .moscow import pot, oval
from .seoul import box
from .paris import bollard
from .hanoi import route_post
from .rome import sizes


def midtown():
    obs=[pot('west_planter',(339,631,120,88),(332,561,134,76)),
         pot('east_planter',(1018,626,57,58),(1012,565,72,67)),
         bollard('west_safety_post',27,605,683,16),
         bollard('east_safety_post',1104,598,684,16),
         box('leasing_display',124,450,171,228),
         object_('cart_bin',746,[(1295,727,64,19)],[
             rect(1295,668,62,69),oval(1325,656,34,13),
             rect(1291,657,68,16),oval(1325,738,33,8)]),
         object_('food_cart',744,[(1362,722,235,22)],[
             [[1361,713],[1361,557],[1386,555],[1386,535],[1535,535],
              [1535,551],[1598,551],[1598,712],[1584,720],[1376,720]],
             rect(1348,553,19,104),rect(1349,541,11,15),
             rect(1567,537,18,15),rect(1385,714,156,13),
             oval(1408,730,16,15),oval(1515,730,16,15),
             rect(1579,711,7,27),rect(1573,734,20,6),
             rect(1417,513,9,26),
             [[1313,496],[1339,480],[1390,464],[1416,454],[1426,454],
              [1450,462],[1503,479],[1532,496],[1531,515],[1525,520],
              [1517,516],[1495,519],[1478,517],[1451,520],[1431,517],
              [1402,521],[1378,518],[1358,520],[1336,516],[1319,519],[1313,516]]]),
         object_('transit_post',749,[(1599,733,41,16)],[
             rect(1610,496,15,242),rect(1598,738,41,10),
             rect(1597,462,41,36),oval(1618,431,23,25)])]
    # The scaffold is a roof, braces and separate legs: no opaque rectangle
    # spanning the open walkway beneath it.
    scaffold=[rect(0,258,1092,105),rect(0,355,1090,19)]
    for x in [96,312,502,1007]:
        scaffold += [rect(x-11,365,23,372),rect(x-20,734,40,10),
                     tube((x-33,372),(x-6,404),9),tube((x+34,372),(x+7,404),9)]
    scaffold += [rect(0,426,568,11),rect(931,426,152,11)]
    obs.append(object_('scaffold_front',744,
        [(x-20,729,40,15) for x in [96,312,502,1007]],scaffold))
    obs.append(object_('scaffold_rear_west',682,[(49,666,26,16)],[rect(53,382,16,294)]))
    return scene('NewYorkMidtown',665,(670,823),obs,{
        'HotelDoor':anchor(754,717),'ExchangeDoor':anchor(1215,717),
        'TransitDoor':anchor(1583,807),'LocalSpot':anchor(457,814),
        'NpcMarisol':anchor(872,820),'ExitEast':anchor(1618,868)},[
        sign((651,285,214,49),'MIDTOWN HOTEL','#183b32','#eedfb4',size=26,object='scaffold_front'),
        sign((1143,432,146,29),'CURRENCY EXCHANGE','#00000000','#2b3a42',size=12),
        sign((143,468,132,114),'OFFICES\nRETAIL\nLEASING','#152731',size=18,object='leasing_display'),
        sign((1594,406,49,50),'M','#254d3b',size=29,object='transit_post'),
        sign((1599,470,36,23),'SUBWAY','#e7e5d7','#263741',size=6,object='transit_post')],
        interaction_sizes=sizes('HotelDoor','ExchangeDoor','TransitDoor','LocalSpot'),
        prompt_overrides={'TransitDoor':'E — Walk to the subway'})


def build():
    from .prepared import world_build
    rows=world_build('newyork')
    for suffix,fn in [('Midtown',midtown)]:
        key='NewYork'+suffix
        file=Path(__file__).resolve().parents[2]/f'art/environments/scenes/{key}-retro.png'
        if not file.exists(): continue
        row=fn()
        row.update(source=[0,0,*struct.unpack('>II',file.read_bytes()[16:24])],
            implementation_stage='replacement_art_and_geometry',art_pending=False,
            signs=[],room_numbers=[],cats=[])
        rows[key]=row
    return rows
