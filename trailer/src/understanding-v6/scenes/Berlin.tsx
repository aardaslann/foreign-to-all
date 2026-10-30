// Berlin: unfamiliar words, a word that begins a conversation, the notebook,
// and asking for it.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {T, at, ease, move, voice, useSeconds, Bubble, Caption, Item, Person, TopShade, Vignette, Wash, World, type Seg} from '../lib/core';
import {Notebook, RepCard} from '../lib/fx';
import {LUKAS} from './Opening';

const local = (id: string, scene: keyof typeof T.scenes) => {
	const v = voice(id);
	return {from: v.at - T.scenes[scene][0], to: v.at - T.scenes[scene][0] + v.dur};
};
const HEAD = 150;   // plate pixels from feet to the top of a head, at u = 5.6

// ── Unfamiliar words. Unwritten rules. ───────────────────────────────────────
const MITTE = {a: {x: 1010, y: 710}, b: {x: 1118, y: 710}, alien: {x: 812, y: 716}};

export const Unfamiliar: React.FC = () => {
	const t = useSeconds();
	const a = local('crowd-a', 'unfamiliar');
	const b = local('crowd-b', 'unfamiliar');
	const bell = 28.2 - T.scenes.unfamiliar[0];
	const startled = t > bell - 0.05 && t < bell + 0.9;
	return (
		<AbsoluteFill>
			<World plate="mitte" cam={move(t, 0, 7.3, {x: 930, y: 500, z: 1.42}, {x: 960, y: 514, z: 1.52})} grade="brightness(0.93) saturate(0.95) contrast(1.03)">
				<Person who="crowd0" act={t > a.from && t < a.to + 0.2 ? 'talk' : 'watch'} x={MITTE.a.x} y={MITTE.a.y} phase={3} />
				<Person who="crowd1" act={startled ? 'look' : t > b.from && t < b.to + 0.2 ? 'talk' : 'look'} x={MITTE.b.x} y={MITTE.b.y} phase={8} />
				<Person who="alien" act={startled ? 'recoil' : t > 2.6 ? 'look' : 'watch'} x={MITTE.alien.x + (startled ? -14 : 0)} y={MITTE.alien.y} />
				<Bubble x={MITTE.a.x} y={MITTE.a.y - HEAD} t={t} from={a.from} to={a.to + 0.5} side="left" segs={[{text: 'Kalt heute.', kind: 'glyph'}]} />
				<Bubble x={MITTE.b.x} y={MITTE.b.y - HEAD} t={t} from={b.from} to={b.to + 0.4} side="right" segs={[{text: 'Der Bus kommt nicht.', kind: 'glyph'}]} />
				<Bubble x={MITTE.alien.x} y={MITTE.alien.y - HEAD} t={t} from={2.85} to={3.85} size={38} segs={[{text: '?'}]} />
				<Bubble x={MITTE.b.x} y={MITTE.b.y - HEAD} t={t} from={bell} to={bell + 1.0} side="right" size={38} segs={[{text: '!!', kind: 'amber'}]} />
			</World>
			<TopShade opacity={0.95} />
			<Caption lines={['Unfamiliar words.', 'Unwritten rules.']} t={t} from={4.3} to={7.15} />
			<Vignette />
		</AbsoluteFill>
	);
};

// ── Brot ─────────────────────────────────────────────────────────────────────
const STALL = {alien: {x: 896, y: 884}, bread: {x: 985, y: 640}};
const DAY = 'brightness(0.98) saturate(1.04) contrast(1.02)';

export const Brot: React.FC = () => {
	const t = useSeconds();
	const line = local('lukas-brot', 'brot');
	const decodeAt = 34.12 - T.scenes.brot[0];
	const segs: Seg[] = [{text: 'Ich habe auch heute frisches ', kind: 'glyph'}, {text: 'Brot', kind: 'decode', at: decodeAt}, {text: '.'}];
	const bread = at(t, [decodeAt + 0.1, decodeAt + 0.5], [0, 1], ease.out);
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 7.3, {x: 1010, y: 640, z: 1.72}, {x: 985, y: 655, z: 1.86})} grade={DAY}>
				<Person who="lukas" act={t < line.from ? 'stand' : t < decodeAt ? 'talk' : 'offer'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={t < decodeAt ? 'watch' : 'look'} x={STALL.alien.x} y={STALL.alien.y} />
				<Item id="bread" x={STALL.bread.x} y={STALL.bread.y - 6 * Math.sin(t * 3)} size={40}
					style={{opacity: bread, scale: `${0.6 + 0.4 * bread}`, filter: `drop-shadow(0 0 ${6 * bread}px rgba(255,214,140,0.9))`}} />
				<Bubble x={LUKAS.x} y={LUKAS.y - HEAD} t={t} from={line.from} to={decodeAt + 1.6} side="left" segs={segs} />
			</World>
			<Wash color="linear-gradient(180deg, rgba(255,214,170,0.35), rgba(255,240,220,0) 60%)" blend="soft-light" />
			<TopShade />
			<Caption lines={['A word begins', 'a conversation.']} t={t} from={3.75} to={7.15} />
			<Vignette />
		</AbsoluteFill>
	);
};

// ── The notebook ─────────────────────────────────────────────────────────────
export const Journal: React.FC = () => {
	const t = useSeconds();
	const start = T.scenes.journal[0];
	const focus = at(t, [0, 0.5], [0, 1], ease.inOut);   // rack focus off the street, onto the page
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={{x: 990, y: 655, z: 1.86 + 0.06 * focus}}
				grade={`blur(${16 * focus}px) brightness(${1 - 0.58 * focus}) saturate(${1 - 0.2 * focus})`} />
			<Wash color="rgba(20,14,40,0.45)" blend="multiply" />
			<Notebook t={t} word="Brot" meaning="bread" language="GERMAN · NOUN" item="bread"
				wordAt={0.35} meaningAt={40.3 - start} playAt={voice('lukas-word').at - start} noteAt={2.35} end={5.45} />
			<Caption lines={['Listen. Notice. Try.']} t={t} from={2.95} to={5.4} y={880} size={60} />
			<Vignette strength={0.6} />
		</AbsoluteFill>
	);
};

// ── Brot, bitte? ─────────────────────────────────────────────────────────────
export const Bitte: React.FC = () => {
	const t = useSeconds();
	const greet = local('lukas-morgen', 'bitte');
	const ask = 2.55;
	const give = 3.35;
	const k = at(t, [give, give + 0.55], [0, 1], ease.inOut);
	const bx = STALL.bread.x + (STALL.alien.x + 26 - STALL.bread.x) * k;
	const by = STALL.bread.y + (STALL.alien.y - 52 - STALL.bread.y) * k - Math.sin(Math.PI * k) * 60;
	const focus = at(t, [0, 0.45], [1, 0], ease.inOut);   // and back onto the street
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 5.5, {x: 960, y: 690, z: 1.95}, {x: 950, y: 700, z: 2.05})}
				grade={`blur(${12 * focus}px) brightness(${1.02 - 0.5 * focus}) saturate(1.06)`}>
				<Person who="lukas" act={t < greet.to ? 'talk' : t < give + 0.8 ? 'offer' : 'nod'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={t < ask ? 'watch' : t < give + 0.3 ? 'talk' : 'take'} x={STALL.alien.x} y={STALL.alien.y} />
				<Item id="bread" x={bx} y={by} size={40} style={{opacity: at(t, [0.2, 0.6], [0, 1])}} />
				<Bubble x={LUKAS.x} y={LUKAS.y - HEAD} t={t} from={greet.from} to={greet.to + 0.3} side="left"
					segs={[{text: 'Guten Morgen! Kann ich Ihnen helfen?', kind: 'glyph'}]} />
				<Bubble x={STALL.alien.x} y={STALL.alien.y - HEAD} t={t} from={ask} to={give + 1.0} side="right" size={34}
					segs={[{text: 'Brot', kind: 'amber'}, {text: ', bitte?'}]} typed={{from: ask + 0.05, cps: 16}} />
			</World>
			<Wash color="linear-gradient(180deg, rgba(255,220,180,0.3), rgba(255,240,220,0) 60%)" blend="soft-light" />
			<RepCard t={t} from={48.45 - T.scenes.bitte[0]} to={5.35} who="lukas" name="LUKAS" delta="+2" line="He understood you." />
			<Vignette />
		</AbsoluteFill>
	);
};
