"""Rework the opening; retain revision 4's story mix and its relative timing."""
from pathlib import Path
import importlib.util, json, math, subprocess
import numpy as np
import soundfile as sf
from scipy.signal import butter, sosfilt, resample_poly

SRC=Path(__file__).resolve().parent
ROOT=SRC.parents[1]
OLD=ROOT/'public/connection-v4'
OUT=ROOT/'public/connection-v5'
OUT.mkdir(exist_ok=True)
SR=48000
FPS=30
CLICK_AT=9.5
STORY_AT=11.5
OLD_STORY=14.5
SHIFT=STORY_AT-OLD_STORY
DURATION=121.5+SHIFT
N=round(DURATION*SR)
rng=np.random.default_rng(942)

def key_times(text,start,end):
    weights=[.85+((i*13)%7)*.045+(.6 if c==' ' else 0)+(1.5 if c in ',.' else 0) for i,c in enumerate(text)]
    seconds=start+np.cumsum(weights)*(end-start)/sum(weights)
    return (np.round(seconds*FPS)/FPS).tolist()

lines=['the profound realization that every random stranger',
       'is living a life as vivid, complex, and central to them',
       'as your own is to you.']
definition=' '.join(lines)
intro={'definition':definition,'lines':lines,'titleKeys':key_times('sonder',.1,.8),'bodyKeys':key_times(definition,1.65,8.1),'clickAt':CLICK_AT,'storyAt':STORY_AT,'bodyEnd':8.1,'duration':DURATION}
(SRC/'intro.ts').write_text('export const INTRO = '+json.dumps(intro,indent=2)+' as const;\n',encoding='utf-8')
(OUT/'intro.json').write_text(json.dumps(intro,indent=2),encoding='utf-8')

def add(buf,x,start,gain=1,pan=0):
    at=round(start*SR)
    if at<0: x=x[-at:];at=0
    x=x[:min(len(x),len(buf)-at)]
    if x.ndim==1:
        buf[at:at+len(x),0]+=x*gain*math.sqrt((1-pan)/2)
        buf[at:at+len(x),1]+=x*gain*math.sqrt((1+pan)/2)
    else:buf[at:at+len(x)]+=x*gain

def shifted_story(name):
    x,sr=sf.read(OLD/name,dtype='float32')
    assert sr==SR
    b=np.zeros((N,2),np.float32)
    add(b,x[round(OLD_STORY*SR):],STORY_AT)
    return b

music=shifted_story('score.wav')
effects=shifted_story('effects.wav')
dialogue=shifted_story('dialogue.wav')

# Reuse the original score's instrument, without running its speech generator.
spec=importlib.util.spec_from_file_location('original_instruments',ROOT/'src/connection/build_audio.py')
instrument=importlib.util.module_from_spec(spec)
spec.loader.exec_module(instrument)

# The old score fades its first bass note almost away. Give the picture cut a
# definite D-minor downbeat, voiced with the same piano as the existing score.
arrival=np.zeros((6*SR,2),np.float32)
for midi,velocity,delay,pan in [(50,.62,0,-.12),(62,.29,.008,.02),(65,.22,.021,-.20),(69,.17,.032,.22)]:
    add(arrival,instrument.piano(midi,velocity,length=5.8),delay,pan=pan)
arrival=instrument.room(arrival,wet=.50)
add(music,arrival,STORY_AT)

# One beat at the existing retimed score's tempo: a reversed piano breath rises
# through the end of black and resolves into the chord, instead of dead silence
# followed by a multi-second fade-in. It is original audio, not the TikTok song.
beat=(5/6)/.8
pickup_n=round(beat*SR)
pickup=instrument.piano(62,.32,length=beat)[::-1]+instrument.piano(69,.20,length=beat)[::-1]
pickup=sosfilt(butter(2,2600,fs=SR,output='sos'),pickup)
pickup*=np.linspace(0,1,pickup_n)**1.8
pickup*=np.minimum(np.arange(pickup_n)[::-1]/(SR*.003),1)
pickup=pickup/max(np.max(np.abs(pickup)),1e-9)*.024
add(music,pickup,STORY_AT-beat,pan=.08)
sf.write(OUT/'pickup.wav',pickup,SR,subtype='PCM_24')

# Same soft recording, now locked to the visible letter frames.
source,sr=sf.read(OLD/'keyboard-soft-source.wav',dtype='float32')
assert sr==SR
peak=int(np.argmax(np.abs(source)))
key=source[max(0,peak-round(.013*SR)):peak+round(.115*SR)]
key=sosfilt(butter(2,[110,2900],btype='bandpass',fs=SR,output='sos'),key)
key*=np.minimum(np.arange(len(key))/(SR*.0015),1)*np.minimum(np.arange(len(key))[::-1]/(SR*.018),1)
key=key/max(np.max(np.abs(key)),1e-9)*.035
keys=np.zeros_like(effects)
typing=intro['titleKeys']+intro['bodyKeys']
for i,at in enumerate(typing):
    variant=resample_poly(key,100,98+i%5)
    add(keys,variant,at,gain=(.78+float(rng.random())*.22)*(1 if i<6 else .5),pan=(i%3-1)*.07)
effects+=keys

# Keep the stronger snap, with a short decaying reflection to link it to the
# incoming piano's room rather than leave it sounding pasted onto the edit.
click,sr=sf.read(OLD/'transition-click.wav',dtype='float32')
assert sr==SR
add(effects,click,CLICK_AT,gain=.94)
tail=sosfilt(butter(2,2100,fs=SR,output='sos'),click)
for delay,gain,pan in [(.082,.12,-.25),(.151,.07,.25),(.243,.025,-.12)]:
    add(effects,tail,CLICK_AT+delay,gain=gain,pan=pan)

cues=json.loads((OLD/'cues.json').read_text())
duck=np.ones(N,np.float32)
for c in cues:
    c['start']+=SHIFT;c['end']+=SHIFT
    lo=round((c['start']-.3)*SR);hi=round((c['end']+.55)*SR)
    t=np.arange(lo,hi)/SR
    envelope=np.minimum(np.clip((t-c['start']+.3)/.3,0,1),np.clip((c['end']+.55-t)/.55,0,1))
    duck[lo:hi]=np.minimum(duck[lo:hi],1-.47*envelope)
assert len(cues)==8 and all('Sonia' not in c['voice'] for c in cues)
(OUT/'cues.json').write_text(json.dumps(cues,indent=2,ensure_ascii=False),encoding='utf-8')
for name,stem in [('score.wav',music),('effects.wav',effects),('dialogue.wav',dialogue),('keyboard.wav',keys[:round(STORY_AT*SR)])]:
    sf.write(OUT/name,stem,SR,subtype='PCM_24')
mix=dialogue+music*duck[:,None]*1.6+effects
sf.write(OUT/'mix-raw.wav',mix,SR,subtype='PCM_24')
gain=json.loads((OLD/'mastering.json').read_text())['fixed_gain_db']
master=mix*10**(gain/20)
assert np.max(np.abs(master))<10**(-1.5/20)
sf.write(OUT/'soundtrack.wav',master,SR,subtype='PCM_24')
sf.write(OUT/'opening-review.wav',master[:round(17.5*SR)],SR,subtype='PCM_24')
report={'duration':DURATION,'definition_completed_at':8.1,'definition_hold_seconds':1.4,'click_at':CLICK_AT,'black_seconds':2,'pickup_start':STORY_AT-beat,'picture_and_downbeat_at':STORY_AT,'story_shift':SHIFT,'fixed_gain_db':gain,'peak_dbfs':float(20*np.log10(np.max(np.abs(master)))),'dialogue_lines':8,'narrator_lines':0}
(OUT/'mastering.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report,indent=2))
