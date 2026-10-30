"""Record an inspected image/layout pairing; a subsequent build installs it.

Run only after viewing the prepared art and realigning the Python source
layout to it. This records technical review, not a new user approval step.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path
from city_geometry.prepared import ART, fingerprint


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('asset_id')
    parser.add_argument('--record-alignment',action='store_true',required=True)
    args=parser.parse_args()
    key=args.asset_id
    packet=None
    for filename in ['prepared-worlds.json','prepared-activity-plates.json']:
        path=ART/filename
        rows=json.loads(path.read_text(encoding='utf8'))
        if key in rows:packet=(path,rows);break
    if packet is None:parser.error('Asset is not in the remaining-city preparation package')
    path,rows=packet
    art=ART/f'scenes/{key}-retro.png'
    if not art.is_file():parser.error('Install the prepared image first')
    data=art.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':parser.error('Expected a PNG image')
    width,height=struct.unpack('>II',data[16:24])
    if abs(width/height-16/9)>.025:parser.error('Image aspect differs from the 16:9 layout')
    record_path=ART/'review/prepared-art-alignment.json'
    records=json.loads(record_path.read_text(encoding='utf8')) if record_path.exists() else {}
    records[key]=dict(layout_sha256=fingerprint(rows[key]),art_sha256=hashlib.sha256(data).hexdigest(),
                      dimensions=[width,height])
    record_path.write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print(key+': image/layout pairing recorded. Run tools/build_city_environments.py to install.')


if __name__=='__main__':main()
