// Set pieces: pixel fireworks, steam, smoke, the falling light, Tanabata.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {at} from './core';

const rand = (i: number) => {
	const x = Math.sin(i * 127.1 + 311.7) * 43758.5453;
	return x - Math.floor(x);
};
const snap = (v: number, grid = 4) => Math.round(v / grid) * grid;

// ── Fireworks, drawn the way revision 5 drew them: on a 4-pixel grid ─────────
export type Burst = {t: number; big: boolean; x: number; y: number; r: number; colour: string; n: number};
const LIFE = (b: Burst) => (b.big ? 3.6 : 2.6);
const RISE = 0.9;

/** How much light the sky is giving off right now, 0..1, and whose colour. */
export const skyLight = (t: number, bursts: Burst[]) => {
	let light = 0;
	let colour = '#e8c25c';
	for (const b of bursts) {
		const dt = t - b.t;
		if (dt < 0 || dt > 1.6) continue;
		const k = Math.exp(-dt * 3.2) * (b.big ? 1 : 0.4);
		if (k > light) colour = b.colour;
		light += k;
	}
	return {light: Math.min(1, light), colour};
};

const Sparks: React.FC<{t: number; bursts: Burst[]}> = ({t, bursts}) => (
	<>
		{bursts.map((b, i) => {
			const dt = t - b.t;
			if (dt < -RISE || dt > LIFE(b)) return null;
			const cx = b.x * 1920;
			const cy = b.y * 1080;
			if (dt < 0) {
				const k = at(dt, [-RISE, 0], [0, 1]);
				const y = 1000 + (cy - 1000) * k;
				return (
					<g key={i}>
						{[0, 1, 2, 3].map((j) => <rect key={j} x={snap(cx) - 2} y={snap(y + j * 14)} width={4} height={8} fill={b.colour} opacity={0.8 - j * 0.2} />)}
					</g>
				);
			}
			const life = LIFE(b);
			const fade = Math.pow(1 - Math.min(1, dt / life), 0.9);
			return (
				<g key={i} opacity={fade}>
					{Array.from({length: b.n}, (_, j) => {
						const ang = (j / b.n) * Math.PI * 2 + rand(i * 97 + j) * 0.12;
						const speed = b.r * (0.78 + 0.22 * rand(i * 31 + j));
						const reach = speed * (1 - Math.exp(-dt * 1.7));
						const fall = dt * dt * 16;
						const x = cx + Math.cos(ang) * reach;
						const y = cy + Math.sin(ang) * reach + fall;
						const twinkle = b.big && dt > 1.4 ? (Math.sin(dt * 30 + j * 1.7) > -0.2 ? 1 : 0.2) : 1;
						const tail = reach - 16;
						return (
							<g key={j} opacity={twinkle}>
								<rect x={snap(x) - 4} y={snap(y) - 4} width={b.big ? 8 : 6} height={b.big ? 8 : 6} fill={b.colour} />
								{dt < 0.9 && j % 3 === 0 && <rect x={snap(x) - 2} y={snap(y) - 2} width={4} height={4} fill="#fffbe8" />}
								{dt < 1.6 && <rect x={snap(cx + Math.cos(ang) * tail) - 2} y={snap(cy + Math.sin(ang) * tail + fall) - 2} width={4} height={4} fill={b.colour} opacity={0.55} />}
								{dt < 1.2 && <rect x={snap(cx + Math.cos(ang) * (reach - 34)) - 1.5} y={snap(cy + Math.sin(ang) * (reach - 34) + fall) - 1.5} width={3} height={3} fill={b.colour} opacity={0.3} />}
							</g>
						);
					})}
				</g>
			);
		})}
	</>
);

export const Fireworks: React.FC<{t: number; bursts: Burst[]}> = ({t, bursts}) => (
	<AbsoluteFill style={{pointerEvents: 'none'}}>
		<svg width="1920" height="1080" style={{position: 'absolute', filter: 'blur(12px)', opacity: 0.85, mixBlendMode: 'screen'}}>
			<Sparks t={t} bursts={bursts} />
		</svg>
		<svg width="1920" height="1080" shapeRendering="crispEdges" style={{position: 'absolute', mixBlendMode: 'screen'}}>
			<Sparks t={t} bursts={bursts} />
		</svg>
	</AbsoluteFill>
);

// ── Steam, revision 5's: three thin stepped wisps ───────────────────────────
export const Steam: React.FC<{x: number; y: number; t: number; colour?: string; scale?: number}> = ({x, y, t, colour = '#f4efe2', scale = 1}) => (
	<svg style={{position: 'absolute', left: x - 50 * scale, top: y - 110 * scale, overflow: 'visible', pointerEvents: 'none'}} width={100 * scale} height={110 * scale} viewBox="0 0 100 110">
		{[0, 1, 2].map((i) => {
			const p = (t * 0.43 + i * 0.29) % 1;
			return <path key={i} d={`M ${42 + i * 9 + Math.sin(p * 8) * 8} ${108 - p * 66} l -4 -9 l 8 -12 l -4 -9`} fill="none" stroke={colour} strokeWidth={3} opacity={Math.sin(p * Math.PI) * 0.4} />;
		})}
	</svg>
);

// ── Smoke from the crashed pod ───────────────────────────────────────────────
export const Smoke: React.FC<{t: number; x: number; y: number; count?: number; scale?: number; color?: string}> = ({t, x, y, count = 12, scale = 1, color = '180,182,198'}) => (
	<>
		{Array.from({length: count}, (_, i) => {
			const life = 5.4;
			const age = (t + i * (life / count)) % life;
			const k = age / life;
			const r = (14 + 44 * k) * scale;
			const ox = (rand(i) - 0.5) * 30 * scale + k * 50 * scale;
			const oy = -k * 200 * scale;
			return (
				<div key={i} style={{position: 'absolute', left: x + ox - r, top: y + oy - r, width: r * 2, height: r * 2, borderRadius: '50%',
					background: `radial-gradient(circle, rgba(${color},${Math.sin(Math.PI * k) * 0.34}) 0%, rgba(${color},0) 70%)`}} />
			);
		})}
	</>
);

/** A soft light on the plate: a lamp, a lantern, a lit window. */
export const Glow: React.FC<{x: number; y: number; r: number; color: string; t?: number; flicker?: number}> = ({x, y, r, color, t = 0, flicker = 0}) => {
	const k = 1 - flicker * (0.5 + 0.5 * Math.sin(t * 7.3 + x * 0.05) * Math.sin(t * 3.1 + y));
	return (
		<div style={{position: 'absolute', left: x - r, top: y - r, width: r * 2, height: r * 2, borderRadius: '50%', mixBlendMode: 'screen',
			opacity: k, background: `radial-gradient(circle, ${color} 0%, rgba(0,0,0,0) 70%)`, pointerEvents: 'none'}} />
	);
};

/** The pod, seen as a small falling light: a pixel core, a glow, a short fading tail. */
export const FallingLight: React.FC<{t: number; from: number; to: number; a: [number, number]; b: [number, number]; size?: number; opacity?: number}> = ({t, from, to, a, b, size = 1, opacity = 1}) => {
	if (t < from || t > to) return null;
	const k = at(t, [from, to], [0, 1], (x) => x * x);
	const pos = (q: number): [number, number] => [a[0] + (b[0] - a[0]) * q, a[1] + (b[1] - a[1]) * q];
	const [x, y] = pos(k);
	const fadeIn = at(t, [from, from + 0.4], [0, 1]);
	return (
		<AbsoluteFill style={{pointerEvents: 'none', opacity: opacity * fadeIn}}>
			{Array.from({length: 14}, (_, i) => {
				const [tx, ty] = pos(Math.max(0, k - i * 0.014));
				return <div key={i} style={{position: 'absolute', left: snap(tx, 3) - 3 * size, top: snap(ty, 3) - 3 * size, width: 6 * size, height: 6 * size,
					background: '#bdf3ff', opacity: 0.7 * (1 - i / 14)}} />;
			})}
			<div style={{position: 'absolute', left: x - 34 * size, top: y - 34 * size, width: 68 * size, height: 68 * size, borderRadius: '50%',
				background: 'radial-gradient(circle, rgba(190,245,255,0.75), rgba(120,220,255,0) 70%)', mixBlendMode: 'screen'}} />
			<div style={{position: 'absolute', left: snap(x, 3) - 4 * size, top: snap(y, 3) - 4 * size, width: 8 * size, height: 8 * size, background: '#ffffff'}} />
		</AbsoluteFill>
	);
};

// ── Tanabata: bamboo, and the wishes tied to it ─────────────────────────────
const STRIPS = ['#e86f7d', '#f2c14e', '#7fc8f8', '#9ad37c', '#c79bf2', '#f59e5b', '#f7f1e3', '#e86f7d', '#7fd8c6'];
export const Tanabata: React.FC<{t: number; x: number; y: number; h: number; added?: number}> = ({t, x, y, h, added}) => {
	const sway = (i: number) => Math.sin(t * 1.4 + i * 0.9) * 4;
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
						boxShadow: isNew ? `0 0 ${16 * appear}px rgba(255,230,160,0.9)` : '0 2px 0 rgba(0,0,0,0.18)'}}>
						<div style={{position: 'absolute', left: 4, top: 8, width: 6, height: 28, background: 'rgba(40,30,30,0.25)'}} />
					</div>
				);
			})}
		</div>
	);
};
