# Research-paper gameplay video

A 2 min 57 s gameplay overview for linking from the research paper, in two cuts:

| Output | What it is |
| --- | --- |
| `trailer/out/foreign-to-all-gameplay-research.mp4` | With short captions for readers who have not played the game |
| `trailer/out/foreign-to-all-gameplay-research-clean.mp4` | The same cut with no added text apart from the title and end cards |

Every moving picture is the game's own frames and sound, recorded by Godot's
movie writer at a fixed 30 fps. The edit only cuts between moments and adds
captions; nothing in the footage is altered.

## How the footage was played

`tools/research_film_capture.gd` plays each segment through the game's real
input paths:

- walking with the walk actions and pressing E;
- a drawn mouse pointer that moves, hovers and clicks menus, replies and buttons
  (the movie writer cannot record the system cursor);
- typing a guess into the word panel ("recycling?" for *Pfand*);
- waiting for each recorded voice line to finish, then allowing reading time.

Replies are chosen by what they say (`REPLIES`), and some are deliberately the
wrong reading (the coin for Kerstin, "I could." for Val), because the game
treats a misreading as a scene of its own.

Segments start from a set point in the journey rather than from one continuous
save:

| Segment | Starts from | Recording |
| --- | --- | --- |
| `opening` | the title screen, New Journey | title, creator, the full opening, the first trade in the Kiez |
| `berlin` | Mitte at 07:30, bed already found | Kerstin's chapter 1, then the notebook (J) |
| `flight` | Berlin airport at 11:00 | the check-in desk, the route map, the flight to London |
| `london` | the terrace at 10:30, just arrived | Val's chapter 0; the neighbour's bins encounter is marked as met so it does not interrupt |
| `cities` | six streets in turn | a short walk in İstanbul, Paris, Moscow, Mumbai, Tokyo and Mexico City |

The alien in every segment wears the same choices made in the creator.
Saves and settings go to a disposable test profile, never the player's own.

## Rebuild

Run from the project root. Each raw AVI is about 6.5 MB per second, so
transcode it and delete it afterwards.

```sh
G="C:/Users/Arda/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
for s in opening berlin flight london cities; do
  "$G" --path . --resolution 1920x1080 --write-movie .build/research-capture/$s.avi --fixed-fps 30 \
    --script res://tools/research_film_capture.gd -- $s
  ffmpeg -i .build/research-capture/$s.avi -c:v libx264 -crf 14 -preset slow -pix_fmt yuv420p \
    -c:a aac -b:a 256k trailer/public/research/film/$s.mp4
done
cp trailer/public/steam/music/title.ogg trailer/public/research/music/title.ogg
cd trailer
npx remotion render src/index.ts ResearchGameplay ../.build/research-capture/ResearchGameplay-raw.mp4 --codec h264 --crf 17
npx remotion render src/index.ts ResearchGameplayClean ../.build/research-capture/ResearchGameplayClean-raw.mp4 --codec h264 --crf 17
# Master: the game's own mix sits near -24.6 LUFS; lift it to about -16 with a peak limiter.
for pair in "ResearchGameplay foreign-to-all-gameplay-research" "ResearchGameplayClean foreign-to-all-gameplay-research-clean"; do
  set -- $pair
  ffmpeg -i ../.build/research-capture/$1-raw.mp4 -c:v copy \
    -af "volume=8.6dB,alimiter=limit=0.8:attack=5:release=60:level=false" \
    -c:a aac -b:a 256k -ar 48000 -movflags +faststart out/$2.mp4
done
```

`FILM_DEBUG=1` and the `kiez` segment (the first trade on its own) are for
iterating on the script without the movie writer. Debug runs are not paced, so
they skip waiting for voices. A run that gets stuck stops itself after
420 seconds of footage.

If the game changes, recheck the cut points in `Gameplay.tsx` (`EDIT`, in
source seconds) against the new recordings: a contact sheet with timestamps
is the quickest way.
