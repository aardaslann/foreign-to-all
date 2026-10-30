// London, Istanbul, Tokyo: the words are only the beginning.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, local, move, typedAt, voice, useSeconds, Bubble, Item, Person, Place, TopShade, Wash, World, type SceneId} from '../lib/core';
import {Glow, Steam, Tanabata} from '../lib/fx';

const HEAD = 150;
const spoken = (id: string, sceneId: SceneId) => {
	const v = voice(id);
	return {from: local(sceneId, v.at), to: local(sceneId, v.at + v.dur)};
};
const during = (t: number, w: {from: number; to: number}) => t > w.from - 0.05 && t < w.to + 0.15;

// ── London: "You alright?" ───────────────────────────────────────────────────
const HIGH = {alien: {x: 740, y: 742}, nadia: {x0: 1210, x1: 935, y: 744}};

export const London: React.FC = () => {
	const t = useSeconds();
	const alright = spoken('nadia-alright', 'london');
	const hello = spoken('nadia-hello', 'london');
	const reply = typedAt('crashed');
	const replyFrom = local('london', reply.at);
	const replyDone = replyFrom + (reply.text.length + 1) / reply.cps;
	const nx = HIGH.nadia.x0 + (HIGH.nadia.x1 - HIGH.nadia.x0) * at(t, [0, 1.0], [0, 1]);
	const nadia = t < 1.0 ? 'walk' : during(t, alright) ? 'wave' : during(t, hello) ? 'talk' : t > hello.to + 0.3 ? 'nod' : 'watch';
	const alien = t < replyFrom - 0.1 ? 'watch' : t < replyDone ? 'talk' : t < hello.to + 0.3 ? 'look' : 'nod';
	const lit = 'brightness(0.94)';
	return (
		<AbsoluteFill>
			<World plate="london" cam={move(t, 0, 12.5, {x: 900, y: 560, z: 1.5}, {x: 850, y: 578, z: 1.64})} grade="brightness(0.92) saturate(0.96) contrast(1.04)">
				<Glow x={1533} y={300} r={64} color="rgba(255,200,120,0.85)" t={t} flicker={0.05} />
				<Glow x={1533} y={320} r={190} color="rgba(255,170,90,0.25)" />
				<Person who="nadia" act={nadia} x={nx} y={HIGH.nadia.y} filter={lit} />
				<Person who="alien" act={alien} x={HIGH.alien.x} y={HIGH.alien.y} filter={lit} />
				<Bubble x={HIGH.nadia.x1} y={HIGH.nadia.y - HEAD} t={t} from={alright.from} to={alright.to + 0.6} side="left" segs={[{text: 'You alright?'}]} />
				<Bubble x={HIGH.alien.x} y={HIGH.alien.y - HEAD} t={t} from={replyFrom} to={replyDone + 0.6} side="right" size={38}
					segs={[{text: reply.text}]} typed={{from: replyFrom, cps: reply.cps}} />
				<Bubble x={HIGH.nadia.x1} y={HIGH.nadia.y - HEAD} t={t} from={hello.from} to={hello.to + 0.6} side="left"
					segs={[{text: 'Ha. I just meant '}, {text: 'hello', kind: 'amber'}, {text: '.'}]} />
			</World>
			{/* dusk on the high street */}
			<Wash color="linear-gradient(180deg, rgba(255,150,100,0.5) 0%, rgba(255,190,150,0.2) 42%, rgba(60,60,140,0.38) 100%)" blend="soft-light" />
			<TopShade opacity={0.9} />
			<Place name="London" detail="A little later" t={t} from={0.3} to={4.8} />
		</AbsoluteFill>
	);
};

// ── Istanbul: "Buyurun. Çay?" ────────────────────────────────────────────────
const QUAY = {arda: {x: 498, y: 730}, alien: {x: 750, y: 735}, glass: {x: 592, y: 694}};

export const Istanbul: React.FC = () => {
	const t = useSeconds();
	const line = spoken('arda-buyurun', 'istanbul');
	const decodeAt = local('istanbul', 63.25);
	const give = local('istanbul', 64.2);
	const hand = at(t, [give, give + 0.6], [0, 1]);
	const sip = Math.min(at(t, [give + 1.2, give + 1.5], [0, 1]), at(t, [give + 3.6, give + 4.0], [1, 0]));
	const gx = QUAY.glass.x + (QUAY.alien.x + 18 - QUAY.glass.x) * hand - 8 * sip;
	const gy = QUAY.glass.y + (QUAY.alien.y - 52 - QUAY.glass.y) * hand - Math.sin(Math.PI * hand) * 30 - 24 * sip;
	const arda = t < line.from ? 'pour' : t < line.to + 0.05 ? 'talk' : t < give + 0.7 ? 'offer' : t < 6.5 ? 'watch' : 'nod';
	const alien = t < give + 0.2 ? 'watch' : t < give + 1.2 ? 'take' : t < give + 3.9 ? 'drink' : 'nod';
	return (
		<AbsoluteFill>
			<World plate="karakoy" cam={move(t, 0, 9.375, {x: 620, y: 560, z: 1.55}, {x: 640, y: 574, z: 1.68})}
				grade="sepia(0.18) saturate(1.15) brightness(0.98) contrast(1.04)">
				<Person who="arda" act={arda} x={QUAY.arda.x} y={QUAY.arda.y} />
				<Person who="alien" act={alien} x={QUAY.alien.x} y={QUAY.alien.y} />
				<Item id="cay" x={gx} y={gy} size={34} style={{opacity: at(t, [0.3, 0.7], [0, 1])}} />
				{sip < 0.5 && <Steam x={gx + 2} y={gy - 12} t={t} scale={0.35} />}
				<Bubble x={QUAY.arda.x} y={QUAY.arda.y - HEAD} t={t} from={line.from} to={line.to + 1.0} side="left"
					segs={[{text: 'Buyurun. ', kind: 'glyph'}, {text: 'Çay', kind: 'decode', at: decodeAt}, {text: '?'}]} />
			</World>
			{/* late afternoon on the water */}
			<Wash color="linear-gradient(180deg, rgba(255,170,90,0.55) 0%, rgba(255,130,80,0.2) 45%, rgba(80,60,130,0.28) 100%)" blend="soft-light" />
			<Wash color="radial-gradient(ellipse 60% 55% at 12% 10%, rgba(255,190,110,0.5), rgba(255,140,80,0.1) 55%, rgba(0,0,0,0) 80%)" blend="screen" />
			<TopShade opacity={0.85} />
			<Place name="Istanbul" t={t} from={0.3} to={3.8} />
		</AbsoluteFill>
	);
};

// ── Tokyo: Tanabata ──────────────────────────────────────────────────────────
const NAKA = {setsuko: {x: 1012, y: 738}, alien: {x: 1168, y: 740}, bamboo: {x: 1322, y: 744, h: 330}};
const LANTERNS: [number, number, number][] = [
	[838, 320, 190], [525, 205, 80], [1150, 205, 80], [645, 300, 62], [1030, 300, 62],
	[695, 350, 50], [980, 350, 50], [520, 490, 62], [1155, 490, 62],
];

export const Tokyo: React.FC = () => {
	const t = useSeconds();
	const line = spoken('setsuko-tanabata', 'tokyo');
	const decodeAt = local('tokyo', 72.15);
	const added = local('tokyo', 76.6);
	const giveAt = local('tokyo', 74.0);
	const give = at(t, [giveAt, giveAt + 0.4], [0, 1]);
	const tie = at(t, [giveAt + 0.8, added], [0, 1]);
	const sx = 1036 + (1146 - 1036) * give + (1238 - 1146) * tie;
	const sy = 650 - Math.sin(Math.PI * give) * 20 + (560 - 650) * tie;
	const setsuko = t < line.from ? 'stand' : t < line.to + 0.1 ? 'talk' : t < giveAt + 0.5 ? 'offer' : t < added + 0.4 ? 'watch' : t < 7.0 ? 'nod' : 'bow';
	const alien = t < giveAt + 0.1 ? 'watch' : t < giveAt + 0.8 ? 'take' : t < added + 0.2 ? 'interact' : t < 7.2 ? 'look' : 'bow';
	const lit = 'brightness(0.88)';
	return (
		<AbsoluteFill>
			<World plate="asakusa" cam={move(t, 0, 9.375, {x: 1100, y: 540, z: 1.5}, {x: 1140, y: 556, z: 1.62})}
				grade="brightness(0.56) saturate(1.1) contrast(1.1) hue-rotate(-8deg)">
				{LANTERNS.map(([x, y, r], i) => (
					<React.Fragment key={i}>
						<Glow x={x} y={y} r={r * 0.9} color="rgba(255,196,120,0.95)" t={t} flicker={0.08} />
						<Glow x={x} y={y + r * 0.5} r={r * 2.4} color="rgba(255,140,80,0.3)" />
					</React.Fragment>
				))}
				<Tanabata t={t} x={NAKA.bamboo.x} y={NAKA.bamboo.y} h={NAKA.bamboo.h} added={added} />
				<Person who="setsuko" act={setsuko} x={NAKA.setsuko.x} y={NAKA.setsuko.y} filter={lit} />
				<Person who="alien" act={alien} x={NAKA.alien.x} y={NAKA.alien.y} filter={lit} />
				{t > giveAt - 0.3 && t < added && (
					<div style={{position: 'absolute', left: sx - 5, top: sy - 16, width: 10, height: 32, background: '#7fd8c6',
						rotate: `${Math.sin(t * 6) * 6}deg`, boxShadow: '0 0 8px rgba(127,216,198,0.7)', opacity: at(t, [giveAt - 0.3, giveAt], [0, 1])}} />
				)}
				<Bubble x={NAKA.setsuko.x} y={NAKA.setsuko.y - HEAD} t={t} from={line.from} to={line.to + 0.7} side="left"
					segs={[{text: 'Tanabata', kind: 'decode', at: decodeAt}, {text: ' da yo. Issho ni.', kind: 'glyph'}]} />
			</World>
			{/* an evening of lanterns */}
			<Wash color="linear-gradient(180deg, rgb(120,124,210) 0%, rgb(255,255,255) 46%)" blend="multiply" />
			<TopShade opacity={0.85} />
			<Place name="Tokyo" detail="Tanabata" t={t} from={0.3} to={3.8} />
		</AbsoluteFill>
	);
};
