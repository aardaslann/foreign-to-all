import React from "react";
import { interpolate, useCurrentFrame, random } from "remotion";
import { C, SERIF, MONO, ramp, EXPO, Label, Wipe } from "./kit";

/* ═══ FIGURE 1 · one word, five glosses, none of them it ═══════════════════
 * `buyurun` is the project's own example of a word that survives no
 * translation. Every candidate is struck out as it arrives.
 */
const GLOSSES = ["here you are", "please", "come in", "go ahead", "what can I do for you"];

export const Buyurun: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <div style={{ display: "flex", gap: 120, alignItems: "flex-start" }}>
      <div style={{ flex: "0 0 540px" }}>
        <Label delay={0}>Turkish · one word</Label>
        <div style={{ height: 26 }} />
        <Wipe delay={6} lift={30}>
          <div
            style={{
              fontFamily: SERIF,
              fontSize: 112,
              fontWeight: 400,
              letterSpacing: "-0.03em",
              color: C.ink,
            }}
          >
            buyurun
          </div>
        </Wipe>
      </div>

      <div style={{ flex: 1, paddingTop: 62 }}>
        {GLOSSES.map((g, i) => {
          const appear = 26 + i * 15;
          const strike = appear + 11;
          const t = ramp(f, appear, 16);
          const s = ramp(f, strike, 13);
          return (
            <div
              key={g}
              style={{
                marginBottom: 16,
                opacity: t,
                transform: `translateX(${(1 - t) * 26}px)`,
              }}
            >
              <div
                style={{
                  fontFamily: MONO,
                  fontSize: 33,
                  color: s > 0.4 ? C.inkFaint : C.inkSoft,
                  display: "inline-block",
                  position: "relative",
                }}
              >
                {g}
                <div
                  style={{
                    position: "absolute",
                    left: -6,
                    top: "54%",
                    height: 2,
                    width: `${s * 106}%`,
                    background: C.vermilion,
                  }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

/* ═══ FIGURE 2 · one word, five meanings, no dictionary ════════════════════ */
const SORRY: [string, string][] = [
  ["Sorry —", "excuse me, I am about to speak to you"],
  ["Sorry.", "get out of my way"],
  ["Sorry?", "I did not hear you"],
  ["Sorry, no.", "absolutely not, and I resent being asked"],
  ["I'm sorry.", "actual regret. the rarest one"],
];

export const SorryFan: React.FC = () => {
  const f = useCurrentFrame();
  const H = 520;
  const rowH = H / SORRY.length;
  return (
    <div style={{ display: "flex", alignItems: "center" }}>
      <div style={{ flex: "0 0 340px" }}>
        <Label delay={0}>England · one word</Label>
        <div style={{ height: 22 }} />
        <Wipe delay={5} lift={26}>
          <div
            style={{
              fontFamily: SERIF,
              fontSize: 96,
              fontStyle: "italic",
              color: C.ink,
              letterSpacing: "-0.03em",
            }}
          >
            sorry
          </div>
        </Wipe>
      </div>

      <svg width={250} height={H} style={{ flex: "0 0 250px", overflow: "visible" }}>
        {SORRY.map((_, i) => {
          const y = rowH * i + rowH / 2;
          const t = ramp(f, 22 + i * 9, 26);
          return (
            <path
              key={i}
              d={`M0,${H / 2} C110,${H / 2} 140,${y} 250,${y}`}
              stroke={C.cobalt}
              strokeWidth={1.5}
              fill="none"
              opacity={0.85}
              strokeDasharray={400}
              strokeDashoffset={400 * (1 - t)}
            />
          );
        })}
      </svg>

      <div style={{ flex: 1, height: H, display: "flex", flexDirection: "column" }}>
        {SORRY.map(([said, means], i) => {
          const t = ramp(f, 34 + i * 9, 22);
          return (
            <div
              key={said}
              style={{
                height: rowH,
                display: "flex",
                flexDirection: "column",
                justifyContent: "center",
                paddingLeft: 30,
                opacity: t,
                transform: `translateX(${(1 - t) * 20}px)`,
              }}
            >
              <div style={{ fontFamily: SERIF, fontSize: 32, color: C.ink }}>{said}</div>
              <div
                style={{
                  fontFamily: MONO,
                  fontSize: 19,
                  color: C.inkSoft,
                  marginTop: 5,
                }}
              >
                {means}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

/* ═══ FIGURE 3 · where meaning is actually kept ════════════════════════════
 * The word sits on top; everything that decides what it means is stacked
 * underneath, and the stack is much bigger than the word.
 */
const STRATA = [
  "who is speaking",
  "to whom",
  "what is owed between them",
  "what was said an hour ago",
  "what everybody here already knows",
];

export const MeaningStrata: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <div>
      <Wipe delay={0} lift={24}>
        <div
          style={{
            fontFamily: SERIF,
            fontSize: 72,
            color: C.ink,
            letterSpacing: "-0.02em",
            paddingLeft: 46,
          }}
        >
          the word
        </div>
      </Wipe>
      <div style={{ height: 18 }} />
      {STRATA.map((s, i) => {
        const t = ramp(f, 16 + i * 10, 26);
        return (
          <div
            key={s}
            style={{
              display: "flex",
              alignItems: "center",
              height: 72,
              borderTop: `1px solid ${C.paperEdge}`,
              opacity: t,
              transform: `translateX(${(1 - t) * -34}px)`,
            }}
          >
            <div
              style={{
                width: 46,
                fontFamily: MONO,
                fontSize: 15,
                color: C.cobalt,
                letterSpacing: "0.12em",
              }}
            >
              {String(i + 1).padStart(2, "0")}
            </div>
            <div style={{ fontFamily: SERIF, fontSize: 37, color: C.inkSoft }}>{s}</div>
          </div>
        );
      })}
      <div
        style={{
          borderTop: `1px solid ${C.paperEdge}`,
          paddingTop: 22,
          opacity: ramp(f, 74, 24),
        }}
      >
        <Label color={C.cobalt}>this is the part no dictionary contains</Label>
      </div>
    </div>
  );
};

/* ═══ FIGURE 4 · the compression ═══════════════════════════════════════════
 * A place rendered as a few hundred distinct marks, then crushed into three
 * crude blocks. The loss is the point.
 */
const N = 340;

export const Compression: React.FC<{ start?: number }> = ({ start = 40 }) => {
  const f = useCurrentFrame();
  const t = interpolate(f, [start, start + 62], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EXPO,
  });
  const W = 1400;
  const H = 470;

  const marks = React.useMemo(
    () =>
      Array.from({ length: N }).map((_, i) => {
        const col = i % 26;
        const row = Math.floor(i / 26);
        const x0 = col * 53 + random(`jx${i}`) * 14;
        const y0 = row * 32 + random(`jy${i}`) * 9;
        const w0 = 12 + random(`w${i}`) * 32;
        const bucket = i % 3;
        const x1 = 130 + bucket * 400;
        const y1 = 118;
        return { x0, y0, w0, x1, y1, o: 0.32 + random(`o${i}`) * 0.6 };
      }),
    []
  );

  return (
    <div>
      <svg width={W} height={H} style={{ display: "block" }}>
        {marks.map((m, i) => {
          const x = interpolate(t, [0, 1], [m.x0, m.x1]);
          const y = interpolate(t, [0, 1], [m.y0, m.y1]);
          const w = interpolate(t, [0, 1], [m.w0, 280]);
          const h = interpolate(t, [0, 1], [7, 110]);
          const o = interpolate(t, [0, 0.5, 0.78], [m.o, m.o * 0.4, 0], {
            extrapolateRight: "clamp",
          });
          return <rect key={i} x={x} y={y} width={w} height={h} fill={C.ink} opacity={o} rx={1} />;
        })}
        {[0, 1, 2].map((b) => (
          <rect
            key={b}
            x={130 + b * 400}
            y={118}
            width={280}
            height={110}
            fill={C.vermilion}
            opacity={interpolate(t, [0.6, 0.95], [0, 0.92], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })}
          />
        ))}
      </svg>
      <div style={{ marginTop: 24, opacity: ramp(f, start + 68, 24) }}>
        <Label color={C.vermilion}>three hundred and forty things about a place → three</Label>
      </div>
    </div>
  );
};

/* ═══ FIGURE 5 · the instrument ════════════════════════════════════════════ */
const CITIES: [string, string, string, string][] = [
  ["Berlin", "you cannot read,\nand you cannot be read", "per word", "bewilderment"],
  ["London", "every word legible,\nthe meaning gone", "per speaker", "embarrassment"],
  ["İstanbul", "you are let in,\nand being let in costs", "per stem", "exposure"],
];

export const ThreeCities: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <div style={{ display: "flex", gap: 56 }}>
      {CITIES.map(([name, line, model, register], i) => {
        const t = ramp(f, 8 + i * 13, 30);
        return (
          <div
            key={name}
            style={{ flex: 1, opacity: t, transform: `translateY(${(1 - t) * 26}px)` }}
          >
            <div style={{ height: 2, background: C.cobaltLit, width: `${t * 100}%` }} />
            <div style={{ paddingTop: 26 }}>
              <div
                style={{
                  fontFamily: SERIF,
                  fontSize: 52,
                  color: C.nightType,
                  letterSpacing: "-0.02em",
                }}
              >
                {name}
              </div>
              <div
                style={{
                  fontFamily: SERIF,
                  fontSize: 28,
                  fontStyle: "italic",
                  color: C.nightSoft,
                  marginTop: 16,
                  lineHeight: 1.35,
                  whiteSpace: "pre-line",
                  minHeight: 82,
                }}
              >
                {line}
              </div>
              <div style={{ height: 1, background: C.nightEdge, margin: "26px 0 16px" }} />
              <div
                style={{
                  fontFamily: MONO,
                  fontSize: 17,
                  color: C.cobaltLit,
                  letterSpacing: "0.16em",
                  textTransform: "uppercase",
                }}
              >
                {model}
              </div>
              <div
                style={{
                  fontFamily: MONO,
                  fontSize: 17,
                  color: C.nightSoft,
                  letterSpacing: "0.16em",
                  textTransform: "uppercase",
                  marginTop: 7,
                }}
              >
                {register}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

/* ═══ FIGURE 6 · a page you cannot read ════════════════════════════════════
 * Word-shapes, which is what unreadable text actually looks like from the
 * outside. One of them resolves.
 */
export const UnreadablePage: React.FC<{ resolveAt?: number }> = ({ resolveAt = 70 }) => {
  const f = useCurrentFrame();
  const ROWS = 10;
  const rows = React.useMemo(
    () =>
      Array.from({ length: ROWS }).map((_, r) => {
        const words: number[] = [];
        let used = 0;
        let i = 0;
        const cap = r === ROWS - 1 ? 600 : 1160;
        while (used < cap) {
          const w = 44 + random(`w${r}-${i}`) * 145;
          words.push(w);
          used += w + 22;
          i++;
        }
        return words;
      }),
    []
  );

  const target = { row: 4, word: 3 };
  const rev = ramp(f, resolveAt, 24);

  return (
    <div>
      {rows.map((words, r) => {
        const t = ramp(f, r * 3.5, 26);
        return (
          <div key={r} style={{ display: "flex", gap: 22, marginBottom: 28, opacity: t }}>
            {words.map((w, i) => {
              const isTarget = r === target.row && i === target.word;
              if (isTarget) {
                return (
                  <div
                    key={i}
                    style={{
                      width: Math.max(w, 128),
                      height: 22,
                      position: "relative",
                      flex: "0 0 auto",
                    }}
                  >
                    <div
                      style={{
                        position: "absolute",
                        inset: 0,
                        background: C.nightType,
                        opacity: (1 - rev) * 0.55,
                        borderRadius: 2,
                      }}
                    />
                    <div
                      style={{
                        position: "absolute",
                        left: 0,
                        top: -16,
                        fontFamily: SERIF,
                        fontSize: 42,
                        color: C.cobaltLit,
                        opacity: rev,
                        letterSpacing: "-0.01em",
                      }}
                    >
                      brot
                    </div>
                  </div>
                );
              }
              return (
                <div
                  key={i}
                  style={{
                    width: w,
                    height: 22,
                    flex: "0 0 auto",
                    background: C.nightType,
                    opacity: 0.16 + random(`o${r}-${i}`) * 0.14,
                    borderRadius: 2,
                  }}
                />
              );
            })}
          </div>
        );
      })}
    </div>
  );
};
