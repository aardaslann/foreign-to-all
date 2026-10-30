// The Steam page's first trailer: sixty seconds of real play, cut on the bar
// to the game's own title theme (112 BPM). Every moving picture is the movie
// writer's 30 fps recording of the game (film_capture.gd): Kerstin's first
// words in glyphs, a word earned in the moment, a seat at the Späti, seven
// more cities, London's plain English, and the end card from the key art.
// The three title cards speak in the dialogue box's glyphs until they land.
import React from 'react';
import {AbsoluteFill, Img, OffthreadVideo, Sequence, interpolate, staticFile, useCurrentFrame} from 'remotion';
import {Audio} from '@remotion/media';
import {Decode, Glyph} from '../welcome/lib/type';
import {pixel, rng, sans} from '../welcome/lib/core';
import {INK, KeyArt, LAVENDER, MINT} from './KeyArt';

const FPS = 30;
const BPM = 112;
const BAR = (4 * 60) / BPM;
const MUSIC_START = 0.273; // the theme's first downbeat, measured from its onsets

type Clip =
	| {kind: 'film'; src: string; from: number; bars: number; label?: string}
	| {kind: 'card'; text: string; bars: number}
	| {kind: 'notes'; bars: number}
	| {kind: 'end'; bars: number};

const CITY = (src: string, label: string): Clip => ({kind: 'film', src, from: 4.3, bars: 0.5, label});

export const EDIT: Clip[] = [
	{kind: 'card', text: 'You arrive on Earth without a word anyone understands.', bars: 2},
	{kind: 'film', src: 'berlin', from: 0.6, bars: 1, label: 'Berlin'},
	{kind: 'film', src: 'berlin', from: 3.9, bars: 2},
	{kind: 'film', src: 'berlin', from: 8.2, bars: 3},
	{kind: 'film', src: 'berlin', from: 15.4, bars: 1},
	{kind: 'film', src: 'berlin', from: 86.4, bars: 2},
	{kind: 'card', text: 'Eight cities. In the order you choose.', bars: 1},
	CITY('tokyo', 'Tokyo'), CITY('mumbai', 'Mumbai'), CITY('istanbul', 'İstanbul'),
	CITY('paris', 'Paris'), CITY('mexico', 'Mexico City'), CITY('moscow', 'Moscow'),
	{kind: 'film', src: 'london', from: 0.0, bars: 2, label: 'London'},
	{kind: 'film', src: 'london', from: 7.5, bars: 2},
	{kind: 'card', text: 'Knowing the words is not enough.', bars: 1},
	{kind: 'film', src: 'berlin', from: 98.6, bars: 3},
	{kind: 'notes', bars: 2},
	{kind: 'end', bars: 3},
];

const frames = (bars: number) => Math.round(bars * BAR * FPS);
export const GAMEPLAY_FRAMES = frames(EDIT.reduce((n, c) => n + c.bars, 0));

/** The dialogue box's glyphs drifting upwards behind a card. */
const Drift: React.FC<{t: number}> = ({t}) => {
	const r = rng(41);
	return (
		<>
			{Array.from({length: 18}, (_, i) => {
				const x = r() * 1920, speed = 22 + r() * 40, y0 = r() * 1080;
				const y = (((y0 - t * speed) % 1080) + 1080) % 1080;
				return <Glyph key={i} index={i % 8} size={22 + r() * 34} color={LAVENDER} style={{position: 'absolute', left: x, top: y, opacity: 0.08 + r() * 0.1}} />;
			})}
		</>
	);
};

const PER = 0.022;

/** Decodes word by word so a line can only break between words. */
const Card: React.FC<{text: string}> = ({text}) => {
	const t = useCurrentFrame() / FPS;
	let start = 0.25;
	return (
		<AbsoluteFill style={{background: INK, alignItems: 'center', justifyContent: 'center'}}>
			<Drift t={t} />
			<div style={{fontFamily: sans, fontWeight: 800, fontSize: 64, color: '#f1edf9', textAlign: 'center', maxWidth: 1360, lineHeight: 1.25, letterSpacing: '-0.01em'}}>
				{text.split(' ').map((word, i) => {
					const from = start;
					start += word.length * PER;
					return (
						<React.Fragment key={i}>
							{i > 0 && ' '}
							<span style={{whiteSpace: 'nowrap'}}>
								<Decode text={word} t={t} from={from} per={PER} scramble={0.3} fontSize={64} color="#f1edf9" glyphColor={LAVENDER} landColor={MINT} seed={7 + i} />
							</span>
						</React.Fragment>
					);
				})}
			</div>
		</AbsoluteFill>
	);
};

const Label: React.FC<{text: string}> = ({text}) => {
	const f = useCurrentFrame();
	const o = interpolate(f, [2, 8], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	return (
		<div style={{position: 'absolute', left: 56, bottom: 52, padding: '10px 18px', background: 'rgba(18,16,28,0.86)', boxShadow: '0 0 0 3px rgba(195,178,222,0.5)',
			fontFamily: pixel, fontSize: 30, letterSpacing: '0.06em', color: '#ece6fa', textTransform: 'uppercase', opacity: o}}>
			{text}
		</div>
	);
};

const Film: React.FC<{src: string; from: number; label?: string}> = ({src, from, label}) => (
	<AbsoluteFill style={{background: INK}}>
		<OffthreadVideo src={staticFile(`steam/film/${src}.mp4`)} trimBefore={Math.round(from * FPS)} muted />
		{label && <Label text={label} />}
	</AbsoluteFill>
);

const Notes: React.FC = () => {
	const f = useCurrentFrame();
	const z = interpolate(f, [0, frames(2)], [1, 1.07]);
	return (
		<AbsoluteFill style={{background: INK, overflow: 'hidden'}}>
			<Img src={staticFile('steam/shots/field-notes.png')} style={{width: 1920, height: 1080, scale: `${z}`, transformOrigin: '42% 45%'}} />
		</AbsoluteFill>
	);
};

const End: React.FC = () => {
	const f = useCurrentFrame();
	const t = f / FPS;
	const show = (a: number) => interpolate(t, [a, a + 0.5], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	return (
		<AbsoluteFill style={{opacity: show(0)}}>
			<KeyArt logo={{cx: 960, cy: 262, scale: 4.5}} alien={{x: 1330, u: 9}} bubbles={[
				{x: 200, y: 556, glyphs: [3, 0, 5, 1], size: 40},
				{x: 1714, y: 566, glyphs: [6, 2, 7], size: 40, tail: 'right'},
				{x: 564, y: 712, glyphs: [1, 4, 7, 2], size: 34, word: 2},
			]} />
			<div style={{position: 'absolute', top: 486, width: '100%', textAlign: 'center', fontFamily: sans, fontWeight: 700, fontSize: 40, color: '#efe9fb',
				textShadow: '0 2px 0 #12101c, 0 0 18px rgba(12,10,26,0.9)', opacity: show(0.6)}}>
				A world to discover. People to understand.
			</div>
			<div style={{position: 'absolute', top: 552, width: '100%', textAlign: 'center', fontFamily: pixel, fontSize: 30, letterSpacing: '0.08em', color: MINT,
				textShadow: '0 2px 0 #12101c, 0 0 14px rgba(12,10,26,0.9)', opacity: show(1.2)}}>
				WISHLIST ON STEAM
			</div>
		</AbsoluteFill>
	);
};

const Shot: React.FC<{clip: Clip}> = ({clip}) => {
	switch (clip.kind) {
		case 'film': return <Film src={clip.src} from={clip.from} label={clip.label} />;
		case 'card': return <Card text={clip.text} />;
		case 'notes': return <Notes />;
		case 'end': return <End />;
	}
};

export const Gameplay: React.FC = () => {
	let bars = 0;
	const fadeOut = GAMEPLAY_FRAMES - Math.round(1.6 * FPS);
	return (
		<AbsoluteFill style={{background: INK}}>
			{EDIT.map((clip, i) => {
				const from = frames(bars);
				bars += clip.bars;
				return (
					<Sequence key={i} from={from} durationInFrames={frames(bars) - from} name={clip.kind === 'film' ? `${clip.src} ${clip.from}s` : clip.kind}>
						<Shot clip={clip} />
					</Sequence>
				);
			})}
			<Audio src={staticFile('steam/music/title.ogg')} trimBefore={Math.round(MUSIC_START * FPS)}
				volume={(f) => interpolate(f, [0, 6, fadeOut, GAMEPLAY_FRAMES], [0, 0.9, 0.9, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})} />
		</AbsoluteFill>
	);
};
