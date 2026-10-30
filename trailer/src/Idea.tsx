import React from "react";
import { AbsoluteFill, Sequence, interpolate, useCurrentFrame } from "remotion";
import { C, SERIF, MONO, T, S, ramp, EXPO, Page, Statement, Rule, Label, Wipe } from "./lib/kit";
import {
  Buyurun,
  SorryFan,
  MeaningStrata,
  Compression,
  ThreeCities,
  UnreadablePage,
} from "./lib/figures";

/**
 * FOREIGN TO ALL — 2:02
 *
 * An argument, not a trailer. The claim: translation is solved and
 * understanding is not, because meaning was never stored in the words; a
 * stereotype is what remains once the context is discarded; and the only way
 * to correct that is to put a person inside the failure rather than describe
 * it to them. The game appears in Part IV as the instrument that does it,
 * and nowhere else.
 *
 * Structure is carried by ground: PAPER is the argument, NIGHT is the
 * experience. The film inverts exactly twice.
 */

/* ── the hinge: a hard wipe between the two halves ─────────────────────── */
const Invert: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const f = useCurrentFrame();
  const t = interpolate(f, [0, 9], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EXPO,
  });
  return (
    <AbsoluteFill style={{ clipPath: `inset(0 ${(1 - t) * 100}% 0 0)` }}>{children}</AbsoluteFill>
  );
};

/* ── a full-bleed statement page, the film's basic unit ────────────────── */
const Say: React.FC<{
  lines: string[];
  night?: boolean;
  section?: string;
  size?: number;
  color?: string;
  label?: string;
  italic?: boolean;
  max?: number;
}> = ({ lines, night, section, size = T.h1, color, label, italic, max = 1420 }) => (
  <Page night={night} section={section}>
    <div style={{ maxWidth: max, width: "100%" }}>
      {label ? (
        <>
          <Label delay={0} color={night ? C.nightSoft : C.inkFaint}>
            {label}
          </Label>
          <div style={{ height: 30 }} />
        </>
      ) : null}
      <Statement
        lines={lines}
        size={size}
        color={color ?? (night ? C.nightType : C.ink)}
        delay={label ? 8 : 0}
        italic={italic}
      />
    </div>
  </Page>
);

/* ── a page whose body is a figure ─────────────────────────────────────── */
const Figure: React.FC<{
  children: React.ReactNode;
  section: string;
  night?: boolean;
  title?: string;
}> = ({ children, section, night, title }) => (
  <Page night={night} section={section} drift={false}>
    <div style={{ width: "100%" }}>
      {title ? (
        <>
          <Label color={night ? C.nightSoft : C.inkFaint}>{title}</Label>
          <div style={{ height: 40 }} />
        </>
      ) : null}
      {children}
    </div>
  </Page>
);

/* ── Part VI · the close ───────────────────────────────────────────────── */
const Close: React.FC = () => {
  const f = useCurrentFrame();
  const out = interpolate(f, [172, 202], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Page drift={false}>
        <div style={{ maxWidth: 1320 }}>
          <Wipe delay={6} lift={40}>
            <div
              style={{
                fontFamily: SERIF,
                fontSize: 116,
                fontWeight: 400,
                letterSpacing: "-0.035em",
                color: C.ink,
                lineHeight: 1.02,
              }}
            >
              Foreign to All
            </div>
          </Wipe>
          <div style={{ height: 40 }} />
          <Rule delay={30} dur={44} width="62%" color={C.cobalt} thickness={2} />
          <div style={{ height: 40 }} />
          <Statement
            lines={["Communication is cultural.", "Knowing the words is not enough."]}
            size={T.h2}
            color={C.inkSoft}
            italic
            delay={44}
            stagger={10}
          />
          <div style={{ height: 64 }} />
          <div
            style={{
              opacity: ramp(f, 84, 30),
              fontFamily: MONO,
              fontSize: 18,
              letterSpacing: "0.22em",
              textTransform: "uppercase",
              color: C.inkFaint,
            }}
          >
            Berlin · London · İstanbul
          </div>
        </div>
      </Page>
    </AbsoluteFill>
  );
};

/* ═══════════════════════════════════════════════════════════════════════ */

export const Idea: React.FC = () => (
  <AbsoluteFill style={{ background: C.paper }}>
    {/* ── I · the untranslatable ─────────────────────────────────────── */}
    <Sequence durationInFrames={S(11)}>
      <Figure section="I · the untranslatable">
        <Buyurun />
      </Figure>
    </Sequence>

    <Sequence from={S(11)} durationInFrames={S(4)}>
      <Say
        section="I · the untranslatable"
        lines={["It means all of these.", "It depends on the hand that comes with it."]}
        size={T.h2}
        italic
      />
    </Sequence>

    {/* ── II · the problem ───────────────────────────────────────────── */}
    <Sequence from={S(15)} durationInFrames={S(4)}>
      <Say section="II · the problem" lines={["We have never been better", "at translation."]} />
    </Sequence>

    <Sequence from={S(19)} durationInFrames={S(4.5)}>
      <Say
        section="II · the problem"
        label="roughly seven thousand living languages"
        lines={["Instant. Free.", "In every pocket on earth."]}
        size={T.h2}
        color={C.inkSoft}
      />
    </Sequence>

    <Sequence from={S(23.5)} durationInFrames={S(4.5)}>
      <Say
        section="II · the problem"
        lines={["And no better", "at understanding one another."]}
        color={C.vermilion}
        size={100}
      />
    </Sequence>

    <Sequence from={S(28)} durationInFrames={S(9)}>
      <Figure section="II · the problem">
        <SorryFan />
      </Figure>
    </Sequence>

    <Sequence from={S(37)} durationInFrames={S(5)}>
      <Say
        section="II · the problem"
        lines={["The words were never", "the hard part."]}
        size={100}
      />
    </Sequence>

    {/* ── III · what a stereotype is ─────────────────────────────────── */}
    <Sequence from={S(42)} durationInFrames={S(11)}>
      <Figure section="III · what a stereotype is" title="where meaning is actually kept">
        <MeaningStrata />
      </Figure>
    </Sequence>

    <Sequence from={S(53)} durationInFrames={S(5)}>
      <Say
        section="III · what a stereotype is"
        lines={["Take all of that away", "and what is left is a stereotype."]}
      />
    </Sequence>

    <Sequence from={S(58)} durationInFrames={S(9)}>
      <Figure section="III · what a stereotype is" title="a stereotype is a compression artifact">
        <Compression start={24} />
      </Figure>
    </Sequence>

    <Sequence from={S(67)} durationInFrames={S(4)}>
      <Say
        section="III · what a stereotype is"
        lines={["Facts have never been", "very good at removing them."]}
        size={T.h2}
      />
    </Sequence>

    {/* ── the dark half sits on a held ground, so the closing wipe has
        something to reveal against ───────────────────────────────────── */}
    <Sequence from={S(71)} durationInFrames={S(44) + 14}>
      <AbsoluteFill style={{ background: C.night }} />
    </Sequence>

    {/* ── IV · the instrument ── the film inverts here ───────────────── */}
    <Sequence from={S(71)} durationInFrames={S(6)}>
      <Invert>
        <Say
          night
          section="IV · the instrument"
          lines={["So do not explain it.", "Build a place where a person can fail."]}
        />
      </Invert>
    </Sequence>

    <Sequence from={S(77)} durationInFrames={S(9)}>
      <Figure night section="IV · the instrument" title="one idea, three ways of being foreign">
        <ThreeCities />
      </Figure>
    </Sequence>

    <Sequence from={S(86)} durationInFrames={S(10)}>
      <Figure night section="IV · the instrument" title="the first hour, as the player sees it">
        <UnreadablePage resolveAt={150} />
      </Figure>
    </Sequence>

    <Sequence from={S(96)} durationInFrames={S(5)}>
      <Say
        night
        section="IV · the instrument"
        lines={[
          "Nobody is told the barrier is real.",
          "They are made to want bread,",
          "and fail to ask for it.",
        ]}
        size={T.h2}
      />
    </Sequence>

    {/* ── V · the turn ───────────────────────────────────────────────── */}
    <Sequence from={S(101)} durationInFrames={S(5)}>
      <Say night lines={["The man I understand perfectly", "has told me nothing true."]} />
    </Sequence>

    <Sequence from={S(106)} durationInFrames={S(5)}>
      <Say night lines={["The woman I cannot understand at all", "has never once lied to me."]} />
    </Sequence>

    <Sequence from={S(111)} durationInFrames={S(4)}>
      <Say
        night
        lines={["Understanding is not translation.", "It is being let in."]}
        color={C.cobaltLit}
        size={94}
      />
    </Sequence>

    {/* ── VI · close ─────────────────────────────────────────────────── */}
    <Sequence from={S(115)} durationInFrames={S(7)}>
      <Invert>
        <Close />
      </Invert>
    </Sequence>
  </AbsoluteFill>
);
