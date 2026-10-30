"""Final Toronto activity measurements; keep masonry and furniture stationary."""
from .shapes import point, sign, object_, rect


def water(x,y,w,h):
    return dict(kind='water',rect=[*point(x,y),*point(w,h)])


def apply(plates):
    plates['ActivityTorontoBluffsTop']['lettering']=[
        sign((1080,623,125,30),'STAY ON\nMARKED PATHS','#00000000','#3b4245',size=11)]
    plates['ActivityTorontoBluffsTop']['animation_patches']=[
        water(1130,353,415,123),water(985,466,411,70)]
    plates['ActivityTorontoBluffsBeach']['animation_patches']=[
        water(990,516,673,113),water(1411,643,255,83)]
    # Foreground grab poles retain their complete silhouette over seated
    # passengers. Never sample the windows or aisle as an opaque rectangle.
    plates['ActivityTorontoStreetcarInterior']['activity_occluders']=[
        object_('grab_poles',750,[],[rect(443,0,21,750),rect(1237,0,21,750)])]
    return plates
