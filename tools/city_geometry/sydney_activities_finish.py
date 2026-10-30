"""Final Sydney activity text, water and furniture measured on installed art."""
from .shapes import point, rect, sign, object_


def water(x,y,w,h):
    return dict(kind='water',rect=[*point(x,y),*point(w,h)])


def apply(plates):
    # Window frames and seats stay fixed; only the water beyond each pane moves.
    plates['ActivitySydneyFerryDeck']['animation_patches']=[
        water(0,387,77,64),water(164,387,39,65),water(259,386,191,56),
        water(539,388,594,70),water(1224,390,278,55),water(1577,387,94,57)]
    plates['ActivitySydneyMartinPlace']['lettering']=[
        sign((668,515,333,40),'TO OUR GLORIOUS DEAD','#00000000','#756959',size=22)]
    plates['ActivitySydneyNewtownPub']['lettering']=[
        sign((1127,106,237,46),'LIVE MUSIC','#00000000','#d4c19b',size=23)]
    plates['ActivitySydneyNewtownMural']['lettering']=[
        sign((1060,641,443,45),'I HAVE A DREAM','#00000000','#29303b',size=30)]
    # Each patch excludes the static poles and the sand. Swimmer marks are
    # waterlines, not foot positions on a transparent rectangle.
    plates['ActivitySydneyBondiSurf']['animation_patches']=[
        water(7,397,418,121),water(443,443,763,161),water(1280,385,391,217)]
    plates['ActivitySydneyBondiPool']['animation_patches']=[
        water(290,409,1094,26),water(280,450,1110,24),water(260,509,1140,22),
        water(242,569,1179,31)]
    bakery=plates['ActivitySydneyCabramattaBakery']
    bakery['lettering']=[sign((512,165,764,72),'BÁNH MÌ · BAKERY','#00000000','#2a5448',size=39)]
    # Individual queue ropes and poles. No rectangular background cut-outs.
    bakery['activity_occluders']=[object_('bakery_queue',767,[],[
        rect(341,625,415,14),rect(341,617,15,140),rect(325,752, 40,15),
        rect(750,618,16,137),rect(734,752,48,15),rect(766,625,156,13),
        rect(920,617,15,137),rect(905,746,43,15),
        rect(459,597,630,15),rect(454,593,15,122),rect(441,712,41,12),
        rect(613,592,14,125),rect(597,713,43,12),rect(870,594,12,123),
        rect(856,712,42,13),rect(1084,592,17,125),rect(1066,711,47,14)])]
    return plates
