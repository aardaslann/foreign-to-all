// Steam key art, one scene re-cropped for every capsule: the opening's dawn
// over Berlin's rooftops (the plate the intro cutscene draws), the alien seen
// from behind on the parapet, and the city's lit windows talking in the
// dialogue box's own glyphs. Everything is the game's art; only the title is
// text, as Steam's capsule rules ask.
import React from 'react';
import {AbsoluteFill, Img, staticFile, useVideoConfig} from 'remotion';
import {Glyph} from '../welcome/lib/type';
import {Sprite} from '../welcome/lib/pixel';

export const PLATE = {w: 1672, h: 941, ledge: 890};
export const INK = '#12101c';
export const LAVENDER = '#c3b2de';
export const MINT = '#79dcc4';

/** Where the plate sits in the output: output = plate * scale + offset. */
export type View = {scale: number; x: number; y: number};

/** Scale the plate to cover the frame, bottom-aligned, centred on plate x `focus`. */
export const cover = (W: number, H: number, focus = PLATE.w / 2, extra = 1): View => {
	const scale = Math.max(W / PLATE.w, H / PLATE.h) * extra;
	const x = Math.min(0, Math.max(W - PLATE.w * scale, W / 2 - focus * scale));
	return {scale, x, y: H - PLATE.h * scale};
};

export type BubbleSpec = {x: number; y: number; glyphs: number[]; size: number; tail?: 'left' | 'right'; word?: number; tone?: 'ink' | 'mint'};

/**
 * A speech box as the game draws one over a speaker: dark panel, light glyphs,
 * a recognised word in the light-purple hover box. Coordinates are output pixels.
 */
export const Bubble: React.FC<BubbleSpec> = ({x, y, glyphs, size, tail = 'left', word = -1, tone = 'ink'}) => {
	const pad = size * 0.42;
	const gap = size * 0.18;
	const px = Math.max(2, Math.round(size / 7));
	const w = glyphs.length * size + (glyphs.length - 1) * gap + pad * 2;
	const h = size + pad * 1.5;
	const fill = tone === 'mint' ? '#173a35' : 'rgba(18,16,28,0.9)';
	const line = tone === 'mint' ? MINT : 'rgba(195,178,222,0.55)';
	const tailX = tail === 'left' ? w * 0.24 : w * 0.76 - px * 3;
	return (
		<div style={{position: 'absolute', left: x - w / 2, top: y - h, width: w, height: h}}>
			<div style={{position: 'absolute', inset: 0, background: fill, boxShadow: `0 0 0 ${px}px ${line}, 0 ${px * 2}px ${px * 6}px rgba(0,0,0,0.35)`,
				display: 'flex', alignItems: 'center', justifyContent: 'center', gap}}>
				{glyphs.map((g, i) => (
					<span key={i} style={{display: 'inline-flex', padding: i === word ? px : 0, margin: i === word ? -px : 0,
						background: i === word ? 'rgba(195,178,222,0.32)' : 'transparent', boxShadow: i === word ? `0 0 0 ${Math.max(1, px / 2)}px ${LAVENDER}` : 'none'}}>
						<Glyph index={g} size={size} color={tone === 'mint' ? MINT : '#ece6fa'} />
					</span>
				))}
			</div>
			{[0, 1, 2].map((k) => (
				<div key={k} style={{position: 'absolute', left: tailX + (tail === 'left' ? k * px : (2 - k) * px), top: h + k * px - px / 2,
					width: px * (3 - k), height: px, background: line}} />
			))}
		</div>
	);
};

/** The game's wordmark, pixel-scaled by a whole factor where possible. */
export const Wordmark: React.FC<{cx: number; cy: number; scale: number; heavy?: boolean; glow?: boolean}> = ({cx, cy, scale, heavy = false, glow = true}) => {
	const w = 240 * scale, h = 84 * scale;
	return (
		<Img src={staticFile(heavy ? 'steam/wordmark-heavy.png' : 'v7/plates/wordmark.png')}
			style={{position: 'absolute', left: cx - w / 2, top: cy - h / 2, width: w, height: h, imageRendering: 'pixelated',
				filter: glow ? `drop-shadow(0 ${scale}px 0 ${INK}) drop-shadow(0 0 ${scale * 3}px rgba(12,10,26,0.8)) drop-shadow(0 0 ${scale * 11}px rgba(12,10,26,0.6))` : undefined}} />
	);
};

export type KeyArtProps = {
	plate?: string;
	focus?: number;
	zoom?: number;
	alien?: {x: number; u: number; act?: string} | null;
	logo?: {cx: number; cy: number; scale: number; heavy?: boolean} | null;
	bubbles?: BubbleSpec[];
	skyShade?: number;
	blur?: number;
	darken?: number;
};

/** One frame of key art in the current composition's size. */
export const KeyArt: React.FC<KeyArtProps> = ({plate = 'rooftops', focus = 836, zoom = 1, alien, logo, bubbles = [], skyShade = 0.35, blur = 0, darken = 0}) => {
	const {width: W, height: H} = useVideoConfig();
	const v = cover(W, H, focus, zoom);
	const ledge = PLATE.ledge * v.scale + v.y;
	return (
		<AbsoluteFill style={{background: INK, overflow: 'hidden'}}>
			<Img src={staticFile(`v7/plates/${plate}.png`)}
				style={{position: 'absolute', left: v.x, top: v.y, width: PLATE.w * v.scale, height: PLATE.h * v.scale, filter: blur ? `blur(${blur}px)` : undefined}} />
			{/* the sky deepens towards the top so the title always reads */}
			<AbsoluteFill style={{background: `linear-gradient(180deg, rgba(10,12,34,${skyShade}) 0%, rgba(10,12,34,${skyShade * 0.45}) 38%, rgba(10,12,34,0) 62%)`}} />
			{darken > 0 && <AbsoluteFill style={{background: `rgba(10,10,22,${darken})`}} />}
			{bubbles.map((b, i) => <Bubble key={i} {...b} />)}
			{alien && <div style={{position: 'absolute', left: alien.x - alien.u * 9, top: ledge + alien.u * 0.6, width: alien.u * 18, height: alien.u * 2.4,
				borderRadius: '50%', background: 'rgba(8,6,16,0.55)', filter: `blur(${alien.u * 0.6}px)`}} />}
			{alien && <Sprite who="alien" act={alien.act ?? 'back_stand'} x={alien.x} y={ledge + alien.u * 1.5} u={alien.u}
				filter={`drop-shadow(0 0 ${alien.u * 0.5}px rgba(255,176,110,0.55)) drop-shadow(0 0 ${alien.u * 3}px rgba(255,150,90,0.25))`} />}
			{logo && <Wordmark {...logo} />}
		</AbsoluteFill>
	);
};
