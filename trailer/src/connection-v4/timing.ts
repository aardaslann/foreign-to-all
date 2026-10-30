export type ReadingCue={start:number;end:number;text:string;y:number;size:number;x?:number;w?:number;align?:'left'|'center'};
export const READING:ReadingCue[]=[
 {start:14.9,end:20.2,text:'You arrive on Earth\nwith nothing but questions.',y:160,size:68},
 {start:20.85,end:25.25,text:'Unfamiliar words.\nUnwritten rules.',y:150,size:70,x:135,w:770,align:'left'},
 {start:25.9,end:30.1,text:'A word begins a conversation.',y:154,size:69},
 {start:32.9,end:37.2,text:'Listen. Notice. Try.',y:154,size:72},
 {start:51.85,end:57.2,text:'Knowing the words\nis only the beginning.',y:170,size:74},
 {start:60.85,end:66.15,text:'A cup of tea.\nA way of welcoming you.',y:160,size:72},
 {start:66.9,end:71.1,text:'Share in the traditions.',y:155,size:75},
 {start:71.5,end:76.2,text:'Discover the stories\nthey carry.',y:150,size:75},
 {start:76.9,end:81.7,text:'A stereotype reduces\na person to a label.',y:145,size:72},
 {start:82.05,end:88.2,text:'Get to know what\nit leaves out.',y:145,size:76},
 {start:104,end:108.2,text:'You may still be foreign.',y:155,size:76},
 {start:108.5,end:113.15,text:'But you can still\nunderstand.',y:155,size:78},
];
export {DEFINITION,TITLE_KEYS,BODY_KEYS,CLICK_AT} from '../connection-v3/timing';
export const STORY_AT=14.5;
