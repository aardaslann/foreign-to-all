// Sonder, exactly as revision 5 had it; then a quiet arrival: a small light
// falls past the Earth, over Berlin before dawn, into the Kiez.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {INTRO} from '../../connection-v5/intro';
import {P} from '../../lib/palette';
import {C, T, at, local, move, mono, serif, useSeconds, Black, Person, TopShade, Wash, World} from '../lib/core';
import {FallingLight, Glow, Smoke} from '../lib/fx';

// ── Sonder: revision 5's Dictionary, unchanged ──────────────────────────────
const clamp = (x: number) => Math.max(0, Math.min(1, x));
const smoothstep = (x: number) => {
	x = clamp(x);
	return x * x * (3 - 2 * x);
};

export const Sonder: React.FC = () => {
	const t = useSeconds();
	const n = INTRO.titleKeys.filter((x) => x <= t).length;
	const bodyCount = INTRO.bodyKeys.filter((x) => x <= t).length;
	const settle = smoothstep((t - 0.85) / 0.65);
	const push = 1 + 0.018 * smoothstep((t - 1.5) / 8);
	const bodyCursor = t >= 1.65 && t < 8.45;
	const lines = INTRO.lines;
	const starts = lines.map((_, i) => lines.slice(0, i).reduce((a, line) => a + line.length + 1, 0));
	return (
		<AbsoluteFill style={{background: C.night, color: C.ink}}>
			<AbsoluteFill style={{transform: `scale(${push})`, transformOrigin: '50% 50%'}}>
				<div style={{position: 'absolute', left: 695 + (248 - 695) * settle, top: 318 + (172 - 318) * settle, fontFamily: serif, fontSize: 148,
					letterSpacing: -5, whiteSpace: 'nowrap'}}>
					{'sonder'.slice(0, n)}
					<span style={{display: 'inline-block', width: 3, height: 110, background: C.lavender, marginLeft: 9, opacity: t < 1.15 ? 1 : 0}} />
				</div>
				<div style={{position: 'absolute', left: 254, top: 358, fontFamily: mono, fontSize: 27, color: P.inkMuted, opacity: smoothstep((t - 1.18) / 0.32)}}>
					[sohn-durr] <span style={{marginLeft: 30, fontFamily: serif, fontStyle: 'italic'}}>noun</span>
				</div>
				<div style={{position: 'absolute', left: 254, top: 428, width: 110, height: 3, background: P.amber,
					transform: `scaleX(${smoothstep((t - 1.35) / 0.4)})`, transformOrigin: 'left'}} />
				{lines.map((line, i) => {
					const count = Math.max(0, Math.min(line.length, bodyCount - starts[i]));
					const cursor = bodyCursor && bodyCount >= starts[i] && bodyCount < starts[i] + line.length + (i === lines.length - 1 ? 1 : 0);
					return (
						<div key={i} style={{position: 'absolute', left: 254, top: 490 + i * 94, fontFamily: serif, fontSize: 60, lineHeight: 1.3, whiteSpace: 'pre',
							color: i === 2 ? C.lavender : C.ink}}>
							{line.slice(0, count)}
							<span style={{display: 'inline-block', width: 2, height: 48, background: C.lavender, marginLeft: 4, verticalAlign: '-4px', opacity: cursor ? 1 : 0}} />
						</div>
					);
				})}
			</AbsoluteFill>
		</AbsoluteFill>
	);
};

// ── Arrival ──────────────────────────────────────────────────────────────────
const ROOFTOPS = local('arrival', T.arrival.rooftops);
const KIEZ = local('arrival', T.arrival.kiez);
const LANDING = local('arrival', 17.55);
// Kiez, plate pixels: the pod's crater, where he stands, where Lukas works.
const POD = {x: 420, y: 560};
export const LUKAS = {x: 1066, y: 676, counter: 654};
const STEP = {x0: 548, y0: 744, x1: 600, y1: 850};

export const Arrival: React.FC = () => {
	const t = useSeconds();
	return (
		<AbsoluteFill style={{background: '#000'}}>
			{t < ROOFTOPS + 0.9 && <Orbit t={t} />}
			{t >= ROOFTOPS - 0.1 && t < KIEZ && <Rooftops t={t} />}
			{t >= KIEZ && <Kiez t={t - KIEZ} />}
		</AbsoluteFill>
	);
};

const Orbit: React.FC<{t: number}> = ({t}) => (
	<AbsoluteFill style={{opacity: at(t, [0, 0.9], [0, 1])}}>
		<World plate="orbit" cam={move(t, 0, ROOFTOPS + 0.9, {x: 820, y: 470, z: 1.04}, {x: 880, y: 500, z: 1.1})} grade="brightness(0.95)" />
		<FallingLight t={t} from={0.5} to={ROOFTOPS + 0.6} a={[1520, 170]} b={[1030, 590]} size={0.7} />
	</AbsoluteFill>
);

const Rooftops: React.FC<{t: number}> = ({t}) => {
	const glow = at(t, [LANDING, LANDING + 0.15], [0, 1]);       // the light goes down behind the roofs; the cut follows
	return (
		<AbsoluteFill style={{opacity: at(t, [ROOFTOPS - 0.1, ROOFTOPS + 0.7], [0, 1])}}>
			<World plate="rooftops" cam={move(t, ROOFTOPS, KIEZ, {x: 836, y: 420, z: 1.06}, {x: 900, y: 450, z: 1.13})} grade="brightness(0.92) saturate(1.04)" />
			<FallingLight t={t} from={ROOFTOPS + 0.2} to={LANDING} a={[1330, 160]} b={[1150, 610]} size={1} />
			<AbsoluteFill style={{mixBlendMode: 'screen', opacity: glow * 0.5,
				background: 'radial-gradient(ellipse 22% 18% at 60% 58%, rgba(190,240,255,0.9), rgba(0,0,0,0) 70%)'}} />
		</AbsoluteFill>
	);
};

const Kiez: React.FC<{t: number}> = ({t}) => {
	const walk = at(t, [1.6, 3.3], [0, 1]);
	const ax = STEP.x0 + (STEP.x1 - STEP.x0) * walk;
	const ay = STEP.y0 + (STEP.y1 - STEP.y0) * walk;
	const act = t < 1.6 ? 'look' : t < 3.3 ? 'walk' : t < 4.6 ? 'watch' : 'look';
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 6.25, {x: 690, y: 600, z: 1.1}, {x: 670, y: 625, z: 1.2})} grade="brightness(0.86) contrast(1.04) saturate(0.9)">
				<Smoke t={t + 2} x={POD.x} y={POD.y} count={12} scale={1.2} />
				<Smoke t={t + 4.3} x={POD.x + 90} y={POD.y + 30} count={7} scale={0.8} color="165,168,188" />
				<Glow x={POD.x + 230} y={POD.y + 10} r={70} color="rgba(120,230,255,0.35)" t={t} flicker={0.3} />
				<Person who="lukas" act={t < 2.2 ? 'stand' : 'watch'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={act} x={ax} y={ay} />
			</World>
			{/* dawn: warm at the top, cool in the shadows */}
			<Wash color="linear-gradient(180deg, rgba(255,170,130,0.5) 0%, rgba(255,205,170,0.2) 38%, rgba(80,70,140,0.32) 100%)" blend="soft-light" />
			<TopShade />
			<Black opacity={at(t, [0, 0.35], [0.6, 0])} />
		</AbsoluteFill>
	);
};
