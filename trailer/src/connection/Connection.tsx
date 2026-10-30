import React from 'react';
import {AbsoluteFill, Audio, Img, staticFile, useCurrentFrame} from 'remotion';
import {CAST, CUES} from './data';
import {toGlyphs} from '../lib/glyphs';

// Authentic character grids exported by Godot from CharacterArt + Cast + Wardrobe.
// All animation is frame driven; no generated illustrations are used in this film.
const W=1920,H=1080;
const C={paper:'#f2e9d8',ink:'#211d30',dim:'#9990b0',gold:'#e2b45c',teal:'#47837c',night:'#0b091a',lavender:'#c3b2de'};
const sans='"Segoe UI", Arial, sans-serif';
const serif='Georgia, "Times New Roman", serif';
const mono='Consolas, monospace';
const clamp=(x:number)=>Math.max(0,Math.min(1,x));
const ease=(x:number)=>{x=clamp(x);return x*x*(3-2*x)};
const move=(t:number,a:number,b:number,x:number,y:number)=>x+(y-x)*ease((t-a)/(b-a));
const fade=(t:number,a:number,b:number,d=.28)=>clamp((t-a)/d)*clamp((b-t)/d);
const px=(v:number)=>Math.round(v);
const asset=(p:string)=>staticFile('connection/'+p);

function Prop({kind,x,y,u=10,opacity=1}:{kind:string;x:number;y:number;u?:number;opacity?:number}){
 const p=CAST.props[kind];if(!p)return null;
 const [w,h,,a,b]=p;
 return <svg style={{position:'absolute',left:px(x-w*u/2-4),top:px(y-h*u/2-4),overflow:'visible',opacity}} width={w*u+8} height={h*u+8} shapeRendering="crispEdges">
  <rect x={0} y={0} width={w*u+8} height={h*u+8} fill={C.ink}/>
  <rect x={4} y={4} width={w*u} height={h*u} fill={a}/>
  <rect x={4} y={4} width={w*u} height={Math.max(u,h*u*.34)} fill={b}/>
  {kind==='loaf'&&[1,2,3].map(i=><path key={i} d={`M ${i*w*u/4} ${5+u*.3} l ${u*.7} ${u*.6}`} stroke="#ad763e" strokeWidth={u*.34}/>)}</svg>
}

function Actor({id='alien',x,y,u=12,t=0,act='stand',flip=false,hideProp=false,opacity=1,back=false}:{id?:string;x:number;y:number;u?:number;t?:number;act?:string;flip?:boolean;hideProp?:boolean;opacity?:number;back?:boolean}){
 const p=CAST.people[id];if(!p)return null;
 const seed=id.split('').reduce((a,b)=>a+b.charCodeAt(0),0)%31;
 let pose=act;
 if(pose==='stand'&&p.idle&&CAST.idle[p.idle]){
  const loop=CAST.idle[p.idle] as [string,number][];
  const total=loop.reduce((a,b)=>a+b[1],0);let clock=(t+seed*.37)%total;
  for(const [a,d] of loop){clock-=d;if(clock<=0){pose=a;break}}
 }
 let rows:string[]=p.acts[pose]||p.rows;
 let unit=u*(CAST.build[p.build]||1);
 const dip=(CAST.dip[pose]||0)+(Math.sin(t*.55+seed*1.7)>.8?1:0)+(p.build==='elder'?1:0);
 const lean=(CAST.lean[pose]||0)+(p.build==='elder'?-1:0);
 const sit=['sit','kneel','squat'].includes(pose);
 const step=pose==='walk'&&Math.sin(t*6+seed)>0?1:0;
 const blink=((t+seed*.47)%5.2)>5.02;
 const rects:React.ReactNode[]=[];
 for(let r=0;r<(sit?23:26);r++){
  const row=rows[r];
  for(let c=0;c<row.length;c++){
   let ch=row[c];
   if(blink&&['E','W'].includes(ch))ch='S';
   if(back&&r<16&&ch!=='.'&&ch!=='X')ch=id==='alien'?'S':'R';
   if(ch==='.'||!p.pal[ch])continue;
   const dy=(sit?2:0)+(r<=15?dip:0);
   // A low moonlight fill preserves the native silhouette against the night sky.
   const colour=back&&id!=='alien'?({'R':'#373044','X':'#24202e','C':'#302d3b','B':'#3b3748','D':'#282431'} as Record<string,string>)[ch]||p.pal[ch]:p.pal[ch];
   rects.push(<rect key={r+'-'+c} x={c-8+(r<=15?lean:0)} y={r-26+dy-(r>=23?step:0)} width={1} height={1} fill={colour}/>);
  }
 }
 return <>
  <svg width={40*unit} height={40*unit} viewBox="-20 -36 40 40" style={{position:'absolute',left:px(x-20*unit),top:px(y-36*unit),overflow:'visible',opacity,transform:flip?'scaleX(-1)':undefined}} shapeRendering="crispEdges">
   <ellipse cx={0} cy={0} rx={7} ry={2.25} fill="#000" opacity={.23}/>
   {rects}
   {sit&&<><rect x={-8} y={-3} width={16} height={3} fill={p.pal.D}/><rect x={-8} y={-1} width={16} height={1} fill={p.pal.X}/></>}
  </svg>
  {!hideProp&&!back&&p.prop&&<Prop kind={p.prop} x={x+(p.prop_side||0)*4*unit} y={y-CAST.props[p.prop][2]*unit+dip*unit+CAST.props[p.prop][1]*unit/2} u={unit} opacity={opacity}/>}
 </>
}

function Plate({name,t,zoom=1.05,pan=0,grade=.12}:{name:string;t:number;zoom?:number;pan?:number;grade?:number}){
 return <AbsoluteFill style={{overflow:'hidden'}}>
  <Img src={asset(name+'.png')} style={{width:W,height:H,imageRendering:'pixelated',transform:`translate(${px(pan+t*1.8)}px,0) scale(${zoom})`,transformOrigin:'50% 65%'}}/>
  <AbsoluteFill style={{background:`linear-gradient(180deg,rgba(11,9,26,${grade}) 0%,transparent 40%,rgba(11,9,26,.22) 100%)`}}/>
 </AbsoluteFill>
}

function Location({name,detail,t}:{name:string;detail:string;t:number}){
 return <div style={{position:'absolute',left:108,top:119,opacity:fade(t,.25,4.7,.4),color:C.paper}}>
  <div style={{fontFamily:sans,fontWeight:600,letterSpacing:6,fontSize:26}}>{name.toUpperCase()}</div>
  <div style={{fontFamily:serif,fontStyle:'italic',fontSize:24,marginTop:9,color:'#ddd1bd'}}>{detail}</div>
 </div>
}

function Bubble({x,y,w=430,children,t,start,end,tail='left',dark=false,size=48}:{x:number;y:number;w?:number;children:React.ReactNode;t:number;start:number;end:number;tail?:'left'|'right';dark?:boolean;size?:number}){
 const a=fade(t,start,end,.16);if(!a)return null;
 const bg=dark?'#252039':C.paper;
 return <div style={{position:'absolute',left:x,top:y,width:w,opacity:a,transform:`translateY(${px((1-ease((t-start)/.25))*12)}px)`,filter:'drop-shadow(0 8px 0 rgba(0,0,0,.15))'}}>
  <div style={{background:bg,color:dark?C.paper:C.ink,padding:'25px 32px 29px',border:'4px solid '+(dark?'#776889':'#3e334c'),fontSize:size,lineHeight:1.25,fontFamily:sans,fontWeight:500,position:'relative'}}>{children}</div>
  <div style={{position:'absolute',top:'calc(100% - 4px)',left:w/2-13,width:25,height:22,background:bg,borderLeft:'4px solid '+(dark?'#776889':'#3e334c'),borderRight:'4px solid '+(dark?'#776889':'#3e334c')}}/>
  <div style={{position:'absolute',top:'calc(100% + 14px)',left:w/2-13,width:14,height:13,background:bg,borderBottom:'4px solid '+(dark?'#776889':'#3e334c')}}/>
 </div>
}

function Steam({x,y,t,colour=C.paper,scale=1}:{x:number;y:number;t:number;colour?:string;scale?:number}){
 return <svg style={{position:'absolute',left:x-50*scale,top:y-110*scale,overflow:'visible'}} width={100*scale} height={110*scale} viewBox="0 0 100 110">
  {[0,1,2].map(i=>{const p=(t*.43+i*.29)%1;return <path key={i} d={`M ${42+i*9+Math.sin(p*8)*8} ${108-p*66} l -4 -9 l 8 -12 l -4 -9`} fill="none" stroke={colour} strokeWidth={3} opacity={Math.sin(p*Math.PI)*.37}/>})}
 </svg>
}

function Rain({t,intensity=50}:{t:number;intensity?:number}){
 return <svg width={W} height={H} style={{position:'absolute',left:0,top:0,pointerEvents:'none'}} shapeRendering="crispEdges">
  {Array.from({length:intensity},(_,i)=>{const x=(i*139+t*80)%W;const y=(i*251+t*470)%H;return <rect key={i} x={px(x/3)*3} y={px(y/3)*3} width={2} height={12+i%5} fill="#bfcede" opacity={.12+(i%3)*.04}/>})}
 </svg>
}

function Dictionary({t}:{t:number}){
 const definition='The realization that every individual passerby has a life just as complex as your own.';
 const count=Math.floor(clamp((t-2.4)/3.7)*definition.length);
 return <AbsoluteFill style={{background:C.paper,color:C.ink,justifyContent:'center',padding:'0 300px'}}>
  <div style={{fontFamily:serif,fontSize:135,letterSpacing:-6,height:167}}>{'sonder'.slice(0,Math.floor(clamp((t-.4)/.75)*6))}<span style={{fontFamily:mono,fontSize:94,opacity:t<1.5&&Math.floor(t*3)%2===0?1:0}}>│</span></div>
  <div style={{fontFamily:mono,fontSize:29,color:'#746e6b',opacity:clamp((t-1.25)/.25),marginTop:10}}>[sohn-durr] <span style={{marginLeft:40,fontFamily:serif,fontStyle:'italic'}}>noun</span></div>
  <div style={{width:110,background:'#b4a88f',height:2,marginTop:40,marginBottom:38,transform:`scaleX(${ease((t-1.8)/.4)})`,transformOrigin:'left'}}/>
  <div style={{fontFamily:serif,fontSize:46,lineHeight:1.5,width:1220,minHeight:150}}>{definition.slice(0,count)}<span style={{opacity:t<6.9&&Math.floor(t*3)%2===0?1:0}}>▏</span></div>
 </AbsoluteFill>
}

function Arrival({t}:{t:number}){
 const ax=move(t,3.7,6.5,690,1010);
 return <AbsoluteFill>
  <Plate name="wreck" t={t} zoom={1.03}/>
  <Actor x={ax} y={845} u={7} t={t} act={t<2.8?'look':t<3.7?'stand':'walk'}/>
  <Steam x={400} y={520} t={t} colour="#80788e" scale={2}/>
  <div style={{position:'absolute',left:118,top:137,color:C.paper,fontFamily:mono,fontSize:24,letterSpacing:5,opacity:fade(t,.7,6.8)}}>SOMEWHERE ON EARTH</div>
  <div style={{position:'absolute',right:160,top:250,color:C.lavender,opacity:fade(t,2.5,5.5),fontFamily:mono,fontSize:56}}>…?</div>
 </AbsoluteFill>
}

function Lost({t}:{t:number}){
 return <AbsoluteFill>
  <Plate name="kiez" t={t} grade={.2}/>
  <Location name="Berlin" detail="A first morning" t={t}/>
  <Actor id="crowd0" x={move(t,0,6,1700,1580)} y={720} u={6} t={t} act="walk"/>
  <Actor id="crowd2" x={1240} y={880} u={11} t={t} act="talk"/>
  <Actor id="crowd3" x={1530} y={892} u={11} t={t+1} act="watch"/>
  <Actor x={move(t,0,2,320,665)} y={939} u={13} t={t} act={t<2?'walk':'recoil'}/>
  <Bubble x={990} y={330} w={400} t={t} start={.9} end={5.8} size={44}>{toGlyphs('guten')} {toGlyphs('morgen')}</Bubble>
  <Bubble x={1420} y={458} w={285} t={t} start={2.1} end={5.8} size={44}>{toGlyphs('ja')}!</Bubble>
  <div style={{position:'absolute',left:580,top:495,color:C.paper,fontSize:50,fontFamily:serif,opacity:fade(t,2.1,5.7)}}>?</div>
 </AbsoluteFill>
}

function Counter({t}:{t:number}){
 return <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges">
  <rect x={1090} y={228} width={13} height={655} fill="#694328"/><rect x={1585} y={228} width={13} height={655} fill="#694328"/>
  <rect x={1065} y={210} width={556} height={50} fill="#8d5140"/>
  {Array.from({length:10},(_,i)=><rect key={i} x={1065+i*55} y={210} width={28} height={65} fill="#c38760"/>)}
  <rect x={1010} y={818} width={650} height={30} fill="#be8e55"/><rect x={1020} y={848} width={630} height={115} fill="#684527"/>
  {[0,1,2,3,4].map(i=><rect key={i} x={1032+i*122} y={860} width={110} height={80} fill={i%2?'#755131':'#7e5935'}/>)}
  <rect x={1000} y={810} width={670} height={12} fill="#e2ba80"/>
 </svg>
}

function BreadScene({t,again=false}:{t:number;again?:boolean}){
 const gift=again?ease((t-3.15)/1.1):ease((t-4)/1.3);
 return <AbsoluteFill>
  <Plate name="berlin" t={t} zoom={1.14} grade={.14}/>
  <Actor id="lukas" x={1350} y={904} u={15} t={t+1} act={gift>0?'offer':'point'} hideProp/>
  <Actor x={again?move(t,0,.55,660,750):730} y={939} u={14} t={t} act={again?(t<.55?'walk':t>3?'take':'talk'):(t>4?'take':'watch')}/>
  <Counter t={t}/>
  <Prop kind="loaf" x={1515} y={794} u={11}/><Prop kind="loaf" x={1270+(790-1270)*gift} y={785-90*Math.sin(gift*Math.PI)+gift*30} u={13}/>
  {again?<>
   <Bubble x={500} y={330} w={510} t={t} start={.65} end={3.1}>Brot, bitte?</Bubble>
   <Bubble x={1170} y={350} w={340} t={t} start={3.08} end={4.9}>Bitte.</Bubble>
  </>:<>
   <Bubble x={1135} y={355} w={385} t={t} start={.9} end={4.2}><span style={{color:'#8b652d'}}>Brot.</span></Bubble>
   <div style={{position:'absolute',left:540,top:280,opacity:fade(t,4.8,7,.3),color:C.paper,fontFamily:serif,fontSize:58}}>Brot <span style={{fontSize:30,color:C.gold}}>→ bread</span></div>
  </>}
 </AbsoluteFill>
}

function Journal({t}:{t:number}){
 const n=Math.floor(clamp((t-.7)/1.1)*4);
 return <AbsoluteFill style={{background:'#1d192b'}}>
  <div style={{position:'absolute',inset:'115px 205px 145px',background:C.paper,color:C.ink,boxShadow:'18px 20px 0 #080613',transform:`translateY(${px((1-ease(t/.6))*50)}px) rotate(-1deg)`}}>
   <div style={{position:'absolute',top:0,left:'50%',height:'100%',width:3,background:'#cbbd9f',boxShadow:'-12px 0 24px #b5a78b33'}}/>
   <div style={{position:'absolute',left:70,top:60,fontFamily:mono,fontSize:23,letterSpacing:3,color:'#877754'}}>THINGS I AM LEARNING</div>
   <div style={{position:'absolute',left:75,top:150,fontFamily:serif,fontSize:115}}>{'Brot'.slice(0,n)}</div>
   <div style={{position:'absolute',left:80,top:300,fontFamily:serif,fontStyle:'italic',fontSize:39,opacity:ease((t-1.6)/.4)}}>bread?</div>
   <div style={{position:'absolute',left:75,top:394,width:430,height:2,background:'#cabc9f'}}/>
   <div style={{position:'absolute',left:80,top:440,fontFamily:serif,fontSize:29,lineHeight:1.8,color:'#726b5d',opacity:ease((t-2.1)/.5)}}>He said it as he handed it over.<br/>I think I can ask next time.</div>
   <div style={{position:'absolute',left:830,top:140,width:470,height:350}}><Prop kind="loaf" x={230} y={160} u={38}/></div>
   <div style={{position:'absolute',left:830,top:490,fontFamily:mono,fontSize:23,color:'#8a795d',opacity:ease((t-2.7)/.6)}}>HEARD → UNDERSTOOD → USED</div>
   <div style={{position:'absolute',bottom:38,right:50,fontFamily:mono,fontSize:21,color:'#a39373'}}>01</div>
  </div>
 </AbsoluteFill>
}

function London({t,reflection=false,invitation=false}:{t:number;reflection?:boolean;invitation?:boolean}){
 const bg=invitation?'london-night':'london';
 return <AbsoluteFill>
  <Plate name={bg} t={t} zoom={1.12} grade={invitation?.3:.17}/>
  {invitation&&<AbsoluteFill style={{background:'#211c4166',mixBlendMode:'multiply'}}/>}
  {reflection&&<div style={{position:'absolute',left:355,top:249,width:835,height:279,background:'#0b091acf',opacity:fade(t,.2,6.9,.3)}}/>}
  {!reflection&&<Location name="London" detail={invitation?'A familiar face':'A little later'} t={t}/>}
  <Actor id="london" x={1260} y={930} u={16} t={t} act={invitation?(t>2?'wave':'watch'):reflection?'talk':t<2?'talk':t<6?'watch':'talk'} hideProp={invitation}/>
  <Actor x={invitation?move(t,2.8,5,710,960):700} y={940} u={14} t={t+1.3} act={invitation?(t>2.8?'walk':'look'):reflection?'interact':t<2?'watch':t<6?'talk':'recoil'}/>
  <Actor id="crowd1" x={move(t,0,9,1850,1630)} y={670} u={5} t={t} act="walk"/>
  <Rain t={t} intensity={invitation?22:38}/>
  {invitation?<Bubble x={1000} y={280} w={620} t={t} start={.65} end={4.7}>Coming?<br/><span style={{fontSize:43}}>I saved you a spot.</span></Bubble>:reflection?<>
   <div style={{position:'absolute',left:400,top:290,fontFamily:serif,fontSize:66,color:C.paper,opacity:fade(t,.35,6.8,.4)}}>“You alright?”</div>
   <div style={{position:'absolute',left:570,top:380,width:100,height:3,background:C.gold,opacity:fade(t,1,6.8)}}/>
   <div style={{position:'absolute',left:490,top:416,fontFamily:serif,fontSize:44,color:C.gold,opacity:fade(t,1.7,6.8)}}>Sometimes, just hello.</div>
  </>:<>
   <Bubble x={1060} y={285} w={480} t={t} start={.65} end={2.05}>You alright?</Bubble>
   <Bubble x={355} y={255} w={650} t={t} start={2.27} end={5.95} size={43}>My ship crashed.<br/>I’m quite far from home.</Bubble>
   <Bubble x={975} y={285} w={650} t={t} start={6.08} end={8.7} size={45}>I just meant hello.</Bubble>
  </>}
 </AbsoluteFill>
}

function Istanbul({t}:{t:number}){
 const give=ease((t-2.3)/1.4);
 return <AbsoluteFill>
  <Plate name="istanbul" t={t} zoom={1.12} grade={.04}/>
  <Location name="Istanbul" detail="Between the words" t={t}/>
  <Actor id="istanbul" x={1290} y={935} u={16} t={t} act={t<2.4?'offer':'watch'}/>
  <Actor x={move(t,2.4,4,690,835)} y={940} u={14} t={t+2} act={t<2.4?'watch':t<4?'take':'drink'}/>
  <Bubble x={1070} y={315} w={460} t={t} start={.7} end={2.8}>Buyurun.</Bubble>
  <Prop kind="glass" x={1210+(870-1210)*give} y={812-65*Math.sin(give*Math.PI)} u={15}/>
  <Steam x={1210+(870-1210)*give} y={791-65*Math.sin(give*Math.PI)} t={t} colour="#fff5dc"/>
  <div style={{position:'absolute',left:560,top:326,fontFamily:serif,fontStyle:'italic',fontSize:43,color:C.paper,opacity:fade(t,4.1,6.8,.3)}}>There is room for you here.</div>
 </AbsoluteFill>
}

function Tokyo({t}:{t:number}){
 return <AbsoluteFill>
  <Plate name="tokyo" t={t} zoom={1.14} grade={0}/>
  <Location name="Tokyo" detail="Learning to listen" t={t}/>
  <Actor id="tokyo" x={1260} y={940} u={17} t={t} act={t<2?'read':t<3.5?'look':'bow'} hideProp/>
  <Actor x={760} y={940} u={14} t={t+1} act={t<2.4?'watch':t<4?'bow':'look'}/>
  <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges">
   <path d="M 1570 940 L 1560 285 M 1556 550 L 1430 400 M 1558 400 L 1700 320" stroke="#65794b" strokeWidth={10} fill="none"/>
   {[0,1,2,3].map(i=><g key={i} transform={`translate(${1450+i*72},${350+((i*51)%130)}) rotate(${Math.sin(t*1.5+i)*4})`}><rect x={0} y={0} width={3} height={45} fill="#dacdb2"/><rect x={-16} y={45} width={35} height={106} fill={['#d49576','#b9a1d0','#92bba4','#dfc783'][i]}/></g>)}
  </svg>
  <div style={{position:'absolute',left:390,top:260,padding:'22px 30px',background:'#0b091ad9',color:C.paper,fontFamily:serif,fontSize:58,opacity:fade(t,2.4,5.8)}}>Listen. Respond. Remember.</div>
 </AbsoluteFill>
}

function Journey({t}:{t:number}){
 const people=[['berlin','Berlin','Kerstin'],['london','London','Nadia'],['paris','Paris','Odile'],['moscow','Moscow','Viktor'],['istanbul','Istanbul','Arda'],['mumbai','Mumbai','Omkar'],['tokyo','Tokyo','Setsuko'],['mexico','Mexico City','Rocío']];
 return <AbsoluteFill style={{background:C.night}}>
  <div style={{position:'absolute',top:150,left:0,width:'100%',textAlign:'center',fontFamily:serif,fontSize:69,color:C.paper,opacity:ease(t/.5)}}>Every city, another beginning.</div>
  <svg width={W} height={H} style={{position:'absolute',inset:0}}>
   <path d="M 225 655 C 560 545 1350 755 1690 615" fill="none" stroke="#65506f" strokeWidth={3} strokeDasharray="4 14" strokeDashoffset={-t*22}/>
  </svg>
  {people.map(([id,city,name],i)=>{const a=ease((t-i*.25-.2)/.6);return <div key={id} style={{position:'absolute',inset:0,opacity:a,transform:`translateY(${px((1-a)*26)}px)`}}>
   <Actor id={id} x={210+i*215} y={665} u={7.9} t={t+i*.6}/>
   <div style={{position:'absolute',left:100+i*215,top:713,width:220,textAlign:'center',fontFamily:sans,fontWeight:600,fontSize:28,color:C.paper}}>{name}</div>
   <div style={{position:'absolute',left:100+i*215,top:756,width:220,textAlign:'center',fontFamily:mono,fontSize:21,color:C.gold}}>{city}</div>
  </div>})}
 </AbsoluteFill>
}

function Fireworks({t}:{t:number}){
 return <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges">
  {[[430,320,.8,'#e2b45c'],[1330,270,3.2,'#bcadd9'],[940,240,5.3,'#96c3b2'],[1510,420,7.8,'#e2b45c']].map(([xx,yy,start,colour],j)=>{
   const age=t-(start as number);if(age<0||age>3.5)return null;
   const burst=clamp(age/2.1);const op=Math.pow(1-clamp(age/3.3),.8);
   return <g key={j} opacity={op}>{Array.from({length:43},(_,i)=>{
    const a=i*Math.PI*2/43;const speed=88+(i%5)*13;const r=speed*(1-Math.exp(-age*1.1));
    const x=(xx as number)+Math.cos(a)*r;const y=(yy as number)+Math.sin(a)*r+age*age*15;
    return <g key={i}><rect x={px(x/4)*4} y={px(y/4)*4} width={5} height={5} fill={colour as string}/><rect x={px((x-Math.cos(a)*13)/4)*4} y={px((y-Math.sin(a)*13)/4)*4} width={3} height={3} fill={colour as string} opacity={.45}/></g>
   })}</g>
  })}
 </svg>
}

function Belonging({t,title=false}:{t:number;title?:boolean}){
 const elapsed=title?t+7:t;
 return <AbsoluteFill style={{background:C.night}}>
  <Img src={staticFile('art/scenes/title.png')} style={{width:W,height:H,imageRendering:'pixelated',opacity:.85}}/>
  <Fireworks t={elapsed}/>
  <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges">
   <rect x={0} y={869} width={W} height={211} fill="#192923"/><rect x={0} y={938} width={W} height={50} fill="#443d3b"/>
   <rect x={638} y={863} width={644} height={20} fill="#917253"/><rect x={660} y={882} width={25} height={87} fill="#372c2c"/><rect x={1235} y={882} width={25} height={87} fill="#372c2c"/>
   <rect x={650} y={810} width={620} height={16} fill="#806148"/>
  </svg>
  <Actor x={825} y={883} u={8.5} t={elapsed} act="sit" hideProp back/>
  <Actor id="london" x={1090} y={883} u={9.5} t={elapsed+1} act="sit" hideProp back/>
  <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges"><rect x={650} y={813} width={620} height={18} fill="#947456"/><rect x={650} y={843} width={620} height={18} fill="#7e5d44"/></svg>
  <Steam x={945} y={805} t={elapsed} scale={.55}/>
  {title&&<>
   <AbsoluteFill style={{background:'linear-gradient(#0b091a55,#0b091a22)',opacity:ease(t/.8)}}/>
   <div style={{position:'absolute',left:360,top:155,width:1200,opacity:ease(t/1.1),transform:`translateY(${px((1-ease(t/1.1))*20)}px)`}}><Img src={staticFile('art/ui/wordmark.png')} style={{width:'100%',imageRendering:'pixelated'}}/></div>
   <div style={{position:'absolute',left:250,right:250,top:526,textAlign:'center',fontFamily:serif,fontSize:48,color:C.paper,opacity:ease((t-1.2)/.8)}}>A world to learn. A place to belong.</div>
   <div style={{position:'absolute',left:250,right:250,top:605,textAlign:'center',fontFamily:sans,fontSize:27,color:'#c7bfd7',opacity:ease((t-2.1)/.7)}}>A narrative game about language, culture and connection.</div>
  </>}
 </AbsoluteFill>
}

export const Connection:React.FC=()=>{
 const f=useCurrentFrame();const time=f/30;
 let content:React.ReactNode=null;
 let start=0,end=9;
 if(time<9)content=<Dictionary t={time}/>;
 else if(time<10){start=9;end=10;content=null;}
 else if(time<17){start=10;end=17;content=<Arrival t={time-start}/>;}
 else if(time<23){start=17;end=23;content=<Lost t={time-start}/>;}
 else if(time<30){start=23;end=30;content=<BreadScene t={time-start}/>;}
 else if(time<35){start=30;end=35;content=<Journal t={time-start}/>;}
 else if(time<40){start=35;end=40;content=<BreadScene t={time-start} again/>;}
 else if(time<49){start=40;end=49;content=<London t={time-start}/>;}
 else if(time<56){start=49;end=56;content=<London t={time-start} reflection/>;}
 else if(time<63){start=56;end=63;content=<Istanbul t={time-start}/>;}
 else if(time<69){start=63;end=69;content=<Tokyo t={time-start}/>;}
 else if(time<75){start=69;end=75;content=<Journey t={time-start}/>;}
 else if(time<80){start=75;end=80;content=<London t={time-start} invitation/>;}
 else if(time<87){start=80;end=87;content=<Belonging t={time-start}/>;}
 else {start=87;end=95;content=<Belonging t={time-start} title/>;}
 const subtitles=CUES.filter(c=>c.voice==='en-GB-SoniaNeural'&&!['title'].includes(c.id));
 const cue=subtitles.find(c=>time>=c.start-.04&&time<c.end+.35);
 const soft=[10,17,30,56,63,69,75,80].includes(start);
 const sceneOpacity=time<9?1:time>=87?clamp((95-time)/.9):soft?fade(time,start,end,.2):1;
 return <AbsoluteFill style={{background:C.night,fontFamily:sans}}>
  <AbsoluteFill style={{opacity:sceneOpacity}}>{content}</AbsoluteFill>
  {time>=10&&<><div style={{position:'absolute',top:0,width:'100%',height:82,background:C.night}}/><div style={{position:'absolute',bottom:0,width:'100%',height:88,background:C.night}}/></>}
  {cue&&<div style={{position:'absolute',left:160,right:160,bottom:26,textAlign:'center',color:C.paper,fontSize:32,fontWeight:400,letterSpacing:.25,opacity:fade(time,cue.start-.05,cue.end+.35,.12)}}>{cue.text}</div>}
  <Audio src={asset('soundtrack.wav')}/>
 </AbsoluteFill>
};
