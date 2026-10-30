import React from 'react';
import {AbsoluteFill,useCurrentFrame} from 'remotion';
import {Actor} from './Connection';
export const CastReview:React.FC=()=>{
 const t=useCurrentFrame()/30;
 const ids=['alien','london','tokyo','berlin','istanbul','paris','moscow','mumbai'];
 const acts=['look','recoil','bow','point','wave','stand'];
 const act=acts[Math.floor(t/2)%acts.length];
 return <AbsoluteFill style={{background:'#0b0a1c'}}>
  <div style={{color:'#e8e4f4',fontSize:40,position:'absolute',left:80,top:40}}>Motion inspection — {act}</div>
  {ids.map((id,i)=><Actor key={id} id={id} x={260+(i%4)*465} y={530+Math.floor(i/4)*455} u={14} t={t} act={act} hideProp/>)}
 </AbsoluteFill>;
};
