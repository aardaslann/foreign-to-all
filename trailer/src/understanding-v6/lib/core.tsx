// Shared building blocks for revision 6: time, type, the world camera, the
// game's own people and items, its glyph runes, speech bubbles and captions.
import React, {createContext, useContext} from 'react';
import {AbsoluteFill, Easing, Img, interpolate, staticFile, useCurrentFrame} from 'remotion';
import {loadFont as loadSerif} from '@remotion/google-fonts/CormorantGaramond';
import {loadFont as loadSans} from '@remotion/google-fonts/OpenSans';
import timeline from '../timeline.json';
import generated from '../generated.json';

// ── Time ─────────────────────────────────────────────────────────────────────
export const FPS = timeline.fps;
export const T = timeline;
export const G = generated;
export const f = (s: number) => Math.round(s * FPS);
export type SceneId = keyof typeof timeline.scenes;
export const scene = (id: SceneId) => {
	const [start, end] = timeline.scenes[id];
	return {start, end, from: f(start), duration: f(end) - f(start)};
};
export const voice = (id: string) => (generated.voices as Record<string, {at: number; dur: number}>)[id];

/** Seconds since the start of the current <Sequence>. */
export const useSeconds = () => useCurrentFrame() / FPS;

const out = Easing.bezier(0.16, 1, 0.3, 1);
const inOut = Easing.bezier(0.65, 0, 0.35, 1);
export const ease = {out, inOut, in: Easing.bezier(0.5, 0, 0.75, 0)};

/** Clamped interpolate on seconds. */
export const at = (t: number, input: number[], output: number[], easing = out) =>
	interpolate(t, input, output, {extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing});

/** 0 → 1 → 0 window: in over `fade`, out over `fade`. */
export const window = (t: number, a: number, b: number, fade = 0.45) =>
	Math.min(at(t, [a, a + fade], [0, 1]), at(t, [b - fade, b], [1, 0], ease.in));

// ── Type and colour ──────────────────────────────────────────────────────────
export const serif = loadSerif('normal', {weights: ['500', '600'], subsets: ['latin', 'latin-ext']}).fontFamily;
loadSerif('italic', {weights: ['500'], subsets: ['latin', 'latin-ext']});
export const sans = loadSans('normal', {weights: ['300', '400', '600'], subsets: ['latin', 'latin-ext', 'cyrillic', 'vietnamese']}).fontFamily;

export const C = {
	night: '#0a0812', ink: '#141024', panel: 'rgba(22, 17, 38, 0.94)', paper: '#f3eeff',
	lavender: '#b9a9e3', dim: '#9a90b8', gold: '#e8bb62', amber: '#f2b44a', teal: '#7fd8c6',
};

// ── The world: a plate from the game, a camera, and things placed on it ──────
export const PLATE = {w: 1672, h: 941};
export const COVER = Math.max(1920 / PLATE.w, 1080 / PLATE.h);
export type Cam = {x: number; y: number; z: number; rot?: number};
const WorldScale = createContext(COVER);
export const useWorldScale = () => useContext(WorldScale);

/** Linear camera move between two framings, eased, over [a, b] seconds. */
export const move = (t: number, a: number, b: number, from: Cam, to: Cam, easing = inOut): Cam => {
	const k = at(t, [a, b], [0, 1], easing);
	return {x: from.x + (to.x - from.x) * k, y: from.y + (to.y - from.y) * k, z: from.z + (to.z - from.z) * k};
};

export const World: React.FC<{
	plate: string; cam: Cam; grade?: string; shake?: number; children?: React.ReactNode; above?: React.ReactNode;
}> = ({plate, cam, grade, shake = 0, children, above}) => {
	const frame = useCurrentFrame();
	const s = COVER * cam.z;
	let tx = 960 - cam.x * s;
	let ty = 540 - cam.y * s;
	tx = Math.min(0, Math.max(1920 - PLATE.w * s, tx));
	ty = Math.min(0, Math.max(1080 - PLATE.h * s, ty));
	if (shake) {
		tx += Math.sin(frame * 2.31) * shake + Math.sin(frame * 5.7) * shake * 0.5;
		ty += Math.cos(frame * 1.93) * shake * 0.8;
	}
	return (
		<AbsoluteFill style={{overflow: 'hidden', backgroundColor: C.night}}>
			<div style={{position: 'absolute', left: 0, top: 0, width: PLATE.w, height: PLATE.h,
				transformOrigin: '0 0', transform: `translate(${tx}px, ${ty}px) scale(${s})`}}>
				<Img src={staticFile(`v6/plates/${plate}.png`)}
					style={{width: PLATE.w, height: PLATE.h, display: 'block', filter: grade}} />
				<WorldScale.Provider value={s}>{children}</WorldScale.Provider>
			</div>
			{above}
		</AbsoluteFill>
	);
};

/** A colour wash over the whole frame, for grading time of day. */
export const Wash: React.FC<{color: string; blend?: React.CSSProperties['mixBlendMode']; opacity?: number}> = ({color, blend = 'multiply', opacity = 1}) => (
	<AbsoluteFill style={{background: color, mixBlendMode: blend, opacity, pointerEvents: 'none'}} />
);

// ── People and things, from the game's own renderer ──────────────────────────
const FRAME = 40;
const FEET = {x: 20, y: 37};
const FRAMES = 24;

/**
 * One of the game's people, played from the strips that
 * tools/export_trailer_cast.gd renders with CharacterArt. `x`, `y` are the
 * feet in plate pixels; `u` is plate pixels per grid unit.
 */
export const Person: React.FC<{
	who: string; act?: string; x: number; y: number; u?: number; flip?: boolean;
	clipY?: number; filter?: string; opacity?: number; shadow?: boolean; phase?: number; still?: boolean;
}> = ({who, act = 'stand', x, y, u = 5.6, flip, clipY, filter, opacity = 1, shadow = true, phase = 0, still}) => {
	const frame = useCurrentFrame();
	const index = still ? 0 : Math.floor((frame / FPS) * 12 + phase) % FRAMES;
	const top = y - FEET.y * u;
	const height = clipY === undefined ? FRAME * u : Math.max(0, Math.min(FRAME * u, clipY - top));
	return (
		<>
			{shadow && clipY === undefined && (
				<div style={{position: 'absolute', left: x - 9 * u, top: y - 1.4 * u, width: 18 * u, height: 3.2 * u, opacity: 0.5 * opacity,
					borderRadius: '50%', background: 'radial-gradient(closest-side, rgba(8,6,14,0.75), rgba(8,6,14,0))'}} />
			)}
			<div style={{position: 'absolute', left: x - FEET.x * u, top, width: FRAME * u, height, overflow: 'hidden',
				opacity, filter, transform: flip ? 'scaleX(-1)' : undefined}}>
				<Img src={staticFile(`v6/cast/${who}/${act}.png`)}
					style={{position: 'absolute', left: -index * FRAME * u, top: 0, width: FRAMES * FRAME * u, height: FRAME * u,
						imageRendering: 'pixelated', maxWidth: 'none'}} />
			</div>
		</>
	);
};

export const Item: React.FC<{id: string; x: number; y: number; size: number; style?: React.CSSProperties}> = ({id, x, y, size, style}) => (
	<Img src={staticFile(`v6/items/${id}.png`)}
		style={{position: 'absolute', left: x - size / 2, top: y - size / 2, width: size, height: size, imageRendering: 'pixelated', ...style}} />
);

// ── The game's glyphs: words he has not got yet ─────────────────────────────
// Drawn as pixel runes (the dialogue box's ◈⟟⬡◉⟢… family) so they render
// crisply and identically everywhere.
const RUNES = [
	'..#...#.#.#.#.#.#.#...#..', '.###...#....#...#.#...#..', '.###.#...##...##...#.###.',
	'.###.#...##.#.##...#.###.', '..#...#.#...#....#...##..', '#...#.#.#...#...#.#.#...#',
	'.......#...#.#...#.......', '.###.###############.###.', '..#...###.#####.###..#.#.',
	'###..#.#..#.#..#.#..###..', '..###..#.#..#.#..#.#..###', '..#...###.#.#.#.###...#..',
	'#.#.#.....#.#.#.....#.#.#', '.#.#.#####.#.#.#####.#.#.',
];
const hash = (s: string) => {
	let h = 2166136261;
	for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619);
	return h >>> 0;
};

export const Rune: React.FC<{seed: string; size: number; color: string; glow?: number}> = ({seed, size, color, glow = 0}) => {
	const rune = RUNES[hash(seed) % RUNES.length];
	const cell = size / 6;
	return (
		<svg width={cell * 6} height={size} viewBox="0 0 6 6" style={{display: 'inline-block', verticalAlign: '-0.12em',
			filter: glow ? `drop-shadow(0 0 ${glow}px ${color})` : undefined}}>
			{[...rune].map((ch, i) => (ch === '#' ? <rect key={i} x={i % 5} y={Math.floor(i / 5) + 0.5} width={1.02} height={1.02} fill={color} /> : null))}
		</svg>
	);
};

export type Seg = {text: string; kind?: 'plain' | 'glyph' | 'amber' | 'decode'; at?: number};

/**
 * A line of speech: plain words, glyph words (flickering every 0.18 s, as in
 * the dialogue box), amber words he knows, and words that decode from glyphs
 * into amber letters at `at` seconds. `typed` reveals characters over time.
 */
export const Speech: React.FC<{segs: Seg[]; t: number; size: number; typed?: {from: number; cps: number}}> = ({segs, t, size, typed}) => {
	const flick = Math.floor(t / 0.18);
	let shown = typed ? Math.max(0, Math.floor((t - typed.from) * typed.cps)) : Infinity;
	return (
		<span>
			{segs.map((seg, si) => (
				<span key={si}>
					{[...seg.text].map((ch, ci) => {
						if (shown-- <= 0) return null;
						const key = `${si}-${ci}`;
						if (ch === ' ') return <span key={key}> </span>;
						const letter = /[\p{L}\p{N}]/u.test(ch);
						if (seg.kind === 'glyph' && letter) return <Rune key={key} seed={`${si}${ci}${flick}`} size={size * 0.78} color={C.lavender} />;
						if (seg.kind === 'decode' && letter) {
							const k = (seg.at ?? 0) + ci * 0.055;
							if (t < k) return <Rune key={key} seed={`${si}${ci}${flick}`} size={size * 0.78} color={C.lavender} />;
							const flash = at(t, [k, k + 0.35], [1, 0]);
							return <span key={key} style={{color: C.amber, textShadow: `0 0 ${18 * flash}px rgba(255,214,140,${0.9 * flash})`}}>{ch}</span>;
						}
						return <span key={key} style={{color: seg.kind === 'amber' ? C.amber : undefined}}>{ch}</span>;
					})}
				</span>
			))}
		</span>
	);
};

/** A speech bubble anchored above someone in the world, constant on screen. */
export const Bubble: React.FC<{
	x: number; y: number; t: number; from: number; to: number; segs: Seg[];
	typed?: {from: number; cps: number}; side?: 'left' | 'right' | 'center'; size?: number;
}> = ({x, y, t, from, to, segs, typed, side = 'center', size = 30}) => {
	const scale = useWorldScale();
	const shown = window(t, from, to, 0.18);
	if (shown <= 0) return null;
	const pop = at(t, [from, from + 0.28], [0.86, 1], Easing.bezier(0.34, 1.56, 0.64, 1));
	const shift = side === 'center' ? '-50%' : side === 'left' ? '-88%' : '-12%';
	return (
		<div style={{position: 'absolute', left: x, top: y, transformOrigin: '0 0', transform: `scale(${1 / scale})`}}>
			<div style={{transform: `translate(${shift}, -100%) scale(${pop})`, transformOrigin: side === 'center' ? '50% 100%' : side === 'left' ? '88% 100%' : '12% 100%',
				opacity: shown, position: 'relative'}}>
				<div style={{background: C.panel, border: '2px solid rgba(185,169,227,0.5)', borderRadius: 12, padding: '14px 22px',
					color: C.paper, fontFamily: sans, fontSize: size, fontWeight: 400, lineHeight: 1.25, whiteSpace: 'nowrap',
					boxShadow: '0 14px 34px rgba(4,2,10,0.5), inset 0 1px 0 rgba(255,255,255,0.06)'}}>
					<Speech segs={segs} t={t} size={size} typed={typed} />
				</div>
				<div style={{position: 'absolute', bottom: -9, left: side === 'center' ? 'calc(50% - 9px)' : side === 'left' ? 'calc(88% - 9px)' : 'calc(12% - 9px)',
					width: 18, height: 18, background: 'rgba(22,17,38,0.96)', borderRight: '2px solid rgba(185,169,227,0.5)',
					borderBottom: '2px solid rgba(185,169,227,0.5)', transform: 'rotate(45deg)'}} />
			</div>
		</div>
	);
};

// ── Captions: the film's own voice ───────────────────────────────────────────
export const Caption: React.FC<{
	lines: string[]; t: number; from: number; to: number; y?: number; size?: number; italic?: boolean; align?: 'center' | 'left'; x?: number;
}> = ({lines, t, from, to, y = 118, size = 66, italic, align = 'center', x = 0}) => {
	const exit = at(t, [to - 0.5, to], [0, 1], ease.in);
	if (t < from - 0.1 || t > to + 0.05) return null;
	let index = 0;
	return (
		<AbsoluteFill style={{pointerEvents: 'none'}}>
			<div style={{position: 'absolute', top: y, left: align === 'center' ? 0 : x, right: 0, textAlign: align, fontFamily: serif,
				fontStyle: italic ? 'italic' : 'normal', fontWeight: 500, fontSize: size, lineHeight: 1.18, color: C.paper,
				letterSpacing: '0.005em', textShadow: '0 2px 24px rgba(8,5,18,0.85), 0 0 2px rgba(8,5,18,0.6)',
				opacity: 1 - exit, filter: `blur(${exit * 6}px)`, translate: `0 ${-exit * 10}px`}}>
				{lines.map((line, li) => (
					<div key={li}>
						{line.split(' ').map((word, wi) => {
							const k = from + index++ * 0.07 + li * 0.12;
							const o = at(t, [k, k + 0.55], [0, 1]);
							return (
								<span key={wi} style={{display: 'inline-block', opacity: o, filter: `blur(${(1 - o) * 7}px)`,
									translate: `0 ${(1 - o) * 16}px`, marginRight: '0.26em'}}>{word}</span>
							);
						})}
					</div>
				))}
			</div>
		</AbsoluteFill>
	);
};

/** Readability for captions over busy art: a soft dark band at the top. */
export const TopShade: React.FC<{opacity?: number}> = ({opacity = 0.75}) => (
	<AbsoluteFill style={{background: 'linear-gradient(180deg, rgba(8,6,16,0.82) 0%, rgba(8,6,16,0.45) 22%, rgba(8,6,16,0) 42%)', opacity, pointerEvents: 'none'}} />
);

/** Where we are: a city in tracked capitals, and a quieter line under it. */
export const Chyron: React.FC<{city: string; sub?: string; t: number; from: number; to: number}> = ({city, sub, t, from, to}) => {
	const o = window(t, from, to, 0.5);
	if (o <= 0) return null;
	const line = at(t, [from, from + 0.9], [0, 1]);
	return (
		<div style={{position: 'absolute', left: 92, bottom: 96, opacity: o, translate: `${(1 - o) * -14}px 0`}}>
			<div style={{fontFamily: sans, fontWeight: 600, fontSize: 24, letterSpacing: '0.42em', color: C.gold,
				textShadow: '0 2px 14px rgba(0,0,0,0.6)'}}>{city}</div>
			<div style={{height: 2, width: 220 * line, background: `linear-gradient(90deg, ${C.gold}, rgba(232,187,98,0))`, margin: '10px 0 8px'}} />
			{sub && <div style={{fontFamily: serif, fontStyle: 'italic', fontSize: 32, color: C.paper, textShadow: '0 2px 14px rgba(0,0,0,0.7)'}}>{sub}</div>}
		</div>
	);
};

// ── Finish: grain, vignette, a fade ──────────────────────────────────────────
export const Grain: React.FC<{opacity?: number}> = ({opacity = 0.07}) => {
	const frame = useCurrentFrame();
	return (
		<AbsoluteFill style={{pointerEvents: 'none', mixBlendMode: 'overlay', opacity}}>
			<svg width="1920" height="1080">
				<filter id={`grain${frame % 6}`}>
					<feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed={frame % 97} stitchTiles="stitch" />
					<feColorMatrix type="saturate" values="0" />
				</filter>
				<rect width="1920" height="1080" filter={`url(#grain${frame % 6})`} />
			</svg>
		</AbsoluteFill>
	);
};

export const Vignette: React.FC<{strength?: number}> = ({strength = 0.55}) => (
	<AbsoluteFill style={{pointerEvents: 'none', background: `radial-gradient(ellipse 75% 72% at 50% 48%, rgba(0,0,0,0) 55%, rgba(4,3,10,${strength}) 100%)`}} />
);

export const Black: React.FC<{opacity: number}> = ({opacity}) =>
	opacity > 0 ? <AbsoluteFill style={{background: '#000', opacity, pointerEvents: 'none'}} /> : null;
