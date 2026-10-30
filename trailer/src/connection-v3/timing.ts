export type ReadingCue={start:number;end:number;text:string;y:number;size:number;x?:number;w?:number;align?:'left'|'center'};
export const READING:ReadingCue[]=[
 {start:14.4,end:19.7,text:'You arrive on Earth\nwith nothing but questions.',y:160,size:68},
 {start:20.35,end:24.75,text:'Unfamiliar words.\nUnwritten rules.',y:150,size:70,x:135,w:770,align:'left'},
 {start:25.4,end:29.6,text:'A word begins a conversation.',y:154,size:69},
 {start:46.35,end:51.7,text:'Knowing the words\nis only the beginning.',y:170,size:74},
 {start:55.35,end:60.65,text:'A cup of tea.\nA way of welcoming you.',y:160,size:72},
 {start:61.4,end:65.6,text:'Share in the traditions.',y:155,size:75},
 {start:66,end:70.7,text:'Discover the stories\nthey carry.',y:150,size:75},
 {start:71.4,end:76.2,text:'A stereotype reduces\na person to a label.',y:145,size:72},
 {start:76.55,end:82.7,text:'Get to know what\nit leaves out.',y:145,size:76},
 {start:98.5,end:102.7,text:'You may still be foreign.',y:155,size:76},
 {start:103,end:107.65,text:'But you can still\nunderstand.',y:155,size:78},
];
export const DEFINITION='the profound realization that every random stranger is living a life as vivid, complex, and central to them as your own is to you.';
export function keyTimes(text:string,start:number,end:number):number[]{
 const gaps=Array.from(text,(c,i)=>.75+((i*37)%11)/20+(c===' '?.25:0)+(/[,.]/.test(c)?1.3:0));
 const scale=(end-start)/gaps.reduce((a,b)=>a+b,0);
 let now=start;
 return gaps.map(g=>{now+=g*scale;return now});
}
export const TITLE_KEYS=keyTimes('sonder',.4,1.2);
export const BODY_KEYS=keyTimes(DEFINITION,2.2,7.3);
export const CLICK_AT=12.5;
export const STORY_AT=14;
