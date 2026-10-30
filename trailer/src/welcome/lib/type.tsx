// Words on screen: the game's pixel glyphs, typing with a cursor, and lines
// that start unreadable and come into focus a letter at a time.
import React from 'react';
import {staticFile} from 'remotion';
import {at, ease, FPS, rng} from './core';

/** The dialogue box's mapping: a character always becomes the same glyph (DialogueBox.gd _to_glyphs, on the pixel atlas). */
export const glyphOf = (ch: string) => (ch.codePointAt(0) ?? 0) % 8;

/** One pixel glyph from the game's atlas, in any colour. */
export const Glyph: React.FC<{index: number; size: number; color: string; style?: React.CSSProperties}> = ({index, size, color, style}) => {
	const mask = `url(${staticFile('welcome/glyphs16.png')})`;
	return (
		<span style={{display: 'inline-block', width: size, height: size, background: color,
			WebkitMaskImage: mask, maskImage: mask, WebkitMaskSize: `${size * 8}px ${size}px`, maskSize: `${size * 8}px ${size}px`,
			WebkitMaskPosition: `${-index * size}px 0`, maskPosition: `${-index * size}px 0`, WebkitMaskRepeat: 'no-repeat', maskRepeat: 'no-repeat',
			...style}} />
	);
};

/** A glyph sized and spaced to sit in a line of text at `fontSize`; `scale` narrows it for long words. */
const InlineGlyph: React.FC<{index: number; fontSize: number; color: string; scale?: number}> = ({index, fontSize, color, scale = 0.66}) => (
	<Glyph index={index} size={fontSize * scale} color={color} style={{margin: '0 0.03em', verticalAlign: '-0.04em'}} />
);

/**
 * A line that resolves from glyphs into letters, left to right: each letter
 * flickers through random glyphs for `scramble` seconds, then lands.
 */
export const Decode: React.FC<{
	text: string; t: number; from: number; per?: number; scramble?: number; fontSize: number; color: string; glyphColor?: string; seed?: number;
	landColor?: string; glyphScale?: number;
}> = ({text, t, from, per = 0.045, scramble = 0.22, fontSize, color, glyphColor, seed = 1, landColor, glyphScale}) => {
	const frame = Math.floor(t * FPS / 2);
	let n = 0;
	return (
		<>
			{[...text].map((ch, i) => {
				if (ch === ' ') return <span key={i}> </span>;
				if (ch === '\n') return <br key={i} />;
				const land = from + n++ * per;
				if (t >= land) {
					const pop = at(t, [land, land + 0.18], [1, 0], ease.out);
					const c = landColor && pop > 0.05 ? landColor : color;
					return <span key={i} style={{display: 'inline-block', color: c, scale: `${1 + pop * 0.25}`}}>{ch}</span>;
				}
				const index = t >= land - scramble ? Math.floor(rng(seed * 997 + i * 31 + frame)() * 8) : glyphOf(ch);
				return <InlineGlyph key={i} index={index} fontSize={fontSize} color={glyphColor ?? color} scale={glyphScale} />;
			})}
		</>
	);
};

/** A whole line in glyphs, never resolving. */
export const GlyphLine: React.FC<{text: string; fontSize: number; color: string}> = ({text, fontSize, color}) => (
	<>
		{[...text].map((ch, i) => (ch === ' ' ? <span key={i}> </span> : <InlineGlyph key={i} index={glyphOf(ch)} fontSize={fontSize} color={color} />))}
	</>
);

/** A text cursor that rides after the last typed character without moving the layout. */
const Cursor: React.FC<{kind: 'block' | 'bar'; color: string; on: boolean}> = ({kind, color, on}) => (
	<span style={{display: 'inline-block', width: 0, position: 'relative'}}>
		<span style={{position: 'absolute', left: '0.08em', top: kind === 'block' ? '-0.78em' : '-0.84em', width: kind === 'block' ? '0.42em' : '0.07em',
			height: kind === 'block' ? '0.9em' : '1.02em', background: color, opacity: on ? 1 : 0}} />
	</span>
);

/**
 * Typed text: characters appear at `cps` from `from`. The untyped rest keeps
 * its space, so a centred line never shifts while it grows. A "\n" breaks the
 * line when the parent sets `whiteSpace: 'pre-line'`.
 */
export const Typed: React.FC<{
	text: string; t: number; from: number; cps?: number; cursor?: 'block' | 'bar' | 'none'; cursorColor?: string; cursorUntil?: number;
}> = ({text, t, from, cps = 26, cursor = 'none', cursorColor = 'currentColor', cursorUntil = Infinity}) => {
	if (t < from) return <span style={{visibility: 'hidden'}}>{text}</span>;
	const n = Math.min(text.length, Math.floor((t - from) * cps));
	const typing = n < text.length;
	const blink = typing || Math.floor((t - from) * 2.4) % 2 === 0;
	return (
		<>
			<span>{text.slice(0, n)}</span>
			{cursor !== 'none' && t < cursorUntil && <Cursor kind={cursor} color={cursorColor} on={blink} />}
			<span style={{visibility: 'hidden'}}>{text.slice(n)}</span>
		</>
	);
};

/** When typed text finishes. */
export const typedEnd = (text: string, from: number, cps = 26) => from + text.length / cps;
