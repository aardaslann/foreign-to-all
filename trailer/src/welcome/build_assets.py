"""Textures for "Welcome": the paper and the film grain. Seeded, so a rebuild is identical.

    python trailer/src/welcome/build_assets.py
"""
from __future__ import annotations

import struct
import subprocess
import zlib
from pathlib import Path

import numpy as np

OUT = Path(__file__).resolve().parents[2] / "public" / "welcome"


def write_png(path: Path, pixels: np.ndarray) -> None:
    """Grey (H, W) or RGB (H, W, 3) uint8 → PNG, without any imaging library."""
    h, w = pixels.shape[:2]
    colour = 0 if pixels.ndim == 2 else 2
    rows = pixels.reshape(h, -1)
    raw = b"".join(b"\x00" + row.tobytes() for row in rows)
    chunk = lambda tag, data: struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, colour, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    path.write_bytes(png)


def smooth_noise(rng: np.random.Generator, size: int, cells: int) -> np.ndarray:
    """Tileable value noise: a coarse random grid, cosine-interpolated up to `size`."""
    grid = rng.random((cells, cells))
    x = np.linspace(0, cells, size, endpoint=False)
    i0 = np.floor(x).astype(int)
    i1 = (i0 + 1) % cells
    f = (1 - np.cos((x - i0) * np.pi)) / 2
    rows = grid[i0][:, i0] * (1 - f)[None, :] + grid[i0][:, i1] * f[None, :]
    rows1 = grid[i1][:, i0] * (1 - f)[None, :] + grid[i1][:, i1] * f[None, :]
    return rows * (1 - f)[:, None] + rows1 * f[:, None]


def paper(size: int = 1024) -> np.ndarray:
    rng = np.random.default_rng(7)
    mottle = sum(smooth_noise(rng, size, c) / (i + 1) for i, c in enumerate((16, 32, 64)))
    mottle = (mottle - mottle.mean()) / mottle.std()
    fibre = rng.normal(0, 1, (size, size))
    fibre = (fibre + np.roll(fibre, 1, axis=1) + np.roll(fibre, 2, axis=1)) / 3   # a faint horizontal grain
    base = np.array([236, 235, 231], dtype=np.float32)
    shade = 1 + 0.004 * mottle + 0.02 * fibre
    return np.clip(base[None, None, :] * shade[..., None], 0, 255).astype(np.uint8)


def grain(seed: int, size: int = 512) -> np.ndarray:
    rng = np.random.default_rng(100 + seed)
    g = rng.normal(128, 34, (size, size))
    g = (g * 2 + np.roll(g, 1, 0) + np.roll(g, 1, 1)) / 4      # soften to film-like clumps
    return np.clip(g, 0, 255).astype(np.uint8)


def glyph_atlas() -> None:
    """The dialogue box's eight pixel glyphs, upscaled ×16 nearest-neighbour so a CSS mask stays crisp."""
    src = OUT.parent / "art" / "ui" / "glyphs.png"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(src), "-vf", "scale=iw*16:ih*16:flags=neighbor",
                    str(OUT / "glyphs16.png")], check=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    write_png(OUT / "paper.png", paper())
    for i in range(6):
        write_png(OUT / f"grain{i}.png", grain(i))
    glyph_atlas()
    print("wrote", sorted(p.name for p in OUT.glob("*.png")))


if __name__ == "__main__":
    main()
