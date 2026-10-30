// The turn: a label stamped on a person and torn off, then eight cities.
import React from 'react';
import {AbsoluteFill, useCurrentFrame} from 'remotion';
import {C, T, at, ease, move, sans, serif, useSeconds, Caption, Person, TopShade, Vignette, Wash, World} from '../lib/core';

// ── A stereotype reduces a person to a label ────────────────────────────────
const [ST] = T.scenes.stereotype;
const STAMP = 75.9 - ST;
const RIP = 80.2 - ST;
const FIGURE = {x: 960, y: 1012, u: 24};
const TAG = {x: 1104, y: 924};

const CARDS = [
	{at: 80.6 - ST, label: 'HER WORK', text: 'A shop on Kappabashi-dori.', left: 150, top: 420, from: [670, 462], to: [820, 600]},
	{at: 81.2 - ST, label: 'HER TRADITIONS', text: 'A wish written for Tanabata.', left: 1250, top: 540, from: [1250, 582], to: [1110, 700]},
	{at: 81.8 - ST, label: 'HER KINDNESS', text: 'A story shared with a stranger.', left: 180, top: 690, from: [722, 732], to: [850, 820]},
] as const;

const rand = (i: number) => {
	const x = Math.sin(i * 91.7 + 17.3) * 43758.5453;
	return x - Math.floor(x);
};

export const Stereotype: React.FC = () => {
	const t = useSeconds();
	const grey = at(t, [RIP, RIP + 0.75], [1, 0], ease.inOut);
	const slam = at(t, [STAMP, STAMP + 0.12], [1.55, 1], ease.in);
	const kick = t > STAMP && t < STAMP + 0.3 ? (1 - (t - STAMP) / 0.3) * 10 : 0;
	const shake = {x: Math.sin(t * 90) * kick, y: Math.cos(t * 77) * kick * 0.6};
	const rip = at(t, [RIP, RIP + 0.7], [0, 1], ease.in);
	const warm = at(t, [RIP, RIP + 1.2], [0, 1]);
	const light = at(t, [0, 0.5], [0, 1]);
	return (
		<AbsoluteFill style={{background: 'radial-gradient(ellipse 70% 80% at 50% 55%, #1a1528 0%, #0b0912 55%, #040306 100%)'}}>
			<AbsoluteFill style={{translate: `${shake.x}px ${shake.y}px`}}>
				{/* the spotlight, cold until she is a person again */}
				<AbsoluteFill style={{opacity: light, filter: 'blur(26px)', mixBlendMode: 'screen',
					clipPath: 'polygon(41% 0, 59% 0, 78% 100%, 22% 100%)',
					background: `linear-gradient(180deg, rgba(${200 + 55 * warm},${215 + 5 * warm},${255 - 85 * warm},0.32) 0%, rgba(${200 + 55 * warm},${200},${240 - 100 * warm},0.08) 100%)`}} />
				<div style={{position: 'absolute', left: 960 - 420, top: 860, width: 840, height: 150, borderRadius: '50%', opacity: 0.5 * light,
					background: `radial-gradient(closest-side, rgba(${220 + 35 * warm},${210},${255 - 90 * warm},0.35), rgba(0,0,0,0))`}} />
				{Array.from({length: 26}, (_, i) => {
					const y = (rand(i) * 1100 - t * (14 + rand(i + 9) * 20)) % 1100;
					const x = 960 + (rand(i + 3) - 0.5) * (260 + (1080 - (y < 0 ? y + 1100 : y)) * 0.35);
					return <div key={i} style={{position: 'absolute', left: x, top: y < 0 ? y + 1100 : y, width: 3, height: 3, borderRadius: 2,
						background: '#fff', opacity: light * (0.15 + 0.35 * rand(i + 5))}} />;
				})}
				<AbsoluteFill style={{opacity: warm * 0.55, mixBlendMode: 'screen',
					background: 'radial-gradient(ellipse 30% 42% at 50% 62%, rgba(255,190,120,0.55), rgba(0,0,0,0) 70%)'}} />
				<Person who="setsuko" act={t < RIP ? 'stand' : 'nod'} x={FIGURE.x} y={FIGURE.y} u={FIGURE.u}
					filter={`grayscale(${grey}) brightness(${0.72 + 0.28 * (1 - grey)}) contrast(${1.08 - 0.08 * (1 - grey)})`} />
				{t >= STAMP && rip < 1 && <Tag t={t} slam={slam} rip={rip} />}
				{CARDS.map((c, i) => <Card key={i} t={t} {...c} />)}
			</AbsoluteFill>
			<Caption lines={['A stereotype reduces', 'a person to a label.']} t={t} from={0.75} to={4.45} />
			<Caption lines={['Get to know', 'what it leaves out.']} t={t} from={5.85} to={9.0} />
			<Vignette strength={0.75} />
		</AbsoluteFill>
	);
};

/** A luggage tag with STRANGER stamped on it: stamped, then torn away. */
const Tag: React.FC<{t: number; slam: number; rip: number}> = ({t, slam, rip}) => {
	const sway = Math.sin(t * 2.2) * 1.5 * (1 - rip);
	return (
		<>
			{rip === 0 && (
				<svg width="1920" height="1080" style={{position: 'absolute', left: 0, top: 0}}>
					<path d={`M ${TAG.x - 128} ${TAG.y - 4} Q ${TAG.x - 150} ${TAG.y - 60} ${TAG.x - 120} ${TAG.y - 96}`} stroke="#c9b89a" strokeWidth={3} fill="none" />
				</svg>
			)}
			<div style={{position: 'absolute', left: TAG.x - 150, top: TAG.y - 52, width: 300, height: 104,
				transformOrigin: '10% 50%', opacity: 1 - rip,
				transform: `translate(${rip * 460}px, ${-rip * 420}px) rotate(${-7 + sway + rip * 48}deg) scale(${slam})`}}>
				<div style={{position: 'absolute', inset: 0, background: 'linear-gradient(170deg, #f4ecd8, #e3d6ba)',
					clipPath: 'polygon(14% 0, 100% 0, 100% 100%, 14% 100%, 0 76%, 0 24%)', boxShadow: '0 10px 30px rgba(0,0,0,0.5)'}} />
				<div style={{position: 'absolute', left: 18, top: 43, width: 18, height: 18, borderRadius: '50%', background: '#0b0912',
					boxShadow: 'inset 0 0 0 4px #c9b89a'}} />
				<div style={{position: 'absolute', left: 60, top: 14, fontFamily: sans, fontWeight: 600, fontSize: 13, letterSpacing: '0.3em', color: '#7d7262'}}>NAME</div>
				<div style={{position: 'absolute', left: 48, top: 32, padding: '3px 12px', border: '4px solid rgba(179,38,46,0.88)', borderRadius: 4,
					rotate: '-4deg', fontFamily: sans, fontWeight: 700, fontSize: 31, letterSpacing: '0.14em', color: 'rgba(179,38,46,0.92)',
					mixBlendMode: 'multiply'}}>STRANGER</div>
			</div>
			{/* scraps where it tore */}
			{rip > 0 && Array.from({length: 7}, (_, i) => (
				<div key={i} style={{position: 'absolute', left: TAG.x - 150 + rand(i) * 30 + rip * (120 + rand(i + 4) * 260),
					top: TAG.y - 10 + rand(i + 2) * 40 - rip * (80 + rand(i + 8) * 200) + rip * rip * 260,
					width: 8 + rand(i + 1) * 8, height: 6 + rand(i + 6) * 6, background: '#efe5cf', rotate: `${rip * 400 * (rand(i) - 0.5)}deg`,
					opacity: 1 - rip}} />
			))}
		</>
	);
};

const Card: React.FC<{t: number; at: number; label: string; text: string; left: number; top: number;
	from: readonly number[]; to: readonly number[]}> = ({t, at: when, label, text, left, top, from, to}) => {
	const o = at(t, [when, when + 0.55], [0, 1]);
	if (o <= 0) return null;
	const side = left < 960 ? -1 : 1;
	const reach = at(t, [when + 0.2, when + 0.75], [0, 1], ease.inOut);
	const x2 = from[0] + (to[0] - from[0]) * reach;
	const y2 = from[1] + (to[1] - from[1]) * reach;
	return (
		<>
			<svg width="1920" height="1080" style={{position: 'absolute', left: 0, top: 0, opacity: o}}>
				<line x1={from[0]} y1={from[1]} x2={x2} y2={y2} stroke="rgba(232,187,98,0.55)" strokeWidth={2} />
				{reach >= 1 && <circle cx={to[0]} cy={to[1]} r={5} fill={C.gold} />}
			</svg>
			<div style={{position: 'absolute', left, top, width: 520, opacity: o, translate: `${side * (1 - o) * 30}px 0`, filter: `blur(${(1 - o) * 6}px)`,
				background: C.panel, borderLeft: `3px solid ${C.gold}`, borderRadius: 10, padding: '18px 26px 20px',
				boxShadow: '0 20px 44px rgba(0,0,0,0.55)'}}>
				<div style={{fontFamily: sans, fontWeight: 600, fontSize: 17, letterSpacing: '0.34em', color: C.gold}}>{label}</div>
				<div style={{marginTop: 8, fontFamily: serif, fontStyle: 'italic', fontWeight: 500, fontSize: 38, lineHeight: 1.15, color: C.paper}}>{text}</div>
			</div>
		</>
	);
};

// ── Across cities, across cultures ───────────────────────────────────────────
const SHOT = 0.9143;
const SHOTS = [
	{who: 'kerstin', name: 'KERSTIN', city: 'Berlin', plate: 'berlin', x: 760, y: 706, act: 'wave'},
	{who: 'nadia', name: 'NADIA', city: 'London', plate: 'brixton', x: 862, y: 792, act: 'talk'},
	{who: 'odile', name: 'ODILE', city: 'Paris', plate: 'paris', x: 420, y: 748, act: 'nod'},
	{who: 'viktor', name: 'VIKTOR', city: 'Moscow', plate: 'moscow', x: 900, y: 726, act: 'look'},
	{who: 'arda', name: 'ARDA', city: 'Istanbul', plate: 'istanbul', x: 760, y: 772, act: 'offer'},
	{who: 'omkar', name: 'OMKAR', city: 'Mumbai', plate: 'mumbai', x: 700, y: 696, act: 'talk'},
	{who: 'setsuko', name: 'SETSUKO', city: 'Tokyo', plate: 'tokyo', x: 740, y: 742, act: 'bow'},
	{who: 'rocio', name: 'ROCÍO', city: 'Mexico City', plate: 'mexico', x: 840, y: 740, act: 'wave'},
];

export const Cities: React.FC = () => {
	const t = useSeconds();
	const i = Math.min(SHOTS.length - 1, Math.floor(t / SHOT));
	return (
		<AbsoluteFill style={{background: C.night}}>
			<Shot index={i} t={t - i * SHOT} />
			<TopShade opacity={0.85} />
			<Caption lines={['Across cities. Across cultures.']} t={t} from={0.2} to={3.5} />
			<Caption lines={['Let the people', 'change your assumptions.']} t={t} from={3.7} to={7.2} />
			<Vignette />
		</AbsoluteFill>
	);
};

const Shot: React.FC<{index: number; t: number}> = ({index, t}) => {
	const frame = useCurrentFrame();
	const s = SHOTS[index];
	const dir = index % 2 ? -1 : 1;
	const whip = at(t, [0, 0.16], [1, 0], ease.out);
	const cam = move(t, 0, SHOT, {x: s.x + dir * 46, y: s.y - 150, z: 1.74}, {x: s.x - dir * 30, y: s.y - 146, z: 1.84});
	const card = at(t, [0.04, 0.3], [0, 1]);
	return (
		<AbsoluteFill>
			<svg width="0" height="0" style={{position: 'absolute'}}>
				<filter id={`whip${frame}`}><feGaussianBlur stdDeviation={`${whip * 26} 0`} /></filter>
			</svg>
			<AbsoluteFill style={{translate: `${dir * whip * 160}px 0`, filter: whip > 0.02 ? `url(#whip${frame})` : undefined}}>
				<World plate={s.plate} cam={cam} grade="brightness(0.94) saturate(1.04) contrast(1.04)">
					<Person who={s.who} act={s.act} x={s.x} y={s.y} phase={index * 5} />
				</World>
				<Wash color="linear-gradient(180deg, rgba(255,190,140,0.32), rgba(80,70,150,0.28))" blend="soft-light" />
			</AbsoluteFill>
			<div style={{position: 'absolute', left: 92, bottom: 96, opacity: card, translate: `${(1 - card) * -18}px 0`}}>
				<div style={{fontFamily: sans, fontWeight: 600, fontSize: 24, letterSpacing: '0.42em', color: C.gold, textShadow: '0 2px 14px rgba(0,0,0,0.6)'}}>{s.name}</div>
				<div style={{height: 2, width: 200 * card, background: `linear-gradient(90deg, ${C.gold}, rgba(232,187,98,0))`, margin: '10px 0 8px'}} />
				<div style={{fontFamily: serif, fontStyle: 'italic', fontSize: 34, color: C.paper, textShadow: '0 2px 14px rgba(0,0,0,0.7)'}}>{s.city}</div>
			</div>
		</AbsoluteFill>
	);
};
