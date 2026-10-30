// Every composition the Steam page needs, registered once in Root.tsx.
import React from 'react';
import {Composition} from 'remotion';
import {SteamStills} from './Capsules';
import {AboutHero, HERO} from './Hero';
import {Gameplay, GAMEPLAY_FRAMES} from './Gameplay';

const FPS = 30;

export const Steam: React.FC = () => (
	<>
		<SteamStills />
		<Composition id="SteamAboutHero" component={AboutHero} durationInFrames={HERO.seconds * FPS} fps={FPS} width={HERO.width} height={HERO.height} />
		<Composition id="SteamGameplayTrailer" component={Gameplay} durationInFrames={GAMEPLAY_FRAMES} fps={FPS} width={1920} height={1080} />
	</>
);
