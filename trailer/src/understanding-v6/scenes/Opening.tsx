// Sonder, the black, and the arrival: orbit → Berlin at dusk → the Kiez at dawn.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {C, G, T, at, ease, move, sans, serif, useSeconds, Caption, Person, TopShade, Vignette, Wash, World} from '../lib/core';
import {LightLeak, PodStreak, Smoke, Stars} from '../lib/fx';

// ── Sonder ───────────────────────────────────────────────────────────────────
const typed = (text: string, times: number[], t: number) => {
	let n = 0;
	while (n < times.length && times[n] <= t) n++;
	return {shown: text.slice(0, n), done: n >= text.length, last: n ? times[n - 1] : -1};
};

const Caret: React.FC<{t: number; active: boolean; size: number}> = ({t, active, size}) => (
	<span style={{display: 'inline-block', width: 3, height: size * 0.82, marginLeft: 4, verticalAlign: '-0.08em', background: C.gold,
		opacity: active || Math.floor(t * 2.1) % 2 === 0 ? 0.9 : 0}} />
);

export const Sonder: React.FC = () => {
	const t = useSeconds();
	const s = T.sonder;
	const word = typed(s.word, G.keys.word, t);
	const lines = s.lines.map((line, i) => typed(line, G.keys.lines[i], t));
	const lastLine = lines.reduce((acc, l, i) => (l.shown.length ? i : acc), -1);
	const meta = at(t, [s.word_at + 0.9, s.word_at + 1.6], [0, 1]);
	const rule = at(t, [s.word_at + 1.2, s.word_at + 2.2], [0, 1]);
	const push = at(t, [0, s.shutter], [1, 1.055], ease.inOut);
	const blades = at(t, [s.shutter - 0.1, s.shutter], [0, 1], ease.in);
	return (
		<AbsoluteFill style={{background: 'radial-gradient(ellipse 80% 70% at 42% 45%, #1b1530 0%, #0d0a17 60%, #060509 100%)'}}>
			<AbsoluteFill style={{scale: `${push}`, transformOrigin: '38% 42%'}}>
				<div style={{position: 'absolute', left: 250, top: 250}}>
					<div style={{fontFamily: serif, fontWeight: 600, fontSize: 176, lineHeight: 1, color: C.paper, letterSpacing: '0.01em'}}>
						{word.shown}{lastLine < 0 && <Caret t={t} active={t - word.last < 0.5} size={176} />}
					</div>
					<div style={{marginTop: 22, display: 'flex', gap: 22, alignItems: 'baseline', opacity: meta}}>
						<span style={{fontFamily: sans, fontStyle: 'italic', fontSize: 30, color: C.lavender}}>{s.phonetic}</span>
						<span style={{fontFamily: serif, fontStyle: 'italic', fontSize: 32, color: C.dim}}>{s.kind}</span>
					</div>
					<div style={{marginTop: 30, height: 2, width: 140 * rule, background: `linear-gradient(90deg, ${C.gold}, rgba(232,187,98,0))`}} />
					<div style={{marginTop: 40, fontFamily: serif, fontWeight: 500, fontSize: 54, lineHeight: 1.42, color: 'rgba(243,238,255,0.94)'}}>
						{lines.map((l, i) => (
							<div key={i} style={{minHeight: 77}}>{l.shown}{i === lastLine && <Caret t={t} active={t - l.last < 0.5} size={54} />}</div>
						))}
					</div>
				</div>
			</AbsoluteFill>
			{/* the shutter: two blades close in the last three frames */}
			<div style={{position: 'absolute', left: 0, right: 0, top: 0, height: 540 * blades, background: '#000'}} />
			<div style={{position: 'absolute', left: 0, right: 0, bottom: 0, height: 540 * blades, background: '#000'}} />
			<Vignette strength={0.7} />
		</AbsoluteFill>
	);
};

// ── Arrival ──────────────────────────────────────────────────────────────────
const [ARR] = T.scenes.arrival;
const B1 = 15.21 - ARR;   // rooftops
const B2 = 18.86 - ARR;   // impact, Kiez

export const Arrival: React.FC = () => {
	const t = useSeconds();
	return (
		<AbsoluteFill style={{background: '#000'}}>
			{t < B1 + 0.3 && <Orbit t={t} />}
			{t >= B1 - 0.3 && t < B2 && <Descent t={t - B1} />}
			{t >= B2 && <Crash t={t - B2} />}
			<LightLeak t={t} at={B1} length={0.9} hue={196} />
		</AbsoluteFill>
	);
};

const Orbit: React.FC<{t: number}> = ({t}) => {
	const fade = at(t, [0, 0.9], [0, 1]);
	const out = at(t, [B1 - 0.3, B1 + 0.3], [1, 0]);
	return (
		<AbsoluteFill style={{opacity: fade * out}}>
			<World plate="orbit" cam={move(t, 0, B1 + 0.3, {x: 820, y: 470, z: 1.04}, {x: 900, y: 520, z: 1.16})} grade="brightness(1.02) saturate(1.05)" />
			<Stars t={t} count={60} top={0.45} opacity={0.6} />
			<PodStreak t={t} from={0.9} to={B1} path={[[1700, 120], [1380, 260], [1080, 430], [900, 560]]} size={40} />
			<Vignette strength={0.6} />
		</AbsoluteFill>
	);
};

const Descent: React.FC<{t: number}> = ({t}) => {
	const len = B2 - B1;
	const fade = at(t, [-0.3, 0.3], [0, 1]);
	const shake = at(t, [len - 1.6, len], [0, 7], ease.in);
	return (
		<AbsoluteFill style={{opacity: fade}}>
			<World plate="rooftops" cam={move(t, 0, len, {x: 836, y: 430, z: 1.06}, {x: 940, y: 470, z: 1.2})} shake={shake}
				grade="brightness(0.9) saturate(1.08)" />
			<PodStreak t={t} from={0.2} to={len - 0.05} path={[[-160, 90], [520, 250], [1180, 470], [1560, 690]]} size={150} />
			{/* the pod lights the clouds as it passes */}
			<AbsoluteFill style={{mixBlendMode: 'screen', opacity: at(t, [len - 1.2, len], [0, 0.35], ease.in),
				background: 'radial-gradient(ellipse 50% 40% at 78% 62%, rgba(150,240,255,0.9), rgba(0,0,0,0) 70%)'}} />
			<Vignette strength={0.5} />
		</AbsoluteFill>
	);
};

// Kiez, plate pixels: the pod's crack, where he steps out, where Lukas works.
const POD = {x: 420, y: 560};
const STEP = {x0: 545, y0: 742, x1: 588, y1: 868};
export const LUKAS = {x: 1066, y: 676, counter: 654};

const Crash: React.FC<{t: number}> = ({t}) => {
	const flash = at(t, [0, 0.55], [1, 0], ease.out);
	const shake = at(t, [0, 0.9], [16, 0], ease.out);
	const walk = at(t, [1.25, 3.0], [0, 1], ease.inOut);
	const appear = at(t, [1.1, 1.5], [0, 1]);
	const ax = STEP.x0 + (STEP.x1 - STEP.x0) * walk;
	const ay = STEP.y0 + (STEP.y1 - STEP.y0) * walk;
	const act = t < 1.25 ? 'stand' : t < 3.0 ? 'walk' : t < 4.4 ? 'look' : 'watch';
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 6, {x: 700, y: 560, z: 1.03}, {x: 640, y: 640, z: 1.24})} shake={shake}
				grade="brightness(0.8) contrast(1.06) saturate(0.86) hue-rotate(-8deg)">
				<Smoke t={t} x={POD.x} y={POD.y} count={16} scale={1.4} color="190,190,205" />
				<Smoke t={t + 1.7} x={POD.x + 90} y={POD.y + 30} count={9} scale={0.9} color="170,170,190" />
				<Person who="lukas" act={t < 2 ? 'stand' : 'watch'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={act} x={ax} y={ay} opacity={appear} />
			</World>
			{/* dawn: warm at the top, cool in the shadows */}
			<Wash color="linear-gradient(180deg, rgba(255,160,120,0.55) 0%, rgba(255,205,170,0.25) 35%, rgba(70,60,130,0.35) 100%)" blend="soft-light" />
			<TopShade opacity={0.7} />
			<Caption lines={['You arrive on Earth', 'with nothing but questions.']} t={t} from={1.6} to={5.4} />
			<AbsoluteFill style={{background: '#fff', opacity: flash * 0.95, mixBlendMode: 'screen'}} />
			<Vignette />
		</AbsoluteFill>
	);
};
