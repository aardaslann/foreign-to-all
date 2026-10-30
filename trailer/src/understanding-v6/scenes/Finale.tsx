// The invitation, the fireworks, and the title.
import React from 'react';
import {AbsoluteFill, cancelRender, continueRender, delayRender, staticFile} from 'remotion';
import {C, G, T, at, ease, move, sans, serif, voice, useSeconds, Black, Bubble, Caption, Chyron, Person, TopShade, Vignette, Wash, World} from '../lib/core';
import {Fireworks, Stars, skyLight, type Burst} from '../lib/fx';

const BURSTS = G.bursts as Burst[];
const HEAD = 150;

const Glow: React.FC<{x: number; y: number; r: number; color: string}> = ({x, y, r, color}) => (
	<div style={{position: 'absolute', left: x - r, top: y - r, width: r * 2, height: r * 2, borderRadius: '50%', mixBlendMode: 'screen',
		background: `radial-gradient(circle, ${color} 0%, rgba(0,0,0,0) 70%)`}} />
);

// ── The invitation: "Coming? I saved you a spot." ────────────────────────────
const [IN] = T.scenes.invitation;
const STREET = {nadia: {x: 1080, y: 738}, alien: {x0: 520, x1: 880, y: 740}, leave: 3.9};
const WINDOWS: [number, number][] = [[105, 312], [295, 312], [852, 312], [1045, 312], [1478, 312], [1005, 522]];

export const Invitation: React.FC = () => {
	const t = useSeconds();
	const line = {from: voice('nadia-coming').at - IN, to: voice('nadia-coming').at - IN + voice('nadia-coming').dur};
	const arrive = at(t, [0, 1.5], [0, 1], ease.out);
	const go = Math.max(0, t - STREET.leave) * 128;
	const ax = STREET.alien.x0 + (STREET.alien.x1 - STREET.alien.x0) * arrive + go;
	const nx = STREET.nadia.x + go;
	const nadia = t < line.from ? 'wave' : t < line.to + 0.05 ? 'talk' : t < STREET.leave ? 'point' : 'walk';
	const alien = t < 1.45 ? 'walk' : t < 2.8 ? 'watch' : t < STREET.leave ? 'nod' : 'walk';
	const lit = 'brightness(0.68) saturate(0.88)';
	return (
		<AbsoluteFill>
			<World plate="terrace" grade="brightness(0.5) saturate(0.8) contrast(1.1) hue-rotate(8deg)"
				cam={move(t, 0, 7.31, {x: 880, y: 585, z: 1.5}, {x: 1160, y: 600, z: 1.62})}>
				{WINDOWS.map(([x, y], i) => <Glow key={i} x={x} y={y} r={74} color="rgba(255,196,112,0.55)" />)}
				<Glow x={180} y={378} r={60} color="rgba(255,214,140,0.9)" />
				<Glow x={180} y={420} r={220} color="rgba(255,180,100,0.22)" />
				<Glow x={1452} y={208} r={60} color="rgba(255,214,140,0.9)" />
				<Glow x={1452} y={260} r={240} color="rgba(255,180,100,0.2)" />
				<Person who="nadia" act={nadia} x={nx} y={STREET.nadia.y} filter={lit} />
				<Person who="alien" act={alien} x={ax} y={STREET.alien.y} filter={lit} />
				<Bubble x={STREET.nadia.x} y={STREET.nadia.y - HEAD} t={t} from={line.from} to={STREET.leave - 0.3} side="left"
					segs={[{text: 'Coming? I saved you a spot.'}]} />
			</World>
			{/* blue hour */}
			<Wash color="linear-gradient(180deg, rgba(40,60,170,0.7) 0%, rgba(90,80,170,0.4) 60%, rgba(255,150,100,0.2) 100%)" blend="soft-light" />
			<TopShade opacity={0.5} />
			<Chyron city="LONDON" sub="a familiar face" t={t} from={0.4} to={3.6} />
			<Vignette strength={0.65} />
			<Black opacity={at(t, [0, 0.55], [1, 0]) + at(t, [6.9, 7.31], [0, 1], ease.in)} />
		</AbsoluteFill>
	);
};

// ── Fireworks over the rooftops ──────────────────────────────────────────────
const [FW] = T.scenes.fireworks;
const LEDGE = 908;

export const FireworksScene: React.FC = () => {
	const t = useSeconds();
	const abs = FW + t;
	const {light, hue} = skyLight(abs, BURSTS);
	const night = at(t, [0, 21.9], [0, 1], ease.inOut);
	const lift = 0.5 + 0.62 * light;
	const rim = `drop-shadow(0 -3px 8px hsla(${hue},90%,70%,${0.85 * light}))`;
	return (
		<AbsoluteFill style={{background: '#05040b'}}>
			<World plate="rooftops" grade={`brightness(${0.52 - 0.14 * night + 0.22 * light}) saturate(${0.86 - 0.1 * night}) contrast(1.08)`}
				cam={move(t, 0, 21.94, {x: 836, y: 476, z: 1.02}, {x: 836, y: 446, z: 1.13})} />
			<Wash color={`linear-gradient(180deg, rgba(20,28,90,${0.55 + 0.25 * night}) 0%, rgba(40,40,110,0.35) 70%, rgba(20,16,40,0.5) 100%)`} blend="multiply" />
			<Stars t={t} count={80} top={0.5} opacity={0.35 + 0.4 * night} />
			<Fireworks t={abs} bursts={BURSTS} />
			<AbsoluteFill style={{mixBlendMode: 'screen', opacity: light * 0.3,
				background: `radial-gradient(ellipse 90% 70% at 50% 20%, hsla(${hue},85%,62%,0.9), rgba(0,0,0,0) 75%)`}} />
			{/* the near rooftop: a parapet, and the two of them on it */}
			<AbsoluteFill style={{scale: `${1 + 0.045 * night}`, transformOrigin: '50% 100%'}}>
				<Parapet light={light} hue={hue} />
				<Person who="alien" act="sit" x={866} y={LEDGE + 16} u={10.4} shadow={false} phase={2} filter={`brightness(${lift}) saturate(0.9) ${rim}`} />
				<Person who="nadia" act="sit" x={1060} y={LEDGE + 16} u={10.4} shadow={false} phase={9} filter={`brightness(${lift}) saturate(0.9) ${rim}`} />
			</AbsoluteFill>
			<Caption lines={['You may still be foreign.']} t={t} from={102.98 - FW} to={108.6 - FW} y={500} size={74} />
			<Caption lines={['But you can still understand.']} t={t} from={110.29 - FW} to={117.2 - FW} y={500} size={74} />
			<Vignette strength={0.6} />
			<Black opacity={at(t, [0, 0.5], [1, 0])} />
			<AbsoluteFill style={{background: '#fff8ec', opacity: at(t, [21.45, 21.94], [0, 1], ease.in)}} />
		</AbsoluteFill>
	);
};

const Parapet: React.FC<{light: number; hue: number}> = ({light, hue}) => (
	<div style={{position: 'absolute', left: -40, right: -40, top: LEDGE, bottom: -40}}>
		<div style={{position: 'absolute', left: 0, right: 0, top: 0, height: 26, background: '#2c2638',
			boxShadow: `inset 0 3px 0 hsla(${hue},70%,${55 + 20 * light}%,${0.25 + 0.5 * light})`}} />
		<div style={{position: 'absolute', left: 0, right: 0, top: 26, bottom: 0,
			background: 'repeating-linear-gradient(0deg, #1b1724 0 34px, #15121d 34px 37px), #1b1724'}} />
		<div style={{position: 'absolute', left: 0, right: 0, top: 26, bottom: 0, opacity: 0.6,
			background: 'repeating-linear-gradient(90deg, rgba(0,0,0,0) 0 92px, rgba(10,8,16,0.8) 92px 95px)'}} />
		<div style={{position: 'absolute', left: 0, right: 0, top: 26, height: 14, background: 'rgba(0,0,0,0.35)'}} />
	</div>
);

// ── Title ────────────────────────────────────────────────────────────────────
const [TI] = T.scenes.title;
const STRANGER = ['Fremder', 'yabancı', 'stranger', 'étranger', 'чужой', 'अजनबी',
	'異邦人', 'forastero', 'straniero', 'estrangeiro', 'người lạ', '이방인', 'უცხო', 'malihini'];
const SCRIPTS = ['NotoSansJP', 'NotoSansKR', 'NotoSansDevanagari', 'NotoSansGeorgian'];
const scriptsReady = delayRender('stranger-word fonts');
Promise.all(SCRIPTS.map((name) => new FontFace(name, `url(${staticFile(`v6/fonts/${name}.ttf`)})`).load()
	.then((face) => {
		// this TypeScript's DOM lib predates FontFaceSet.add
		(document.fonts as unknown as {add: (font: FontFace) => void}).add(face);
	})))
	.then(() => continueRender(scriptsReady))
	.catch((err: unknown) => cancelRender(err));

const Letters: React.FC<{text: string; t: number; from: number; style: React.CSSProperties}> = ({text, t, from, style}) => (
	<span style={style}>
		{[...text].map((ch, i) => {
			const o = at(t, [from + i * 0.06, from + i * 0.06 + 0.7], [0, 1]);
			return <span key={i} style={{display: 'inline-block', opacity: o, filter: `blur(${(1 - o) * 10}px)`, translate: `0 ${(1 - o) * 16}px`}}>{ch}</span>;
		})}
	</span>
);

const Diamond: React.FC = () => (
	<span style={{display: 'inline-block', width: 11, height: 11, rotate: '45deg', border: `1.5px solid ${C.lavender}`, margin: '0 26px', verticalAlign: '0.12em',
		background: 'radial-gradient(circle, rgba(185,169,227,0.9) 0 2px, rgba(0,0,0,0) 2.5px)'}} />
);

export const Title: React.FC = () => {
	const t = useSeconds();
	const word = at(t, [2.3, 2.7], [0, 1]);
	const index = Math.max(0, Math.floor((t - 2.3) / 0.5)) % STRANGER.length;
	const rule = at(t, [2.9, 3.8], [0, 1], ease.inOut);
	const line2 = at(t, [128.58 - TI, 128.58 - TI + 0.9], [0, 1]);
	const outro = at(t, [18.34, 20.24], [0, 1], ease.inOut);
	return (
		<AbsoluteFill style={{background: '#05040b'}}>
			<World plate="title" grade="brightness(0.6) saturate(0.92)" cam={move(t, 0, 20.24, {x: 836, y: 470, z: 1.0}, {x: 836, y: 452, z: 1.1}, ease.out)} />
			<Fireworks t={TI + t} bursts={BURSTS} />
			<AbsoluteFill style={{background: 'radial-gradient(ellipse 52% 40% at 50% 46%, rgba(8,6,16,0.72) 0%, rgba(8,6,16,0.35) 60%, rgba(8,6,16,0) 100%)'}} />
			<div style={{position: 'absolute', top: 330, left: 0, right: 0, textAlign: 'center', color: C.paper, whiteSpace: 'nowrap',
				textShadow: '0 0 40px rgba(185,169,227,0.35), 0 4px 30px rgba(0,0,0,0.6)'}}>
				<Letters text="FOREIGN" t={t} from={0.7} style={{fontFamily: sans, fontWeight: 300, fontSize: 108, letterSpacing: '0.36em'}} />
				<span style={{fontFamily: serif, fontStyle: 'italic', fontSize: 60, color: C.lavender, margin: '0 0.55em 0 0.05em', letterSpacing: '0.12em',
					opacity: at(t, [1.3, 1.9], [0, 1]), verticalAlign: '0.35em'}}>· to ·</span>
				<Letters text="ALL" t={t} from={1.1} style={{fontFamily: sans, fontWeight: 300, fontSize: 108, letterSpacing: '0.36em', marginRight: '-0.36em'}} />
			</div>
			<div style={{position: 'absolute', top: 490, left: 0, right: 0, textAlign: 'center', opacity: word,
				fontFamily: `${sans}, ${SCRIPTS.join(', ')}`, fontSize: 32, color: C.lavender, letterSpacing: '0.06em'}}>
				<Diamond />{STRANGER[index]}<Diamond />
			</div>
			<div style={{position: 'absolute', top: 572, left: 960 - 40 * rule, width: 80 * rule, height: 1, background: '#8a77c0'}} />
			<Caption lines={['A world to discover. People to understand.']} t={t} from={124.92 - TI} to={19.4} y={604} size={50} italic />
			<div style={{position: 'absolute', top: 690, left: 0, right: 0, textAlign: 'center', fontFamily: sans, fontWeight: 300, fontSize: 27,
				letterSpacing: '0.04em', color: C.dim, opacity: line2, translate: `0 ${(1 - line2) * 12}px`}}>
				A narrative game about culture, connection and seeing beyond stereotypes.
			</div>
			<Vignette strength={0.7} />
			<AbsoluteFill style={{background: '#fff8ec', opacity: at(t, [0, 1.4], [1, 0], ease.out), pointerEvents: 'none'}} />
			<Black opacity={outro} />
		</AbsoluteFill>
	);
};
