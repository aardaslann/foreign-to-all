// The turn: a label on a person, struck out and let go; then eight people.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {P} from '../../lib/palette';
import {C, at, local, mono, sans, serif, useSeconds, Person, Window} from '../lib/core';

const rand = (i: number) => {
	const x = Math.sin(i * 91.7 + 17.3) * 43758.5453;
	return x - Math.floor(x);
};

// ── A stereotype reduces a person to a label ────────────────────────────────
const FIG = {x: 700, y: 952, u: 20};
const TAG = {x: 885, y: 805};
const HANG = local('stereotype', 81.0);
const STRIKE = local('stereotype', 86.0);
const DROP = STRIKE + 0.35;
const NAME = local('stereotype', 86.6);
const DETAILS = [
	{title: 'Her work', text: 'A shop on Kappabashi-dori.', colour: C.gold},
	{title: 'Her traditions', text: 'A wish written for Tanabata.', colour: C.lavender},
	{title: 'Her kindness', text: 'A story shared with a stranger.', colour: C.teal},
];

export const Stereotype: React.FC = () => {
	const t = useSeconds();
	const grey = at(t, [DROP, DROP + 0.8], [1, 0]);
	const warm = at(t, [DROP, DROP + 1.4], [0, 1]);
	const light = at(t, [0, 0.8], [0, 1]);
	return (
		<AbsoluteFill style={{background: C.night}}>
			{/* the light she stands in: cold, until she is a person again */}
			<AbsoluteFill style={{opacity: light, filter: 'blur(28px)', mixBlendMode: 'screen', clipPath: 'polygon(31% 0, 42% 0, 58% 100%, 15% 100%)',
				background: `linear-gradient(180deg, rgba(${190 + 60 * warm},${200 + 10 * warm},${255 - 80 * warm},0.22), rgba(${190 + 60 * warm},200,${240 - 100 * warm},0.05))`}} />
			<div style={{position: 'absolute', left: FIG.x - 330, top: FIG.y - 60, width: 660, height: 110, borderRadius: '50%', opacity: 0.6 * light,
				background: `radial-gradient(closest-side, rgba(${215 + 40 * warm},205,${250 - 90 * warm},0.28), rgba(0,0,0,0))`}} />
			{Array.from({length: 22}, (_, i) => {
				const y = 120 + ((rand(i) * 900 - t * (12 + rand(i + 9) * 16)) % 900 + 900) % 900;
				const x = FIG.x + (rand(i + 3) - 0.5) * (200 + (y - 100) * 0.42);
				return <div key={i} style={{position: 'absolute', left: Math.round(x / 3) * 3, top: Math.round(y / 3) * 3, width: 3, height: 3, background: '#fff',
					opacity: light * (0.1 + 0.25 * rand(i + 5))}} />;
			})}
			<Person who="setsuko" act={t < DROP + 0.6 ? 'stand' : t < NAME + 2.2 ? 'nod' : 'bow'} x={FIG.x} y={FIG.y} u={FIG.u}
				filter={`grayscale(${grey}) brightness(${0.7 + 0.3 * (1 - grey)})`} />
			<Tag t={t} />
			<div style={{position: 'absolute', left: FIG.x - 300, width: 600, top: 438, textAlign: 'center', fontFamily: serif, fontSize: 56, color: C.ink,
				opacity: at(t, [NAME, NAME + 0.8], [0, 1]), transform: `translateY(${(1 - at(t, [NAME, NAME + 0.8], [0, 1])) * 10}px)`}}>Setsuko</div>
			<svg width={1920} height={1080} style={{position: 'absolute', left: 0, top: 0}} shapeRendering="crispEdges">
				{DETAILS.map((_, i) => {
					const o = at(t, [NAME + 0.6 + i * 0.7, NAME + 1.25 + i * 0.7], [0, 1]);
					return <path key={i} d={`M ${FIG.x + 150} ${700 + i * 34} H ${965 + i * 23} V ${465 + i * 164} H 1065`} fill="none" stroke={P.border} strokeWidth={3} opacity={o * 0.7} />;
				})}
			</svg>
			{DETAILS.map((d, i) => {
				const o = at(t, [NAME + 0.6 + i * 0.7, NAME + 1.25 + i * 0.7], [0, 1]);
				return (
					<div key={d.title} style={{position: 'absolute', left: 1065, top: 425 + i * 164, width: 655, padding: '22px 30px', borderLeft: `4px solid ${d.colour}`,
						background: P.panel, opacity: o, transform: `translateX(${(1 - o) * 20}px)`}}>
						<div style={{fontFamily: serif, fontSize: 39, color: d.colour}}>{d.title}</div>
						<div style={{fontFamily: sans, fontSize: 29, color: C.ink, marginTop: 10}}>{d.text}</div>
					</div>
				);
			})}
		</AbsoluteFill>
	);
};

/** A luggage tag reading STRANGER, hung on her; the word is struck out and the tag lets go. */
const Tag: React.FC<{t: number}> = ({t}) => {
	const hang = at(t, [HANG, HANG + 0.7], [0, 1]);
	if (hang <= 0) return null;
	const strike = at(t, [STRIKE, STRIKE + 0.35], [0, 1]);
	const fall = at(t, [DROP, DROP + 1.0], [0, 1], (x) => x * x);
	const sway = Math.sin(t * 1.8) * 2 * (1 - fall) + (1 - hang) * -8;
	const opacity = hang * (1 - fall);
	return (
		<>
			{fall === 0 && (
				<svg width={1920} height={1080} style={{position: 'absolute', left: 0, top: 0, opacity: hang}}>
					<path d={`M ${TAG.x - 130} ${TAG.y - 2} Q ${TAG.x - 165} ${TAG.y - 70} ${TAG.x - 140} ${TAG.y - 140}`} stroke="#c9b89a" strokeWidth={3} fill="none" />
				</svg>
			)}
			<div style={{position: 'absolute', left: TAG.x - 150, top: TAG.y - 52, width: 300, height: 104, opacity, transformOrigin: '6% 50%',
				transform: `translate(${fall * 40}px, ${fall * 300 - (1 - hang) * 12}px) rotate(${-6 + sway + fall * 34}deg)`}}>
				<div style={{position: 'absolute', inset: 0, background: 'linear-gradient(170deg, #f1e8d4, #ddd0b4)',
					clipPath: 'polygon(13% 0, 100% 0, 100% 100%, 13% 100%, 0 74%, 0 26%)'}} />
				<div style={{position: 'absolute', left: 16, top: 43, width: 18, height: 18, borderRadius: '50%', background: C.night, boxShadow: 'inset 0 0 0 4px #c9b89a'}} />
				<div style={{position: 'absolute', left: 58, top: 12, fontFamily: mono, fontSize: 13, letterSpacing: 4, color: '#80766a'}}>NAME</div>
				<div style={{position: 'absolute', left: 56, top: 34, fontFamily: mono, fontSize: 38, letterSpacing: 6, color: '#5a5048'}}>STRANGER</div>
				<div style={{position: 'absolute', left: 52, top: 56, height: 4, width: 228 * strike, background: C.gold}} />
			</div>
		</>
	);
};

// ── Across cities, across cultures ───────────────────────────────────────────
const PEOPLE = [
	{who: 'kerstin', name: 'Kerstin', city: 'Berlin', plate: 'berlin', x: 760, y: 706, act: 'wave'},
	{who: 'nadia', name: 'Nadia', city: 'London', plate: 'brixton', x: 862, y: 792, act: 'talk'},
	{who: 'odile', name: 'Odile', city: 'Paris', plate: 'paris', x: 420, y: 748, act: 'nod'},
	{who: 'viktor', name: 'Viktor', city: 'Moscow', plate: 'moscow', x: 900, y: 726, act: 'look'},
	{who: 'arda', name: 'Arda', city: 'Istanbul', plate: 'istanbul', x: 760, y: 772, act: 'offer'},
	{who: 'omkar', name: 'Omkar', city: 'Mumbai', plate: 'mumbai', x: 700, y: 696, act: 'talk'},
	{who: 'setsuko', name: 'Setsuko', city: 'Tokyo', plate: 'tokyo', x: 740, y: 742, act: 'bow'},
	{who: 'rocio', name: 'Rocío', city: 'Mexico City', plate: 'mexico', x: 840, y: 740, act: 'wave'},
];
const CARD = {w: 380, h: 214, gap: 30, left: 155, rows: [372, 676], zoom: 1.25};

export const People: React.FC = () => {
	const t = useSeconds();
	return (
		<AbsoluteFill style={{background: C.night}}>
			<div style={{position: 'absolute', top: 124, width: '100%', textAlign: 'center', fontFamily: serif, fontSize: 70, color: C.ink,
				opacity: at(t, [0.3, 0.9], [0, 1])}}>Across cities. Across cultures.</div>
			<div style={{position: 'absolute', top: 226, width: '100%', textAlign: 'center', fontFamily: serif, fontSize: 50, color: C.lavender,
				opacity: at(t, [2.9, 3.6], [0, 1])}}>Let the people change your assumptions.</div>
			{PEOPLE.map((p, i) => {
				const col = i % 4;
				const row = Math.floor(i / 4);
				const a = at(t, [0.4 + i * 0.3, 1.1 + i * 0.3], [0, 1]);
				const drift = (t - 4.5) * (i % 2 ? -3 : 3);
				return (
					<div key={p.who} style={{position: 'absolute', left: CARD.left + col * (CARD.w + CARD.gap), top: CARD.rows[row], opacity: a,
						transform: `translateY(${(1 - a) * 22}px)`}}>
						<div style={{border: `3px solid ${P.border}`, boxShadow: '0 14px 30px rgba(0,0,0,0.45)'}}>
							<Window plate={p.plate} x={p.x + drift} y={p.y - 70} zoom={CARD.zoom} w={CARD.w} h={CARD.h} grade="brightness(0.95) saturate(1.02)">
								<Person who={p.who} act={p.act} x={p.x} y={p.y} phase={i * 5} />
							</Window>
						</div>
						<div style={{marginTop: 12, textAlign: 'center', fontFamily: sans, fontWeight: 600, fontSize: 27, color: C.ink}}>{p.name}</div>
						<div style={{marginTop: 2, textAlign: 'center', fontFamily: mono, fontSize: 19, color: C.gold}}>{p.city}</div>
					</div>
				);
			})}
		</AbsoluteFill>
	);
};
