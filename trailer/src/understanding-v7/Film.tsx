// Foreign to All — Understanding, revision 7. Revision 5's film (its opening,
// its pace, its piano, its letterbox and captions, its bench) rebuilt on the
// game's retro scene art, its own renderer's people and its characters' voices.
import React from 'react';
import {AbsoluteFill, Sequence, staticFile, useCurrentFrame} from 'remotion';
import {Audio} from '@remotion/media';
import {C, FPS, T, at, f, scene, CaptionShade, Captions, Letterbox, type SceneId} from './lib/core';
import {Arrival, Sonder} from './scenes/Opening';
import {Bitte, Brot, Journal, Unfamiliar} from './scenes/Berlin';
import {Istanbul, London, Tokyo} from './scenes/Journey';
import {People, Stereotype} from './scenes/Turn';
import {BenchScene, Invitation} from './scenes/Finale';

export const DURATION = f(T.duration);

// "black" has no picture: the shutter closes on it.
const SCENES: [SceneId, React.FC][] = [
	['sonder', Sonder], ['arrival', Arrival], ['unfamiliar', Unfamiliar], ['brot', Brot], ['journal', Journal],
	['bitte', Bitte], ['london', London], ['istanbul', Istanbul], ['tokyo', Tokyo], ['stereotype', Stereotype],
	['people', People], ['invitation', Invitation], ['bench', BenchScene],
];

/** Revision 5's soft changes of place: a quick breath through the night colour. */
const SOFT = (['london', 'istanbul', 'tokyo', 'stereotype', 'people', 'invitation'] as SceneId[]).map((id) => T.scenes[id][0]);
const breath = (t: number) => Math.max(0, ...SOFT.map((cut) => (t < cut ? at(t, [cut - 0.22, cut], [0, 1]) : at(t, [cut, cut + 0.3], [1, 0]))));

export const UnderstandingV7: React.FC = () => {
	const t = useCurrentFrame() / FPS;
	return (
		<AbsoluteFill style={{background: '#000'}}>
			{SCENES.map(([id, Scene]) => {
				const s = scene(id);
				return (
					<Sequence key={id} name={id} from={s.from} durationInFrames={s.duration} premountFor={FPS}>
						<Scene />
					</Sequence>
				);
			})}
			<AbsoluteFill style={{background: C.night, opacity: breath(t), pointerEvents: 'none'}} />
			<CaptionShade t={t} />
			<Captions t={t} />
			{t >= T.story_at && <Letterbox />}
			<Audio src={staticFile('v7/mix.wav')} />
		</AbsoluteFill>
	);
};
