# Recover the Pod — the main plot

> Buildable spec. Written against `autoload/GameState.gd` and `autoload/Services.gd`
> as they stand. Berlin is built; London and Istanbul are not. Nothing here has
> been run — Godot is not on PATH. Everything below is static design.

The thesis, restated so the plot can be checked against it:

**Communication is cultural. Knowing the words is not enough.**

So no fragment is ever gated on an item. Every one of the five is gated on the
player understanding how a place works. The key is always a custom.

---

## The spine

Three acts, one city each. Each act teaches a different way of failing to
communicate, and each act's language mechanic *is* its theme.

| Act | City | Emotional arc | Language model | What the player learns |
|---|---|---|---|---|
| I | Berlin | **Illegible** — you cannot read, and you cannot be read | per-word familiarity (built) | that a system can receive you without understanding you |
| II | London | **Fluent and alone** — every word legible, the meaning gone | per-speaker attunement (to build) | that the sentence is not where the meaning lives |
| III | Istanbul | **Indebted** — you are let in, and being let in costs | per-stem, with suffixes (to build) | that being given to is not free, and should not be |

Act I is survival. You are a shape in the road people walk around. You get
food, a bed, a map, and three pieces of your own machine, and you do all of it
without a single sentence.

Act II is the reversal. You land somewhere you can *read*. Every word arrives
whole. And you get nothing, for a long time, because in London the words are
the outside of the meaning and you have been handed the outside.

Act III is the debt. Istanbul does not make you earn anything. It sits you
down and feeds you before it asks your name, and by the time you want the
fragment you are inside a house, and the fragment belongs to that house, and
taking it will cost them something real.

Then Berlin again, one last time, to put the thing back together in the field
where it came apart. The last flight is homeward to a crash site.

---

## The five fragments

Each entry: who holds it · why they will not hand it over · what must be
understood · the beat where it turns.

### 1 — `shard_medical` · the warm shard · Berlin · BUILT

**Holder.** Nobody. It is in the player's side. The *system* holds it: it
cannot come out without a clinic, and a clinic is a counter, and a counter
wants a card, a name, a number.

**Why it will not come.** `Services._hospital_desk()` opens on the correct
obstacle — she asks for something the player does not have and cannot fake.
Every box on the form is a small locked door.

**What must be understood.** That the German counter is not a wall. It is a
door with a rule attached, and one of the rules is that a body in front of you
gets treated whether or not it can be filed. The player has to stop trying to
become legible and show the wound instead. Paperwork is a language; the body
is not.

**The turn.** She puts the pen down and asks to see it instead. Already
written. Keep it.

**Refinement.** The `forms` path currently converges to the same result with a
line of flavour. Make the forms path *cost* — one attempt, then the nurse
comes round the desk. Set `world_flags["tried_the_form"]`; the ending prose
can remember whether the player fought the paper or gave up on it.

### 2 — `shard_lost` · the ridged fragment · Berlin · BUILT

**Holder.** The Fundbüro clerk, and his ledger.

**Why it will not come.** He has no way to know it is yours, and he has a book
that says what he is allowed to do.

**What must be understood.** Two things, and both are cultural, not
transactional. First: a stranger found an unidentifiable object on the tracks
and *carried it to an office* rather than pocketing it or binning it. That is
the fact the player has to sit with. Second: the fee is not a bribe. He rubs
two fingers together and an alien raised on London or Istanbul would read
extortion. It is a listed charge. Paying it without flinching is the correct
gesture; refusing it insults the office.

**The turn.** He turns the ledger round and taps an empty box, and the player
draws the only mark they know is theirs. A signature is a promise in a shape.
The alien has one. Already written.

### 3 — `shard_evidence` · the etched fragment · Berlin · BUILT

**Holder.** The Polizeiwache, as Fundsachen. Bagged, numbered, released only
to its owner.

**Why it will not come.** Because *claiming* is not *owning*, and the officer
has heard the claim from better liars.

**What must be understood.** The best beat in the game so far and it should be
the model for the other two cities: **assertion is not proof, and pointing
harder is not a stronger argument.** The player must produce evidence that
speaks without a language — the medical shard, whose broken edge fits the
bagged one and fits nothing else in the world.

**The turn.** Two broken edges that only fit each other. Something in his face
changes. Already written. The `insist` path correctly costs reputation.

**Note the dependency.** `shard_evidence` requires `shard_medical`. The
ordering is already enforced by `can_prove`. Leave it.

### 4 — `shard_london` · the cold fragment · London · TO BUILD

**Holder.** **Denny Rooke.** Dealer. Salvage, militaria, curios, house
clearances — a lock-up under a railway arch, with a market running past the
door. He bought the fragment off a courier who did not know what it was
either, and he does not know what it is, and that is exactly why he likes it.

**Why he will not hand it over.** *He never says no.* This is the whole point.
He is warm, he is delighted to see you, he speaks slowly and clearly for the
foreigner, and he says:

> "Yeah, no, I hear you. Leave it with me. I'll have a look for you, definitely.
> Thing is, it's sort of spoken for. But no, come back, come back any time."

Every word of that is legible. The alien parses all of it. The alien walks out
with what feels like a promise, and comes back, and gets the same warmth and
the same nothing, and comes back again. Denny is not lying. In his language
this was an unambiguous refusal, delivered with maximum kindness, and the
player has been told no four times and recorded four maybes.

**What must be understood.** Three layers, and the player has to climb all
three:

1. **That "yes" was a "no".** The refusal is real. Nothing the player does
   with Denny directly will move it, because there is nothing to move — you
   cannot argue with a man who has already agreed with you.
2. **That the actual channel is sideways.** In Denny's world you do not sell
   to a stranger off the street. You sell to a friend of a friend. The
   fragment is not for sale to the player because the player is nobody's
   friend. It is not about money. It is about who introduces you.
3. **That the introduction has to be earned from someone the player cannot
   understand at all.**

**Bev.** Runs the caff across the road from the arches — she has fed Denny
breakfast for eleven years. She talks fast, drops consonants, and uses about
six words the player will never find in any dictionary. She is the hardest
speaker in the game. **She is also the only person in London who tells the
player the truth.** That inversion is the act:

> The man I understand perfectly has told me nothing true.
> The woman I cannot understand at all has never once lied to me.

Attunement to Bev cannot be bought or rushed. It goes up by sitting there. By
working the morning rush with her. By letting her finish. It goes *down* if
the player asks her to speak properly — the one response option that looks
polite and is a small act of contempt.

**The turn.** The player never wins the argument, because there is no
argument. One morning Bev puts down a plate, wipes her hands, walks out of the
caff, crosses the road, and says nine words to Denny in the doorway of the
lock-up.

The player does not understand one of them.

Denny's whole face changes. He goes into the back and comes out with a shoebox.

That is the beat. Berlin: understood nothing, and proved it with an object.
London: understood every word from the man who had it, and it meant nothing —
and the sentence that actually got it back was inaugurally, completely opaque.

**The Istanbul lead** comes out of the same shoebox. Denny keeps his book. The
courier had two. He sold one on to a runner headed east. Denny reads the name
of a market out of the ledger, and mispronounces it, and Bev corrects him, and
neither of them can spell it. Sets `world_flags["istanbul_lead"]`.

### 5 — `shard_istanbul` · the bright fragment · Istanbul · TO BUILD

**Holder.** **Yusuf**, who keeps a shop in a han off the market. The bright
fragment is not in a case and not in a drawer and not for sale.

It is strung on a cord above his doorway, between two blue glass eyes.

His brother **Kerem** bought it off a runner four years ago, thought it was
pretty, drilled a hole in it and hung it up as a charm. Kerem is not here any
more. The shop has done well since. Nobody in the family thinks those two
facts are unrelated, and nobody in the family would say so out loud.

**Why he will not hand it over.** Not price. *Price is the insult.* Offering
money for it says two things at once: that his luck has a number on it, and
that he looks like a man who needs cash. The player, trained by Berlin
(pay the correct fee) and London (find the right channel), will get this
exactly wrong, twice, and both wrong answers cost reputation.

**What must be understood.** That the way in is not a transaction at all.
Istanbul will not sell to you. Istanbul will *take you in*, and the entire act
is the alien learning to be taken in — which turns out to be the hardest thing
it has been asked to do, because it means owing.

The sequence, and every step of it is a refusal the player must not make:

- **The tea.** Yusuf pours a glass before a word is exchanged. Refusing it, or
  paying for it, ends the conversation politely and permanently. The player's
  Berlin instinct — settle up, owe nothing — is the failure state here.
- **The stool.** He will not talk business standing. Sitting down and letting
  an hour go past with nothing agreed is the work.
- **The meal.** Meryem, his mother, feeds whoever is in the shop at the hour
  she feeds people. She never once asks the alien a question it cannot answer.
  She asks it whether it is hungry, which is a question that can be answered
  with a plate.
- **The fourth plate.** You are full. Eat it. Stopping too early says the food
  was not good.
- **The bed.** They will offer. The hotel is right there and the player has
  money. Taking the room is the last polite refusal available and it undoes
  most of the week.
- **The work, unpaid.** Sweeping the shop, carrying trays, sitting with Meryem
  while she does not need help. And then refusing the money when Yusuf tries
  to press it on you — which is the exact inverse of every correct move in
  Berlin, where refusing payment would have been incomprehensible.

By the end of it the player is not a customer. That is the only status that
can get the charm down, and it cannot be reached by any road that starts with
"how much".

**The turn.** The player never asks for it. Yusuf works out what it is —
because the player is finally understood well enough to be asked, and finally
fluent enough to answer, and the answer is a drawing of a sky and a hand laid
on a scar.

He goes quiet. He goes outside. He unties the knot with his thumbnail, takes
the bright piece off the cord, and ties the cord back up with one bead missing.

Then he puts it in the player's hand and says the sentence that names the act:

> *"Kerem'in."* — It was Kerem's.

He is not giving away an object. He is giving away his luck, and his brother's
last purchase, to a stranger who ate at his table for a week. Sets
`world_flags["charm_taken"]` and `world_flags["charm_named"]`.

**What the player owes.** The game does not resolve this for them. The cord
over the door has a gap in it and the gap is visible in the scene from then
on. `world_flags["charm_repaid"]` is set only if the player goes back with
something — not money. Working the shop for three more days after they have
what they came for. Bringing the blue bead that replaces it. The ending reads
this flag and it is the only one that follows the player home.

---

## Gates

Three hard gates. Each is a wall of understanding, not of inventory.

### Gate A — Berlin will not sell you a ticket out

Extends `Services._airport_desk()`, which already checks the first condition.

| # | Condition | Concrete state |
|---|---|---|
| 1 | All three Berlin fragments | `has_fragment("shard_medical") and has_fragment("shard_lost") and has_fragment("shard_evidence")` — built as `berlin_done` |
| 2 | You have slept here once | `world_flags["rested"] == true` |
| 3 | You can answer the desk | `words_at_tier("german", TIER_PARTIAL) >= 12` (new helper) |
| 4 | The fare | `GameState.money >= 15` (EUR) |
| 5 | You have money for where you land | `world_flags["used_exchange"] == true` — soft gate: allowed without it, but the arrival scene has no coins in it |

Condition 3 is the important one and it needs its own scene beat. The desk
agent asks three questions. Not in mime — she is behind glass, she is on a
schedule, and she will not draw pictures. Below twelve partial words the
questions are a wall of sound and she waves the player aside for the next
person in the line. This is the only place in Berlin where *not knowing the
words* is what stops you, and it lands hardest right at the end of the act
where the player thought they had learned to cope without them.

On success: `world_flags["ticket_" + dest] = true`, `world_flags["left_berlin"] = true`,
`GameState.travel_to(dest)`, `complete_quest_step("leave_berlin", 3)`.

Delete the placeholder line `( that city is not built yet — the trail waits )`.

### Gate B — Istanbul does not open until London closes

The departures board offers Istanbul from Berlin. It must be refusable in a
way that is information rather than a lock.

| # | Condition | Concrete state |
|---|---|---|
| 1 | You know where you are going | `world_flags["istanbul_lead"] == true` |
| 2 | You have the London piece | `has_fragment("shard_london")` |
| 3 | Fare | `cash("GBP") >= 15` |

`_dest_note("istanbul", …)` before the lead should read: *"you know a market is
involved. You do not know which city the market is in."* The trail is
sequential and it is sequential for a reason the player can feel: Denny's
ledger is the only record of where the fifth piece went.

Attunement is folded in through condition 1 — the lead comes out of the
conversation that only happens after `world_flags["bev_vouched"]`, which
requires `attune_tier("bev") >= TIER_PARTIAL`. No separate check needed.

### Gate C — the field

Ending is reachable only at the WreckSite, in Berlin, with all five:

```gdscript
GameState.fragment_count() >= 5 and GameState.city == "berlin"
```

sets `world_flags["core_whole"]` and starts `stay_or_go`.

The last flight is a fourth ticket the player has to fund from an Istanbul
wallet, through the exchange, at a tenth off. Going home costs money and the
game should make them count it.

---

## Quest ids

Naming matches what exists: lowercase snake, one or two words, plain.

Existing: `pod_core` · `first_trade` · `get_map` · `find_bed` · `leave_berlin`

| id | title | steps |
|---|---|---|
| `leave_berlin` | *Two more, somewhere else* | extend from 2 to 4: change money · earn the fare · get past the woman at the desk · buy a flight |
| `read_the_room` | *Everyone here is being lovely* | he said yes four times · find out what he meant · stop asking him · sit in the caff until she stops slowing down |
| `cold_fragment` | *The man under the arch* | find the lock-up · hear the shoebox mentioned · be introduced |
| `leave_london` | *East, apparently* | get the name off his ledger · change money · buy a flight |
| `be_a_guest` | *They keep giving me things* | drink the tea · sit down and stay sat · eat at the table · sleep where they put you · work, and refuse the money |
| `bright_fragment` | *Above the door* | see what is on the cord · learn whose it was · tell them where it came from |
| `mend_the_core` | *All five* | get back to the field · put them together |
| `stay_or_go` | *The pod is fixed* | decide |

`pod_core` already has the five steps and `recover_fragment()` already ticks
them by index. Do not reorder `_fragment_step()`.

---

## The language systems

Berlin's per-word model is built and is the baseline. The other two are new,
and each is small.

### London — per-speaker attunement

The alien understands standard English on arrival. It does not understand
speed, elision, or slang. Familiarity is **per speaker**, not per word.

New state on GameState, and one new key in `SaveManager.save_game`:

```gdscript
# ── London: you understand the language, not the person ──────────────────────
# Attunement is per speaker. Standard English arrives whole; anything marked
# fast, dropped or local reads through the speaker's number instead.
var attunement: Dictionary = {}      # speaker_id -> 0-100

const ATTUNE_GAIN := {
	"listen":   3,    # one full exchange at their speed
	"patience": 8,    # you let them finish; you did not ask them to slow down
	"shared":   12,   # a shift worked, a round bought, a joke that landed
}
```

Tier thresholds reuse 25 / 50 / 80 so `get_tier`'s constants stay the single
source of truth. `attune_tier(speaker_id) -> int` mirrors `get_tier`.

Dialogue word entries in London carry a `fast` flag:

```gdscript
{"text": "A'right",  "word": "alright", "language": "english", "fast": true},
{"text": "morning",  "word": "morning", "language": "english"},
```

`DialogueBox.show_dialogue` takes an optional `speaker_id: String = ""`.
`_render_word` gets one branch: for `language == "english"`, an entry without
`fast` renders at `TIER_KNOWN` always; an entry with `fast` renders at the
speaker's attune tier. Glyphs, the animation path and the tooltip all work
unchanged.

**Denny starts attuned and stays legible.** He is easy from the first line and
never gets harder. **Bev starts at zero.** Her first three visits are almost
solid glyphs with two English words floating in them, which is precisely the
experience of being new in a city and being spoken to like a local.

One response option in Bev's tree — *"Ask her to say it properly"* — reads as
polite, applies `-10`, and is the only negative attunement move in the game.

### Istanbul — per-stem, with suffixes

Turkish builds words out of a stem and a stack of endings, so the third model
is the first one that *gives back*. Words the player has never heard become
half-readable because of what is inside them.

Stems live in `familiarity["turkish"]`. Endings live in
`familiarity["turkish_sfx"]` — a separate language bucket, which means it
serialises through `SaveManager` with no change at all.

```gdscript
const TR_SUFFIXES := ["lar", "ler", "im", "in", "iz", "de", "da", "den", "dan",
	"ye", "ya", "yor", "dir", "ci", "cı", "lik", "lık", "siz", "sız"]
```

`tr_split(word) -> Array` peels endings off the tail, longest first, and
returns `[stem, [suffixes]]`. `tr_tier(word) -> int` returns the stem's tier,
stepped down once for each *unknown* ending it carries, floored at UNKNOWN.

So: knowing `ev` alone makes `evde` glimpsed. Knowing `ev` and `-de` makes
`evde` readable the first time it is ever spoken. This is the mechanical shape
of the act's feeling — the language starts paying the player back for having
stayed.

---

## Money

`Services.JOBS` gains a `city` key and `_jobboard()` filters on
`GameState.city`. Nothing else in the jobs system changes. Pay is in local
currency, so Istanbul's numbers are large — with `RATES["TRY"] = 35.0` a £5
job is roughly ₺200 and the exchange takes a tenth on the way in.

| id | city | giver | pay |
|---|---|---|---|
| `crates`, `flyers`, `dishes`, `sweep` | berlin | built | 3–5 € |
| `van_rush` | london | Bev, through the hatch | 6 £ |
| `arch_haul` | london | Denny, who pays cash and counts it in front of you | 5 £ |
| `cay_run` | istanbul | the tea man, who hands you the tray before you agree | ₺160 |
| `unload` | istanbul | a van blocking the han gate | ₺200 |

`van_rush` is the attunement engine — a shift beside Bev grants
`ATTUNE_GAIN["shared"]`. `arch_haul` deliberately does not; you can work for
Denny all week and be no closer to him, which is the joke and the lesson.

Istanbul has a fifth job that pays nothing: **`shop_sit`**, sweeping Yusuf's
floor. It offers money on completion and the correct answer is to refuse it.
Refusing sets `world_flags["refused_pay"]`, a required step of `be_a_guest`.
Taking it is not a fail state — it is just a week added.

---

## New scenes

Interiors stay code-drawn. `InteriorBackground.room` takes new values; the
shell, floor and lighting come from `InteriorArt` as they already do.

**London** — `Arches.tscn` (street, `ArchesBackground.gd`: brick arches, a
market running past, wet light) · `Lockup.tscn` (`room = "lockup"`) ·
`Caff.tscn` (`room = "caff"` — formica, a hatch, a tea urn, condensation).

**Istanbul** — `Carsi.tscn` (street/market, `CarsiBackground.gd`) ·
`Han.tscn` (`room = "han"` — the courtyard arcade, Yusuf's shop, the cord over
the door with the fragment on it, drawn) · `Lokanta.tscn` (`room = "lokanta"` —
one long table).

**Reused, made city-aware** — `Airport.tscn`, `Exchange.tscn`. Both are single
interiors driven by `Services`; branch on `GameState.city` inside
`_airport_desk()`, `_exchange()` and `InteriorBackground` rather than
duplicating the scenes. This is the cheapest correct answer and it keeps the
departure board in one place.

**Reputation regions.** `GameState.reputation` gains `"arches"` and `"carsi"`.
Add them to `reset()` too. `REP_LEVELS` is written in a Berlin voice —
London and Istanbul want their own ladders, keyed by region, or the ending
prose will sound wrong in two cities out of three.

---

## The three moments

The real payoff of the game is not the fragments. It is these. Each is a
ThoughtBox, first person, shown once, gated on a flag.

### Berlin — `understood_berlin`

Gate: `get_tier("german", "brot") >= TIER_PARTIAL` and `world_flags["bread_bought"]`,
at the stall, on a return visit.

> I said it.
>
> Not well. The sound came out of the wrong part of me and landed
> somewhere near the word — close enough to be aimed at it.
>
> Brot.
>
> He did not correct me. He did not give me the smile people here
> give a child. He turned round, took a loaf off the back rack, put
> it in my hands, and carried on arguing with the man behind me
> about something else entirely.
>
> That is the whole thing. He heard a want, and he answered it.
>
> For four days I have been a shape in the road that people walk
> around. Just then, for one second, I was a customer.

### London — `understood_london`

Gate: `attune_tier("bev") >= TIER_PARTIAL`, on the visit after the player has
picked the local greeting over the correct one.

> For a week she has been slowing down for me.
>
> I did not notice her doing it until this morning, when I stopped
> letting her. I did not say good morning. I said it the way the
> room says it — half of it swallowed, the whole sentence leaning
> forward like it is late for something.
>
> A'right.
>
> And she said it back at full speed and kept going, straight into
> a story about her sister's boiler, and did not check my face once
> to see whether I was keeping up.
>
> I understood perhaps a third of it.
>
> I have never been so completely inside a conversation.
>
> In this city, being understood is not being explained to. It is
> being left alone in the middle of the language, the way you leave
> someone alone in a room they live in.

### Istanbul — `understood_istanbul`

Gate: the first time the player selects a response built from a stem and a
suffix they know separately and have never heard joined.

> I built a word.
>
> I have never heard it. Nobody has ever said it to me. I took the
> piece that means water, and the piece that means yours, and I
> stacked them the way I have watched them stack all week, and I
> pushed the result across the table with my voice.
>
> Suyunuz.
>
> The table stopped.
>
> Then Meryem said it back to me — the same word with the edges
> filed off it, the way it is supposed to sound — and passed the
> jug, and the eating started again, and nobody made anything of it.
>
> In Berlin I learned words. In London I learned that the words are
> not where the meaning is kept. Here the language has handed me a
> tool and walked off and left me to make things with it.
>
> I have been given a great deal in this house.
>
> That is the first thing I have made in it.

---

## Endings

All endings are reached at the WreckSite with `fragment_count() == 5`. The pod
is repairable in every one of them. **Staying only means something because
leaving is genuinely available** — never gate the stay ending on failure.

New helper, so the endings read from something real:

```gdscript
const CITY_REGIONS := {
	"berlin":   ["kiez", "mitte", "prenzlberg"],
	"london":   ["arches"],
	"istanbul": ["carsi"],
}

func city_regard(c: String) -> int      # mean reputation across that city's regions
func words_known() -> int               # words_at_tier(lang, TIER_PARTIAL) summed
                                        # across german, english, turkish
```

### Leave — unseen

`city_regard(c) < 15` for all three · `words_known() < 25`

The field at dawn. The core seats and holds. Nothing goes wrong. The burn ring
is still in the grass from the first landing and it will still be there
tomorrow, and no one who walks past it will know what it was.

> Nobody came. There was no reason for anybody to come.
>
> I was here for a season and I leave the way I arrived — as a thing
> that happened to a field.
>
> I know four hundred words. I never once managed to be a person
> anybody would walk across a road for.

### Leave — seen off

`city_regard >= 35` in at least two cities · `words_known() >= 60`

They come. Not all of them and not from everywhere — the ones who can get to a
field outside Berlin on a Tuesday. Renate. Lukas, who shuts the stall for it.
The officer, off duty, who stands well back.

And in the pocket: a card from a caff with a phone number on it in biro, and a
small heavy parcel from Istanbul that the player is not shown opening.

> I have learned how to say goodbye in three languages and I am told
> that I get all three of them slightly wrong.
>
> I said them anyway. Every one. To the right people, in the right
> order, with the right hands.
>
> That is not fluency. I have decided it is better than fluency.

### Leave — owed

Modifier on either leaving ending. `world_flags["charm_taken"] and not
world_flags["charm_repaid"]`. Plays last, after the pod lights.

> There is a shop in a courtyard on the other side of the world with
> a cord over its door, and the cord has a gap in it where I am.
>
> He did not sell it to me. He would not have sold it to me. He gave
> it to me because by then I was somebody it could be given to.
>
> I am taking their luck off the planet at four hundred metres a
> second and I never went back with the bead.

### Stay — by choice

Player picks it, and `city_regard(c) >= 35` for the chosen city. The pod is
repaired and left sitting in the grass with the hatch open. Ending text
branches on the city:

- **Berlin.** An Anmeldung. A form, a counter, a woman with a pen. Every box
  is a box now. The player fills it in, and the hardest part is choosing what
  to write on the line that says name.
- **London.** The caff at six in the morning. Bev says one full sentence at
  full speed about the weather, and the player gets all of it, and it is the
  most beautiful thing anyone has ever said to them.
- **Istanbul.** The cord over the door, retied. There is a new bead in the
  empty place and it is the wrong blue, and Yusuf has not mentioned it once.

### Stay — because there is nowhere to be

Player picks stay with no city at `>= 35`. Same repaired pod, same open hatch,
different sentence. This is a real ending, not a punishment, and it should be
written with respect: staying because you have nowhere to go is a thing that
happens to people, and it is what the whole game is about.

> The pod works. I checked it twice.
>
> I am not staying because I am wanted here. I am staying because I
> have run out of places where I would be less of a stranger, and
> this one at least has bread I know the word for.

---

## Flags, in one place

Existing: `kiez_pouch_taken` · `bread_bought` · `renate_met` · `has_map` ·
`room_booked` · `hotel_entered` · `rested` · `used_exchange` · `rode_ubahn` ·
`visited_<city>`

New, Berlin: `tried_the_form` · `understood_berlin` · `ticket_london` ·
`ticket_istanbul` · `left_berlin`

New, London: `denny_met` · `denny_soft_no` · `read_the_room` · `caff_regular` ·
`bev_vouched` · `understood_london` · `istanbul_lead`

New, Istanbul: `guest_tea` · `guest_sat` · `guest_meal` · `guest_bed` ·
`refused_pay` · `charm_named` · `understood_istanbul` · `charm_taken` ·
`charm_repaid`

New, endgame: `core_whole` · `ending_chosen`

New GameState fields: `attunement: Dictionary`. Add to `save_game` and
`load_game` (through `_int_values`), and to `reset()`. Add `"arches"` and
`"carsi"` to `reputation` and to `reset()`.

New GameState helpers: `words_at_tier(lang, tier)` · `attune(speaker, kind)` ·
`attune_tier(speaker)` · `tr_split(word)` · `tr_tier(word)` ·
`city_regard(city)` · `words_known()`

---

## Build notes

- `leave_berlin` grows from 2 steps to 4. Quests are constructed at runtime, so
  saves made before the change keep their old two-step list and will never
  complete. Either accept that, or have `_airport_desk` complete the last step
  by index-from-end rather than by literal index.
- Everything above is static design. Nothing here has been run.
- The Berlin three are built and correct. Do not rewrite them to match this
  document — this document was written to match them.
