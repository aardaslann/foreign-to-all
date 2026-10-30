import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  interpolateColors,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFont } from "@remotion/google-fonts/PlusJakartaSans";
import { loadFont as loadGameFont } from "@remotion/google-fonts/OpenSans";
import { shuffledGlyphs } from "./glyphs";

const { fontFamily } = loadFont();
const game = loadGameFont();

export const FONT = `${fontFamily}, "Segoe UI", system-ui, sans-serif`;
/** Godot 4's default face — literally the font the game renders in. */
export const GAME_FONT = `${game.fontFamily}, "Segoe UI", system-ui, sans-serif`;

/* ── palette ───────────────────────────────────────────────────────────────
 * Every value below is lifted from art/world/foreigntoall_world.gpl or from
 * scenes/dialogue/DialogueBox.gd. Nothing here is invented.
 */
export const P = {
  void: "#0b0a1c", // sky void — the engine's clear colour
  deep: "#0d0b1a", // ui panel dark
  panel: "#141126", // ui panel
  mid: "#16132e", // sky mid
  dusk: "#2c1a34", // sky dusk
  facade: "#1c1730", // facade wall
  border: "#4c4482", // ui border
  borderHi: "#6b63a6", // ui border hi
  text: "#e8e4f4", // ui text
  muted: "#8a84b8", // ui muted
  amber: "#e8c25c", // window lit
  glow: "#f2c56e", // warm glow
  mint: "#46e8c0", // alien mint
  ubahn: "#1c4a9c", // U-Bahn blue
  green: "#2ca858", // apotheke green
  /** Lifted off horizon crest #7a4430 so it stays legible as type on dark. */
  ember: "#e0705a",
  /** Title-screen menu text — UIStyles.style_title_btn. */
  menu: "#c7c2fa",
} as const;

/** DialogueBox.gd:496-511, verbatim. */
export const TIER = {
  unknown: "#e8e4ff",
  glimpsed: "#b8b4f0",
  partial: "#d8d4ff",
  partialBg: "#35359a",
  known: "#f0eeff",
} as const;

export const S = (sec: number) => Math.round(sec * 30);
export const OUT = Easing.bezier(0.16, 1, 0.3, 1);

/**
 * Frames a viewer needs to read `n` words: about a third of a second to
 * notice the text, then a fifth of a second per word. Deliberately tight —
 * a three-word line does not need two seconds.
 */
export const read = (n: number) => Math.max(24, Math.round((0.3 + 0.2 * n) * 30));

/** Word count of a plain string, so delays chain off the real copy. */
export const words = (s: string) => s.trim().split(/\s+/).length;

/** 0→1, eased, delayed. */
export const r = (f: number, delay = 0, dur = 16) =>
  interpolate(f - delay, [0, dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: OUT,
  });

/* ── the ground ────────────────────────────────────────────────────────────
 * Two layers. The floor is a near-black journey through the game's own night
 * values; over it sits a wide soft glow whose colour carries the emotional
 * temperature — violet when nobody understands anybody, amber when they do.
 * The background never cuts.
 */
const STOPS = [0, 380, 480, 1100, 1200, 1540, 1640, 1960, 2060, 2760, 2830, 3090];

const FLOOR = [
  P.void,
  P.void, // the failures — coldest
  P.mid,
  P.mid, // words
  P.dusk,
  P.dusk, // culture — warm
  P.facade,
  P.facade, // the stereotype — flat
  P.deep,
  P.deep, // inside the game — deepest
  P.dusk,
  P.dusk, // understanding
];

const LIGHT = [
  "#2a2450",
  "#2a2450", // cold violet
  "#332b5c",
  "#332b5c", // violet
  "#5f3c26",
  "#5f3c26", // amber warmth
  "#1e2440",
  "#1e2440", // cold blue
  "#251e40",
  "#251e40", // deep violet
  "#63421f",
  "#63421f", // gold
];

export const Ground: React.FC = () => {
  const f = useCurrentFrame();
  const floor = interpolateColors(f, STOPS, FLOOR);
  const light = interpolateColors(f, STOPS, LIGHT);
  const drift = Math.sin(f / 240) * 3;
  return (
    <AbsoluteFill style={{ background: floor }}>
      <AbsoluteFill
        style={{
          background: `radial-gradient(ellipse 78% 72% at ${50 + drift}% 46%, ${light}, transparent 72%)`,
        }}
      />
    </AbsoluteFill>
  );
};

/* ── actors ────────────────────────────────────────────────────────────────
 * NPC sheets are 192x128 — 32px cells, rows down/up/right/left,
 * cols = idle x2 then walk x4.
 */
const ROWS = { down: 0, up: 1, right: 2, left: 3 } as const;

export const Actor: React.FC<{
  who: string;
  dir?: keyof typeof ROWS;
  anim?: "idle" | "walk";
  x: number;
  y?: number;
  scale?: number;
  opacity?: number;
  bob?: boolean;
  grey?: boolean;
}> = ({ who, dir = "down", anim = "idle", x, y = 500, scale = 10, opacity = 1, bob, grey }) => {
  const f = useCurrentFrame();
  const fps = anim === "idle" ? 2 : 8;
  const count = anim === "idle" ? 2 : 4;
  const first = anim === "idle" ? 0 : 2;
  const col = first + (Math.floor((f / 30) * fps) % count);
  const size = 32 * scale;
  const lift = bob ? Math.sin(f / 5) * 6 : 0;

  return (
    <>
      {/* a pool of light rather than a shadow — nothing casts dark on dark */}
      <div
        style={{
          position: "absolute",
          left: x - size * 0.42,
          top: y + size - 36,
          width: size * 0.84,
          height: 48,
          borderRadius: "50%",
          background: "radial-gradient(ellipse, rgba(242,197,110,0.17), transparent 70%)",
          opacity,
        }}
      />
      <div
        style={{
          position: "absolute",
          left: x - size / 2,
          top: y + lift,
          width: size,
          height: size,
          opacity,
          backgroundImage: `url(${staticFile(`art/npcs/${who}_sheet.png`)})`,
          backgroundRepeat: "no-repeat",
          backgroundSize: `${192 * scale}px ${128 * scale}px`,
          backgroundPosition: `-${col * 32 * scale}px -${ROWS[dir] * 32 * scale}px`,
          imageRendering: "pixelated",
          filter: grey ? "grayscale(1) brightness(0.55) contrast(0.6)" : undefined,
        }}
      />
    </>
  );
};

/* ── speech ────────────────────────────────────────────────────────────────
 * The game's own dialogue box, rounded and popped on a spring:
 * panel #141126, border #4c4482, text #e8e4f4.
 */
export const Bubble: React.FC<{
  tailX: number;
  tailY: number;
  side?: "left" | "right";
  delay?: number;
  children: React.ReactNode;
  tone?: "panel" | "amber";
  size?: number;
  thought?: boolean;
  hold?: number;
}> = ({
  tailX,
  tailY,
  side = "right",
  delay = 0,
  children,
  tone = "panel",
  size = 40,
  thought,
  hold,
}) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: f - delay, fps, config: { damping: 13, stiffness: 190, mass: 0.7 } });
  const gone =
    hold === undefined
      ? 1
      : interpolate(f, [hold, hold + 8], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });

  const amber = tone === "amber";
  const bg = amber ? P.amber : P.panel;
  const fg = amber ? P.void : P.text;
  const edge = amber ? P.glow : P.border;
  const INSET = 52;

  const body: React.CSSProperties = {
    position: "absolute",
    bottom: 0,
    background: bg,
    color: fg,
    border: `2px solid ${edge}`,
    borderRadius: thought ? 46 : 28,
    padding: "22px 36px",
    fontFamily: FONT,
    fontWeight: 700,
    fontSize: size,
    letterSpacing: "-0.01em",
    whiteSpace: "nowrap",
    boxShadow: "0 20px 52px rgba(4,2,12,0.6)",
  };
  if (side === "right") body.left = -INSET;
  else body.right = -INSET;

  const dot = (d: number, w: number): React.CSSProperties => ({
    position: "absolute",
    bottom: -d,
    [side === "right" ? "left" : "right"]: INSET - (w === 20 ? 10 : 26),
    width: w,
    height: w,
    borderRadius: "50%",
    background: bg,
    border: `2px solid ${edge}`,
  });

  const tail: React.CSSProperties = {
    position: "absolute",
    bottom: -12,
    width: 24,
    height: 24,
    background: bg,
    borderRight: `2px solid ${edge}`,
    borderBottom: `2px solid ${edge}`,
    borderRadius: 5,
    transform: "rotate(45deg)",
  };
  if (side === "right") tail.left = INSET - 12;
  else tail.right = INSET - 12;

  return (
    <div
      style={{
        position: "absolute",
        left: tailX,
        top: tailY,
        width: 0,
        height: 0,
        transform: `scale(${s})`,
        transformOrigin: "0px 0px",
        opacity: gone,
      }}
    >
      <div style={body}>
        {children}
        {!thought ? <div style={tail} /> : null}
        {thought ? (
          <>
            <div style={dot(24, 20)} />
            <div style={dot(48, 11)} />
          </>
        ) : null}
      </div>
    </div>
  );
};

/* ── type ──────────────────────────────────────────────────────────────── */

export const Punch: React.FC<{
  lines: string[];
  delay?: number;
  size?: number;
  color?: string;
  align?: "center" | "left";
  stagger?: number;
  y?: number;
  accentIndex?: number;
  accent?: string;
}> = ({
  lines,
  delay = 0,
  size = 104,
  color = P.text,
  align = "center",
  stagger = 11,
  y = 0,
  accentIndex = -1,
  accent = P.amber,
}) => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        alignItems: align === "center" ? "center" : "flex-start",
        justifyContent: "center",
        paddingLeft: align === "left" ? 160 : 60,
        paddingRight: 60,
        transform: `translateY(${y}px)`,
      }}
    >
      {lines.map((l, i) => {
        const t = r(f, delay + i * stagger, 14);
        return (
          <div key={i} style={{ overflow: "hidden", paddingBottom: 10 }}>
            <div
              style={{
                fontFamily: FONT,
                fontWeight: 800,
                fontSize: size,
                lineHeight: 1.08,
                letterSpacing: "-0.035em",
                color: i === accentIndex ? accent : color,
                textAlign: align,
                transform: `translateY(${(1 - t) * size * 0.6}px)`,
                opacity: interpolate(t, [0, 0.3], [0, 1], { extrapolateRight: "clamp" }),
              }}
            >
              {l}
            </div>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

export const Caption: React.FC<{ children: React.ReactNode; delay?: number; y?: number }> = ({
  children,
  delay = 0,
  y = 926,
}) => {
  const f = useCurrentFrame();
  const t = r(f, delay, 14);
  return (
    <div
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        top: y,
        textAlign: "center",
        fontFamily: FONT,
        fontWeight: 600,
        fontSize: 38,
        color: P.muted,
        opacity: t,
        transform: `translateY(${(1 - t) * 14}px)`,
      }}
    >
      {children}
    </div>
  );
};

/**
 * Glyphs, alive. The game reshuffles an unknown word every 0.18s
 * (DialogueBox.gd ANIM_INTERVAL), so nothing you can't read holds still.
 * `settle` (0→1) slows the shuffle and then locks it to the real word.
 */
export const Glyphs: React.FC<{
  word: string;
  color?: string;
  spacing?: number;
  settle?: number;
}> = ({ word, color = TIER.unknown, spacing = 4, settle = 0 }) => {
  const f = useCurrentFrame();
  const rate = 5.4 + settle * 30;
  const step = Math.floor(f / rate);
  if (settle >= 1) return <span style={{ color, letterSpacing: spacing }}>{word}</span>;
  return <span style={{ color, letterSpacing: spacing }}>{shuffledGlyphs(word.length, step)}</span>;
};

/* ── the details that make a person ────────────────────────────────────── */
const PATHS: Record<string, React.ReactNode> = {
  house: <path d="M4 15 L16 5 L28 15 L28 27 L4 27 Z" />,
  cup: (
    <>
      <path d="M6 10 h16 v12 a8 8 0 0 1 -16 0 Z" />
      <path d="M22 13 h4 a4 4 0 0 1 0 8 h-4" fill="none" strokeWidth="3" />
    </>
  ),
  heart: (
    <path d="M16 27 C4 18 4 9 10 7 C14 5.5 16 9 16 11 C16 9 18 5.5 22 7 C28 9 28 18 16 27 Z" />
  ),
  note: (
    <>
      <circle cx="11" cy="24" r="5" />
      <path d="M14 24 V7 l12 -3 v17" fill="none" strokeWidth="3.5" />
    </>
  ),
  book: (
    <>
      <path d="M5 6 h10 v21 H5 Z" />
      <path d="M17 6 h10 v21 H17 Z" />
    </>
  ),
  bread: <path d="M3 19 a13 9 0 0 1 26 0 v4 a4 4 0 0 1 -4 4 h-18 a4 4 0 0 1 -4 -4 Z" />,
  sun: (
    <>
      <circle cx="16" cy="16" r="7" />
      <path
        d="M16 2 v4 M16 26 v4 M2 16 h4 M26 16 h4 M6 6 l3 3 M23 23 l3 3 M26 6 l-3 3 M9 23 l-3 3"
        fill="none"
        strokeWidth="3"
      />
    </>
  ),
};

export const DETAILS = ["house", "cup", "heart", "note", "book", "sun", "bread"];

export const DetailIcon: React.FC<{
  kind: string;
  x: number;
  y: number;
  size?: number;
  color?: string;
  opacity?: number;
  rot?: number;
}> = ({ kind, x, y, size = 62, color = P.text, opacity = 1, rot = 0 }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 32 32"
    style={{
      position: "absolute",
      left: x - size / 2,
      top: y - size / 2,
      opacity,
      transform: `rotate(${rot}deg)`,
      fill: color,
      stroke: color,
      strokeLinecap: "round",
      strokeLinejoin: "round",
    }}
  >
    {PATHS[kind]}
  </svg>
);
