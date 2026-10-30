// These are reading windows, independent of the character speech cues.
export const READING = [
 {start:13.5,end:19.7,text:'You arrive on Earth\nwith nothing but questions.',y:160,size:68},
 {start:20.5,end:25.7,text:'No translator.\nNo familiar voice.',y:150,size:70,x:135,w:770,align:'left'},
 {start:26.4,end:30.5,text:'Begin with one word.',y:154,size:72},
 {start:33.45,end:38.7,text:'Listen. Notice. Try.',y:140,size:72},
 {start:53.35,end:57.65,text:'Knowing the words\nis only the beginning.',y:170,size:74},
 {start:58,end:61.75,text:'People mean more\nthan they say.',y:170,size:74},
 {start:65.2,end:68.7,text:'An invitation\nyou almost missed.',y:160,size:70},
 {start:69.55,end:75.6,text:'Learn languages\nby living them.',y:155,size:76},
 {start:90.5,end:94.7,text:'You may still be foreign.',y:155,size:76},
 {start:95,end:99.65,text:'But you don’t have\nto be alone.',y:155,size:78},
];

export const DEFINITION = 'the profound realization that every random stranger is living a life as vivid, complex, and central to them as your own is to you.';
// Key sounds and glyph reveals use this same deterministic sequence.
export function keyTimes(text:string,start:number,end:number):number[]{
 const gaps=Array.from(text, (c,i)=>.75+((i*37)%11)/20+(c===' '?.25:0)+(/[,.]/.test(c)?1.3:0));
 const scale=(end-start)/gaps.reduce((a,b)=>a+b,0);
 let now=start;
 return gaps.map(g=>{now+=g*scale;return now});
}
export const TITLE_KEYS=keyTimes('sonder',.4,1.2);
export const BODY_KEYS=keyTimes(DEFINITION,2.2,7.3);
