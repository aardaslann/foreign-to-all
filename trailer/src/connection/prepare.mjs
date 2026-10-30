import {readFileSync, writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const read = name => JSON.parse(readFileSync(path.join(root, 'public/connection', name), 'utf8'));
const cast = read('cast.json');
const cues = read('cues.json');
writeFileSync(path.join(here, 'data.ts'), `// Generated from the current game cast and timed audio cues.\nexport const CAST:any = ${JSON.stringify(cast)};\nexport const CUES:any[] = ${JSON.stringify(cues)};\n`);
const stamp = seconds => {
  const n = Math.round(seconds * 1000);
  return `${String(Math.floor(n / 3600000)).padStart(2, '0')}:${String(Math.floor(n / 60000) % 60).padStart(2, '0')}:${String(Math.floor(n / 1000) % 60).padStart(2, '0')},${String(n % 1000).padStart(3, '0')}`;
};
writeFileSync(path.join(root, 'out/foreign-to-all-a-place-to-belong.srt'), cues.map((c, i) => `${i+1}\n${stamp(c.start)} --> ${stamp(c.end+.15)}\n${c.text}\n`).join('\n'), 'utf8');
console.log('Updated cast, cue data, and subtitle sidecar.');
