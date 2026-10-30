// Shared pieces for revision 7: revision 5's look (Georgia captions, the
// letterbox, square pixel speech boxes, the game's own glyphs) carried onto
// the game's retro scene art and its own renderer's people.
import React, {createContext, useContext} from 'react';
import {AbsoluteFill, Easing, Img, interpolate, staticFile, useCurrentFrame} from 'remotion';
import {P} from '../../lib/palette';
import {toGlyphs} from '../../lib/glyphs';
import timeline from '../timeline.json';
import generated from '../generated.json';

// ── Time ─────────────────────────────────────────────────────────────────────
export const FPS = timeline.fps;
export const T = timeline;
export const G = generated;
export const f = (s: number) => Math.round(s * FPS);
export type SceneId = keyof typeof timeline.scenes;
export const scene = (id: SceneId) => {
	const [start, end] = timeline.scenes[id];
	return {start, end, from: f(start), duration: f(end) - f(start)};
};
export const voice = (id: string) => (generated.voices as Record<string, {at: number; dur: number}>)[id];
export const typedAt = (id: string) => timeline.typed.find((x) => x.id === id) ?? {id, text: '', at: 0, cps: 12};

/** Seconds since the start of the current <Sequence>. */
export const useSeconds = () => useCurrentFrame() / FPS;
/** A scene's local clock for a film time. */
export const local = (id: SceneId, film: number) => film - timeline.scenes[id][0];

const smooth = Easing.bezier(0.45, 0, 0.25, 1);
export const ease = {out: Easing.bezier(0.16, 1, 0.3, 1), inOut: Easing.bezier(0.65, 0, 0.35, 1), in: Easing.bezier(0.5, 0, 0.75, 0), smooth};

/** Clamped interpolate on seconds. */
export const at = (t: number, input: number[], output: number[], easing = smooth) =>
	interpolate(t, input, output, {extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing});
/** 0 → 1 → 0: in over `fade`, out over `fade`. */
export const window = (t: number, a: number, b: number, fade = 0.35) =>
	Math.min(at(t, [a, a + fade], [0, 1]), at(t, [b - fade, b], [1, 0]));

// ── Type and colour (revision 5's) ───────────────────────────────────────────
export const serif = 'Georgia, "Times New Roman", serif';
export const sans = '"Segoe UI", Arial, sans-serif';
export const mono = 'Consolas, monospace';
export const C = {night: P.void, ink: P.ink, muted: P.inkMuted, gold: P.amber, panel: P.panel, border: P.border,
	lavender: '#c3b2de', teal: '#82baad', frame: '#776889'};
export const LETTERBOX = {top: 82, bottom: 88};

// ── The world: a plate from the game, a camera, things placed on it ─────────
export const PLATE = {w: 1672, h: 941};
export const COVER = Math.max(1920 / PLATE.w, 1080 / PLATE.h);
export type Cam = {x: number; y: number; z: number};
const WorldScale = createContext(COVER);
export const useWorldScale = () => useContext(WorldScale);

/** A slow camera move between two framings. */
export const move = (t: number, a: number, b: number, from: Cam, to: Cam, easing = smooth): Cam => {
	const k = at(t, [a, b], [0, 1], easing);
	return {x: from.x + (to.x - from.x) * k, y: from.y + (to.y - from.y) * k, z: from.z + (to.z - from.z) * k};
};

export const World: React.FC<{plate: string; cam: Cam; grade?: string; children?: React.ReactNode}> = ({plate, cam, grade, children}) => {
	const s = COVER * cam.z;
	const tx = Math.min(0, Math.max(1920 - PLATE.w * s, 960 - cam.x * s));
	const ty = Math.min(0, Math.max(1080 - PLATE.h * s, 540 - cam.y * s));
	return (
		<AbsoluteFill style={{overflow: 'hidden', backgroundColor: C.night}}>
			<div style={{position: 'absolute', left: 0, top: 0, width: PLATE.w, height: PLATE.h,
				transformOrigin: '0 0', transform: `translate(${tx}px, ${ty}px) scale(${s})`}}>
				<Img src={staticFile(`v7/plates/${plate}.png`)} style={{width: PLATE.w, height: PLATE.h, display: 'block', filter: grade}} />
				<WorldScale.Provider value={s}>{children}</WorldScale.Provider>
			</div>
		</AbsoluteFill>
	);
};

/** A framed window onto a plate, for the cities: centre (x, y) in plate pixels, `zoom` box px per plate px. */
export const Window: React.FC<{plate: string; x: number; y: number; zoom: number; w: number; h: number; grade?: string; children?: React.ReactNode}> = ({plate, x, y, zoom, w, h, grade, children}) => {
	const tx = Math.min(0, Math.max(w - PLATE.w * zoom, w / 2 - x * zoom));
	const ty = Math.min(0, Math.max(h - PLATE.h * zoom, h / 2 - y * zoom));
	return (
		<div style={{position: 'relative', width: w, height: h, overflow: 'hidden', background: C.night}}>
			<div style={{position: 'absolute', left: 0, top: 0, width: PLATE.w, height: PLATE.h, transformOrigin: '0 0',
				transform: `translate(${tx}px, ${ty}px) scale(${zoom})`}}>
				<Img src={staticFile(`v7/plates/${plate}.png`)} style={{width: PLATE.w, height: PLATE.h, display: 'block', filter: grade}} />
				<WorldScale.Provider value={zoom}>{children}</WorldScale.Provider>
			</div>
		</div>
	);
};

/** A colour wash over the whole frame, for the time of day. */
export const Wash: React.FC<{color: string; blend?: React.CSSProperties['mixBlendMode']; opacity?: number}> = ({color, blend = 'multiply', opacity = 1}) => (
	<AbsoluteFill style={{background: color, mixBlendMode: blend, opacity, pointerEvents: 'none'}} />
);

// ── People and things, from the game's own renderer ──────────────────────────
const FRAME = 40;
const FEET = {x: 20, y: 37};
const FRAMES = 24;

/**
 * One of the game's people, played from the strips that
 * tools/export_trailer_cast.gd renders with CharacterArt. `x`, `y` are the
 * feet in the parent's pixels; `u` is pixels per grid unit. `back_*` acts are
 * the same person seen from behind.
 */
export const Person: React.FC<{
	who: string; act?: string; x: number; y: number; u?: number; clipY?: number; filter?: string; opacity?: number; phase?: number;
}> = ({who, act = 'stand', x, y, u = 5.6, clipY, filter, opacity = 1, phase = 0}) => {
	const frame = useCurrentFrame();
	const index = Math.floor((frame / FPS) * 12 + phase) % FRAMES;
	const top = y - FEET.y * u;
	const height = clipY === undefined ? FRAME * u : Math.max(0, Math.min(FRAME * u, clipY - top));
	return (
		<div style={{position: 'absolute', left: x - FEET.x * u, top, width: FRAME * u, height, overflow: 'hidden', opacity, filter}}>
			<Img src={staticFile(`v7/cast/${who}/${act}.png`)}
				style={{position: 'absolute', left: -index * FRAME * u, top: 0, width: FRAMES * FRAME * u, height: FRAME * u,
					imageRendering: 'pixelated', maxWidth: 'none'}} />
		</div>
	);
};

export const Item: React.FC<{id: string; x: number; y: number; size: number; style?: React.CSSProperties}> = ({id, x, y, size, style}) => (
	<Img src={staticFile(`v7/items/${id}.png`)}
		style={{position: 'absolute', left: x - size / 2, top: y - size / 2, width: size, height: size, imageRendering: 'pixelated', ...style}} />
);

// ── Speech: the game's glyphs, and words that come into focus ────────────────
export type Seg = {text: string; kind?: 'plain' | 'glyph' | 'amber' | 'decode'; at?: number};

/**
 * Plain words, glyph words (the dialogue box's own glyph set, one fixed shape
 * per word), amber words he knows, and words that turn from glyphs into amber
 * letters one by one from `at`. `typed` reveals characters over time.
 */
export const Speech: React.FC<{segs: Seg[]; t: number; typed?: {from: number; cps: number}}> = ({segs, t, typed}) => {
	let shown = typed ? Math.max(0, Math.floor((t - typed.from) * typed.cps)) : Infinity;
	return (
		<span>
			{segs.map((seg, si) => {
				const glyphs = seg.kind === 'glyph' || seg.kind === 'decode' ? seg.text.split(/(\s+)/).map((w) => (/\s/.test(w) ? w : toGlyphs(w))).join('') : seg.text;
				return (
					<span key={si}>
						{[...seg.text].map((ch, ci) => {
							if (shown-- <= 0) return null;
							const key = `${si}-${ci}`;
							const g = [...glyphs][ci] ?? ch;
							if (seg.kind === 'glyph') return <span key={key} style={{color: C.lavender}}>{g}</span>;
							if (seg.kind === 'decode') {
								const k = (seg.at ?? 0) + ci * 0.07;
								if (t < k) return <span key={key} style={{color: C.lavender}}>{g}</span>;
								const glow = at(t, [k, k + 0.6], [1, 0]);
								return <span key={key} style={{color: C.gold, textShadow: `0 0 ${16 * glow}px rgba(242,197,110,${0.9 * glow})`}}>{ch}</span>;
							}
							return <span key={key} style={{color: seg.kind === 'amber' ? C.gold : undefined}}>{ch}</span>;
						})}
					</span>
				);
			})}
		</span>
	);
};

/** Revision 5's speech box: square, a thick frame, a stepped pixel tail; anchored to someone, constant on screen. */
export const Bubble: React.FC<{
	x: number; y: number; t: number; from: number; to: number; segs: Seg[];
	typed?: {from: number; cps: number}; side?: 'left' | 'right' | 'center'; size?: number;
}> = ({x, y, t, from, to, segs, typed, side = 'center', size = 40}) => {
	const scale = useWorldScale();
	const shown = window(t, from, to, 0.16);
	if (shown <= 0) return null;
	const rise = (1 - at(t, [from, from + 0.25], [0, 1])) * 12;
	const shift = side === 'center' ? '-50%' : side === 'left' ? '-82%' : '-18%';
	const tail = side === 'center' ? '50%' : side === 'left' ? '82%' : '18%';
	return (
		<div style={{position: 'absolute', left: x, top: y, transformOrigin: '0 0', transform: `scale(${1 / scale})`}}>
			<div style={{transform: `translate(${shift}, calc(-100% - 26px + ${rise}px))`, opacity: shown, position: 'relative',
				filter: 'drop-shadow(0 8px 0 rgba(0,0,0,.15))'}}>
				<div style={{background: C.panel, color: C.ink, padding: '18px 26px 21px', border: `4px solid ${C.frame}`, fontSize: size, lineHeight: 1.25,
					fontFamily: sans, fontWeight: 500, whiteSpace: 'nowrap'}}>
					<Speech segs={segs} t={t} typed={typed} />
				</div>
				<div style={{position: 'absolute', top: 'calc(100% - 4px)', left: `calc(${tail} - 13px)`, width: 25, height: 18, background: C.panel,
					borderLeft: `4px solid ${C.frame}`, borderRight: `4px solid ${C.frame}`}} />
				<div style={{position: 'absolute', top: 'calc(100% + 10px)', left: `calc(${tail} - 13px)`, width: 14, height: 12, background: C.panel,
					borderBottom: `4px solid ${C.frame}`, borderLeft: `4px solid ${C.frame}`}} />
			</div>
		</div>
	);
};

// ── The film's own voice: revision 5's reading captions ─────────────────────
export const Captions: React.FC<{t: number}> = ({t}) => {
	const c = T.captions.find((x) => t >= x.at && t < x.until);
	if (!c) return null;
	const a = window(t, c.at, c.until, 0.45);
	const two = c.text.includes('\n');
	return (
		<div style={{position: 'absolute', left: 160, right: 160, top: two ? 128 : 146, whiteSpace: 'pre-line', textAlign: 'center',
			fontFamily: serif, fontSize: two ? 70 : 74, lineHeight: 1.24, color: C.ink, opacity: a,
			transform: `translateY(${(1 - at(t, [c.at, c.at + 0.6], [0, 1])) * 10}px)`,
			textShadow: '0 2px 18px rgba(8,6,20,0.9), 0 0 3px rgba(8,6,20,0.7)'}}>{c.text}</div>
	);
};

/** Revision 5's place label: small tracked capitals and an italic line. */
export const Place: React.FC<{name: string; detail?: string; t: number; from: number; to: number}> = ({name, detail, t, from, to}) => (
	<div style={{position: 'absolute', left: 108, top: 119, opacity: window(t, from, to, 0.4), color: C.ink, textShadow: '0 2px 10px rgba(8,6,20,0.8)'}}>
		<div style={{fontFamily: sans, fontWeight: 600, letterSpacing: 6, fontSize: 26}}>{name.toUpperCase()}</div>
		{detail && <div style={{fontFamily: serif, fontStyle: 'italic', fontSize: 24, marginTop: 9, color: '#ddd1bd'}}>{detail}</div>}
	</div>
);

/** The art dims under a caption while it is up, and only then. */
export const CaptionShade: React.FC<{t: number}> = ({t}) => {
	const c = T.captions.find((x) => t >= x.at - 0.3 && t < x.until + 0.3);
	if (!c) return null;
	const a = window(t, c.at - 0.3, c.until + 0.3, 0.6);
	return <AbsoluteFill style={{pointerEvents: 'none', opacity: a,
		background: 'linear-gradient(180deg, rgba(11,10,28,0.92) 0%, rgba(11,10,28,0.78) 20%, rgba(11,10,28,0.42) 30%, rgba(11,10,28,0) 42%)'}} />;
};

/** Readability under the captions: a soft dark band below the letterbox. */
export const TopShade: React.FC<{opacity?: number}> = ({opacity = 0.7}) => (
	<AbsoluteFill style={{background: 'linear-gradient(180deg, rgba(11,10,28,0.9) 0%, rgba(11,10,28,0.5) 22%, rgba(11,10,28,0) 40%)', opacity, pointerEvents: 'none'}} />
);

export const Letterbox: React.FC = () => (
	<>
		<div style={{position: 'absolute', left: 0, right: 0, top: 0, height: LETTERBOX.top, background: C.night}} />
		<div style={{position: 'absolute', left: 0, right: 0, bottom: 0, height: LETTERBOX.bottom, background: C.night}} />
	</>
);

export const Black: React.FC<{opacity: number}> = ({opacity}) =>
	opacity > 0 ? <AbsoluteFill style={{background: '#000', opacity, pointerEvents: 'none'}} /> : null;
