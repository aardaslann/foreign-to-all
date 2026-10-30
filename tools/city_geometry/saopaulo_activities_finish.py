"""Furniture edges and text measured on the eight final activity images."""
from .shapes import point, rect, sign, object_


def apply(plates):
    feira=plates['ActivitySaoPauloFeira']
    feira['lettering']=[
        sign((186,359,205,53),'LIVROS','#00000000','#363237',size=26),
        sign((620,355,227,55),'FEIRA DA LIBERDADE','#00000000','#363237',size=19),
        sign((1140,372,380,42),'PASTEL DA FEIRA','#00000000','#363237',size=26)]
    feira['animation_patches']=[dict(kind='steam',rect=[*point(1215,539),*point(29,61)])]
    plates['ActivitySaoPauloCantina']['activity_occluders']=[
        object_('shared_table',767,[],[
            [[622,569],[663,560],[1220,560],[1259,574],[1249,694],
             [1218,700],[664,697],[630,683]],
            rect(650,687,20,77),rect(1207,687,21,79)])]
    plates['ActivitySaoPauloMarketHall']['lettering']=[
        sign((100,362,307,48),'FRUTAS DA ESTAÇÃO','#00000000','#f1e5c9',size=23),
        sign((1264,362,305,49),'MERCADO MUNICIPAL','#00000000','#f1e5c9',size=24)]
    plates['ActivitySaoPauloSandwich']['lettering']=[
        sign((920,139,575,70),'SANDUÍCHE DE MORTADELA','#00000000','#25443c',size=33)]
    plates['ActivitySaoPauloVao']['lettering']=[
        sign((1041,686,50,80),'CAFÉ\nCOADO','#00000000','#ead8b0',size=10)]
    plates['ActivitySaoPauloMASPGallery']['lettering']=[
        sign((441,532,26,17),'ACERVO','#f0e8dc','#353436',size=7),
        sign((1454,533,30,18),'ACERVO','#f0e8dc','#353436',size=7)]
    # One compact native inscription fits the blank painted band. The rest
    # remains textured charcoal wall, not generated pseudo-writing.
    plates['ActivitySaoPauloMuralAlley']['lettering']=[
        sign((397,70,280,55),'ZONA LIVRE','#00000000','#b4b0a3',size=30)]
