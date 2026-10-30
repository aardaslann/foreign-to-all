import React from "react";
import { Composition } from "remotion";
import { Pitch, TOTAL } from "./Pitch";
import { Idea } from "./Idea";
import { Film as TrailerV1 } from "./Film";
import { UnderstandingV6, DURATION as V6_DURATION } from "./understanding-v6/Film";
import { UnderstandingV7, DURATION as V7_DURATION } from "./understanding-v7/Film";
import { Welcome, DURATION as WELCOME_DURATION } from "./welcome/Welcome";
import { Steam } from "./steam/Steam";
import { Research } from "./research/Research";

export const FPS = 30;

export const RemotionRoot: React.FC = () => (
  <>
    {/* Research — the paper's gameplay video, real-time footage with and without captions */}
    <Research />
    {/* Steam — store capsules, library art and page background from the game's own art */}
    <Steam />
    {/* Welcome — the message as kinetic type from the game's own pixels: 9:16 for social, 16:9 for everything else */}
    <Composition
      id="WelcomeTall"
      component={Welcome}
      durationInFrames={WELCOME_DURATION}
      fps={FPS}
      width={1080}
      height={1920}
    />
    <Composition
      id="WelcomeWide"
      component={Welcome}
      durationInFrames={WELCOME_DURATION}
      fps={FPS}
      width={1920}
      height={1080}
    />
    {/* v7 — revision 5's film rebuilt on the game's retro art, cast and voices */}
    <Composition
      id="UnderstandingV7"
      component={UnderstandingV7}
      durationInFrames={V7_DURATION}
      fps={FPS}
      width={1920}
      height={1080}
    />
    {/* v6 — Understanding, rebuilt from the game's own art, cast and voices */}
    <Composition
      id="UnderstandingV6"
      component={UnderstandingV6}
      durationInFrames={V6_DURATION}
      fps={FPS}
      width={1920}
      height={1080}
    />
    {/* v3 — the pitch: the idea shown, not argued */}
    <Composition
      id="Film"
      component={Pitch}
      durationInFrames={TOTAL}
      fps={FPS}
      width={1920}
      height={1080}
    />
    {/* v2 — the essay film, kept for reference */}
    <Composition
      id="IdeaV2"
      component={Idea}
      durationInFrames={122 * FPS}
      fps={FPS}
      width={1920}
      height={1080}
    />
    {/* v1 — the game-first trailer, kept for reference */}
    <Composition
      id="TrailerV1"
      component={TrailerV1}
      durationInFrames={95 * FPS}
      fps={FPS}
      width={1920}
      height={1080}
    />
  </>
);
