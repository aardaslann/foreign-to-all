const fs=require('node:fs');
const path=require('node:path');
const Module=require('node:module');
const ts=require('typescript');
const code=fs.readFileSync(path.join(__dirname,'actorGeometry.ts'),'utf8');
const compiled=ts.transpileModule(code,{compilerOptions:{module:ts.ModuleKind.CommonJS}}).outputText;
const m=new Module('actorGeometry',module);m._compile(compiled,'actorGeometry.cjs');
const {actorPixels}=m.exports;
const cast=JSON.parse(fs.readFileSync(path.join(__dirname,'../../public/connection/cast.json'),'utf8'));
let checked=0;
const failures=[];
// Connectivity is checked on the occupied pixel mesh, independent of colours.
// A path must join face centre to coat centre under every pose/phase tested.
function linked(pixels){
 const occupied=new Set(pixels.map(p=>`${p.x},${p.y}`));
 const top=pixels.find(p=>p.x>=-2&&p.x<=2&&p.y>=-17&&p.y<=-14);
 if(!top)return false;
 const queue=[[top.x,top.y]],seen=new Set([`${top.x},${top.y}`]);
 for(let i=0;i<queue.length;i++){
  const [x,y]=queue[i];if(y>=-7&&Math.abs(x)<=4)return true;
  for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){
   const k=`${x+dx},${y+dy}`;
   if(occupied.has(k)&&!seen.has(k)){seen.add(k);queue.push([x+dx,y+dy]);}
  }
 }
 return false;
}
for(const [id,p] of Object.entries(cast.people)){
 const seed=[...id].reduce((a,b)=>a+b.charCodeAt(0),0)%31;
 for(const pose of ['stand','look','recoil','wave','bow','read','point','walk','take','offer','sit','drink']){
  for(let f=0;f<360;f++){
   const t=f/30;
   const pixels=actorPixels(p.rows,pose,t,seed,p.build==='elder',cast.dip,cast.lean);
   if(!linked(pixels))failures.push({id,pose,t});
   // Whites and pupils must preserve the source socket geometry up to a
   // shared translation, or close together in a blink.
   const source=[];p.rows.forEach((r,y)=>[...r].forEach((ch,x)=>{if(ch==='E'||ch==='W')source.push({x,y,ch})}));
   const eye=pixels.filter(v=>v.ch==='E'||v.ch==='W');
   if(eye.length&&source.length){
    const dx=eye[0].x-source[0].x,dy=eye[0].y-source[0].y;
    if(eye.length!==source.length||eye.some((v,i)=>v.x!==source[i].x+dx||v.y!==source[i].y+dy||v.ch!==source[i].ch))failures.push({id,pose,t,error:'eye geometry'});
   }
   checked++;
  }
 }
}
console.log(JSON.stringify({checkedPoseFrames:checked,failures:failures.length,examples:failures.slice(0,8)},null,2));
if(failures.length)process.exit(1);
