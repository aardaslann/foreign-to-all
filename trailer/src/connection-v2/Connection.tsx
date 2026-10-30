import React from 'react';
import {AbsoluteFill, Audio, Img, staticFile, useCurrentFrame} from 'remotion';
import {CAST} from '../connection/data';
import {P} from '../lib/palette';
import {READING,DEFINITION,TITLE_KEYS} from './timing';
import {toGlyphs} from '../lib/glyphs';

// Authentic character grids exported by Godot from CharacterArt + Cast + Wardrobe.
// All animation is frame driven; no generated illustrations are used in this film.
const W=1920,H=1080;
const C={paper:P.ink,ink:P.void,dim:P.inkMuted,gold:P.amber,teal:'#47837c',night:P.void,lavender:'#c3b2de'};
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

function Stage({kind,t}:{kind:string;t:number}){
 const lamp=kind==='london'?1650:kind==='berlin'?1510:210;
 const night=kind==='night';
 return <AbsoluteFill style={{background:C.night}}>
  <svg width={W} height={H} shapeRendering="crispEdges" style={{position:'absolute',inset:0}}>
   <rect x={0} y={590} width={W} height={410} fill={P.skyMid}/>
   <rect x={0} y={922} width={W} height={78} fill="#201c34"/>
   <rect x={0} y={922} width={W} height={4} fill={P.border} opacity={.5}/>
   {[0,1,2,3,4,5,6,7].map(i=><g key={i} opacity={.28}>
    <rect x={i*260-50} y={535-(i%3)*26} width={180+(i%2)*40} height={387+(i%3)*26} fill={P.facade2}/>
    {[0,1,2].map(j=><rect key={j} x={i*260+j*40-20} y={570-(i%3)*26} width={14} height={20} fill={i%3===1?P.amber:P.border}/>)}</g>)}
   {kind!=='istanbul'&&kind!=='tokyo'&&<g>
    <polygon points={`${lamp-18},468 ${lamp+18},468 ${lamp+210},925 ${lamp-210},925`} fill={P.amber} opacity={night?.05:.035}/>
    <rect x={lamp-5} y={444} width={10} height={482} fill="#524766"/>
    <rect x={lamp-27} y={435} width={54} height={45} fill={P.border}/>
    <rect x={lamp-19} y={443} width={38} height={28} fill={P.amber}/>
    <rect x={lamp-32} y={431} width={64} height={8} fill="#6d5d82"/>
   </g>}
   {kind==='istanbul'&&<g>
    <path d="M 1530 923 V 605 H 1545 V 580 H 1570 V 555 H 1710 V 580 H 1735 V 605 H 1750 V 923" stroke="#55445e" strokeWidth={18} fill={P.facade}/>
    <rect x={1628} y={602} width={22} height={43} fill={P.amber} opacity={.8}/>
    <rect x={940} y={865} width={150} height={12} fill="#997153"/><rect x={962} y={877} width={10} height={48} fill="#5e4552"/><rect x={1060} y={877} width={10} height={48} fill="#5e4552"/>
   </g>}
   {kind==='tokyo'&&<g opacity={.58}>
    <rect x={135} y={626} width={330} height={295} fill={P.facade2}/>
    <rect x={164} y={671} width={272} height={136} fill="#776449" opacity={.3}/>
    {[0,1,2,3,4,5].map(i=><rect key={i} x={166+i*52} y={635} width={6} height={286} fill="#5e5166"/>)}
    <rect x={160} y={691} width={278} height={6} fill="#5e5166"/><rect x={160} y={754} width={278} height={6} fill="#5e5166"/>
   </g>}
  </svg>
 </AbsoluteFill>
}

function Reading({time}:{time:number}){
 const c=READING.find(c=>time>=c.start&&time<c.end);if(!c)return null;
 const a=fade(time,c.start,c.end,.35);
 return <div style={{position:'absolute',left:c.x??200,top:c.y,width:c.w??1520,whiteSpace:'pre-line',fontFamily:serif,fontSize:c.size,lineHeight:1.24,textAlign:(c.align??'center') as 'left'|'center',color:C.paper,opacity:a,transform:`translateY(${px((1-ease((time-c.start)/.5))*10)}px)`}}>{c.text}</div>
}

function Location({name,detail,t}:{name:string;detail:string;t:number}){
 return <div style={{position:'absolute',left:108,top:119,opacity:fade(t,.25,4.7,.4),color:C.paper}}>
  <div style={{fontFamily:sans,fontWeight:600,letterSpacing:6,fontSize:26}}>{name.toUpperCase()}</div>
  <div style={{fontFamily:serif,fontStyle:'italic',fontSize:24,marginTop:9,color:'#ddd1bd'}}>{detail}</div>
 </div>
}

function Bubble({x,y,w=430,children,t,start,end,tail='left',dark=true,size=52}:{x:number;y:number;w?:number;children:React.ReactNode;t:number;start:number;end:number;tail?:'left'|'right';dark?:boolean;size?:number}){
 const a=fade(t,start,end,.16);if(!a)return null;
 const bg=dark?P.panel:C.paper;
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
 const n=TITLE_KEYS.filter(x=>x<=t).length;
 return <AbsoluteFill style={{background:C.night,color:C.paper}}>
  <div style={{position:'absolute',left:270,top:162,fontFamily:serif,fontSize:140,letterSpacing:-5}}>{'sonder'.slice(0,n)}<span style={{fontFamily:mono,fontSize:100,color:C.lavender,opacity:t<1.8&&Math.floor(t*3)%2===0?1:0}}>▏</span></div>
  <div style={{position:'absolute',left:276,top:345,fontFamily:mono,fontSize:28,color:P.inkMuted,opacity:ease((t-1.5)/.4)}}>[sohn-durr] <span style={{marginLeft:32,fontFamily:serif,fontStyle:'italic'}}>noun</span></div>
  <div style={{position:'absolute',left:276,top:414,width:126,height:4,background:P.amber,transform:`scaleX(${ease((t-1.8)/.45)})`,transformOrigin:'left'}}/>
  <div style={{position:'absolute',left:276,top:465,width:1360,fontFamily:serif,fontSize:54,lineHeight:1.48,opacity:ease((t-2.2)/.65)}}>{DEFINITION}</div>
  <div style={{position:'absolute',left:276,right:276,bottom:160,height:2,background:P.border,opacity:.45}}/>
 </AbsoluteFill>
}

function Arrival({t}:{t:number}){
 const ax=move(t,3.7,6.5,860,1110);
 return <AbsoluteFill>
  <Stage kind="arrival" t={t}/>
  <svg width={W} height={H} shapeRendering="crispEdges" style={{position:'absolute',inset:0}}>
   <rect x={305} y={910} width={450} height={17} fill="#080715"/>
   <path d="M 340 881 V 780 H 363 V 754 H 399 V 729 H 663 V 754 H 699 V 780 H 722 V 881 Z" fill="#37324b" stroke="#4c435f" strokeWidth={10}/>
   <rect x={437} y={761} width={181} height={47} fill="#18182c"/><rect x={453} y={773} width={144} height={23} fill="#716a96" opacity={.6}/>
   <path d="M 656 754 v 45 h -14 v 28 h 13 v 29 h -10 v 27" stroke="#8bb7ae" strokeWidth={5} fill="none"/>
   <rect x={351} y={882} width={360} height={19} fill="#252133"/>
   <rect x={402} y={900} width={37} height={16} fill="#302b40"/><rect x={634} y={900} width={37} height={16} fill="#302b40"/>
  </svg>
  <Actor x={ax} y={939} u={12} t={t} act={t<2.8?'look':t<3.7?'stand':'walk'}/>
  <Steam x={652} y={755} t={t} colour="#80788e" scale={1.1}/>
 </AbsoluteFill>
}

function Lost({t}:{t:number}){
 return <AbsoluteFill>
  <Stage kind="berlin" t={t}/>
  
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
  <rect x={1090} y={365} width={13} height={518} fill="#694328"/><rect x={1585} y={365} width={13} height={518} fill="#694328"/>
  <rect x={1065} y={349} width={556} height={42} fill="#8d5140"/>
  {Array.from({length:10},(_,i)=><rect key={i} x={1065+i*55} y={349} width={28} height={54} fill="#c38760"/>)}
  <rect x={1010} y={818} width={650} height={30} fill="#be8e55"/><rect x={1020} y={848} width={630} height={115} fill="#684527"/>
  {[0,1,2,3,4].map(i=><rect key={i} x={1032+i*122} y={860} width={110} height={80} fill={i%2?'#755131':'#7e5935'}/>)}
  <rect x={1000} y={810} width={670} height={12} fill="#e2ba80"/>
 </svg>
}

function BreadScene({t,again=false}:{t:number;again?:boolean}){
 const gift=again?ease((t-3.15)/1.1):ease((t-4)/1.3);
 return <AbsoluteFill>
  <Stage kind="berlin" t={t}/>
  <Actor id="lukas" x={1350} y={904} u={15} t={t+1} act={gift>0?'offer':'point'} hideProp/>
  <Actor x={again?move(t,0,.55,660,750):730} y={939} u={14} t={t} act={again?(t<.55?'walk':t>3?'take':'talk'):(t>4?'take':'watch')}/>
  <Counter t={t}/>
  <Prop kind="loaf" x={1515} y={794} u={11}/><Prop kind="loaf" x={1270+(790-1270)*gift} y={785-90*Math.sin(gift*Math.PI)+gift*30} u={13}/>
  {again?<>
   <Bubble x={500} y={330} w={510} t={t} start={.65} end={3.1}>Brot, bitte?</Bubble>
   <Bubble x={1170} y={350} w={340} t={t} start={3.08} end={4.9}>Bitte.</Bubble>
  </>:<>
   <Bubble x={1135} y={432} w={385} t={t} start={.9} end={4.2}><span style={{color:C.gold}}>Brot.</span></Bubble>
   <div style={{position:'absolute',left:510,top:350,opacity:fade(t,4.8,7,.3),color:C.paper,fontFamily:serif,fontSize:58}}>Brot <span style={{fontSize:44,color:C.gold}}>→ bread</span></div>
  </>}
 </AbsoluteFill>
}

function Journal({t}:{t:number}){
 return <AbsoluteFill style={{background:C.night}}>
  <div style={{position:'absolute',left:270,top:320,width:1380,height:550,background:P.panel,border:'3px solid '+P.border,opacity:ease(t/.5)}}>
   <div style={{position:'absolute',left:94,top:66,color:P.inkMuted,fontFamily:mono,fontSize:25,letterSpacing:3}}>A WORD TO KEEP</div>
   <div style={{position:'absolute',left:90,top:144,color:C.paper,fontFamily:serif,fontSize:132}}>Brot</div>
   <div style={{position:'absolute',left:100,top:330,color:C.gold,fontFamily:serif,fontSize:54,opacity:ease((t-1.0)/.6)}}>bread</div>
   <div style={{position:'absolute',left:100,top:436,color:P.inkMuted,fontFamily:sans,fontSize:31,opacity:ease((t-2.1)/.6)}}>Next time, you can ask.</div>
   <div style={{position:'absolute',left:682,top:76,width:3,height:390,background:P.border,opacity:.5}}/>
   <Prop kind="loaf" x={1025} y={285} u={39}/>
  </div>
 </AbsoluteFill>
}

function London({t,reflection=false,invitation=false}:{t:number;reflection?:boolean;invitation?:boolean}){
 return <AbsoluteFill>
  <Stage kind={invitation?'night':'london'} t={t}/>
  {!reflection&&<Location name="London" detail={invitation?'A familiar face':'A little later'} t={t}/>}
  <Actor id="london" x={1260} y={930} u={16} t={t} act={invitation?(t>2?'wave':'watch'):reflection?'talk':t<2?'talk':t<6?'watch':'talk'} hideProp={invitation}/>
  <Actor x={invitation?move(t,2.8,5,710,960):700} y={940} u={14} t={t+1.3} act={invitation?(t>2.8&&t<5?'walk':'look'):reflection?'interact':t<2?'watch':t<6?'talk':'recoil'}/>
  <Rain t={t} intensity={invitation?12:24}/>
  {invitation?<Bubble x={1000} y={280} w={660} t={t} start={.65} end={5.6}>Coming?<br/><span style={{fontSize:47}}>I saved you a spot.</span></Bubble>:!reflection&&<>
   <Bubble x={1060} y={285} w={480} t={t} start={.65} end={2.1}>You alright?</Bubble>
   <Bubble x={355} y={255} w={685} t={t} start={2.27} end={5.95} size={47}>My ship crashed.<br/>I’m quite far from home.</Bubble>
   <Bubble x={975} y={285} w={690} t={t} start={6.08} end={8.85} size={49}>I just meant hello.</Bubble>
  </>}
 </AbsoluteFill>
}

function Istanbul({t}:{t:number}){
 const give=ease((t-2.3)/1.4);
 return <AbsoluteFill>
  <Stage kind="istanbul" t={t}/>
  <Location name="Istanbul" detail="" t={t}/>
  <Actor id="istanbul" x={1290} y={935} u={16} t={t} act={t<2.4?'offer':'watch'}/>
  <Actor x={move(t,2.4,4,690,835)} y={940} u={14} t={t+2} act={t<2.4?'watch':t<4?'take':'drink'}/>
  <Bubble x={1070} y={315} w={460} t={t} start={.7} end={2.8}>Buyurun.</Bubble>
  <Prop kind="glass" x={1210+(870-1210)*give} y={812-65*Math.sin(give*Math.PI)} u={15}/>
  <Steam x={1210+(870-1210)*give} y={791-65*Math.sin(give*Math.PI)} t={t} colour="#fff5dc"/>
 </AbsoluteFill>
}

function Tokyo({t}:{t:number}){
 return <AbsoluteFill>
  <Stage kind="tokyo" t={t}/>
  
  <Actor id="tokyo" x={1260} y={940} u={17} t={t} act={t<2?'read':t<3.5?'look':'bow'} hideProp/>
  <Actor x={760} y={940} u={14} t={t+1} act={t<2.4?'watch':t<4?'bow':'look'}/>
  <svg width={W} height={H} style={{position:'absolute',inset:0}} shapeRendering="crispEdges">
   <path d="M 1570 940 L 1560 285 M 1556 550 L 1430 400 M 1558 400 L 1700 320" stroke="#65794b" strokeWidth={10} fill="none"/>
   {[0,1,2,3].map(i=><g key={i} transform={`translate(${1450+i*72},${350+((i*51)%130)}) rotate(${Math.sin(t*1.5+i)*4})`}><rect x={0} y={0} width={3} height={45} fill="#dacdb2"/><rect x={-16} y={45} width={35} height={106} fill={['#d49576','#b9a1d0','#92bba4','#dfc783'][i]}/></g>)}
  </svg>
 </AbsoluteFill>
}

function Journey({t}:{t:number}){
 const people=[['berlin','Berlin','Kerstin'],['london','London','Nadia'],['paris','Paris','Odile'],['moscow','Moscow','Viktor'],['istanbul','Istanbul','Arda'],['mumbai','Mumbai','Omkar'],['tokyo','Tokyo','Setsuko'],['mexico','Mexico City','Rocío']];
 return <AbsoluteFill style={{background:C.night}}>
  <div style={{position:'absolute',top:150,left:0,width:'100%',textAlign:'center',fontFamily:serif,fontSize:73,color:C.paper,opacity:ease(t/.5)}}>Across cities. Across cultures.</div>
  <div style={{position:'absolute',top:272,width:'100%',textAlign:'center',fontFamily:serif,fontSize:57,color:C.lavender,opacity:ease((t-2.6)/.6)}}>Lives that become part of yours.</div>
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
  {[[430,470,.8,'#e2b45c'],[1450,440,3.2,'#bcadd9'],[960,500,5.3,'#96c3b2'],[1510,530,7.8,'#e2b45c']].map(([xx,yy,start,colour],j)=>{
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
 const elapsed=title?t+10:t;
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
 const time=useCurrentFrame()/30;
 let content:React.ReactNode=null;
 let start=0,end=12;
 if(time<12)content=<Dictionary t={time}/>;
 else if(time<13){start=12;end=13;}
 else if(time<20){start=13;end=20;content=<Arrival t={time-start}/>;}
 else if(time<26){start=20;end=26;content=<Lost t={time-start}/>;}
 else if(time<33){start=26;end=33;content=<BreadScene t={time-start}/>;}
 else if(time<39){start=33;end=39;content=<Journal t={time-start}/>;}
 else if(time<44){start=39;end=44;content=<BreadScene t={time-start} again/>;}
 else if(time<53){start=44;end=53;content=<London t={time-start}/>;}
 else if(time<62){start=53;end=62;content=<London t={time-start} reflection/>;}
 else if(time<69){start=62;end=69;content=<Istanbul t={time-start}/>;}
 else if(time<76){start=69;end=76;content=<Tokyo t={time-start}/>;}
 else if(time<84){start=76;end=84;content=<Journey t={time-start}/>;}
 else if(time<90){start=84;end=90;content=<London t={time-start} invitation/>;}
 else if(time<100){start=90;end=100;content=<Belonging t={time-start}/>;}
 else {start=100;end=108;content=<Belonging t={time-start} title/>;}
 const soft=[13,20,33,62,69,76,84,90].includes(start);
 const opacity=time<12?clamp((12-time)/.35):time>=100?clamp((108-time)/.9):soft?fade(time,start,end,.22):1;
 return <AbsoluteFill style={{background:C.night,fontFamily:sans}}>
  <AbsoluteFill style={{opacity}}>{content}</AbsoluteFill>
  {time>=13&&<><div style={{position:'absolute',top:0,width:'100%',height:82,background:C.night}}/><div style={{position:'absolute',bottom:0,width:'100%',height:88,background:C.night}}/></>}
  <Reading time={time}/>
  <Audio src={staticFile('connection-v2/soundtrack.wav')}/>
 </AbsoluteFill>
};
