// The research-paper gameplay video, with captions and clean, registered once in Root.tsx.
import React from 'react';
import {Composition} from 'remotion';
import {RESEARCH_FRAMES, ResearchGameplay, ResearchGameplayClean} from './Gameplay';

const FPS = 30;

export const Research: React.FC = () => (
	<>
		<Composition id="ResearchGameplay" component={ResearchGameplay} durationInFrames={RESEARCH_FRAMES} fps={FPS} width={1920} height={1080} />
		<Composition id="ResearchGameplayClean" component={ResearchGameplayClean} durationInFrames={RESEARCH_FRAMES} fps={FPS} width={1920} height={1080} />
	</>
);
