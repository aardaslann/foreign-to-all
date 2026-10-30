import React from 'react';
import {Composition,registerRoot} from 'remotion';
import {Connection} from './Connection';
import {INTRO} from './intro';
const Root:React.FC=()=> <Composition id="ConnectionV5" component={Connection} width={1920} height={1080} fps={30} durationInFrames={Math.round(INTRO.duration*30)}/>;
registerRoot(Root);
