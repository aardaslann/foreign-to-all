// The research-paper gameplay video: a little under three minutes of the game
// played in real time, recorded by Godot's movie writer through
// tools/research_film_capture.gd (keyboard to walk, a drawn mouse pointer for
// menus and replies, a guess typed by hand). Every moving picture is the
// game's own frames and sound; the edit only cuts, and adds short captions
// for readers who have not played it. The clean cut leaves the captions out.
import React from 'react';
import {AbsoluteFill, OffthreadVideo, Sequence, interpolate, staticFile, useCurrentFrame} from 'remotion';
import {Audio} from '@remotion/media';
import {pixel, sans} from '../welcome/lib/core';
import {INK, LAVENDER, MINT, Wordmark} from '../steam/KeyArt';

const FPS = 30;
const DIP = 10;           // frames of fade through black between chapters
const EDGE = 4;           // frames of audio fade at every cut, so nothing clicks

type Place = 'top' | 'bottom' | 'header' | 'sky';
type Caption = {kicker?: string; text: string; at: Place; seconds?: number};
type Film = {kind: 'film'; src: string; from: number; to: number; dip?: 'in' | 'out' | 'both';
	caption?: Caption; label?: string; muted?: boolean};
type Card = {kind: 'title' | 'end'; seconds: number};
type Clip = Film | Card;

const film = (src: string, from: number, to: number, extra: Partial<Film> = {}): Film =>
	({kind: 'film', src, from, to, ...extra});
const city = (from: number, label: string, extra: Partial<Film> = {}): Film =>
	film('cities', from, from + 2.6, {label, muted: true, ...extra});

export const EDIT: Clip[] = [
	{kind: 'title', seconds: 4.5},
	// Starting a journey
	film('opening', 0.6, 5.4, {dip: 'in', caption: {kicker: 'Starting a journey', text: 'The player designs the alien who will travel.', at: 'bottom'}}),
	film('opening', 6.0, 12.0),
	film('opening', 19.6, 23.2),
	film('opening', 24.4, 28.6, {caption: {kicker: 'Arrival', text: 'An alien crash-lands in Berlin. It speaks no human language.', at: 'top'}}),
	// The rooftop into the crash; the opening falls silent after it, so the
	// quiet "you are not alone" beat is left out and the chapter card closes it.
	film('opening', 33.4, 40.4),
	film('opening', 47.6, 50.4, {dip: 'out'}),
	// First words, in the field where it landed
	film('opening', 51.3, 60.6, {dip: 'in', caption: {kicker: 'First words', text: 'Things are named in the local language: the coins in the grass are Geld.', at: 'top', seconds: 5}}),
	film('opening', 63.6, 74.6, {dip: 'out', caption: {text: 'Unfamiliar speech appears as glyphs and becomes readable with exposure. Replies are gestures.', at: 'top', seconds: 6}}),
	// Berlin: Kerstin's crates
	film('berlin', 0.0, 4.6, {dip: 'in', caption: {kicker: 'Berlin: Kerstin', text: 'Nothing is translated. The player reads the situation and acts.', at: 'top'}}),
	film('berlin', 5.0, 14.5, {caption: {text: 'Every reply is a guess about what she meant. Here: offer her a coin.', at: 'bottom', seconds: 5}}),
	film('berlin', 15.0, 22.5, {caption: {text: 'A wrong reading is not a failure. It plays out, and the word is learned anyway.', at: 'top'}}),
	film('berlin', 45.0, 51.5),
	film('berlin', 86.0, 100.5, {caption: {kicker: 'A word to keep', text: 'Players can write their own guess before the meaning is shown.', at: 'bottom', seconds: 6}}),
	film('berlin', 206.0, 213.0, {dip: 'out', caption: {kicker: 'Field notes', text: "The notebook keeps the player's reading beside the meaning.", at: 'header'}}),
	// Travel
	film('flight', 4.0, 14.6, {dip: 'in'}),
	film('flight', 16.0, 21.5, {dip: 'out', caption: {kicker: 'Eight cities', text: 'After Berlin, the other seven can be visited in any order.', at: 'sky'}}),
	// London: Val's request
	film('london', 0.5, 11.5, {dip: 'in', caption: {kicker: 'London: Val', text: 'Every word is readable here. What she means still has to be worked out.', at: 'bottom', seconds: 6}}),
	film('london', 12.0, 22.5),
	film('london', 41.0, 49.0),
	film('london', 101.6, 108.6, {dip: 'out'}),
	// Six more streets, over the title theme
	city(8.6, 'İstanbul', {dip: 'in'}),
	city(30.2, 'Paris'),
	city(40.6, 'Moscow'),
	film('cities', 62.9, 64.9, {label: 'Mumbai', muted: true}),
	city(73.2, 'Tokyo'),
	city(96.8, 'Mexico City', {dip: 'out'}),
	{kind: 'end', seconds: 6.5},
];

const length = (clip: Clip): number =>
	Math.round((clip.kind === 'film' ? clip.to - clip.from : clip.seconds) * FPS);
export const RESEARCH_FRAMES = EDIT.reduce((n, clip) => n + length(clip), 0);

// Spans the first cuts of the montage rather than one 2.6 s street.
const MONTAGE: Caption = {kicker: 'Seven more cities', text: 'Each with its own language, script and customs.', at: 'top', seconds: 5.5};
const MONTAGE_FRAMES = 6.5 * FPS;

// The montage and the end card share one music bed: the game's title theme.
const BED_FROM = (() => {
	let at = 0;
	for (const clip of EDIT) {
		if (clip.kind === 'film' && clip.src === 'cities') return at;
		at += length(clip);
	}
	return at;
})();

const fade = (f: number, total: number, edge: number) =>
	interpolate(f, [0, edge, total - edge, total], [0, 1, 1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});

const CaptionBox: React.FC<{caption: Caption; clipFrames: number}> = ({caption, clipFrames}) => {
	const f = useCurrentFrame();
	const start = 10;
	const end = Math.min(clipFrames - 8, start + Math.round((caption.seconds ?? 5) * FPS));
	const o = interpolate(f, [start, start + 9, end - 9, end], [0, 1, 1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	const lift = interpolate(f, [start, start + 12], [10, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	// Chosen per shot: a dialogue box can open at the top or the bottom of the
	// screen, and street HUDs reach about 180px down.
	const where: React.CSSProperties =
		caption.at === 'top' ? {left: 56, top: 200}
		: caption.at === 'header' ? {right: 316, top: 92}
		: caption.at === 'sky' ? {right: 72, top: 150}
		: {left: 56, bottom: 52};
	return (
		<div style={{position: 'absolute', ...where, maxWidth: 780, padding: '16px 24px 18px', background: 'rgba(18,16,28,0.9)',
			boxShadow: '0 0 0 2px rgba(195,178,222,0.42), 0 8px 26px rgba(6,4,14,0.55)', opacity: o, transform: `translateY(${lift}px)`}}>
			{caption.kicker && (
				<div style={{fontFamily: pixel, fontSize: 19, letterSpacing: '0.08em', color: MINT, textTransform: 'uppercase', marginBottom: 8}}>
					{caption.kicker}
				</div>
			)}
			<div style={{fontFamily: sans, fontWeight: 600, fontSize: 29, lineHeight: 1.3, color: '#efe9fb'}}>{caption.text}</div>
		</div>
	);
};

const CityLabel: React.FC<{text: string}> = ({text}) => {
	const f = useCurrentFrame();
	const o = interpolate(f, [2, 8], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	return (
		<div style={{position: 'absolute', left: 56, bottom: 52, padding: '10px 18px', background: 'rgba(18,16,28,0.86)', boxShadow: '0 0 0 3px rgba(195,178,222,0.5)',
			fontFamily: pixel, fontSize: 30, letterSpacing: '0.06em', color: '#ece6fa', textTransform: 'uppercase', opacity: o}}>
			{text}
		</div>
	);
};

const FilmShot: React.FC<{clip: Film; captions: boolean}> = ({clip, captions}) => {
	const f = useCurrentFrame();
	const total = length(clip);
	const dipIn = clip.dip === 'in' || clip.dip === 'both';
	const dipOut = clip.dip === 'out' || clip.dip === 'both';
	const black = Math.max(
		dipIn ? interpolate(f, [0, DIP], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}) : 0,
		dipOut ? interpolate(f, [total - DIP, total], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}) : 0);
	return (
		<AbsoluteFill style={{background: INK}}>
			<OffthreadVideo src={staticFile(`research/film/${clip.src}.mp4`)} trimBefore={Math.round(clip.from * FPS)}
				muted={clip.muted} volume={(v) => fade(v, total, dipIn || dipOut ? DIP : EDGE)} />
			{captions && clip.label && <CityLabel text={clip.label} />}
			{captions && clip.caption && <CaptionBox caption={clip.caption} clipFrames={total} />}
			<AbsoluteFill style={{background: INK, opacity: black}} />
		</AbsoluteFill>
	);
};

const TitleCard: React.FC<{seconds: number}> = ({seconds}) => {
	const f = useCurrentFrame();
	const total = seconds * FPS;
	const show = (at: number) => interpolate(f, [at * FPS, at * FPS + 12], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	const out = interpolate(f, [total - 12, total], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	return (
		<AbsoluteFill style={{background: INK, opacity: out}}>
			<div style={{opacity: show(0.2)}}><Wordmark cx={960} cy={400} scale={4} heavy /></div>
			<div style={{position: 'absolute', top: 610, width: '100%', textAlign: 'center', fontFamily: sans, fontWeight: 700, fontSize: 46, color: '#efe9fb', opacity: show(0.7)}}>
				Gameplay overview
			</div>
			<div style={{position: 'absolute', top: 690, width: '100%', textAlign: 'center', fontFamily: pixel, fontSize: 22, letterSpacing: '0.08em', color: LAVENDER, opacity: show(1.1)}}>
				BETA 0.2.1 · BUILD 20261004.6
			</div>
			<div style={{position: 'absolute', top: 742, width: '100%', textAlign: 'center', fontFamily: sans, fontWeight: 600, fontSize: 26, color: '#b9b0cf', opacity: show(1.4)}}>
				Recorded in real time from the game, with its own sound
			</div>
		</AbsoluteFill>
	);
};

const EndCard: React.FC<{seconds: number}> = ({seconds}) => {
	const f = useCurrentFrame();
	const show = (at: number) => interpolate(f, [at * FPS, at * FPS + 14], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	const out = interpolate(f, [seconds * FPS - 24, seconds * FPS], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
	return (
		<AbsoluteFill style={{background: INK, opacity: out}}>
			<div style={{opacity: show(0.1)}}><Wordmark cx={960} cy={380} scale={4} heavy /></div>
			<div style={{position: 'absolute', top: 590, width: '100%', textAlign: 'center', fontFamily: sans, fontWeight: 700, fontSize: 44, color: '#efe9fb', opacity: show(0.8)}}>
				Knowing the words is not enough.
			</div>
			<div style={{position: 'absolute', top: 690, width: '100%', textAlign: 'center', fontFamily: sans, fontWeight: 600, fontSize: 24, color: '#a79fbe', opacity: show(1.6)}}>
				Excerpts from several sessions of beta 0.2.1, recorded in real time. Cuts only.
			</div>
		</AbsoluteFill>
	);
};

const Shot: React.FC<{clip: Clip; captions: boolean}> = ({clip, captions}) => {
	if (clip.kind !== 'film') {
		return clip.kind === 'title' ? <TitleCard seconds={clip.seconds} /> : <EndCard seconds={clip.seconds} />;
	}
	return <FilmShot clip={clip} captions={captions} />;
};

const Video: React.FC<{captions: boolean}> = ({captions}) => {
	let at = 0;
	const bed = RESEARCH_FRAMES - BED_FROM;
	return (
		<AbsoluteFill style={{background: INK}}>
			{EDIT.map((clip, i) => {
				const from = at;
				at += length(clip);
				const name = clip.kind === 'film' ? `${clip.src} ${clip.from}-${clip.to}s` : clip.kind;
				return (
					<Sequence key={i} from={from} durationInFrames={length(clip)} name={name}>
						<Shot clip={clip} captions={captions} />
					</Sequence>
				);
			})}
			{captions && (
				<Sequence from={BED_FROM} durationInFrames={MONTAGE_FRAMES} name="montage caption">
					<CaptionBox caption={MONTAGE} clipFrames={MONTAGE_FRAMES} />
				</Sequence>
			)}
			<Sequence from={BED_FROM} durationInFrames={bed} name="title theme">
				<Audio src={staticFile('research/music/title.ogg')}
					volume={(f) => interpolate(f, [0, 20, bed - 40, bed], [0, 0.8, 0.8, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})} />
			</Sequence>
		</AbsoluteFill>
	);
};

export const ResearchGameplay: React.FC = () => <Video captions />;
export const ResearchGameplayClean: React.FC = () => <Video captions={false} />;
