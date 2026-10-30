# London — Design Bible

> *Foreign to All* — region 2 of 3. Holder of `shard_london` ("Cold fragment"),
> sold on to a dealer.
>
> Status: **design only.** No London scene exists on disk. Nothing in this
> document has been built, run, or play-tested — Godot is not installed here.

---

## 0. The thesis, restated for this city

Berlin taught the player that **words are opaque**. You cannot read the sign, so
you learn the sign, one word at a time, and the fog lifts in patches.

London teaches the harder half: **words are not enough.** Here the alien can
already read most of what is written and much of what is said — and is *more*
lost, not less. The fog is gone and it turns out the fog was never the problem.

So London must not feel like Berlin-with-a-new-palette. It must feel like the
moment the difficulty changes shape. Three inversions carry that:

| | Berlin | London |
|---|---|---|
| **What is hidden** | the word | the *speaker*, and the meaning behind a clear word |
| **What you accumulate** | vocabulary | ears — one person at a time |
| **What failure looks like** | a wall of glyphs | a sentence you read perfectly and act on wrongly |
| **Emotional register** | bewilderment | embarrassment |

Bewilderment is lonely. Embarrassment is *social* — it requires an audience who
understood you fine and is being polite about it. That is the upgrade.

---

## 1. The read — what makes a London street not a Berlin street

Berlin, as built in `MitteBackground.gd` / `Kiez.gd`, is: wide, flat-fronted,
tall-windowed, indigo-and-amber, with generous pavement and a lot of sky. The
city sits *back* from you.

London sits **on top of you**. Design every plate from these five differences:

**1. The street is narrower and the buildings are shorter, but it feels tighter.**
Berlin's Mietshaus is 5–6 storeys with a wide street. A London terrace is 2–4
storeys with a street half the width. Same claustrophobia from the opposite
direction. Reduce street width, reduce building height, keep the rooflines
*busy* — that is where London's density lives.

**2. The roofline is a mess, on purpose.** Berlin's roofline is one long ruled
edge. London's is chimney stacks — clusters of 4–8 pots on every party wall,
staggered, never level, because the terrace steps down the hill. Add TV
aerials, satellite dishes, a slumped parapet, a bit of moss. **The chimney
stacks are the single most identifying silhouette element.** If the player
squints at a black cut-out of the skyline they should know which city it is.

**3. Every house has a hole in front of it.** The basement area: a sunken well
between pavement and front door, guarded by cast-iron railings, crossed by
steps up to a raised front door. Berlin's door meets the pavement. London's
door is *above* the pavement and there is a pit beside it. This gives the
facade a vertical rhythm Berlin does not have: railing / void / steps / stoop /
door, repeated every 5 metres.

**4. The wall is yellow-brown, not grey.** London stock brick — made from
Thames-basin brickearth, fired yellow, then blackened by two centuries of coal
smoke, so it reads as a dirty ochre-grey that goes *warmer* where it is washed
and *sootier* under sills and cornices. Accented with bands of red brick over
window heads and at the corners. Where the ground floor is a shop or a grander
terrace, the brick is rendered over in **stucco**, painted dirty cream, with the
render scored to fake stone blocks. Two materials, one wall.

**5. Sash windows, and they are always a bit wrong.** Vertical sliding sashes,
white-painted, divided into panes, and the top one is nearly always open two
inches — no matter the weather. That two-inch gap, repeated up a whole terrace,
is a free authenticity detail that costs one `draw_rect`.

### The layer stack for a London street plate

Draw in this order. It matches how `MitteBackground.gd` already builds Berlin,
so the London background script can be a sibling, not a rewrite.

```
  ── sky ──────────────────────────────────────────────────────────────
  0  overcast lid          low, close cloud. Never a clear sky in London.
                           No stars. This alone re-reads the whole scene.
  1  sodium bounce         warm-grey glow smeared on the cloud belly from
                           beneath — the city lighting itself back at itself.

  ── far ──────────────────────────────────────────────────────────────
  2  far roofline          silhouette only: chimney stacks, one crane,
                           the ghost of a tower block.

  ── facade ───────────────────────────────────────────────────────────
  3  stock brick field     base wall, with courses hinted, not drawn.
  4  soot gradient         darker under every horizontal — sills, cornice,
                           the underside of the parapet. Dirt falls down.
  5  red brick bands       flat arches over window heads; quoins at corners.
  6  stucco ground floor   on some houses only. Never all of them.
  7  sash windows          white frame, glazing bars, top sash open 2in.
  8  door + fanlight       raised door, semicircular fanlight above it,
                           number painted on the fanlight glass.
  9  chimney stacks        clustered pots. Stagger them. Never level.

  ── street furniture ─────────────────────────────────────────────────
 10  railings              cast iron, spear-headed, in front of the area.
 11  area steps            down into the basement well, and up to the door.
 12  shopfront fascia      where there is a shop: a painted board above the
                           window, gold or white serif on a dark ground.
 13  wheelie bins          black, blue, brown. Overfull. Lids ajar.
                           Left out on the wrong day. This is not set dress —
                           it is 40% of what a London street actually looks like.
 14  scaffolding           one building in every four. Poles, boards, a green
                           debris net, a plastic banner with a phone number.
                           London is permanently half-repaired.
 15  plane tree            camouflage bark in cream / olive / grey, big
                           maple-ish leaf, planted in a small square of dirt
                           in the pavement with a low hoop guard.

  ── ground ───────────────────────────────────────────────────────────
 16  pavement              grey-buff slabs, rectangular, badly relaid,
                           with tarmac patches where the utilities dug.
 17  kerb                  granite, higher than Berlin's, rounded lip.
 18  double yellow         two parallel yellow lines against the kerb.
                           The only saturated colour on the road surface.
 19  tarmac                cooler and bluer than Berlin asphalt, always
                           slightly wet-looking. Sheen, not shine.

  ── punctuation (sparse — never more than two per plate) ──────────────
 20  pillar box            fat red cylinder, domed cap, black slot.
 21  phone box             red, square, small panes, crown in the pediment.
                           Usually broken. Usually being used as a bin.
 22  bus stop flag         a pole with a red-and-blue roundel flag on top.
 23  Underground roundel   red ring, blue bar. See §4.3.
```

**The rule that keeps it from looking like Berlin:** London has **more small
objects and fewer big shapes**. Berlin is composed; London is accumulated.
Every plate should have at least four pieces of clutter that nobody placed
deliberately — a bin, a bag of rubbish, a chained bicycle wheel with no
bicycle, a traffic cone that has been there for a year.

---

## 2. Colour palette

London reads **cooler, greyer and browner** than Berlin. Berlin's world palette
is an indigo night with amber windows — violet shadows, warm glass. London
replaces the violet with **grey-green**, the amber with a **paler, milkier
warm**, and then hits the whole thing with two or three points of absolutely
saturated red and blue that appear nowhere else in the frame.

The discipline: **the accents are statutory, everything else is filthy.** No
mid-saturation colour anywhere. Either it is dirt, or it is a sign.

### 2.1 The sixteen — `art/world/foreigntoall_london.gpl`

```
GIMP Palette
Name: ForeignToAll London
Columns: 8
#
 27  30  38   overcast lid (#1b1e26)        low cloud, the ceiling on the city
 44  49  60   cloud belly (#2c313c)         sodium bounce on the underside
 61  58  52   sodium haze (#3d3a34)         warm-grey glow over the rooftops
 92  81  64   stock brick (#5c5140)         London yellow stock, sooted
 70  61  49   stock brick shade (#463d31)   soot under every sill and cornice
110  95  73   stock brick lit (#6e5f49)     where a window throws light on it
109  49  40   red brick band (#6d3128)      flat arches, quoins, chimney stacks
196 189 172   stucco (#c4bdac)              rendered ground floors, dirty cream
 46  49  56   wet slate (#2e3138)           roof, and every horizontal surface
232 226 212   sash white (#e8e2d4)          window frames — the bright line
 26  29  36   window dark (#1a1d24)         unlit glass
240 215 154   window lit (#f0d79a)          milkier and cooler than Berlin's
 51  53  60   tarmac (#33353c)              cooler, bluer, always faintly wet
 75  74  70   york stone (#4b4a46)          pavement slabs, grey-buff
106 102  96   granite kerb (#6a6660)        higher lip than Berlin's
143 138 118   plane bark (#8f8a76)          the camouflage flake
```

### 2.2 The statutory six — do not art-direct these

These are real specifications. They are the punctuation of the city and they
are the *only* fully saturated colours London gets. Using them accurately is
worth more than any amount of invented palette, because a Londoner recognises
these six before they recognise a building.

| Hex | Name | Where it is real | Use in game |
|---|---|---|---|
| `#e1251b` | TfL Corporate Red (PMS 485) | Underground roundel ring, bus stop flag, bus livery, Central line | roundels, bus flags, the one moving bus |
| `#0019a8` | TfL Corporate Blue (PMS 072) | the bar across the roundel, station name plates, Piccadilly line | roundel bar, platform name frieze |
| `#a23b3c` | Post Office Red, BS381C-538 | pillar boxes, the K2/K6 phone box | pillar box, phone box — note it is **deeper and browner** than TfL red, and standing them near each other is a real London colour event |
| `#005eb8` | NHS Blue (PMS 300) | every NHS sign in the country | hospital exterior, A&E wayfinding |
| `#ffd329` | Circle line yellow | line diagrams, roundel infill on some maps | the double-yellow kerb line reads as a dirtier cousin at `#d8b800` |
| `#000000` | Northern line black | line diagrams, ironwork | railings, lamp columns, the bin |

**Composition rule.** A London plate is 90% values between `#1a1d24` and
`#6e5f49`, plus **one** statutory accent at full chroma. Two accents only where
the fiction demands it (a pillar box beside a bus stop). Three is a mistake.
Berlin's amber windows are allowed to be everywhere because warmth is Berlin's
character; London's red is a *signal*, and a signal that appears everywhere is
noise.

---

## 3. What London is, as a place in this story

The alien arrives at an airport, not a crash site. That inversion matters — the
player has *chosen* to come here, with a ticket bought with money they earned.
They are no longer a survivor. They are a tourist, which is a much lonelier
thing to be.

**The fragment.** `shard_london` — "Cold fragment." Sold on to a dealer. The
word *dealer* is doing a lot of work: this is the first fragment held by
someone who understands it is worth money, and who will therefore *talk*. The
Berlin fragments were held by systems (a clinic, a lost property office, an
evidence locker) that could be navigated with paperwork and patience. London's
is held by a person with an interest in the conversation going a certain way.
You cannot fill in a form to get it. You have to understand what he means.

That is the region's whole design in one sentence: **Berlin was bureaucracy,
London is negotiation.**

**The geography.** Two or three street plates is enough. Suggested:

- **`Terrace`** — residential. Where the cheap hotel is. Wheelie bins,
  scaffolding, one plane tree, a pillar box. The quiet plate. Learn to walk here.
- **`HighStreet`** — the shops. Bureau de change, the caff, the pub, the
  bus stop, the Underground entrance. The loud plate. Everything is transacted here.
- **`ArchesMarket`** — under a railway viaduct. Brick arches, lock-up units,
  stalls, a dealer's unit at the far end. Trains overhead, felt not seen.
  The plate the fragment lives on.

---

## 4. The seven buildings, localised

Every building keeps its `Services.gd` hook. What changes is the **signage
vocabulary**, the **counter behaviour**, and the **social script** — because
the social script is the actual content of this region.

Interiors follow the existing rule: **drawn in GDScript.** Extend
`InteriorBackground.gd`'s `room` switch with London variants rather than
authoring new `.tscn` art. Suggested keys: `bureau`, `nick`, `ae`, `caff`,
`tube`, `terminal`, plus `b_and_b` for the hotel lobby.

---

### 4.1 Hotel → **the B&B**

Not a hotel. A converted Victorian terrace with a laminated sign in the front
window and a bell on the desk.

**Exterior.** Two terraced houses knocked together, stucco ground floor painted
a colour that was cream in 1994. A plastic-and-vinyl sign across the first-floor
windows. A small internally-lit box sign at the door reading **VACANCIES**, with
a hinged panel that flips to **NO VACANCIES**. Four stars printed on the sign by
the owner, on the owner's own authority.

**Signage vocabulary.**
`VACANCIES` · `NO VACANCIES` · `B&B` · `EN-SUITE` · `FULL ENGLISH INCLUDED` ·
`RECEPTION` · `PLEASE RING FOR ATTENTION` · `NO SMOKING` · `CHECK-OUT 10AM` ·
`ROOM 4 — FIRST FLOOR`

**The trap that costs the player a day.** In Britain the **ground floor is not
the first floor.** "Room 4, first floor" is one storey *up*. Berlin taught
`dritter Stock` = third floor and the alien learned to count. London silently
shifts the origin by one. Have the player go to the wrong door, and have a
guest open it, and have the guest say *"sorry"* — meaning *you are in the wrong
place, please leave.*

**Social script.** The desk person will ask **"You alright?"** before anything
else. It is not a question about your condition. Answering it as one is the
region's tutorial failure, and it should happen in the first sixty seconds.

**Reuse.** `HotelLobby`, `HotelFloor`, `HotelRoom`, `HotelDoor`, `BedRest`,
`Elevator` all carry over — except the lift. A B&B in a Victorian terrace has
**no lift**, only a narrow staircase with a worn runner. Removing the
`ElevatorPanel` from London is a small change that speaks loudly.

---

### 4.2 Money exchange → **the bureau de change**

**Exterior.** A narrow unit between a phone-unlocking shop and a chicken shop.
Yellow-and-black vinyl in the window. Big printed numbers taped to the glass.

**Interior.** Reuse `_dress_exchange()`'s bones — booth, security glass, split-flap
rate board — but re-dress: the rate board becomes a backlit acrylic panel with
**two columns, WE BUY and WE SELL**, and the alien must work out why there are
two numbers for the same thing. That is a genuinely alien-legible piece of
cultural learning: *the price of a thing depends on which way it is moving.*

**Signage vocabulary.**
`BUREAU DE CHANGE` · `WE BUY / WE SELL` · `0% COMMISSION` · `NO COMMISSION ON
EUROS` · `TRAVEL MONEY` · `BEST RATES IN LONDON` · `MINIMUM £20` ·
`RATES SUBJECT TO CHANGE` · `PLEASE HAVE ID READY`

**The lie.** `0% COMMISSION` is displayed enormously; the margin is buried in
the spread between BUY and SELL. `GameState.EXCHANGE_FEE` is `0.10` — in Berlin
the booth *told* the alien it was taking a cut. London's booth advertises that
it takes nothing and takes more. The alien can only detect this by exchanging
twice and comparing, which is a perfect optional journal beat.

**Social script.** No greeting. The clerk says a number and waits. Silence here
is not hostility, it is efficiency, and the alien will read it as hostility.

---

### 4.3 Metro → **the Underground**

Never "U-Bahn", never "metro", never "subway" (in Britain a *subway* is a
pedestrian tunnel under a road). It is **the Underground**, or in speech,
**the Tube**.

**Exterior.** A tiled entrance arch in ox-blood glazed terracotta, or a plain
1930s concrete portal. Above it, the **roundel**: a red ring, a blue horizontal
bar, `UNDERGROUND` in white on the bar. This is the single most recognisable
object in the region — get the geometry right. The bar is wider than the circle
and passes fully through it.

**Interior.** Extend `_dress_ubahn()` into `_dress_tube()`:

- Cream and ox-blood **glazed tiles**, in bands, with the station name spelled
  out in tile mosaic at intervals along the platform wall.
- The **name frieze**: station name in white on the blue roundel bar, repeated
  down the platform so it is readable from any carriage window.
- **Ticket barriers** — waist-high gates with yellow card readers. Berlin's
  U-Bahn was open; you could walk on. London physically will not let you
  through. The barrier is the region's first hard "no".
- A **line diagram**: coloured lines on white, no geography, no scale. To the
  alien this is a *nonsense object* — a map that does not correspond to the
  ground. Nail this beat. It is genuinely, philosophically strange, and it is
  correct: the Tube map is a diagram of *relations*, not of *places*.
- Warm gritty wind from the tunnel mouth before a train.
- The tannoy, in the clearest, slowest English in the whole region.

**Signage vocabulary.**
`UNDERGROUND` · `WAY OUT` (not EXIT — that word is reserved for emergencies) ·
`MIND THE GAP` · `NO EXIT` · `TO THE TRAINS` · `NORTHBOUND` / `SOUTHBOUND` ·
`CHANGE HERE FOR…` · `TOUCH IN / TOUCH OUT` · `PLEASE KEEP LEFT` ·
`STAND ON THE RIGHT` · `DOGS MUST BE CARRIED` · `LOST PROPERTY` ·
`THIS ESCALATOR IS TEMPORARILY OUT OF SERVICE — WE APOLOGISE FOR ANY
INCONVENIENCE`

**Fare.** `GameState.CITIES.london.fare` is 15 for the flight in. The Tube ride
should *not* be `UBAHN_FARE`'s flat 3 — London charges by zone and by tap. Make
the alien tap in and tap out, and charge on the *second* tap. Failing to tap
out costs a penalty fare. That is a rule with no analogue in Berlin and it will
catch the player exactly once, which is the right number.

**Social script — this is the important one.**
- **Stand on the right** on the escalator. Walk on the left. Standing on the
  left is the most reliably punished error in the city, and the punishment is
  entirely non-verbal: a build-up of people behind you, and a *tut*.
- **Let people off before you get on.** Berlin was pushy and forgiving; London
  is orderly and unforgiving.
- **Do not make eye contact.** Not coldness — a courtesy. In a space where
  strangers are pressed together, refusing to look is how you give them privacy.
  The alien, trained by Berlin to *seek out faces* to gain familiarity, will
  find that the London exposure mechanic actively punishes staring. Nobody
  will look back. Familiarity gain on the Tube should be near-zero, and this
  should be *felt* as a wall.
- **Nobody speaks.** A silent carriage of forty people is not a broken scene.
  It is the scene.

---

### 4.4 Restaurant → **the caff, and the pub**

Split this into two, because in London they are two different social machines
and the difference is the lesson.

#### The caff (greasy spoon)

**Exterior.** A single wide window, steamed. A hand-painted fascia in a font
chosen in 1974. Laminated menu taped inside the glass. Plastic sign:
`OPEN` / `CLOSED`, hung on a suction cup, at an angle.

**Interior.** Cream wall tiles to shoulder height. **Formica** table tops.
Fixed plastic chairs. Black-and-white photos of boxers and a football team.
A chrome tea urn. Red and brown squeezy sauce bottles shaped like tomatoes.
Salt in a glass shaker with rice in it. A laminated menu card, and a
hand-chalked board that contradicts it.

**Signage vocabulary.**
`ALL DAY BREAKFAST` · `FULL ENGLISH £6.50` · `SET B — 2 EGGS, BACON, BEANS,
TOAST & TEA` · `TEA 90p` · `TAKE AWAY` (two words — a *takeaway* is the noun,
*take away* is the act) · `CASH ONLY` · `NO PUBLIC TOILETS` ·
`PLEASE PAY AT COUNTER` · `TABLE SERVICE`

**Social script.** You sit down. Someone comes to you. You order. You pay at the
end, at the counter. Tea arrives without being specified — *tea* means one
thing here and it means it strongly.

#### The pub

**Exterior.** Corner site. Ground floor in **glazed green or ox-blood tile**.
Gold serif lettering on the fascia and painted directly onto the window glass,
often with `SALOON BAR` and `PUBLIC BAR` over two different doors that lead to
the same room. A **hanging sign** on a bracket with a painted picture and a
noun-phrase name: *The Lamb and Flag*, *The Crown*, *The World's End*. Hanging
baskets. A blackboard promising a quiz on Tuesday.

**Interior.** Dark timber, a patterned carpet that hides everything, etched
glass panels, hand pumps in a row along the bar with badges clipped to them,
horse brasses, a fireplace nobody has lit, low warm light from wall sconces.

**Signage vocabulary.**
`FREE HOUSE` · `REAL ALE` · `GUEST ALE` · `SKY SPORTS SHOWN HERE` ·
`FOOD SERVED 12–3, 6–9` · `LAST ORDERS` · `TIME, PLEASE` · `NO FOOTBALL
COLOURS` · `SALOON BAR` / `PUBLIC BAR` · `LADIES` / `GENTS` ·
`PLEASE DRINK RESPONSIBLY`

**Social script — the biggest single trap in the region.**

1. **There is no table service.** You go to the bar. Sitting down and waiting
   is the tourist's error, and the alien has just been trained by the caff, two
   doors down, that sitting and waiting is exactly correct. **The rules changed
   between two adjacent buildings on the same street and nobody mentioned it.**
   This is the best single beat available in London. Build the caff first so
   the pub can break it.
2. **There is no queue at the bar** — and Britain is a country obsessed with
   queues. You ease forward, catch the barman's eye, and wait your turn, and
   everyone knows whose turn it is, and there is no line. The alien, having
   spent all region learning to queue, will queue at the bar, and will be
   served last, and will never be told why.
3. **The round.** If you drink with people, one person buys for everyone, and
   then the next, and everyone silently tracks it. Leaving before you have
   bought your round is a real offence, committed silently, punished silently.
   Buying a round *out of turn* is nearly as bad — it reads as saying you do
   not want to owe anyone anything, which reads as saying you do not want to be
   here again.
4. **Do not tip the barman.** There may be a jar. There is no obligation. The
   Berlin-trained instinct to round up is wrong.

**Quest hook.** The dealer holding `shard_london` should conduct business in the
pub, and the price of the conversation should be **the round**. Not money — the
alien can pay money, has learned to pay money. The price is understanding that
buying the drinks is what makes the talk possible.

---

### 4.5 Police station → **the nick**

**Exterior.** A solid Victorian or interwar building, red brick with stone
dressings, a blue lamp on a bracket over the door — a glass box lantern with
`POLICE` on all four faces, lit from inside. Below it, a sign with the
**Sillitoe tartan**: a band of black-and-white checks. A blue-and-white sign
reading `METROPOLITAN POLICE`.

**Interior.** Reuse `_dress_police()` — the cool palette and indifferent
counter are already right. Re-dress: a **front counter** behind toughened
glass with a small speaking grille, a ticket-style queue system, plastic bucket
chairs bolted to a rail, a rack of leaflets in eleven languages (none of them
the alien's), a poster about knife crime, a poster about bogus callers, a
CCTV-in-operation notice, and a laminated sheet on the door reading
`FRONT COUNTER OPEN 10AM–4PM MON–FRI`.

**Signage vocabulary.**
`POLICE` · `METROPOLITAN POLICE` · `FRONT COUNTER` · `LOST PROPERTY —
ENQUIRIES` · `PLEASE TAKE A SEAT AND WAIT TO BE CALLED` ·
`IN AN EMERGENCY DIAL 999` · `FOR NON-URGENT MATTERS CALL 101` ·
`CCTV IN OPERATION` · `NO WEAPONS BEYOND THIS POINT` ·
`THIS COUNTER IS CLOSED — PLEASE USE THE INTERCOM`

**The difference from Berlin.** The Polizeiwache *had* the fragment and would
release it to its owner on proof. The Met station does not have it and never
did; it has a **record** of it — a crime number, a property reference, a name
that leads to the dealer. London's police give you information, not objects.
That keeps the fragment where it belongs (with a person, in the arches) and
gives the station a real function.

**Social script.** The officer at the counter will be scrupulously polite and
will help with nothing. "I'm afraid that's not something we can help you with"
is a complete refusal delivered as regret. The alien will hear the regret.

---

### 4.6 Hospital → **A&E**

Not *ER*, not *Notaufnahme*. **A&E** — Accident & Emergency. Everyone says the
letters.

**Exterior.** A 1970s concrete block bolted onto a Victorian original. A blue
sign with a white **H** and an arrow — but note: the British hospital road sign
is a white `H` on blue, *not* Berlin's yellow (`H sign yellow #d8b02c` in the
world palette is a Berlin colour; London's must be NHS Blue `#005eb8`). Over
the entrance, a large illuminated sign in **Emergency Services Red** reading
`ACCIDENT & EMERGENCY`, and beside it `24 HOURS`. Ambulance bays with yellow
and green chevrons. A smoking shelter fifteen metres from the door with people
in dressing gowns in it.

**Interior.** Reuse `_dress_hospital()`. Re-dress hard:

- **Reception first, triage second, waiting third, treatment fourth.** Four
  separate waits. Each one feels like progress and is not.
- A **digital display** showing `CURRENT WAITING TIME: 4 HRS 20 MINS`, which
  does not decrease.
- Rows of blue vinyl-and-steel chairs, mostly full.
- A vending machine. A children's play corner with three toys. A TV bolted high
  in a corner showing the news with subtitles and no sound.
- Blue-and-white NHS wayfinding everywhere, in Frutiger, immaculately designed,
  pointing at departments that are all closed.

**Signage vocabulary.**
`ACCIDENT & EMERGENCY` · `A&E` · `24 HOURS` · `MINOR INJURIES UNIT` ·
`URGENT TREATMENT CENTRE` · `PLEASE BOOK IN AT RECEPTION` ·
`TRIAGE` · `CURRENT WAITING TIME` · `THIS IS AN EMERGENCY DEPARTMENT — PATIENTS
ARE SEEN IN ORDER OF CLINICAL NEED, NOT ARRIVAL` · `PLEASE DO NOT ABUSE OUR
STAFF` · `AMBULANCES ONLY` · `NO ENTRY` · `WARD 6 — VISITING 2–4PM & 6–8PM`

**The lesson.** *"Seen in order of clinical need, not arrival."* — Britain
queues for everything, obsessively, morally. And then in the one building where
the stakes are highest, it publicly abolishes the queue. The alien has just
spent the whole region learning that the queue is sacred. Here it is not.
**The rule is not the rule everywhere, and nobody flags the exception.**

**Berlin's clinic removed a fragment from the alien's body.** London's A&E must
not repeat that. Use it instead as the place where the alien learns what
*waiting* means socially: four hours in a chair, surrounded by people, being
spoken to kindly by nobody in particular.

---

### 4.7 Airport → **Heathrow**

The alien's arrival plate, and the region's opening shot.

**Exterior / airside.** Grey-green carpet, back-lit signage, a long walk.
Everything in the same clean typeface. Yellow directional signs overhead.

**Interior.** Extend `_dress_airport()`. The beats:

- **A queue with rope barriers**, snaking, orderly, silent. The first thing
  the region shows the player is Britain queueing. Do not open on anything else.
- **Border Force desks** and **e-gates**. A sign splitting the queue into
  categories the alien cannot classify themselves under.
- The **retractable belt barrier** — a physical object that draws a line on the
  floor and is universally obeyed despite being defeatable by a toddler.
- Duty free forcing a path through perfume before you reach the gate.
- A carousel. A single unclaimed bag going round.

**Signage vocabulary.**
`ARRIVALS` · `DEPARTURES` · `BAGGAGE RECLAIM` (not *claim*) · `WAY OUT` ·
`TOILETS` (not *restroom*) · `LIFT` (not *elevator*) · `TROLLEYS` ·
`NOTHING TO DECLARE` / `GOODS TO DECLARE` · `UK BORDER` · `ALL PASSPORTS` ·
`PLEASE HAVE YOUR PASSPORT OPEN AT THE PHOTO PAGE` · `QUEUE THIS SIDE` ·
`ONE METRE APART` · `NO ENTRY — DO NOT RE-ENTER` · `HEATHROW EXPRESS` ·
`TAXIS` · `COACHES`

**The vocabulary lesson.** Berlin's signs were unreadable and the alien learned
them as shapes. London's signs are *readable and wrong* — the alien knows the
word `exit` and London says `WAY OUT`; knows `elevator` and London says `LIFT`;
knows `bathroom` and London says `TOILETS`. **Every one of these should render
as fully legible text that the alien's journal notes it does not recognise.**
That is a beautiful, cheap, exactly-on-theme effect and it costs one flag.

**Social script.** The Border Force officer asks three questions in a flat tone.
*"What's the purpose of your visit?"* The correct answer is short. Any answer
longer than eight words reads as evasion. Berlin rewarded elaboration; London
punishes it.

---

## 5. The language mechanic — **Accents and Speed**

This is the region's system, and it is the thing that must be *built*, not
reskinned.

### 5.1 The principle

In Berlin, meaning is hidden in the **word**. In London, meaning is hidden in
three other places:

1. **The surface form.** The alien knows *have*. It does not know *'ave*.
   It knows *is not*. It does not know *ain't*. It knows *do not know*.
   It does not know *dunno*.
2. **The speaker.** Ears are earned one person at a time. Understanding Dot at
   the caff does not help you understand the dealer under the arches.
3. **The gap between the words and the meaning.** *"Not bad"* is four fully
   legible characters of nothing.

### 5.2 The three render states

Berlin has four tiers of one axis. London has three *states*, which is a
different shape and should be felt as one.

**PLAIN.** Fully legible. The player reads it and it means what it says.

**BROKEN.** Legible words with holes punched in them. **Not a wall of glyphs.**
This is the crucial visual difference from Berlin: in Berlin, unknown text is
solid fog. In London, unknown text is *mostly readable with the important bits
missing*, which is far more maddening and far more true. Function words survive
(they are unstressed, short, and the same in every accent); stressed content
words and contracted forms go. What the player sees is the *shape* of a
sentence they cannot use.

> `"Nah ⬡⟢⋄, he ⟦⟧⬣'⋄ been in ⬢⟣⟤⟥ — you ⟟⬡⟢⋄ ⋄⟤ ⬠⟦⟧?"`

**FALSE-CLEAR.** Every word renders in `PLAIN`. The journal records a literal
reading. The literal reading is wrong, and the player will act on it. This state
has **no visual marker whatsoever** — that is the entire point, and it is where
London earns the game's thesis. The only tell is retrospective: the journal
entry, later, gets a second line struck through and rewritten.

### 5.3 Implementation, against what already exists

The existing machinery does not need changing. It needs *feeding differently*.

`GameState.familiarity` is `{language: {word: 0-100}}` and `get_tier()` reads it.
London uses the same store with two key conventions:

```
familiarity["english"]["'ave"]     surface forms are their own entries.
familiarity["english"]["have"]     "have" and "'ave" are unrelated words as
                                   far as the alien's ear is concerned.

familiarity["english"]["@dot"]     the "@" prefix cannot collide with a real
familiarity["english"]["@dealer"]  word. This is the per-SPEAKER ease.
```

Then one new function, and one new field on a dialogue line:

```
speaker_gate(speaker_id) -> int      maps "@id" familiarity onto a tier ceiling
                                     via the same 25 / 50 / 80 thresholds.

line.register: int 0..4              how far the line sits from standard English
line.speed:    int 0..2              0 measured, 1 normal, 2 fast/overlapping
line.false_clear: bool               renders PLAIN regardless; means otherwise
```

The resolved tier for a word in London is:

```
effective = min( word_tier , speaker_gate - register - speed )
```

...clamped to `TIER_UNKNOWN`. So:

- A **familiar speaker** speaking **standard English slowly** → everything PLAIN.
- The **same speaker** dropping into slang → the content words fall out even
  though you know the person. *You know their voice and not their words.*
- A **stranger** speaking **perfect standard English** → still partly BROKEN
  the first time, because you have not tuned to them yet. *You know the words
  and not their voice.*

That symmetry is the whole mechanic and it is worth protecting.

**Exposure.** `EXPOSURE_GAIN` already has `hear / pointed / used / read`. London
adds gain to `"@speaker"` on every line heard from them — so the mechanic
rewards **staying in one conversation** rather than sampling the crowd. Berlin
rewarded breadth; London rewards depth. Reflect this in the Tube: forty people,
zero eye contact, zero gain. The alien cannot farm a city that will not look at
them.

**Journal.** `WORD_GUESSES` gains English surface forms. The voice must match
Berlin's — a guess, with visible uncertainty, occasionally wrong on purpose:

```
"'ave":     '— "have"?  he swallowed the front of it',
"innit":    '— a question glued to the end of a sentence. Always the same shape.',
"mate":     '— "friend"?  he calls everyone this, including the man he shouted at',
"alright":  '— not a question about my condition. I keep answering it wrongly.',
"sorry":    '— excuse me / move / no / I heard you / I am sorry.  (all of them)',
"cheers":   '— "thank you"?  also "goodbye"?  also raising a glass?',
"proper":   '— "very".  nothing to do with correctness',
"quid":     '— one pound.  never pluralised.  "five quid", not "five quids"',
"bruv":     '— "brother"?  they are not brothers',
"tenner":   '— ten pounds.  they have a word for each amount',
```

### 5.4 The eighteen lines

Escalating. `R` = register, `S` = speed. Glyph runs use the project's
`GLYPHS_FULL` set, `◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡`, at matching character length.

---

**Ladder 1 — clear words, hidden meaning. (FALSE-CLEAR.)**
*These render perfectly. That is the trap.*

**1.** `R0 S0` — B&B reception, first line in the region.
> **Renders:** "You alright?"
> **Alien reads:** *Am I injured? Does she know about the crash?*
> **Means:** Hello.
> *The player will answer this with a status report. Let them.*

**2.** `R0 S0` — the caff, after the alien tries the tea.
> **Renders:** "Not bad, is it."
> **Alien reads:** *Mediocre. She is disappointed.*
> **Means:** That's excellent.
> *Note it is not even a question. The rising tone is absent in text — and the*
> *alien cannot hear tone. This is the purest expression of the thesis available.*

**3.** `R0 S0` — the Border Force officer, on being handed a long explanation.
> **Renders:** "Right. And how long are you staying?"
> **Alien reads:** *He agreed with me and is now interested in my plans.*
> **Means:** Stop talking. Answer the question I already asked.
> *"Right." is a full stop wearing a smile.*

**4.** `R0 S0` — the police front counter.
> **Renders:** "I'm afraid that's not something we can help you with."
> **Alien reads:** *He is frightened. Perhaps he can help unofficially.*
> **Means:** No. Go away.

**5.** `R1 S0` — a neighbour on the Terrace plate, in the rain.
> **Renders:** "Lovely weather for it."
> **Alien reads:** *He approves of the weather.*
> **Means:** This weather is appalling and I am acknowledging that you exist.
> *Weather talk is not about weather. It is a handshake with words in it.*

**6.** `R0 S0` — the pub, after the alien buys a drink for himself only.
> **Renders:** "No, you're alright."
> **Alien reads:** *He confirms I am well.*
> **Means:** No thank you — and also, you have just done something wrong.

---

**Ladder 2 — the ear starts to slip. (BROKEN, lightly.)**
*Contractions and elisions. Grammar survives; the swallowed bits do not.*

**7.** `R1 S1` — the caff.
> **Renders:** "Y'⬡⟢⟣⬟⬣⬠, love? What ⬢⟤⬡ I ⟦⟧⋄ you?"
> **Means:** "Y'alright, love? What can I get you?"
> *`love` renders plain and is the more alarming half. It is not affection.*

**8.** `R1 S1` — a man on the High Street plate, blocking the pavement.
> **Renders:** "⬡⟢⟣⟤⬢ mate, ⬠⟦⟧ ⋄⟤⬣ me."
> **Means:** "Sorry mate, 'scuse me."
> *`sorry` here means "move". It is the second of its five faces.*

**9.** `R2 S1` — the market, a stallholder.
> **Renders:** "⟟⬡⟢⋄ a ⟦⟧⬣⬠⟤⟥'⬢ at ⋄⬡⟟⋄, go on."
> **Means:** "Have a butcher's at that, go on."
> *Rhyming slang: `butcher's hook` → `look`, then the rhyming half is deleted.*
> *Even at full familiarity the phrase does not decode from its parts. This is*
> *the region's proof that vocabulary is not comprehension.*

**10.** `R2 S1` — the pub, a regular, unprompted.
> **Renders:** "He's ⬡⟢ his ⟦⧧⬣⬠ ⟟⬡⟤⋄⟥ again, poor sod."
> **Means:** "He's on his Jack Jones again, poor sod." — He's alone again.
> *`poor sod` renders plain and is sympathy. The alien will read it as insult.*

---

**Ladder 3 — the ear fails. (BROKEN, heavily.)**
*Content words gone. Only scaffolding left.*

**11.** `R3 S1` — under the arches, a lookout.
> **Renders:** "⬢⟤⬡⟢⟣⬠, you ⟦⧧⬣ ⋄⟤ ⬡⟢⟣ ⬠⟦⟧, ⟟⬡⬢⟢⋄?"
> **Means:** "Wagwan, you here to see the man, innit?"

**12.** `R3 S1` — two teenagers on the top deck of the bus.
> **Renders:** "⟢⟣⋄ ⬠⟦⟧'⬢ ⟟⬡⬣ ⬠⟤⬡⟥, ⋄⬢⟢ ⟦⧧⬣⬠ ⋄⬡⟟."
> **Means:** "Man's bare tired, my ends is long." — I'm exhausted, my
> neighbourhood is far away.
> *`man` is a first-person pronoun here. That single fact should be a journal*
> *entry all of its own.*

**13.** `R3 S2` — the dealer, testing whether the alien is worth talking to.
> **Renders:** "⟟⬡⟢⋄'⬢ it ⬠⟦⧧ me ⋄⟤⬣, ⟥⟦⧧? ⟢⟣⬡⬠ ⋄⟤ me ⬢⟤⬡⟟⋄."
> **Means:** "What's it worth to you, though? Talk to me straight."
> *He is not being hostile. He is checking. The alien cannot tell.*

**14.** `R3 S2` — a bus driver, through glass, to a queue of eleven.
> **Renders:** "⟦⧧⬣⬠ ⬡⟢⟣ ⋄⟤⬢, ⟟⬡⬠ ⬢⟤⬡⟥⋄ ⟦⧧, ⋄⬡⟢⬠⬣ ⟤⟥."
> **Means:** "Move down inside, this bus ain't moving, thank you."
> *Everyone else complies instantly. The alien does not move. Everyone notices.*

**15.** `R4 S2` — the market at full volume, three voices overlapping.
> **Renders:** "⬢⟤⬡⟢ ⟦⧧⬣ ⬠⟤⟥ — ⟟⬡⬢ ⋄⟤⬣⬠ ⟦⧧ — ⬡⟢⟣⋄⟤ ⬢⟣⬠⟦ ⟥⧧⬣!"
> **Means:** Unrecoverable, and *intended* to be. Three people are selling three
> things and none of it was addressed to you.
> *`R4` lines have no plain meaning in the journal — only a note about rhythm.*
> *The alien records: "Fast, and not for me. I think that is most of it."*

---

**Ladder 4 — the words come back, the meaning does not. (FALSE-CLEAR again.)**
*Placed after the hardest lines on purpose. The player has just spent an hour*
*fighting for legibility, wins it, and discovers it bought them nothing.*

**16.** `R0 S0` — the dealer, once the alien has earned his ear, holding the shard.
> **Renders:** "I'm not being funny, but that's a lot of money to me."
> **Alien reads:** *He is being serious, and he is poor. He wants money.*
> **Means:** I am about to say something you will not like. The price has gone up.
> *"I'm not being funny, but" is a warning light, not a disclaimer.*

**17.** `R0 S0` — the same conversation, three lines later.
> **Renders:** "Yeah, no, I hear you."
> **Alien reads:** *Yes and no. Confusing. But he is listening.*
> **Means:** No. I have listened and I am declining.
> *`Yeah, no` = no. `No, yeah` = yes. Both are one word long and the wrong one.*

**18.** `R0 S0` — the last line the dealer says, after the round is bought.
> **Renders:** "Go on then. But you never got it off me, alright?"
> **Alien reads:** *A command, then a denial of a transaction that occurred.*
> **Means:** Yes. Take it. And do not name me.
> *`Go on then` is consent given as reluctance, which is how this city gives*
> *consent. The alien has to learn that being talked out of something and*
> *being given it look identical from outside.*

### 5.5 The five faces of *sorry*

The alien meets `sorry` in the first minute and it renders PLAIN every time.
It is one word with an unstable meaning, which is the exact inverse of Berlin's
many words with stable ones. Build a journal page that accumulates:

| Said as | Actually means | Where the alien meets it |
|---|---|---|
| "Sorry —" *(rising, before speech)* | Excuse me, I am about to speak to you | shop, bureau, ticket hall |
| "Sorry." *(flat, while moving)* | Get out of my way | High Street pavement |
| "Sorry?" *(rising, alone)* | I did not hear you, repeat it | the caff, over noise |
| "Sorry, no." | Absolutely not, and I resent being asked | police front counter |
| "*I'm* sorry." *(stressed)* | Actual regret. The rarest one. | A&E, once, quietly |

And the sixth, which is the one that breaks the alien: **the person you walked
into says it to you.** Being apologised to for your own error is not sarcasm and
is not weakness. It is the city closing an awkward moment as fast as possible so
that neither of you has to stand in it.

---

## 6. The social script, and how to fail it

Each of these should be a **playable failure with a silent consequence** — no
error message, no red text, no NPC explaining the rule. London does not tell you.
That is the region's contract with the player.

**Queueing.** The queue is a moral object. It is single-file, it is invisible
(no rope, no markings, it is simply *known*), and it is respected absolutely.
Joining it wrongly does not produce shouting; it produces a silence with a
particular texture, and someone saying "sorry, I think there's a queue" in the
mildest voice available. *Consequence:* served last, reputation down, nobody
explains.
**And then:** the bar has no queue, and A&E abolishes the queue by policy. Two
exceptions to a sacred rule, both unmarked.

**Apologising.** Under-apologising reads as aggression. The alien must learn to
say sorry for things that are not their fault, including being walked into. A
dialogue response tagged `sorry` should become available early and should be
correct startlingly often. It is the region's universal lubricant.

**The weather.** Small talk about weather is not information exchange and not
enthusiasm. It is a **low-stakes opening move** — a sentence with no content, so
that the other person can decline it without cost. The alien, trained in Berlin
to seek meaning in every utterance, will search this for meaning and find none,
and conclude the speaker is stupid. They are not. They are being careful.
*Correct response:* agree, add nothing, move on.

**Eye contact on the Tube.** Do not. In Berlin, looking at a face gained
familiarity. On the Tube, looking gains nothing and costs reputation. The player
will try it, because the game trained them to. That is the design.

**The round.** See §4.4. Buying for the group is not generosity; it is
membership. Refusing to be bought for is not modesty; it is a refusal to be
owed, and therefore a refusal of the relationship. The dealer will not sell to
someone who will not be owed anything.

**Volume.** The alien's dialogue style tags — `formal / direct / gesture /
indirect` (`#5a52cc / #1e9482 / #b8701e / #2e70b8` in the world palette) — should
reweight in London. `direct` was efficient in Berlin and is *rude* here.
`indirect` was evasive in Berlin and is *correct* here. Same button, inverted
meaning, no notification. The player discovers it from reputation drift.

**Thank you.** London says thank you at a rate the alien will find deranged:
to the bus driver on the way off, to the machine that dispensed the ticket, to
the person who held the door, twice. Under-thanking is the most common way to
be quietly disliked.

---

## 7. Build notes

Static observations from the codebase. Nothing here has been run.

- **`scenes/ui/MapView.gd` is Berlin-only.** It has `_draw_kiez_map`,
  `_draw_mitte_map`, `_draw_ost_map`, `_draw_lobby_map`, `_draw_hotel_floor_map`,
  `_draw_room_map`, `_draw_interior_map` and no city dispatch. Adding London
  needs a city-level branch. This file was mid-edit when the previous session
  was cut off — **read it before trusting it.**

- **`GameState.reputation`** is `{"kiez", "mitte", "prenzlberg"}` — Berlin
  districts only. London needs its own keys. `REP_LEVELS` strings
  ("practically a neighbour", "that odd one") are Berlin-voiced and warm;
  London's ladder should be cooler and more oblique — *"someone they've seen
  before"*, *"not from round here"*.

- **`GameState.UBAHN_FARE`** is a flat 3. The Tube's tap-in/tap-out charging
  (§4.3) cannot use it as-is.

- **`WorldArt.TILE_*`** has no London-appropriate ground tile. `TILE_SIDEWALK`
  is Berlin-grey. A `TILE_YORKSTONE` / `TILE_TARMAC_WET` pair would earn its
  place; the `TILE_FALLBACK` array must gain matching entries **in the same
  order** or every index after the insertion point shifts.

- **`InteriorBackground.gd`** is 393 lines with six rooms. Adding seven London
  rooms will push it past the 800-line ceiling in the project's own style rules.
  **Split it now**, before writing London: `InteriorBackground.gd` keeps the
  dispatch, `InteriorRoomsBerlin.gd` and `InteriorRoomsLondon.gd` hold the
  dressing. `InteriorArt.gd`'s static helpers stay shared — they are already the
  right abstraction.

- **GDScript, from this project's own scar tissue:** do not use `:=` to infer
  from a `Dictionary`/`Array` subscript, from `.get()`, or from a multi-part
  boolean. The London line struct is all dictionary reads — annotate every one:
  `var register: int = line.get("register", 0)`. Files are **tab-indented.**

- **Nothing above has been tested.** Godot is not on PATH in this environment.

---

## 8. The one-line brief

> **Berlin was a wall you learned to read. London is a door that is already open,
> and you still cannot get through it, and everyone is being very nice about it.**
