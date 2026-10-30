// Shared clock, layout and type for "Welcome": the music's bar grid, the
// frame's shape (one composition renders 9:16 and 16:9), and the faces.
import React, {createContext, useContext} from 'react';
import {AbsoluteFill, Easing, interpolate, Sequence, useCurrentFrame, useVideoConfig} from 'remotion';
import {loadFont as loadFigtree} from '@remotion/google-fonts/Figtree';
import {loadFont as loadSilkscreen} from '@remotion/google-fonts/Silkscreen';
import timeline from '../timeline.json';

// ── Time ─────────────────────────────────────────────────────────────────────
export const T = timeline;
export const FPS = timeline.fps;
export const BEAT = timeline.beat;
export const BAR = BEAT * 4;
export const f = (s: number) => Math.round(s * FPS);
export const DURATION = f(timeline.duration);

/** Bar `k`, beat `b` of the music, in film seconds. */
export const bar = (k: number, b = 0) => timeline.b0 + k * BAR + b * BEAT;
const parse = (spec: string) => {
	const [k, b] = spec.split(':').map(Number);
	return bar(k, b);
};
export type CueId = keyof typeof timeline.cues;
export const cue = (id: CueId) => parse(timeline.cues[id]);
export const copy = timeline.copy;

const smooth = Easing.bezier(0.45, 0, 0.25, 1);
export const ease = {
	out: Easing.bezier(0.16, 1, 0.3, 1), inOut: Easing.bezier(0.65, 0, 0.35, 1), in: Easing.bezier(0.55, 0, 0.9, 0.4),
	back: Easing.bezier(0.34, 1.56, 0.64, 1), snap: Easing.bezier(0.2, 0.9, 0.1, 1), linear: Easing.linear, smooth,
};
/** Clamped interpolate on seconds. */
export const at = (t: number, input: number[], output: number[], easing = smooth) =>
	interpolate(t, input, output, {extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing});
/** 0 → 1 → 0: in over `fade`, out over `fade`. */
export const window = (t: number, a: number, b: number, fade = 0.2) =>
	Math.min(at(t, [a, a + fade], [0, 1]), at(t, [b - fade, b], [1, 0]));

/** A seeded random stream, so every render draws the same scribbles. */
export const rng = (seed: number) => {
	let s = (seed * 2654435761) >>> 0;
	return () => {
		s = (s + 0x6d2b79f5) >>> 0;
		let r = Math.imul(s ^ (s >>> 15), 1 | s);
		r = (r + Math.imul(r ^ (r >>> 7), 61 | r)) ^ r;
		return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
	};
};

/** The film's absolute clock, shared into every <Shot> (whose own frame count restarts). */
const Clock = createContext(0);
export const useFilm = () => useContext(Clock);
export const FilmClock: React.FC<{children: React.ReactNode}> = ({children}) => (
	<Clock.Provider value={useCurrentFrame() / FPS}>{children}</Clock.Provider>
);

/** A shot from `from` to `to` film seconds. Children read film time with useFilm(). */
export const Shot: React.FC<{from: number; to: number; name: string; children: React.ReactNode}> = ({from, to, name, children}) => {
	const t = useFilm();
	return (
		<Sequence name={name} from={f(from)} durationInFrames={Math.max(1, f(to) - f(from))} premountFor={FPS}>
			<Clock.Provider value={t}>
				<AbsoluteFill style={{overflow: 'hidden'}}>{children}</AbsoluteFill>
			</Clock.Provider>
		</Sequence>
	);
};

// ── The frame ────────────────────────────────────────────────────────────────
/** W×H of this render; `tall` for 9:16. Both shapes share a 1080 short side. */
export const useFrame = () => {
	const {width: W, height: H} = useVideoConfig();
	return {W, H, tall: H > W, cx: W / 2, cy: H / 2};
};

// ── Colour: the game's palette, pushed to the reference's contrast ──────────
export const C = {
	paper: '#ecebe7', ink: '#17151c', inkSoft: '#4a4652', night: '#0e0d16',
	red: '#e5322a', amber: '#f2b530', mint: '#46e8c0', lavender: '#c3b2de', glyph: '#8a84b8', white: '#fbfaf6',
};

// ── Type ─────────────────────────────────────────────────────────────────────
const figtree = loadFigtree('normal', {weights: ['600', '700', '800', '900'], subsets: ['latin']});
const silkscreen = loadSilkscreen('normal', {weights: ['400', '700'], subsets: ['latin']});
export const sans = `${figtree.fontFamily}, "Segoe UI", sans-serif`;
export const pixel = `${silkscreen.fontFamily}, monospace`;
