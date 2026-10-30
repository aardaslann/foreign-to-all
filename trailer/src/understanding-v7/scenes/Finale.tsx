// The invitation, then revision 5's ending: the two of them on a bench, seen
// from behind, watching fireworks over the city; the title over them.
import React from 'react';
import {AbsoluteFill, cancelRender, continueRender, delayRender, Img, staticFile} from 'remotion';
import {C, G, T, at, local, move, sans, serif, voice, useSeconds, Black, Bubble, Person, Place, TopShade, Wash, World} from '../lib/core';
import {Fireworks, Glow, Steam, skyLight, type Burst} from '../lib/fx';

const BURSTS = G.bursts as Burst[];
const HEAD = 150;

// ── The invitation: "Coming? I saved you a spot." ────────────────────────────
const STREET = {nadia: {x: 1080, y: 740}, alien: {x0: 560, x1: 870, y: 742}, leave: 3.7};
const WINDOWS: [number, number][] = [[105, 312], [295, 312], [852, 312], [1045, 312], [1478, 312], [1005, 522]];

export const Invitation: React.FC = () => {
	const t = useSeconds();
	const v = voice('nadia-coming');
	const line = {from: local('invitation', v.at), to: local('invitation', v.at + v.dur)};
	const go = Math.max(0, t - STREET.leave) * 120;
	const ax = STREET.alien.x0 + (STREET.alien.x1 - STREET.alien.x0) * at(t, [0, 1.5], [0, 1]) + go;
	const nx = STREET.nadia.x + go;
	const nadia = t < line.from ? 'wave' : t < line.to + 0.05 ? 'talk' : t < STREET.leave ? 'watch' : 'walk';
	const alien = t < 1.5 ? 'walk' : t < 3.0 ? 'watch' : t < STREET.leave ? 'nod' : 'walk';
	const lit = 'brightness(0.72) saturate(0.9)';
	return (
		<AbsoluteFill>
			<World plate="terrace" cam={move(t, 0, 6.25, {x: 880, y: 560, z: 1.5}, {x: 1100, y: 575, z: 1.6})}
				grade="brightness(0.5) saturate(0.8) contrast(1.1) hue-rotate(8deg)">
				{WINDOWS.map(([x, y], i) => <Glow key={i} x={x} y={y} r={72} color="rgba(255,196,112,0.55)" />)}
				<Glow x={180} y={378} r={58} color="rgba(255,214,140,0.9)" />
				<Glow x={180} y={420} r={220} color="rgba(255,180,100,0.2)" />
				<Glow x={1452} y={208} r={58} color="rgba(255,214,140,0.9)" />
				<Glow x={1452} y={260} r={240} color="rgba(255,180,100,0.18)" />
				<Person who="nadia" act={nadia} x={nx} y={STREET.nadia.y} filter={lit} />
				<Person who="alien" act={alien} x={ax} y={STREET.alien.y} filter={lit} />
				<Bubble x={STREET.nadia.x} y={STREET.nadia.y - HEAD} t={t} from={line.from} to={STREET.leave - 0.2} side="left"
					segs={[{text: 'Coming? I saved you a spot.'}]} />
			</World>
			{/* evening, blue */}
			<Wash color="linear-gradient(180deg, rgba(40,60,170,0.7) 0%, rgba(90,80,170,0.4) 60%, rgba(255,150,100,0.18) 100%)" blend="soft-light" />
			<TopShade opacity={0.6} />
			<Place name="London" detail="A familiar face" t={t} from={0.3} to={3.6} />
			<Black opacity={at(t, [5.8, 6.25], [0, 1])} />
		</AbsoluteFill>
	);
};

// ── The bench ────────────────────────────────────────────────────────────────
const [BENCH] = T.scenes.bench;
const TITLE = 117.75 - BENCH;
const SEAT = 860;
const STRANGER = ['Fremder', 'yabancı', 'stranger', 'étranger', 'чужой', 'अजनबी',
	'異邦人', 'forastero', 'straniero', 'estrangeiro', 'người lạ', '이방인', 'უცხო', 'malihini'];
const SCRIPTS = ['NotoSansJP', 'NotoSansKR', 'NotoSansDevanagari', 'NotoSansGeorgian'];
const scriptsReady = delayRender('stranger-word fonts');
Promise.all(SCRIPTS.map((name) => new FontFace(name, `url(${staticFile(`v7/fonts/${name}.ttf`)})`).load()
	.then((face) => {
		// this TypeScript's DOM lib predates FontFaceSet.add
		(document.fonts as unknown as {add: (font: FontFace) => void}).add(face);
	})))
	.then(() => continueRender(scriptsReady))
	.catch((err: unknown) => cancelRender(err));

/** The bench from behind: two back posts, two slats, the seat's edge. */
const Bench: React.FC = () => (
	<svg width={1920} height={1080} style={{position: 'absolute', left: 0, top: 0}} shapeRendering="crispEdges">
		<rect x={662} y={772} width={18} height={150} fill="#4f3b2c" />
		<rect x={1240} y={772} width={18} height={150} fill="#4f3b2c" />
		<rect x={640} y={792} width={640} height={20} fill="#8a6a4e" />
		<rect x={640} y={792} width={640} height={4} fill="#a5846a" />
		<rect x={640} y={824} width={640} height={20} fill="#7a5b41" />
		<rect x={640} y={824} width={640} height={4} fill="#94755a" />
		<rect x={630} y={856} width={660} height={14} fill="#5e4533" />
	</svg>
);

export const BenchScene: React.FC = () => {
	const t = useSeconds();
	const film = BENCH + t;
	const {light, colour} = skyLight(film, BURSTS);
	const title = at(t, [TITLE, TITLE + 1.2], [0, 1]);
	const word = at(t, [TITLE + 1.4, TITLE + 1.9], [0, 1]);
	const index = Math.max(0, Math.floor((t - TITLE - 1.4) / 0.5)) % STRANGER.length;
	const rim = Math.round(light * 200).toString(16).padStart(2, '0');
	const lift = `brightness(${0.62 + 0.45 * light}) drop-shadow(0 -2px 5px ${colour}${rim})`;
	return (
		<AbsoluteFill style={{background: C.night}}>
			<World plate="title" cam={move(t, 0, 17.6, {x: 836, y: 430, z: 1.08}, {x: 836, y: 412, z: 1.15})} grade={`brightness(${0.78 + 0.18 * light})`} />
			<Fireworks t={film} bursts={BURSTS} />
			<AbsoluteFill style={{background: colour, mixBlendMode: 'soft-light', opacity: light * 0.25}} />
			{/* the slope they sit on */}
			<svg width={1920} height={1080} style={{position: 'absolute', left: 0, top: 0}} shapeRendering="crispEdges">
				<rect x={0} y={900} width={1920} height={180} fill="#121c19" />
				<rect x={0} y={900} width={1920} height={6} fill="#1c2b25" />
				{Array.from({length: 48}, (_, i) => <rect key={i} x={i * 40 + (i % 3) * 7} y={896 - (i % 4) * 2} width={4} height={6 + (i % 4) * 2} fill="#1f3029" />)}
			</svg>
			<Person who="alien" act="back_sit" x={830} y={SEAT} u={9.5} phase={2} filter={lift} />
			<Person who="nadia" act="back_sit" x={1090} y={SEAT} u={9.5} phase={9} filter={lift} />
			<Steam x={962} y={792} t={film} scale={0.55} />
			<Bench />
			<AbsoluteFill style={{background: 'radial-gradient(ellipse 70% 50% at 50% 30%, rgba(11,10,28,0.55), rgba(11,10,28,0) 70%)', opacity: title}} />
			<div style={{position: 'absolute', left: 360, top: 92, width: 1200, height: 420, opacity: title, transform: `translateY(${(1 - title) * 16}px)`}}>
				<Img src={staticFile('v7/plates/wordmark.png')} style={{width: 1200, height: 420, imageRendering: 'pixelated'}} />
			</div>
			<div style={{position: 'absolute', left: 0, right: 0, top: 450, textAlign: 'center', opacity: word, fontFamily: `${sans}, ${SCRIPTS.join(', ')}`,
				fontSize: 30, color: C.lavender, whiteSpace: 'pre'}}>{`◈   ${STRANGER[index]}   ◈`}</div>
			<div style={{position: 'absolute', left: 250, right: 250, top: 508, textAlign: 'center', fontFamily: serif, fontSize: 48, color: C.ink,
				opacity: at(t, [TITLE + 1.6, TITLE + 2.4], [0, 1]), textShadow: '0 2px 16px rgba(11,10,28,0.9)'}}>A world to discover. People to understand.</div>
			<div style={{position: 'absolute', left: 250, right: 250, top: 580, textAlign: 'center', fontFamily: sans, fontSize: 28, color: '#c7bfd7',
				opacity: at(t, [TITLE + 2.5, TITLE + 3.2], [0, 1]), textShadow: '0 2px 12px rgba(11,10,28,0.9)'}}>A narrative game about culture, connection and seeing beyond stereotypes.</div>
			<Black opacity={at(t, [0, 0.9], [1, 0]) + at(t, [16.2, 17.6], [0, 1])} />
		</AbsoluteFill>
	);
};
