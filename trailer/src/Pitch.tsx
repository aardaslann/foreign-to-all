import React from "react";
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  useCurrentFrame,
  spring,
  useVideoConfig,
  staticFile,
  random,
} from "remotion";
import {
  Ground,
  Actor,
  Bubble,
  Punch,
  Caption,
  DetailIcon,
  DETAILS,
  Glyphs,
  FONT,
  GAME_FONT,
  P,
  TIER,
  read,
  r,
} from "./lib/pitch";
import { shuffledGlyphs } from "./lib/glyphs";

/**
 * FOREIGN TO ALL — 1:43
 *
 * Every delay in this file is chained off `read(n)` — the frames a viewer
 * needs for n words. A second line never lands before the first has been
 * read, and no shot outlives its last line by more than about half a second.
 *
 * The palette is the game's throughout, so the end card is not a costume
 * change: it is where the film was heading all along.
 */

const A = "renate";
const B = "weber";
const YOU = "commuter_f";
const VENDOR = "lukas";

const LEFT = 640;
const RIGHT = 1280;
/** Sprites are 320px tall from y=500, so a tail at 476 sits just off the head. */
const SPEAK = 476;
/** A glyph string is registered, not read — about eight tenths of a second. */
const SEEN = 24;

/* ═══ 1 · THE FAILURE EVERYONE KNOWS ═══════════════════════════════════ */
/* glyphs 55 → seen 24 → "???" 85 → seen 24 → caption 115 → read 24 → 145 */

const Meet: React.FC = () => {
  const f = useCurrentFrame();
  const ax = interpolate(f, [0, 44], [260, LEFT], { extrapolateRight: "clamp" });
  const bx = interpolate(f, [0, 44], [1700, RIGHT], { extrapolateRight: "clamp" });
  const walking = f < 44;
  return (
    <AbsoluteFill>
      <Actor who={A} x={ax} dir="right" anim={walking ? "walk" : "idle"} />
      <Actor who={B} x={bx} dir="left" anim={walking ? "walk" : "idle"} />
      <Bubble tailX={LEFT} tailY={SPEAK} side="left" delay={55}>
        <Glyphs word="merhaba nasilsin" />
      </Bubble>
      <Bubble tailX={RIGHT} tailY={SPEAK} side="right" delay={85} size={46}>
        ? ? ?
      </Bubble>
      <Caption delay={115}>Different languages.</Caption>
    </AbsoluteFill>
  );
};

/* ═══ 2 · THE FAILURE NOBODY NOTICES ═══════════════════════════════════ */
/* "I'll think about it." 4w=33 → "Great, thanks!" 2w=24 → beat 18 → thought 4w=33 */

const HiddenNo: React.FC = () => (
  <AbsoluteFill>
    <Actor who={A} x={LEFT} dir="right" />
    <Actor who={B} x={RIGHT} dir="left" />
    <Bubble tailX={LEFT} tailY={SPEAK} side="left" delay={8}>
      I&rsquo;ll think about it.
    </Bubble>
    <Bubble tailX={RIGHT} tailY={SPEAK} side="right" delay={8 + read(4)}>
      Great, thanks!
    </Bubble>
    <Bubble tailX={LEFT} tailY={286} side="left" delay={8 + read(4) + read(2) + 18} thought size={52}>
      <span style={{ color: P.ember }}>That was a no.</span>
    </Bubble>
  </AbsoluteFill>
);

/* ═══ 3 · ONE WORD, A WHOLE FEELING ════════════════════════════════════ */
/* bubble 10 → "Sorry." 1w=24 → caption 34 → 3w=27 → 61 */

const SorryBeat: React.FC<{
  line: string;
  means: string;
  who: string;
  anim: "walk" | "idle";
}> = ({ line, means, who, anim }) => {
  const f = useCurrentFrame();
  const x = anim === "walk" ? interpolate(f, [0, 84], [430, 1560]) : 800;
  return (
    <AbsoluteFill>
      <Actor who={YOU} x={1160} dir="left" />
      <Actor who={who} x={x} dir="right" anim={anim} />
      <Bubble tailX={x} tailY={SPEAK} side="left" delay={10}>
        {line}
      </Bubble>
      <Caption delay={10 + read(1)}>
        means <b style={{ color: P.text }}>{means}</b>
      </Caption>
    </AbsoluteFill>
  );
};

/* three bubbles 2/16/30, last seen by 54 → headline 54 → 4w=33 → 97 */
const ThreeMeanings: React.FC = () => (
  <AbsoluteFill>
    <Bubble tailX={420} tailY={390} side="right" delay={2} size={44}>
      Sorry.
    </Bubble>
    <Bubble tailX={930} tailY={470} side="right" delay={16} size={44}>
      Sorry.
    </Bubble>
    <Bubble tailX={1500} tailY={390} side="left" delay={30} size={44}>
      Sorry?
    </Bubble>
    <Punch lines={["One word.", "Three meanings."]} delay={54} size={92} y={230} accentIndex={1} />
  </AbsoluteFill>
);

/** Every language keeps a word carrying a feeling the others can't. */
const WORDS: [string, string, string[]][] = [
  ["English", "sorry", ["excuse me", "move", "pardon?", "I regret it"]],
  ["German", "doch", ["no —", "actually,", "yes it is"]],
  ["Turkish", "buyurun", ["here you are", "please", "come in", "go ahead"]],
];

/* columns land 6/22/38, meanings done ~79, scan 45 → caption 124 → 8w=57 → 181 */
const Untranslatable: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill style={{ justifyContent: "center" }}>
      <div style={{ display: "flex", padding: "0 150px", gap: 60 }}>
        {WORDS.map(([lang, word, means], i) => {
          const t = r(f, 6 + i * 16, 24);
          return (
            <div
              key={word}
              style={{
                flex: 1,
                opacity: t,
                transform: `translateY(${(1 - t) * 32}px)`,
                textAlign: "center",
              }}
            >
              <div
                style={{
                  fontFamily: FONT,
                  fontWeight: 700,
                  fontSize: 22,
                  letterSpacing: "0.22em",
                  textTransform: "uppercase",
                  color: P.amber,
                }}
              >
                {lang}
              </div>
              <div
                style={{
                  fontFamily: FONT,
                  fontWeight: 800,
                  fontSize: 88,
                  letterSpacing: "-0.04em",
                  color: P.text,
                  margin: "14px 0 22px",
                }}
              >
                {word}
              </div>
              {means.map((m, j) => (
                <div
                  key={m}
                  style={{
                    fontFamily: FONT,
                    fontWeight: 600,
                    fontSize: 32,
                    lineHeight: 1.45,
                    color: P.muted,
                    opacity: r(f, 26 + i * 16 + j * 7, 16),
                  }}
                >
                  {m}
                </div>
              ))}
            </div>
          );
        })}
      </div>
      <Caption delay={124} y={906}>
        Every language hides a feeling the others can&rsquo;t.
      </Caption>
    </AbsoluteFill>
  );
};

/* ═══ 4 · CULTURE ══════════════════════════════════════════════════════ */

/**
 * The tea. Offered before a word is exchanged; refusing it closes the
 * conversation politely and permanently. Nobody ever explains this.
 */
const Tea: React.FC<{ accept: boolean }> = ({ accept }) => {
  const f = useCurrentFrame();
  const out = r(f, 12, 40);
  const back = accept ? 0 : r(f, 62, 32);
  const t = out - back;
  const cupX = LEFT + 150 + t * 400;
  const cupY = 470 - Math.sin(t * Math.PI) * 46;
  const turned = !accept && f > 96;
  const happy = accept && f > 58;

  return (
    <AbsoluteFill>
      <Actor who={A} x={LEFT} dir={turned ? "left" : "right"} bob={happy} />
      <Actor who={B} x={RIGHT} dir="left" bob={happy} />

      <DetailIcon kind="cup" x={cupX} y={cupY} size={72} color={turned ? "#5a5170" : P.glow} />
      {happy ? (
        <DetailIcon kind="cup" x={LEFT + 130} y={470} size={72} color={P.glow} opacity={r(f, 62, 18)} />
      ) : null}

      {!accept ? (
        <Bubble tailX={RIGHT} tailY={SPEAK} side="right" delay={40} size={38}>
          No, thank you.
        </Bubble>
      ) : null}

      {/* refused: bubble 40 → 3w=27 → cup back 62-94 → turn 96 → caption 100 → 7w=51 */}
      {/* accepted: cup lands 52 → second cup 62 → caption 70 → 6w=45 */}
      <Caption delay={accept ? 70 : 100}>
        {accept ? "Accept it, and you're a guest." : "Refuse it, and the conversation is over."}
      </Caption>
    </AbsoluteFill>
  );
};

/* ═══ 5 · WHAT A STEREOTYPE IS ═════════════════════════════════════════ */

const TINTS = [P.text, P.text, P.amber, P.text, P.mint, P.ember, P.muted];

const SWARM = Array.from({ length: 21 }).map((_, i) => ({
  kind: DETAILS[i % DETAILS.length],
  ring: Math.floor(i / 7),
  slot: i % 7,
  size: 40 + ((i * 13) % 34),
  tint: TINTS[i % 7],
}));

const RichPerson: React.FC<{ strip?: boolean }> = ({ strip }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  return (
    <AbsoluteFill>
      <Actor who={B} x={960} y={470} scale={11} grey={strip ? f > 30 : false} />
      {SWARM.map((d, i) => {
        const base = (d.slot / 7) * Math.PI * 2 + d.ring * 0.45;
        const ang = base - Math.PI / 2 + f / (240 + d.ring * 90);
        const inR = spring({ frame: f - 6 - i * 3, fps, config: { damping: 14, mass: 0.6 } });
        const out = strip
          ? interpolate(f, [4 + i * 2, 40 + i * 2], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })
          : 0;
        const ring = 250 + d.ring * 150;
        const rad = strip ? ring + out * 1100 : 90 + inR * (ring - 90);
        return (
          <DetailIcon
            key={i}
            kind={d.kind}
            x={960 + Math.cos(ang) * rad}
            y={540 + Math.sin(ang) * rad * 0.46}
            size={d.size}
            color={strip ? "#4a4360" : d.tint}
            opacity={strip ? 1 - out : inR * 0.95}
            rot={Math.sin(f / 40 + i) * 9}
          />
        );
      })}
    </AbsoluteFill>
  );
};

/* ═══ 6 · THE GAME ═════════════════════════════════════════════════════ */

/* signs 6-46 → caption 48 → 9w=63 → 111 */
const Street: React.FC = () => {
  const f = useCurrentFrame();
  const x = interpolate(f, [0, 100], [440, 1180]);
  const signs = ["apotheke", "bäckerei", "polizei", "fundbüro", "ausgang"];
  return (
    <AbsoluteFill>
      {signs.map((s, i) => {
        const t = r(f, 6 + i * 8, 20);
        return (
          <div
            key={s}
            style={{
              position: "absolute",
              left: 130 + i * 360,
              top: 180 + (i % 3) * 125,
              fontFamily: FONT,
              fontWeight: 700,
              fontSize: 44,
              opacity: t * 0.9,
              transform: `translateY(${(1 - t) * 20}px)`,
            }}
          >
            <Glyphs word={s} color={P.borderHi} spacing={8} />
          </div>
        );
      })}
      <Actor who={YOU} x={x} dir="right" anim="walk" />
      <Caption delay={48}>So we built a place where you&rsquo;re the foreigner.</Caption>
    </AbsoluteFill>
  );
};

/* vendor glyphs 6 → seen 24 → "???" 40 → seen 24 → 64 */
const AskFails: React.FC = () => (
  <AbsoluteFill>
    <Actor who={YOU} x={LEFT} dir="right" />
    <Actor who={VENDOR} x={RIGHT} dir="left" />
    <Bubble tailX={RIGHT} tailY={SPEAK} side="right" delay={6}>
      <Glyphs word="was möchten sie" color={P.borderHi} />
    </Bubble>
    <Bubble tailX={LEFT} tailY={SPEAK} side="left" delay={6 + SEEN + 12} size={46}>
      ? ? ?
    </Bubble>
  </AbsoluteFill>
);

/**
 * The learning moment, in three beats.
 *
 * 1. The baker holds out a loaf and names it. The word is still glyphs, but
 *    one of them is lit, and the bread is right there beside it.
 * 2. Watching the loaf while hearing the word, the glyphs settle into `brot`.
 * 3. Next time, you use it — and it works.
 *
 * This is the game's "pointed" exposure event: a word said while the thing
 * it means is visible.
 */
const BakerNames: React.FC = () => {
  const f = useCurrentFrame();
  const loaf = r(f, 14, 26);
  return (
    <AbsoluteFill>
      <Actor who={YOU} x={LEFT} dir="right" />
      <Actor who={VENDOR} x={RIGHT} dir="left" />
      <DetailIcon
        kind="bread"
        x={RIGHT - 210}
        y={604 - loaf * 44}
        size={84}
        color={P.glow}
        opacity={loaf}
      />
      <Bubble tailX={RIGHT} tailY={SPEAK} side="left" delay={6}>
        <Glyphs word="ein" color={P.borderHi} />{" "}
        <span style={{ color: P.amber }}>brot</span>{" "}
        <Glyphs word="bitte" color={P.borderHi} />
      </Bubble>
      <Caption delay={48}>He says it while handing it over.</Caption>
    </AbsoluteFill>
  );
};

/* glyphs settle 20-70 → word held → meaning 78 → 5w=39 → 117 */
const ItClicks: React.FC = () => {
  const f = useCurrentFrame();
  const flip = f > 46;
  const glow = r(f, 46, 28);
  const meaning = r(f, 62, 22);
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", transform: "translateY(-46px)" }}>
      <div
        style={{
          fontFamily: FONT,
          fontWeight: 800,
          fontSize: 186,
          letterSpacing: flip ? "-0.04em" : "0.08em",
          color: flip ? P.amber : TIER.glimpsed,
          textShadow: `0 0 ${100 * glow}px rgba(242,197,110,0.4)`,
        }}
      >
        {flip ? "brot" : <Glyphs word="brot" color={TIER.glimpsed} spacing={16} />}
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 24,
          marginTop: 40,
          opacity: meaning,
          transform: `translateY(${(1 - meaning) * 18}px)`,
        }}
      >
        <div style={{ position: "relative", width: 82, height: 82 }}>
          <DetailIcon kind="bread" x={41} y={41} size={82} color={P.text} />
        </div>
        <div style={{ fontFamily: FONT, fontWeight: 700, fontSize: 62, color: P.text }}>bread</div>
      </div>
    </AbsoluteFill>
  );
};

/* bubble 6 → 2w=24 → loaf crosses 40-80 → caption 84 → 6w=45 → 129 */
const UseIt: React.FC = () => {
  const f = useCurrentFrame();
  const hand = r(f, 40, 40);
  const loafX = RIGHT - 170 - hand * 340;
  const loafY = 500 - Math.sin(hand * Math.PI) * 54;
  const happy = f > 82;
  return (
    <AbsoluteFill>
      <Actor who={YOU} x={LEFT} dir="right" bob={happy} />
      <Actor who={VENDOR} x={RIGHT} dir="left" bob={happy} />
      <Bubble tailX={LEFT} tailY={SPEAK} side="left" delay={6} tone="amber" size={44}>
        Brot, bitte.
      </Bubble>
      {f > 34 ? <DetailIcon kind="bread" x={loafX} y={loafY} size={80} color={P.glow} /> : null}
      <Caption delay={84}>Now you can ask for it yourself.</Caption>
    </AbsoluteFill>
  );
};

/* ═══ 7 · CLOSE ════════════════════════════════════════════════════════ */
/* walk 0-40 → "Merhaba." 46 → 1w=24 → reply 74 → 1w=24 → 98 */

const Understood: React.FC = () => {
  const f = useCurrentFrame();
  const ax = interpolate(f, [0, 40], [260, LEFT], { extrapolateRight: "clamp" });
  const bx = interpolate(f, [0, 40], [1700, RIGHT], { extrapolateRight: "clamp" });
  const walking = f < 40;
  return (
    <AbsoluteFill>
      <Actor who={A} x={ax} dir="right" anim={walking ? "walk" : "idle"} bob={f > 86} />
      <Actor who={B} x={bx} dir="left" anim={walking ? "walk" : "idle"} bob={f > 86} />
      <Bubble tailX={LEFT} tailY={SPEAK} side="left" delay={46}>
        Merhaba.
      </Bubble>
      <Bubble tailX={RIGHT} tailY={SPEAK} side="right" delay={74} tone="amber">
        Merhaba!
      </Bubble>
    </AbsoluteFill>
  );
};

/**
 * The end card IS the game's title screen — its plate, its wordmark, its
 * drifting glyph motes, and a line set the way the menu buttons are set:
 * Godot's default font, #c7c2fa, wide tracking, ornamented with ◈.
 * It dissolves in over the previous shot rather than cutting.
 */
/** TitleScreen._randomise_glyphs(): six glyphs a side, rerolled every 0.35s. */
const shuffle6 = (step: number) => shuffledGlyphs(6, step);

const MOTES = Array.from({ length: 20 }).map((_, i) => ({
  x: random(`mx${i}`) * 1860,
  y0: random(`my${i}`) * 1200,
  speed: 20 + random(`ms${i}`) * 26,
  size: 24 + random(`mz${i}`) * 22,
}));

const Title: React.FC = () => {
  const f = useCurrentFrame();
  const dissolve = interpolate(f, [0, 26], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  // TitleScreen._play_intro(): title, then glyphs, then tagline, then menu
  const title = r(f, 16, 22);
  const glyphs = r(f, 40, 16);
  const tag = r(f, 52, 16);
  const menu = r(f, 66, 20);
  const sub = r(f, 66 + read(3), 20);
  // _process(): a slow brightness pulse on the title row
  const pulse = 0.93 + 0.07 * Math.sin((f / 30) * 0.65);
  // _randomise_glyphs() fires every 0.35s, not the dialogue box's 0.18s
  const gstep = Math.floor(f / 10.5);

  // TitleScreen.tscn sizes, scaled up: this is an end card, not the menu.
  const K = 1.6;
  const big: React.CSSProperties = {
    fontFamily: GAME_FONT,
    fontSize: 72 * K,
    color: "#f5f0ff",
    textShadow: "0 0 5px rgba(97,77,184,0.55), 0 0 14px rgba(97,77,184,0.35)",
    whiteSpace: "pre",
  };

  return (
    <AbsoluteFill style={{ opacity: dissolve, overflow: "hidden", background: P.void }}>
      <img
        src={staticFile("art/scenes/title.png")}
        style={{
          position: "absolute",
          left: -192,
          top: -108,
          width: 2304,
          height: 1296,
          imageRendering: "pixelated",
        }}
      />

      {MOTES.map((m, i) => {
        const y = ((m.y0 - f * (m.speed / 30) + 2400) % 1300) - 100;
        return (
          <div
            key={i}
            style={{
              position: "absolute",
              left: m.x,
              top: y,
              fontFamily: GAME_FONT,
              fontSize: m.size,
              opacity: 0.13,
            }}
          >
            <Glyphs word="x" color="#807acc" spacing={0} />
          </div>
        );
      })}

      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", transform: "translateY(-46px)" }}>
        {/* TitleRow */}
        <div
          style={{
            display: "flex",
            alignItems: "baseline",
            opacity: title,
            filter: `brightness(${pulse})`,
          }}
        >
          <span style={big}>F O R E I G N</span>
          <span style={{ fontFamily: GAME_FONT, fontSize: 30 * K, color: "#ada6e6", whiteSpace: "pre" }}>
            {"  ·  to  ·  "}
          </span>
          <span style={big}>A L L</span>
        </div>

        {/* GlyphRow — six glyphs either side of the one word you can read */}
        <div
          style={{
            display: "flex",
            fontFamily: GAME_FONT,
            fontSize: 15 * K,
            marginTop: 16,
            opacity: glyphs,
            whiteSpace: "pre",
          }}
        >
          <span style={{ color: "#807acc" }}>{shuffle6(gstep)}</span>
          <span style={{ color: "#bdb8f5" }}>{"   s t r a n g e r   "}</span>
          <span style={{ color: "#807acc" }}>{shuffle6(gstep + 7)}</span>
        </div>

        {/* Tagline */}
        <div
          style={{
            fontFamily: GAME_FONT,
            fontWeight: 700,
            fontSize: 13 * K,
            color: "#7085cc",
            marginTop: 12,
            opacity: tag,
          }}
        >
          a stranger in every tongue
        </div>

        {/* where the menu lives — the invitation, styled like the buttons */}
        <div
          style={{
            fontFamily: GAME_FONT,
            fontWeight: 600,
            fontSize: 22 * K,
            color: "rgba(199,194,250,0.76)",
            marginTop: 92,
            opacity: menu,
          }}
        >
          Ready to understand?
        </div>
        <div
          style={{
            fontFamily: GAME_FONT,
            fontWeight: 600,
            fontSize: 22 * K,
            color: "rgba(199,194,250,0.76)",
            marginTop: 26,
            opacity: sub,
          }}
        >
          The whole world is waiting.
        </div>
      </AbsoluteFill>

    </AbsoluteFill>
  );
};

/* ═══ THE CUT ══════════════════════════════════════════════════════════════
 * [shot, duration, overlap?]. Overlap pulls a shot's start back so it can
 * dissolve over the one before it — used once, into the title.
 */
const SHOTS: [React.ReactNode, number, number?][] = [
  [<Meet key="meet" />, 160],
  [<Punch key="obv" lines={["Obvious, right?"]} size={116} />, 14 + read(2) + 14],

  [<HiddenNo key="no" />, 150],
  [
    <Punch key="same" lines={["Same language.", "Still lost."]} size={112} accentIndex={1} accent={P.ember} />,
    14 + 11 + read(4) + 14,
  ],

  [<Punch key="half" lines={["Words are only half of it."]} size={98} />, 14 + read(6) + 14],
  [<SorryBeat key="s1" line="Sorry." means="excuse me" who={B} anim="idle" />, 78],
  [<SorryBeat key="s2" line="Sorry." means="move" who="commuter_m" anim="walk" />, 78],
  [<SorryBeat key="s3" line="Sorry?" means="say that again" who={A} anim="idle" />, 82],
  [<ThreeMeanings key="3m" />, 110],
  [<Untranslatable key="untr" />, 195],
  [
    <Punch key="lookup" lines={["You can look up a word.", "You can't look up the rest."]} size={88} />,
    14 + 11 + read(11) + 14,
  ],

  [<Tea key="tea1" accept={false} />, 165],
  [<Tea key="tea2" accept />, 130],
  [<Punch key="noteach" lines={["Nobody teaches you that."]} size={100} />, 14 + read(4) + 16],
  [
    <Punch key="culture" lines={["That's not language.", "That's culture."]} size={104} accentIndex={1} />,
    14 + 11 + read(5) + 16,
  ],

  [
    <React.Fragment key="rich">
      <RichPerson />
      <Caption delay={72}>A person is a thousand small things.</Caption>
    </React.Fragment>,
    72 + read(7) + 14,
  ],
  [
    <React.Fragment key="strip">
      <RichPerson strip />
      <Caption delay={46}>Take them away, and this is what&rsquo;s left.</Caption>
    </React.Fragment>,
    46 + read(8) + 14,
  ],
  [
    <Punch key="makeup" lines={["When you can't see the rest,", "you make it up."]} size={86} />,
    14 + 11 + read(9) + 14,
  ],
  [<Punch key="stereo" lines={["That's a stereotype."]} size={120} color={P.ember} />, 14 + read(3) + 22],

  [
    <Punch key="live" lines={["Reading about it doesn't work.", "You have to live it."]} size={88} />,
    14 + 11 + read(10) + 14,
  ],
  [<Street key="street" />, 48 + read(9) + 14],
  [<AskFails key="ask" />, 6 + 24 + 12 + 24 + 14],
  [<BakerNames key="names" />, 48 + read(6) + 16],
  [<ItClicks key="clicks" />, 62 + read(5) + 20],
  [<UseIt key="use" />, 84 + read(6) + 16],
  [
    <Punch key="notextbook" lines={["No textbook. No lessons.", "You learned it by living there."]} size={84} accentIndex={1} />,
    14 + 11 + read(9) + 14,
  ],

  [<Understood key="und" />, 120],
  [<Title key="title" />, 182, 26],
];

export const TOTAL = SHOTS.reduce((n, [, d, o]) => n + d - (o ?? 0), 0);

export const Pitch: React.FC = () => {
  let at = 0;
  return (
    <AbsoluteFill>
      <Ground />
      {SHOTS.map(([node, dur, overlap], i) => {
        const from = at - (overlap ?? 0);
        at = from + dur;
        return (
          <Sequence key={i} from={from} durationInFrames={dur}>
            {node}
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};
