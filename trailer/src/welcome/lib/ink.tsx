// Hand-made marks: pen strokes that draw themselves, ink balls, splats and
// sparkle stars. Strokes are dense seeded point lists; a stroke "draws" by
// keeping only the first part of its list, so no dash tricks are needed.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {C, rng, useFrame} from './core';

export type Pt = [number, number];

/** Catmull-Rom through the points, as cubic Béziers. */
export const smoothPath = (pts: Pt[]): string => {
	if (pts.length < 2) return '';
	let d = `M${pts[0][0].toFixed(2)},${pts[0][1].toFixed(2)}`;
	for (let i = 0; i < pts.length - 1; i++) {
		const p0 = pts[Math.max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[Math.min(pts.length - 1, i + 2)];
		const c1 = [p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6];
		const c2 = [p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6];
		d += `C${c1[0].toFixed(2)},${c1[1].toFixed(2)} ${c2[0].toFixed(2)},${c2[1].toFixed(2)} ${p2[0].toFixed(2)},${p2[1].toFixed(2)}`;
	}
	return d;
};

/** The first `p` (0..1) of a polyline, by length. */
export const partial = (pts: Pt[], p: number): Pt[] => {
	if (p >= 1) return pts;
	if (p <= 0) return [];
	const seg = pts.slice(1).map((q, i) => Math.hypot(q[0] - pts[i][0], q[1] - pts[i][1]));
	let left = seg.reduce((a, b) => a + b, 0) * p;
	const out: Pt[] = [pts[0]];
	for (let i = 0; i < seg.length; i++) {
		if (left >= seg[i]) {
			out.push(pts[i + 1]);
			left -= seg[i];
			continue;
		}
		const k = seg[i] ? left / seg[i] : 0;
		out.push([pts[i][0] + (pts[i + 1][0] - pts[i][0]) * k, pts[i][1] + (pts[i + 1][1] - pts[i][1]) * k]);
		break;
	}
	return out;
};

// ── Marks, in a 0..100 box around whatever they mark ─────────────────────────
const wobble = (r: () => number, amount: number) => (r() - 0.5) * 2 * amount;

export const marks = {
	/** A loose loop and a bit, like circling a word on a page. */
	circle: (seed: number, turns = 1.3): Pt[] => {
		const r = rng(seed);
		const start = -2.6 + wobble(r, 0.3);
		const tilt = wobble(r, 0.08);
		return Array.from({length: 90}, (_, i) => {
			const s = i / 89;
			const a = start + s * turns * Math.PI * 2;
			const grow = 1 + s * 0.12;
			const x = 50 + Math.cos(a) * 56 * grow + wobble(r, 1.2);
			const y = 50 + Math.sin(a) * 66 * grow + Math.cos(a) * tilt * 60 + wobble(r, 1.6);
			return [x, y] as Pt;
		});
	},
	underline: (seed: number): Pt[] => {
		const r = rng(seed);
		const lift = wobble(r, 4);
		return Array.from({length: 40}, (_, i) => {
			const s = i / 39;
			const hook = s > 0.9 ? (s - 0.9) * 120 : 0;
			return [-3 + s * 106 - hook * 0.4, 112 + Math.sin(s * 3.1) * 3 + lift * s - hook + wobble(r, 0.5)] as Pt;
		});
	},
	/** Back and forth over the box until it is gone. */
	scribble: (seed: number, rows = 9): Pt[] => {
		const r = rng(seed);
		const pts: Pt[] = [];
		for (let i = 0; i <= rows; i++) {
			const y = 4 + (i / rows) * 92 + wobble(r, 3);
			const left = -6 + wobble(r, 6), right = 106 + wobble(r, 6);
			const [a, b] = i % 2 ? [right, left] : [left, right];
			for (let k = 0; k <= 6; k++) pts.push([a + (b - a) * (k / 6), y + (k / 6) * (92 / rows) * 0.6 + wobble(r, 1.2)]);
		}
		return pts;
	},
	/** A rough box with overshooting corners, a designer's markup. */
	box: (seed: number): Pt[] => {
		const r = rng(seed);
		const c: Pt[] = [[-6, -8], [107, -4], [104, 108], [-4, 104], [-7, -12]];
		const pts: Pt[] = [];
		c.slice(0, -1).forEach((p, i) => {
			const q = c[i + 1];
			for (let k = 0; k <= 10; k++) pts.push([p[0] + (q[0] - p[0]) * (k / 10) + wobble(r, 0.6), p[1] + (q[1] - p[1]) * (k / 10) + wobble(r, 0.6)]);
		});
		return pts;
	},
	/** Cursive loops running left to right, like a signature. */
	signature: (seed: number): Pt[] => {
		const r = rng(seed);
		const loops = 5 + Math.floor(r() * 3);
		const phase = r() * 6;
		return Array.from({length: 160}, (_, i) => {
			const s = i / 159;
			const a = s * loops * Math.PI * 2 + phase;
			const env = Math.sin(Math.PI * Math.min(1, s * 1.15));
			return [s * 100 + Math.sin(a) * 6, 50 - Math.cos(a) * 34 * env * (0.6 + 0.4 * Math.sin(s * 9 + phase))] as Pt;
		});
	},
};

/** A mark over inline content (a word): drawn to `p`. */
export const Mark: React.FC<{
	pts: Pt[]; p: number; color?: string; width?: number; padX?: number; padY?: number; children: React.ReactNode;
}> = ({pts, p, color = C.red, width = 5, padX = 0, padY = 0, children}) => (
	<span style={{position: 'relative', display: 'inline-block'}}>
		{children}
		{p > 0 && (
			<svg viewBox="0 0 100 100" preserveAspectRatio="none"
				style={{position: 'absolute', left: `${-padX}%`, top: `${-padY}%`, width: `${100 + 2 * padX}%`, height: `${100 + 2 * padY}%`,
					overflow: 'visible', pointerEvents: 'none', filter: 'url(#ink-rough)'}}>
				<path d={smoothPath(partial(pts, p))} fill="none" stroke={color} strokeWidth={width} strokeLinecap="round" strokeLinejoin="round"
					vectorEffect="non-scaling-stroke" />
			</svg>
		)}
	</span>
);

/** A free stroke in frame pixels. */
export const Stroke: React.FC<{pts: Pt[]; p: number; color?: string; width?: number; blur?: number; opacity?: number}> = ({pts, p, color = C.ink, width = 4, blur = 0, opacity = 1}) => {
	const {W, H} = useFrame();
	if (p <= 0) return null;
	return (
		<svg width={W} height={H} style={{position: 'absolute', left: 0, top: 0, overflow: 'visible', opacity,
			filter: blur ? `blur(${blur}px)` : 'url(#ink-rough)'}}>
			<path d={smoothPath(partial(pts, p))} fill="none" stroke={color} strokeWidth={width} strokeLinecap="round" strokeLinejoin="round" />
		</svg>
	);
};

/** Points of a mark placed into a frame box. */
export const place = (pts: Pt[], x: number, y: number, w: number, h: number): Pt[] => pts.map(([px, py]) => [x + (px / 100) * w, y + (py / 100) * h]);

/** The filters the marks use: a slight tremble on the line, like a real pen. */
export const InkDefs: React.FC = () => (
	<svg width={0} height={0} style={{position: 'absolute'}}>
		<defs>
			<filter id="ink-rough" x="-20%" y="-20%" width="140%" height="140%">
				<feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves={2} seed={3} result="n" />
				<feDisplacementMap in="SourceGraphic" in2="n" scale={2.2} xChannelSelector="R" yChannelSelector="G" />
			</filter>
		</defs>
	</svg>
);

// ── Ink and light ────────────────────────────────────────────────────────────
/** A four-point sparkle, the reference's star. */
export const Star: React.FC<{x: number; y: number; r: number; color: string; rotate?: number; glow?: number; opacity?: number; pinch?: number}> = ({x, y, r, color, rotate = 0, glow = 0, opacity = 1, pinch = 0.14}) => {
	const k = pinch;
	const d = `M0,-1 Q${k},${-k} 1,0 Q${k},${k} 0,1 Q${-k},${k} -1,0 Q${-k},${-k} 0,-1 Z`;
	return (
		<svg width={r * 2} height={r * 2} viewBox="-1 -1 2 2"
			style={{position: 'absolute', left: x - r, top: y - r, overflow: 'visible', opacity, rotate: `${rotate}deg`,
				filter: glow ? `drop-shadow(0 0 ${glow}px ${color}) drop-shadow(0 0 ${glow * 2.5}px ${color})` : undefined}}>
			<path d={d} fill={color} />
		</svg>
	);
};

/** Ink droplets thrown out from a point; `p` 0..1 is the throw. */
export const Splat: React.FC<{x: number; y: number; size: number; p: number; color?: string; seed?: number; count?: number}> = ({x, y, size, p, color = C.ink, seed = 1, count = 18}) => {
	if (p <= 0 || p >= 1) return null;
	const r = rng(seed);
	const drops = Array.from({length: count}, () => ({a: r() * Math.PI * 2, d: 0.3 + r() * 0.9, s: 0.03 + r() * 0.09}));
	const fly = 1 - Math.pow(1 - p, 3);
	return (
		<svg width={size * 3} height={size * 3} viewBox="-1.5 -1.5 3 3" style={{position: 'absolute', left: x - size * 1.5, top: y - size * 1.5, overflow: 'visible'}}>
			<circle r={0.34 * (1 - p * 0.6)} fill={color} opacity={1 - p} />
			{drops.map((dr, i) => (
				<ellipse key={i} cx={Math.cos(dr.a) * dr.d * fly} cy={Math.sin(dr.a) * dr.d * fly} rx={dr.s * (1 - p * 0.7) * 1.8} ry={dr.s * (1 - p * 0.7)}
					transform={`rotate(${(dr.a * 180) / Math.PI} ${Math.cos(dr.a) * dr.d * fly} ${Math.sin(dr.a) * dr.d * fly})`} fill={color} opacity={1 - p * 0.8} />
			))}
		</svg>
	);
};

/** A ball of ink with its smear; `trail` is a list of past positions, newest last. */
export const InkBall: React.FC<{trail: Pt[]; r: number; color?: string}> = ({trail, r, color = C.ink}) => (
	<AbsoluteFill style={{pointerEvents: 'none'}}>
		{trail.map(([x, y], i) => {
			const k = (i + 1) / trail.length;
			const rr = r * (0.25 + 0.75 * k);
			return <div key={i} style={{position: 'absolute', left: x - rr, top: y - rr, width: rr * 2, height: rr * 2, borderRadius: '50%',
				background: color, opacity: 0.25 + 0.75 * k, filter: i < trail.length - 1 ? 'blur(2px)' : undefined}} />;
		})}
	</AbsoluteFill>
);

/** Horizontal speed lines for a whip, in frame pixels. */
export const SpeedLines: React.FC<{p: number; color?: string; seed?: number; count?: number}> = ({p, color = C.red, seed = 4, count = 9}) => {
	const {W, H} = useFrame();
	const r = rng(seed);
	return (
		<AbsoluteFill style={{pointerEvents: 'none'}}>
			{Array.from({length: count}, (_, i) => {
				const y = r() * H, len = W * (0.2 + r() * 0.5), th = 2 + r() * 5, x = (1.4 - p * 2.4 + r() * 0.5) * W;
				return <div key={i} style={{position: 'absolute', left: x, top: y, width: len, height: th, background: color, borderRadius: th, opacity: 0.85}} />;
			})}
		</AbsoluteFill>
	);
};
