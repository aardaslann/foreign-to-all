// Every Steam store and library image, as Remotion stills. Sizes follow
// partner.steamgames.com/doc/store/assets (checked 2026-10-11). Positions are
// output pixels, worked out from the plate's lit windows and its ledge.
import React from 'react';
import {AbsoluteFill, Still} from 'remotion';
import {KeyArt, type KeyArtProps, Wordmark} from './KeyArt';

type Capsule = {id: string; width: number; height: number; props: KeyArtProps};

export const CAPSULES: Capsule[] = [
	{id: 'SteamHeader', width: 920, height: 430, props: {
		logo: {cx: 460, cy: 116, scale: 2.4},
		alien: {x: 655, u: 4.4},
		bubbles: [
			{x: 92, y: 214, glyphs: [3, 0, 5], size: 19},
			{x: 830, y: 196, glyphs: [6, 2, 7], size: 19, tail: 'right'},
			{x: 262, y: 290, glyphs: [1, 4, 7, 2], size: 16, word: 2},
		],
	}},
	{id: 'SteamSmall', width: 462, height: 174, props: {
		logo: {cx: 231, cy: 88, scale: 1.75, heavy: true},
		darken: 0.38, blur: 1.2, skyShade: 0.2,
	}},
	{id: 'SteamMain', width: 1232, height: 706, props: {
		logo: {cx: 616, cy: 186, scale: 3.5},
		alien: {x: 852, u: 6},
		bubbles: [
			{x: 128, y: 344, glyphs: [3, 0, 5, 1], size: 27},
			{x: 1100, y: 352, glyphs: [6, 2, 7], size: 27, tail: 'right'},
			{x: 362, y: 448, glyphs: [1, 4, 7, 2], size: 22, word: 2},
		],
	}},
	{id: 'SteamVertical', width: 748, height: 896, props: {
		focus: 980,
		logo: {cx: 374, cy: 178, scale: 2.8},
		alien: {x: 404, u: 7.5},
		bubbles: [
			{x: 168, y: 520, glyphs: [3, 0, 5], size: 30},
			{x: 594, y: 452, glyphs: [6, 2, 7], size: 30, tail: 'right'},
			{x: 254, y: 652, glyphs: [1, 4, 7, 2], size: 24, word: 2},
		],
	}},
	{id: 'SteamLibraryCapsule', width: 600, height: 900, props: {
		focus: 980,
		logo: {cx: 300, cy: 168, scale: 2.25},
		alien: {x: 318, u: 7},
		bubbles: [
			{x: 136, y: 522, glyphs: [3, 0, 5], size: 27},
			{x: 470, y: 456, glyphs: [6, 2, 7], size: 27, tail: 'right'},
			{x: 196, y: 652, glyphs: [1, 4, 2], size: 22, word: 1},
		],
	}},
	{id: 'SteamLibraryHero', width: 3840, height: 1240, props: {
		alien: {x: 2250, u: 14},
		skyShade: 0.2,
		bubbles: [
			{x: 360, y: 196, glyphs: [3, 0, 5, 1], size: 58},
			{x: 3400, y: 262, glyphs: [6, 2, 7], size: 58, tail: 'right'},
			{x: 980, y: 446, glyphs: [1, 4, 7, 2], size: 48, word: 2},
			{x: 3010, y: 470, glyphs: [0, 6], size: 44, tail: 'right'},
		],
	}},
	{id: 'SteamPageBackground', width: 1438, height: 810, props: {
		plate: 'title', blur: 3, darken: 0.3, skyShade: 0,
	}},
];

/** The library logo: the wordmark alone on transparency, 1280 wide. */
const LibraryLogo: React.FC = () => (
	<AbsoluteFill>
		<Wordmark cx={640} cy={224} scale={5} glow={false} />
	</AbsoluteFill>
);

export const SteamStills: React.FC = () => (
	<>
		{CAPSULES.map((c) => (
			<Still key={c.id} id={c.id} component={KeyArt} width={c.width} height={c.height} defaultProps={c.props} />
		))}
		<Still id="SteamLibraryLogo" component={LibraryLogo} width={1280} height={448} />
	</>
);
