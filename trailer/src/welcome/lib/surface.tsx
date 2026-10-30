// What every shot sits on: paper or night, with film grain and a vignette.
import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import {C, FPS, useFilm} from './core';

/** The paper: a seeded fibre texture, lit from the middle. */
export const Paper: React.FC<{light?: number; children?: React.ReactNode}> = ({light = 1, children}) => (
	<AbsoluteFill style={{background: C.paper}}>
		<AbsoluteFill style={{backgroundImage: `url(${staticFile('welcome/paper.png')})`, backgroundSize: '1024px 1024px'}} />
		<AbsoluteFill style={{background: `radial-gradient(ellipse 70% 60% at 50% 45%, rgba(255,255,255,${0.35 * light}), rgba(255,255,255,0) 70%)`}} />
		{children}
	</AbsoluteFill>
);

export const Night: React.FC<{color?: string; children?: React.ReactNode}> = ({color = C.night, children}) => (
	<AbsoluteFill style={{background: color}}>{children}</AbsoluteFill>
);

/** Film grain: six seeded plates, changed every second frame. */
export const Grain: React.FC<{opacity?: number}> = ({opacity = 0.16}) => {
	const t = useFilm();
	const plate = Math.floor(t * FPS / 2) % 6;
	const shift = (Math.floor(t * FPS / 2) * 137) % 512;
	return (
		<AbsoluteFill style={{pointerEvents: 'none', mixBlendMode: 'overlay', opacity,
			backgroundImage: `url(${staticFile(`welcome/grain${plate}.png`)})`, backgroundSize: '512px 512px',
			backgroundPosition: `${shift}px ${(shift * 3) % 512}px`}} />
	);
};

export const Vignette: React.FC<{strength?: number; color?: string}> = ({strength = 0.35, color = '0,0,0'}) => (
	<AbsoluteFill style={{pointerEvents: 'none',
		background: `radial-gradient(ellipse 85% 75% at 50% 50%, rgba(${color},0) 55%, rgba(${color},${strength}) 100%)`}} />
);

/** A hard full-frame colour for `frames` frames from `from`. */
export const Flash: React.FC<{from: number; frames?: number; color: string; blend?: React.CSSProperties['mixBlendMode']}> = ({from, frames = 2, color, blend}) => {
	const t = useFilm();
	const on = t >= from && t < from + frames / FPS;
	return on ? <AbsoluteFill style={{background: color, mixBlendMode: blend}} /> : null;
};

/** A still of a picture, for the few raster pieces (the wordmark). */
export const Pixelated: React.FC<{src: string; style?: React.CSSProperties}> = ({src, style}) => (
	<Img src={staticFile(src)} style={{imageRendering: 'pixelated', ...style}} />
);
