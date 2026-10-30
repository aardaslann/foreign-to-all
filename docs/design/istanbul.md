# Istanbul — Design Bible

> *Foreign to All* — region 3 of 3. Holder of `shard_istanbul` ("Bright fragment"),
> strung above Yusuf's doorway between two blue glass eyes.
>
> Status: **design.** Godot is not installed here; nothing in this document has
> been run or play-tested.

---

## 0. The thesis, restated for this city

Berlin was **illegible** — you cannot read, and you cannot be read.
London was **fluent and alone** — every word legible, the meaning gone.

Istanbul is **indebted**. It does not make you earn anything. It sits you down
and feeds you before it asks your name, and by the time you want the fragment
you are inside a house, and the fragment belongs to that house.

The alien has spent two cities learning to settle up and owe nothing. Berlin
taught it to pay the correct fee. London taught it to find the correct channel.
Both instincts are *wrong here*, and the game must let the player run them and
fail, twice, before the way in becomes visible.

| | Berlin | London | Istanbul |
|---|---|---|---|
| **What is hidden** | the word | the speaker | the obligation |
| **What you accumulate** | vocabulary | ears | debt, and the willingness to carry it |
| **Failure looks like** | a wall of glyphs | acting confidently on a misread | settling up — closing the thing that was opening |
| **Emotional register** | bewilderment | embarrassment | exposure |

Bewilderment is lonely. Embarrassment is social. **Exposure is intimate** — it
requires someone to have decided about you, in your favour, before you earned it.

---

## 1. The read — what makes an Istanbul street not Berlin and not London

Berlin sits **back** from you: wide, flat-fronted, generous pavement, a lot of sky.
London sits **on top of** you: narrow, busy roofline, a hole in front of every house.
Istanbul sits **above and below** you. The city is on a hill and never lets you forget.

**The identifying silhouette element is the `cumba`** — the closed timber bay
window that juts out over the street on brackets, at first-floor level, from
both sides at once. Berlin's facades are flat. London's project downward into a
basement void. Istanbul's project *outward, overhead*, and they nearly touch.
If the player sees a black cut-out of two upper storeys leaning toward each
other across a narrow gap, that is Istanbul and nowhere else.

Five differences to draw every plate from:

1. **The ground is never level.** Streets are stepped. Draw the pavement as a
   stair, not a plane — three or four risers across the width of the screen.
   Doors sit at different heights along the same street. Berlin and London are
   both flat; this one costs the player nothing mechanically and reads instantly.

2. **The sky is netted.** Overhead: electrical cable strung in tangles pole to
   pole, laundry lines between balconies, string lights, and awnings cantilevered
   out over the shopfronts. Very little open sky, but the light is *warm* —
   the opposite of London, where the sky is a closed grey lid.

3. **Timber over masonry.** A stone or plastered ground floor, timber above,
   painted in colours that have faded unevenly: ochre, terracotta, dusty rose,
   mint, pale blue. Balat's houses are famous for exactly this. Never uniform
   — every house a different colour, every colour sun-bleached on one side.

4. **Ironwork, not railings.** Ornate iron balconies, small and shallow, with
   things on them: pots, a satellite dish, a drying rack, a cat.

5. **Cats hold the ground.** They are on the steps, the wall, the stool, the
   car roof. They are not decoration — they are the only inhabitants who are
   completely at ease, and the alien notices that before it notices anything else.

---

## 2. Palette

İznik ceramic supplies the saturated accents; Balat's housing supplies the
mid-tones; sun-bleached plaster supplies the ground. Warmer than Berlin,
*much* warmer than London.

| Hex | Name | Where it goes |
|---|---|---|
| `#2a1f18` | shadow ground | under awnings, inside the arcade, the void |
| `#4a3626` | timber dark | brackets, shutters, the underside of a cumba |
| `#6b4f35` | timber | the upper storeys, unpainted or worn back to it |
| `#8a6f4e` | worn plaster | ground floors, walls that have been repaired often |
| `#c9a878` | sun plaster | the lit face of everything — the city's base note |
| `#e8d5b0` | bleached | the top of a wall where the sun sits longest |
| `#b5563c` | terracotta | roof pantiles, pots, the warm house |
| `#8c4a3a` | roof shadow | the underside of every pantile course |
| `#a8574f` | dusty rose | one house in five, faded unevenly |
| `#7d9b6f` | mint | one house in seven — Balat green, chalky |
| `#5a7a8c` | pale blue | shutters, the cool house |
| `#3d3a34` | cable | the netting overhead, ironwork, the stove |

**İznik accents** — saturated, used *only* on ceramic, tile, glass and the eye.
Never on architecture.

| Hex | Name | Note |
|---|---|---|
| `#1c39a8` | cobalt | the İznik signature; the deep blue of the eye |
| `#2fa4a0` | turquoise | copper oxide, added ~1520; heavens, holiness |
| `#c8453a` | bole red | Armenian bole — a *raised* slip, tomato-red, tactile |
| `#1f7a5a` | emerald | copper + cobalt |
| `#f0ece0` | tile white | the ground every İznik pattern sits on |

**Composition rule.** An Istanbul plate is warm mid-tones almost everywhere,
with İznik saturation appearing *only* where a real object would carry it: a
tiled panel, a tea glass, a stack of bowls, a nazar. The accents are small,
numerous and scattered — the exact opposite of London, where one statutory
accent dominates a grey plate. Istanbul has no statutory colour. It has jewellery.

---

## 3. The two districts

### `carsi` — the market street (arrival)

Where the plane leaves you. A stepped, covered-ish market lane: awnings from
both sides nearly meeting overhead, stalls at ground level, cumbas above,
cables between. Crates, a simit cart, plastic stools outside every shop, tea
glasses on a tray going somewhere. The han's gate is on this street — a big
studded timber door in a stone arch, deliberately unremarkable.

### `han` — the courtyard

Through the gate. **This is the reveal of the act**, and it must feel like
stepping into a different pressure: after the netted, stepped, noisy lane, a
rectangular open courtyard, two storeys of **porticoed gallery** running all
the way round on stone piers, a **şadırvan** (fountain) in the middle, one tree,
and workshop doors under the arcade. Open sky above — the *only* open sky in
Istanbul — because the courtyard is a hole punched up through the city.

Yusuf's shop is one door under the arcade. Above its doorway, on a cord between
two blue glass eyes, is the bright fragment.

---

## 4. Buildings, localised

| Building | Turkish | The read | Social script the alien gets wrong |
|---|---|---|---|
| Hotel | `OTEL` / `PANSİYON` | family-run, a key on a wooden fob, a landing with a fridge | offering to pay in advance reads as distrust |
| Money exchange | `DÖVİZ` | a booth with a running LED rate board, no commission line | haggling here is absurd; haggling elsewhere is mandatory |
| Metro | `METRO` / `MARMARAY` | jeton and İstanbulkart, turnstiles, tiled tunnel | the jeton is not change; it cannot be spent |
| Restaurant | `LOKANTA` (esnaf lokantası) | steam trays behind glass, you point at food, not at words | asking the price first is rude, not prudent |
| Police | `KARAKOL` | flag, a desk, tea offered even here | refusing the tea in a police station is a mistake too |
| Hospital | `HASTANE` / `ACİL` | red crescent, a crowded corridor, family everywhere | you are never asked to be alone; being alone is the anomaly |
| Airport | `HAVALİMANI` / `GİDİŞ` | bright, enormous, the only cold room | — |

Signage vocabulary to use verbatim: `ÇIKIŞ` (exit), `GİRİŞ` (entrance),
`ACİL` (emergency), `ECZANE` (pharmacy), `NÖBETÇİ ECZANE` (duty pharmacy),
`AÇIK`/`KAPALI` (open/closed), `DİKKAT` (caution), `GİDİŞ` (departures).

---

## 5. The language mechanic — per-stem, with suffixes

Turkish is agglutinative: one stem takes a stack of suffixes, and the stack
carries what English would use whole words for. Berlin's model was per-word.
London's was per-speaker. **Istanbul's is per-stem** — the player learns a stem,
and then keeps meeting it wearing clothes they cannot take off.

The renderer shows the known stem plainly and the unknown suffixes as glyphs:

    ev            → "house"              (stem known)
    ev⟟◈          → "house-?"            (ev-de, "in the house")
    ev⟟◈⟟         → "house-?-?"          (ev-de-ki, "the one in the house")
    ev◈⟟◈⟟◈       → the alien is lost again, and it is the *same word*

That is the whole feeling: recognising the root of a word and still not knowing
what has been done to it. Turkish is unrelated to German and English, so there
are **almost no cognate freebies** — this is the hardest city, which is correct
for the last one.

Stems worth teaching, in rough order of first encounter:

| Stem | Meaning | Suffixed forms the player will meet | Where |
|---|---|---|---|
| `ev` | house | evde, evden, evimiz | the han, Meryem |
| `çay` | tea | çayınız, çaydan, çaycı | everywhere, constantly |
| `su` | water | suyu, sudan | the fountain, the table |
| `ekmek` | bread | ekmeği, ekmekle | the lokanta |
| `yol` | road/way | yolu, yoldan, yolcu | the metro, the airport |
| `gel` | come | gelin, geliyor, gelsene | Yusuf, calling you in |
| `otur` | sit | oturun, oturuyor | the stool — the whole act, in one stem |
| `ye` | eat | yiyin, yemek, yemedin | the fourth plate |
| `var` | there is | var mı, vardı | the market |
| `yok` | there isn't | yoktu, yok mu | the market; also means simply "no" |
| `teşekkür` | thanks | teşekkürler, teşekkür ederim | every refusal the player should not make |
| `buyurun` | — | (unanalysable; *do not* translate it) | offered with everything |

`buyurun` is the key vocabulary joke and should never resolve to a gloss. It
means here-you-are / please / come-in / go-ahead / what-can-I-do, depending
entirely on the hand that comes with it. The journal entry for it should stay
uncertain permanently — the alien's guess field is the only place it exists.

---

## 6. The social script, and how Istanbul punishes competence

Every failure state in this act is a thing the player learned to do *correctly*
in Berlin or London.

- **Refusing tea** — or worse, paying for it. Berlin: settle up. Here: the glass
  is not a transaction, and treating it as one ends the conversation politely
  and permanently.
- **Standing** — Yusuf will not talk business standing up. Sitting down and
  letting an hour pass with nothing agreed *is the work*, and the player who
  optimises will skip it.
- **Stopping eating too early.** You are full. There is a fourth plate. Stopping
  says the food was not good.
- **Taking the hotel room.** They will offer a bed. The hotel is right there and
  the player has money. Booking it is the last available polite refusal and it
  undoes most of the week.
- **Accepting payment for the unpaid work.** Sweeping the shop, carrying trays,
  sitting with Meryem while she does not need help — and then refusing the money
  Yusuf presses on you. The exact inverse of Berlin, where refusing pay would
  have been incomprehensible.
- **Offering money for the charm.** *Price is the insult.* It says his luck has
  a number on it and that he looks like a man who needs cash.

By the end the player is not a customer. That is the only status that can get
the charm down.

---

## 7. Yusuf, Kerem, Meryem

**Yusuf** keeps a shop in the han. Warm, unhurried, and completely immovable on
the one thing. He is not withholding the fragment; he genuinely does not
consider it a thing that can change hands.

**Kerem**, his brother, bought it off a runner four years ago, thought it was
pretty, drilled a hole in it and hung it up as a charm. Kerem is not here any
more. The shop has done well since. Nobody in the family thinks those two facts
are unrelated, and nobody would say so out loud.

**Meryem**, their mother, feeds whoever is in the shop at the hour she feeds
people. She never once asks the alien a question it cannot answer. She asks it
whether it is hungry — a question that can be answered with a plate.

The drilled hole matters. It is damage, done in ignorance, by someone who is
gone, and it is the reason the fragment can be worn at all. When the player
finally gets it down, it does not arrive clean.

---

## 8. Anti-cliché rules

Deliberate exclusions. None of the following appear anywhere in this region:

- No belly dancers, no hookah lounges, no flying carpets, no snake charmers.
- No minaret silhouetted against a sunset as set dressing. Mosques exist in the
  skyline because the city has them, not as a signifier of exoticism.
- No haggling minigame at the han. Yusuf is not a rug seller archetype; the
  entire point is that he will not trade.
- No character speaks in broken, article-dropping English. When Turkish is
  rendered in English it is rendered in *fluent* English — the alien's problem
  is comprehension, never the speaker's competence.
- Warmth is not naivety. Meryem feeding the alien is a considered act by an
  adult who has decided something, not folksy instinct.
- The call to prayer, if used, is ambient and unremarked. The alien does not
  editorialise about it.
