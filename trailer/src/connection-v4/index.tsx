import React from 'react';
import {Composition,registerRoot} from 'remotion';
import {Connection} from './Connection';
const Root:React.FC=()=> <Composition id="ConnectionV4" component={Connection} width={1920} height={1080} fps={30} durationInFrames={3645}/>;
registerRoot(Root);
