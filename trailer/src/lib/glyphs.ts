// scenes/dialogue/DialogueBox.gd:3 and :522 — the exact set and the exact mapping.
export const GLYPHS = "\u25c8\u27df\u2b21\u25c9\u27e2\u27e3\u22c4\u27e4\u27e5\u2b22\u2b23\u2b1f\u2b20\u27e6\u27e7\u27e1";

/** _to_glyphs(): deterministic, so a word always renders the same shape. */
export const toGlyphs = (word: string): string =>
  [...word].map((c) => GLYPHS[c.codePointAt(0)! % GLYPHS.length]).join("");

/** _random_glyphs(): seeded so a render is reproducible frame to frame. */
export const shuffledGlyphs = (len: number, seed: number): string => {
  let s = seed * 9301 + 49297;
  let out = "";
  for (let i = 0; i < len; i++) {
    s = (s * 9301 + 49297) % 233280;
    out += GLYPHS[Math.floor((s / 233280) * GLYPHS.length)];
  }
  return out;
};
