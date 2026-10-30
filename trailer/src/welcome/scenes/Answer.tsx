// The answer: the alien, seen as warmth — "you don't start with words." —
// then a ring of the cities' things, and an ink ball knocks through it.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, C, copy, cue, ease, FPS, rng, sans, useFilm, useFrame, window} from '../lib/core';
import {Night, Paper} from '../lib/surface';
import {InkBall, partial, type Pt, smoothPath, Splat, Star} from '../lib/ink';
import {Glyph, glyphOf, Typed} from '../lib/type';
import {Icon, Item, type ItemId, Sprite, Warm} from '../lib/pixel';

/** A word that pops in on its own beat. */
const Pop: React.FC<{t: number; at: number; children: React.ReactNode}> = ({t, at: from, children}) => (
	<span style={{display: 'inline-block', opacity: at(t, [from, from + 0.08], [0, 1]), translate: `0 ${at(t, [from, from + 0.16], [18, 0], ease.out)}px`}}>{children}</span>
);

/** "words." losing its letters back to glyphs, one by one. */
const Unword: React.FC<{text: string; t: number; from: number; fs: number}> = ({text, t, from, fs}) => (
	<>
		{[...text].map((ch, i) => {
			const go = from + i * 0.06;
			if (t < go) return <span key={i}>{ch}</span>;
			const index = t < go + 0.12 ? Math.floor(rng(i * 13 + Math.floor(t * FPS))() * 8) : glyphOf(ch);
			return <Glyph key={i} index={index} size={fs * 0.62} color={C.lavender} style={{margin: '0 0.03em'}} />;
		})}
	</>
);

/** A thin white ring around the head, its far half behind him. */
const ringPts = (cx: number, cy: number, rx: number, ry: number, tilt: number, from: number, to: number): Pt[] =>
	Array.from({length: 48}, (_, i) => {
		const a = from + ((to - from) * i) / 47;
		const x = Math.cos(a) * rx, y = Math.sin(a) * ry;
		return [cx + x * Math.cos(tilt) - y * Math.sin(tilt), cy + x * Math.sin(tilt) + y * Math.cos(tilt)] as Pt;
	});

export const Answer: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const [answer, orbit, unwords, ring] = [cue('answer'), cue('orbit'), cue('unwords'), cue('ring')];
	const u = tall ? 27 : 22;
	const x = tall ? W / 2 : W * 0.68;
	const feet = tall ? H * 0.88 : H * 0.97;
	const head = {x, y: feet - 23 * u};
	const breathe = 1 + Math.sin((t - answer) * 3) * 0.006;
	const fs = tall ? 108 : 100;
	const cool = at(t, [unwords + 0.1, ring], [0, 1]);
	const p = at(t, [orbit, orbit + 0.7], [0, 1], ease.inOut);
	const tilt = -0.25;
	const back = ringPts(head.x, head.y, 15 * u, 3.6 * u, tilt, Math.PI, Math.PI * 2);
	const front = ringPts(head.x, head.y, 15 * u, 3.6 * u, tilt, 0, Math.PI);
	const words = copy.answer;
	const [w1, w2] = [words[0].split(' '), words[1].split(' ')];
	const times = [answer + 0.05, answer + 0.26, answer + 0.5, orbit - 0.78, orbit - 0.52];
	const textBox: React.CSSProperties = tall
		? {position: 'absolute', left: 0, right: 0, top: H * 0.13, textAlign: 'center'}
		: {position: 'absolute', left: W * 0.08, top: H * 0.36, textAlign: 'left'};
	return (
		<Night>
			<AbsoluteFill style={{background: C.paper, opacity: cool}} />
			<AbsoluteFill style={{scale: `${breathe}`, transformOrigin: `${x}px ${feet}px`}}>
				<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0, opacity: 1 - cool}}>
					<path d={smoothPath(partial(back, p * 2))} fill="none" stroke={C.white} strokeWidth={3.5} strokeLinecap="round" opacity={0.75} />
				</svg>
				<Warm who="alien" x={x} y={feet} u={u} heat="warm" opacity={1 - cool} />
				<Sprite who="alien" x={x} y={feet} u={u} filter="url(#heat-grey)" opacity={cool * 0.9} />
				<Sprite who="alien" x={x + 14 * cool} y={feet - 6 * cool} u={u} filter="url(#heat-grey)" opacity={cool * 0.3} />
				<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0, opacity: 1 - cool}}>
					<path d={smoothPath(partial(front, p * 2 - 1))} fill="none" stroke={C.white} strokeWidth={3.5} strokeLinecap="round" />
				</svg>
				{/* his words rise as glyphs no one here can read */}
				{[0, 1, 2, 3].map((i) => {
					const t0 = answer + 0.35 + i * 0.55;
					const k = at(t, [t0, t0 + 1.6], [0, 1], ease.linear);
					return <Glyph key={i} index={(i * 3 + 1) % 8} size={u * 2.4} color={C.lavender}
						style={{position: 'absolute', left: head.x + (i % 2 ? 1 : -1) * u * (5 + i * 1.5) - u * 1.2, top: head.y - u * 9 - k * u * 10,
							opacity: window(t, t0, t0 + 1.6, 0.3) * 0.85 * (1 - cool)}} />;
				})}
			</AbsoluteFill>
			<div style={{...textBox, fontFamily: sans, fontWeight: 800, fontSize: fs, lineHeight: 1.08, letterSpacing: '-0.02em',
				color: C.white, opacity: 1 - cool, textShadow: '0 0 40px rgba(255,138,30,0.25)'}}>
				<Pop t={t} at={times[0]}>{w1[0]}</Pop> <Pop t={t} at={times[1]}>{w1[1]}</Pop> <Pop t={t} at={times[2]}>{w1[2]}</Pop>
				<br />
				<Pop t={t} at={times[3]}>{w2[0]}</Pop> <Pop t={t} at={times[4]}><Unword text={w2[1]} t={t} from={unwords - 0.55} fs={fs} /></Pop>
			</div>
		</Night>
	);
};

// ── The ring ─────────────────────────────────────────────────────────────────
type Thing = {kind: 'item'; id: ItemId} | {kind: 'glyph'; index: number} | {kind: 'icon'; index: number};
const THINGS: Thing[] = [
	{kind: 'item', id: 'bread'}, {kind: 'item', id: 'cay'}, {kind: 'glyph', index: 7}, {kind: 'item', id: 'kermel_flowers'}, {kind: 'item', id: 'apple'},
	{kind: 'icon', index: 4}, {kind: 'item', id: 'old_book'}, {kind: 'glyph', index: 0}, {kind: 'item', id: 'money'}, {kind: 'item', id: 'water'},
];

const ThingView: React.FC<{thing: Thing; x: number; y: number; size: number; rotate: number; scale: number; filter?: string}> = ({thing, x, y, size, rotate, scale, filter}) => {
	if (thing.kind === 'item') return <Item id={thing.id} x={x} y={y} size={size} rotate={rotate} scale={scale} filter={filter} />;
	if (thing.kind === 'icon') return <Icon index={thing.index} x={x} y={y} size={size * 0.8 * scale} rotate={rotate} />;
	return <Glyph index={thing.index} size={size * 0.6 * scale} color={C.glyph}
		style={{position: 'absolute', left: x - size * 0.3 * scale, top: y - size * 0.3 * scale, rotate: `${rotate}deg`, filter}} />;
};

export const Ring: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const [ring, inkball, spin, listen] = [cue('ring'), cue('inkball'), cue('spin'), cue('listen')];
	const c = {x: W / 2, y: tall ? H * 0.57 : H * 0.57};
	const R = tall ? 400 : 370;
	const size = tall ? 168 : 128;
	const rot = (tt: number) => (tt - ring) * 0.45 + Math.max(0, tt - spin) ** 2 * 9;
	const pos = (i: number, tt: number) => {
		const a = (i / THINGS.length) * Math.PI * 2 + rot(tt) - Math.PI / 2;
		return {x: c.x + Math.cos(a) * R, y: c.y + Math.sin(a) * R, a};
	};
	// The ink ball: in from the top left, through two of them, out at the bottom right.
	const [t1, t2, t3] = [inkball + 0.16, inkball + 0.32, inkball + 0.55];
	const nearest = (tt: number, angle: number) => THINGS.map((_, i) => i).sort((a, b) => {
		const d = (i: number) => Math.abs(Math.atan2(Math.sin(pos(i, tt).a - angle), Math.cos(pos(i, tt).a - angle)));
		return d(a) - d(b);
	})[0];
	const hit1 = nearest(t1, -2.4), hit2 = nearest(t2, 0.75);
	const P: Pt[] = [[-W * 0.12, c.y - R * 1.5], [pos(hit1, t1).x, pos(hit1, t1).y], [pos(hit2, t2).x, pos(hit2, t2).y], [W * 1.15, c.y + R * 1.6]];
	const ball = (tt: number): Pt | null => {
		if (tt < inkball || tt > t3) return null;
		const legs = [[inkball, t1], [t1, t2], [t2, t3]];
		const k = legs.findIndex(([a, b]) => tt >= a && tt <= b);
		const [a, b] = legs[k];
		const s = (tt - a) / (b - a);
		return [P[k][0] + (P[k + 1][0] - P[k][0]) * s, P[k][1] + (P[k + 1][1] - P[k][1]) * s];
	};
	const trail = Array.from({length: 7}, (_, k) => ball(t - (6 - k) * 0.012)).filter((q): q is Pt => q !== null);
	const blur = at(t, [spin + 0.2, listen], [0, 9], ease.in);
	const grow = at(t, [spin, listen], [1, 1.35], ease.in);
	return (
		<Paper>
			<div style={{position: 'absolute', left: 0, right: 0, top: tall ? H * 0.17 : H * 0.07, textAlign: 'center', fontFamily: sans, fontWeight: 700,
				fontSize: tall ? 78 : 64, color: C.ink, opacity: at(t, [spin, spin + 0.4], [1, 0])}}>
				<Typed text={copy.startwith} t={t} from={ring + 0.1} cps={24} cursor="bar" cursorUntil={spin} />
			</div>
			<AbsoluteFill style={{scale: `${grow}`, transformOrigin: `${c.x}px ${c.y}px`}}>
				{THINGS.map((thing, i) => {
					const hitAt = i === hit1 ? t1 : i === hit2 ? t2 : Infinity;
					const p = pos(i, t);
					const pop = at(t, [ring + i * 0.035, ring + i * 0.035 + 0.28], [0, 1], ease.back);
					const bob = Math.sin(t * 2.4 + i) * 6;
					if (t >= hitAt) {
						// knocked out along the ball's line
						const dt = t - hitAt;
						const dir = i === hit1 ? [P[2][0] - P[1][0], P[2][1] - P[1][1]] : [P[3][0] - P[2][0], P[3][1] - P[2][1]];
						const len = Math.hypot(dir[0], dir[1]);
						const h = pos(i, hitAt);
						return <ThingView key={i} thing={thing} x={h.x + (dir[0] / len) * dt * 2600} y={h.y + (dir[1] / len) * dt * 2600 - dt * 300} size={size}
							rotate={dt * 900} scale={1} />;
					}
					return <ThingView key={i} thing={thing} x={p.x} y={p.y + bob} size={size} rotate={Math.sin(t * 1.7 + i) * 8} scale={pop} filter={blur ? `blur(${blur}px)` : undefined} />;
				})}
				{[[hit1, t1], [hit2, t2]].map(([i, at0]) => {
					const h = pos(i, at0);
					const k = (t - at0) / 0.35;
					return (
						<React.Fragment key={i}>
							<Splat x={h.x} y={h.y} size={size * 1.6} p={k} color={C.amber} seed={i + 5} />
							{k > 0 && k < 0.5 && <Star x={h.x} y={h.y} r={size * (0.9 - k)} color={C.amber} glow={12} />}
						</React.Fragment>
					);
				})}
				{trail.length > 0 && <InkBall trail={trail} r={tall ? 46 : 40} />}
			</AbsoluteFill>
		</Paper>
	);
};
