import React from 'react';
import {Composition,registerRoot} from 'remotion';
import {Connection} from './Connection';
import {CastReview} from './CastReview';
const Root:React.FC=()=> <>
 <Composition id="ConnectionV3" component={Connection} width={1920} height={1080} fps={30} durationInFrames={3480}/>
 <Composition id="CastReview" component={CastReview} width={1920} height={1080} fps={30} durationInFrames={360}/>
</>;
registerRoot(Root);
