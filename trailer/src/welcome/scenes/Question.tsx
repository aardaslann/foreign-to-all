// The question, typed on paper, and the beat drop: everything bursts out of it.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, C, copy, cue, ease, rng, sans, useFilm, useFrame} from '../lib/core';
import {Flash, Paper, Vignette} from '../lib/surface';
import {marks, Mark, place, Star, Stroke} from '../lib/ink';
import {Glyph, Typed} from '../lib/type';
import {Icon, Item, type ItemId} from '../lib/pixel';

const CPS = 30;
const [LINE1, LINE2] = copy.question;
const WORD = 'understand';
const [BEFORE, AFTER] = LINE1.split(WORD);

/** The two lines of the question, typed; the word "understand" gets a line under it. Four short lines on a tall frame. */
const QuestionText: React.FC<{t: number; fs: number; tall: boolean; full?: boolean}> = ({t, fs, tall, full}) => {
	const q = full ? -100 : cue('question') + 0.05;
	const q2 = full ? -100 : cue('question2');
	const w = q + BEFORE.length / CPS;
	const a = w + WORD.length / CPS;
	const under = at(t, [a + 0.15, a + 0.5], [0, 1], ease.inOut);
	const before = tall ? BEFORE.trimEnd() + '\n' : BEFORE;
	const second = tall ? LINE2.replace('share ', 'share\n') : LINE2;
	return (
		<div style={{fontFamily: sans, fontWeight: 700, fontSize: fs, color: C.ink, textAlign: 'center', lineHeight: 1.22, letterSpacing: '-0.015em', whiteSpace: 'pre-line'}}>
			<Typed text={before} t={t} from={q} cps={CPS} cursor="bar" cursorUntil={w} />
			<Mark pts={marks.underline(3)} p={under} color={C.ink} width={5}>
				<Typed text={WORD} t={t} from={w} cps={CPS} cursor="bar" cursorUntil={a} />
			</Mark>
			<Typed text={AFTER} t={t} from={a} cps={CPS} cursor="bar" cursorUntil={q2} />
			{'\n'}
			<Typed text={second} t={t} from={q2} cps={CPS} cursor="bar" />
		</div>
	);
};

export const Question: React.FC = () => {
	const t = useFilm();
	const {tall} = useFrame();
	const burst = cue('burst');
	// The breath before the drop: a slow push and a tremble.
	const push = at(t, [cue('question2'), burst], [1, 1.05], ease.in);
	const shake = at(t, [burst - 0.3, burst], [0, 1]) * Math.sin(t * 90) * 3;
	return (
		<Paper>
			<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', padding: '0 70px', scale: `${push}`, translate: `${shake}px 0`}}>
				<QuestionText t={t} fs={tall ? 76 : 64} tall={tall} />
			</AbsoluteFill>
		</Paper>
	);
};

type Piece = {kind: 'item'; id: ItemId} | {kind: 'glyph'; index: number} | {kind: 'icon'; index: number};
const PIECES: Piece[] = [
	{kind: 'item', id: 'bread'}, {kind: 'glyph', index: 7}, {kind: 'item', id: 'cay'}, {kind: 'item', id: 'kermel_flowers'},
	{kind: 'glyph', index: 0}, {kind: 'item', id: 'apple'}, {kind: 'icon', index: 4}, {kind: 'item', id: 'money'},
	{kind: 'glyph', index: 3}, {kind: 'item', id: 'old_book'}, {kind: 'item', id: 'water'}, {kind: 'glyph', index: 5},
];

/** Where a piece is `dt` after the burst: thrown hard, then drifting. */
const flight = (i: number, dt: number, W: number, H: number) => {
	const r = rng(70 + i);
	const a = (i / PIECES.length) * Math.PI * 2 + (r() - 0.5) * 0.5;
	const reach = Math.min(W, H) * (0.34 + r() * 0.22);
	const out = 1 - Math.exp(-Math.max(0, dt) * 9);
	const drift = Math.max(0, dt) * 26;
	return {x: W / 2 + Math.cos(a) * (reach * out + drift), y: H / 2 + Math.sin(a) * (reach * out + drift) * (H > W ? 1.25 : 0.85),
		spin: (r() - 0.5) * 70 * out + dt * (r() - 0.5) * 30, size: 0.9 + r() * 0.5};
};

const PieceView: React.FC<{p: Piece; x: number; y: number; size: number; rotate: number; opacity?: number}> = ({p, x, y, size, rotate, opacity = 1}) => {
	if (p.kind === 'item') return <Item id={p.id} x={x} y={y} size={size} rotate={rotate} opacity={opacity} />;
	if (p.kind === 'icon') return <Icon index={p.index} x={x} y={y} size={size * 0.8} rotate={rotate} opacity={opacity} />;
	return <Glyph index={p.index} size={size * 0.62} color={C.glyph}
		style={{position: 'absolute', left: x - size * 0.31, top: y - size * 0.31, rotate: `${rotate}deg`, opacity}} />;
};

/** The drop: an amber flash, a mint star of light, and everything thrown out from the question. */
export const Burst: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const burst = cue('burst');
	const dt = t - burst;
	const base = tall ? 160 : 124;
	const light = at(t, [burst, burst + 0.35], [0.4, 1], ease.out);
	const punch = at(t, [burst, burst + 0.25], [1.1, 1], ease.out);
	// a red brush arc swept over the top, the reference's flourish
	const arc = place(marks.circle(31, 0.42), W * 0.18, H * (tall ? 0.16 : 0.1), W * 0.9, H * (tall ? 0.3 : 0.5));
	return (
		<Paper light={0.6}>
			{/* the mint light from the left edge, the alien's colour */}
			<AbsoluteFill style={{background: `radial-gradient(ellipse 55% 70% at 0% 50%, rgba(70,232,192,${0.55 * light}), rgba(70,232,192,0) 70%)`}} />
			<Star x={-W * 0.02} y={H * 0.5} r={Math.min(W, H) * 0.62 * light} color={C.mint} glow={30} pinch={0.07} opacity={0.95} />
			<Vignette strength={0.62} color="23,21,28" />
			{PIECES.map((p, i) => {
				const trail = [0.05, 0.035, 0.02].map((k) => flight(i, dt - k, W, H));
				const now = flight(i, dt, W, H);
				return (
					<React.Fragment key={i}>
						{dt < 0.3 && trail.map((q, k) => <PieceView key={k} p={p} x={q.x} y={q.y} size={base * now.size} rotate={q.spin} opacity={0.18 + k * 0.1} />)}
						<PieceView p={p} x={now.x} y={now.y} size={base * now.size} rotate={now.spin} />
					</React.Fragment>
				);
			})}
			<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', padding: '0 70px', scale: `${punch}`}}>
				<QuestionText t={t} fs={tall ? 76 : 64} tall={tall} full />
			</AbsoluteFill>
			<Stroke pts={arc} p={at(t, [burst + 0.08, burst + 0.45], [0, 1], ease.out)} color={C.red} width={tall ? 12 : 10} />
			<Flash from={burst} frames={2} color={C.amber} />
			{dt < 2 / 30 && <Star x={W / 2} y={H / 2} r={Math.min(W, H) * 0.42} color={C.white} pinch={0.09} />}
		</Paper>
	);
};
