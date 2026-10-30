// The resolve: you may still be foreign, but you can still understand —
// then F·O·R·E·I·G·N a letter at a time (the O is the world), gathered by the
// red pen into the game's wordmark.
import React from 'react';
import {AbsoluteFill, cancelRender, continueRender, delayRender, staticFile} from 'remotion';
import {at, BEAT, C, copy, cue, ease, pixel, rng, sans, T, useFilm, useFrame, window} from '../lib/core';
import {Flash, Night, Paper, Pixelated} from '../lib/surface';
import {marks, Mark, place, Star, Stroke} from '../lib/ink';
import {Decode, Glyph, Typed} from '../lib/type';
import {Earth, Item, type ItemId} from '../lib/pixel';

// ── you may still be foreign. but you can still understand. ────────────────
export const Foreign: React.FC = () => {
	const t = useFilm();
	const {tall} = useFrame();
	const [foreign, understand, letters] = [cue('foreign'), cue('understand'), cue('letters')];
	const [l1, l2, l3] = copy.foreign;
	const [pre, word] = ['you may still be ', 'foreign'];
	const w = foreign + 0.05 + pre.length / 26;
	const fs = tall ? 76 : 66;
	const big = tall ? 156 : 176;
	const push = at(t, [foreign, letters], [1, 1.06], ease.linear);
	return (
		<Paper>
			<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', scale: `${push}`}}>
				<div style={{fontFamily: sans, fontWeight: 700, fontSize: fs, color: C.ink, textAlign: 'center', lineHeight: 1.3, letterSpacing: '-0.01em'}}>
					<Typed text={pre} t={t} from={foreign + 0.05} cps={26} />
					<Mark pts={marks.underline(12)} p={at(t, [w + 0.45, w + 0.8], [0, 1], ease.inOut)} color={C.ink} width={4}>
						<Typed text={word} t={t} from={w} cps={26} />
					</Mark>
					<Typed text={l1.slice(pre.length + word.length)} t={t} from={w + word.length / 26} cps={26} />
					<br />
					<Typed text={l2} t={t} from={understand} cps={26} cursor="bar" cursorUntil={understand + 0.75} />
					<div style={{fontSize: big, fontWeight: 900, letterSpacing: '-0.035em', marginTop: fs * 0.25, opacity: at(t, [understand + 0.45, understand + 0.6], [0, 1])}}>
						<Mark pts={marks.circle(23, 1.2)} p={at(t, [understand + 1.1, understand + 1.42], [0, 1], ease.inOut)} color={C.red} width={7} padX={tall ? -1 : 5} padY={-10}>
							<Decode text={l3} t={t} from={understand + 0.7} per={0.05} fontSize={big} color={C.ink} glyphColor={C.glyph} landColor={C.red} seed={5} glyphScale={0.5} />
						</Mark>
					</div>
				</div>
			</AbsoluteFill>
		</Paper>
	);
};

// ── F·O·R·E·I·G·N ───────────────────────────────────────────────────────────
const WORD = 'FOREIGN';
const SLOT_THINGS: (ItemId | null)[] = [null, null, 'cay', 'bread', 'old_book', 'kermel_flowers', 'apple'];
const BACKS = ['paper', 'night', 'red', 'night', 'paper', 'red', 'night'] as const;
const HALF = BEAT / 2;

const useRow = () => {
	const {W, H, tall, cy} = useFrame();
	const fs = tall ? 168 : 190;
	const slot = tall ? 146 : 215;
	const x = (k: number) => W / 2 + (k - 3) * slot;
	return {W, H, tall, cy, fs, slot, x};
};

/** One slot of the word: a letter, or the world for the O. */
const Slot: React.FC<{k: number; x: number; y: number; fs: number; color: string; spin: number; scale?: number; rotate?: number}> = ({k, x, y, fs, color, spin, scale = 1, rotate = 0}) => (
	<div style={{position: 'absolute', left: x, top: y, translate: '-50% -50%', scale: `${scale}`, rotate: `${rotate}deg`}}>
		{k === 1 ? (
			<div style={{position: 'relative', width: fs * 0.84, height: fs * 0.84}}><Earth x={fs * 0.42} y={fs * 0.42} size={fs * 0.84} spin={spin} /></div>
		) : (
			<span style={{fontFamily: pixel, fontWeight: 700, fontSize: fs, color, lineHeight: 1, display: 'block'}}>{WORD[k]}</span>
		)}
	</div>
);

/** Where letter `i` lands when the word flies apart. */
const scattered = (i: number, W: number, H: number) => {
	const r = rng(300 + i);
	const col = i % 3, row = Math.floor(i / 3);
	return {x: W * (0.2 + col * 0.3 + (r() - 0.5) * 0.14), y: H * (0.22 + row * 0.27 + (r() - 0.5) * 0.1), r: (r() - 0.5) * 70};
};

export const Letters: React.FC = () => {
	const t = useFilm();
	const {W, H, cy, fs, x} = useRow();
	const [letters, scatter, converge] = [cue('letters'), cue('scatter'), cue('converge')];
	const spin = (t - letters) * 140;
	if (t >= scatter) {
		// the letters fly apart over the paper
		const k = at(t, [scatter, converge], [0, 1], ease.out);
		return (
			<Paper>
				{[...WORD].map((_, i) => {
					const s = scattered(i, W, H);
					return <Slot key={i} k={i} x={x(i) + (s.x - x(i)) * k} y={cy + (s.y - cy) * k} fs={fs} color={C.ink} spin={spin} scale={1 - 0.5 * k} rotate={s.r * k} />;
				})}
			</Paper>
		);
	}
	const card = Math.min(6, Math.floor((t - letters) / HALF));
	const local = t - letters - card * HALF;
	const back = BACKS[card];
	const ink = back === 'paper' ? C.ink : C.white;
	const zoom = at(local, [0, HALF], [1.07, 1], ease.out);
	const thing = SLOT_THINGS[card + 1];
	const content = (
		<AbsoluteFill style={{scale: `${zoom}`}}>
			{[...WORD].slice(0, card + 1).map((_, i) => (
				<Slot key={i} k={i} x={x(i)} y={cy} fs={fs} color={ink} spin={spin} scale={i === card ? at(local, [0, 0.12], [1.35, 1], ease.out) : 1} />
			))}
			{card === 0 && <Slot k={1} x={x(1)} y={cy} fs={fs} color={ink} spin={spin} scale={at(local, [0, 0.14], [0.4, 1], ease.back)} />}
			{thing && <Item id={thing} x={x(card + 1)} y={cy} size={fs * 0.9} scale={at(local, [0, 0.14], [0.4, 1], ease.back)} rotate={(1 - at(local, [0, 0.14], [0, 1])) * -20} />}
		</AbsoluteFill>
	);
	if (back === 'paper') return <Paper>{content}</Paper>;
	return <Night color={back === 'red' ? C.red : C.night}>{content}</Night>;
};

/** The red pen loops each scattered letter, then they all pull together. */
export const Converge: React.FC = () => {
	const t = useFilm();
	const {W, H, cy, fs, x} = useRow();
	const [converge, snap] = [cue('converge'), cue('snap')];
	const spin = (t - cue('letters')) * 140;
	const pull = at(t, [snap - 0.32, snap], [0, 1], ease.in);
	const dots = rng(77);
	return (
		<Paper>
			{Array.from({length: 6}, (_, i) => (
				<div key={`d${i}`} style={{position: 'absolute', left: W * (0.08 + dots() * 0.84), top: H * (0.1 + dots() * 0.8), width: 10, height: 10, borderRadius: '50%', background: C.ink, opacity: 1 - pull}} />
			))}
			{[...WORD].map((_, i) => {
				const s = scattered(i, W, H);
				const drift = Math.sin(t * 1.3 + i) * 10;
				const px = s.x + (x(i) - s.x) * pull, py = s.y + drift + (cy - s.y - drift) * pull;
				const loop = place(marks.circle(60 + i, 1.4), s.x - fs * 0.45, s.y - fs * 0.45, fs * 0.9, fs * 0.9);
				return (
					<React.Fragment key={i}>
						<Stroke pts={loop} p={at(t, [converge + 0.1 + i * 0.13, converge + 0.5 + i * 0.13], [0, 1], ease.inOut)} color={C.red} width={4} opacity={1 - pull} />
						<Slot k={i} x={px} y={py} fs={fs} color={C.ink} spin={spin} scale={0.5 + 0.5 * pull} rotate={s.r * (1 - pull)} />
					</React.Fragment>
				);
			})}
		</Paper>
	);
};

// ── The wordmark ─────────────────────────────────────────────────────────────
const STRANGER = ['stranger', 'Fremder', 'yabancı', 'étranger', 'чужой', 'अजनबी', '異邦人', 'forastero', 'straniero', 'người lạ', '이방인', 'უცხო', 'estrangeiro', 'malihini'];
const SCRIPTS = ['NotoSansJP', 'NotoSansKR', 'NotoSansDevanagari', 'NotoSansGeorgian'];
const scriptsReady = delayRender('stranger-word fonts');
Promise.all(SCRIPTS.map((name) => new FontFace(name, `url(${staticFile(`v7/fonts/${name}.ttf`)})`).load()
	.then((face) => {
		// this TypeScript's DOM lib predates FontFaceSet.add
		(document.fonts as unknown as {add: (f: FontFace) => void}).add(face);
	})))
	.then(() => continueRender(scriptsReady))
	.catch((err: unknown) => cancelRender(err));

export const Title: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const [snap, tagline, fade] = [cue('snap'), cue('tagline'), cue('fade')];
	const k = tall ? 4 : 5;
	const mark = {w: 240 * k, h: 84 * k};
	const top = (tall ? H * 0.4 : H * 0.36) - mark.h / 2;
	const land = at(t, [snap, snap + 0.28], [1.18, 1], ease.out);
	const word = Math.max(0, Math.floor((t - snap - 0.5) / HALF)) % STRANGER.length;
	const r = rng(91);
	return (
		<Night>
			{/* glyphs drifting up behind, the language you are learning */}
			{Array.from({length: 14}, (_, i) => {
				const x = r() * W, speed = 30 + r() * 50, y0 = r() * H;
				const y = ((y0 - (t - snap) * speed) % H + H) % H;
				return <Glyph key={i} index={i % 8} size={24 + r() * 30} color={C.lavender} style={{position: 'absolute', left: x, top: y, opacity: 0.12 + r() * 0.12}} />;
			})}
			<div style={{position: 'absolute', left: (W - mark.w) / 2, top, width: mark.w, height: mark.h, scale: `${land}`}}>
				<Pixelated src="v7/plates/wordmark.png" style={{width: mark.w, height: mark.h}} />
			</div>
			{[[-0.42, -0.1, C.mint], [0.44, 0.05, C.lavender], [-0.3, 0.42, C.lavender], [0.36, -0.38, C.mint], [0.05, -0.5, C.white]].map(([dx, dy, col], i) => {
				const tw = window(t, snap + 0.1 + i * 0.22, snap + 0.9 + i * 0.22, 0.25);
				return <Star key={i} x={W / 2 + (dx as number) * mark.w} y={top + mark.h / 2 + (dy as number) * mark.h * 1.4} r={(tall ? 26 : 30) * tw} color={col as string} glow={8} />;
			})}
			<div style={{position: 'absolute', left: 0, right: 0, top: top + mark.h + (tall ? 10 : 0), textAlign: 'center', whiteSpace: 'pre',
				fontFamily: `${sans}, ${SCRIPTS.join(', ')}`, fontWeight: 600, fontSize: tall ? 46 : 38, color: C.lavender, opacity: at(t, [snap + 0.45, snap + 0.7], [0, 1])}}>
				{`◈   ${STRANGER[word]}   ◈`}
			</div>
			<div style={{position: 'absolute', left: 60, right: 60, top: top + mark.h + (tall ? 120 : 96), textAlign: 'center', fontFamily: sans, fontWeight: 700,
				fontSize: tall ? 60 : 50, color: C.white, letterSpacing: '-0.01em', whiteSpace: 'pre-line', lineHeight: 1.2, opacity: at(t, [tagline, tagline + 0.5], [0, 1]),
				translate: `0 ${at(t, [tagline, tagline + 0.6], [16, 0], ease.out)}px`}}>
				{tall ? copy.tagline.replace('. ', '.\n') : copy.tagline}
			</div>
			<Flash from={snap} frames={2} color={C.white} />
			<AbsoluteFill style={{background: '#000', opacity: at(t, [fade, T.duration - 0.15], [0, 1])}} />
		</Night>
	);
};
