// One connected mesh. Eyes stay in their original sockets; the whole face
// carries a look. Never move white pixels independently of their pupils.
export type Pixel={x:number;y:number;ch:string};
const clamp=(x:number,a:number,b:number)=>Math.max(a,Math.min(b,x));
export function actorPixels(rows:string[],pose:string,t:number,seed:number,elder:boolean,dips:Record<string,number>,leans:Record<string,number>,back=false,alien=false):Pixel[]{
 const seated=['sit','kneel','squat'].includes(pose);
 const breath=Math.sin(t*.55+seed*1.7)>.8?1:0;
 const dip=clamp((dips[pose]||0)+breath+(elder?1:0),-1,2);
 const lean=clamp((leans[pose]||0)+(elder?-1:0),-1,1);
 const blink=((t+seed*.47)%5.2)>5.02;
 const step=pose==='walk'&&Math.sin(t*6+seed)>0?1:0;
 const pixels:Pixel[]=[];
 const rowOffsets=(r:number)=>({
  // The collar (row 15) stays with the coat. Its join is extended when the
  // head lifts. Lowering the head is drawn over the coat, so no seam opens.
  dx:r<=14?lean:0,
  dy:(seated?2:0)+(r<=14?dip:0)-(r>=23?step:0),
 });
 for(let r=0;r<(seated?23:26);r++){
  const {dx,dy}=rowOffsets(r);
  for(let c=0;c<rows[r].length;c++){
   let ch=rows[r][c];
   if(ch==='.')continue;
   if(blink&&(ch==='E'||ch==='W'))ch='S';
   if(back&&r<=14&&ch!=='X')ch=alien?'S':'R';
   // Draw the lifted neck through the original collar; interior colour is
   // sampled from that character's native row, preserving its wardrobe.
   if(r===15&&dip<0&&c>=4&&c<=11){
    for(let yy=dip;yy<0;yy++)pixels.push({x:c-8,y:r-26+(seated?2:0)+yy,ch});
   }
   pixels.push({x:c-8+dx,y:r-26+dy,ch});
  }
 }
 return pixels;
}
