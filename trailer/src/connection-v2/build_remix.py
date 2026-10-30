"""Rebuild the dialogue-only mix from saved recordings; no speech service needed."""
from pathlib import Path
import json, subprocess, math, re
import numpy as np
import soundfile as sf
from scipy.signal import butter, sosfilt, resample_poly

ROOT=Path(__file__).resolve().parents[2]
OLD=ROOT/'public/connection'
OUT=ROOT/'public/connection-v2'
OUT.mkdir(exist_ok=True)
SR=48000
DURATION=108
N=SR*DURATION
rng=np.random.default_rng(942)

def add(buf,x,start,gain=1,pan=0):
 at=round(start*SR)
 n=min(len(x),len(buf)-at)
 if n<=0:return
 x=x[:n]
 if x.ndim==1:
  buf[at:at+n,0]+=x*gain*math.sqrt((1-pan)/2)
  buf[at:at+n,1]+=x*gain*math.sqrt((1+pan)/2)
 else:buf[at:at+n]+=x*gain

def key_times(text,start,end):
 gaps=[.75+((i*37)%11)/20+(.25 if c==' ' else 0)+(1.3 if c in ',.' else 0) for i,c in enumerate(text)]
 return (start+np.cumsum(gaps)*(end-start)/sum(gaps)).tolist()

# The score's tempo slows slightly to follow the longer reading pauses.
original_music=sf.read(OLD/'score.wav',dtype='float32')[0]
sf.write(OUT/'score-content.wav',original_music[10*SR:],SR,subtype='PCM_24')
subprocess.run(['ffmpeg','-v','error','-y','-i',str(OUT/'score-content.wav'),'-af','atempo=0.9','-ar',str(SR),'-c:a','pcm_s24le',str(OUT/'score-slow.wav')],check=True)
music=np.zeros((N,2),np.float32)
add(music,sf.read(OUT/'score-slow.wav',dtype='float32')[0],13)
sf.write(OUT/'score.wav',music,SR,subtype='PCM_24')
effects=np.zeros((N,2),np.float32)
oldfx=sf.read(OLD/'effects.wav',dtype='float32')[0]
# Reuse the quiet environmental sounds, excluding the old keyboard completely.
segments=[(10,17,13,20),(17,23,20,26),(23,30,26,33),(30,35,33,39),(35,40,39,44),(40,49,44,53),(49,56,53,62),(56,63,62,69),(63,69,69,76),(69,75,76,84),(75,80,84,90),(80,87,90,100),(87,95,100,108)]
for a,b,c,d in segments:
 x=oldfx[round(a*SR):round(b*SR)]
 if d-c!=b-a:x=resample_poly(x,d-c,b-a,axis=0)
 # Tiny ramps prevent discontinuities at edits.
 ramp=np.minimum(np.arange(len(x))/(SR*.015),1)*np.minimum(np.arange(len(x))[::-1]/(SR*.025),1)
 add(effects,x*ramp[:,None],c)

# An actual recorded soft mechanical key, rounded with EQ, lightly varied.
source,sr=sf.read(OUT/'keyboard-soft-source.wav',dtype='float32')
assert sr==SR
peak=int(np.argmax(np.abs(source)))
key=source[max(0,peak-round(.013*SR)):peak+round(.115*SR)]
key=sosfilt(butter(2,[110,2900],btype='bandpass',fs=SR,output='sos'),key)
key*=np.minimum(np.arange(len(key))/(SR*.0015),1)*np.minimum(np.arange(len(key))[::-1]/(SR*.018),1)
key=key/max(np.max(np.abs(key)),1e-6)*.035
keys=np.zeros_like(effects)
for i,at in enumerate(key_times('sonder',.4,1.2)+[1.7]):
 variant=resample_poly(key,100,98+i%5)
 add(keys,variant,at,gain=.78+float(rng.random())*.22,pan=(i%3-1)*.07)
effects+=keys
sf.write(OUT/'keyboard.wav',keys[:round(2.2*SR)],SR,subtype='PCM_24')
sf.write(OUT/'effects.wav',effects,SR,subtype='PCM_24')

# Explicit allowlist: narrator recordings are never loaded into the mix.
starts={'brot-lukas':27.15,'ask':39.8,'please-lukas':42.1,'alright':44.8,'crashed':46.35,'hello':50.15,'buyurun':63.0,'coming':84.8}
old_cues={c['id']:c for c in json.loads((OLD/'cues.json').read_text(encoding='utf-8'))}
dialogue=np.zeros((N,2),np.float32)
duck=np.ones(N,np.float32)
new_cues=[]
for name,start in starts.items():
 x,sr=sf.read(OLD/(name+'.wav'),dtype='float32')
 assert sr==SR
 add(dialogue,x,start)
 end=start+len(x)/SR
 c={**old_cues[name],'start':start,'end':end,'duration':len(x)/SR}
 assert c['voice']!='en-GB-SoniaNeural'
 new_cues.append(c)
 lo=round((start-.3)*SR);hi=round((end+.55)*SR)
 t=np.arange(lo,hi)/SR
 envelope=np.minimum(np.clip((t-start+.3)/.3,0,1),np.clip((end+.55-t)/.55,0,1))
 duck[lo:hi]=np.minimum(duck[lo:hi],1-.47*envelope)
sf.write(OUT/'dialogue.wav',dialogue,SR,subtype='PCM_24')
(OUT/'cues.json').write_text(json.dumps(new_cues,indent=2,ensure_ascii=False),encoding='utf-8')
mix=dialogue+music*duck[:,None]*1.6+effects
sf.write(OUT/'mix-raw.wav',mix,SR,subtype='PCM_24')
measurement=subprocess.run(['ffmpeg','-hide_banner','-i',str(OUT/'mix-raw.wav'),'-af','loudnorm=I=-18:TP=-1.5:LRA=10:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
levels=json.loads(re.findall(r'\{\s*"input_i".*?\}',measurement.stderr,re.S)[-1])
# Use one fixed gain for the whole film. Dynamic loudness normalization boosts
# the sparse keyboard intro toward the same peak as speech, ruining its softness.
gain=min(-18-float(levels['input_i']),-1.5-float(levels['input_tp']))
subprocess.run(['ffmpeg','-v','error','-y','-i',str(OUT/'mix-raw.wav'),'-af',f'volume={gain:.4f}dB','-ar',str(SR),'-c:a','pcm_s24le',str(OUT/'soundtrack.wav')],check=True)
(OUT/'mastering.json').write_text(json.dumps({'input':levels,'fixed_gain_db':gain,'target_lufs':-18},indent=2),encoding='utf-8')
print(json.dumps({'duration':DURATION,'dialogue_lines':len(new_cues),'narrator_lines':0,'keyboard_events':7,'keyboard_source':'bigmonmulgrew / Freesound 378083 / CC0'},indent=2))
