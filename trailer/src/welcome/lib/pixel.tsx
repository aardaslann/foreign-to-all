// The game's own pixels: its items, its people (drawn by its renderer through
// tools/export_trailer_cast.gd), heat-map looks for them, and a pixel Earth.
import React from 'react';
import {Img, staticFile} from 'remotion';
import {C} from './core';

export type ItemId = 'apple' | 'bread' | 'cay' | 'kermel_flowers' | 'money' | 'old_book' | 'water';

/** One of the game's 32-px items, centred on (x, y). */
export const Item: React.FC<{id: ItemId; x: number; y: number; size: number; rotate?: number; opacity?: number; filter?: string; scale?: number}> = ({id, x, y, size, rotate = 0, opacity = 1, filter, scale = 1}) => (
	<Img src={staticFile(`v7/items/${id}.png`)}
		style={{position: 'absolute', left: x - size / 2, top: y - size / 2, width: size, height: size, imageRendering: 'pixelated',
			rotate: `${rotate}deg`, scale: `${scale}`, opacity, filter}} />
);

/** An icon from the game's 16-px UI strip (art/ui/icons.png): 4 is the journal. */
export const Icon: React.FC<{index: number; x: number; y: number; size: number; rotate?: number; opacity?: number}> = ({index, x, y, size, rotate = 0, opacity = 1}) => (
	<div style={{position: 'absolute', left: x - size / 2, top: y - size / 2, width: size, height: size, rotate: `${rotate}deg`, opacity,
		backgroundImage: `url(${staticFile('art/ui/icons.png')})`, backgroundSize: `${size * 8}px ${size}px`, backgroundPosition: `${-index * size}px 0`,
		imageRendering: 'pixelated'}} />
);

// The cast strips: 24 frames of 40×40, feet at (20, 37) — public/v7/cast.json.
const FRAME = 40;
const FRAMES = 24;
const FEET = {x: 20, y: 37};

/** One of the game's people, feet at (x, y), `u` screen pixels per sprite pixel. */
export const Sprite: React.FC<{who: string; act?: string; frame?: number; x: number; y: number; u: number; filter?: string; opacity?: number}> = ({who, act = 'stand', frame = 0, x, y, u, filter, opacity = 1}) => (
	<div style={{position: 'absolute', left: x - FEET.x * u, top: y - FEET.y * u, width: FRAME * u, height: FRAME * u, overflow: 'hidden', filter, opacity}}>
		<Img src={staticFile(`v7/cast/${who}/${act}.png`)}
			style={{position: 'absolute', left: -(Math.floor(frame) % FRAMES) * FRAME * u, top: 0, width: FRAMES * FRAME * u, height: FRAME * u,
				imageRendering: 'pixelated', maxWidth: 'none'}} />
	</div>
);

/** The sprite's visible body, for placing things around it: top of head to feet, in sprite pixels from the feet. */
export const BODY = {head: 31, waist: 14};

// ── Heat: a gradient map from the sprite's own light and dark ────────────────
const HEAT = {
	warm: ['#1a0610', '#7a0f1f', '#e2361c', '#ff8a1e', '#ffd25a', '#fff5d6'],
	rose: ['#1a0716', '#6e1250', '#d62f7a', '#ff7aa8', '#ffc3c9', '#fff1ec'],
	gold: ['#170f05', '#6b3d0a', '#c97a12', '#f2b530', '#ffe08a', '#fffbe8'],
	mint: ['#04121a', '#0c4a5a', '#1aa39a', '#46e8c0', '#b6ffe9', '#f4fffb'],
	violet: ['#0e0a1f', '#3a2a7a', '#6f5bd6', '#a995f0', '#d9cffb', '#fbf9ff'],
	grey: ['#141318', '#36353c', '#5c5a63', '#86848d', '#b2b0b8', '#d6d4da'],
} as const;
export type Heat = keyof typeof HEAT;

const channel = (stops: readonly string[], k: number) => stops.map((s) => (parseInt(s.slice(1 + k * 2, 3 + k * 2), 16) / 255).toFixed(3)).join(' ');

/** SVG filters `heat-<name>`: luminance → palette. Mount once. */
export const HeatDefs: React.FC = () => (
	<svg width={0} height={0} style={{position: 'absolute'}}>
		<defs>
			{Object.entries(HEAT).map(([name, stops]) => (
				<filter key={name} id={`heat-${name}`} colorInterpolationFilters="sRGB">
					<feColorMatrix type="matrix" values="0.3 0.59 0.11 0 0  0.3 0.59 0.11 0 0  0.3 0.59 0.11 0 0  0 0 0 1 0" />
					<feComponentTransfer>
						<feFuncR type="table" tableValues={channel(stops, 0)} />
						<feFuncG type="table" tableValues={channel(stops, 1)} />
						<feFuncB type="table" tableValues={channel(stops, 2)} />
					</feComponentTransfer>
				</filter>
			))}
		</defs>
	</svg>
);

/** A person seen as warmth: the heat-mapped sprite over a soft bloom of itself. */
export const Warm: React.FC<{who: string; act?: string; frame?: number; x: number; y: number; u: number; heat: Heat; glow?: number; opacity?: number}> = ({who, act, frame, x, y, u, heat, glow = 1, opacity = 1}) => (
	<>
		<Sprite who={who} act={act} frame={frame} x={x} y={y} u={u} opacity={0.75 * glow * opacity} filter={`url(#heat-${heat}) blur(${u * 2.2}px) brightness(1.4)`} />
		<Sprite who={who} act={act} frame={frame} x={x} y={y} u={u} opacity={opacity} filter={`url(#heat-${heat})`} />
	</>
);

// ── A pixel Earth ────────────────────────────────────────────────────────────
type LonLat = [number, number];
// Rough continents, (longitude, latitude) — enough for 28 pixels across.
const LAND: LonLat[][] = [
	[[-168, 66], [-140, 70], [-100, 72], [-80, 73], [-62, 60], [-55, 52], [-66, 44], [-76, 35], [-81, 25], [-90, 29], [-97, 26], [-97, 16], [-87, 13], [-78, 8], [-83, 9], [-92, 15], [-105, 20], [-112, 30], [-118, 34], [-124, 40], [-125, 49], [-133, 57], [-150, 60], [-165, 60]],
	[[-55, 83], [-25, 83], [-20, 72], [-40, 62], [-50, 64], [-58, 76]],
	[[-78, 8], [-60, 11], [-50, 0], [-35, -6], [-40, -22], [-48, -28], [-58, -38], [-65, -45], [-68, -55], [-74, -50], [-72, -30], [-70, -18], [-76, -12], [-81, -5], [-80, 2]],
	[[-10, 36], [-9, 43], [-2, 44], [-5, 48], [2, 51], [5, 53], [8, 57], [5, 62], [15, 69], [28, 71], [40, 68], [40, 45], [28, 41], [26, 38], [20, 40], [15, 38], [12, 44], [8, 44], [3, 42], [-5, 36]],
	[[-17, 21], [-16, 13], [-8, 5], [5, 5], [9, 4], [9, -1], [13, -12], [12, -17], [15, -27], [20, -35], [26, -34], [33, -26], [35, -20], [40, -15], [40, -5], [43, 0], [51, 11], [43, 12], [37, 17], [33, 30], [25, 31], [20, 31], [11, 33], [10, 37], [0, 36], [-6, 35], [-10, 30], [-17, 22]],
	[[40, 45], [40, 68], [60, 70], [80, 73], [105, 78], [140, 73], [180, 69], [180, 64], [160, 60], [155, 52], [140, 48], [135, 35], [127, 35], [121, 31], [120, 23], [110, 20], [106, 10], [100, 13], [98, 8], [100, 3], [104, 1], [98, 16], [92, 22], [88, 22], [80, 15], [77, 8], [72, 20], [67, 25], [57, 26], [50, 30], [48, 29], [56, 24], [59, 22], [52, 16], [44, 12], [35, 30], [36, 36], [30, 40]],
	[[113, -22], [114, -34], [118, -35], [129, -32], [137, -35], [144, -39], [150, -37], [153, -27], [146, -19], [142, -11], [136, -12], [130, -12], [122, -17]],
	[[109, 2], [119, 7], [118, -4], [110, -3]], [[95, 5], [106, -6], [102, -6], [95, 2]], [[131, -1], [150, -6], [146, -9], [138, -8]],
	[[130, 31], [141, 41], [145, 44], [141, 45], [139, 38], [132, 33]], [[-5, 50], [1, 51], [-2, 57], [-6, 58], [-5, 54]],
	[[44, -12], [50, -15], [47, -25], [43, -22]], [[172, -34], [178, -38], [167, -46], [170, -45]],
];
const inside = (poly: LonLat[], [x, y]: LonLat) => {
	let hit = false;
	for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
		const [xi, yi] = poly[i], [xj, yj] = poly[j];
		if (yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi) hit = !hit;
	}
	return hit;
};
// A 5° land grid, built once.
const GRID = Array.from({length: 36}, (_, r) => Array.from({length: 72}, (_, c) => {
	const p: LonLat = [-177.5 + c * 5, 87.5 - r * 5];
	if (p[1] < -68) return 2;
	if (p[1] > 78) return 2;
	return LAND.some((poly) => inside(poly, p)) ? 1 : 0;
}));
const PLANET = {
	ocean: ['#2a4c88', '#3a6bb8', '#5b8fd6'], land: ['#3c7d45', '#5fae5a', '#8fd16a'], ice: ['#a9b9c9', '#d6e0ea', '#f4f7fa'],
};

/** A turning pixel Earth `D` pixels across, drawn at `size` screen pixels. */
export const Earth: React.FC<{x: number; y: number; size: number; spin: number; D?: number}> = ({x, y, size, spin, D = 28}) => {
	const cells: React.ReactNode[] = [];
	const L = [-0.55, -0.55, 0.63];
	for (let j = 0; j < D; j++) {
		for (let i = 0; i < D; i++) {
			const nx = ((i + 0.5) / D) * 2 - 1, ny = ((j + 0.5) / D) * 2 - 1;
			const rr = nx * nx + ny * ny;
			if (rr > 1) continue;
			const edge = rr > (1 - 2.2 / D) ** 2;
			const nz = Math.sqrt(1 - rr);
			const lat = (Math.asin(-ny) * 180) / Math.PI;
			const lon = ((((Math.atan2(nx, nz) * 180) / Math.PI + spin) % 360) + 540) % 360 - 180;
			const kind = GRID[Math.min(35, Math.max(0, Math.floor((90 - lat) / 5)))][Math.min(71, Math.max(0, Math.floor((lon + 180) / 5)))];
			const light = nx * L[0] + ny * L[1] + nz * L[2];
			const shade = light > 0.62 ? 2 : light > 0.18 ? 1 : 0;
			const fill = edge ? C.ink : (kind === 2 ? PLANET.ice : kind === 1 ? PLANET.land : PLANET.ocean)[shade];
			cells.push(<rect key={`${i}-${j}`} x={i} y={j} width={1.02} height={1.02} fill={fill} />);
		}
	}
	return (
		<svg width={size} height={size} viewBox={`0 0 ${D} ${D}`} shapeRendering="crispEdges"
			style={{position: 'absolute', left: x - size / 2, top: y - size / 2, overflow: 'visible'}}>
			{cells}
		</svg>
	);
};

/** A square pixel speech box with a stepped tail, holding a few glyphs. */
export const PixelBubble: React.FC<{x: number; y: number; w: number; px: number; children?: React.ReactNode; fill?: string; line?: string}> = ({x, y, w, px, children, fill = C.white, line = C.ink}) => {
	const h = w * 0.62;
	return (
		<div style={{position: 'absolute', left: x - w / 2, top: y - h / 2, width: w, height: h}}>
			<div style={{position: 'absolute', inset: 0, background: fill, boxShadow: `0 0 0 ${px}px ${line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: px * 2}}>
				{children}
			</div>
			{[0, 1, 2].map((k) => (
				<div key={k} style={{position: 'absolute', left: w * 0.22 + k * px, top: h + k * px, width: px * (3 - k) + px, height: px, background: line}} />
			))}
			<div style={{position: 'absolute', left: w * 0.22 + px, top: h, width: px * 2, height: px, background: fill}} />
		</div>
	);
};
