# Flight artwork

Bitmap assets added on 2026-10-02 without replacing existing artwork.
`FlightStage.gd` draws them separately with nearest texture filtering, a slow
sky pan and a complete aircraft silhouette. Alpha is preserved on the aircraft.

- `cloud-sea.png`: environment plate, 1672 x 941.
- `airliner.png`: transparent sprite, 1879 x 837.
- `airliner-retro.png`: revised, chunkier transparent aircraft, used by the game.
  The first aircraft is retained as a source, not drawn. The revised sprite has
  stepped dark contours, larger square window clusters and flatter shading.
  Its motion snaps to two-pixel positions without rotation or shrinking.
