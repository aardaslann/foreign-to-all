import React from "react";
import { AbsoluteFill, Sequence, interpolate, useCurrentFrame, Easing, staticFile } from "remotion";
import { P, TIER } from "./lib/palette";
import { toGlyphs, shuffledGlyphs } from "./lib/glyphs";
import {
  Stage,
  Sprite,
  Vignette,
  Grain,
  Card,
  CityCard,
  DialogueBox,
  G,
  FONT,
  S,
} from "./lib/ui";
import { LondonPlate, IstanbulPlate } from "./lib/cities";

const MITTE = "art/scenes/mitte_dawn.png";
const RENATE = "art/npcs/renate_sheet.png";

/** Feet land on the far pavement: plate y 182, x4 = stage y 728. */
const PAVEMENT = 728;

/* ═══ ACT 0 · THE FAILURE — 0:00-0:09 ═══════════════════════════════════ */

const Shot_Dark: React.FC = () => {
  const f = useCurrentFrame();
  const up = interpolate(f, [0, 30], [0, 0.24], { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ background: P.void }}>
      <AbsoluteFill style={{ opacity: up }}>
        <Stage src={MITTE} />
      </AbsoluteFill>
      <Vignette strength={0.96} />
    </AbsoluteFill>
  );
};

const Shot_SheSpeaks: React.FC = () => {
  const f = useCurrentFrame();
  const fade = interpolate(f, [0, 10], [0.24, 1], { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ background: P.void, opacity: fade }}>
      <Stage src={MITTE} push={[1.0, 1.09]}>
        <Sprite sheet={RENATE} dir="down" anim="idle" scale={5} x={1050} y={PAVEMENT - 160} />
      </Stage>
      <Vignette strength={0.86} />
      <Grain />
    </AbsoluteFill>
  );
};

/**
 * The bold move: the glyphs tear out of the dialogue box and fill the frame.
 * She repeats herself slower and the shapes do not change.
 */
const Shot_Glyphs: React.FC = () => {
  const f = useCurrentFrame();
  const word = "entschuldigung";
  const stable = toGlyphs(word);
  const text = f < 22 ? shuffledGlyphs(word.length, Math.floor(f / 5.4)) : stable;

  const boxIn = interpolate(f, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  const breakout = interpolate(f, [32, 76], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.inOut(Easing.cubic),
  });
  const typeSize = interpolate(breakout, [0, 1], [44, 132]);
  const track = interpolate(breakout, [0, 1], [2, 20]);
  const boxOp = interpolate(breakout, [0, 0.4], [1, 0], { extrapolateRight: "clamp" });
  const dim = interpolate(breakout, [0, 1], [1, 0.14]);

  return (
    <AbsoluteFill style={{ background: P.void }}>
      <Stage src={MITTE} dim={dim}>
        <Sprite sheet={RENATE} dir="down" anim="idle" scale={5} x={1050} y={PAVEMENT - 160} />
      </Stage>

      <div style={{ opacity: boxOp * boxIn }}>
        <DialogueBox speaker="Renate" reveal={boxIn}>
          <G tier="unknown">{text}</G>
        </DialogueBox>
      </div>

      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: breakout }}>
        <div
          style={{
            fontFamily: FONT,
            fontSize: typeSize,
            color: TIER.unknown,
            letterSpacing: track,
            whiteSpace: "nowrap",
            textShadow: `0 0 ${70 * breakout}px rgba(232,228,255,0.30)`,
          }}
        >
          {stable}
        </div>
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

const Shot_SheLeaves: React.FC = () => {
  const f = useCurrentFrame();
  const x = interpolate(f, [0, 30], [1050, 1720]);
  const fade = interpolate(f, [18, 30], [1, 0], { extrapolateLeft: "clamp" });
  return (
    <AbsoluteFill style={{ background: P.void }}>
      <Stage src={MITTE} dim={0.9}>
        <Sprite
          sheet={RENATE}
          dir="right"
          anim="walk"
          scale={5}
          x={x}
          y={PAVEMENT - 160}
          opacity={fade}
        />
      </Stage>
      <Vignette strength={0.9} />
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 1 · ILLEGIBLE — 0:09-0:22 ═════════════════════════════════════ */

/** Signage held just short of long enough to read. */
const Shot_Signage: React.FC = () => {
  const f = useCurrentFrame();
  const words = ["FUNDBÜRO", "APOTHEKE", "POLIZEI"];
  const i = Math.min(words.length - 1, Math.floor(f / 30));
  const local = f - i * 30;
  const op = interpolate(local, [0, 4, 22, 28], [0, 1, 1, 0], { extrapolateRight: "clamp" });
  const slide = interpolate(local, [0, 28], [0, -26]);
  return (
    <AbsoluteFill style={{ background: P.void }}>
      <Stage src={MITTE} dim={0.34} panX={[0, -110]} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div
          style={{
            fontFamily: FONT,
            fontWeight: 700,
            fontSize: 172,
            letterSpacing: 14,
            color: P.amber,
            opacity: op,
            transform: `translateY(${slide}px)`,
          }}
        >
          {words[i]}
        </div>
      </AbsoluteFill>
      <Vignette strength={0.8} />
      <Grain />
    </AbsoluteFill>
  );
};

const Shot_Wreck: React.FC = () => (
  <AbsoluteFill style={{ background: P.void }}>
    <Stage src="art/scenes/wreck_dawn.png" push={[1.06, 1.0]} dim={0.86} />
    <Vignette strength={0.88} />
    <Grain />
  </AbsoluteFill>
);

/** Three people speak. Three boxes. All glyphs. They walk around you. */
const Shot_ThreeVoices: React.FC = () => {
  const f = useCurrentFrame();
  const set = [
    { who: "Weber", w: "danke", sheet: "art/npcs/weber_sheet.png" },
    { who: "Lukas", w: "fundbüro", sheet: "art/npcs/lukas_sheet.png" },
    { who: "Passerby", w: "polizei", sheet: "art/npcs/commuter_m_sheet.png" },
  ];
  const i = Math.min(set.length - 1, Math.floor(f / 50));
  const local = f - i * 50;
  const op = interpolate(local, [0, 6, 42, 50], [0, 1, 1, 0], { extrapolateRight: "clamp" });
  const cur = set[i];
  return (
    <AbsoluteFill style={{ background: P.void }}>
      <Stage src={MITTE} dim={0.6} panX={[-60, 40]}>
        <Sprite
          sheet={cur.sheet}
          dir="down"
          anim="idle"
          scale={5}
          x={900 + i * 210}
          y={PAVEMENT - 160}
        />
      </Stage>
      <div style={{ opacity: op }}>
        <DialogueBox speaker={cur.who}>
          <G tier="unknown">{toGlyphs(cur.w)}</G>
        </DialogueBox>
      </div>
      <Vignette strength={0.82} />
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 2 · ONE WORD — 0:22-0:38 ══════════════════════════════════════ */

/** brot: glyphs, shuffle, partial, known. No chime. Nothing congratulates you. */
const Shot_Brot: React.FC = () => {
  const f = useCurrentFrame();
  const stable = toGlyphs("brot");

  let node: React.ReactNode;
  if (f < 90) node = <G tier="unknown">{stable}</G>;
  else if (f < 150) node = <G tier="glimpsed">{shuffledGlyphs(4, Math.floor((f - 90) / 5.4))}</G>;
  else if (f < 210) node = <G tier="partial">brot</G>;
  else node = <G tier="known">brot</G>;

  const size = interpolate(f, [140, 215], [150, 232], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.inOut(Easing.cubic),
  });
  const glow = interpolate(f, [210, 240], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ background: P.void }}>
      <Stage src={MITTE} dim={0.26} push={[1.0, 1.05]}>
        <Sprite
          sheet="art/npcs/lukas_sheet.png"
          dir="down"
          anim="idle"
          scale={5}
          x={1080}
          y={PAVEMENT - 160}
        />
      </Stage>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div
          style={{
            fontFamily: FONT,
            fontWeight: 400,
            fontSize: size,
            letterSpacing: f < 150 ? 22 : 4,
            textShadow: `0 0 ${90 * glow}px rgba(242,197,110,0.35)`,
          }}
        >
          {node}
        </div>
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 3a · FALSE CLEAR — 0:38-0:55 ══════════════════════════════════ */

/** The line renders perfectly. That is the trap. */
const Shot_NotBad: React.FC = () => {
  const f = useCurrentFrame();
  const boxIn = interpolate(f, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  const readOp = interpolate(f, [56, 68], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const strike = interpolate(f, [96, 116], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const truthOp = interpolate(f, [112, 128], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ background: "#1b1e26" }}>
      <LondonPlate />
      <AbsoluteFill style={{ background: "rgba(11,10,28,0.55)" }} />
      <AbsoluteFill style={{ justifyContent: "center", paddingLeft: 180, paddingRight: 180 }}>
        <div
          style={{
            fontFamily: FONT,
            fontSize: 96,
            fontWeight: 300,
            color: TIER.known,
            opacity: boxIn,
            letterSpacing: -1,
          }}
        >
          &ldquo;Not bad, is it.&rdquo;
        </div>

        <div style={{ marginTop: 56, opacity: readOp }}>
          <div style={{ fontFamily: FONT, fontSize: 21, letterSpacing: 5, color: P.inkMuted }}>
            YOU HEAR
          </div>
          <div
            style={{
              fontFamily: FONT,
              fontSize: 46,
              fontWeight: 300,
              color: P.inkMuted,
              marginTop: 10,
              position: "relative",
              width: "fit-content",
            }}
          >
            She is disappointed.
            <div
              style={{
                position: "absolute",
                left: 0,
                top: "52%",
                height: 3,
                width: `${strike * 100}%`,
                background: "#e1251b",
              }}
            />
          </div>
        </div>

        <div style={{ marginTop: 44, opacity: truthOp }}>
          <div style={{ fontFamily: FONT, fontSize: 21, letterSpacing: 5, color: "#e1251b" }}>
            SHE MEANS
          </div>
          <div
            style={{ fontFamily: FONT, fontSize: 62, fontWeight: 600, color: P.ink, marginTop: 10 }}
          >
            That&rsquo;s excellent.
          </div>
        </div>
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

/** Denny. Warm, delighted, and every word of it a refusal. */
const Shot_Denny: React.FC = () => {
  const f = useCurrentFrame();
  const boxIn = interpolate(f, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ background: "#1b1e26" }}>
      <LondonPlate />
      <AbsoluteFill style={{ background: "rgba(11,10,28,0.62)" }} />
      <DialogueBox speaker="Denny Rooke" reveal={boxIn} size={40}>
        <G tier="known">
          &ldquo;Yeah, no, I hear you. Leave it with me. I&rsquo;ll have a look for you,
          definitely. Thing is, it&rsquo;s sort of spoken for. But no, come back, come back any
          time.&rdquo;
        </G>
      </DialogueBox>
      <Grain />
    </AbsoluteFill>
  );
};

/** The turn. The score drops out here. */
const Shot_SayingNo: React.FC = () => {
  const f = useCurrentFrame();
  const op = interpolate(f, [0, 8], [0, 1], { extrapolateRight: "clamp" });
  const scale = interpolate(f, [0, 60], [0.97, 1.02], { easing: Easing.out(Easing.cubic) });
  return (
    <AbsoluteFill style={{ background: P.void, alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          fontFamily: FONT,
          fontWeight: 600,
          fontSize: 138,
          color: "#e1251b",
          opacity: op,
          transform: `scale(${scale})`,
          letterSpacing: -2,
        }}
      >
        He is saying no.
      </div>
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 3b · INSIDE IT — 0:55-1:11 ════════════════════════════════════ */

/** Plain English and glyphs in one sentence: it is not the language, it is her. */
const Shot_Bev: React.FC = () => {
  const f = useCurrentFrame();
  const boxIn = interpolate(f, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  return (
    <AbsoluteFill style={{ background: "#1b1e26" }}>
      <LondonPlate rain={false} />
      <AbsoluteFill style={{ background: "rgba(11,10,28,0.6)" }} />
      <DialogueBox speaker="Bev" reveal={boxIn} size={50}>
        <G tier="known">&ldquo;Y&rsquo;</G>
        <G tier="unknown">{toGlyphs("alright")}</G>
        <G tier="known">, love? What </G>
        <G tier="unknown">{toGlyphs("can")}</G>
        <G tier="known"> I </G>
        <G tier="unknown">{toGlyphs("get")}</G>
        <G tier="known"> you?&rdquo;</G>
      </DialogueBox>
      <Grain />
    </AbsoluteFill>
  );
};

const Shot_Aright: React.FC = () => {
  const f = useCurrentFrame();
  const op = interpolate(f, [0, 10], [0, 1], { extrapolateRight: "clamp" });
  const sub = interpolate(f, [46, 62], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ background: P.void, alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          fontFamily: FONT,
          fontWeight: 300,
          fontSize: 210,
          color: TIER.known,
          opacity: op,
          letterSpacing: -4,
        }}
      >
        A&rsquo;right
      </div>
      <div
        style={{
          fontFamily: FONT,
          fontSize: 38,
          fontStyle: "italic",
          color: P.inkMuted,
          opacity: sub,
          marginTop: 26,
        }}
      >
        she answers at full speed, and does not check your face
      </div>
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 4 · TAKEN IN — 1:11-1:31 ══════════════════════════════════════ */

/** su + -yunuz. Two pieces you know, stacked into a word you have never heard. */
const Shot_Suyunuz: React.FC = () => {
  const f = useCurrentFrame();
  const join = interpolate(f, [40, 92], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.inOut(Easing.cubic),
  });
  const gap = interpolate(join, [0, 1], [150, 0]);
  const merged = f > 96;
  const glow = interpolate(f, [96, 130], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ background: "#2a1f18" }}>
      <IstanbulPlate />
      <AbsoluteFill style={{ background: "rgba(20,12,8,0.34)" }} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        {merged ? (
          <div
            style={{
              fontFamily: FONT,
              fontSize: 210,
              fontWeight: 300,
              color: TIER.known,
              letterSpacing: -3,
              textShadow: `0 0 ${110 * glow}px rgba(242,197,110,0.4)`,
            }}
          >
            suyunuz
          </div>
        ) : (
          <div style={{ display: "flex", alignItems: "baseline", gap }}>
            <div style={{ fontFamily: FONT, fontSize: 190, fontWeight: 300, color: TIER.known }}>
              su
            </div>
            <div style={{ fontFamily: FONT, fontSize: 190, fontWeight: 300, color: "#2fa4a0" }}>
              yunuz
            </div>
          </div>
        )}
        <div
          style={{
            fontFamily: FONT,
            fontSize: 30,
            letterSpacing: 4,
            color: P.inkMuted,
            marginTop: 44,
            opacity: interpolate(f, [8, 26], [0, 1], { extrapolateRight: "clamp" }),
          }}
        >
          WATER &nbsp;+&nbsp; YOURS
        </div>
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

/** The cord over the door, retied with one bead missing. */
const Shot_Cord: React.FC = () => {
  const f = useCurrentFrame();
  const gone = f > 40;
  const op = interpolate(f, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const lineOp = interpolate(f, [56, 72], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ background: "#2a1f18" }}>
      <IstanbulPlate />
      <AbsoluteFill style={{ background: "rgba(20,12,8,0.50)" }} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: op }}>
        <svg width={860} height={230} viewBox="0 0 860 230">
          <path d="M20,40 Q430,150 840,40" stroke="#6b4f35" strokeWidth={7} fill="none" />
          <circle cx={250} cy={112} r={34} fill="#f0ece0" />
          <circle cx={250} cy={112} r={23} fill="#1c39a8" />
          <circle cx={250} cy={112} r={9} fill="#f0ece0" />
          {!gone ? (
            <circle cx={430} cy={131} r={28} fill="#f2c56e" opacity={0.95} />
          ) : (
            <circle
              cx={430}
              cy={131}
              r={28}
              fill="none"
              stroke="#6b4f35"
              strokeWidth={2}
              strokeDasharray="6 8"
              opacity={0.7}
            />
          )}
          <circle cx={610} cy={112} r={34} fill="#f0ece0" />
          <circle cx={610} cy={112} r={23} fill="#1c39a8" />
          <circle cx={610} cy={112} r={9} fill="#f0ece0" />
        </svg>
        <div
          style={{
            fontFamily: FONT,
            fontSize: 92,
            fontWeight: 300,
            color: TIER.known,
            marginTop: 30,
            opacity: lineOp,
          }}
        >
          &ldquo;Kerem&rsquo;in.&rdquo;
        </div>
      </AbsoluteFill>
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ ACT 5 · TITLE — 1:31-1:35 ═════════════════════════════════════════ */

const Shot_Title: React.FC = () => {
  const f = useCurrentFrame();
  const op = interpolate(f, [0, 18], [0, 1], { extrapolateRight: "clamp" });
  const sub = interpolate(f, [26, 46], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const out = interpolate(f, [96, 118], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{ background: P.void, alignItems: "center", justifyContent: "center", opacity: out }}
    >
      <img
        src={staticFile("art/ui/wordmark.png")}
        style={{ width: 960, height: 336, imageRendering: "pixelated", opacity: op }}
      />
      <div
        style={{
          fontFamily: FONT,
          fontSize: 36,
          fontWeight: 300,
          color: P.inkMuted,
          marginTop: 40,
          opacity: sub,
          letterSpacing: 1,
        }}
      >
        Communication is cultural. Knowing the words is not enough.
      </div>
      <Grain />
    </AbsoluteFill>
  );
};

/* ═══ THE FILM ══════════════════════════════════════════════════════════ */

export const Film: React.FC = () => (
  <AbsoluteFill style={{ background: P.void }}>
    {/* Act 0 — the failure */}
    <Sequence durationInFrames={S(1)}>
      <Shot_Dark />
    </Sequence>
    <Sequence from={S(1)} durationInFrames={S(2)}>
      <Shot_SheSpeaks />
    </Sequence>
    <Sequence from={S(3)} durationInFrames={S(3)}>
      <Shot_Glyphs />
    </Sequence>
    <Sequence from={S(6)} durationInFrames={S(1)}>
      <Shot_SheLeaves />
    </Sequence>
    <Sequence from={S(7)} durationInFrames={S(2)}>
      <AbsoluteFill style={{ background: P.void }}>
        <Card lines={["You didn’t understand her."]} />
      </AbsoluteFill>
    </Sequence>

    {/* Act 1 — illegible */}
    <Sequence from={S(9)} durationInFrames={S(3)}>
      <Shot_Signage />
    </Sequence>
    <Sequence from={S(12)} durationInFrames={S(2)}>
      <Shot_Wreck />
    </Sequence>
    <Sequence from={S(14)} durationInFrames={S(5)}>
      <Shot_ThreeVoices />
    </Sequence>
    <Sequence from={S(19)} durationInFrames={S(3)}>
      <AbsoluteFill style={{ background: P.void }}>
        <CityCard name="BERLIN" sub="you cannot read, and you cannot be read" accent={P.amber} />
      </AbsoluteFill>
    </Sequence>

    {/* Act 2 — one word */}
    <Sequence from={S(22)} durationInFrames={S(10)}>
      <Shot_Brot />
    </Sequence>
    <Sequence from={S(32)} durationInFrames={S(6)}>
      <AbsoluteFill style={{ background: P.void }}>
        <Card
          lines={["He didn’t correct you.", "He heard a want, and he answered it."]}
          quiet="for one second, you were a customer"
          size={68}
        />
      </AbsoluteFill>
    </Sequence>

    {/* Act 3a — false clear */}
    <Sequence from={S(38)} durationInFrames={S(3)}>
      <AbsoluteFill style={{ background: "#1b1e26" }}>
        <LondonPlate />
        <AbsoluteFill style={{ background: "rgba(11,10,28,0.55)" }} />
        <CityCard name="LONDON" sub="every word legible, the meaning gone" accent="#e1251b" />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(41)} durationInFrames={S(6)}>
      <Shot_NotBad />
    </Sequence>
    <Sequence from={S(47)} durationInFrames={S(6)}>
      <Shot_Denny />
    </Sequence>
    <Sequence from={S(53)} durationInFrames={S(2)}>
      <Shot_SayingNo />
    </Sequence>

    {/* Act 3b — inside it */}
    <Sequence from={S(55)} durationInFrames={S(3)}>
      <Shot_Bev />
    </Sequence>
    <Sequence from={S(58)} durationInFrames={S(6)}>
      <AbsoluteFill style={{ background: P.void }}>
        <Card lines={["The man I understand perfectly", "has told me nothing true."]} size={64} />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(64)} durationInFrames={S(4)}>
      <AbsoluteFill style={{ background: P.void }}>
        <Card
          lines={["The woman I cannot understand at all", "has never once lied to me."]}
          size={64}
        />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(68)} durationInFrames={S(3)}>
      <Shot_Aright />
    </Sequence>

    {/* Act 4 — taken in */}
    <Sequence from={S(71)} durationInFrames={S(3)}>
      <AbsoluteFill style={{ background: "#2a1f18" }}>
        <IstanbulPlate />
        <AbsoluteFill style={{ background: "rgba(20,12,8,0.22)" }} />
        <CityCard name="İSTANBUL" sub="it feeds you before it asks your name" accent="#2fa4a0" />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(74)} durationInFrames={S(5)}>
      <AbsoluteFill style={{ background: "#2a1f18" }}>
        <IstanbulPlate />
        <AbsoluteFill style={{ background: "rgba(20,12,8,0.46)" }} />
        <Card
          lines={["A glass of tea,", "before a word is exchanged."]}
          quiet="refusing it ends the conversation politely, and permanently"
          size={62}
          accent="#2fa4a0"
        />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(79)} durationInFrames={S(5)}>
      <Shot_Suyunuz />
    </Sequence>
    <Sequence from={S(84)} durationInFrames={S(3)}>
      <AbsoluteFill style={{ background: P.void }}>
        <Card lines={["The table stopped."]} size={96} accent="#2fa4a0" />
      </AbsoluteFill>
    </Sequence>
    <Sequence from={S(87)} durationInFrames={S(4)}>
      <Shot_Cord />
    </Sequence>

    {/* Act 5 — title */}
    <Sequence from={S(91)} durationInFrames={S(4)}>
      <Shot_Title />
    </Sequence>
  </AbsoluteFill>
);
