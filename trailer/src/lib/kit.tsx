import React from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame } from "remotion";
import { loadFont as loadSerif } from "@remotion/google-fonts/Literata";
import { loadFont as loadMono } from "@remotion/google-fonts/IBMPlexMono";

const serif = loadSerif();
const mono = loadMono();

/** Literata: Google's reading face — editorial, full Turkish coverage. */
export const SERIF = `${serif.fontFamily}, Georgia, "Times New Roman", serif`;
/** IBM Plex Mono: the research-paper register, for labels and annotation. */
export const MONO = `${mono.fontFamily}, ui-monospace, Menlo, monospace`;

/* ── colour ────────────────────────────────────────────────────────────────
 * The film argues in light and experiences in dark. Paper is where the
 * thinking happens; ink-ground is where the viewer is put inside it.
 */
export const C = {
  paper: "#e9e7e0",
  paperDeep: "#dcd9d0",
  paperEdge: "#cbc7bc",
  ink: "#15171b",
  inkSoft: "#585b62",
  inkFaint: "#8b8d92",

  night: "#15171b",
  nightType: "#eae8e1",
  nightSoft: "#9a9ca3",
  nightEdge: "#2b2e35",

  /** Signal. İznik cobalt, carried over from the project's own palette. */
  cobalt: "#1c39a8",
  cobaltLit: "#8ba2ee",
  /** Used only where meaning fails. Never decorative. */
  vermilion: "#b5432f",
  vermilionLit: "#e2705a",
} as const;

/* ── grid ──────────────────────────────────────────────────────────────── */
export const GRID = { margin: 200, top: 132, bottom: 132 } as const;

/* ── type scale ────────────────────────────────────────────────────────── */
export const T = {
  display: 128,
  h1: 84,
  h2: 58,
  body: 38,
  small: 27,
  label: 19,
} as const;

/* ── motion ────────────────────────────────────────────────────────────────
 * One easing for entrances (expo-out: fast, then settles — reads expensive),
 * one for moves. Nothing linear, nothing bouncy.
 */
export const EXPO = Easing.bezier(0.16, 1, 0.3, 1);
export const SOFT = Easing.bezier(0.4, 0, 0.2, 1);

export const S = (sec: number) => Math.round(sec * 30);

/** 0→1 with expo easing, delayed. The one ramp everything is built on. */
export const ramp = (frame: number, delay = 0, dur = 24) =>
  interpolate(frame - delay, [0, dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EXPO,
  });

/* ── primitives ────────────────────────────────────────────────────────── */

/**
 * A masked wipe from the baseline up. Text arrives as if being set, not
 * faded in — the single biggest difference between designed motion and
 * default motion.
 */
export const Wipe: React.FC<{
  delay?: number;
  dur?: number;
  children: React.ReactNode;
  lift?: number;
}> = ({ delay = 0, dur = 26, children, lift = 22 }) => {
  const f = useCurrentFrame();
  const t = ramp(f, delay, dur);
  return (
    <div style={{ overflow: "hidden", paddingBottom: 6 }}>
      <div
        style={{
          transform: `translateY(${(1 - t) * lift}px)`,
          opacity: interpolate(t, [0, 0.35], [0, 1], { extrapolateRight: "clamp" }),
        }}
      >
        {children}
      </div>
    </div>
  );
};

/** A hairline that draws itself left to right. */
export const Rule: React.FC<{
  delay?: number;
  dur?: number;
  color?: string;
  width?: number | string;
  thickness?: number;
  margin?: string;
}> = ({ delay = 0, dur = 30, color = C.ink, width = "100%", thickness = 1, margin = "0" }) => {
  const f = useCurrentFrame();
  const t = ramp(f, delay, dur);
  return (
    <div style={{ width, margin, height: thickness }}>
      <div style={{ width: `${t * 100}%`, height: thickness, background: color }} />
    </div>
  );
};

/** Small uppercase mono label — the annotation voice of the film. */
export const Label: React.FC<{
  children: React.ReactNode;
  color?: string;
  delay?: number;
  size?: number;
}> = ({ children, color = C.inkFaint, delay = 0, size = T.label }) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        fontFamily: MONO,
        fontSize: size,
        fontWeight: 500,
        letterSpacing: "0.2em",
        textTransform: "uppercase",
        color,
        opacity: ramp(f, delay, 20),
      }}
    >
      {children}
    </div>
  );
};

/** A statement set in the serif, one line per array entry, staggered. */
export const Statement: React.FC<{
  lines: string[];
  size?: number;
  color?: string;
  delay?: number;
  stagger?: number;
  align?: "left" | "center";
  weight?: number;
  italic?: boolean;
  leading?: number;
}> = ({
  lines,
  size = T.h1,
  color = C.ink,
  delay = 0,
  stagger = 9,
  align = "left",
  weight = 400,
  italic = false,
  leading = 1.16,
}) => (
  <div style={{ textAlign: align }}>
    {lines.map((l, i) => (
      <Wipe key={i} delay={delay + i * stagger} lift={size * 0.24}>
        <div
          style={{
            fontFamily: SERIF,
            fontSize: size,
            fontWeight: weight,
            fontStyle: italic ? "italic" : "normal",
            lineHeight: leading,
            letterSpacing: size > 90 ? "-0.025em" : "-0.014em",
            color,
          }}
        >
          {l}
        </div>
      </Wipe>
    ))}
  </div>
);

/* ── page ──────────────────────────────────────────────────────────────── */

const PAPER_TEXTURE =
  "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='p'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23p)'/%3E%3C/svg%3E\")";

/**
 * The page. `night` inverts the whole system — the film uses that inversion
 * structurally: light is the argument, dark is the experience of it.
 */
export const Page: React.FC<{
  night?: boolean;
  children: React.ReactNode;
  section?: string;
  pad?: boolean;
  drift?: boolean;
}> = ({ night = false, children, section, pad = true, drift = true }) => {
  const f = useCurrentFrame();
  const scale = drift ? interpolate(f, [0, 220], [1, 1.015], { extrapolateRight: "clamp" }) : 1;
  return (
    <AbsoluteFill style={{ background: night ? C.night : C.paper, overflow: "hidden" }}>
      <AbsoluteFill style={{ transform: `scale(${scale})`, transformOrigin: "50% 50%" }}>
        <AbsoluteFill
          style={{
            paddingLeft: pad ? GRID.margin : 0,
            paddingRight: pad ? GRID.margin : 0,
            paddingTop: pad ? GRID.top : 0,
            paddingBottom: pad ? GRID.bottom : 0,
            justifyContent: "center",
          }}
        >
          {children}
        </AbsoluteFill>
      </AbsoluteFill>

      {section ? (
        <div
          style={{
            position: "absolute",
            left: GRID.margin,
            top: 62,
            fontFamily: MONO,
            fontSize: 16,
            letterSpacing: "0.3em",
            textTransform: "uppercase",
            color: night ? C.nightSoft : C.inkFaint,
            opacity: 0.62,
          }}
        >
          {section}
        </div>
      ) : null}

      {/* paper fibre — fine, not the usual overlay mush */}
      <AbsoluteFill
        style={{
          backgroundImage: PAPER_TEXTURE,
          opacity: night ? 0.04 : 0.06,
          mixBlendMode: night ? "screen" : "multiply",
          pointerEvents: "none",
        }}
      />
      <AbsoluteFill
        style={{
          pointerEvents: "none",
          background: night
            ? "radial-gradient(ellipse 85% 80% at 50% 50%, transparent 40%, rgba(0,0,0,0.45) 100%)"
            : "radial-gradient(ellipse 88% 84% at 50% 48%, transparent 45%, rgba(90,84,70,0.14) 100%)",
        }}
      />
    </AbsoluteFill>
  );
};
