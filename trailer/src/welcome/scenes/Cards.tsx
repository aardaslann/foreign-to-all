// listen. notice. try. — three hero cards on the pre-chorus break, each with
// a thing from a city, a red star behind it, and a whip between them.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, C, copy, cue, ease, FPS, rng, sans, useFilm, useFrame, window} from '../lib/core';
import {Night, Paper} from '../lib/surface';
import {SpeedLines, Star, Stroke, type Pt} from '../lib/ink';
import {Glyph, Typed} from '../lib/type';
import {Item, PixelBubble} from '../lib/pixel';

const WHIP = 4 / FPS;

/** The shared card: night, a red star, the thing popping in, the word typing with a block cursor. */
const Card: React.FC<{from: number; to: number; word: string; children: (box: {x: number; y: number; s: number; pop: number}) => React.ReactNode; beam?: boolean}> = ({from, to, word, children, beam}) => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const start = from + WHIP;
	const s = tall ? 380 : 320;
	const item = tall ? {x: W / 2, y: H * 0.38} : {x: W * 0.34, y: H / 2};
	const pop = at(t, [start, start + 0.22], [0, 1], ease.back);
	const star = at(t, [start + 0.02, start + 0.3], [0, 1], ease.back);
	const fs = tall ? 168 : 156;
	const text: React.CSSProperties = tall
		? {position: 'absolute', left: 0, right: 0, top: H * 0.6, textAlign: 'center'}
		: {position: 'absolute', left: W * 0.5, top: H / 2 - fs * 0.62};
	return (
		<Night>
			{beam && (
				<div style={{position: 'absolute', left: item.x, top: item.y - 26, width: Math.hypot(W, H), height: 52, background: C.red, transformOrigin: '0 50%',
					rotate: '-32deg', scale: `${at(t, [start + 0.05, start + 0.3], [0, 1], ease.out)} 1`, clipPath: 'polygon(0 45%, 100% 0, 100% 100%, 0 55%)'}} />
			)}
			<Star x={item.x} y={item.y} r={s * 0.9 * star} color={C.red} rotate={(t - start) * 25} glow={16} />
			<div style={{position: 'absolute', inset: 0, scale: `${0.55 + 0.45 * pop}`, rotate: `${(1 - pop) * -14}deg`, transformOrigin: `${item.x}px ${item.y}px`, opacity: pop > 0 ? 1 : 0}}>
				{children({...item, s, pop})}
			</div>
			<div style={{...text, fontFamily: sans, fontWeight: 800, fontSize: fs, color: C.white, letterSpacing: '-0.03em'}}>
				<Typed text={word} t={t} from={start + 0.06} cps={16} cursor="block" cursorColor={C.white} cursorUntil={to} />
			</div>
		</Night>
	);
};

/** listen. — someone speaking to you in glyphs, and the sound coming off it. */
const Listen: React.FC = () => {
	const t = useFilm();
	const [from, to] = [cue('listen'), cue('notice')];
	return (
		<Card from={from} to={to} word={copy.cards[0]}>
			{({x, y, s}) => (
				<>
					<PixelBubble x={x} y={y} w={s} px={s / 26}>
						{[2, 6, 7].map((g) => <Glyph key={g} index={g} size={s * 0.2} color={C.glyph} />)}
					</PixelBubble>
					{[0, 1, 2].map((k) => {
						const phase = ((t - from) * 2.2 + k / 3) % 1;
						const r = s * (0.62 + phase * 0.5);
						const arc: Pt[] = Array.from({length: 12}, (_, i) => {
							const a = -0.7 + (1.4 * i) / 11;
							return [x + Math.cos(a) * r, y + Math.sin(a) * r];
						});
						return <Stroke key={k} pts={arc} p={1} color={C.red} width={s / 22} opacity={1 - phase} />;
					})}
				</>
			)}
		</Card>
	);
};

/** notice. — the journal, a red beam, small sparks catching the eye. */
const Notice: React.FC = () => {
	const t = useFilm();
	const [from, to] = [cue('notice'), cue('try')];
	return (
		<Card from={from} to={to} word={copy.cards[1]} beam>
			{({x, y, s}) => (
				<>
					<Item id="old_book" x={x} y={y} size={s * 0.95} />
					{[0, 1, 2].map((k) => {
						const r = rng(k + 3);
						const tw = window(t, from + WHIP + 0.1 + k * 0.15, from + WHIP + 0.5 + k * 0.15, 0.12);
						return <Star key={k} x={x + (r() - 0.3) * s * 0.9} y={y - s * 0.35 - r() * s * 0.3} r={s * 0.09 * tw} color={C.amber} glow={8} />;
					})}
				</>
			)}
		</Card>
	);
};

/** try. — a glass of çay, steam rising off it in square puffs. */
const Try: React.FC = () => {
	const t = useFilm();
	const [from, to] = [cue('try'), cue('label')];
	return (
		<Card from={from} to={to} word={copy.cards[2]}>
			{({x, y, s}) => (
				<>
					<Item id="cay" x={x} y={y} size={s} />
					{[0, 1, 2, 3, 4].map((k) => {
						const life = ((t - from) * 0.9 + k / 5) % 1;
						const px = s / 16;
						return <div key={k} style={{position: 'absolute', left: x - px + Math.sin(life * 6 + k) * px * 1.5, top: y - s * 0.42 - life * s * 0.55,
							width: px * (2 - life), height: px * (2 - life), background: C.white, opacity: (1 - life) * 0.8}} />;
					})}
				</>
			)}
		</Card>
	);
};

/** A 4-frame whip across paper: things smeared sideways, red speed lines. */
const Whip: React.FC<{from: number}> = ({from}) => {
	const t = useFilm();
	const {W, H} = useFrame();
	const p = at(t, [from, from + WHIP], [0, 1], ease.linear);
	const row = ['bread', 'kermel_flowers', 'money', 'apple', 'water', 'old_book', 'cay'] as const;
	return (
		<Paper>
			<div style={{position: 'absolute', inset: 0, filter: 'blur(10px)', translate: `${(0.3 - p) * W * 1.6}px 0`}}>
				{row.map((id, i) => <Item key={id} id={id} x={W * 0.1 + i * W * 0.22} y={H / 2 + (i % 2 ? 40 : -30)} size={Math.min(W, H) * 0.22} />)}
			</div>
			<SpeedLines p={p} seed={Math.round(from * 10)} />
		</Paper>
	);
};

export const Cards: React.FC = () => {
	const t = useFilm();
	const [listen, notice, tryAt] = [cue('listen'), cue('notice'), cue('try')];
	const whipOn = (a: number) => t >= a && t < a + WHIP;
	return (
		<AbsoluteFill>
			{t < notice && <Listen />}
			{t >= notice && t < tryAt && <Notice />}
			{t >= tryAt && <Try />}
			{whipOn(listen) && <Whip from={listen} />}
			{whipOn(notice) && <Whip from={notice} />}
			{whipOn(tryAt) && <Whip from={tryAt} />}
		</AbsoluteFill>
	);
};
