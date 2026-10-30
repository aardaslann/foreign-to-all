// Act I — "you can't read this." Giant glyphs, a line on paper that comes into
// focus as a welcome, and the turn: you just couldn't read it yet.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, C, copy, cue, ease, rng, sans, useFilm, useFrame, window} from '../lib/core';
import {Paper, Night, Flash} from '../lib/surface';
import {marks, Mark, place, Stroke} from '../lib/ink';
import {Decode, Glyph, glyphOf, Typed} from '../lib/type';

const LINE = copy.glyphline;

/** Dashed guide lines, the reference's ruled page. */
const Guides: React.FC<{y: number[]; color: string; opacity?: number}> = ({y, color, opacity = 0.9}) => (
	<>
		{y.map((yy, i) => (
			<div key={i} style={{position: 'absolute', left: 0, right: 0, top: yy, height: 0, borderTop: `3px dashed ${color}`, opacity}} />
		))}
	</>
);

/** The line laid out as giant glyphs: x of each character's left edge. */
const layout = (size: number) => {
	const xs: number[] = [];
	let x = 0;
	for (const ch of LINE) {
		xs.push(x);
		x += ch === ' ' ? size * 0.5 : size * 0.86;
	}
	return {xs, width: x};
};

/** The opening card: three glyphs on red, slammed in. */
export const RedCard: React.FC = () => {
	const t = useFilm();
	const {W, H, tall, cx, cy} = useFrame();
	const size = tall ? 290 : 330;
	const slam = at(t, [0, 0.12], [1.22, 1], ease.out) * at(t, [0.12, cue('track1')], [1, 0.97], ease.linear);
	const shown = [...LINE.slice(0, 3)];
	return (
		<AbsoluteFill style={{background: C.red}}>
			<Guides y={[cy - size * 0.72, cy + size * 0.72]} color={C.ink} opacity={0.75} />
			<div style={{position: 'absolute', left: 0, top: 0, width: W, height: H, scale: `${slam}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: size * 0.22}}>
				{shown.map((ch, i) => <Glyph key={i} index={glyphOf(ch)} size={size} color={C.ink} />)}
			</div>
			<Flash from={0.48} frames={2} color={C.amber} />
			<div style={{position: 'absolute', left: cx - 4, top: cy + size * 0.9, width: 8, height: 8, background: C.ink, opacity: window(t, 0.2, 0.9)}} />
		</AbsoluteFill>
	);
};

/** The line as giant glyphs on paper, the camera stepping along it on the beat. */
export const Track: React.FC = () => {
	const t = useFilm();
	const {W, H, tall, cy} = useFrame();
	const size = tall ? 260 : 300;
	const {xs} = layout(size);
	const centreOf = (a: number, b: number) => (xs[a] + xs[b] + size * 0.62) / 2;
	const stops = [centreOf(0, 7), centreOf(12, 15), centreOf(17, 25)];
	const [s1, s2, s3, dz] = [cue('track1'), cue('track2'), cue('track3'), cue('dissolve')];
	const focus = stops[0] + (stops[1] - stops[0]) * at(t, [s2, s2 + 0.32], [0, 1], ease.out) + (stops[2] - stops[1]) * at(t, [s3, s3 + 0.32], [0, 1], ease.out);
	const enter = at(t, [s1, s1 + 0.28], [W * 0.35, 0], ease.out);
	const squash = at(t, [dz, cue('small')], [1, 0.07], ease.in);
	const shrink = at(t, [dz + 0.12, cue('small')], [1, 0.22], ease.in);
	const box = place(marks.box(11), xs[12] - size * 0.18, cy - size * 0.62, xs[15] + size * 0.8 - xs[12], size * 1.24);
	const blink = Math.floor((t - s3) * 2.6) % 2 === 0;
	return (
		<Paper>
			<Guides y={[cy - size * 0.75, cy + size * 0.75]} color={C.red} opacity={at(t, [dz, cue('small')], [0.85, 0])} />
			<div style={{position: 'absolute', left: 0, top: 0, width: W, height: H, scale: `${shrink} ${shrink * squash}`, transformOrigin: '50% 50%'}}>
				<div style={{position: 'absolute', left: 0, top: 0, width: W, height: H, translate: `${W / 2 - focus + enter}px 0`}}>
					{[...LINE].map((ch, i) => ch === ' ' ? null : (
						<Glyph key={i} index={glyphOf(ch)} size={size} color={C.ink} style={{position: 'absolute', left: xs[i], top: cy - size / 2}} />
					))}
					<Stroke pts={box} p={at(t, [s2 + 0.18, s2 + 0.55], [0, 1], ease.inOut)} color={C.ink} width={7} />
					{t >= s3 && <div style={{position: 'absolute', left: xs[25] + size * 0.9, top: cy - size * 0.62, width: 12, height: size * 1.24, background: C.ink, opacity: blink ? 1 : 0}} />}
				</div>
			</div>
			<Flash from={s1} frames={1} color={C.ink} />
		</Paper>
	);
};

/** Ghost strokes: big blurred pen loops drifting behind the page. */
const Ghosts: React.FC<{t: number; from: number; until: number}> = ({t, from, until}) => {
	const {W, H, tall} = useFrame();
	const r = rng(21);
	const fade = at(t, [until, until + 0.8], [1, 0.3]);
	return (
		<>
			{[0, 1, 2].map((i) => {
				const x = W * (0.05 + r() * 0.45), y = H * (tall ? 0.18 + i * 0.24 : 0.1 + i * 0.28), w = W * (0.4 + r() * 0.3), h = H * (tall ? 0.07 : 0.12);
				const drift = (t - from) * 30;
				return <Stroke key={i} pts={place(marks.signature(40 + i), x + drift, y - drift * 0.4, w, h)} p={at(t, [from + i * 0.25, from + 1.4 + i * 0.25], [0, 1])}
					color={C.ink} width={12} blur={7} opacity={0.14 * fade} />;
			})}
		</>
	);
};

/** The small line: a selection box, a signature, then the glyphs come into focus. */
export const SmallLine: React.FC = () => {
	const t = useFilm();
	const {tall} = useFrame();
	const fs = tall ? 78 : 66;
	const [small, decode, circle, notyet] = [cue('small'), cue('decode'), cue('circle'), cue('notyet')];
	const select = window(t, small, decode - 0.35, 0.06);
	const snap = at(t, [small, small + 0.12], [1.06, 1], ease.out);
	const push = at(t, [circle, notyet], [1, 1.07], ease.linear);
	const [first, rest] = [LINE.slice(0, 8), LINE.slice(9)];
	const sig = at(t, [small + 0.1, small + 1.1], [0, 1], ease.inOut);
	return (
		<Paper>
			<Ghosts t={t} from={small} until={decode} />
			<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', scale: `${push}`}}>
				<div style={{position: 'relative', fontFamily: sans, fontWeight: 700, fontSize: fs, color: C.ink, letterSpacing: '-0.01em', textAlign: 'center', lineHeight: 1.35}}>
					<Mark pts={marks.circle(5)} p={at(t, [circle, circle + 0.45], [0, 1], ease.inOut)} color={C.red} width={6} padX={12} padY={-6}>
						<Decode text={first} t={t} from={decode} fontSize={fs} color={C.ink} glyphColor={C.ink} landColor={C.red} />
					</Mark>
					{tall ? <br /> : ' '}
					<Decode text={tall ? rest.replace('were ', 'were\n') : rest} t={t} from={decode + 0.36} fontSize={fs} color={C.ink} glyphColor={C.ink} landColor={C.red} seed={2} />
					{select > 0 && (
						<div style={{position: 'absolute', inset: '-26px -34px', border: `2px dashed ${C.ink}`, opacity: select, scale: `${snap}`}}>
							{[[0, 0], [1, 0], [0, 1], [1, 1]].map(([a, b], i) => (
								<div key={i} style={{position: 'absolute', left: `calc(${a * 100}% - 7px)`, top: `calc(${b * 100}% - 7px)`, width: 14, height: 14, background: C.paper, border: `2px solid ${C.ink}`}} />
							))}
						</div>
					)}
					<div style={{position: 'absolute', left: '18%', right: '18%', top: '125%', height: fs * 1.6, opacity: at(t, [decode - 0.3, decode], [1, 0])}}>
						<svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{width: '100%', height: '100%', overflow: 'visible', filter: 'url(#ink-rough)'}}>
							<SignaturePath p={sig} />
						</svg>
					</div>
				</div>
			</AbsoluteFill>
		</Paper>
	);
};

const SignaturePath: React.FC<{p: number}> = ({p}) => {
	const pts = marks.signature(8);
	const n = Math.max(2, Math.floor(pts.length * p));
	return <polyline points={pts.slice(0, n).map(([x, y]) => `${x},${y}`).join(' ')} fill="none" stroke={C.ink} strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" vectorEffect="non-scaling-stroke" />;
};

/** Black. The turn. */
export const NotYet: React.FC = () => {
	const t = useFilm();
	const {tall} = useFrame();
	const from = cue('notyet') + 0.06;
	return (
		<Night>
			<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', padding: '0 90px'}}>
				<div style={{fontFamily: sans, fontWeight: 700, fontSize: tall ? 88 : 76, color: C.white, textAlign: 'center', lineHeight: 1.2, whiteSpace: 'pre-line',
					letterSpacing: '-0.01em', textShadow: '0 0 30px rgba(255,255,255,0.18)'}}>
					<Typed text={tall ? copy.notyet.replace("couldn't ", "couldn't\n") : copy.notyet} t={t} from={from} cps={24} cursor="block" cursorColor={C.white} />
				</div>
			</AbsoluteFill>
		</Night>
	);
};
