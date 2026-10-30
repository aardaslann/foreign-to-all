"""Exact text and inset fascia coordinates for the Berlin/Istanbul art.

Coordinates are source pixels. This writes layout data, never painted images.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
DATA={}
def sign(scene,text,r,bg='#173649',ink='#f3ecd9',size=32,object_='',border=False):
    x,y,w,h=r
    DATA.setdefault(scene,{'lettering':[]})['lettering'].append(dict(text=text,
        rect=[round(x*1152/1672,2),round(y*648/941,2),round(w*1152/1672,2),round(h*648/941,2)],
        background=bg,ink=ink,size=round(size*1152/1672),object=object_,border=border))

sign('Mitte','SPÄTI',(112,434,312,48),'#343b43',size=40)
sign('Mitte','HOTEL',(528,222,129,27),'#383937','#ead099',25)
sign('Mitte','CAFÉ',(814,435,111,49),'#aa9474','#292d2d',29)
sign('Mitte','WECHSELSTUBE',(1354,446,221,35),'#292f34',size=25)
sign('Mitte','HOTEL\nEMPFANG\nZIMMER\n→',(449,512,34,74),'#e5d4aa','#252d2c',10)
sign('Mitte','LIVE\nIM KIEZ\nFR · 20 UHR',(1029,545,49,54),'#1f6190','#f1e7cb',13,'shelter')
sign('Mitte','FAHRPLAN\nBUS 100\n10 · 30 · 50\nBUS 200\n05 · 25 · 45',(1200,528,53,94),'#ddd5a8','#284048',11,'shelter')
sign('Mitte','EUR  1,00\nUSD  1,09\nGBP  0,86\nCHF  0,94',(1396,517,54,80),'#172c36','#d5e2da',12)
sign('Mitte','CURRENCY\nEXCHANGE\nDÖVİZ\nCHANGE',(1533,519,46,73),'#e9dfc3','#202d35',10)
sign('MitteOst','POLIZEI',(806,362,213,46),'#f2e2bc','#10273e',43)
sign('MitteOst','GASTSTÄTTE',(1273,374,291,61),'#efe5c5','#15423e',36)
sign('MitteOst','SPEISEN\nSUPPE\nEINTOPF\nKAFFEE',(1243,518,31,73),'#172f37',size=9)
sign('MitteOst','FAHRPLAN\nBUS 100\n10 · 30 · 50\nBUS 200\n05 · 25 · 45',(107,530,51,95),'#ddd5ad','#263d45',10,'shelter')
sign('MitteOst','NACHTBUS\nN2\n00 · 30\nN8\n15 · 45',(246,529,49,95),'#ddd5ad','#263d45',10,'shelter')
for text,r in [('Tomaten\n2,50',(447,591,39,26)),('Karotten\n1,80',(521,591,36,26)),('Salat\n1,50',(602,591,31,25)),('Zucchini\n1,90',(769,591,36,27)),('Äpfel\n2,20',(853,591,29,26))]:
    sign('BerlinPrenzlberg',text,r,'#e6d2a5','#292c27',11,'market_0' if r[0]<680 else 'market_1')
sign('BerlinKreuzberg','MANAV',(174,403,439,73),'#153e28',size=43)
sign('BerlinKreuzberg','SPÄTI',(754,403,240,77),'#a33029',size=41)
sign('BerlinKreuzberg','FAHRRÄDER',(1210,405,246,76),'#174564',size=38)
sign('Kiez','KIEZ\nBLEIBT',(1374,602,96,75),'#e5e5e3','#25242a',27,'garden_notice')
sign('UBahnStation','Alexanderplatz',(685,104,447,93),'#134881',size=47)
sign('UBahnStation','← Ausgang',(27,183,238,55),'#30363a',size=29)
sign('UBahnStation','Ausgang\n→',(1525,265,115,100),'#ece2ca','#17252b',26,'column_east')
sign('UBahnStation','Fahrkarten',(1181,409,178,46),'#174c7e',size=28,object_='ticket_machine')
sign('HotelLobby','PENSION',(571,146,202,57),'#4c382c','#ead6aa',34,border=True)
sign('HotelLobby','BERLIN',(713,295,81,24),'#d7d4be','#232b31',19)
sign('Restaurant','TAGESMENÜ\n\nSUPPE\nEINTOPF\nKAFFEE',(492,76,148,249),'#252b2f',size=24)
sign('Restaurant','KAFFEE\n\nEspresso\nMilchkaffee\nCappuccino',(1570,108,89,172),'#252b2f',size=14)
sign('Hospital','Behandlung',(203,345,203,43),'#b0d5cc','#193f3f',28)
sign('Hospital','Ambulanz  →\nRöntgen   →\nLabor     →',(1428,275,209,139),'#bfd0a5','#26433f',29)
sign('Hospital','A042   3\nA041   1\nA040   4',(686,204,206,109),'#19272c','#efe6c7',26)
sign('Police','POLIZEI',(113,245,144,63),'#a4bdd0','#142c45',33)
sign('Police','INFORMATION',(1376,168,222,49),'#ecdfc2','#142e43',30)
sign('Police','A  012\nB  007\nC  003',(1169,65,129,164),'#171e28','#efc7b5',31)
sign('Exchange','CHANGE\nEXCHANGE\nWECHSEL',(650,144,251,169),'#345365',size=38)
sign('Exchange','€      1,000\n$      0,920\n£      0,780',(1015,144,300,184),'#152b39','#ecd487',36)
sign('Airport','LH203   London     13:20   A7\nEW746   Paris      14:10   A8\nBA981   New York   15:40   A9\nFR312   Rome       16:05   A8',(854,111,693,208),'#17232e','#e8d092',30)
sign('Airport','Abflug  →',(1331,387,284,81),'#142f4e',size=43)
sign('Airport','A7',(79,334,92,61),'#1d2c37','#e7c667',41)

for text,r,bg,ink in [
    ('ACİL',(73,402,85,40),'#edf0e8','#152633'),('OTEL',(263,393,112,39),'#493019','#ecd397'),
    ('LOKANTA',(431,405,194,32),'#ecede5','#182b38'),('FIRIN',(690,414,113,27),'#f2dfb5','#812821'),
    ('HAN',(894,354,88,31),'#d7c298','#312b25'),('DÖVİZ',(1070,405,148,35),'#16544a','#eee8cf'),
    ('METRO',(1310,408,95,39),'#103b7a','#f0e9d3'),('KARAKOL',(1497,406,132,42),'#113a72','#f0e9d3'),
    ('POLİS',(1517,554,57,25),'#98c5d0','#073966')]: sign('IstanbulCarsi',text,r,bg,ink,28)
sign('IstanbulCarsi','$  32,50\n€  35,20\n£  41,10',(1135,477,75,87),'#172d39','#edc9a4',21)
for text,r,bg in [('KİTAP',(98,329,301,57),'#ead6ad'),('MÜZİK',(509,331,292,53),'#173e46'),('PASAJ',(1431,276,220,61),'#ecddbe')]:
    sign('IstanbulBeyoglu',text,r,bg,'#162b33' if bg!='#173e46' else '#eee6d2',36)
sign('IstanbulBeyoglu','METRO',(932,379,109,38),'#194b89',size=29)
sign('IstanbulKadikoy','BALIKÇI',(334,302,300,64),'#135dac',size=38)
sign('IstanbulKadikoy','KİTAP',(727,296,217,54),'#144d46',size=33)
sign('IstanbulKadikoy','KAFE',(1115,286,147,55),'#a22a40',size=33)
sign('IstanbulKadikoy','İSKELE',(1484,302,136,54),'#e4eceb','#174474',34)
sign('IstanbulKadikoy','Kahve\nTatlı\nSohbet',(1430,522,61,83),'#243741',size=13,object_='menu')
sign('IstanbulKarakoy','DENİZ MALZEMELERİ',(677,312,281,44),'#e5e3d5','#164168',27)
sign('IstanbulKarakoy','BİSİKLET',(1051,311,183,43),'#ede6d6','#222e39',30)
sign('IstanbulMetro','METRO',(730,162,235,63),'#0b5087',size=43)
sign('IstanbulMetro','← ÇIKIŞ',(198,252,127,45),'#166a63',size=26)
sign('IstanbulMetro','İSTANBUL\nDAİMA\nİLERİDE',(1480,310,128,117),'#e9e4d3','#1d4c77',26,'column')
sign('IstanbulOtel','OTEL',(744,91,154,55),'#68452d','#e8d6a6',40)
sign('IstanbulLokanta','LOKANTA',(723,57,306,71),'#694329','#efe2bf',49)
sign('IstanbulLokanta','GÜNLÜK YEMEKLER\n\nMercimek\nKuru fasulye\nPilav\nKöfte',(243,116,184,260),'#24333d',size=23)
sign('IstanbulDoviz','DÖVİZ',(781,51,197,65),'#674329','#ead9b3',47)
sign('IstanbulDoviz','USD   32,00\nEUR   34,50\nGBP   39,10\nCHF   36,70',(520,184,215,198),'#21303e','#b8d6b6',29)
sign('IstanbulHastane','ACİL',(785,118,143,62),'#eee6cb','#a51b29',40)
sign('IstanbulHastane','MUAYENE',(1136,238,125,42),'#99bfbd','#183437',24)
sign('IstanbulHastane','B-40',(1451,129,94,53),'#182c36','#76d5b6',28)
sign('IstanbulKarakol','KARAKOL',(782,95,308,78),'#e1d7b7','#142d50',49)
sign('IstanbulKarakol','VATANDAŞ İÇİN\nGÜVENLİ YARINLAR',(1325,130,248,81),'#e9ddbd','#163250',26)
sign('IstanbulHavalimani','GİDİŞ   Departures  →',(638,96,462,75),'#202e40',size=38)
sign('IstanbulHavalimani','Check-in  →\n\nBagaj  →\n\nTüm Kapılar  →\nAll Gates',(1399,112,266,237),'#202e40',size=29)

def save():
    (ROOT/'art/environments/lettering.json').write_text(json.dumps(DATA,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__': save()
