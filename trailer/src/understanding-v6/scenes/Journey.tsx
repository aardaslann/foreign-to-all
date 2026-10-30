// London, Istanbul, Tokyo: the words are only the beginning.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {T, at, ease, move, voice, useSeconds, Bubble, Caption, Chyron, Item, Person, TopShade, Vignette, Wash, World, type Cam, type SceneId} from '../lib/core';
import {Smoke, Tanabata} from '../lib/fx';

const local = (id: string, scene: SceneId) => {
	const v = voice(id);
	return {from: v.at - T.scenes[scene][0], to: v.at - T.scenes[scene][0] + v.dur};
};
const HEAD = 150;
const during = (t: number, w: {from: number; to: number}, pad = 0.15) => t > w.from - 0.05 && t < w.to + pad;

/** A soft light on the plate: a lamp, a lantern, a lit window. */
const Glow: React.FC<{x: number; y: number; r: number; color: string; t: number; flicker?: number}> = ({x, y, r, color, t, flicker = 0}) => {
	const k = 1 - flicker * (0.5 + 0.5 * Math.sin(t * 7.3 + x * 0.05) * Math.sin(t * 3.1 + y));
	return (
		<div style={{position: 'absolute', left: x - r, top: y - r, width: r * 2, height: r * 2, borderRadius: '50%', mixBlendMode: 'screen',
			opacity: k, background: `radial-gradient(circle, ${color} 0%, rgba(0,0,0,0) 70%)`, pointerEvents: 'none'}} />
	);
};

/** Two camera moves joined: a quick settle, then a long slow drift. */
const settle = (t: number, end: number, a: Cam, b: Cam, c: Cam, cut = 1.6): Cam =>
	t < cut ? move(t, 0, cut, a, b, ease.out) : move(t, cut, end, b, c);

// ── London: "You alright?" ───────────────────────────────────────────────────
const HIGH = {alien: {x: 740, y: 742}, nadia: {x0: 1210, x1: 935, y: 744}};

export const London: React.FC = () => {
	const t = useSeconds();
	const alright = local('nadia-alright', 'london');
	const hello = local('nadia-hello', 'london');
	const reply = {from: 2.05, cps: 18};
	const walk = at(t, [0, 0.85], [0, 1], ease.out);
	const nx = HIGH.nadia.x0 + (HIGH.nadia.x1 - HIGH.nadia.x0) * walk;
	const nadia = t < 0.8 ? 'walk' : during(t, alright) ? 'wave' : during(t, hello) ? 'talk' : t > hello.to + 0.3 ? 'nod' : 'watch';
	const alien = t < reply.from - 0.1 ? 'watch' : t < 4.45 ? 'talk' : t < hello.to + 0.2 ? 'look' : 'nod';
	const lit = 'brightness(0.92) saturate(0.95)';
	return (
		<AbsoluteFill>
			<World plate="london" grade="brightness(0.92) saturate(0.96) contrast(1.05)"
				cam={settle(t, 10.97, {x: 960, y: 520, z: 1.36}, {x: 860, y: 558, z: 1.62}, {x: 845, y: 566, z: 1.72})}>
				<Glow x={1533} y={318} r={70} color="rgba(255,200,120,0.85)" t={t} flicker={0.06} />
				<Glow x={1533} y={330} r={190} color="rgba(255,170,90,0.28)" t={t} />
				<Person who="nadia" act={nadia} x={nx} y={HIGH.nadia.y} filter={lit} />
				<Person who="alien" act={alien} x={HIGH.alien.x} y={HIGH.alien.y} filter={lit} />
				<Bubble x={HIGH.nadia.x1} y={HIGH.nadia.y - HEAD} t={t} from={alright.from} to={alright.to + 0.55} side="left" segs={[{text: 'You alright?'}]} />
				<Bubble x={HIGH.alien.x} y={HIGH.alien.y - HEAD} t={t} from={reply.from} to={4.95} side="right"
					segs={[{text: "My ship crashed. I'm quite far from home."}]} typed={reply} />
				<Bubble x={HIGH.nadia.x1} y={HIGH.nadia.y - HEAD} t={t} from={hello.from} to={hello.to + 0.5} side="left"
					segs={[{text: 'Ha. I just meant '}, {text: 'hello', kind: 'amber'}, {text: '.'}]} />
			</World>
			{/* dusk on the high street */}
			<Wash color="linear-gradient(180deg, rgba(255,150,100,0.55) 0%, rgba(255,190,150,0.22) 42%, rgba(60,60,140,0.42) 100%)" blend="soft-light" />
			<Wash color="rgba(96,84,150,0.12)" blend="multiply" />
			<TopShade opacity={0.95} />
			<Chyron city="LONDON" sub="a little later" t={t} from={0.3} to={3.7} />
			<Caption lines={['Knowing the words', 'is only the beginning.']} t={t} from={7.45} to={10.8} />
			<Vignette />
		</AbsoluteFill>
	);
};

// ── Istanbul: "Buyurun. Çay?" ────────────────────────────────────────────────
const QUAY = {arda: {x: 498, y: 726}, alien: {x: 750, y: 730}, glass: {x: 592, y: 672}};

export const Istanbul: React.FC = () => {
	const t = useSeconds();
	const line = local('arda-buyurun', 'istanbul');
	const decodeAt = 62.45 - T.scenes.istanbul[0];
	// the glass: on the cart, into his hands, up to his mouth, back down
	const hand = at(t, [2.0, 2.55], [0, 1], ease.inOut);
	const sip = Math.min(at(t, [3.1, 3.4], [0, 1], ease.inOut), at(t, [5.4, 5.8], [1, 0], ease.inOut));
	const gx = QUAY.glass.x + (QUAY.alien.x + 18 - QUAY.glass.x) * hand - 8 * sip;
	const gy = QUAY.glass.y + (QUAY.alien.y - 52 - QUAY.glass.y) * hand - Math.sin(Math.PI * hand) * 36
		- 24 * sip + Math.sin(t * 5) * 1.5 * sip;
	const arda = t < line.from ? 'pour' : t < line.to + 0.05 ? 'talk' : t < 2.9 ? 'offer' : 'nod';
	const alien = t < 2.35 ? 'watch' : t < 3.1 ? 'take' : t < 5.6 ? 'drink' : 'nod';
	const warm = 'brightness(0.98) saturate(1.04)';
	return (
		<AbsoluteFill>
			<World plate="karakoy" grade="sepia(0.22) saturate(1.22) brightness(0.97) contrast(1.06)"
				cam={settle(t, 7.31, {x: 600, y: 530, z: 1.5}, {x: 615, y: 548, z: 1.66}, {x: 625, y: 556, z: 1.78}, 1.2)}>
				<Person who="arda" act={arda} x={QUAY.arda.x} y={QUAY.arda.y} filter={warm} />
				<Person who="alien" act={alien} x={QUAY.alien.x} y={QUAY.alien.y} filter={warm} />
				<Item id="cay" x={gx} y={gy} size={34} style={{opacity: at(t, [0.25, 0.6], [0, 1]), filter: 'drop-shadow(0 0 4px rgba(255,190,120,0.7))'}} />
				{t < 3.3 && <Smoke t={t} x={gx + 2} y={gy - 18} count={6} scale={0.16} color="255,250,240" />}
				<Bubble x={QUAY.arda.x} y={QUAY.arda.y - HEAD - 4} t={t} from={line.from} to={line.to + 0.9} side="left"
					segs={[{text: 'Buyurun. ', kind: 'glyph'}, {text: 'Çay', kind: 'decode', at: decodeAt}, {text: '?'}]} />
			</World>
			{/* golden hour on the Golden Horn */}
			<Wash color="linear-gradient(180deg, rgba(255,170,90,0.6) 0%, rgba(255,130,80,0.22) 45%, rgba(80,60,130,0.3) 100%)" blend="soft-light" />
			<Wash color="radial-gradient(ellipse 60% 55% at 12% 8%, rgba(255,190,110,0.55), rgba(255,140,80,0.12) 55%, rgba(0,0,0,0) 80%)" blend="screen" />
			<TopShade opacity={0.9} />
			<Chyron city="ISTANBUL" sub="Karaköy" t={t} from={0.25} to={3.4} />
			<Caption lines={['A cup of tea.', 'A way of welcoming you.']} t={t} from={3.7} to={7.15} />
			<Vignette />
		</AbsoluteFill>
	);
};

// ── Tokyo: Tanabata ──────────────────────────────────────────────────────────
const NAKA = {setsuko: {x: 1012, y: 736}, alien: {x: 1168, y: 738}, bamboo: {x: 1322, y: 742, h: 330}};
const LANTERNS: [number, number, number][] = [
	[838, 335, 190], [525, 200, 80], [1150, 200, 80], [645, 295, 62], [1030, 295, 62],
	[695, 345, 50], [980, 345, 50], [520, 490, 62], [1155, 490, 62],
];

export const Tokyo: React.FC = () => {
	const t = useSeconds();
	const line = local('setsuko-tanabata', 'tokyo');
	const decodeAt = 69.35 - T.scenes.tokyo[0];
	const added = 72.45 - T.scenes.tokyo[0];
	// the paper strip: her hand → his hand → the bamboo
	const give = at(t, [2.75, 3.15], [0, 1], ease.inOut);
	const tie = at(t, [3.6, added], [0, 1], ease.inOut);
	const sx = 1036 + (1146 - 1036) * give + (1238 - 1146) * tie;
	const sy = 650 - Math.sin(Math.PI * give) * 20 + (560 - 650) * tie;
	const setsuko = t < line.from ? 'stand' : t < line.to + 0.1 ? 'talk' : t < 3.3 ? 'offer' : t < added + 0.2 ? 'watch' : 'nod';
	const alien = t < 2.9 ? 'watch' : t < 3.5 ? 'take' : t < added + 0.25 ? 'interact' : 'look';
	const lit = 'brightness(0.86) saturate(0.95)';
	return (
		<AbsoluteFill>
			<World plate="asakusa" grade="brightness(0.56) saturate(1.1) contrast(1.1) hue-rotate(-8deg)"
				cam={settle(t, 7.32, {x: 1080, y: 520, z: 1.45}, {x: 1130, y: 546, z: 1.62}, {x: 1150, y: 556, z: 1.72}, 1.4)}>
				{LANTERNS.map(([x, y, r], i) => (
					<React.Fragment key={i}>
						<Glow x={x} y={y} r={r * 0.9} color="rgba(255,196,120,0.95)" t={t} flicker={0.08} />
						<Glow x={x} y={y + r * 0.5} r={r * 2.4} color="rgba(255,140,80,0.32)" t={t} />
					</React.Fragment>
				))}
				<Tanabata t={t} x={NAKA.bamboo.x} y={NAKA.bamboo.y} h={NAKA.bamboo.h} added={added} />
				<Person who="setsuko" act={setsuko} x={NAKA.setsuko.x} y={NAKA.setsuko.y} filter={lit} />
				<Person who="alien" act={alien} x={NAKA.alien.x} y={NAKA.alien.y} filter={lit} />
				{t > 2.6 && t < added && (
					<div style={{position: 'absolute', left: sx - 5, top: sy - 16, width: 10, height: 32, background: '#7fd8c6',
						rotate: `${Math.sin(t * 9) * 8}deg`, boxShadow: '0 0 10px rgba(127,216,198,0.8)', opacity: at(t, [2.6, 2.8], [0, 1])}} />
				)}
				<Bubble x={NAKA.setsuko.x} y={NAKA.setsuko.y - HEAD} t={t} from={line.from} to={line.to + 0.6} side="left"
					segs={[{text: 'Tanabata', kind: 'decode', at: decodeAt}, {text: ' da yo. Issho ni.', kind: 'glyph'}]} />
			</World>
			{/* an evening of lanterns */}
			<Wash color="linear-gradient(180deg, rgb(120,124,210) 0%, rgb(255,255,255) 46%)" blend="multiply" />
			<TopShade opacity={0.85} />
			<Chyron city="TOKYO" sub="Tanabata" t={t} from={0.3} to={3.3} />
			<Caption lines={['Share in the traditions.']} t={t} from={1.7} to={4.25} />
			<Caption lines={['Discover the stories', 'they carry.']} t={t} from={4.5} to={7.2} />
			<Vignette />
		</AbsoluteFill>
	);
};
