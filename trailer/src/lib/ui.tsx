import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, Easing, staticFile } from "remotion";
import { P, TIER } from "./palette";
import { loadFont } from "@remotion/google-fonts/OpenSans";

const { fontFamily } = loadFont();
export const FONT = `${fontFamily}, "Segoe UI", system-ui, sans-serif`;
export const S = (sec: number) => Math.round(sec * 30);

const NOISE_SVG =
  "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='3'/%3E%3C/filter%3E%3Crect width='140' height='140' filter='url(%23n)'/%3E%3C/svg%3E\")";

/* ── atmosphere ────────────────────────────────────────────────────────── */

export const Vignette: React.FC<{ strength?: number }> = ({ strength = 0.8 }) => (
  <AbsoluteFill
    style={{
      background: `radial-gradient(ellipse 72% 62% at 50% 50%, transparent 0%, rgba(6,4,16,${strength}) 100%)`,
      pointerEvents: "none",
    }}
  />
);

export const Grain: React.FC<{ opacity?: number }> = ({ opacity = 0.055 }) => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        opacity,
        mixBlendMode: "overlay",
        pointerEvents: "none",
        backgroundImage: NOISE_SVG,
        backgroundPosition: `${(f * 13) % 140}px ${(f * 7) % 140}px`,
      }}
    />
  );
};

/**
 * A 576x324 plate at x4 (2304x1296), centre-cropped into the 1920x1080 frame.
 * Integer scale keeps every pixel hard; cropping kills the dead letterbox.
 * Children are positioned in STAGE space (2304x1296), not screen space.
 */
export const Stage: React.FC<{
  src: string;
  push?: [number, number];
  panX?: [number, number];
  children?: React.ReactNode;
  dim?: number;
}> = ({ src, push = [1, 1], panX = [0, 0], children, dim = 1 }) => {
  const f = useCurrentFrame();
  const zoom = interpolate(f, [0, 90], push, {
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.quad),
  });
  const px = interpolate(f, [0, 90], panX, { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ overflow: "hidden", background: P.void }}>
      <div
        style={{
          position: "absolute",
          left: -192 + px,
          top: -108,
          width: 2304,
          height: 1296,
          transform: `scale(${zoom})`,
          transformOrigin: "50% 50%",
          filter: dim < 1 ? `brightness(${dim})` : undefined,
        }}
      >
        <img
          src={staticFile(src)}
          style={{ width: 2304, height: 1296, imageRendering: "pixelated", display: "block" }}
        />
        {children}
      </div>
    </AbsoluteFill>
  );
};

/**
 * NPC sheets: 192x128, 32px cells, rows down/up/right/left,
 * cols = idle x2 then walk x4. Matches WorldArt.npc_frames().
 */
const ROWS = { down: 0, up: 1, right: 2, left: 3 } as const;

export const Sprite: React.FC<{
  sheet: string;
  dir?: keyof typeof ROWS;
  anim?: "idle" | "walk";
  scale?: number;
  x: number;
  y: number;
  opacity?: number;
}> = ({ sheet, dir = "down", anim = "idle", scale = 4, x, y, opacity = 1 }) => {
  const f = useCurrentFrame();
  const fps = anim === "idle" ? 2 : 8;
  const count = anim === "idle" ? 2 : 4;
  const first = anim === "idle" ? 0 : 2;
  const col = first + (Math.floor((f / 30) * fps) % count);
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width: 32 * scale,
        height: 32 * scale,
        opacity,
        backgroundImage: `url(${staticFile(sheet)})`,
        backgroundRepeat: "no-repeat",
        backgroundSize: `${192 * scale}px ${128 * scale}px`,
        backgroundPosition: `-${col * 32 * scale}px -${ROWS[dir] * 32 * scale}px`,
        imageRendering: "pixelated",
      }}
    />
  );
};

/* ── type ──────────────────────────────────────────────────────────────── */

/** The manifesto card: an amber rule that draws itself, then the lines. */
export const Card: React.FC<{
  lines: string[];
  quiet?: string;
  delay?: number;
  size?: number;
  accent?: string;
}> = ({ lines, quiet, delay = 0, size = 76, accent = P.amber }) => {
  const f = useCurrentFrame() - delay;
  const rule = interpolate(f, [0, 22], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
  return (
    <AbsoluteFill style={{ justifyContent: "center", paddingLeft: 170, paddingRight: 170 }}>
      <div style={{ width: 660 * rule, height: 2, background: accent, marginBottom: 38 }} />
      {lines.map((l, i) => {
        const op = interpolate(f, [10 + i * 12, 26 + i * 12], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
        const y = interpolate(op, [0, 1], [16, 0]);
        return (
          <div
            key={i}
            style={{
              fontFamily: FONT,
              fontWeight: 300,
              fontSize: size,
              lineHeight: 1.22,
              color: P.ink,
              opacity: op,
              transform: `translateY(${y}px)`,
              letterSpacing: -1,
            }}
          >
            {l}
          </div>
        );
      })}
      {quiet ? (
        <div
          style={{
            fontFamily: FONT,
            fontWeight: 300,
            fontStyle: "italic",
            fontSize: size * 0.46,
            color: P.inkMuted,
            marginTop: 30,
            opacity: interpolate(
              f,
              [30 + lines.length * 12, 48 + lines.length * 12],
              [0, 1],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
            ),
          }}
        >
          {quiet}
        </div>
      ) : null}
    </AbsoluteFill>
  );
};

/** Big letterspaced city name that tightens as it settles. */
export const CityCard: React.FC<{ name: string; sub: string; accent: string }> = ({
  name,
  sub,
  accent,
}) => {
  const f = useCurrentFrame();
  const track = interpolate(f, [0, 40], [64, 26], {
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
  const op = interpolate(f, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const bar = interpolate(f, [4, 34], [0, 1], {
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
  return (
    <AbsoluteFill style={{ justifyContent: "center", alignItems: "center", opacity: op }}>
      <div
        style={{
          fontFamily: FONT,
          fontWeight: 700,
          fontSize: 92,
          letterSpacing: track,
          color: accent,
          textIndent: track,
        }}
      >
        {name}
      </div>
      <div
        style={{ width: 520 * bar, height: 1, background: accent, opacity: 0.5, margin: "26px 0" }}
      />
      <div
        style={{
          fontFamily: FONT,
          fontWeight: 300,
          fontSize: 34,
          color: "rgba(244,242,255,0.72)",
          fontStyle: "italic",
        }}
      >
        {sub}
      </div>
    </AbsoluteFill>
  );
};

/** The dialogue box, rebuilt rather than filmed. */
export const DialogueBox: React.FC<{
  speaker: string;
  children: React.ReactNode;
  reveal?: number;
  size?: number;
}> = ({ speaker, children, reveal = 1, size = 44 }) => (
  <div
    style={{
      position: "absolute",
      left: 200,
      right: 200,
      bottom: 128,
      background: P.panelDark,
      border: `2px solid ${P.border}`,
      padding: "32px 44px 38px",
      opacity: reveal,
      transform: `translateY(${(1 - reveal) * 26}px)`,
      boxShadow: "0 24px 80px rgba(4,2,12,0.75)",
    }}
  >
    <div
      style={{
        fontFamily: FONT,
        fontSize: 19,
        letterSpacing: 4,
        color: P.inkMuted,
        marginBottom: 16,
      }}
    >
      {speaker.toUpperCase()}
    </div>
    <div style={{ fontFamily: FONT, fontSize: size, lineHeight: 1.42, color: TIER.known }}>
      {children}
    </div>
  </div>
);

/** One run of text at a familiarity tier — the game's exact colours. */
export const G: React.FC<{ tier?: keyof typeof TIER; children: React.ReactNode }> = ({
  tier = "unknown",
  children,
}) =>
  tier === "partial" ? (
    <span style={{ color: TIER.partial, background: TIER.partialBg, padding: "0 .3em" }}>
      {children}
    </span>
  ) : (
    <span style={{ color: TIER[tier] as string }}>{children}</span>
  );
