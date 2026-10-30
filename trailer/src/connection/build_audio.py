from pathlib import Path
import asyncio, json, subprocess, math
import numpy as np
from scipy.signal import butter, sosfilt, fftconvolve
import soundfile as sf
import edge_tts

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'public'/'connection'
OUT.mkdir(parents=True,exist_ok=True)
SR=48000
DURATION=95
N=SR*DURATION
RNG=np.random.default_rng(2809)
# Each cue is deliberately separate: the edit leaves room for responses.
CUES=[
 ('arrival',10.8,'You arrive on Earth with nothing but questions.','en-GB-SoniaNeural','-12%','+0Hz'),
 ('lost',17.7,'No translator. No familiar voice.','en-GB-SoniaNeural','-12%','+0Hz'),
 ('brot-lukas',24.15,'Brot.','de-DE-ConradNeural','-16%','-3Hz'),
 ('oneword',26.1,'So you begin with one word.','en-GB-SoniaNeural','-12%','+0Hz'),
 ('learn',30.45,'Listen. Notice. Try.','en-GB-SoniaNeural','-16%','+0Hz'),
 ('ask',35.8,'Brot, bitte?','de-DE-ConradNeural','-18%','+15Hz'),
 ('please-lukas',38.1,'Bitte.','de-DE-ConradNeural','-7%','-3Hz'),
 ('alright',40.8,'You alright?','en-GB-LibbyNeural','+3%','+0Hz'),
 ('crashed',42.35,"My ship crashed. I'm quite far from home.",'en-GB-RyanNeural','+0%','+12Hz'),
 ('hello',46.15,'I just meant hello.','en-GB-LibbyNeural','-3%','+0Hz'),
 ('beginning',49.65,'Knowing the words is only the beginning.','en-GB-SoniaNeural','-10%','+0Hz'),
 ('meaning',53.15,'People mean more than they say.','en-GB-SoniaNeural','-9%','+0Hz'),
 ('buyurun',57.0,'Buyurun.','tr-TR-AhmetNeural','-12%','+0Hz'),
 ('invitation',59.05,'An invitation you almost missed.','en-GB-SoniaNeural','-10%','+0Hz'),
 ('living',63.6,'Learn languages by living them.','en-GB-SoniaNeural','-10%','+0Hz'),
 ('cities',69.4,'Across cities, cultures, and lives that become part of yours.','en-GB-SoniaNeural','-9%','+0Hz'),
 ('coming',75.8,'Coming? I saved you a spot.','en-GB-LibbyNeural','-7%','+0Hz'),
 ('alone',80.6,"You may still be foreign. But you don't have to be alone.",'en-GB-SoniaNeural','-12%','+0Hz'),
 ('title',89.0,'Foreign to All.','en-GB-SoniaNeural','-12%','+0Hz'),
]

async def voices():
 sem=asyncio.Semaphore(3)
 async def one(c):
  name,start,words,voice,rate,pitch=c
  p=OUT/(name+'.mp3')
  async with sem:
   if not p.exists():
    await edge_tts.Communicate(words,voice,rate=rate,pitch=pitch).save(str(p))
  dur=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(p)]))
  return dict(id=name,start=start,text=words,voice=voice,duration=dur)
 return await asyncio.gather(*(one(c) for c in CUES))

def add(buf,x,start,gain=1.,pan=0.):
 at=int(start*SR)
 if at>=len(buf): return
 if at<0: x=x[-at:];at=0
 length=min(len(x),len(buf)-at)
 x=x[:length]
 if x.ndim==1:
  buf[at:at+length,0]+=x*gain*math.sqrt((1-pan)/2)
  buf[at:at+length,1]+=x*gain*math.sqrt((1+pan)/2)
 else:buf[at:at+length]+=x*gain

def piano(midi,velocity=.5,length=5.8):
 f=440*2**((midi-69)/12)
 t=np.arange(int(length*SR))/SR
 y=np.zeros_like(t)
 # Inharmonic decaying partials and detuned strings; no sampled music.
 for k in range(1,11):
  decay=(3.2/(1+k*.42))*(220/f)**.16
  amp=(1/(k**1.65))*np.exp(-t/decay)
  freq=f*k*math.sqrt(1+.000045*k*k)
  y+=amp*(np.sin(2*np.pi*freq*t)+.28*np.sin(2*np.pi*freq*1.0009*t+.07))
 hammer=RNG.normal(0,1,len(t))*np.exp(-t*90)
 hammer=sosfilt(butter(2,1800,fs=SR,output='sos'),hammer)
 y=(y+.1*hammer)*(1-np.exp(-t*340))*np.minimum(1,(length-t)/.12)
 return y*velocity*.13

def pad(midis,length=6.7):
 t=np.arange(int(length*SR))/SR
 y=np.zeros_like(t)
 for m in midis:
  f=440*2**((m-69)/12)
  for det in [.997,1,1.003]:
   y+=np.sin(2*np.pi*f*det*t+0.18*np.sin(t*1.3))
   y+=.13*np.sin(2*np.pi*f*2*det*t)
 env=np.minimum(t/1.6,1)*np.minimum((length-t)/2.3,1)
 return y*env*.0028

def room(x,wet=.23):
 # Small early reflections, then an irregular diffuse tail.
 result=x.copy()
 impulse=np.zeros(int(3.7*SR))
 for i in range(130):
  when=.049+i*.025+float(RNG.uniform(-.006,.006))
  impulse[int(when*SR)]+=float(RNG.choice([-1,1]))*np.exp(-when/1.03)*.087
 for c in range(2):
  reverb=fftconvolve(x[:,c],np.roll(impulse,int(c*.007*SR)))[:len(x)]
  reverb=sosfilt(butter(2,3400,fs=SR,output='sos'),reverb)
  result[:,c]+=wet*reverb
 return result

def score():
 b=np.zeros((N,2),np.float32)
 # D minor opens into F major; 6/8 at 72 dotted-quarter beats/minute.
 chords=[[50,57,62,65,69],[46,53,58,62,65],[53,60,65,69,72],[48,55,60,64,67],
         [50,57,62,65,69],[46,53,58,62,65],[53,60,65,69,72],[48,55,60,64,67],
         [58,65,69,72,74],[53,60,65,69,72],[48,55,60,64,67],[50,57,62,65,69],
         [46,53,58,62,65],[53,60,65,69,72],[48,55,60,64,67],[53,60,65,69,72]]
 for bar,chord in enumerate(chords):
  at=10+bar*5
  vel=.34 if at<23 else .43 if at<49 else .53 if at<75 else .62
  pattern=[0,2,3,4,2,3]
  for beat,index in enumerate(pattern):
   if at<23 and beat in [2,4]:continue
   start=at+beat*5/6+float(RNG.uniform(-.016,.016))
   add(b,piano(chord[index],vel*(1.04 if beat==0 else .75+RNG.random()*.17)),start,pan=(index-2)*.13)
  if at>=25:add(b,pad([chord[0],chord[2],chord[3]]),at,gain=.6 if at<65 else 1.2,pan=.05)
 # A spare recurring melody, with a completed phrase at the invitation.
 for at,notes in [(20,[74,72,69]),(30,[69,67,65]),(50,[74,72,69]),(65,[72,74,77]),(80,[77,76,72,69]),(88,[72,69,65])]:
  for i,m in enumerate(notes):add(b,piano(m,.31 if at<60 else .39,6),at+i*.93,pan=.22)
 add(b,piano(41,.5,7),88)
 for i,m in enumerate([53,60,65,69,72]):add(b,piano(m,.3,7),88+i*.047,pan=(i-2)*.12)
 b=room(b,wet=.54)
 times=np.arange(N)/SR
 b*=np.minimum(np.maximum((times-9.8)/2,0),1)[:,None]
 b*=np.clip((94.8-times)/4.8,0,1)[:,None]
 sf.write(OUT/'score.wav',b,SR,subtype='PCM_24')
 return b

def effects():
 b=np.zeros((N,2),np.float32)
 # Soft irregular physical keystrokes with a tiny wooden resonance.
 for j in range(101):
  at=.35+j*.058+float(RNG.uniform(-.016,.016))
  if 1.45<at<1.9:continue
  t=np.arange(int(.075*SR))/SR
  x=RNG.normal(0,1,len(t))*np.exp(-t*115)*.026+np.sin(2*np.pi*float(RNG.uniform(620,1050))*t)*np.exp(-t*65)*.015
  add(b,x,at,pan=float(RNG.uniform(-.1,.1)))
 # Paper page and a soft transition click.
 for at in [8.9,30,69]:
  t=np.arange(int(.4*SR))/SR
  x=sosfilt(butter(2,[800,7500],fs=SR,btype='bandpass',output='sos'),RNG.normal(0,1,len(t)))
  add(b,x*np.sin(np.pi*t/.4)**2*.009,at)
 # Distant air, rain and leaves, deliberately very low under the score.
 for start,end,gain in [(10,23,.005),(40,56,.011),(75,80,.009),(80,94,.006)]:
  n=int((end-start)*SR);t=np.arange(n)/SR
  noise=RNG.normal(0,1,n)
  noise=sosfilt(butter(2,1250,fs=SR,output='sos'),noise)
  noise*=np.minimum(t,1)*np.minimum(end-start-t,1)
  add(b,noise,start,gain=gain,pan=-.4)
  add(b,np.roll(noise,2501),start,gain=gain,pan=.4)
 # A door bell, cup touching saucer, and a vocabulary-discovery note.
 for at,midi in [(23.35,88),(29.2,81),(35.2,84),(58.7,91)]:
  add(b,piano(midi,.22,2.4),at)
 # Soft footfalls.
 for start,count in [(18,7),(35.2,3),(76.3,5)]:
  for i in range(count):
   t=np.arange(int(.13*SR))/SR
   x=sosfilt(butter(2,380,fs=SR,output='sos'),RNG.normal(0,1,len(t)))
   add(b,x*np.exp(-t*27)*.018,start+i*.37,pan=(-1 if i%2 else 1)*.14)
 # Small distant fireworks: low impact, soft crackle, no startling peaks.
 for at in [81.5,83.9,86.0,88.5]:
  t=np.arange(int(2.2*SR))/SR
  x=sosfilt(butter(2,290,fs=SR,output='sos'),RNG.normal(0,1,len(t)))*np.exp(-t*2.9)*.045
  x+=np.sin(2*np.pi*54*t)*np.exp(-t*5)*.012
  add(b,x,at,pan=float(RNG.uniform(-.45,.45)))
 sf.write(OUT/'effects.wav',b,SR,subtype='PCM_24')
 return b

def readvoice(p):
 raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-f','f32le','-ac','1','-ar',str(SR),'-'])
 x=np.frombuffer(raw,dtype=np.float32).copy()
 # Remove codec padding/silence so the dialogue cue really starts on its mark.
 active=np.flatnonzero(np.abs(x)>.002)
 if len(active):x=x[max(0,active[0]-int(.045*SR)):min(len(x),active[-1]+int(.1*SR))]
 x=sosfilt(butter(2,80,fs=SR,btype='highpass',output='sos'),x)
 peak=np.max(np.abs(x))
 if peak:x*=.48/peak
 return x

async def main():
 data=await voices()
 voice=np.zeros((N,2),np.float32)
 duck=np.ones(N,dtype=np.float32)
 for d in data:
  x=readvoice(OUT/(d['id']+'.mp3'))
  d['duration']=len(x)/SR
  d['end']=d['start']+d['duration']
  sf.write(OUT/(d['id']+'.wav'),x,SR,subtype='PCM_24')
  add(voice,x,d['start'],gain=1.0)
  # Music ducks smoothly just around each line.
  lo=max(0,int((d['start']-.3)*SR));hi=min(N,int((d['end']+.55)*SR))
  ts=np.arange(lo,hi)/SR
  env=np.minimum(np.clip((ts-(d['start']-.3))/.3,0,1),np.clip((d['end']+.55-ts)/.55,0,1))
  duck[lo:hi]=np.minimum(duck[lo:hi],1-env*.49)
 (OUT/'cues.json').write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')
 music=sf.read(OUT/'score.wav',dtype='float32')[0] if (OUT/'score.wav').exists() else score()
 sfx=sf.read(OUT/'effects.wav',dtype='float32')[0] if (OUT/'effects.wav').exists() else effects()
 mix=voice+music*duck[:,None]*1.42+sfx
 sf.write(OUT/'mix-raw.wav',mix,SR,subtype='PCM_24')
 subprocess.run(['ffmpeg','-y','-v','warning','-i',str(OUT/'mix-raw.wav'),'-af','loudnorm=I=-17:TP=-1.5:LRA=10','-ar',str(SR),'-c:a','pcm_s24le',str(OUT/'soundtrack.wav')],check=True)
 print(json.dumps(data,indent=2,ensure_ascii=False))

if __name__=='__main__':asyncio.run(main())
