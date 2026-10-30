// Foreign to All — "Welcome". A kinetic-type film of the game's message, made
// only from its own pixels (glyphs, items, people, wordmark) and cut to an
// original R&B track. One composition, rendered 9:16 and 16:9.
import React from 'react';
import {AbsoluteFill, staticFile} from 'remotion';
import {Audio} from '@remotion/media';
import {cue, FilmClock, Shot, T, useFilm} from './lib/core';
import {Grain} from './lib/surface';
import {InkDefs} from './lib/ink';
import {HeatDefs} from './lib/pixel';
import {NotYet, RedCard, SmallLine, Track} from './scenes/Opening';
import {Burst, Question} from './scenes/Question';
import {Answer, Ring} from './scenes/Answer';
import {Cards} from './scenes/Cards';
import {Everyone, Label} from './scenes/Label';
import {Converge, Foreign, Letters, Title} from './scenes/Title';

export {DURATION} from './lib/core';

/** A short decaying shake on the film's hits: the slam, the drop, the ink ball, the tag torn away, the wordmark. */
const Camera: React.FC<{children: React.ReactNode}> = ({children}) => {
	const t = useFilm();
	const hits = [0, cue('burst'), cue('inkball') + 0.16, cue('inkball') + 0.32, cue('life'), cue('snap')];
	const [x, y] = hits.reduce(([ax, ay], h) => {
		const dt = t - h;
		if (dt < 0 || dt > 0.4) return [ax, ay];
		const k = Math.exp(-dt * 11) * 16;
		return [ax + Math.sin(dt * 83) * k, ay + Math.cos(dt * 67) * k * 0.7];
	}, [0, 0]);
	return <AbsoluteFill style={{translate: `${x}px ${y}px`, scale: x || y ? '1.02' : '1'}}>{children}</AbsoluteFill>;
};

/** `soundtrack`: "mix" (music, voices, sound) or "nomusic" (voices and sound only, for laying a TikTok sound over it). */
export const Welcome: React.FC<{soundtrack?: 'mix' | 'nomusic'}> = ({soundtrack = 'mix'}) => (
	<FilmClock>
		<AbsoluteFill style={{background: '#000'}}>
			<InkDefs />
			<HeatDefs />
			<Camera>
				{/* Act I — you can't read this */}
				<Shot name="red card" from={0} to={cue('track1')}><RedCard /></Shot>
				<Shot name="track" from={cue('track1')} to={cue('small')}><Track /></Shot>
				<Shot name="welcome" from={cue('small')} to={cue('notyet')}><SmallLine /></Shot>
				<Shot name="not yet" from={cue('notyet')} to={cue('question')}><NotYet /></Shot>
				{/* Act II — the question, the drop, the answer */}
				<Shot name="question" from={cue('question')} to={cue('burst')}><Question /></Shot>
				<Shot name="burst" from={cue('burst')} to={cue('answer')}><Burst /></Shot>
				<Shot name="answer" from={cue('answer')} to={cue('ring')}><Answer /></Shot>
				<Shot name="ring" from={cue('ring')} to={cue('listen')}><Ring /></Shot>
				<Shot name="listen notice try" from={cue('listen')} to={cue('label')}><Cards /></Shot>
				{/* Act III — the label, and the life behind it */}
				<Shot name="label" from={cue('label')} to={cue('strobe')}><Label /></Shot>
				<Shot name="everyone" from={cue('strobe')} to={cue('foreign')}><Everyone /></Shot>
				{/* Act IV — foreign, and understanding */}
				<Shot name="foreign" from={cue('foreign')} to={cue('letters')}><Foreign /></Shot>
				<Shot name="letters" from={cue('letters')} to={cue('converge')}><Letters /></Shot>
				<Shot name="converge" from={cue('converge')} to={cue('snap')}><Converge /></Shot>
				<Shot name="title" from={cue('snap')} to={T.duration}><Title /></Shot>
			</Camera>
			<Grain />
			<Audio src={staticFile(`welcome/${soundtrack}.wav`)} />
		</AbsoluteFill>
	</FilmClock>
);
