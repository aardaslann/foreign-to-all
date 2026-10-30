// The About section's opening banner: the key art's rooftops at dawn, and the
// city saying hello in the eight languages of the journey. Each greeting
// starts as the dialogue box's glyphs and comes into focus a letter at a time,
// then takes the light-purple box the game gives a word you have understood.
// Loops seamlessly: every bubble is gone again before the last frame.
import React from 'react';
import {AbsoluteFill, cancelRender, continueRender, delayRender, Img, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {Glyph} from '../welcome/lib/type';
import {Sprite} from '../welcome/lib/pixel';
import {sans} from '../welcome/lib/core';
import {cover, INK, LAVENDER, PLATE} from './KeyArt';

export const HERO = {width: 1560, height: 620, seconds: 6};

const SCRIPTS = ['NotoSansJP', 'NotoSansDevanagari'];
const scriptsReady = delayRender('greeting fonts');
Promise.all(SCRIPTS.map((name) => new FontFace(name, `url(${staticFile(`v7/fonts/${name}.ttf`)})`).load()
	.then((face) => {
		(document.fonts as unknown as {add: (f: FontFace) => void}).add(face);
	})))
	.then(() => continueRender(scriptsReady))
	.catch((err: unknown) => cancelRender(err));

type Greeting = {text: string; x: number; y: number; at: number};

// Positions sit over the plate's lit windows at this frame size.
const GREETINGS: Greeting[] = [
	{text: 'Hallo!', x: 168, y: 182, at: 0.15},
	{text: 'Merhaba!', x: 1392, y: 206, at: 0.7},
	{text: 'Hello!', x: 520, y: 236, at: 1.25},
	{text: 'Bonjour !', x: 1046, y: 266, at: 1.8},
	{text: 'Привет!', x: 300, y: 300, at: 2.35},
	{text: 'नमस्ते!', x: 1262, y: 300, at: 2.9},
	{text: 'こんにちは!', x: 700, y: 318, at: 3.45},
	{text: '¡Hola!', x: 1450, y: 352, at: 4.0},
];

const FONT = 30;
const SCRAMBLE = 0.45;
const PER = 0.07;
const GONE = 5.55;

const clamp = (v: number) => Math.min(1, Math.max(0, v));

const Speech: React.FC<{g: Greeting; t: number; frame: number; seed: number}> = ({g, t, frame, seed}) => {
	const local = t - g.at;
	if (local < 0 || t > GONE + 0.25) return null;
	const chars = [...g.text];
	const pop = clamp(local / 0.18);
	const fade = 1 - clamp((t - GONE) / 0.25);
	const settled = local > SCRAMBLE + chars.length * PER + 0.1;
	const px = 4;
	return (
		<div style={{position: 'absolute', left: g.x, top: g.y, translate: '-50% -100%', scale: `${0.6 + 0.4 * pop}`, opacity: pop * fade,
			transformOrigin: '30% 100%'}}>
			<div style={{position: 'relative', background: 'rgba(18,16,28,0.92)', boxShadow: `0 0 0 ${px}px rgba(195,178,222,0.55), 0 8px 24px rgba(0,0,0,0.35)`,
				padding: '10px 16px', whiteSpace: 'nowrap', fontFamily: `${sans}, NotoSansJP, NotoSansDevanagari`, fontWeight: 700, fontSize: FONT, lineHeight: 1.1, color: '#ece6fa'}}>
				<span style={{display: 'inline-block', padding: '0 6px', margin: '0 -6px', background: settled ? 'rgba(195,178,222,0.3)' : 'transparent',
					boxShadow: settled ? `0 0 0 2px ${LAVENDER}` : 'none'}}>
					{chars.map((ch, i) => {
						const lands = SCRAMBLE + i * PER;
						if (ch === ' ' || local >= lands) return <span key={i}>{ch}</span>;
						const index = (Math.floor(frame / 2) * 7 + i * 3 + seed) % 8;
						return <Glyph key={i} index={index} size={FONT * 0.7} color={LAVENDER} style={{margin: '0 0.05em', verticalAlign: '-0.05em'}} />;
					})}
				</span>
			</div>
			{[0, 1, 2].map((k) => (
				<div key={k} style={{position: 'absolute', left: 22 + k * px, top: `calc(100% + ${k * px + px / 2}px)`, width: px * (3 - k), height: px,
					background: 'rgba(195,178,222,0.55)'}} />
			))}
		</div>
	);
};

export const AboutHero: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps, width: W, height: H} = useVideoConfig();
	const t = frame / fps;
	const v = cover(W, H, 836);
	const ledge = PLATE.ledge * v.scale + v.y;
	const u = 6.5;
	return (
		<AbsoluteFill style={{background: INK, overflow: 'hidden'}}>
			<Img src={staticFile('v7/plates/rooftops.png')} style={{position: 'absolute', left: v.x, top: v.y, width: PLATE.w * v.scale, height: PLATE.h * v.scale}} />
			<AbsoluteFill style={{background: 'linear-gradient(180deg, rgba(10,12,34,0.35) 0%, rgba(10,12,34,0) 45%)'}} />
			<div style={{position: 'absolute', left: W / 2 - u * 9, top: ledge + u * 0.6, width: u * 18, height: u * 2.4, borderRadius: '50%',
				background: 'rgba(8,6,16,0.55)', filter: `blur(${u * 0.6}px)`}} />
			<Sprite who="alien" act="back_stand" frame={Math.floor(frame / 2.5)} x={W / 2} y={ledge + u * 1.5} u={u}
				filter={`drop-shadow(0 0 ${u * 0.5}px rgba(255,176,110,0.55)) drop-shadow(0 0 ${u * 3}px rgba(255,150,90,0.25))`} />
			{GREETINGS.map((g, i) => <Speech key={i} g={g} t={t} frame={frame} seed={i * 5} />)}
		</AbsoluteFill>
	);
};
