import React from 'react';
import {Composition,registerRoot} from 'remotion';
import {Connection} from './Connection';
const Root:React.FC=()=> <Composition id="ConnectionV2" component={Connection} width={1920} height={1080} fps={30} durationInFrames={3240}/>;
registerRoot(Root);
