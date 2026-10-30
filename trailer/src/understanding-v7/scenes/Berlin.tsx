// Berlin: words he cannot read yet, one he can, the journal, and asking for it.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {P} from '../../lib/palette';
import {C, at, local, move, mono, sans, serif, typedAt, voice, useSeconds, Bubble, Item, Person, TopShade, Wash, World, type Seg} from '../lib/core';
import {LUKAS} from './Opening';

const HEAD = 150;   // plate pixels from feet to just above a head, at u = 5.6
const spoken = (id: string, sceneId: Parameters<typeof local>[0]) => {
	const v = voice(id);
	return {from: local(sceneId, v.at), to: local(sceneId, v.at + v.dur)};
};
const during = (t: number, w: {from: number; to: number}) => t > w.from - 0.05 && t < w.to + 0.15;
const DAY = 'brightness(0.97) saturate(1.02)';
const MORNING = 'linear-gradient(180deg, rgba(255,214,170,0.32), rgba(255,240,220,0) 60%)';

// ── Unfamiliar words. Unwritten rules. ───────────────────────────────────────
const MITTE = {a: {x: 1010, y: 712}, b: {x: 1118, y: 712}, alien: {x: 812, y: 718}};

export const Unfamiliar: React.FC = () => {
	const t = useSeconds();
	const a = spoken('crowd-a', 'unfamiliar');
	const b = spoken('crowd-b', 'unfamiliar');
	const bell = local('unfamiliar', 28.4);
	const startled = t > bell - 0.05 && t < bell + 0.9;
	const walkIn = at(t, [0, 1.3], [0, 1]);
	return (
		<AbsoluteFill>
			<World plate="mitte" cam={move(t, 0, 6.25, {x: 905, y: 500, z: 1.45}, {x: 940, y: 512, z: 1.52})} grade={DAY}>
				<Person who="crowd0" act={during(t, a) ? 'talk' : startled ? 'look' : 'watch'} x={MITTE.a.x} y={MITTE.a.y} phase={3} />
				<Person who="crowd1" act={during(t, b) ? 'talk' : startled ? 'look' : 'watch'} x={MITTE.b.x} y={MITTE.b.y} phase={8} />
				<Person who="alien" act={startled ? 'recoil' : t < 1.3 ? 'walk' : t > 2.4 ? 'look' : 'watch'}
					x={MITTE.alien.x - 120 * (1 - walkIn) - (startled ? 12 : 0)} y={MITTE.alien.y} />
				<Bubble x={MITTE.a.x} y={MITTE.a.y - HEAD} t={t} from={a.from} to={a.to + 0.6} side="left" segs={[{text: 'Kalt heute.', kind: 'glyph'}]} />
				<Bubble x={MITTE.b.x} y={MITTE.b.y - HEAD} t={t} from={b.from} to={b.to + 0.5} side="right" segs={[{text: 'Der Bus kommt nicht.', kind: 'glyph'}]} />
				<Bubble x={MITTE.alien.x} y={MITTE.alien.y - HEAD} t={t} from={2.6} to={3.9} size={36} segs={[{text: '?'}]} />
			</World>
			<Wash color={MORNING} blend="soft-light" />
			<TopShade opacity={0.9} />
		</AbsoluteFill>
	);
};

// ── A word begins a conversation ─────────────────────────────────────────────
const STALL = {alien: {x: 896, y: 884}, bread: {x: 985, y: 640}};

export const Brot: React.FC = () => {
	const t = useSeconds();
	const line = spoken('lukas-brot', 'brot');
	const decodeAt = local('brot', 32.55);
	const segs: Seg[] = [{text: 'Ich habe auch heute frisches ', kind: 'glyph'}, {text: 'Brot', kind: 'decode', at: decodeAt}, {text: '.'}];
	const bread = at(t, [decodeAt + 0.1, decodeAt + 0.7], [0, 1]);
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 6.25, {x: 1010, y: 596, z: 1.72}, {x: 990, y: 606, z: 1.82})} grade={DAY}>
				<Person who="lukas" act={t < line.from ? 'stand' : t < line.to + 0.1 ? 'talk' : 'offer'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={t < decodeAt ? 'watch' : 'look'} x={STALL.alien.x} y={STALL.alien.y} />
				<Item id="bread" x={STALL.bread.x} y={STALL.bread.y} size={40}
					style={{filter: `drop-shadow(0 0 ${7 * bread}px rgba(242,197,110,${0.9 * bread}))`, scale: `${1 + 0.12 * bread}`}} />
				<Bubble x={LUKAS.x} y={LUKAS.y - HEAD} t={t} from={line.from} to={decodeAt + 1.2} side="left" segs={segs} />
			</World>
			<Wash color={MORNING} blend="soft-light" />
			<TopShade />
		</AbsoluteFill>
	);
};

// ── The journal: revision 5's page, with the game's bread on it ─────────────
export const Journal: React.FC = () => {
	const t = useSeconds();
	const focus = at(t, [0, 0.55], [0, 1]);
	const letters = [0.5, 0.8, 1.1, 1.4].filter((x) => x <= t).length;
	const meaning = at(t, [local('journal', 38.2), local('journal', 38.2) + 0.6], [0, 1]);
	const play = at(t, [local('journal', 38.7), local('journal', 38.75)], [0, 1]) * at(t, [local('journal', 39.3), local('journal', 39.7)], [1, 0]);
	const note = at(t, [2.9, 3.5], [0, 1]);
	const show = at(t, [0.1, 0.6], [0, 1]) * at(t, [5.85, 6.25], [1, 0]);
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={{x: 990, y: 655, z: 1.86 + 0.05 * focus}}
				grade={`blur(${14 * focus}px) brightness(${1 - 0.6 * focus}) saturate(${1 - 0.25 * focus})`} />
			<AbsoluteFill style={{background: 'rgba(11,10,28,0.35)'}} />
			<div style={{position: 'absolute', left: 270, top: 330, width: 1380, height: 550, background: P.panel, border: `3px solid ${P.border}`,
				opacity: show, transform: `translateY(${(1 - show) * 14}px)`, boxShadow: '0 30px 70px rgba(0,0,0,0.5)'}}>
				<div style={{position: 'absolute', left: 94, top: 66, color: P.inkMuted, fontFamily: mono, fontSize: 25, letterSpacing: 3}}>JOURNAL · A WORD TO KEEP</div>
				<div style={{position: 'absolute', left: 90, top: 144, color: C.ink, fontFamily: serif, fontSize: 132}}>
					{'Brot'.slice(0, letters)}
					<span style={{color: C.lavender, fontSize: 88, opacity: t < 1.9 && Math.floor(t * 4) % 2 === 0 ? 1 : 0}}>▏</span>
				</div>
				<div style={{position: 'absolute', left: 430, top: 196, width: 54, height: 54, borderRadius: '50%', border: `3px solid ${C.gold}`, opacity: meaning,
					background: `rgba(232,194,92,${0.12 + 0.45 * play})`, boxShadow: `0 0 ${30 * play}px rgba(232,194,92,${0.8 * play})`,
					display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
					<div style={{width: 0, height: 0, borderTop: '10px solid transparent', borderBottom: '10px solid transparent', borderLeft: `17px solid ${C.gold}`, marginLeft: 5}} />
				</div>
				<div style={{position: 'absolute', left: 100, top: 330, color: C.gold, fontFamily: serif, fontSize: 54, opacity: meaning}}>bread</div>
				<div style={{position: 'absolute', left: 100, top: 436, color: P.inkMuted, fontFamily: sans, fontSize: 31, opacity: note}}>Next time, you can ask.</div>
				<div style={{position: 'absolute', left: 682, top: 76, width: 3, height: 390, background: P.border, opacity: 0.5}} />
				<div style={{opacity: at(t, [local('journal', 38.0), local('journal', 38.5)], [0, 1])}}>
					<Item id="bread" x={1025} y={285} size={260} style={{filter: 'drop-shadow(0 12px 0 rgba(0,0,0,0.25))'}} />
				</div>
			</div>
		</AbsoluteFill>
	);
};

// ── Brot, bitte? ─────────────────────────────────────────────────────────────
export const Bitte: React.FC = () => {
	const t = useSeconds();
	const greet = spoken('lukas-morgen', 'bitte');
	const ask = typedAt('ask');
	const askFrom = local('bitte', ask.at);
	const give = local('bitte', 47.0);
	const k = at(t, [give, give + 0.6], [0, 1]);
	const bx = STALL.bread.x + (STALL.alien.x + 18 - STALL.bread.x) * k;
	const by = STALL.bread.y + (STALL.alien.y - 52 - STALL.bread.y) * k - Math.sin(Math.PI * k) * 60;
	const focus = at(t, [0, 0.45], [1, 0]);
	return (
		<AbsoluteFill>
			<World plate="kiez" cam={move(t, 0, 6.25, {x: 960, y: 690, z: 1.95}, {x: 950, y: 700, z: 2.05})}
				grade={`blur(${12 * focus}px) brightness(${1 - 0.5 * focus}) saturate(1.02)`}>
				<Person who="lukas" act={during(t, greet) ? 'talk' : t < give ? 'watch' : t < give + 0.9 ? 'offer' : 'nod'} x={LUKAS.x} y={LUKAS.y} clipY={LUKAS.counter} />
				<Person who="alien" act={t < askFrom ? 'watch' : t < give ? 'talk' : t < give + 1.0 ? 'take' : 'look'} x={STALL.alien.x} y={STALL.alien.y} />
				<Item id="bread" x={bx} y={by} size={40} />
				<Bubble x={LUKAS.x} y={LUKAS.y - HEAD} t={t} from={greet.from} to={greet.to + 0.4} side="left"
					segs={[{text: 'Guten Morgen! Kann ich Ihnen helfen?', kind: 'glyph'}]} />
				<Bubble x={STALL.alien.x} y={STALL.alien.y - HEAD} t={t} from={askFrom} to={give + 0.7} side="right" size={38}
					segs={[{text: 'Brot', kind: 'amber'}, {text: ', bitte?'}]} typed={{from: askFrom, cps: ask.cps}} />
				<Bubble x={LUKAS.x} y={LUKAS.y - HEAD} t={t} from={give + 0.2} to={6.1} side="left" size={38} segs={[{text: 'Bitte!', kind: 'amber'}]} />
			</World>
			<Wash color={MORNING} blend="soft-light" />
			<TopShade opacity={0.5} />
		</AbsoluteFill>
	);
};
