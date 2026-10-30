// Foreign to All — Understanding, revision 6. One score, cut on its downbeats;
// every scene's times come from timeline.json, the soundtrack from
// build_audio.py.
import React from 'react';
import {AbsoluteFill, Sequence, staticFile, useCurrentFrame} from 'remotion';
import {Audio} from '@remotion/media';
import {FPS, T, at, ease, f, scene, Black, Grain, type SceneId} from './lib/core';
import {LightLeak} from './lib/fx';
import {Arrival, Sonder} from './scenes/Opening';
import {Bitte, Brot, Journal, Unfamiliar} from './scenes/Berlin';
import {Istanbul, London, Tokyo} from './scenes/Journey';
import {Cities, Stereotype} from './scenes/Turn';
import {FireworksScene, Invitation, Title} from './scenes/Finale';

export const DURATION = f(T.duration);

// "black" has no picture: the shutter closes on it.
const SCENES: [SceneId, React.FC][] = [
	['sonder', Sonder], ['arrival', Arrival], ['unfamiliar', Unfamiliar], ['brot', Brot], ['journal', Journal],
	['bitte', Bitte], ['london', London], ['istanbul', Istanbul], ['tokyo', Tokyo], ['stereotype', Stereotype],
	['cities', Cities], ['invitation', Invitation], ['fireworks', FireworksScene], ['title', Title],
];

/** Dips through black: [cut, out, in] — out before the cut, in after it. */
const DIPS: [number, number, number][] = [[0, 0, 0.4], [T.scenes.london[0], 0.25, 0.35]];
const dip = (t: number) => Math.max(0, ...DIPS.map(([cut, out, inn]) =>
	t < cut ? (out ? at(t, [cut - out, cut], [0, 1], ease.in) : 0) : at(t, [cut, cut + inn], [1, 0])));

export const UnderstandingV6: React.FC = () => {
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
			<LightLeak t={t} at={T.scenes.istanbul[0]} length={0.8} hue={30} />
			<LightLeak t={t} at={T.scenes.tokyo[0]} length={0.8} hue={338} />
			<Black opacity={dip(t)} />
			<Grain />
			<Audio src={staticFile('v6/mix.wav')} />
		</AbsoluteFill>
	);
};
