import React from "react";
import { AbsoluteFill, useCurrentFrame, random } from "remotion";

/**
 * No London or Istanbul art exists in the project, so both plates are drawn
 * here as flat graphic silhouettes. Palettes are taken verbatim from
 * docs/design/london.md 2.1-2.2 and docs/design/istanbul.md 2.
 */

/* ── LONDON ────────────────────────────────────────────────────────────────
 * "The chimney stacks are the single most identifying silhouette element."
 * 90% of the plate sits between #1a1d24 and #6e5f49, plus ONE statutory
 * accent at full chroma. Three is a mistake.
 */
const L = {
  lid: "#1b1e26",
  cloudBelly: "#2c313c",
  sodium: "#3d3a34",
  brick: "#5c5140",
  brickShade: "#463d31",
  redBand: "#6d3128",
  stucco: "#c4bdac",
  slate: "#2e3138",
  sash: "#e8e2d4",
  windowDark: "#1a1d24",
  windowLit: "#f0d79a",
  york: "#4b4a46",
  kerb: "#6a6660",
  tflRed: "#e1251b",
  tflBlue: "#0019a8",
};

/** One terrace house: chimney stack and pots, roof, facade, sashes, area railing. */
const Terrace: React.FC<{ x: number; w: number; h: number; pots: number; lit: number[] }> = ({
  x,
  w,
  h,
  pots,
  lit,
}) => {
  const roofY = 1296 - h;
  return (
    <g>
      <rect x={x + w - 46} y={roofY - 74} width={40} height={80} fill={L.redBand} />
      {Array.from({ length: pots }).map((_, i) => (
        <rect
          key={i}
          x={x + w - 42 + i * 11}
          y={roofY - 94 - (i % 2) * 8}
          width={8}
          height={26 + (i % 2) * 8}
          fill={L.brickShade}
        />
      ))}
      <rect x={x} y={roofY} width={w} height={26} fill={L.slate} />
      <rect x={x} y={roofY + 26} width={w} height={h - 26} fill={L.brick} />
      <rect x={x} y={roofY + 26} width={6} height={h - 26} fill={L.brickShade} />
      <rect x={x} y={1146} width={w} height={110} fill={L.stucco} opacity={0.3} />
      {[0, 1, 2, 3].map((row) =>
        [0, 1].map((col) => {
          const wx = x + 26 + col * (w / 2 - 6);
          const wy = roofY + 60 + row * 96;
          if (wy > 1106) return null;
          const isLit = lit.includes(row * 2 + col);
          return (
            <g key={`${row}-${col}`}>
              <rect x={wx - 3} y={wy - 3} width={44} height={68} fill={L.sash} opacity={0.85} />
              <rect
                x={wx}
                y={wy}
                width={38}
                height={62}
                fill={isLit ? L.windowLit : L.windowDark}
                opacity={isLit ? 0.9 : 1}
              />
            </g>
          );
        })
      )}
      {/* every house has a hole in front of it */}
      <rect x={x} y={1254} width={w} height={42} fill="#000000" opacity={0.55} />
      {Array.from({ length: Math.floor(w / 16) }).map((_, i) => (
        <rect key={i} x={x + 6 + i * 16} y={1218} width={3} height={40} fill="#000000" />
      ))}
    </g>
  );
};

export const LondonPlate: React.FC<{ rain?: boolean }> = ({ rain = true }) => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: L.lid, overflow: "hidden" }}>
      <svg
        viewBox="0 0 2304 1296"
        style={{ position: "absolute", left: 0, top: 0, width: 1920, height: 1080 }}
      >
        <defs>
          <linearGradient id="lsky" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={L.lid} />
            <stop offset="70%" stopColor={L.cloudBelly} />
            <stop offset="100%" stopColor={L.sodium} />
          </linearGradient>
        </defs>
        <rect width={2304} height={1296} fill="url(#lsky)" />

        {/* the terrace steps down the hill — the roofline is never level */}
        <Terrace x={-40} w={300} h={1010} pots={5} lit={[1, 4, 6]} />
        <Terrace x={250} w={280} h={1050} pots={4} lit={[0, 5]} />
        <Terrace x={520} w={300} h={995} pots={6} lit={[3, 7]} />
        <Terrace x={810} w={290} h={1040} pots={4} lit={[2, 4]} />
        <Terrace x={1090} w={310} h={985} pots={5} lit={[1, 6]} />
        <Terrace x={1390} w={280} h={1025} pots={5} lit={[0, 3]} />
        <Terrace x={1660} w={300} h={1000} pots={6} lit={[4, 7]} />
        <Terrace x={1950} w={300} h={1040} pots={4} lit={[2, 5]} />

        <rect x={0} y={1256} width={2304} height={40} fill={L.york} />
        <rect x={0} y={1288} width={2304} height={8} fill={L.kerb} />

        {/* the one statutory accent */}
        <rect x={1912} y={700} width={7} height={560} fill="#000000" />
        <circle cx={1915} cy={680} r={46} fill={L.tflRed} />
        <circle cx={1915} cy={680} r={27} fill={L.lid} />
        <rect x={1859} y={668} width={112} height={24} fill={L.tflBlue} />
      </svg>

      {rain ? (
        <AbsoluteFill style={{ opacity: 0.26 }}>
          {Array.from({ length: 80 }).map((_, i) => {
            const speed = 240 + random(`s${i}`) * 260;
            const x = random(`x${i}`) * 1920;
            const y = ((random(`y${i}`) * 1080 + f * speed) % 1220) - 140;
            return (
              <div
                key={i}
                style={{
                  position: "absolute",
                  left: x,
                  top: y,
                  width: 1.5,
                  height: 22 + random(`h${i}`) * 26,
                  background:
                    "linear-gradient(180deg, rgba(232,226,212,0), rgba(232,226,212,0.75))",
                  transform: "rotate(9deg)",
                }}
              />
            );
          })}
        </AbsoluteFill>
      ) : null}
    </AbsoluteFill>
  );
};

/* ── ISTANBUL ──────────────────────────────────────────────────────────────
 * "If the player sees a black cut-out of two upper storeys leaning toward
 * each other across a narrow gap, that is Istanbul and nowhere else."
 */
const I = {
  shadow: "#2a1f18",
  timberDark: "#4a3626",
  plasterWorn: "#8a6f4e",
  plasterSun: "#c9a878",
  bleached: "#e8d5b0",
  terracotta: "#b5563c",
  roofShadow: "#8c4a3a",
  rose: "#a8574f",
  mint: "#7d9b6f",
  paleBlue: "#5a7a8c",
  cable: "#3d3a34",
  cobalt: "#1c39a8",
  turquoise: "#2fa4a0",
  bole: "#c8453a",
  tileWhite: "#f0ece0",
  lamp: "#f2c56e",
};

/** A cumba: the closed timber bay jutting over the street on brackets. */
const Cumba: React.FC<{ x: number; w: number; y: number; face: string; flip?: boolean }> = ({
  x,
  w,
  y,
  face,
  flip,
}) => (
  <g transform={flip ? `translate(${x + w},${y}) scale(-1,1)` : `translate(${x},${y})`}>
    <rect x={0} y={0} width={w} height={150} fill={face} />
    <rect x={0} y={0} width={w} height={12} fill={I.timberDark} />
    <path d={`M0,150 L34,150 L0,196 Z`} fill={I.timberDark} />
    <path d={`M${w - 34},150 L${w},150 L${w},196 Z`} fill={I.timberDark} />
    {[0, 1, 2].map((i) => (
      <rect
        key={i}
        x={18 + i * (w / 3)}
        y={30}
        width={w / 3 - 30}
        height={86}
        fill={I.lamp}
        opacity={0.82}
      />
    ))}
  </g>
);

export const IstanbulPlate: React.FC = () => {
  const f = useCurrentFrame();
  const sway = Math.sin(f / 34) * 5;
  return (
    <AbsoluteFill style={{ background: I.shadow, overflow: "hidden" }}>
      <svg
        viewBox="0 0 2304 1296"
        style={{ position: "absolute", left: 0, top: 0, width: 1920, height: 1080 }}
      >
        <defs>
          <linearGradient id="isky" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={I.bleached} />
            <stop offset="55%" stopColor={I.plasterSun} />
            <stop offset="100%" stopColor={I.terracotta} />
          </linearGradient>
        </defs>
        <rect width={2304} height={1296} fill="url(#isky)" />

        {/* the ground is never level: draw the pavement as a stair */}
        <rect x={0} y={1180} width={620} height={116} fill={I.plasterWorn} />
        <rect x={620} y={1210} width={560} height={86} fill={I.plasterWorn} />
        <rect x={1180} y={1240} width={560} height={56} fill={I.plasterWorn} />
        <rect x={1740} y={1266} width={564} height={30} fill={I.plasterWorn} />

        {/* mid-distance houses: every one a different colour, bleached one side */}
        {[
          { x: 500, w: 300, h: 620, c: I.paleBlue },
          { x: 800, w: 260, h: 700, c: I.rose },
          { x: 1060, w: 290, h: 640, c: I.mint },
          { x: 1350, w: 250, h: 690, c: I.plasterWorn },
          { x: 1600, w: 230, h: 630, c: I.paleBlue },
        ].map((h, i) => (
          <g key={i}>
            <rect x={h.x} y={1296 - h.h} width={h.w} height={h.h} fill={h.c} />
            <rect
              x={h.x}
              y={1296 - h.h}
              width={h.w * 0.32}
              height={h.h}
              fill={I.bleached}
              opacity={0.18}
            />
            <rect x={h.x} y={1296 - h.h - 18} width={h.w} height={18} fill={I.terracotta} />
            <rect x={h.x} y={1296 - h.h} width={h.w} height={7} fill={I.roofShadow} />
            {[0, 1, 2].map((r) =>
              [0, 1].map((c) => (
                <rect
                  key={`${r}${c}`}
                  x={h.x + 34 + c * (h.w / 2)}
                  y={1296 - h.h + 58 + r * 128}
                  width={54}
                  height={92}
                  fill={(r + c + i) % 3 === 0 ? I.lamp : I.timberDark}
                  opacity={(r + c + i) % 3 === 0 ? 0.85 : 0.75}
                />
              ))
            )}
          </g>
        ))}

        {/* two sides leaning in, nearly touching overhead */}
        <rect x={-20} y={300} width={520} height={996} fill={I.plasterSun} />
        <rect x={-20} y={300} width={520} height={22} fill={I.timberDark} />
        <rect x={420} y={300} width={80} height={996} fill={I.shadow} opacity={0.28} />
        <Cumba x={40} w={400} y={330} face={I.rose} />

        <rect x={1810} y={280} width={520} height={1016} fill={I.plasterSun} />
        <rect x={1810} y={280} width={520} height={22} fill={I.timberDark} />
        <rect x={1810} y={280} width={80} height={1016} fill={I.shadow} opacity={0.28} />
        <Cumba x={1870} w={400} y={318} face={I.mint} flip />

        {/* awnings cantilevered over the shopfronts */}
        {[560, 880, 1180, 1480].map((x, i) => (
          <path
            key={i}
            d={`M${x},${1040 + i * 12} L${x + 210},${1040 + i * 12} L${x + 190},${1108 + i * 12} L${x + 20},${1108 + i * 12} Z`}
            fill={i % 2 ? I.bole : I.turquoise}
            opacity={0.9}
          />
        ))}

        {/* the sky is netted */}
        {[
          { y: 250, sag: 92 },
          { y: 330, sag: 132 },
          { y: 420, sag: 70 },
        ].map((c, i) => (
          <path
            key={i}
            d={`M-40,${c.y} Q1152,${c.y + c.sag + sway} 2344,${c.y - 16}`}
            stroke={I.cable}
            strokeWidth={i === 1 ? 5 : 3}
            fill="none"
          />
        ))}
        {Array.from({ length: 16 }).map((_, i) => {
          const t = i / 15;
          const x = -40 + t * 2384;
          const y = 330 + 4 * 132 * t * (1 - t) + sway * t;
          return <circle key={i} cx={x} cy={y} r={7} fill={I.lamp} opacity={0.95} />;
        })}

        {/* Iznik accents only where a real object would carry them: a nazar */}
        <circle cx={1150} cy={905} r={26} fill={I.tileWhite} />
        <circle cx={1150} cy={905} r={18} fill={I.cobalt} />
        <circle cx={1150} cy={905} r={7} fill={I.tileWhite} />
      </svg>
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(ellipse 78% 70% at 50% 52%, transparent 0%, rgba(42,31,24,0.40) 100%)",
        }}
      />
    </AbsoluteFill>
  );
};
