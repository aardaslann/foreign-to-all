// Lifted verbatim from art/world/foreigntoall_world.gpl and
// scenes/dialogue/DialogueBox.gd — never eyeball these.
export const P = {
  void: "#0b0a1c",
  skyMid: "#16132e",
  facade: "#1c1730",
  facade2: "#241d3c",
  windowLit: "#e8c25c",
  windowLit2: "#c89a3c",
  asphalt: "#16171f",
  panel: "#141126",
  panelDark: "#0d0b1a",
  border: "#4c4482",
  ink: "#e8e4f4",
  inkMuted: "#8a84b8",
  amber: "#e8c25c",
  warmGlow: "#f2c56e",
  mint: "#46e8c0",
} as const;

// DialogueBox.gd:496-511
export const TIER = {
  unknown: "#e8e4ff",
  glimpsed: "#b8b4f0",
  partial: "#d8d4ff",
  partialBg: "#35359a",
  known: "#f0eeff",
} as const;
