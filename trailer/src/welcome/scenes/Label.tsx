// The turn of the chorus: a label gives you one word — the pen takes it away,
// and the person behind it lights up with a whole life. Then everyone does.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at, BEAT, C, copy, cue, ease, pixel, sans, useFilm, useFrame} from '../lib/core';
import {Flash, Night, Paper} from '../lib/surface';
import {marks, Mark, partial, type Pt, smoothPath, Splat} from '../lib/ink';
import {Typed} from '../lib/type';
import {type Heat, Item, type ItemId, Sprite, Warm} from '../lib/pixel';

/** The luggage tag from revision 7, reading STRANGER. */
const Tag: React.FC<{w: number; scribble: number}> = ({w, scribble}) => {
	const h = w * 0.36;
	return (
		<Mark pts={marks.scribble(17, 8)} p={scribble} color={C.red} width={w / 34} padX={2} padY={6}>
			<div style={{position: 'relative', width: w, height: h}}>
				<div style={{position: 'absolute', inset: 0, background: 'linear-gradient(170deg, #f1e8d4, #d8c9aa)', clipPath: 'polygon(13% 0, 100% 0, 100% 100%, 13% 100%, 0 74%, 0 26%)'}} />
				<div style={{position: 'absolute', left: w * 0.055, top: h * 0.41, width: h * 0.18, height: h * 0.18, borderRadius: '50%', background: C.night, boxShadow: `inset 0 0 0 ${h * 0.04}px #c9b89a`}} />
				<div style={{position: 'absolute', left: w * 0.19, top: h * 0.12, fontFamily: pixel, fontSize: h * 0.13, letterSpacing: '0.2em', color: '#80766a'}}>NAME</div>
				<div style={{position: 'absolute', left: w * 0.19, top: h * 0.4, fontFamily: pixel, fontWeight: 700, fontSize: h * 0.27, letterSpacing: '0.04em', color: '#4f463e'}}>STRANGER</div>
			</div>
		</Mark>
	);
};

const LIFE: ItemId[] = ['old_book', 'kermel_flowers', 'cay', 'apple', 'money', 'bread', 'water'];

export const Label: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const [label, scribble, life, strobe] = [cue('label'), cue('scribble'), cue('life'), cue('strobe')];
	const u = tall ? 25 : 20;
	const x = tall ? W / 2 : W * 0.64;
	const feet = tall ? H * 0.86 : H * 0.96;
	const chest = {x, y: feet - 16 * u};
	const lit = at(t, [life, life + 0.28], [0, 1], ease.out);
	const bloom = at(t, [life, life + 0.12, life + 0.9], [0, 1.6, 1]);
	// the tag: swings in on its string, gets scribbled out, then lets go
	const hang = at(t, [label + 0.1, label + 0.55], [0, 1], ease.out);
	const swing = Math.exp(-(t - label - 0.3) * 3) * Math.sin((t - label) * 9) * 14 * (t > label ? 1 : 0);
	const fall = at(t, [life + 0.05, life + 0.9], [0, 1], ease.in);
	const tagW = tall ? 400 : 330;
	const tag = {x: x - tagW * 0.5, y: feet - 9 * u};
	const scrib = at(t, [scribble, life], [0, 1], ease.inOut);
	// her life, orbiting her
	const orbitIn = at(t, [life + 0.35, life + 1.1], [0, 1], ease.inOut);
	const rx = 15 * u, ry = 3.4 * u, tilt = -0.16;
	const orbitAt = (a: number) => {
		const ox = Math.cos(a) * rx, oy = Math.sin(a) * ry;
		return {x: chest.x + ox * Math.cos(tilt) - oy * Math.sin(tilt), y: chest.y + ox * Math.sin(tilt) + oy * Math.cos(tilt), z: Math.sin(a)};
	};
	const line = (from: number, to: number): Pt[] => Array.from({length: 40}, (_, i) => {
		const o = orbitAt(from + ((to - from) * i) / 39);
		return [o.x, o.y];
	});
	const things = LIFE.map((id, i) => {
		const a = (i / LIFE.length) * Math.PI * 2 + (t - life) * 0.9;
		const o = orbitAt(a);
		const pop = at(t, [life + 0.5 + i * 0.06, life + 0.8 + i * 0.06], [0, 1], ease.back);
		return {id, ...o, pop};
	});
	const thing = (o: (typeof things)[number]) => (
		<Item key={o.id} id={o.id} x={o.x} y={o.y} size={u * 6.2 * (0.82 + 0.18 * o.z)} scale={o.pop} opacity={0.65 + 0.35 * o.z} />
	);
	const fs = tall ? 90 : 84;
	const textBox: React.CSSProperties = tall
		? {position: 'absolute', left: 60, right: 60, top: H * 0.1, textAlign: 'center'}
		: {position: 'absolute', left: W * 0.07, top: H * 0.34, width: W * 0.42};
	const [l1, l2] = copy.label;
	const [m1, m2] = copy.life;
	return (
		<Night>
			{/* the spotlight */}
			<AbsoluteFill style={{background: `radial-gradient(ellipse ${tall ? '60% 40%' : '30% 70%'} at ${(x / W) * 100}% ${tall ? 62 : 55}%, rgba(255,255,255,${0.09 * (1 - lit)}), rgba(255,255,255,0) 70%)`}} />
			<AbsoluteFill style={{background: `radial-gradient(ellipse ${tall ? '70% 45%' : '35% 75%'} at ${(x / W) * 100}% ${tall ? 64 : 58}%, rgba(255,138,30,${0.28 * lit}), rgba(226,54,28,${0.08 * lit}) 45%, rgba(0,0,0,0) 72%)`}} />
			<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0}}>
				<path d={smoothPath(partial(line(Math.PI, Math.PI * 2), orbitIn))} fill="none" stroke={C.white} strokeWidth={3} opacity={0.6} />
			</svg>
			{things.filter((o) => o.z < 0).map(thing)}
			<Sprite who="setsuko" x={x} y={feet} u={u} filter="url(#heat-grey) brightness(0.85)" opacity={1 - lit} />
			<Warm who="setsuko" x={x} y={feet} u={u} heat="warm" glow={bloom} opacity={lit} />
			<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0}}>
				<path d={smoothPath(partial(line(0, Math.PI), orbitIn))} fill="none" stroke={C.white} strokeWidth={3} />
			</svg>
			{things.filter((o) => o.z >= 0).map(thing)}
			{hang > 0 && fall < 1 && (
				<>
					<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0, opacity: hang * (1 - fall)}}>
						<path d={`M ${tag.x + tagW * 0.08} ${tag.y} Q ${tag.x + tagW * 0.1} ${feet - 15 * u} ${x} ${feet - 15.5 * u}`} stroke="#c9b89a" strokeWidth={4} fill="none" />
					</svg>
					<div style={{position: 'absolute', left: tag.x, top: tag.y - tagW * 0.18, transformOrigin: '6% 50%', opacity: 1 - fall,
						translate: `${fall * 60}px ${fall * H * 0.4 - (1 - hang) * H * 0.4}px`, rotate: `${-8 + swing + fall * 40}deg`}}>
						<Tag w={tagW} scribble={scrib} />
					</div>
				</>
			)}
			<Splat x={tag.x + tagW * 0.5} y={tag.y} size={tagW * 0.5} p={(t - life) / 0.5} color={C.red} seed={9} count={22} />
			<div style={{...textBox, fontFamily: sans, fontWeight: 800, fontSize: fs, lineHeight: 1.1, letterSpacing: '-0.02em', color: C.white}}>
				{t < life ? (
					<>
						<Typed text={l1} t={t} from={label + 0.4} cps={26} />
						<br />
						<span style={{color: C.red}}><Typed text={l2} t={t} from={label + 2 * BEAT} cps={20} cursor="block" cursorColor={C.red} cursorUntil={life} /></span>
					</>
				) : (
					<>
						<Typed text={m1} t={t} from={life + 0.5 * BEAT} cps={28} />
						<br />
						<span style={{color: '#ffd25a'}}><Typed text={m2} t={t} from={life + 1.6 * BEAT} cps={22} cursor="block" cursorColor="#ffd25a" cursorUntil={strobe} /></span>
					</>
				)}
			</div>
			<Flash from={life} frames={2} color={C.white} />
		</Night>
	);
};

// ── Everyone ─────────────────────────────────────────────────────────────────
type Person = {who: string; act: string; heat?: Heat; frame: number; name: string};
const EVERYONE: Person[] = [
	{who: 'kerstin', act: 'wave', heat: 'warm', frame: 6, name: 'Kerstin · Berlin'}, {who: 'nadia', act: 'talk', heat: 'rose', frame: 4, name: 'Nadia · London'},
	{who: 'viktor', act: 'offer', heat: 'gold', frame: 8, name: 'Viktor · Moscow'}, {who: 'omkar', act: 'wave', heat: 'mint', frame: 5, name: 'Omkar · Mumbai'},
	{who: 'rocio', act: 'offer', heat: 'violet', frame: 9, name: 'Rocío · Mexico City'}, {who: 'odile', act: 'bow', heat: 'rose', frame: 10, name: 'Odile · Paris'},
	{who: 'arda', act: 'pour', heat: 'gold', frame: 7, name: 'Arda · Istanbul'}, {who: 'alien', act: 'wave', frame: 6, name: 'You · far from home'},
];
const HALO: Record<Heat, string> = {warm: '255,138,30', rose: '255,122,168', gold: '242,181,48', mint: '70,232,192', violet: '169,149,240', grey: '180,180,190'};

/** Eight people, half a beat each — the last is the alien in his own colours, on paper. */
export const Everyone: React.FC = () => {
	const t = useFilm();
	const {W, H, tall} = useFrame();
	const strobe = cue('strobe');
	const k = Math.min(EVERYONE.length - 1, Math.max(0, Math.floor((t - strobe) / (BEAT / 2))));
	const p = EVERYONE[k];
	const local = t - strobe - k * (BEAT / 2);
	const u = tall ? 26 : 20;
	const x = W / 2, feet = tall ? H * 0.78 : H * 0.88;
	const zoom = at(local, [0, BEAT / 2], [1.06, 1], ease.out);
	const last = !p.heat;
	const fs = tall ? 92 : 78;
	const content = (
		<>
			<AbsoluteFill style={{scale: `${zoom}`, transformOrigin: `${x}px ${feet}px`}}>
				{p.heat ? <Warm who={p.who} act={p.act} frame={p.frame} x={x} y={feet} u={u} heat={p.heat} />
					: <Sprite who={p.who} act={p.act} frame={p.frame + Math.floor(local * 12)} x={x} y={feet} u={u} />}
			</AbsoluteFill>
			<div style={{position: 'absolute', left: 0, right: 0, top: feet + u * 1.6, textAlign: 'center', fontFamily: pixel, fontSize: tall ? 34 : 30,
				letterSpacing: '0.12em', textTransform: 'uppercase', color: last ? C.inkSoft : 'rgba(251,250,246,0.82)'}}>{p.name}</div>
			<div style={{position: 'absolute', left: 0, right: 0, top: tall ? H * 0.12 : H * 0.08, textAlign: 'center', fontFamily: sans, fontWeight: 800,
				fontSize: fs, letterSpacing: '-0.02em', color: last ? C.ink : C.white}}>
				<Typed text={copy.vivid} t={t} from={strobe + 0.04} cps={34} />
			</div>
		</>
	);
	return last ? <Paper>{content}</Paper> : (
		<Night>
			<AbsoluteFill style={{background: `radial-gradient(ellipse ${tall ? '75% 45%' : '40% 80%'} at 50% 62%, rgba(${HALO[p.heat!]},0.34), rgba(0,0,0,0) 70%)`}} />
			{content}
		</Night>
	);
};
