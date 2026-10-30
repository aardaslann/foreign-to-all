// Set pieces: fireworks, smoke, stars, the pod's streak, Tanabata, the
// notebook card, the reputation card and a light leak.
import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import {C, at, ease, sans, serif, window, Item, Person} from './core';

const rand = (i: number) => {
	const x = Math.sin(i * 127.1 + 311.7) * 43758.5453;
	return x - Math.floor(x);
};

// ── Fireworks ────────────────────────────────────────────────────────────────
export type Burst = {t: number; big: boolean; x: number; y: number; r: number; hue: number; n: number};
const LIFE = (b: Burst) => (b.big ? 2.6 : 1.7);
const RISE = 0.72;

/** How brightly the sky is lit right now, 0..1, and in what hue. */
export const skyLight = (t: number, bursts: Burst[]) => {
	let light = 0;
	let hue = 40;
	for (const b of bursts) {
		const dt = t - b.t;
		if (dt < 0 || dt > 1.4) continue;
		const k = Math.exp(-dt * 4.5) * (b.big ? 1 : 0.45);
		if (k > light) hue = b.hue;
		light += k;
	}
	return {light: Math.min(1, light), hue};
};

const Particles: React.FC<{t: number; bursts: Burst[]; glow?: boolean}> = ({t, bursts, glow}) => (
	<>
		{bursts.map((b, i) => {
			const dt = t - b.t;
			if (dt < -RISE || dt > LIFE(b)) return null;
			const cx = b.x * 1920;
			const cy = b.y * 1080;
			if (dt < 0) {
				const k = at(dt, [-RISE, 0], [0, 1], ease.out);
				const y = 1120 + (cy - 1120) * k;
				return (
					<g key={i}>
						<line x1={cx} y1={y + 70} x2={cx} y2={y} stroke={`hsla(${b.hue},90%,80%,0.55)`} strokeWidth={glow ? 8 : 3} strokeLinecap="round" />
						<rect x={cx - 3} y={y - 3} width={6} height={6} fill="#fff8e8" />
					</g>
				);
			}
			const life = LIFE(b);
			const fade = Math.pow(Math.max(0, 1 - dt / life), 1.3);
			const out = [] as React.ReactNode[];
			if (dt < 0.18) out.push(<circle key="core" cx={cx} cy={cy} r={(1 - dt / 0.18) * (b.big ? 70 : 40)} fill={`hsla(${b.hue},100%,92%,0.9)`} />);
			for (let j = 0; j < b.n; j++) {
				const ang = (j / b.n) * Math.PI * 2 + rand(i * 97 + j) * 0.25;
				const spd = b.r * (0.72 + 0.28 * rand(i * 31 + j * 7));
				const reach = spd * (1 - Math.exp(-dt * 3.1));
				const fall = 70 * dt * dt;
				const x = cx + Math.cos(ang) * reach;
				const y = cy + Math.sin(ang) * reach + fall;
				const twinkle = b.big && dt > 1.1 ? 0.45 + 0.55 * Math.abs(Math.sin(dt * 38 + j)) : 1;
				const size = b.big ? 9 : 6;
				const light = j % 5 === 0 ? 88 : 66;
				out.push(<rect key={j} x={x - size / 2} y={y - size / 2} width={size} height={size}
					fill={`hsla(${(b.hue + (j % 3) * 14) % 360},96%,${light}%,${fade * twinkle})`} />);
				if (!glow) {
					const back = spd * (1 - Math.exp(-(dt - 0.06) * 3.1));
					out.push(<rect key={`t${j}`} x={cx + Math.cos(ang) * back - 2} y={cy + Math.sin(ang) * back + fall - 2} width={4} height={4}
						fill={`hsla(${b.hue},90%,70%,${fade * 0.4})`} />);
				}
			}
			return <g key={i}>{out}</g>;
		})}
	</>
);

export const Fireworks: React.FC<{t: number; bursts: Burst[]}> = ({t, bursts}) => (
	<AbsoluteFill style={{mixBlendMode: 'screen', pointerEvents: 'none'}}>
		<svg width="1920" height="1080">
			<defs>
				<filter id="fw-glow" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="9" /></filter>
			</defs>
			<g filter="url(#fw-glow)" opacity={0.9}><Particles t={t} bursts={bursts} glow /></g>
			<Particles t={t} bursts={bursts} />
		</svg>
	</AbsoluteFill>
);

// ── Smoke and stars ──────────────────────────────────────────────────────────
export const Smoke: React.FC<{t: number; x: number; y: number; count?: number; scale?: number; color?: string}> = ({t, x, y, count = 14, scale = 1, color = '150,160,180'}) => (
	<>
		{Array.from({length: count}, (_, i) => {
			const life = 4.2;
			const age = (t + i * (life / count)) % life;
			const k = age / life;
			const r = (14 + 46 * k) * scale;
			const ox = (rand(i) - 0.5) * 30 * scale + k * 60 * scale;
			const oy = -k * 220 * scale;
			const o = Math.sin(Math.PI * k) * 0.42;
			return (
				<div key={i} style={{position: 'absolute', left: x + ox - r, top: y + oy - r, width: r * 2, height: r * 2, borderRadius: '50%',
					background: `radial-gradient(circle, rgba(${color},${o}) 0%, rgba(${color},0) 70%)`, filter: 'blur(2px)'}} />
			);
		})}
	</>
);

export const Stars: React.FC<{t: number; count?: number; top?: number; opacity?: number}> = ({t, count = 90, top = 0.55, opacity = 1}) => (
	<AbsoluteFill style={{pointerEvents: 'none', opacity}}>
		{Array.from({length: count}, (_, i) => {
			const tw = 0.35 + 0.65 * Math.abs(Math.sin(t * (0.6 + rand(i) * 1.4) + i));
			const s = rand(i + 3) > 0.92 ? 3 : 2;
			return <div key={i} style={{position: 'absolute', left: rand(i + 11) * 1920, top: rand(i + 29) * 1080 * top, width: s, height: s,
				background: '#fff', opacity: tw * (0.4 + 0.6 * rand(i + 5))}} />;
		})}
	</AbsoluteFill>
);

// ── The pod, falling across the sky ─────────────────────────────────────────
export const PodStreak: React.FC<{t: number; from: number; to: number; path: [number, number][]; size: number; opacity?: number}> = ({t, from, to, path, size, opacity = 1}) => {
	const k = at(t, [from, to], [0, 1], ease.in);
	if (t < from || t > to + 0.1) return null;
	const point = (q: number): [number, number] => {
		const seg = Math.min(path.length - 2, Math.floor(q * (path.length - 1)));
		const local = q * (path.length - 1) - seg;
		const [a, b] = [path[seg], path[seg + 1]];
		return [a[0] + (b[0] - a[0]) * local, a[1] + (b[1] - a[1]) * local];
	};
	const [x, y] = point(k);
	const [px, py] = point(Math.max(0, k - 0.02));
	const angle = (Math.atan2(y - py, x - px) * 180) / Math.PI;
	const trail = Array.from({length: 24}, (_, i) => point(Math.max(0, k - i * 0.012)));
	return (
		<AbsoluteFill style={{pointerEvents: 'none', opacity}}>
			<svg width="1920" height="1080" style={{position: 'absolute'}}>
				<defs>
					<filter id="trail-blur"><feGaussianBlur stdDeviation="6" /></filter>
				</defs>
				{trail.slice(1).map(([tx, ty], i) => (
					<line key={i} x1={trail[i][0]} y1={trail[i][1]} x2={tx} y2={ty} stroke={`rgba(160,245,255,${0.55 * (1 - i / 24)})`}
						strokeWidth={size * 0.32 * (1 - i / 26)} strokeLinecap="round" filter="url(#trail-blur)" />
				))}
				{trail.slice(1).map(([tx, ty], i) => (
					<line key={`c${i}`} x1={trail[i][0]} y1={trail[i][1]} x2={tx} y2={ty} stroke={`rgba(255,250,235,${0.8 * (1 - i / 24)})`}
						strokeWidth={size * 0.08 * (1 - i / 26)} strokeLinecap="round" />
				))}
			</svg>
			<Img src={staticFile('v6/plates/pod.png')} style={{position: 'absolute', left: x - size / 2, top: y - (size * 2 / 3) / 2,
				width: size, height: size * 2 / 3, rotate: `${angle - 18}deg`,
				filter: `drop-shadow(0 0 ${size * 0.12}px rgba(140,240,255,0.9)) brightness(1.1)`}} />
		</AbsoluteFill>
	);
};

// ── Tanabata: bamboo, and the wishes tied to it ─────────────────────────────
const STRIPS = ['#e86f7d', '#f2c14e', '#7fc8f8', '#9ad37c', '#c79bf2', '#f59e5b', '#f7f1e3', '#e86f7d', '#7fd8c6'];
export const Tanabata: React.FC<{t: number; x: number; y: number; h: number; added?: number}> = ({t, x, y, h, added}) => {
	const sway = (i: number) => Math.sin(t * 1.7 + i * 0.9) * 5;
	const branches = [0.18, 0.32, 0.46, 0.6];
	return (
		<div style={{position: 'absolute', left: x, top: y - h, width: 1, height: h}}>
			{Array.from({length: 8}, (_, i) => (
				<div key={i} style={{position: 'absolute', left: -5, top: (h / 8) * i, width: 10, height: h / 8 - 3, background: i % 2 ? '#5f8f4c' : '#6aa055',
					boxShadow: 'inset -3px 0 0 rgba(0,0,0,0.18)'}} />
			))}
			{branches.map((b, bi) => {
				const dir = bi % 2 ? 1 : -1;
				const len = 120 - bi * 12;
				return (
					<div key={bi} style={{position: 'absolute', left: 0, top: h * b, rotate: `${dir * (62 + sway(bi) * 0.4)}deg`, transformOrigin: '0 0'}}>
						<div style={{position: 'absolute', left: 0, top: -2, width: len, height: 4, background: '#5f8f4c'}} />
						{[0.35, 0.65, 0.92].map((p, li) => (
							<div key={li} style={{position: 'absolute', left: len * p, top: -10, width: 22, height: 8, background: '#7cb35f', rotate: `${-30 + li * 25}deg`}} />
						))}
					</div>
				);
			})}
			{STRIPS.map((c, i) => {
				const b = branches[i % branches.length];
				const dir = (i % branches.length) % 2 ? 1 : -1;
				const reach = 30 + (i % 3) * 26;
				const isNew = added !== undefined && i === STRIPS.length - 1;
				const appear = isNew ? at(t, [added!, added! + 0.5], [0, 1]) : 1;
				if (appear <= 0) return null;
				return (
					<div key={i} style={{position: 'absolute', left: dir * reach - 7 + sway(i), top: h * b + 18 + (i % 3) * 8, width: 14, height: 46,
						background: c, rotate: `${sway(i) * 1.2}deg`, transformOrigin: '50% 0', opacity: appear,
						boxShadow: isNew ? `0 0 ${18 * appear}px rgba(255,230,160,0.9)` : '0 2px 0 rgba(0,0,0,0.18)'}}>
						<div style={{position: 'absolute', left: 4, top: 8, width: 6, height: 28, background: 'rgba(40,30,30,0.25)'}} />
					</div>
				);
			})}
		</div>
	);
};

// ── The notebook: what he noticed, kept ──────────────────────────────────────
export const Notebook: React.FC<{t: number; word: string; meaning: string; language: string; item: string;
	wordAt: number; meaningAt: number; playAt: number; noteAt: number; end: number}> = ({t, word, meaning, language, item, wordAt, meaningAt, playAt, noteAt, end}) => {
	const show = window(t, 0.05, end, 0.5);
	const rise = at(t, [0.05, 0.75], [60, 0]);
	const letters = Math.floor(at(t, [wordAt, wordAt + 0.45], [0, word.length], ease.inOut));
	const m = at(t, [meaningAt, meaningAt + 0.6], [0, 1]);
	const play = window(t, playAt - 0.05, playAt + 0.8, 0.12);
	const note = at(t, [noteAt, noteAt + 0.7], [0, 1]);
	return (
		<AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', opacity: show}}>
			<div style={{width: 1040, height: 520, translate: `0 ${rise}px`, background: 'linear-gradient(160deg, rgba(34,26,58,0.97), rgba(20,15,36,0.97))',
				border: '2px solid rgba(232,187,98,0.35)', borderRadius: 18, boxShadow: '0 40px 90px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.07)',
				position: 'relative', overflow: 'hidden'}}>
				<div style={{position: 'absolute', left: 56, top: 44, fontFamily: sans, fontWeight: 600, fontSize: 20, letterSpacing: '0.38em', color: C.gold}}>NOTEBOOK</div>
				<div style={{position: 'absolute', left: 56, top: 74, fontFamily: serif, fontStyle: 'italic', fontSize: 28, color: C.dim}}>a word to keep</div>
				<div style={{position: 'absolute', left: 590, top: 52, bottom: 52, width: 1, background: 'rgba(185,169,227,0.18)'}} />
				<div style={{position: 'absolute', left: 52, top: 150, fontFamily: serif, fontWeight: 600, fontSize: 150, lineHeight: 1, color: C.paper}}>
					{word.slice(0, letters)}<span style={{opacity: letters < word.length ? 0.8 : 0, color: C.gold}}>|</span>
				</div>
				<div style={{position: 'absolute', left: 58, top: 318, fontFamily: sans, fontSize: 22, letterSpacing: '0.2em', color: C.dim, opacity: m}}>{language}</div>
				<div style={{position: 'absolute', left: 56, top: 350, fontFamily: serif, fontStyle: 'italic', fontSize: 64, color: C.amber, opacity: m,
					translate: `${(1 - m) * 18}px 0`}}>{meaning}</div>
				<div style={{position: 'absolute', left: 480, top: 182, width: 64, height: 64, borderRadius: '50%', border: `2px solid ${C.gold}`,
					display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: m, background: `rgba(232,187,98,${0.15 + 0.5 * play})`,
					boxShadow: `0 0 ${36 * play}px rgba(232,187,98,${0.8 * play})`, scale: `${1 + 0.12 * play}`}}>
					<div style={{width: 0, height: 0, borderTop: '12px solid transparent', borderBottom: '12px solid transparent', borderLeft: `20px solid ${C.gold}`, marginLeft: 6}} />
				</div>
				<div style={{position: 'absolute', left: 660, top: 120, width: 320, height: 280, display: 'flex', alignItems: 'center', justifyContent: 'center',
					background: 'radial-gradient(circle, rgba(232,187,98,0.18), rgba(232,187,98,0) 65%)'}}>
					<div style={{position: 'relative', width: 240, height: 240, scale: `${at(t, [meaningAt - 0.2, meaningAt + 0.4], [0.6, 1], ease.out)}`,
						opacity: at(t, [meaningAt - 0.2, meaningAt + 0.2], [0, 1])}}>
						<Item id={item} x={120} y={120} size={240} />
					</div>
				</div>
				<div style={{position: 'absolute', left: 56, bottom: 46, fontFamily: serif, fontStyle: 'italic', fontSize: 34, color: C.paper, opacity: note,
					translate: `0 ${(1 - note) * 10}px`}}>Next time, you can ask.</div>
			</div>
		</AbsoluteFill>
	);
};

// ── The reputation card: how your answer landed ─────────────────────────────
export const RepCard: React.FC<{t: number; from: number; to: number; who: string; name: string; delta: string; line: string}> = ({t, from, to, who, name, delta, line}) => {
	const o = window(t, from, to, 0.35);
	if (o <= 0) return null;
	const slide = at(t, [from, from + 0.5], [60, 0]);
	return (
		<div style={{position: 'absolute', right: 90, top: 96, opacity: o, translate: `${slide}px 0`, display: 'flex', alignItems: 'center', gap: 20,
			background: C.panel, border: '2px solid rgba(232,187,98,0.45)', borderRadius: 14, padding: '16px 26px 16px 18px',
			boxShadow: '0 18px 40px rgba(0,0,0,0.5)'}}>
			<div style={{position: 'relative', width: 72, height: 72, overflow: 'hidden', borderRadius: 10, background: 'rgba(255,255,255,0.05)'}}>
				<Person who={who} act="nod" x={36} y={128} u={4.6} shadow={false} />
			</div>
			<div>
				<div style={{fontFamily: sans, fontWeight: 600, fontSize: 18, letterSpacing: '0.3em', color: C.dim}}>{name}</div>
				<div style={{fontFamily: serif, fontSize: 40, color: C.paper, lineHeight: 1.05}}><span style={{color: C.gold}}>{delta}</span> {line}</div>
			</div>
		</div>
	);
};

// ── A warm light leak, for passing between places ───────────────────────────
export const LightLeak: React.FC<{t: number; at: number; length?: number; hue?: number}> = ({t, at: when, length = 1.0, hue = 34}) => {
	const k = (t - when) / length;
	if (k < -0.5 || k > 0.5) return null;
	const o = Math.cos(k * Math.PI) ** 2;
	return (
		<AbsoluteFill style={{pointerEvents: 'none', mixBlendMode: 'screen', opacity: o * 0.85,
			background: `radial-gradient(ellipse 60% 80% at ${30 + k * 80}% 40%, hsla(${hue},95%,70%,0.85), hsla(${hue + 20},90%,55%,0.25) 45%, rgba(0,0,0,0) 70%)`}} />
	);
};
