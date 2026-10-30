# Berlin Audit — recovered from workflow run wf_6b0aeee5-a56

Static analysis only; Godot was not installed and nothing was run.


---

## Audit agent 1 (ad452dd5a491840b4)

# THE CITY TEMPLATE â€” "Foreign to All"

Contract for building a new city (London / Istanbul) without re-reading Berlin.
Every path below is absolute-real and every signature is quoted verbatim from disk.
Project root: `C:/Users/gulci/Downloads/foreigntoall` (= `res://`).

---

## 0. READ THIS FIRST â€” three things that are broken or missing on disk right now

**0.1 `C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd` does not parse.**
Lines 200â€“205 call a function that is never defined anywhere in the file (verified: the file is 391 lines and `grep` finds only the six call sites, no `func`):

```gdscript
		"Exchange":     _draw_interior_map("counter", "the glass, and what is behind it")
		"Police":       _draw_interior_map("counter", "the desk Â· found property")
		"Hospital":     _draw_interior_map("counter", "reception Â· curtains beyond")
		"Restaurant":   _draw_interior_map("counter", "the bar Â· tables Â· the hatch")
		"UBahnStation": _draw_interior_map("platform", "platform edge Â· machine Â· FundbÃ¼ro")
		"Airport":      _draw_interior_map("counter", "check-in Â· the board Â· the glass")
```

`MapView.tscn` is instanced by **every playable scene** (directly in the street scenes, and via `UILayer.tscn` in every interior). Until `_draw_interior_map(kind: String, note: String) -> void` exists, nothing loads. **Fix this before adding a single new scene**, and add your new city's scene names to the `_open()` title dictionary (MapView.gd:65-78), the `region` dictionary (:80-83) and the `_draw_map()` match (:193-205), or your city silently maps to `"Somewhere"` with a blank canvas.

**0.2 `GameState.travel_to()` exists but is called by nobody.**
`Services._airport_desk()` (autoload/Services.gd:356-398) charges the fare and then prints a placeholder thought: `"( that city is not built yet â€” the trail waits )"`. It never sets `GameState.city`, never calls `TransitionManager.go()`. The new-city builder owns that wiring. The correct sequence is `GameState.travel_to(pick)` â†’ `GameState.spawn_tag = "from_flight"` â†’ `TransitionManager.go("<first scene of the new city>")`. `travel_to` already does `city = dest_city`, sets `world_flags["visited_" + dest_city] = true` and re-emits `money_changed` (because `GameState.money` is a computed property over `wallet[currency()]` â€” arriving in London makes the HUD read `Â£` and the GBP pocket).

**0.3 Latent parse hazard already in the shipped code.** `autoload/Services.gd:234`:

```gdscript
	var dest := {
		"mitte":     "res://scenes/world/Mitte.tscn",
		"klinik":    "res://scenes/world/Hospital.tscn",
		"flughafen": "res://scenes/world/Airport.tscn",
	}.get(pick, "")
```

This is exactly the `:=`-from-`.get()` pattern that has broken this project before. Do not copy it; write `var dest: String = {...}.get(pick, "")`.

---

## 1. COORDINATE SYSTEM AND HARD CONVENTIONS

| Fact | Value |
|---|---|
| Authoring box for every scene | **1152 Ã— 648 world px** (`VW`/`VH` constants repeated in each background script) |
| Project viewport | 1920Ã—1080, `stretch/mode="canvas_items"`, `aspect="expand"` â€” the Player carries a `Camera2D`, so the 1152Ã—648 box is a camera-scrolled world, not a fixed frame |
| Outdoor horizon / walkable top | y = **292** is where sky ends; `WorldBorder.wall_top` default **305** |
| Outdoor street bands | sidewalk 292â€“372, asphalt 372â€“516, sidewalk 516â€“648 |
| Interior geometry (`InteriorArt` consts) | `CEIL 46`, `WALL 305`, `NEAR 606`, `SIDE 44`; walkable floor = x 44â€“1108, y 305â€“606 |
| Pixel art | authored 1Ã—, displayed 2Ã—, `TEXTURE_FILTER_NEAREST`. `WorldArt.sprite()` multiplies your 1Ã— position by 2 for you |
| Clear colour / void | `Color(0.043, 0.039, 0.110)` â€” every background paints a huge `EXT := 4000.0` rect of this so the camera never sees past the plate |
| Indentation | **TABS only.** Verified: zero `.gd` files in the repo contain leading spaces |
| Interact key | Raw `KEY_E` in `_unhandled_input`. There is **no** input-map action for interact. `ui_cancel` (Esc) is the only mapped action used |
| Godot | 4.7, `gl_compatibility` renderer |

**`WorldArt` and `InteriorArt` are NOT autoloads.** `project.godot` `[autoload]` lists only GameState, SaveManager, UIStyles, TransitionManager, AudioManager, Services. `WorldArt` (`autoload/WorldArt.gd`) and `InteriorArt` (`scenes/world/InteriorArt.gd`) are globals via `class_name WorldArt extends Object` / `class_name InteriorArt extends Object` and are called statically.

---

## 2. FILE CHECKLIST FOR ONE NEW CITY

```
scenes/world/<Street>.tscn        + <Street>.gd          (one per outdoor block)
scenes/world/<City>Background.gd  (shared by that city's streets, @export district)
scenes/world/<Interior>.tscn      (reuses Interior.gd + InteriorBackground.gd)
```
plus edits to:
```
scenes/world/InteriorBackground.gd   â€” new `room` cases in the _draw() match
autoload/Services.gd                 â€” new service handlers + run() dispatch lines
autoload/GameState.gd                â€” reputation regions, WORD_GUESSES, reset()
scenes/ui/Inventory.gd               â€” ITEM_DEFS entries for new items/fragments
scenes/ui/MapView.gd                 â€” titles, region map, _draw_map() cases
scenes/ui/Journal.gd                 â€” de-hardcode "german" (see Â§10.4)
```
**No new art files.** `art/world/facades/` contains only German buildings (`altbau`, `apotheke`, `baeckerei`, `biergarten`, `block`, `cafe`, `hotel`, `markthalle`, `spaeti`). `art/world/scenes/` has only `mitte_*`/`wreck_*`/`lobby_dawn`/`title`/`intro_*` plates. **A new city has zero authored plates and must be drawn entirely in GDScript**, using `MitteBackground._build_ost()`/`_draw()` as the model (tileset bands + `_draw()` primitives) and the shared, city-neutral props (`bench`, `bush`, `tree`, `fence`, `crate(s)`, `debris`, `signpost`, `stall`, `tarp_stall`, `table_set`, `shelter`, `low_table`, `sofa`, `plant`, `desk`, `wall_art`, `sconce`, `chandelier`, `key_rack`, `glow_pool`, `smoke`).
NPC sheets available: `commuter_f`, `commuter_m`, `lukas`, `renate`, `weber`, `pigeon`. Use `commuter_f`/`commuter_m` for all new clerks â€” that is what every Berlin ServicePoint does.

---

## 3. STREET SCENE â€” EXACT ANATOMY

### 3.1 `scenes/world/Mitte.tscn` â€” verbatim header and node tree

```
[gd_scene format=3]

[ext_resource type="Script"      path="res://scenes/world/Mitte.gd"            id="1_mitte"]
[ext_resource type="Script"      path="res://scenes/world/MitteBackground.gd"  id="2_bg"]
[ext_resource type="Script"      path="res://scenes/world/WorldBorder.gd"      id="3_border"]
[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn"        id="4_player"]
[ext_resource type="PackedScene" path="res://scenes/world/SceneExit.tscn"      id="5_exit"]
[ext_resource type="PackedScene" path="res://scenes/dialogue/DialogueBox.tscn" id="6_dlg"]
[ext_resource type="PackedScene" path="res://scenes/ui/EscapeMenu.tscn"        id="7_esc"]
[ext_resource type="PackedScene" path="res://scenes/ui/Journal.tscn"           id="8_jrn"]
[ext_resource type="PackedScene" path="res://scenes/ui/Inventory.tscn"         id="9_inv"]
[ext_resource type="PackedScene" path="res://scenes/ui/ThoughtBox.tscn"        id="10_tb"]
[ext_resource type="PackedScene" path="res://scenes/ui/HudBar.tscn"            id="11_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/QuestLog.tscn"          id="12_ql"]
[ext_resource type="Script"      path="res://scenes/npc/WalkingFriends.gd"     id="13_wf"]
[ext_resource type="PackedScene" path="res://scenes/npc/BusStopNPC.tscn"       id="14_bus"]
[ext_resource type="PackedScene" path="res://scenes/ui/MapView.tscn"           id="15_map"]

[ext_resource type="PackedScene" path="res://scenes/ui/ChoicePanel.tscn"       id="16_cp"]

[sub_resource type="RectangleShape2D" id="Shape_hoteldoor"]
size = Vector2(96, 62)

[node name="Mitte" type="Node2D"]
script = ExtResource("1_mitte")

[node name="MitteBackground" type="Node2D" parent="."]
z_index = -2
script = ExtResource("2_bg")

[node name="WorldBorder" type="StaticBody2D" parent="."]
script = ExtResource("3_border")

[node name="Player" parent="." instance=ExtResource("4_player")]
position = Vector2(110, 440)

[node name="WalkingFriends" type="Node2D" parent="."]
position = Vector2(320, 346)
script = ExtResource("13_wf")

[node name="BusStopNPC" parent="." instance=ExtResource("14_bus")]
position = Vector2(712, 322)

[node name="ExitToKiez" parent="." instance=ExtResource("5_exit")]
position = Vector2(28, 440)
target_scene = "res://scenes/world/Kiez.tscn"
spawn_tag = "from_mitte"
prompt_text = "E â€” Back to the field"
...
[node name="ChoicePanel" parent="." instance=ExtResource("16_cp")]

[node name="CollisionShape2D" parent="HotelEntrance" index="0"]
shape = SubResource("Shape_hoteldoor")

[node name="Prompt" parent="HotelEntrance" index="1"]
position = Vector2(-76, -70)

[node name="DialogueBox" parent="." instance=ExtResource("6_dlg")]
[node name="EscapeMenu" parent="." instance=ExtResource("7_esc")]
[node name="Journal" parent="." instance=ExtResource("8_jrn")]
[node name="Inventory" parent="." instance=ExtResource("9_inv")]
[node name="QuestLog" parent="." instance=ExtResource("12_ql")]
[node name="MapView" parent="." instance=ExtResource("15_map")]
[node name="ThoughtBox" parent="." instance=ExtResource("10_tb")]
[node name="HudBar" parent="." instance=ExtResource("11_hud")]
```

Format rules extracted:
* Header is exactly `[gd_scene format=3]` â€” **no `load_steps`, no `uid`**. (Interiors carry a stale `load_steps=12`; Godot recomputes it. Only `WreckSite.tscn` has a `uid`. Follow Mitte: omit both.)
* `ext_resource` ids are `<n>_<mnemonic>` and the columns are space-padded into alignment. Match this â€” it is part of the house voice.
* Overriding a child of an **instanced** scene requires the `index=` attribute: `[node name="CollisionShape2D" parent="HotelEntrance" index="0"]` / `[node name="Prompt" parent="HotelEntrance" index="1"]`. Index 0 = `CollisionShape2D`, index 1 = `Prompt`, per `SceneExit.tscn` child order.
* Overlay UI is declared last, after world nodes.
* Street scenes list every UI scene by hand and **omit `AngryBox.tscn`**; interiors use `UILayer.tscn` which includes it. For new streets, prefer instancing `res://scenes/ui/UILayer.tscn` as a single node â€” it is the superset and is already the interior standard. If you hand-list instead, `ChoicePanel.tscn` is **mandatory** for any street holding a `ServicePoint` (`Services._choice()` returns `get_tree().get_first_node_in_group("choice_panel")` and every handler bails on null).

### 3.2 Blocking geometry

Two mechanisms, both used:
* **`WorldBorder`** (`scenes/world/WorldBorder.gd`) â€” a `StaticBody2D` with the script attached, four exported floats. Defaults `wall_top 305 / wall_bottom 648 / wall_left 0 / wall_right 1152` suit outdoor scenes; it builds 200-px-thick `RectangleShape2D` walls in `_ready()`.
* **Ad-hoc `StaticBody2D` + `CollisionPolygon2D`** for anything solid inside the box. Verbatim pattern (`Kiez.tscn`):
```
[node name="PodCollision" type="StaticBody2D" parent="."]

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="PodCollision"]
polygon = PackedVector2Array(67, 375, 114, 253, 210, 216, 302, 239, 366, 339, 350, 375)
```
Every interior with a counter carries a `CounterCollision` node of exactly this shape (see Â§4.1).

### 3.3 `scenes/world/Mitte.gd` â€” the whole file

```gdscript
extends Node2D

# Where the player appears depends on which door they came through.
const SPAWNS := {
	"from_mitte_ost": Vector2(1040, 440),
	"from_hotel":     Vector2(150, 350),
	"from_exchange":  Vector2(1004, 380),
	"from_ubahn":     Vector2(496, 386),
	"from_ubahn_stairs": Vector2(496, 386),
}


func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "mitte"
	else:
		GameState.visit_region("mitte")
	if SPAWNS.has(GameState.spawn_tag):
		$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
```

`MitteOst.gd` and `Kiez.gd` are the same five moves. **Copy this shape exactly for every new street scene.** The `skip_next_visit_count` branch is not optional: `SaveManager.load_game()` sets it so loading a save does not advance NPC dialogue rounds (`NPC._round_for_visit()` reads `GameState.region_visits`).

`AudioManager.set_ambience(kind: String)` accepts exactly `"field"` (windy, gusting), `"street"` (city rumble), `"interior"` (room tone), `"none"`. Everything is synthesised â€” no files.

### 3.4 `scenes/world/MitteBackground.gd` â€” the city-art model

Two dispatch modes on one script via `@export var district: String = "west"`:
* `"west"` â€” one shipped plate: `WorldArt.sprite(self, WorldArt.tex("scenes/mitte_%s.png" % WorldArt.mode()), Vector2.ZERO, 1)`.
* `"ost"` â€” **composed in code. This is the model for a new city.** `_ready()` places facade/prop sprites; `_draw()` paints sky bands, a procedural skyline, signage, then the street tile bands; `_process()` calls `queue_redraw()` only when animated.

```gdscript
const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

var _t: float = 0.0

func _process(delta: float) -> void:
	if district == "ost":
		_t += delta
		queue_redraw()

func _draw() -> void:
	# The node's own drawing sits behind its positive-z children
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)
	...
	var morning := GameState.is_morning()
	if morning:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.42, 0.58, 0.74))
		draw_rect(Rect2(0, 190, VW, 102), Color(0.52, 0.64, 0.77))
	else:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.045, 0.040, 0.105))
		draw_rect(Rect2(0, 45, VW, 180), Color(0.072, 0.058, 0.148))
		draw_rect(Rect2(0, 180, VW, 70), Color(0.160, 0.090, 0.182))
		draw_rect(Rect2(0, 250, VW, 42), Color(0.300, 0.160, 0.135))
	...
	# Street bands from the tileset (world px; 1Ã— bands Ã—2)
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 292, VW, 80))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT,  Rect2(0, 372, VW, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT_D, Rect2(0, 436, VW, 32))
	WorldArt.draw_tiles(self, WorldArt.TILE_CROSSWALK, Rect2(64, 372, 128, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 516, VW, 132))
```

Sprite z-layering convention in `_build_ost()`: facades `z=2`, props `z=3`. The background node itself is `z_index = -2` in the .tscn, and `_draw()` output sits behind its own positive-z sprite children.

Time-of-day is global and binary: `GameState.time_of_day` is `"dawn"` until the player sleeps, then `"morning"`. Read it via `GameState.is_morning() -> bool`; `WorldArt.mode()` returns `"morning"`/`"dawn"` for texture suffixes. **Every new city's art must branch on it** â€” Berlin does so in the sky bands, the skyline colours, `InteriorArt.window()` and `_dress_airport()`'s curtain wall.

---

## 4. INTERIORS

### 4.1 `scenes/world/Exchange.tscn` â€” the interior skeleton, verbatim

```
[gd_scene load_steps=12 format=3]

[ext_resource type="Script"      path="res://scenes/world/Interior.gd"            id="1_int"]
[ext_resource type="Script"      path="res://scenes/world/InteriorBackground.gd"  id="2_bg"]
[ext_resource type="Script"      path="res://scenes/world/WorldBorder.gd"         id="3_border"]
[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn"           id="4_player"]
[ext_resource type="PackedScene" path="res://scenes/world/ServicePoint.tscn"      id="5_sp"]
[ext_resource type="PackedScene" path="res://scenes/world/SceneExit.tscn"         id="6_exit"]
[ext_resource type="PackedScene" path="res://scenes/ui/UILayer.tscn"              id="7_ui"]

[sub_resource type="RectangleShape2D" id="Shape_exit"]
size = Vector2(70, 200)


[node name="Exchange" type="Node2D"]
script = ExtResource("1_int")
region = "mitte"
spawn = Vector2(210, 430)

[node name="Background" type="Node2D" parent="."]
z_index = -2
script = ExtResource("2_bg")
room = "exchange"

[node name="WorldBorder" type="StaticBody2D" parent="."]
script = ExtResource("3_border")
wall_top = 305.0
wall_bottom = 606.0
wall_left = 44.0
wall_right = 1108.0


[node name="CounterCollision" type="StaticBody2D" parent="."]

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="CounterCollision"]
polygon = PackedVector2Array(462, 218, 958, 218, 958, 312, 462, 312)


[node name="Player" parent="." instance=ExtResource("4_player")]
position = Vector2(210, 430)


[node name="Counter" parent="." instance=ExtResource("5_sp")]
position = Vector2(710, 366)
service = "exchange"
prompt_text = "E â€” Change money"
clerk = "commuter_f"


[node name="Exit" parent="." instance=ExtResource("6_exit")]
position = Vector2(116, 430)
target_scene = "res://scenes/world/Mitte.tscn"
spawn_tag = "from_exchange"
prompt_text = "E â€” Back to the street"

[node name="CollisionShape2D" parent="Exit" index="0"]
shape = SubResource("Shape_exit")

[node name="UILayer" parent="." instance=ExtResource("7_ui")]
```

Interior invariants observed across all six Berlin interiors:
* `WorldBorder` is always `305 / 606 / 44 / 1108` (except `UBahnStation.tscn`, `wall_top = 336.0`, keeping the player off the platform edge).
* Player spawn is always `Vector2(210, 430)`, exit door at `Vector2(116, 430)` (UBahn: `118, 400`) with the `70Ã—200` `Shape_exit` override.
* `CounterCollision` polygon is a flat 4-point box ending at y â‰ˆ 312, matching where `InteriorArt.counter()` was drawn.
* `ServicePoint` sits at roughly the counter's x-centre, y = 366 â€” i.e. **in front of** the counter collision, so the player can reach it.
* Every interior instances `res://scenes/ui/UILayer.tscn` once (that single node supplies DialogueBox, EscapeMenu, Journal, Inventory, QuestLog, MapView, ThoughtBox, AngryBox, ChoicePanel, HudBar).

### 4.2 `scenes/world/Interior.gd` â€” the whole file

```gdscript
extends Node2D

# Shared root for every building interior: sets the region for reputation,
# picks the ambience, and puts the player just inside the door.

@export var region: String = "mitte"
@export var spawn: Vector2 = Vector2(210, 430)


func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.set_ambience("interior")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = region
	else:
		GameState.visit_region(region)
	$Player.position = spawn
	GameState.spawn_tag = ""
```

**Interiors ignore `spawn_tag` entirely** â€” they always land you at `spawn`. Only street scenes branch on it. Reuse `Interior.gd` unchanged for new-city interiors; only set `region` and `spawn` in the .tscn.

### 4.3 `scenes/world/InteriorBackground.gd` â€” how to add a room

```gdscript
extends Node2D

@export var room: String = "exchange"

const IA := preload("res://scenes/world/InteriorArt.gd")

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	match room:
		"exchange":   _dress_exchange()
		"police":     _dress_police()
		"hospital":   _dress_hospital()
		"restaurant": _dress_restaurant()
		"ubahn":      _dress_ubahn()
		"airport":    _dress_airport()
		_:            _dress_exchange()
```

Add `"<newroom>": _dress_<newroom>()` cases. Every `_dress_*` follows the same five-beat order â€” deviate and the room reads wrong:

1. `IA.shell(self, wall, trim, accent)` â€” void, ceiling, back wall, cornice, dado, skirting
2. `IA.floor_tiles(self, WorldArt.TILE_*)` (+ optional `IA.floor_sheen`)
3. lighting: `IA.ceiling_light(...)` (warm rooms) or `IA.strip_light(...)` (institutional)
4. the room's own furniture â€” raw `draw_rect` / `draw_circle` / `draw_colored_polygon`, plus `IA.counter`, `IA.glass_screen`, `IA.sign`, `IA.notice`, `IA.bench_run`, `IA.plant`, `IA.flap_board`, `IA.queue_posts`, `IA.window`
5. `IA.side_walls(self, wall, trim)` then `IA.exit_door(self, 56, wood)` â€” **always last two**, they overpaint the left wall so the door reads as an opening

Canonical opener (`_dress_police`):
```gdscript
func _dress_police() -> void:
	var wall := Color(0.135, 0.145, 0.180)
	var trim := Color(0.180, 0.195, 0.240)
	var cool := Color(0.72, 0.82, 0.95)
	IA.shell(self, wall, trim, Color(0.16, 0.18, 0.23))
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.7, 0.8, 0.95))

	IA.strip_light(self, 180, 260, cool, _t)
	IA.strip_light(self, 620, 300, cool, _t)
	...
	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.22, 0.26, 0.32))
```

Room palettes are three colours (`wall`, `trim`, plus `warm` or `cool`) and they carry the room's whole character. Berlin's set, for contrast when you pick London's / Istanbul's:
`exchange` warm brown `(.180,.140,.105)` Â· `police` cold blue-grey `(.135,.145,.180)` Â· `hospital` pale green `(.150,.185,.180)` Â· `restaurant` dark wood `(.155,.105,.085)` Â· `ubahn` cream/ochre `(.165,.155,.140)` Â· `airport` slate `(.130,.140,.170)`.

### 4.4 `InteriorArt` â€” COMPLETE public API (`scenes/world/InteriorArt.gd`)

Constants: `VW 1152.0`, `VH 648.0`, `CEIL 46.0`, `WALL 305.0`, `NEAR 606.0`, `SIDE 44.0`, `EXT 4000.0`, `C_VOID Color(0.043, 0.039, 0.110)`.

Every function is `static` and takes the `CanvasItem` as first arg. Signatures verbatim:

```gdscript
static func shell(ci: CanvasItem, wall: Color, trim: Color, accent: Color) -> void
static func side_walls(ci: CanvasItem, wall: Color, trim: Color) -> void
static func floor_tiles(ci: CanvasItem, tile: int) -> void
static func floor_sheen(ci: CanvasItem, col: Color) -> void

static func window(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void
static func exit_door(ci: CanvasItem, x: float, wood: Color) -> void

static func counter(ci: CanvasItem, x: float, y: float, w: float, h: float,
		body: Color, top: Color) -> void
static func glass_screen(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void
static func sign(ci: CanvasItem, x: float, y: float, w: float, h: float,
		board: Color, ink: Color, marks: int = 5) -> void
static func notice(ci: CanvasItem, x: float, y: float, w: float, h: float,
		paper: Color, ink: Color) -> void

static func ceiling_light(ci: CanvasItem, x: float, warm: Color, t: float,
		drop: float = 34.0) -> void
static func strip_light(ci: CanvasItem, x: float, w: float, cool: Color, t: float) -> void

static func bench_run(ci: CanvasItem, x: float, y: float, seats: int,
		frame: Color, seat: Color) -> void
static func plant(ci: CanvasItem, x: float, y: float, pot: Color) -> void
static func flap_board(ci: CanvasItem, x: float, y: float, w: float, rows: int,
		t: float) -> void
static func queue_posts(ci: CanvasItem, x: float, y: float, count: int) -> void
```
(`_pool(ci, c, rx, ry, col)` is private, used by both light helpers.)

Behavioural notes that matter for layout:
* `window()` auto-tints itself from `GameState.is_morning()` â€” you pass only the frame colour.
* `exit_door()` draws an 84-px-wide door from y 120 to `WALL`; Berlin always calls it with `x = 56`, matching the `SceneExit` at world x 116.
* `sign()` draws `marks` unreadable diagonal strokes instead of text â€” **this is how all foreign signage is rendered.** Never draw real letters on a sign the alien can't read. `notice()` does the same in horizontal ragged lines.
* `counter()`'s top slab overhangs by 8 px and sits 14 px above `y`; size your `CounterCollision` polygon to the drawn box, not the slab.
* `ceiling_light`/`strip_light`/`flap_board` need the caller's accumulated `_t` for their flicker/shuffle; that's why `InteriorBackground._process` redraws every frame.

---

## 5. `ServicePoint` â€” `scenes/world/ServicePoint.gd` / `.tscn`

Exported properties (verbatim):
```gdscript
@export var service: String = ""
@export var prompt_text: String = "E â€” Use"
@export var clerk: String = ""       # optional NPC sheet name behind the counter
@export var clerk_facing: String = "down"
# Where the clerk stands relative to this point â€” default puts them behind
# a counter whose front edge the player is standing at
@export var clerk_offset: Vector2 = Vector2(0, -136)
```

The binding is one line â€” **the `service` string is the only contract with `Services`**:
```gdscript
func _use() -> void:
	_busy = true
	await Services.run(service, self)
	_busy = false
```
Guard: `if not player_nearby or _busy or get_tree().paused: return`, then `get_viewport().set_input_as_handled()` on `KEY_E`. Clerk sprite is built in `_ready()` via `WorldArt.npc_sprite(self, clerk, "idle_" + clerk_facing)`, positioned at `clerk_offset`, `z_index = -1`.

Scene: `Area2D` root + `CollisionShape2D` (`RectangleShape2D` 150Ã—120) + `Prompt: Label` at `(-56, -96)`, `font_size 12`, `visible = false`.

Existing service ids in the world (all Berlin): `exchange`, `jobboard`, `ubahn_ticket`, `ubahn_travel`, `lost_property`, `police_desk`, `hospital_desk`, `airport_desk`, `job_crates`, `job_flyers`, `job_dishes`. **Namespace new ones by city** (`london_dealer`, `istanbul_market`, â€¦) to avoid collisions.

`scenes/world/SceneExit.gd` for comparison â€” same proximity/prompt shape, different payload:
```gdscript
@export var target_scene: String = ""
@export var spawn_tag:    String = ""
@export var prompt_text:  String = "E â€” Leave"

func _go() -> void:
	if target_scene.is_empty():
		return
	GameState.spawn_tag = spawn_tag
	TransitionManager.go(target_scene)
```
`SceneExit.tscn`: `Area2D` + `RectangleShape2D` 70Ã—220 + `Prompt: Label` at `(-92, -130)`.

---

## 6. `Services.run()` â€” EXACT SHAPE OF A NEW HANDLER

`autoload/Services.gd:68`:
```gdscript
func run(service: String, _source: Node) -> void:
	match service:
		"exchange":       await _exchange()
		"jobboard":       await _jobboard()
		"ubahn_ticket":   await _ubahn_ticket()
		"ubahn_travel":   await _ubahn_travel()
		"lost_property":  await _lost_property()
		"police_desk":    await _police_desk()
		"hospital_desk":  await _hospital_desk()
		"airport_desk":   await _airport_desk()
		"job_crates", "job_flyers", "job_dishes": _job_site(service)
		_: _think("Nothing here answers to me.")
```
Rules: `run` is `-> void` and **not** `async`-annotated (GDScript has none); any handler that opens a ChoicePanel must be `await`-ed here. Handlers that only show a thought are called without `await`. Add your city's ids as new `match` arms; do not restructure the match.

Two private helpers every handler uses:
```gdscript
func _choice() -> Node:
	return get_tree().get_first_node_in_group("choice_panel")

func _think(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(text)
```

**Canonical handler â€” copy this skeleton** (`_lost_property`, the closest analogue to a fragment-recovery beat in a new city):
```gdscript
func _lost_property() -> void:
	if GameState.has_fragment("shard_lost"):
		_think("The clerk recognises me now and shakes his head,\n" +
			"almost kindly. Nothing else of mine has been lost.")
		return
	var cp := _choice()
	if cp == null:
		return
	var fee := 2
	var afford := GameState.money >= fee
	cp.open("FundbÃ¼ro",
		"a hatch, a ledger, and shelves of umbrellas going back years. He " +
		"holds up something ridged and dark and raises an eyebrow.",
		[
			{"id": "claim", "label": "Point at it. Then at yourself.",
				"sub": "he taps the ledger and rubs two fingers together â€” a fee",
				"cost": "%s%d" % [GameState.symbol(), fee], "disabled": not afford},
			{"id": "", "label": "Leave it on the shelf",
				"sub": "" if afford else "he will not take a promise instead of coins"},
		])
	var pick: String = await cp.chosen
	if pick != "claim" or not afford:
		return
	GameState.money -= fee
	GameState.money_changed.emit(GameState.money)
	GameState.recover_fragment("shard_lost")
	_think("He writes a line in the ledger, turns the book round, and\n" +
		"taps an empty box. I draw the only mark I know is mine.\n\n" +
		"The fragment is warm through the paper bag. Two now.")
```

Hard-won details:
* `var pick: String = await cp.chosen` â€” **explicitly typed**, never `:=`.
* Always re-validate affordability **after** the await; the panel pauses the tree but the handler must not trust its own pre-await snapshot (see `_exchange`, which recomputes `here_now` and `amount`).
* `GameState.money -= fee` does **not** auto-emit. You must follow every direct mutation with `GameState.money_changed.emit(GameState.money)`. (`GameState.add_money()` and `finish_job()` do emit for you.)
* The `""` id is the back-out row and must always be present, last.
* Multi-outcome handlers use `match pick:` with a case per id (`_police_desk`).
* Reputation nudges go through `GameState.change_reputation("<region>", Â±n)`.

**Odd-jobs pattern** â€” a job is accepted at a `jobboard` service and completed at a ServicePoint whose `service` equals the job's `target`:
```gdscript
const JOBS := {
	"crates": {
		"title":  "Stack the delivery crates",
		"giver":  "the bread man at the field market",
		"where":  "the stall by the wreck",
		"pay":    4,
		"target": "job_crates",
		"accept": "â€¦",
		"done":   "â€¦",
	},
	â€¦
}
```
`_job_site(service)` verifies `String(job["target"]) == service`, then `GameState.finish_job(id, pay)`. To give a new city its own work, add `JOBS` entries with new `target` ids and add those ids to the `"job_crates", "job_flyers", "job_dishes":` arm. **Note the current `JOBS` dict is city-agnostic** â€” a London notice board would offer Berlin's crates unless you filter (e.g. add a `"city"` key and skip non-matching entries in `_jobboard()`).

---

## 7. `ChoicePanel` â€” EXACT CALL SIGNATURE

`scenes/ui/ChoicePanel.gd`, its own doc comment is the contract:
```gdscript
# Generic chooser used by the U-Bahn, the airport desk, the exchange booth and
# the job board. Open it with a title and a list of rows; the `chosen` signal
# fires with the row's id, or "" if the player backs out.
#
#   var cp := get_tree().get_first_node_in_group("choice_panel")
#   cp.open("Where to?", "the line map is a coloured tangle", rows)
#   var id: String = await cp.chosen
#
# rows: [{ "id", "label", "sub" (optional), "cost" (optional String),
#          "disabled" (optional bool), "note" (optional String) }]

signal chosen(id: String)

func open(title: String, subtitle: String, rows: Array) -> void
```
Semantics: `open()` no-ops if already open; sets `get_tree().paused = true`; `Esc` (`ui_cancel`) closes with `""`. Disabled rows render at `modulate.a = 0.45` with no button â€” **a disabled row can never be picked, so the post-await guard is belt-and-braces, not the gate.** `cost` is a pre-formatted String, always built as `"%s%d" % [GameState.symbol(), amount]` so it follows the wallet across cities. The `"note"` key is documented but unread by `_populate()` â€” do not rely on it.

The panel is a `CanvasLayer` at `layer = 11`, group `"choice_panel"`, `process_mode = PROCESS_MODE_ALWAYS`.

Adjacent UI, same idiom: `ThoughtBox.show_thought(text: String)` (group `"thought_box"`, pauses, closes on E or Esc, wraps text in `[i]â€¦[/i]`, `\n` is honoured â€” Berlin's thoughts are hand-wrapped at ~62 chars).

---

## 8. `WorldArt` â€” COMPLETE API (`autoload/WorldArt.gd`, `class_name WorldArt`)

```gdscript
const ROOT := "res://art/world/"

# tiles/tileset_<mode>.png â€” single row of 16Ã—16 cells, in this order
const TILE_SIDEWALK   := 0
const TILE_SIDEWALK_B := 1
const TILE_KERB       := 2
const TILE_ASPHALT    := 3
const TILE_ASPHALT_D  := 4
const TILE_CROSSWALK  := 5
const TILE_COBBLE     := 6
const TILE_GRASS      := 7
const TILE_GRASS_B    := 8
const TILE_DIRT       := 9
const TILE_BURN       := 10
const TILE_CARPET     := 11
const TILE_WOOD       := 12
const TILE_RUNNER     := 13

# ui/icons.png â€” 16px cells
const ICON_COIN := 0 Â· ICON_BROT := 1 Â· ICON_KARTE := 2 Â· ICON_KEYCARD := 3
const ICON_JOURNAL := 4 Â· ICON_QUEST := 5 Â· ICON_QUEST_OK := 6 Â· ICON_EKEY := 7

const TILE_FALLBACK := [...]   # one solid Color per TILE_*, same order
```

```gdscript
static func mode() -> String                                   # "morning" | "dawn"
static func tex(rel: String) -> Texture2D                      # rel is under art/world/
static func mode_tex(rel_base: String) -> Texture2D            # "props/lamp" -> props/lamp_dawn.png
static func sprite(parent: Node, texture: Texture2D, pos_1x: Vector2,
		z: int = 0) -> Sprite2D
static func strip_sprite(parent: Node, texture: Texture2D, frames: int, fps: float,
		pos_1x: Vector2, z: int = 0, loops: bool = true) -> AnimatedSprite2D
static func npc_frames(npc: String) -> SpriteFrames
static func npc_sprite(parent: Node2D, npc: String,
		anim: String = "idle_down") -> AnimatedSprite2D
static func avatar(npc: String) -> Texture2D                   # head crop, 32Ã—18
static func icon(idx: int) -> Texture2D
static func pip(tier: int) -> Texture2D                        # familiarity pip 0-3
static func draw_tiles(ci: CanvasItem, tile: int, rect: Rect2) -> void
```

Behaviour you must respect:
* `tex()` returns `null` and `push_warning`s on a missing path; `sprite()`/`strip_sprite()` return `null` on a null texture. **Never assume a sprite came back.**
* `sprite()`/`strip_sprite()` take **1Ã— coordinates** and multiply by 2 internally, set `centered = false`, `scale = (2,2)`, `TEXTURE_FILTER_NEAREST`.
* `draw_tiles()` takes a **world-px** `Rect2`, paints an opaque `TILE_FALLBACK` base first (so a missing atlas never shows the clear colour), then blits 16Ã—16 source cells at 32Ã—32.
* NPC sheets are 192Ã—128, 32-px cells, rows `down/up/right/left`, cols = idleÃ—2 then walkÃ—4. `npc_frames` produces `idle_<dir>` @2 fps and `walk_<dir>` @8 fps. `npc_sprite` sets `offset = Vector2(0, -1.5)` so feet land on the node origin â€” same rig as the Player.

---

## 9. SPAWN / RETURN CONTRACT BETWEEN SCENES

The whole handshake is one `String`:

1. `SceneExit._go()` sets `GameState.spawn_tag = spawn_tag`, then `TransitionManager.go(target_scene)`.
2. `TransitionManager.go(path: String)` fades to `Color(0.05,0.04,0.10)` over `FADE_OUT := 0.30`, calls `get_tree().change_scene_to_file(path)`, then fades in over `FADE_IN := 0.35`. It is a `CanvasLayer` autoload at `layer = 128` and re-guards with `_busy`.
3. The destination street scene's `_ready()` looks the tag up in its own `const SPAWNS` and clears it. Interiors ignore it and use `@export var spawn`.
4. **`GameState.spawn_tag = ""` at the end of `_ready()` is mandatory** in every scene root, or the next scene inherits a stale tag.

The naming convention is `"from_<origin>"`, and the two halves live in different files:
* `Mitte.tscn`'s `ExchangeEntrance` sets `spawn_tag = "from_street"` (consumed by nothing â€” interiors ignore it; it is documentation).
* `Exchange.tscn`'s `Exit` sets `spawn_tag = "from_exchange"`, and `Mitte.gd`'s `SPAWNS` has `"from_exchange": Vector2(1004, 380)` â€” one y-offset of +50 below the door, so you land on the pavement facing out.

Round-trips currently defined: Mitte â†” Kiez (`from_mitte`/`from_kiez`), Mitte â†” MitteOst (`from_mitte`/`from_mitte_ost`), Mitte â†” Hotel/Exchange/UBahn, MitteOst â†” Restaurant/Police, UBahn â†” Hospital/Airport. Note `Hospital` and `Airport` exit **to the U-Bahn**, not to a street â€” a hub-and-spoke shape a new city can reuse.

`Services._ubahn_travel()` shows the alternative: fast travel without a `SceneExit`, by setting `GameState.spawn_tag = "from_ubahn"` and calling `TransitionManager.go(dest)` directly.

---

## 10. `GameState` â€” LANGUAGE AND WORD-FAMILIARITY API

### 10.1 Register an exposure event â€” the one function

```gdscript
func expose(language: String, word: String, exposure_type: String) -> void
```
`autoload/GameState.gd:244`, full body:
```gdscript
func expose(language: String, word: String, exposure_type: String) -> void:
	word = word.to_lower()
	if not familiarity.has(language):
		familiarity[language] = {}
	var current: int = familiarity[language].get(word, 0)
	var base_gain: int = EXPOSURE_GAIN.get(exposure_type, 0)
	var gain: int = roundi(float(base_gain) * _word_ease(word))
	var old_tier := get_tier(language, word)
	familiarity[language][word] = min(100, current + gain)
	var new_tier := get_tier(language, word)
	if new_tier > old_tier:
		word_tier_changed.emit(language, word, new_tier)
```

Exposure types and gains (`EXPOSURE_GAIN`, :193):
```gdscript
const EXPOSURE_GAIN = {
	"hear":    4,
	"pointed": 15,
	"used":    10,
	"read":    7,
}
```
An unknown type silently yields 0. `"used"` and `"read"` are **defined but never called anywhere in the codebase** â€” free for a new city's mechanics.

Tiers and thresholds (`get_tier`, :233):
```gdscript
const TIER_UNKNOWN  = 0
const TIER_GLIMPSED = 1     # score >= 25
const TIER_PARTIAL  = 2     # score >= 50
const TIER_KNOWN    = 3     # score >= 80
func get_familiarity(language: String, word: String) -> int
func get_tier(language: String, word: String) -> int
signal word_tier_changed(language: String, word: String, new_tier: int)
```

Difficulty curve (`_word_ease`, :258) â€” **German-specific and needs extending for a new language**:
```gdscript
func _word_ease(word: String) -> float:
	var n := word.length()
	var ease: float
	if n <= 3:
		ease = 2.5
	elif n <= 5:
		ease = 1.5
	elif n <= 7:
		ease = 1.0
	elif n <= 9:
		ease = 0.7
	else:
		ease = 0.4
	for ch: String in ["Ã¤", "Ã¶", "Ã¼", "ÃŸ"]:
		if word.contains(ch):
			ease *= 0.8
			break
	return ease
```
Turkish `Ä± ÄŸ ÅŸ Ã§ Ã¶ Ã¼ Ä°` get no penalty today. For London's **per-speaker** model, `_word_ease` is the wrong lever entirely â€” see Â§14.

### 10.2 Register a language's vocabulary â€” **there is no such function**

This is the single most important thing to know. A language is created **lazily** by the first `expose()` call (`if not familiarity.has(language): familiarity[language] = {}`). There is no registry, no vocabulary list, no validation. Two consequences:

* Any string works as a `language` key. `"english"` and `"turkish"` are already declared in `GameState.CITIES` (`"language"` field) and reachable via `GameState.local_language() -> String`, but nothing has ever written to `familiarity["english"]`.
* **The player's meaning-guesses live in one flat, un-namespaced const**, `GameState.WORD_GUESSES` (:74â€“138), keyed by bare lowercase word:
```gdscript
const WORD_GUESSES := {
	"ich":    'â€” "I"',
	"und":    'â€” "and"',
	"ihnen":  'â€” "him"? "her"?  (unclear)',
	â€¦
}
```
Entries begin with `'â€” '` (em dash + space) and use single-quoted GDScript strings so `"` can appear inline. Consumers: `DialogueBox._wrap_guess()` (makes a word hoverable only if a guess exists), `DialogueBox._on_word_hover_started()` (renders `"your guess: " + guess.trim_prefix("â€” ")`) and `Journal._spawn_toast()`. **A Turkish or English word that collides with a German key will inherit the German guess.** If a new city adds vocabulary, either keep keys collision-free or promote `WORD_GUESSES` to `{language: {word: guess}}` and update those three call sites.

### 10.3 How a line of speech is authored

The unit is an *entry*; a conversation is an `Array` of entries. Verbatim from `scenes/npc/NPC.gd`:
```gdscript
{
	"words": [
		{"text": "Guten",   "word": "guten",  "language": "german"},
		{"text": "Morgen!", "word": "morgen", "language": "german"},
		{"text": "Kann",    "word": "kann",   "language": "german"},
		{"text": "ich",     "word": "ich",    "language": "german"},
		{"text": "Ihnen",   "word": "ihnen",  "language": "german"},
		{"text": "helfen?", "word": "helfen", "language": "german"},
	],
	"responses": [
		{"text": "Bow slightly, hands clasped",     "style": "formal"},
		{"text": "Point at yourself and shrug",     "style": "gesture"},
		{"text": "Nod and hold steady eye contact", "style": "direct", "rep": 1},
	]
}
```
* `text` = what is printed (inflected, punctuated); `word` = the lowercase **lemma** the familiarity score is keyed on. `"frisches"`â†’`"frisch"`, `"gutes"`â†’`"gut"`, `"kommt"`â†’`"kommen"`. This is how repetition compounds.
* Response keys: `text`, `style` âˆˆ `formal|direct|gesture|indirect` (coloured chips, `DialogueBox.STYLE_COLORS`), optional `rep: int`, optional `action: String`, optional `requires_money: int` (row is hidden, not disabled, when unaffordable).
* `action` is dispatched by a hardcoded if-chain in `DialogueBox._on_response()` (:240): `"buy_bread"`, `"give_map"`, `"book_room"`. **A new city's dialogue actions must be added there** â€” there is no generic dispatch.

Presenting it:
```gdscript
func show_dialogue(entries: Array, npc_name: String, relationship: String,
		npc_color: Color, grant_exposure: bool = true, region: String = "") -> void
```
called as `dlg.show_dialogue(_ROUNDS[round_i], npc_name, relationship, npc_color, not _talked_this_visit, region)` where `dlg = get_tree().get_first_node_in_group("dialogue_box")`.

Anti-farming rules, both already enforced â€” replicate them:
* `grant_exposure = false` on repeat talks within one visit â‡’ no `expose()`, no `rep` change.
* Dialogue *round* advances only on `GameState.region_visits[region]`: `func _round_for_visit() -> int: return clampi(int(GameState.region_visits.get(region, 1)) - 1, 0, _ROUNDS.size() - 1)`.

Rendering (`DialogueBox._render_word`, :448) â€” the visible thesis of the game:
| tier | rendering |
|---|---|
| KNOWN (â‰¥80) | plain `[color=#f0eeff]` real text, hoverable |
| PARTIAL (â‰¥50) | real text with a `[bgcolor=#35359a]` highlight (or `[u]` if `highlight_partial_words`), hoverable |
| GLIMPSED (â‰¥25) | `[color=#b8b4f0]` **deterministic** glyphs â€” `_to_glyphs()` maps each codepoint mod alphabet length, so the same word always looks the same |
| UNKNOWN, first sight | `_random_glyphs()` reshuffled every `ANIM_INTERVAL := 0.18` s â€” unresolved static |
| UNKNOWN, seen before | deterministic glyphs |

Alphabets: `GLYPHS_FULL := "â—ˆâŸŸâ¬¡â—‰âŸ¢âŸ£â‹„âŸ¤âŸ¥â¬¢â¬£â¬Ÿâ¬ âŸ¦âŸ§âŸ¡"`, `GLYPHS_SIMPLE := "â–²â–¼â—â– â—†â˜…â–¸â—€â–´â–¾"` (accessibility setting `simplified_glyph_set`). These same two constants are duplicated at the top of `Journal.gd` â€” keep them in sync or share them.

Ambient/overheard exposure (`WalkingFriends._try_expose`, :136) â€” the pattern for street chatter:
```gdscript
func _try_expose(snip: Array) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not (player is Node2D):
		return
	if global_position.distance_to((player as Node2D).global_position) > EARSHOT:
		return
	for pair in snip:
		var wkey: String = pair[1]
		if not _exposed.has(wkey):
			_exposed[wkey] = true
			GameState.expose("german", wkey, "hear")
```
`EARSHOT := 170.0`; `_exposed` is per-instance so one walk-by teaches each word once.

### 10.4 `Journal` is hardcoded to German

`scenes/ui/Journal.gd:211` `if language != "german": return` (tier-up toasts), `:304` `var fam: Dictionary = GameState.familiarity.get("german", {})`, `:320` `GameState.get_tier("german", word)`, and the subtitle literal `"German  Â·  %d %s recognised"`. Until this reads `GameState.local_language()` (and titles from `CITIES[city]["language"].capitalize()`), **no English or Turkish word will ever appear in the journal or fire a toast.**

---

## 11. `GameState` STATE A NEW CITY MUST EXTEND

| Thing | Where | What to do |
|---|---|---|
| `CITIES` | :57 | already has `london` (GBP, `Â£`, `english`, fare 15) and `istanbul` (TRY, `â‚º`, `turkish`, fare 15). Do not edit. |
| `FRAGMENTS` | :23 | `shard_london` and `shard_istanbul` exist with `name`/`city`/`where` but **`"desc": ""`** â€” fill them in |
| `reputation` | :202 | `{"kiez": 0, "mitte": 0, "prenzlberg": 0}` only. `change_reputation()` is `if reputation.has(region)` â€” **it silently no-ops for an unknown region.** Add your city's region keys here **and** in `reset()` (:504) |
| `Inventory.ITEM_DEFS` | scenes/ui/Inventory.gd:9 | has `fragment_shard_medical/lost/evidence` but **not** `fragment_shard_london` / `fragment_shard_istanbul`. `recover_fragment()` calls `add_item("fragment_" + id)`, so those will show with no name/desc/colour |
| `SaveManager.save_game/load_game` | :92 / :128 | already persists `city`, `wallet`, `fragments`, `active_job`, `jobs_done`, `world_flags`, `quests`, `familiarity`, `reputation`, and the current `scene` path. **Any new top-level GameState var you add must be added to both** |

Money/currency API (all verbatim):
```gdscript
var money: int                      # computed property over wallet[currency()]
var wallet: Dictionary = {"EUR": 0, "GBP": 0, "TRY": 0}
const RATES := {"EUR": 1.0, "GBP": 0.85, "TRY": 35.0}
const EXCHANGE_FEE := 0.10
func currency() -> String
func symbol() -> String
func city_name() -> String
func local_language() -> String
func cash(cur: String) -> int
func convert_preview(amount: int, from: String, to: String) -> int
func exchange(amount: int, from: String, to: String) -> bool
func travel_to(dest_city: String) -> void
func add_money(amount: int) -> void
```
Fragments / jobs / quests:
```gdscript
func has_fragment(id: String) -> bool
func fragment_count() -> int
func recover_fragment(id: String) -> void      # adds item, emits, ticks pod_core step
func accept_job(id: String) -> void
func finish_job(id: String, pay: int, rep: int = 1) -> void
func visit_region(region: String) -> int
func change_reputation(region: String, delta: int) -> void
func reputation_level(region: String) -> String
func start_quest(id: String, title: String, step_texts: Array) -> void
func complete_quest_step(id: String, idx: int) -> void
func is_morning() -> bool
```
`recover_fragment` maps id â†’ quest step via `_fragment_step()` on the fixed order `["shard_medical","shard_lost","shard_evidence","shard_london","shard_istanbul"]`, so `"pod_core"` steps 3 and 4 are London's and Istanbul's. It also auto-starts the `"leave_berlin"` quest at â‰¥3 fragments.

Reputation is never shown as a number â€” only via `REP_LEVELS` strings: `practically a neighbour / a friendly face / the curious one / a stranger / that odd one / trouble`.

---

## 12. NPC PATTERNS (three, pick per need)

1. **Hand-drawn talking NPC** â€” `scenes/npc/NPC.tscn` + `NPC.gd`. `StaticBody2D` root, `CollisionShape2D` (Rect 14Ã—18), `InteractionArea: Area2D` with `CircleShape2D radius 48`, `Prompt: Label` at `(-28, -62)` text `"[E] Talk"` hidden. The script owns `npc_name`, `npc_color`, `region`, a `const _RELATIONSHIPS: Array[String]`, a `const _ROUNDS: Array` of per-visit conversation rounds, and a `_draw()` built from `PackedVector2Array` silhouettes. 290 lines for one vendor â€” expensive; prefer #2 for a new city's minor characters.
2. **Sheet-based NPC** â€” `WorldArt.npc_sprite(self, "commuter_m", "idle_down")` in `_ready()`, no `_draw()`. This is what `ServicePoint` does for clerks and is the cheapest way to populate a new city.
3. **Ambient / non-talking** â€” `WalkingFriends.gd` (patrols between `PATH_LEFT`/`PATH_RIGHT`, speech bubbles, earshot exposure), `Pigeons.gd`. Attached as a bare `Node2D` with `script = ExtResource(...)` and a `position`.

---

## 13. VOICE, STYLE AND GDSCRIPT GOTCHAS

**Section rules.** `# â”€â”€ Title ` padded with `â”€` (U+2500) to **column 79** in `Services.gd` / `GameState.gd` (column 80 in `InteriorArt.gd`). Sub-headers inside a file may carry an em dash: `# â”€â”€ Wechselstube â€” money exchange â”€â”€â”€â€¦`. Use column 79.

**Comment voice.** Lower-case, sparse, literary, explaining *intent* not mechanics. Real examples to imitate:
> `# Cool, orderly, and entirely indifferent to how long you have been standing there. Found property lives behind the desk.`
> `# You cannot claim it with words. You claim it by matching it.`
> `# The round is fixed per scene visit: it advances only when the player leaves and comes back.`
> `# Signage the alien can't read, plus the notice board that hands out work.`

**Player-facing prose.** First person, present tense, the alien's confusion made concrete. Hard-wrapped with `\n` at ~62 chars, paragraph breaks as `\n\n`, string continuation with trailing `+`. Money deltas appended as `"\n\n( +%s%d )" % [GameState.symbol(), pay]`. Parenthetical asides in lower case: `"( that city is not built yet â€” the trail waits )"`.

**Prompts.** Always `"E â€” <verb phrase>"` with an em dash, described from the alien's ignorance where appropriate: `"E â€” Enter the bed-sign building"`, `"E â€” The place with chairs outside"`, `"E â€” Down into the U-Bahn"`.

**GDScript rules â€” these have broken this project:**
```gdscript
# WRONG â€” inference from a Dictionary/Array subscript, .get(), or a bool expression
var j := JOBS[id]
var lang := w.get("language", "")
var dest := {...}.get(pick, "")
var berlin_done := true and x

# RIGHT â€” explicit type, exactly as the shipped code does it
var j: Dictionary = JOBS[id]
var lang: String = w.get("language", "")
var dest: String = {...}.get(pick, "")
var berlin_done: bool = true
var info: Dictionary = GameState.CITIES[dest]
var base: Color = TILE_FALLBACK[tile]
var pick: String = await cp.chosen
var guess: String = GameState.WORD_GUESSES.get(word, "")
```
Also: typed for-loop vars are used where the element type matters (`for cur: String in ["EUR", "GBP", "TRY"]`, `for id: String in JOBS`). Wrap values from Dictionaries in explicit casts at use sites: `String(j["title"])`, `int(j["pay"])`, `bool(steps[idx]["done"])`. **Tabs only, never spaces.**

**Verification.** Godot is not on PATH; nothing can be run. All checking is static: re-read what you wrote, confirm every `ExtResource` path exists on disk, every `service` string has a `run()` arm, every `spawn_tag` written by a `SceneExit` has a matching `SPAWNS` key in the destination `.gd`, and every function you call is defined (the MapView bug in Â§0.1 is exactly the failure mode).

---

## 14. WHAT IS SPECIFIC TO LONDON AND ISTANBUL

**Istanbul** is a straight instantiation of this template: new streets + `<City>Background.gd` composed in code, new `InteriorBackground` room cases (a market/bazaar interior), new `Services` handlers for `shard_istanbul`, `"turkish"` as the `language` key in dialogue word entries, Turkish entries in `WORD_GUESSES`, Turkish characters added to `_word_ease`, TRY currency (already wired â€” the wallet and `symbol()` follow `GameState.city`).

**London breaks the model deliberately.** The locked design is *ACCENTS AND SPEED*: the alien understands standard English, but Cockney/slang/fast speech garbles, and familiarity is **per-speaker, not per-word**. Nothing on disk supports this yet. The template's honest guidance:

* The existing store is `familiarity[language][word]`. The cleanest fit that touches nothing else is to use the **speaker id as the `language` key**: `GameState.expose("speaker:mo_the_dealer", <utterance-or-token>, "hear")`. Every existing accessor (`get_familiarity`, `get_tier`, `expose`, save/load, `word_tier_changed`) then works unmodified, and `DialogueBox` keeps rendering tiers correctly â€” because it reads `w.get("language", "")` per word, London entries just put the speaker key in that field.
* `_word_ease` is the wrong lever (it is length + umlaut based). London wants a per-entry `"speed"` / `"accent"` weight instead. Adding an optional 4th arg to `expose()` with a default keeps all Berlin call sites valid: `func expose(language: String, word: String, exposure_type: String, ease_override: float = -1.0) -> void`.
* Words the alien already knows in standard English should be authored at `TIER_KNOWN` from the start â€” i.e. seed `familiarity["english"]` at London arrival â€” while the *garbled* tokens live under the speaker key and start at 0. That gives the intended reading: a sentence half-legible, half static, depending on who is talking and how fast.
* `Journal.gd` (Â§10.4) and `WORD_GUESSES` (Â§10.2) both need the language dimension before any of this becomes visible to the player.
* The one existing English-language hook: `GameState.CITIES["london"]["language"] == "english"`, reachable as `GameState.local_language()`.

Both cities additionally need Â§0.2 (make `_airport_desk` actually travel), a return flight, and the `Airport` scene generalised â€” it currently hardcodes `region = "mitte"` and exits to `res://scenes/world/UBahnStation.tscn`.

### Findings

- **[critical] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd** — BLOCKING: `_draw_interior_map()` is called at lines 200-205 inside `_draw_map()` but the function is never defined anywhere in the 391-line file (verified by grep across the whole project â€” six call sites, zero definitions). In Godot 4 GDScript, calling an undefined method on `self` is a compile-time error, so MapView.gd fails to parse, MapView.tscn fails to load, and every scene in the game fails with it â€” street scenes instance MapView.tscn directly, interiors get it through UILayer.tscn. This is the half-finished edit from the credit-limited session.
  - Fix: Define `func _draw_interior_map(kind: String, note: String) -> void:` in MapView.gd alongside the other `_draw_*_map` helpers. It should draw the room box with `_map_rect(44, 305, 1064, 301)` filled `C_ROAD` and stroked `C_LINE`, then branch on `kind`: "counter" draws a counter bar across the upper third plus `_label(...)` with `note`; "platform" draws the platform-edge line and the same label. Finish with `_arrow(60, 430, -1.0, "out")` to match the other interior maps.
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — `_airport_desk()` (lines 356-398) charges the flight fare and shows a placeholder thought ending `"( that city is not built yet â€” the trail waits )"`, but never calls `GameState.travel_to()` and never calls `TransitionManager.go()`. `GameState.travel_to()` (GameState.gd:376) is defined but has zero callers project-wide. The player pays 15 units and stays in Berlin.
  - Fix: After the fare deduction, add `GameState.travel_to(pick)`, `GameState.spawn_tag = "from_flight"`, and `TransitionManager.go(<first scene path of the destination city>)`. `travel_to` already re-emits `money_changed`, which is what makes the HUD switch to the new currency symbol and pocket.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — Line 234 uses `var dest := {...}.get(pick, "")` â€” inferring a type from `.get()`, the exact GDScript pattern the project brief lists as having broken this codebase before. `Dictionary.get()` returns Variant, which has no set type to infer from.
  - Fix: Change to `var dest: String = { ... }.get(pick, "")`. Do not let new city handlers copy this line as a template.
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `reputation` is initialised (line 202) and reset (line 504) with only `{"kiez": 0, "mitte": 0, "prenzlberg": 0}`, and `change_reputation()` guards with `if reputation.has(region)`. Any London or Istanbul region key will make every reputation change a silent no-op, and `reputation_level()` will always return "a stranger" â€” which DialogueBox and MapView both display to the player.
  - Fix: Add the new cities' region keys to both the `reputation` var initialiser and the `reset()` function before writing any London/Istanbul dialogue or service handler that awards rep.
- **[high] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Journal.gd** — The Journal hardcodes German in three places: line 211 `if language != "german": return` (suppresses all tier-up toasts for other languages), line 304 `GameState.familiarity.get("german", {})`, line 320 `GameState.get_tier("german", word)`, plus literal subtitles "German Â· N words recognised". No English or Turkish word will ever appear in the journal or fire a discovery toast.
  - Fix: Replace the literals with `GameState.local_language()` and derive the display name from `GameState.CITIES[GameState.city]["language"].capitalize()`. Consider showing all discovered languages as sections rather than only the current one, so Berlin's German stays visible after travel.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Inventory.gd** — `ITEM_DEFS` (line 9) defines `fragment_shard_medical`, `fragment_shard_lost` and `fragment_shard_evidence` but has no entry for `fragment_shard_london` or `fragment_shard_istanbul`. `GameState.recover_fragment()` calls `add_item("fragment_" + id)` for all five, so the last two will land in the inventory with no name, no description and no colour.
  - Fix: Add `fragment_shard_london` ("Cold fragment") and `fragment_shard_istanbul` ("Bright fragment") entries with `name`/`desc`/`color`/`eatable: false`, matching the teal ramp used by the existing three. Also fill in the empty `"desc": ""` fields for those two in `GameState.FRAGMENTS` (lines 42-53).
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `WORD_GUESSES` (line 74) is a single flat dictionary keyed by bare lowercase word, with no language namespace. It is consumed by DialogueBox._wrap_guess, DialogueBox._on_word_hover_started and Journal._spawn_toast. A Turkish or English word that collides with a German key (e.g. "in", "das", "bin", "kann") will silently show the German guess to the player in the other city.
  - Fix: Either keep new-language keys provably collision-free, or restructure to `{language: {word: guess}}` and update the three call sites to pass the language through. The DialogueBox already knows the language per word (`w.get("language", "")`) but currently drops it before the guess lookup â€” `_wrap_guess(word, inner)` would need a `lang` parameter.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `_word_ease()` (line 258) applies a 0.8 difficulty multiplier only for the German characters `Ã¤ Ã¶ Ã¼ ÃŸ`. Turkish `Ä± ÄŸ ÅŸ Ã§ Ä°` and English orthographic irregularity get no adjustment, so a new city's vocabulary will be scored on German assumptions. Separately, this length-based function is the wrong mechanism entirely for London's locked per-speaker accent/speed model.
  - Fix: Extend the character list per language, and for London add an optional weight parameter with a Berlin-safe default â€” `func expose(language: String, word: String, exposure_type: String, ease_override: float = -1.0) -> void` â€” so accent/speed can drive the gain without touching any existing call site.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/dialogue/DialogueBox.gd** — `_on_response()` (line 240) dispatches dialogue actions through a hardcoded if/elif chain covering only `buy_bread`, `give_map` and `book_room`. Any `"action"` string a new city's dialogue introduces is silently ignored â€” the response row still consumes the turn and closes, so the failure is invisible.
  - Fix: Add the new actions to the chain, or convert it to a `match` with a default that calls `push_warning("unhandled dialogue action: " + action)` so a typo surfaces during static review.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/world/Airport.tscn** — The Airport is the intended departure point for both new cities but is hardcoded to Berlin: root `region = "mitte"` and its `Exit` targets `res://scenes/world/UBahnStation.tscn` with `spawn_tag = "from_airport"`. A player who flies to London and walks back into an airport would be returned to the Berlin U-Bahn.
  - Fix: Either give each city its own airport scene reusing `Interior.gd` + the `airport` room dressing with the correct `region` and exit target, or make the exit target data-driven off `GameState.city`. Note `UBahnStation.tscn` has no `from_airport` entry in a SPAWNS table either â€” `Interior.gd` ignores `spawn_tag` entirely, so that tag is currently decorative.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — The `JOBS` dictionary (line 10) is city-agnostic and `_jobboard()` lists every entry unconditionally. A notice board placed in London or Istanbul would offer "Stack the delivery crates" at "the field where I came down" in Berlin, and `_job_site()` would reject completion everywhere in the new city.
  - Fix: Add a `"city"` key to each JOBS entry and filter in `_jobboard()` with `if String(j.get("city", "berlin")) != GameState.city: continue`, then add the new city's jobs with their own `target` ids and register those ids in the `run()` match arm alongside `job_crates`/`job_flyers`/`job_dishes`.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/Mitte.tscn** — Street scenes (Mitte, MitteOst, Kiez) hand-list ten-plus UI scenes individually and omit `AngryBox.tscn`, while every interior instances the single `res://scenes/ui/UILayer.tscn` which includes it. This is drift, not design, and it means a street scene is one forgotten line away from a null-group crash â€” `Services._choice()` and `Services._think()` both return/no-op silently on a missing panel rather than erroring.
  - Fix: New city street scenes should instance `res://scenes/ui/UILayer.tscn` as a single node rather than replicating the hand-list. If a hand-list is kept for consistency with Berlin, `ChoicePanel.tscn` is mandatory on any street holding a ServicePoint.

---

## Audit agent 2 (afd5e85038c79237e)

Berlin audit complete, static only (Godot not on PATH; nothing was run, nothing was edited).

THE BLOCKER: the previous session died mid-edit inside scenes/ui/MapView.gd exactly as suspected. It added interior-map dispatch (six `match` arms calling `_draw_interior_map(...)`) but never wrote the function. The file is 391 lines and ends at `_draw_room_map`. In Godot 4 an unqualified self-call that resolves to nothing is a parse-time error ("Function '_draw_interior_map()' not found in base self"), so MapView.gd does not compile, MapView.tscn does not load, and every playable scene in the game instances MapView.tscn â€” the six street/hotel scenes directly, and the six interiors transitively through UILayer.tscn. Nothing boots past the title until that function exists. I verified programmatically that it is the ONLY undefined self-call in the entire project, which is consistent with a single truncated edit.

WHAT IS ACTUALLY CLEAN (checks 1-4, 7 all pass):
- Service ids: all 11 distinct `service` values across scenes/world/*.tscn (exchange, jobboard, ubahn_ticket, ubahn_travel, lost_property, police_desk, hospital_desk, airport_desk, job_crates, job_flyers, job_dishes) are handled by Services.run(). Zero unhandled ids.
- JOBS targets: cratesâ†’Kiez.tscn:71, flyersâ†’UBahnStation.tscn:59, dishesâ†’Restaurant.tscn:45, and the fourth job "sweep" reuses target job_flyers, which exists. All four resolve.
- All 89 `res://` paths referenced from any .gd/.tscn/.godot exist on disk. All runtime-composed WorldArt paths resolve too, and every atlas index is in range (tileset 224x16 = 14 cells vs max TILE_RUNNER=13; icons 128x16 = 8 vs max ICON_EKEY=7; pips 32x8 = 4; clerk sheets commuter_f/commuter_m are 192x128 as the rig expects).
- Zero .tscn references an undeclared ExtResource/SubResource id.
- Every member access on GameState/Services/AudioManager/TransitionManager/UIStyles/SaveManager/WorldArt resolves to a real declaration.
- All three Berlin fragments are genuinely obtainable, not just declared: shard_medical via Services._hospital_desk (Hospital.tscn, reached by U-Bahn "klinik"), shard_lost via _lost_property (UBahnStation, 2-coin fee), shard_evidence via _police_desk (Police.tscn, gated on already holding shard_medical â€” the "match the broken edges" solution). The pod_core quest that tracks them is started from WreckSite.gd:35, and WreckSite.tscn is instanced in Kiez.tscn:43, so the spine is reachable. SaveManager persists city/wallet/fragments/active_job/jobs_done/time_of_day with an old-save fallback.
- WorldArt is NOT a missing autoload â€” it is `class_name WorldArt extends Object` with static methods, so its absence from project.godot's [autoload] block is correct, not an oversight.

THE WHITE-FLOOR FIX (check 6) IS SOUND, NOT PAPERED OVER. Three things had to be true and all three are: (a) WorldArt.draw_tiles():184-187 paints an opaque per-tile-type fallback rect over the exact target rect before any atlas blit; (b) every Berlin background lays a full-bleed opaque underlay as its first draw call â€” MitteBackground.gd:63, HotelFloorBackground.gd:35, HotelRoomBackground.gd:31, HotelLobbyBackground.gd:26, and InteriorArt.shell():29, which all six _dress_* functions in InteriorBackground.gd call before floor_tiles(); (c) project.godot:44 sets the right value â€” under [rendering] that key is rendering/textures/canvas_textures/default_texture_filter, whose enum is "Nearest,Linear,Linear Mipmap,Nearest Mipmap", so 0 = Nearest and the engine default of 1 = Linear was indeed wrong. That setting is load-bearing rather than decorative: WorldArt.sprite/strip_sprite/npc_sprite set TEXTURE_FILTER_NEAREST per node, but draw_tiles blits inside a CanvasItem's _draw() and none of the background CanvasItems set their own texture_filter, so they inherit the project default. The one residual weakness is listed below as a finding.

Everything else I found is post-blocker polish: one narrative branch whose text is unreachable, a stale map that calls the police station a pharmacy, an airport that takes your money and does nothing, and a currency system where exchanging money before flying is a pure loss. Details below, most severe first.

### Findings

- **[critical] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd** — `_draw_interior_map(...)` is called from six `match` arms at MapView.gd:200-205 ("Exchange", "Police", "Hospital", "Restaurant", "UBahnStation", "Airport") but the function is never defined. The file is 391 lines and the last definition is `_draw_room_map` at line 380. Godot 4's GDScript analyzer resolves unqualified self-calls at parse time, so this is a compile error, not a lazy runtime failure: MapView.gd fails to load, therefore MapView.tscn fails to load, therefore every scene that instances it fails. That is the whole game â€” Kiez.tscn:65, Mitte.tscn:92, MitteOst.tscn:73, HotelLobby.tscn:68, HotelFloor.tscn:65, HotelRoom.tscn:71 instance it directly, and Exchange/Police/Hospital/Restaurant/UBahnStation/Airport instance it transitively via UILayer.tscn:26. I confirmed by script that this is the only undefined self-call anywhere in the project, so it is a single truncated edit and nothing else was left dangling.
  - Fix: Define `func _draw_interior_map(kind: String, caption: String) -> void:` before or after `_draw_room_map`. The call sites fix the signature: two Strings, where `kind` is "counter" for five rooms and "platform" for UBahnStation, and `caption` is a landmark list. Follow the existing sibling drawers: fill a room box with `_map_rect`/C_ROAD plus a C_LINE outline, draw a counter slab (or a platform edge band plus track hatching when kind == "platform"), then `_label(...)` the caption under it. Note `_draw_you_marker()` is already called unconditionally at line 206, so the new function must not draw the player marker itself. Use TABS.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — `_hospital_desk()` shows two thoughts back to back on the "forms" branch. Line 341-344 calls `_think("I fill three boxes with marks that mean nothing here...")`, then execution falls through to line 346 `recover_fragment("shard_medical")` and line 348 `_think("No card. No name they can spell...")`. ThoughtBox.show_thought (scenes/ui/ThoughtBox.gd:68-71) simply assigns `_text_label.text` and shows â€” there is no queue and no await â€” so the second call overwrites the first in the same frame. The "forms" flavour text is dead content the player can never read, on one of only two paths to a main-plot fragment.
  - Fix: Either await the first thought's dismissal before continuing, or merge the two strings for the forms branch. Simplest surgical fix: build a local `var lead := ""` set to the forms text on that branch, then pass `lead + main_text` to a single `_think()` call at the end. Alternatively give ThoughtBox a queue, but that is a wider change than this bug warrants.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — `_airport_desk()` deducts the fare at lines 390-394 but never calls `GameState.travel_to(pick)` and never transitions anywhere â€” it just prints "( that city is not built yet â€” the trail waits )". The player permanently loses 15 EUR for nothing, repeatably, since no flag is set to prevent buying again. This compounds with a currency trap: `GameState.money` (GameState.gd:145-150) reads only `wallet[currency()]`, and `currency()` derives from `GameState.city`, which `_airport_desk` never changes. So any EUR the player converts to GBP/TRY at the Wechselstube becomes completely unreachable â€” it is not spendable, and it does not count toward the flight fare check at line 391. Following the game's own "Change money for where you are going" quest step (GameState.gd:403) actively makes the flight unaffordable.
  - Fix: Two parts. (1) Gate the purchase so it cannot be repeated and is not a pure sink â€” set a world_flag such as `GameState.world_flags["ticket_" + pick] = true` and check it in the `disabled` computation at line 375, or do not charge at all until the destination scene exists. (2) When London/Istanbul are built, call `GameState.travel_to(pick)` before the transition so the wallet pocket switches. Until then, consider reordering the leave_berlin quest steps in GameState.gd:402-405 so 'change money' comes after arrival, since as written it instructs the player into a dead end.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd** — `_draw_ost_map()` is stale relative to the MitteOst world it claims to describe. At lines 321-326 it draws a green cross at map-world x 596-746 labelled "green cross place" (a pharmacy), but the world at that exact span is the Polizeiwache: MitteBackground.gd:103-120 paints the green-and-white police band at x 504-696 with the shield and blue lamp centred on x=600, and MitteOst.tscn:44-45 puts PoliceEntrance at x=600. The map therefore tells the player the police station is a chemist â€” actively misleading for shard_evidence, a main-plot fragment. The same function also omits the notice board entirely: MitteBackground.gd:123-133 draws it at x 232-408 and MitteOst.tscn:50-52 puts the `jobboard` ServicePoint at x=300, but no map landmark marks it, even though it is the game's only money source. `_draw_mitte_map()` has a milder version of the same drift: the U-Bahn mark is at x=553 (line 295) while UBahnEntrance is at x=496 (Mitte.tscn:69), and ExchangeEntrance at x=1004 (Mitte.tscn:63) falls past the last labelled block "little shop" at 886-996 (line 287), so the money-changer is unlabelled.
  - Fix: In `_draw_ost_map`, relabel the x~600 landmark to the police station (green cross swap for a shield/lamp glyph, label something like "green-and-white building" to match MapView._open's existing Police title) and add a notice-board landmark around x 232-408 labelled for work. In `_draw_mitte_map`, move the U mark to x=496 and extend/relabel the 886 block so the exchange reads as the money place. Keep the alien's first-person guessing voice used by the surrounding labels.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/WorldArt.gd** — `draw_tiles()` re-resolves the tileset on every single call: line 188 `tex("tiles/tileset_" + mode() + ".png")` runs `ResourceLoader.exists(path)` (a filesystem/UID lookup) plus `load()` each time. This is called from inside `_draw()`, and several backgrounds redraw unconditionally every frame â€” InteriorBackground.gd:14-16 calls `queue_redraw()` in `_process` with no guard, as do HotelFloorBackground and HotelRoomBackground, and MitteBackground.gd:28-31 does for the "ost" district. MitteBackground's ost path alone calls draw_tiles 5 times per frame (lines 92-96), so that is 5 `ResourceLoader.exists()` + `load()` round trips per frame, every frame, plus a full-screen procedural repaint of the entire room. `load()` hits the resource cache, but `exists()` does not.
  - Fix: Cache the tileset in a `static var _tileset_cache: Dictionary = {}` in WorldArt keyed by mode, populated on first use and read thereafter. Separately, gate the unconditional `queue_redraw()` in InteriorBackground/HotelFloorBackground/HotelRoomBackground so they only redraw when something animated actually changed (they currently redraw purely to advance `_t` for lamp flicker); a lower-rate timer or a dirty flag would cut a full-screen repaint per frame.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/WorldArt.gd** — Residual fragility in the otherwise-sound white-floor fix. Line 191 builds the source region as `Rect2(tile * 16, 0, 16, 16)` â€” the exact atlas cell with no half-texel inset. With the global Nearest filter now set (project.godot:44) this samples cleanly, but it means floor correctness depends entirely on that one project setting staying at 0. Any CanvasItem in a background's ancestry that sets `texture_filter` to Linear, or a future change of the project default, silently reintroduces bleed from the neighbouring tile at every 32px seam â€” and TILE_CARPET(11)/TILE_WOOD(12)/TILE_RUNNER(13) sit adjacent in the atlas, so hotel floors would bleed into each other. None of the background CanvasItems (MitteBackground, InteriorBackground, HotelFloorBackground, HotelRoomBackground) set their own texture_filter, so they are all inheriting.
  - Fix: Belt and braces: either inset the source rect by a half texel (`Rect2(tile * 16 + 0.5, 0.5, 15, 15)`) so the draw is filter-independent, or set `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` explicitly on the background nodes in their `_ready()` so the invariant is local to the code that depends on it rather than global. Do not remove project.godot:44 either way.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/Mitte.gd** — Two spawn_tags are produced by SceneExits but absent from the receiving SPAWNS dicts, so those transitions silently fall through to the .tscn's default Player position. Kiez.tscn:52 sends `spawn_tag = "from_kiez"` to Mitte, but Mitte.gd:4-10 SPAWNS has no "from_kiez" key. Mitte.tscn:53 sends `spawn_tag = "from_mitte"` to MitteOst, but MitteOst.gd:3-6 SPAWNS has only "from_restaurant" and "from_police". Both currently land correctly only by coincidence â€” Mitte.tscn:35 and MitteOst.tscn:32 both default the Player to Vector2(110, 440), which happens to be the correct west edge in each case. Separately, Mitte.tscn:47 and Mitte.tscn:53 both emit the same tag "from_mitte" for two different destinations (Kiez and MitteOst), which is what makes this fragile: any future edit to either default position or a third consumer of "from_mitte" breaks it with no error.
  - Fix: Add the explicit keys â€” `"from_kiez": Vector2(110, 440)` to Mitte.gd SPAWNS and `"from_mitte": Vector2(110, 440)` to MitteOst.gd SPAWNS â€” and give Mitte.tscn's two exits distinct tags (e.g. ExitToKiez keeps "from_mitte", ExitToOst becomes "from_mitte_west") so one tag never means two places. This matters more once London/Istanbul add scenes that reuse the same tag vocabulary.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/SceneExit.gd** — `SceneExit._unhandled_input` (lines 16-19) neither calls `get_viewport().set_input_as_handled()` nor checks `get_tree().paused`, unlike ServicePoint.gd:32-37 which does both. CoinPouch.gd:23-26 and WreckSite.gd:11-14 have the same omission. Every one of these is an Area2D listening for KEY_E, and their trigger shapes are generous (SceneExit 70x220, ServicePoint 150x120, WreckSite radius 80). Where two overlap â€” for example in MitteOst, JobBoard at x=300 (MitteOst.tscn:50-51) versus ExitToMitte at x=28 with a 70-wide shape, or in Kiez where the wreck, the pouch and the stall cluster â€” a single E press can fire both handlers, e.g. running a service and immediately changing scene.
  - Fix: Mirror ServicePoint's guards in SceneExit, CoinPouch and WreckSite: early-return on `get_tree().paused`, and call `get_viewport().set_input_as_handled()` before acting. Cheap, and it makes overlap harmless rather than positional luck.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/HotelLobbyBackground.gd** — The hotel lobby never advances to morning. Line 15 hardcodes `WorldArt.tex("scenes/lobby_dawn.png")` instead of using `WorldArt.mode_tex("scenes/lobby")` like every other plate, and there is in fact no `art/world/scenes/lobby_morning.png` on disk â€” the dawn/morning pair exists for mitte and wreck but not lobby. BedRest.gd:75 sets `GameState.time_of_day = "morning"`, so after the player sleeps every other Berlin surface flips (WorldArt.mode() drives facades, props, tilesets and InteriorArt.window) while the lobby alone stays night-lit. The props layered over it on lines 17-22 do switch, via mode_tex("props/front_doors"), so the composite will read as inconsistent rather than merely unchanged.
  - Fix: Author art/world/scenes/lobby_morning.png at 576x324 to match lobby_dawn.png, then change line 15 to `WorldArt.mode_tex("scenes/lobby")`. If the art is not coming soon, at least tint the dawn plate toward daylight when GameState.is_morning() so the doors and the room agree.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/Room01.tscn** — Dead weight worth knowing about before the London/Istanbul build starts. Room01.tscn is orphaned â€” no `target_scene`, no `TransitionManager.go` call, and no ExtResource anywhere references it; it also predates the current UI convention, instancing only DialogueBox and EscapeMenu rather than UILayer.tscn. Separately, art/world/npcs/pigeon_sheet.png (128x16) is never loaded: Pigeons.gd draws its birds procedurally with draw_rect, and that sheet's geometry would not fit WorldArt.npc_frames() anyway, which assumes a 192x128 four-row 32px rig. A further set of shipped facades and props is unreferenced (altbau, apotheke, baeckerei, hotel, spaeti, plus crate/crates/debris/glow_pool/hsign/key_rack/lamp/low_table/plant/pretzel_sign/shelter/signpost/sofa/stall/tarp_stall/ubahn_entry/usign/wall_art/apo_cross/bed_sign) â€” several of these are exactly the pieces MitteBackground._build_ost would need to make the Ost street match what MapView describes. Cosmetic note in the same area: the six interior .tscn files declare `load_steps=12` while carrying 7 ext + 1 sub = 8 resources (e.g. Police.tscn:1); Godot uses load_steps only for the loading progress bar so this is harmless, but it is a sign the files were hand-templated.
  - Fix: Leave Room01.tscn alone for now if it is a reference sketch, but do not let it drift into the London/Istanbul copy-paste source â€” clone from Police.tscn or UBahnStation.tscn instead, since those carry the correct UILayer wiring. The unused facade/prop set is an asset for the Ost street rather than cruft: wiring apotheke/spaeti/baeckerei into MitteBackground._build_ost would let the world match the map instead of changing the map to match the world.

---

## Audit agent 3 (a259ac625d2a08837)

# FOREIGN TO ALL â€” THE CITY TEMPLATE
## The contract for building London and Istanbul without re-reading Berlin

Project root: `C:/Users/gulci/Downloads/foreigntoall`
Engine: Godot 4.7, GL Compatibility, `gd_scene format=3`.
Godot is not installed. Nothing can be run. All verification is static â€” never claim a scene was tested.
Not under git. Be surgical. Never mass-rewrite an existing file.

---

## 0. GROUND RULES (violating any of these has already broken this project once)

**Indentation.** Every `.gd` file is TAB-indented. Never emit a leading space in GDScript.

**Type inference traps.** `:=` cannot infer a type from a Dictionary/Array subscript, from `.get()`, or from a multi-part boolean expression. Write the type out:
```gdscript
var j: Dictionary = JOBS[id]                 # NOT  var j := JOBS[id]
var guess: String = GameState.WORD_GUESSES.get(word, "")
var berlin_done: bool = true
var lang: String = w.get("language", "")
```
`:=` is fine on literals, on typed function returns (`var cp := _choice()`), and on arithmetic of known floats.

**Voice.** Sparse, literary, lower-case section comments under box-drawing rules, exactly 78 columns wide:
```gdscript
# â”€â”€ Wechselstube â€” money exchange â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# A booth barely wider than a corridor. Everything of value is behind glass.
```
Player-facing prose is first-person alien interiority â€” observation before conclusion, never naming what the alien cannot name ("the building with the cross", "the moving room", "round metal discs, stamped with faces").

**Art.** There are NO art plates for London or Istanbul, and none will be made. `art/world/scenes/` holds only `mitte_*`, `lobby_dawn`, `wreck_*`, `title`, `intro_*`. `art/world/facades/` and `props/` are Berlin-specific. New cities must be **drawn in GDScript** â€” follow `MitteBackground._build_ost()/_draw()` for streets and `InteriorBackground.gd` + `InteriorArt.gd` for interiors. The only reusable atlases are `tiles/tileset_{dawn,morning}.png` (via `WorldArt.draw_tiles`) and `npcs/{commuter_f,commuter_m,lukas,renate,weber,pigeon}_sheet.png`.

---

## 1. STAGE GEOMETRY (identical in every scene, indoors and out)

```
world px, one screen, no scrolling level design:
  stage rect            0,0 â†’ 1152,648        (VW 1152.0, VH 648.0)
  outdoor horizon/wall  y = 292 (sky above), walkable band y 292..648
  outdoor street bands  sidewalk 292..372 Â· asphalt 372..516 Â· sidewalk 516..648
  interior ceiling      0..46      (CEIL 46.0)
  interior back wall    46..305    (WALL 305.0)
  interior floor        305..606   (NEAR 606.0)
  interior near wall    606..648
  interior side walls   x 0..44 and 1108..1152   (SIDE 44.0)
  void inflation        EXT 4000.0 Â· C_VOID Color(0.043, 0.039, 0.110)
```
The Player carries a bare `Camera2D` with no limits and no zoom, so the camera sees past the 1152Ã—648 stage. **Every background script MUST paint the void first** or the window clear colour shows through:
```gdscript
draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)
```
(`WreckageBackground.gd` does the same thing with a `Polygon2D` at `z_index = -20` when the background is sprite-based rather than `_draw`-based.)

Player collision box is 14Ã—18; feet sit on the node origin. Stand the player at yâ‰ˆ430 indoors, yâ‰ˆ440 on the street.

---

## 2. FILE MANIFEST FOR ONE CITY

Berlin's shape, transposed. Nothing here is optional except where marked.

```
scenes/world/<Street>.tscn          + <Street>.gd            one per outdoor screen
scenes/world/<City>Background.gd                             ONE bg script, @export var district
scenes/world/<Interior>.tscn                                 one per building; script = Interior.gd (shared)
scenes/world/InteriorBackground<City>.gd                     ONE bg script, @export var room
                                                             (see Â§8 for why a new file, not an edit)
```
Shared files you must EDIT (see Â§24 for the full list): `autoload/Services.gd`, `autoload/GameState.gd`, `scenes/ui/MapView.gd`, `scenes/ui/Journal.gd`, `scenes/ui/Inventory.gd`.

Berlin for reference: 4 street scenes (`Kiez`, `Mitte`, `MitteOst`, plus the wreck field), 6 interiors on the shared `Interior.gd`/`InteriorBackground.gd` pair (`Exchange`, `Police`, `Hospital`, `Restaurant`, `UBahnStation`, `Airport`), and 3 bespoke hotel scenes with their own scripts.

---

## 3. STREET SCENE â€” the exact `.tscn`

Hand-authored `.tscn` in this project deliberately **omit `uid=`, omit `unique_id=`, and align the `ext_resource` columns.** (`Room01.tscn` is a dead editor-written scene with `uid`/`unique_id` â€” do not imitate it.) `load_steps` may be omitted entirely (`Mitte.tscn`, `Kiez.tscn`) or over-declared (`Exchange.tscn` says 12 with 8 resources â€” harmless, it is only a loading hint). **Omitting it is safest.**

`scenes/world/Mitte.tscn`, verbatim and complete:

```
[gd_scene format=3]

[ext_resource type="Script"      path="res://scenes/world/Mitte.gd"            id="1_mitte"]
[ext_resource type="Script"      path="res://scenes/world/MitteBackground.gd"  id="2_bg"]
[ext_resource type="Script"      path="res://scenes/world/WorldBorder.gd"      id="3_border"]
[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn"        id="4_player"]
[ext_resource type="PackedScene" path="res://scenes/world/SceneExit.tscn"      id="5_exit"]
[ext_resource type="PackedScene" path="res://scenes/dialogue/DialogueBox.tscn" id="6_dlg"]
[ext_resource type="PackedScene" path="res://scenes/ui/EscapeMenu.tscn"        id="7_esc"]
[ext_resource type="PackedScene" path="res://scenes/ui/Journal.tscn"           id="8_jrn"]
[ext_resource type="PackedScene" path="res://scenes/ui/Inventory.tscn"         id="9_inv"]
[ext_resource type="PackedScene" path="res://scenes/ui/ThoughtBox.tscn"        id="10_tb"]
[ext_resource type="PackedScene" path="res://scenes/ui/HudBar.tscn"            id="11_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/QuestLog.tscn"          id="12_ql"]
[ext_resource type="Script"      path="res://scenes/npc/WalkingFriends.gd"     id="13_wf"]
[ext_resource type="PackedScene" path="res://scenes/npc/BusStopNPC.tscn"       id="14_bus"]
[ext_resource type="PackedScene" path="res://scenes/ui/MapView.tscn"           id="15_map"]

[ext_resource type="PackedScene" path="res://scenes/ui/ChoicePanel.tscn"       id="16_cp"]

[sub_resource type="RectangleShape2D" id="Shape_hoteldoor"]
size = Vector2(96, 62)

[node name="Mitte" type="Node2D"]
script = ExtResource("1_mitte")

[node name="MitteBackground" type="Node2D" parent="."]
z_index = -2
script = ExtResource("2_bg")

[node name="WorldBorder" type="StaticBody2D" parent="."]
script = ExtResource("3_border")

[node name="Player" parent="." instance=ExtResource("4_player")]
position = Vector2(110, 440)

[node name="WalkingFriends" type="Node2D" parent="."]
position = Vector2(320, 346)
script = ExtResource("13_wf")

[node name="BusStopNPC" parent="." instance=ExtResource("14_bus")]
position = Vector2(712, 322)

[node name="ExitToKiez" parent="." instance=ExtResource("5_exit")]
position = Vector2(28, 440)
target_scene = "res://scenes/world/Kiez.tscn"
spawn_tag = "from_mitte"
prompt_text = "E â€” Back to the field"

[node name="ExitToOst" parent="." instance=ExtResource("5_exit")]
position = Vector2(1124, 440)
target_scene = "res://scenes/world/MitteOst.tscn"
spawn_tag = "from_mitte"
prompt_text = "E â€” Deeper into the city"

[node name="HotelEntrance" parent="." instance=ExtResource("5_exit")]
position = Vector2(134, 330)
target_scene = "res://scenes/world/HotelLobby.tscn"
spawn_tag = "from_street"
prompt_text = "E â€” Enter the bed-sign building"

[node name="ExchangeEntrance" parent="." instance=ExtResource("5_exit")]
position = Vector2(1004, 330)
target_scene = "res://scenes/world/Exchange.tscn"
spawn_tag = "from_street"
prompt_text = "E â€” Wechselstube (money)"

[node name="UBahnEntrance" parent="." instance=ExtResource("5_exit")]
position = Vector2(496, 336)
target_scene = "res://scenes/world/UBahnStation.tscn"
spawn_tag = "from_street"
prompt_text = "E â€” Down into the U-Bahn"

[node name="ChoicePanel" parent="." instance=ExtResource("16_cp")]

[node name="CollisionShape2D" parent="HotelEntrance" index="0"]
shape = SubResource("Shape_hoteldoor")

[node name="Prompt" parent="HotelEntrance" index="1"]
position = Vector2(-76, -70)

[node name="DialogueBox" parent="." instance=ExtResource("6_dlg")]

[node name="EscapeMenu" parent="." instance=ExtResource("7_esc")]

[node name="Journal" parent="." instance=ExtResource("8_jrn")]

[node name="Inventory" parent="." instance=ExtResource("9_inv")]

[node name="QuestLog" parent="." instance=ExtResource("12_ql")]

[node name="MapView" parent="." instance=ExtResource("15_map")]

[node name="ThoughtBox" parent="." instance=ExtResource("10_tb")]

[node name="HudBar" parent="." instance=ExtResource("11_hud")]
```

### Rules read off that file

* **Root** is `Node2D`, named exactly as the scene file, script = the street script.
* **Background** is a plain `Node2D` child with `z_index = -2` and the background script. Any `@export` on that script is set here as a bare `key = value` line (`district = "ost"` in `MitteOst.tscn`).
* **WorldBorder** is a `StaticBody2D` with `WorldBorder.gd`. Outdoor scenes take the defaults (`wall_top 305.0, wall_bottom 648.0, wall_left 0.0, wall_right 1152.0`) and set nothing.
* **Player** is instanced, never typed inline. Its `position` here is the *default* spawn; the script overrides it per `spawn_tag`.
* **SceneExit / ServicePoint** instances carry their exports as plain lines: `target_scene`, `spawn_tag`, `prompt_text`, `service`, `clerk`, `clerk_offset`.
* **Overriding a node INSIDE an instanced scene** uses the `index=` form and must appear *after* the instancing node. `index` counts the instanced scene's own children in declaration order â€” for `SceneExit.tscn` that is `0 = CollisionShape2D`, `1 = Prompt`:
  ```
  [node name="CollisionShape2D" parent="HotelEntrance" index="0"]
  shape = SubResource("Shape_hoteldoor")

  [node name="Prompt" parent="HotelEntrance" index="1"]
  position = Vector2(-76, -70)
  ```
* **Solid world geometry** (counters, the pod, a desk) is a bare `StaticBody2D` + `CollisionPolygon2D` child in *absolute world coordinates*:
  ```
  [node name="CounterCollision" type="StaticBody2D" parent="."]

  [node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="CounterCollision"]
  polygon = PackedVector2Array(462, 218, 958, 218, 958, 312, 462, 312)
  ```
* **UI tail.** Outdoor scenes list the UI scenes individually, in this order at the end: DialogueBox, EscapeMenu, Journal, Inventory, QuestLog, MapView, ThoughtBox, HudBar â€” plus ChoicePanel wherever it lands. (Interiors use `UILayer.tscn` instead; see Â§6.) An outdoor scene may equally use `UILayer.tscn` â€” it bundles all ten including `AngryBox` â€” and doing so is shorter and less error-prone. Prefer `UILayer.tscn` for new cities.

---

## 4. STREET SCENE SCRIPT

`scenes/world/Mitte.gd`, complete:

```gdscript
extends Node2D

# Where the player appears depends on which door they came through.
const SPAWNS := {
	"from_mitte_ost": Vector2(1040, 440),
	"from_hotel":     Vector2(150, 350),
	"from_exchange":  Vector2(1004, 380),
	"from_ubahn":     Vector2(496, 386),
	"from_ubahn_stairs": Vector2(496, 386),
}


func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "mitte"
	else:
		GameState.visit_region("mitte")
	if SPAWNS.has(GameState.spawn_tag):
		$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
```

`MitteOst.gd` is the identical shape with `SPAWNS = {"from_restaurant": Vector2(856, 380), "from_police": Vector2(600, 380)}` â€” note **both scenes count as region `"mitte"`**: a region is a *reputation neighbourhood*, not a scene.

### The return-spawn protocol, stated exactly

1. `SceneExit._go()` writes `GameState.spawn_tag = spawn_tag`, then `TransitionManager.go(target_scene)`.
2. The destination's `_ready()` looks the tag up in its own `SPAWNS` and moves `$Player`.
3. The destination **clears** `GameState.spawn_tag = ""` unconditionally, even on a miss.
4. Interiors ignore the tag entirely â€” `Interior.gd` always uses its `spawn` export (one door per interior).
5. Naming convention: the tag names *where you came from*, from the destination's point of view. Mitte's exit east sets `"from_mitte"`, which MitteOst does not list (so the player lands on MitteOst's default `Vector2(110, 440)`); MitteOst's exit west sets `"from_mitte_ost"`, which Mitte maps to `Vector2(1040, 440)`. A tag with no entry is not an error â€” it falls back to the `.tscn` position.

`skip_next_visit_count` is set true by `SaveManager.load_game()`. It exists so loading a save does not advance NPC dialogue rounds (rounds are keyed on `GameState.region_visits`). **Every scene root `_ready()` must honour it** with the exact three-line branch above.

---

## 5. STREET BACKGROUND SCRIPT

`MitteBackground.gd` is one script serving two districts via `@export var district: String = "west"`. `"west"` blits a shipped plate; `"ost"` is **composed in code** â€” that branch is the model for a new city.

```gdscript
extends Node2D

@export var district: String = "west"

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# Far skyline for the composed Ost district: [x, height]
const _FAR := [
	[0, 120], [70, 158], [150, 132], [230, 170], [310, 128],
	...
]
const _FAR_W := [64, 74, 70, 78, 66, 72, 68, 76, 64, 74, 70, 78, 68, 72, 70]

var _t: float = 0.0


func _process(delta: float) -> void:
	if district == "ost":
		_t += delta
		queue_redraw()


func _ready() -> void:
	if district == "west":
		WorldArt.sprite(self, WorldArt.tex("scenes/mitte_%s.png" % WorldArt.mode()),
			Vector2.ZERO, 1)
	else:
		_build_ost()


func _draw() -> void:
	# The node's own drawing sits behind its positive-z children
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)
	if district != "ost":
		return

	var morning := GameState.is_morning()

	# Sky bands
	if morning:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.42, 0.58, 0.74))
		draw_rect(Rect2(0, 190, VW, 102), Color(0.52, 0.64, 0.77))
	else:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.045, 0.040, 0.105))
		draw_rect(Rect2(0, 45, VW, 180), Color(0.072, 0.058, 0.148))
		draw_rect(Rect2(0, 180, VW, 70), Color(0.160, 0.090, 0.182))
		draw_rect(Rect2(0, 250, VW, 42), Color(0.300, 0.160, 0.135))

	# Far skyline
	var bldg_c := Color(0.30, 0.34, 0.44) if morning else Color(0.046, 0.042, 0.088)
	var rim_c  := Color(0.86, 0.80, 0.62, 0.55) if morning else Color(0.095, 0.082, 0.165, 0.35)
	for i in range(_FAR.size()):
		var bx: float = float(_FAR[i][0])
		var bh: float = float(_FAR[i][1])
		var bw: float = float(_FAR_W[i % _FAR_W.size()])
		draw_rect(Rect2(bx, 292 - bh, bw, bh + 4), bldg_c)
		draw_rect(Rect2(bx, 292 - bh, bw, 2), rim_c)

	_draw_ost_signage()

	# Street bands from the tileset (world px; 1Ã— bands Ã—2)
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 292, VW, 80))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT,  Rect2(0, 372, VW, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT_D, Rect2(0, 436, VW, 32))
	WorldArt.draw_tiles(self, WorldArt.TILE_CROSSWALK, Rect2(64, 372, 128, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 516, VW, 132))
```

Note `float(_FAR[i][0])` â€” an explicit cast off a nested subscript, exactly as the type-inference rule requires. Note also the ordering: the node's `_draw()` renders *behind* its positive-`z_index` sprite children, so `_build_ost()` sprites (z 2, z 3) sit on top of the `_draw()` skyline and tiles.

Animated signage is drawn in a helper (`_draw_ost_signage()`) using the `_t` accumulator: a pulsing police lamp is `var pulse := 0.6 + 0.4 * sin(_t * 1.6)`.

**Time of day.** `GameState.is_morning()` returns `time_of_day == "morning"`, flipped once, permanently, by sleeping in the hotel (`BedRest.gd`). Two palettes per outdoor scene is the standard: cold pre-dawn and pale morning.

---

## 6. INTERIOR SCENE â€” the exact `.tscn`

`scenes/world/Exchange.tscn`, verbatim and complete. Every Berlin interior is this file with three lines changed (`room`, the counter polygon, the ServicePoint block).

```
[gd_scene load_steps=12 format=3]

[ext_resource type="Script"      path="res://scenes/world/Interior.gd"            id="1_int"]
[ext_resource type="Script"      path="res://scenes/world/InteriorBackground.gd"  id="2_bg"]
[ext_resource type="Script"      path="res://scenes/world/WorldBorder.gd"         id="3_border"]
[ext_resource type="PackedScene" path="res://scenes/player/Player.tscn"           id="4_player"]
[ext_resource type="PackedScene" path="res://scenes/world/ServicePoint.tscn"      id="5_sp"]
[ext_resource type="PackedScene" path="res://scenes/world/SceneExit.tscn"         id="6_exit"]
[ext_resource type="PackedScene" path="res://scenes/ui/UILayer.tscn"              id="7_ui"]

[sub_resource type="RectangleShape2D" id="Shape_exit"]
size = Vector2(70, 200)


[node name="Exchange" type="Node2D"]
script = ExtResource("1_int")
region = "mitte"
spawn = Vector2(210, 430)

[node name="Background" type="Node2D" parent="."]
z_index = -2
script = ExtResource("2_bg")
room = "exchange"

[node name="WorldBorder" type="StaticBody2D" parent="."]
script = ExtResource("3_border")
wall_top = 305.0
wall_bottom = 606.0
wall_left = 44.0
wall_right = 1108.0


[node name="CounterCollision" type="StaticBody2D" parent="."]

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="CounterCollision"]
polygon = PackedVector2Array(462, 218, 958, 218, 958, 312, 462, 312)


[node name="Player" parent="." instance=ExtResource("4_player")]
position = Vector2(210, 430)


[node name="Counter" parent="." instance=ExtResource("5_sp")]
position = Vector2(710, 366)
service = "exchange"
prompt_text = "E â€” Change money"
clerk = "commuter_f"


[node name="Exit" parent="." instance=ExtResource("6_exit")]
position = Vector2(116, 430)
target_scene = "res://scenes/world/Mitte.tscn"
spawn_tag = "from_exchange"
prompt_text = "E â€” Back to the street"

[node name="CollisionShape2D" parent="Exit" index="0"]
shape = SubResource("Shape_exit")

[node name="UILayer" parent="." instance=ExtResource("7_ui")]
```

Fixed interior values, do not deviate: `WorldBorder` 305/606/44/1108 (the U-Bahn platform uses `wall_top = 336.0` because the platform edge is a hazard line), player spawn `Vector2(210, 430)`, exit at `Vector2(116, 430)` with the narrower `Shape_exit` of `Vector2(70, 200)`, counter ServicePoint at yâ‰ˆ366 with the counter collision polygon spanning roughly y 218..312 so the player physically cannot walk behind the counter.

**`UILayer.tscn` bundles**, in order: DialogueBox, EscapeMenu, Journal, Inventory, QuestLog, MapView, ThoughtBox, AngryBox, ChoicePanel, HudBar. One line gets you every overlay.

---

## 7. `Interior.gd` â€” shared root script, complete

```gdscript
extends Node2D

# Shared root for every building interior: sets the region for reputation,
# picks the ambience, and puts the player just inside the door.

@export var region: String = "mitte"
@export var spawn: Vector2 = Vector2(210, 430)


func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.set_ambience("interior")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = region
	else:
		GameState.visit_region(region)
	$Player.position = spawn
	GameState.spawn_tag = ""
```

Reuse this file unchanged for new cities' interiors â€” set `region` in the `.tscn`. Only build a bespoke root script if the interior needs extra `_ready` logic (as the hotel does).

---

## 8. INTERIOR BACKGROUND + `InteriorArt` â€” the full drawing API

`InteriorBackground.gd` is one 393-line script, one `_dress_*` function per room, dispatched by an export:

```gdscript
extends Node2D

# One script, six rooms. `room` picks the dressing; the shell, floor and
# lighting come from InteriorArt so every interior in the game shares its
# architecture and only differs where it should.

@export var room: String = "exchange"

const IA := preload("res://scenes/world/InteriorArt.gd")

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	match room:
		"exchange":   _dress_exchange()
		"police":     _dress_police()
		"hospital":   _dress_hospital()
		"restaurant": _dress_restaurant()
		"ubahn":      _dress_ubahn()
		"airport":    _dress_airport()
		_:            _dress_exchange()
```

**Do not extend this file for a new city.** The project's own rule caps files at 800 lines; Berlin's six rooms already cost 393. Create `scenes/world/InteriorBackgroundLondon.gd` / `InteriorBackgroundIstanbul.gd` with the identical shape (same `@export var room`, same `const IA := preload(...)`, same `_process`/`_draw`), and point the interior `.tscn`'s `Background` node at the new script. Nothing in the codebase resolves this script by `class_name` â€” it is attached purely by path â€” so a parallel file is a drop-in.

**The canonical room-dressing sequence** (from `_dress_exchange`, and every other room follows it):
```gdscript
func _dress_exchange() -> void:
	var wall  := Color(0.180, 0.140, 0.105)
	var trim  := Color(0.240, 0.180, 0.115)
	var warm  := Color(0.95, 0.78, 0.42)
	IA.shell(self, wall, trim, Color(0.22, 0.17, 0.12))     # 1. architecture
	IA.floor_tiles(self, WorldArt.TILE_WOOD)                #    (+ IA.floor_sheen for clinics)

	IA.ceiling_light(self, 380.0, warm, _t)                 # 2. lighting
	IA.ceiling_light(self, 760.0, warm, _t)

	# 3. bespoke wall furniture, drawn with raw draw_rect/draw_circle/
	#    draw_colored_polygon on `self` â€” the rate board, the crest, the
	#    chalkboard menu, the notice board
	IA.window(self, 120, 96, 200, 128, Color(0.30, 0.22, 0.14))

	IA.counter(self, 470, 236, 480, 70,                     # 4. the counter
		Color(0.30, 0.20, 0.12), Color(0.42, 0.30, 0.16))
	IA.glass_screen(self, 470, 120, 480, 116, Color(0.34, 0.28, 0.18))

	IA.notice(self, 210, 250, 76, 46, Color(0.86, 0.82, 0.70), Color(0.25, 0.2, 0.15))
	IA.plant(self, 1046, 268, Color(0.42, 0.26, 0.16))
	IA.side_walls(self, wall, trim)                          # 5. side walls LAST
	IA.exit_door(self, 56, Color(0.26, 0.18, 0.11))          # 6. door on top of them
```
`side_walls` then `exit_door` must be the last two calls â€” they overpaint the room edges and the door has to sit on top of the left wall.

### `InteriorArt.gd` â€” complete public API, verbatim signatures

`class_name InteriorArt extends Object`. Constants: `VW := 1152.0`, `VH := 648.0`, `CEIL := 46.0`, `WALL := 305.0`, `NEAR := 606.0`, `SIDE := 44.0`, `EXT := 4000.0`, `C_VOID := Color(0.043, 0.039, 0.110)`.

```gdscript
# â”€â”€ Shell â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# wall: main wall colour Â· trim: skirting//cornice Â· accent: panel tint
# Paints the void, the ceiling, the back wall with a 96px panel rhythm,
# cornice, dado rail at WALL-74, and skirting. Call FIRST.
static func shell(ci: CanvasItem, wall: Color, trim: Color, accent: Color) -> void

# Left/right side walls + the near wall seen from above. Call SECOND-TO-LAST.
static func side_walls(ci: CanvasItem, wall: Color, trim: Color) -> void

# Fills the floor band (SIDE..VW-SIDE, WALL..NEAR+4) with a WorldArt tile id,
# then lays a contact shadow along the back wall.
static func floor_tiles(ci: CanvasItem, tile: int) -> void

# Glossy institutional floor: six pale sheen wedges. Clinics, airports, police.
static func floor_sheen(ci: CanvasItem, col: Color) -> void

# â”€â”€ Openings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Window onto the street, auto-tinted by GameState.is_morning().
static func window(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void

# Doorway back to the street, drawn on the left side wall. x is the door's
# left edge â€” Berlin always passes 56. Call LAST.
static func exit_door(ci: CanvasItem, x: float, wood: Color) -> void

# â”€â”€ Fittings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Service counter: contact shadow, panelled front (one panel per 88px),
# overhanging top slab.
static func counter(ci: CanvasItem, x: float, y: float, w: float, h: float,
		body: Color, top: Color) -> void

# Glass partition above a counter â€” the universal sign of officialdom.
# Includes speaking grille, pass-through slot, reflection streak.
static func glass_screen(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void

# Wall sign board with unreadable lettering (`marks` diagonal strokes).
static func sign(ci: CanvasItem, x: float, y: float, w: float, h: float,
		board: Color, ink: Color, marks: int = 5) -> void

# Framed notice / poster with ragged text lines.
static func notice(ci: CanvasItem, x: float, y: float, w: float, h: float,
		paper: Color, ink: Color) -> void

# Ceiling lamp: flex, shade, glow, and a pool of light on the floor at y 470.
# `t` is the caller's accumulated delta; `drop` is the flex length.
static func ceiling_light(ci: CanvasItem, x: float, warm: Color, t: float,
		drop: float = 34.0) -> void

# Long fluorescent batten with a stutter-flicker. Clinics, offices, stations.
static func strip_light(ci: CanvasItem, x: float, w: float, cool: Color,
		t: float) -> void

# Waiting-room seating: a run of `seats` linked chairs, 46px pitch.
static func bench_run(ci: CanvasItem, x: float, y: float, seats: int,
		frame: Color, seat: Color) -> void

# Potted plant: pot, shadow, four overlapping leaf circles.
static func plant(ci: CanvasItem, x: float, y: float, pot: Color) -> void

# Departure/arrival split-flap board; one row shuffles at a time.
static func flap_board(ci: CanvasItem, x: float, y: float, w: float, rows: int,
		t: float) -> void

# Rope-and-post queue line, 110px pitch.
static func queue_posts(ci: CanvasItem, x: float, y: float, count: int) -> void
```
`_pool(ci, c, rx, ry, col)` is private; call `ceiling_light`/`strip_light` instead of reaching for it.

**Adding a new primitive.** If London or Istanbul needs a shape Berlin never had (a market awning, a stall run, a bazaar arcade), add it to `InteriorArt.gd` as a new `static func` following the same `(ci: CanvasItem, x, y, ...)` convention with an explicit `-> void`. That file is 255 lines and is the correct home for shared architecture; do not fork it.

---

## 9. `WorldArt.gd` â€” the palette/atlas API

`class_name WorldArt extends Object`, `const ROOT := "res://art/world/"`. Authored at 1Ã— (16px tiles, 32px characters, 576Ã—324 plates), displayed at 2Ã— Nearest. **Positions passed to `sprite`/`strip_sprite` are 1Ã— and get doubled for you; positions passed to `draw_tiles` are already world px.**

```gdscript
# tiles/tileset_<mode>.png â€” single row of 16Ã—16 cells, in this order
const TILE_SIDEWALK   := 0
const TILE_SIDEWALK_B := 1
const TILE_KERB       := 2
const TILE_ASPHALT    := 3
const TILE_ASPHALT_D  := 4
const TILE_CROSSWALK  := 5
const TILE_COBBLE     := 6
const TILE_GRASS      := 7
const TILE_GRASS_B    := 8
const TILE_DIRT       := 9
const TILE_BURN       := 10
const TILE_CARPET     := 11
const TILE_WOOD       := 12
const TILE_RUNNER     := 13

# ui/icons.png â€” 16px cells
const ICON_COIN    := 0
const ICON_BROT    := 1
const ICON_KARTE   := 2
const ICON_KEYCARD := 3
const ICON_JOURNAL := 4
const ICON_QUEST   := 5
const ICON_QUEST_OK:= 6
const ICON_EKEY    := 7

# "morning" if GameState.is_morning() else "dawn"
static func mode() -> String

# Loads ROOT + rel; push_warning + null if missing (never crashes)
static func tex(rel: String) -> Texture2D

# "props/lamp" -> props/lamp_dawn.png or props/lamp_morning.png
static func mode_tex(rel_base: String) -> Texture2D

# Static sprite at 1Ã— coordinates, drawn at 2Ã— with Nearest. Returns null on
# a null texture, so it is safe to call for art that does not exist.
static func sprite(parent: Node, texture: Texture2D, pos_1x: Vector2,
		z: int = 0) -> Sprite2D

# Animated sprite from a horizontal strip (uniform cells, full height)
static func strip_sprite(parent: Node, texture: Texture2D, frames: int,
		fps: float, pos_1x: Vector2, z: int = 0,
		loops: bool = true) -> AnimatedSprite2D

# NPC sheets: 192Ã—128, 32px cells, rows down/up/right/left,
#             cols idleÃ—2 then walkÃ—4. Builds idle_/walk_ Ã— 4 directions.
static func npc_frames(npc: String) -> SpriteFrames

# Standing NPC sprite: same rig as the player â€” feet on the node origin line
static func npc_sprite(parent: Node2D, npc: String,
		anim: String = "idle_down") -> AnimatedSprite2D

# Dialogue portrait: the head (top 18px) of the idle-down frame
static func avatar(npc: String) -> Texture2D

static func icon(idx: int) -> Texture2D              # ui/icons.png, 16px cells
static func pip(tier: int) -> Texture2D              # ui/familiarity_pips.png, 8px

# Fill a WORLD-space rect with one tile, inside a CanvasItem's _draw().
# Paints TILE_FALLBACK[tile] as an opaque base FIRST, so a missing atlas can
# never leave a floor unpainted. Tiles land on a 32px grid from rect.position.
static func draw_tiles(ci: CanvasItem, tile: int, rect: Rect2) -> void
```

`TILE_FALLBACK` is a parallel `const` array of solid Colors indexed by the same `TILE_*` ids â€” this is the project's canonical ground palette and is what a new city inherits for free.

**Available NPC sheet names** (the complete set â€” `npc_sprite("...")` with anything else silently draws nothing): `commuter_f`, `commuter_m`, `lukas`, `renate`, `weber`, `pigeon`. New-city clerks use `commuter_f` / `commuter_m`. New-city *characters* are drawn in GDScript, `_draw()`-style, following `NPC.gd` / `Receptionist.gd` / `BusStopNPC.gd`.

---

## 10. `SceneExit.gd` + `SceneExit.tscn`

```gdscript
extends Area2D

@export var target_scene: String = ""
@export var spawn_tag:    String = ""
@export var prompt_text:  String = "E â€” Leave"

var player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.text = prompt_text


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event is InputEventKey \
			and event.keycode == KEY_E and event.pressed and not event.echo:
		_go()


func _go() -> void:
	if target_scene.is_empty():
		return
	GameState.spawn_tag = spawn_tag
	TransitionManager.go(target_scene)
```
Scene: `Area2D` + `CollisionShape2D` (`RectangleShape2D` `Vector2(70, 220)`) + `Prompt` `Label` at `Vector2(-92, -130)`, `visible = false`, font size 12. Override the shape per-instance for a wide doorway (`Vector2(96, 62)` for the hotel door) and move the Prompt to match.

`TransitionManager.go(path: String) -> void` â€” a `layer = 128` CanvasLayer autoload; 0.30s fade to `Color(0.05, 0.04, 0.10)`, `change_scene_to_file`, 0.35s fade in. Re-entrant calls are dropped while `_busy`. **Always route scene changes through it, never `get_tree().change_scene_to_file` directly.**

---

## 11. `ServicePoint.gd` â€” every counter, machine and notice board

```gdscript
extends Area2D

# Any counter, machine or notice board you can walk up to and press E at.
# The behaviour lives in the Services autoload â€” this node is just the
# proximity prompt and the trigger.

@export var service: String = ""
@export var prompt_text: String = "E â€” Use"
@export var clerk: String = ""       # optional NPC sheet name behind the counter
@export var clerk_facing: String = "down"
# Where the clerk stands relative to this point â€” default puts them behind
# a counter whose front edge the player is standing at
@export var clerk_offset: Vector2 = Vector2(0, -136)

var player_nearby := false
var _busy := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.text = prompt_text
	$Prompt.visible = false
	if not clerk.is_empty():
		var s := WorldArt.npc_sprite(self, clerk, "idle_" + clerk_facing)
		if s != null:
			s.position = clerk_offset
			s.z_index = -1


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or _busy or get_tree().paused:
		return
	if event is InputEventKey and event.keycode == KEY_E \
			and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		_use()


func _use() -> void:
	_busy = true
	await Services.run(service, self)
	_busy = false
```
Scene: `Area2D` + `CollisionShape2D` (`RectangleShape2D` `Vector2(150, 120)`) + `Prompt` `Label` at `Vector2(-56, -96)`, `visible = false`, font size 12.

**Binding a service id** is exactly one `.tscn` line â€” `service = "exchange"` â€” plus one `match` arm in `Services.run`. Nothing else connects them. There is no registry, no validation: a `service` string with no arm falls into `_: _think("Nothing here answers to me.")`.

`clerk_offset` default `Vector2(0, -136)` places the sprite behind a standard counter. The U-Bahn lost-property hatch uses `clerk_offset = Vector2(0, -142)` because the hatch is higher.

---

## 12. `Services.gd` â€” the dispatch, and the exact shape of a new handler

```gdscript
func run(service: String, _source: Node) -> void:
	match service:
		"exchange":       await _exchange()
		"jobboard":       await _jobboard()
		"ubahn_ticket":   await _ubahn_ticket()
		"ubahn_travel":   await _ubahn_travel()
		"lost_property":  await _lost_property()
		"police_desk":    await _police_desk()
		"hospital_desk":  await _hospital_desk()
		"airport_desk":   await _airport_desk()
		"job_crates", "job_flyers", "job_dishes": _job_site(service)
		_: _think("Nothing here answers to me.")
```
Rules: one arm per service id; arms that open a chooser are `await`ed, arms that only show a thought are not; multiple ids may share one arm via a comma list. Add new-city arms to this same `match` â€” **do not create a second dispatcher.**

Two private helpers every handler uses:
```gdscript
func _choice() -> Node:
	return get_tree().get_first_node_in_group("choice_panel")


func _think(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(text)
```

**The canonical handler shape** â€” copy this skeleton exactly (from `_lost_property`, the tightest example):

```gdscript
# â”€â”€ U-Bahn lost property â€” the ridged fragment â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func _lost_property() -> void:
	if GameState.has_fragment("shard_lost"):                    # 1. already done?
		_think("The clerk recognises me now and shakes his head,\n" +
			"almost kindly. Nothing else of mine has been lost.")
		return
	var cp := _choice()                                          # 2. get the panel
	if cp == null:
		return
	var fee := 2                                                 # 3. compute gates
	var afford := GameState.money >= fee
	cp.open("FundbÃ¼ro",                                          # 4. open
		"a hatch, a ledger, and shelves of umbrellas going back years. He " +
		"holds up something ridged and dark and raises an eyebrow.",
		[
			{"id": "claim", "label": "Point at it. Then at yourself.",
				"sub": "he taps the ledger and rubs two fingers together â€” a fee",
				"cost": "%s%d" % [GameState.symbol(), fee], "disabled": not afford},
			{"id": "", "label": "Leave it on the shelf",
				"sub": "" if afford else "he will not take a promise instead of coins"},
		])
	var pick: String = await cp.chosen                           # 5. await, typed
	if pick != "claim" or not afford:                            # 6. re-validate
		return
	GameState.money -= fee                                       # 7. mutate
	GameState.money_changed.emit(GameState.money)                # 8. EMIT MANUALLY
	GameState.recover_fragment("shard_lost")
	_think("He writes a line in the ledger, turns the book round, and\n" +
		"taps an empty box. I draw the only mark I know is mine.\n\n" +
		"The fragment is warm through the paper bag. Two now.")
```

Non-obvious obligations:
* `var pick: String = await cp.chosen` â€” explicit `String`, never `:=`.
* **`GameState.money -= x` does NOT emit.** The `money` property setter only writes `wallet[currency()]`. You must call `GameState.money_changed.emit(GameState.money)` yourself, or the HUD and the pickup toast go stale. (`GameState.add_money()` *does* emit â€” use it for income.)
* Always re-validate affordability after the `await`; the panel pauses the tree but the guard is cheap and the codebase does it everywhere.
* `_think` text is hard-wrapped by hand with `\n` at ~62 chars and uses `\n\n` between beats. Money deltas are appended as `"\n\n( +%s%d )" % [GameState.symbol(), pay]`.
* Rows with `"id": ""` are the walk-away option and always come last.

**The odd-jobs contract** (`JOBS` const, already populated with `crates`/`flyers`/`dishes`/`sweep`):
```gdscript
"crates": {
	"title":  "Stack the delivery crates",
	"giver":  "the bread man at the field market",
	"where":  "the stall by the wreck",
	"pay":    4,
	"target": "job_crates",     # the ServicePoint `service` id that completes it
	"accept": "...",            # thought shown on accepting
	"done":   "...",            # thought shown on completing
},
```
`_jobboard()` lists every entry in `JOBS` regardless of city, refuses if `GameState.active_job` is non-empty, and `_job_site(service)` completes only if `job["target"] == service`. **A new city adding jobs must also add the matching `job_*` ids to the `run()` match arm's comma list**, and â€” because `JOBS` is global â€” should gate rows by city if a Berlin job should not appear on an Istanbul board.

---

## 13. `ChoicePanel` â€” the chooser

Group: `"choice_panel"`. `layer = 11`. `process_mode = PROCESS_MODE_ALWAYS`. Pauses the tree while open.

```gdscript
signal chosen(id: String)

func open(title: String, subtitle: String, rows: Array) -> void
```

Call site, verbatim from the file's own header comment:
```gdscript
var cp := get_tree().get_first_node_in_group("choice_panel")
cp.open("Where to?", "the line map is a coloured tangle", rows)
var id: String = await cp.chosen
```

Row dictionary â€” `rows: [{...}]`, all values read via `.get()` with defaults:

| key | type | effect |
|---|---|---|
| `id` | String | emitted on `chosen`. `""` = back out |
| `label` | String | 18px, `Color(0.94, 0.92, 1.00)` |
| `sub` | String, optional | 12px word-wrapped, `Color(0.60, 0.58, 0.88, 0.75)` |
| `cost` | String, optional | right-aligned 16px gold; formatted `"%s%d" % [GameState.symbol(), n]` |
| `disabled` | bool, optional | row dims to `modulate.a = 0.45` and gets **no button** â€” unclickable |
| `note` | â€” | documented in the header comment but **never read by `_populate`**. Do not rely on it. |

Escape emits `chosen("")`. `open()` early-returns if already `_open` â€” if you call it twice without awaiting, the second caller's `await` hangs. `ServicePoint._busy` prevents this for service points; any new caller must guard itself the same way.

Idiom for "the option exists but you can't take it": include the row with `"disabled": true` and put the reason in `sub`, so the player *sees the door and learns why it is shut*. `_airport_desk` does this and puts the explanation in the walk-away row's `sub`.

---

## 14. `ThoughtBox` and `AngryBox`

```gdscript
# group "thought_box" â€” the alien's interiority. Pauses the tree.
func show_thought(text: String) -> void

# group "angry_box" â€” a wall of hostile sound through a closed door.
# No responses; any key closes. Renders `words` through the glyph filter.
func show_angry(words: Array, source: String) -> void
```
`AngryBox._render` is **hard-coded to `GameState.get_tier("german", wkey)`**. If a new city uses the angry box, that line needs the local language (see findings).

---

## 15. `DialogueBox` â€” the conversation and the glyph filter

Group: `"dialogue_box"`. Pauses the tree. `Player.gd` watches this group to trigger the notebook read animation, so any conversation must go through it.

```gdscript
func show_dialogue(entries: Array, npc_name: String, relationship: String,
		npc_color: Color, grant_exposure: bool = true, region: String = "") -> void
```

`entries` is an Array of Dictionaries, each one screen of dialogue:
```gdscript
{
	"words": [
		{"text": "Guten",   "word": "guten",  "language": "german"},
		{"text": "Morgen!", "word": "morgen", "language": "german"},
	],
	"responses": [
		{"text": "Bow slightly, hands clasped",     "style": "formal"},
		{"text": "Point at yourself and shrug",     "style": "gesture"},
		{"text": "Nod and hold steady eye contact", "style": "direct", "rep": 1},
		{"text": "Hold out the metal discs, point at the bread  (â‚¬2)",
			"style": "direct", "action": "buy_bread", "requires_money": 2},
	]
}
```
* `text` is the **display** form with punctuation and inflection ("frisches", "Morgen!"); `word` is the lowercase **familiarity key** ("frisch", "morgen"). Several display forms share one key â€” that is the point.
* `language` is the `GameState.familiarity` bucket: `"german"` today, `"english"` / `"turkish"` per `GameState.CITIES[*].language`.
* `style` âˆˆ `formal` / `direct` / `gesture` / `indirect` â†’ coloured tag chip. Anything else falls back to grey.
* `rep` (int, optional) applies `GameState.change_reputation(region, rep)` â€” **only on the first talk of a visit** (`grant_exposure` true) and only if `region` is non-empty.
* `requires_money` (int, optional) â€” the row is **not rendered at all** if `GameState.money` is below it.
* `action` (String, optional) is dispatched by a hard-coded `if/elif` chain in `_on_response`: `"buy_bread"` â†’ `GameState.buy_bread()`, `"give_map"` â†’ `GameState.receive_map()`, `"book_room"` â†’ `GameState.book_room()`. **A new city action must be added to that chain**; there is no lookup table.

Every entry, on display: fires `AudioManager.speak(_name_label.text.hash(), words.size())` (one blip per word, pitch stable per speaker name), records which words are at familiarity 0 so they shuffle glyphs, then â€” if `grant_exposure` â€” calls `GameState.expose(lang, word, "hear")` on each.

### The rendering ladder (this is the game's thesis, in code)

```gdscript
func _render_word(display: String, word: String, tier: int, first_time: bool) -> String:
	var underline: bool = SaveManager.settings.get("highlight_partial_words", false)
	match tier:
		GameState.TIER_KNOWN:
			return _wrap_guess(word, "[color=#f0eeff]" + display + "[/color]")
		GameState.TIER_PARTIAL:
			if underline:
				return _wrap_guess(word, "[u][color=#d8d4ff]" + display + "[/color][/u]")
			return _wrap_guess(word,
				"[bgcolor=#35359a][color=#d8d4ff] " + display + " [/color][/bgcolor]")
		GameState.TIER_GLIMPSED:
			return "[color=#b8b4f0]" + _to_glyphs(word) + "[/color]"
		_:  # UNKNOWN
			if first_time:
				return "[color=#e8e4ff]" + _random_glyphs(word.length()) + "[/color]"
			return "[color=#e8e4ff]" + _to_glyphs(word) + "[/color]"
```
Glyph sets: `GLYPHS_FULL := "â—ˆâŸŸâ¬¡â—‰âŸ¢âŸ£â‹„âŸ¤âŸ¥â¬¢â¬£â¬Ÿâ¬ âŸ¦âŸ§âŸ¡"`, `GLYPHS_SIMPLE := "â–²â–¼â—â– â—†â˜…â–¸â—€â–´â–¾"` (accessibility setting `simplified_glyph_set`). `_to_glyphs` is **deterministic** â€” `g[word.unicode_at(i) % g.length()]` â€” so a word has a stable alien shape you learn to recognise before you can read it. `_random_glyphs` reshuffles every 0.18s and is used *only* for never-before-heard words. The same two constants and the same `_to_glyphs` are duplicated in `Journal.gd`, `AngryBox.gd`, and `WalkingFriends.gd` (with its own inline `GLYPHS`) â€” if a new city needs a variant filter, follow that duplication rather than refactoring the four.

`_wrap_guess` makes a word hoverable **only if `GameState.WORD_GUESSES.has(word)`** â€” an `[url]` tag with meta underline disabled, surfacing the player's guess as a tooltip.

---

## 16. `GameState` â€” the language API

**Registering an exposure event â€” the one function:**
```gdscript
func expose(language: String, word: String, exposure_type: String) -> void
```
It lowercases the word, creates `familiarity[language]` on demand, adds `roundi(EXPOSURE_GAIN[type] * _word_ease(word))` clamped at 100, and emits `word_tier_changed(language, word, new_tier)` if the tier rose.

```gdscript
const EXPOSURE_GAIN = {
	"hear":    4,      # heard in dialogue â€” the default
	"pointed": 15,     # pointed at while transacting â€” the strongest
	"used":    10,     # defined, never yet called
	"read":    7,      # defined, never yet called
}

const TIER_UNKNOWN  = 0     # score  0-24  â†’ glyphs
const TIER_GLIMPSED = 1     # score 25-49  â†’ glyphs, brighter
const TIER_PARTIAL  = 2     # score 50-79  â†’ readable, highlighted
const TIER_KNOWN    = 3     # score 80-100 â†’ readable, plain

func get_familiarity(language: String, word: String) -> int
func get_tier(language: String, word: String) -> int
signal word_tier_changed(language: String, word: String, new_tier: int)
```

Word difficulty, `_word_ease(word) -> float`: â‰¤3 chars Ã—2.5, â‰¤5 Ã—1.5, â‰¤7 Ã—1.0, â‰¤9 Ã—0.7, else Ã—0.4; then Ã—0.8 if the word contains any of `Ã¤ Ã¶ Ã¼ ÃŸ`. Turkish `Ã§ ÄŸ Ä± ÅŸ` get no penalty â€” decide deliberately whether to extend that list.

Call sites in shipped code, for calibration: `DialogueBox` fires `"hear"` on every word of every entry, first talk per visit only. `WalkingFriends` fires `"hear"` once per overheard snippet within 170px. `Services._ubahn_ticket` fires `GameState.expose("german", "fahrkarte", "pointed")` when the ticket drops. `GameState.buy_bread()` and `receive_map()` and `book_room()` each fire one `"pointed"` for the object changing hands.

**Registering a language's vocabulary â€” there is no function.** Vocabulary is the union of two things:
1. Words simply appear in `familiarity[language]` the first time `expose()` names them. No declaration needed.
2. A word becomes *readable in the journal and hoverable in dialogue* only if it has an entry in the flat const:
```gdscript
const WORD_GUESSES := {
	"ich":    'â€” "I"',
	"guten":  'â€” "good"?',
	"ihnen":  'â€” "him"? "her"?  (unclear)',
	"karte":  'â€” "card"?  a paper drawing of the streets',
	"bus":    'â€” "bus"!  (same word?!)',
}
```
The guess is the alien's *working hypothesis*, not the translation. Easy cognates land direct; hard words carry visible uncertainty; `"ihnen"` deliberately misleads toward "him/her" because that is the intuitive wrong read. Entries are grouped with lower-case comments (`# Round 1+`, `# Heard on the street`, `# The hotel`). **`WORD_GUESSES` has no language dimension** â€” a Turkish `"bin"` would collide with the German `"bin": 'â€” "am"'` already there (see findings).

---

## 17. `GameState` â€” everything else a city touches

```gdscript
# â”€â”€ travel & money â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const CITIES := {
	"berlin":   {"name": "Berlin",   "country": "Germany",        "currency": "EUR",
		"symbol": "â‚¬", "language": "german",  "fare": 0},
	"london":   {"name": "London",   "country": "United Kingdom", "currency": "GBP",
		"symbol": "Â£", "language": "english", "fare": 15},
	"istanbul": {"name": "Istanbul", "country": "TÃ¼rkiye",        "currency": "TRY",
		"symbol": "â‚º", "language": "turkish", "fare": 15},
}
const RATES := {"EUR": 1.0, "GBP": 0.85, "TRY": 35.0}
const EXCHANGE_FEE := 0.10

var city: String = "berlin"
var wallet: Dictionary = {"EUR": 0, "GBP": 0, "TRY": 0}

var money: int:                          # reads/writes wallet[currency()]
	get: return int(wallet.get(currency(), 0))
	set(value): wallet[currency()] = value

func currency() -> String                # CITIES[city].currency
func symbol() -> String                  # "â‚¬" / "Â£" / "â‚º"
func city_name() -> String
func local_language() -> String          # "german" / "english" / "turkish"
func cash(cur: String) -> int
func convert_preview(amount: int, from: String, to: String) -> int
func exchange(amount: int, from: String, to: String) -> bool
func travel_to(dest_city: String) -> void   # sets city, world_flags["visited_"+city], emits money_changed
func add_money(amount: int) -> void         # emits money_changed
```
Arriving in a new city is `GameState.travel_to("london")` followed by `TransitionManager.go(<arrival scene>)`. That flips the wallet pocket, the HUD symbol, and `local_language()` in one call. **`Services._airport_desk` does not currently call it** â€” it dead-ends in a thought (see findings).

```gdscript
# â”€â”€ fragments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const FRAGMENTS := { "shard_medical": {...}, "shard_lost": {...},
	"shard_evidence": {...}, "shard_london": {...}, "shard_istanbul": {...} }

func has_fragment(id: String) -> bool
func fragment_count() -> int
func recover_fragment(id: String) -> void
```
`recover_fragment` adds `"fragment_" + id` to the inventory, emits `fragment_found`, and completes `pod_core` step `["shard_medical","shard_lost","shard_evidence","shard_london","shard_istanbul"].find(id)` â€” so **`shard_london` is step 3 and `shard_istanbul` is step 4** of the quest `WreckSite.gd` starts. It is idempotent and refuses unknown ids.

```gdscript
# â”€â”€ jobs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var active_job: String = ""
var job_progress: int = 0
var jobs_done: Dictionary = {}
func accept_job(id: String) -> void
func finish_job(id: String, pay: int, rep: int = 1) -> void   # pays via add_money, rep to current_region

# â”€â”€ quests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var quests: Dictionary = {}   # id -> {"title", "steps": [{"text","done"}], "completed"}
signal quest_updated(quest_id: String)
func start_quest(id: String, title: String, step_texts: Array) -> void   # no-op if it exists
func complete_quest_step(id: String, idx: int) -> void                   # no-op if quest/idx missing
```
`complete_quest_step` on a quest that does not exist yet is a deliberate no-op â€” `BusStopNPC` calls it speculatively with the comment `# no-op until the quest exists`. Use that pattern rather than guarding.

```gdscript
# â”€â”€ reputation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var reputation: Dictionary = { "kiez": 0, "mitte": 0, "prenzlberg": 0 }
const REP_LEVELS := [
	[60,    "practically a neighbour"],
	[35,    "a friendly face"],
	[15,    "the curious one"],
	[-10,   "a stranger"],
	[-30,   "that odd one"],
	[-9999, "trouble"],
]
func reputation_level(region: String) -> String
func change_reputation(region: String, delta: int) -> void   # SILENTLY IGNORES unknown regions
```
The raw number is never shown; only `reputation_level()` reaches the player, in `DialogueBox`'s standing label and `MapView`'s subtitle. **A new region must be added to both the `reputation` initialiser and `reset()`** or every rep change in that city silently vanishes.

```gdscript
# â”€â”€ misc â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var current_region: String = "kiez"
var region_visits: Dictionary = {}        # drives NPC dialogue rounds
var world_flags: Dictionary = {}          # one-shot world state, e.g. "kiez_pouch_taken"
var inventory: Dictionary = {}
var time_of_day: String = "dawn"          # "morning" after sleeping
var spawn_tag: String = ""
var skip_next_visit_count: bool = false
func is_morning() -> bool
func visit_region(region: String) -> int  # returns the new visit count
func add_item(item: String, n: int = 1) -> void
func remove_item(item: String, n: int = 1) -> bool
func reset() -> void                      # new game; must list every new field
signal money_changed(amount: int)
signal item_changed(item: String, count: int)
signal fragment_found(fragment_id: String)
signal job_changed(job_id: String)
```

---

## 18. NPCs

There is **no NPC base class**. An NPC is any `StaticBody2D` that duck-types four variables and one method. `NPC.gd`, `BusStopNPC.gd`, `Receptionist.gd`, `WalkingFriends.gd` are four independent implementations of the same shape:

```gdscript
extends StaticBody2D

var npc_name:     String = "Frau Weber"
var npc_color:    Color  = Color(0.38, 0.30, 0.55)   # avatar panel tint
var relationship: String = "Empfang"                  # shown under the name
var region:       String = "mitte"                    # reputation bucket

var player_nearby := false
var _talked: Dictionary = {}      # or _talked_this_visit := false


func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event is InputEventKey \
			and event.keycode == KEY_E and event.pressed and not event.echo:
		_start_dialogue()


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var variant: String
	var entries: Array
	if GameState.world_flags.get("room_booked", false):
		variant = "booked"
		entries = _BOOKED
	elif GameState.world_flags.get("has_map", false):
		variant = "greet"
		entries = _GREET
	else:
		variant = "early"
		entries = _EARLY
	dlg.show_dialogue(entries, npc_name, relationship, npc_color,
		not _talked.has(variant), region)
	_talked[variant] = true
```

Scene shape (`NPC.tscn` / `BusStopNPC.tscn`, identical): `StaticBody2D` + `CollisionShape2D` (`RectangleShape2D` ~14Ã—18 or 16Ã—20) + `InteractionArea` (`Area2D`) + `InteractionShape` (`CircleShape2D` radius `48.0`) + `Prompt` `Label` at `Vector2(-28, -62)`, text `"[E] Talk"`, `visible = false`, size 12.

**Two ways an NPC picks what to say:**
* *Rounds* (`NPC.gd`): `_ROUNDS` is an Array of Arrays; `_round_for_visit()` returns `clampi(int(GameState.region_visits.get(region, 1)) - 1, 0, _ROUNDS.size() - 1)`. Talk again in the same visit and you get the same round with `grant_exposure = false` â€” no farming. A parallel `_RELATIONSHIPS` array names the relationship per round (`["Fremder", "Bekannt", "Stammgast", "Stammgast"]`).
* *Variants* (`Receptionist.gd`, `BusStopNPC.gd`): branch on `world_flags`, key `_talked` by variant name.

The **body is drawn in `_draw()`** with `draw_rect` / `draw_colored_polygon` / `draw_circle` â€” an outline polygon in near-black `Color(0.06, 0.05, 0.08)` with a slightly inset fill polygon, a ground shadow ellipse, and one animated tell (`sin(_t * 1.3)` weight shift for the impatient commuter, `sin(_t * 1.1)` for the receptionist). Five named colour constants at the top: `_OUT`, `_SKIN`, `_HAIR`/`_COAT`, plus one signature garment. Keep the silhouette readable at 32px â€” the cap brim, the beanie, the grey bun are what distinguish them.

**Ambient teaching** (`WalkingFriends.gd`) is the pattern for street-level language:
```gdscript
const EARSHOT := 170.0
const SNIPPETS := [
	[["Guten", "guten"], ["Morgen!", "morgen"]],
	[["Der", "der"], ["Bus", "bus"], ["kommt", "kommen"], ["nicht.", "nicht"]],
]
var _exposed: Dictionary = {}

func _try_expose(snip: Array) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not (player is Node2D):
		return
	if global_position.distance_to((player as Node2D).global_position) > EARSHOT:
		return
	for pair in snip:
		var wkey: String = pair[1]
		if not _exposed.has(wkey):
			_exposed[wkey] = true
			GameState.expose("german", wkey, "hear")
```
Speech bubbles render through the same glyph filter, so overheard talk resolves as you learn â€” the street teaches, once per word per visit.

---

## 19. SAVE / LOAD

`SaveManager.save_game(slot)` writes a flat JSON dict; `load_game(slot)` reads it back and sets `pending_scene` from `data["scene"]`. Persisted today: `play_time, region, scene, familiarity, reputation, money, inventory, region_visits, world_flags, quests, hotel_floor, time_of_day, city, wallet, fragments, active_job, job_progress, jobs_done`.

Two hard constraints for anything a new city adds to `GameState`:
1. **JSON stores every number as a float.** Integer dictionaries must be pushed back through `_int_values()` on load, as `inventory`, `region_visits`, `jobs_done` and `wallet` already are.
2. New persistent state must be added in **three** places: `save_game`'s dict, `load_game`'s reader (with a default for old saves), and `GameState.reset()`. Miss `reset()` and a new game inherits the last run's state.

`load_game` sets `GameState.skip_next_visit_count = true` â€” which is why Â§4's three-line branch is mandatory.

---

## 20. GROUPS TABLE (the whole cross-scene wiring)

| group | node | entry point |
|---|---|---|
| `player` | Player | `is_in_group("player")` in every Area2D |
| `dialogue_box` | DialogueBox | `show_dialogue(entries, name, rel, color, grant, region)` |
| `choice_panel` | ChoicePanel | `open(title, subtitle, rows)` â†’ `await chosen` |
| `thought_box` | ThoughtBox | `show_thought(text)` |
| `angry_box` | AngryBox | `show_angry(words, source)` |
| `elevator_panel` | ElevatorPanel | `open_for(current_floor)` |
| `journal` | Journal | `open_from_hud()`, key J |
| `inventory` | Inventory | `open_from_hud()`, key I |
| `quest_log` | QuestLog | `open_from_hud()`, key Q |
| `quest_tracker` | QuestLog's tracker panel | read by Inventory to stack toasts |
| `map_view` | MapView | `open_from_hud()`, keys M / Tab |

`HudBar` finds all four `open_from_hud()` overlays by group and calls the method if it exists â€” no new wiring needed for a new city.

**Input convention, universal:** `KEY_E` on `_unhandled_input`, guarded by `event.pressed and not event.echo` and a `player_nearby` flag. Overlays additionally `process_mode = Node.PROCESS_MODE_ALWAYS`, set `get_tree().paused = true` on open, `false` on close, and consume Escape with `get_viewport().set_input_as_handled()`.

---

## 21. AUDIO

```gdscript
AudioManager.stop_music()
AudioManager.set_ambience(kind)   # "field" | "street" | "interior" | "none"
AudioManager.speak(voice_seed: int, syllables: int)
AudioManager.play_music(path: String)
```
All ambience and speech is synthesized at runtime â€” no asset files. Street scenes call `stop_music()` + `set_ambience("street")` in `_ready`; `Interior.gd` calls `set_ambience("interior")`. A market or a bazaar reuses `"street"`; there is no new ambience kind unless you add one to `_fill_ambience`'s `match`.

---

## 22. THE INTEGRATION CHECKLIST â€” shared files a new city MUST edit

1. **`autoload/Services.gd`** â€” add one `match` arm in `run()` per new service id; add the handler with the Â§12 skeleton; add the new city's job ids to the `job_*` comma list if it has jobs; **and make `_airport_desk` actually depart** (`GameState.travel_to(pick)` + `TransitionManager.go(<arrival scene>)`).
2. **`autoload/GameState.gd`** â€” add the city's regions to `reputation` **and** to `reset()`; add the local vocabulary to `WORD_GUESSES` (watch for cross-language key collisions).
3. **`scenes/ui/MapView.gd`** â€” add the new scene names to the title dict in `_open()`, to the region dict below it, and to the `match` in `_draw_map()`. Unlisted scenes render a blank map titled `"Somewhere"`. Interiors get this for free via `_draw_interior_map(kind, caption)` where `kind` âˆˆ `"counter"` / `"platform"`; only new street layouts need a bespoke `_draw_*_map()`.
4. **`scenes/ui/Journal.gd`** â€” `_populate()` reads `GameState.familiarity.get("german", {})` and `_on_word_tier_changed` returns early unless `language == "german"`. Both must become `GameState.local_language()`-aware, and the hard-coded `"German"` subtitle with it.
5. **`scenes/ui/Inventory.gd`** â€” add `fragment_shard_london` and `fragment_shard_istanbul` to `ITEM_DEFS`, plus any new local items. Missing ids fall back to `item.capitalize()`, which prints `"Fragment shard london"`.
6. **`scenes/dialogue/DialogueBox.gd`** â€” add any new `action` string to the `if/elif` chain in `_on_response`.
7. **`scenes/ui/AngryBox.gd`** â€” only if the city uses it; its `_render` hard-codes `"german"`.

---

## 23. LONDON'S PER-SPEAKER MODEL â€” where it plugs in

The locked design ("accents and speed", familiarity per *speaker* not per *word*) has no storage today. `familiarity` is `familiarity[language][word]`, `expose()` is the only writer, and `get_tier()` is the only reader `DialogueBox`/`Journal`/`AngryBox`/`WalkingFriends` consult.

The seam that costs least and breaks nothing:

* `GameState.familiarity` is a plain `Dictionary` keyed by an arbitrary string. Using a **speaker-scoped language key** â€” `"english:mick"`, `"english:standard"` â€” means `expose()`, `get_tier()`, save, and load all work untouched, and `DialogueBox` needs no change at all: the word entries just carry `"language": "english:mick"`.
* The word key then stops being a word and becomes the *utterance's difficulty band* â€” the same key repeated across a speaker's lines is what accumulates. Note `_word_ease()` still applies by key length, so choose keys of a deliberate length.
* What that seam costs: `Journal._populate` would list speaker-scoped buckets as vocabulary, so the Journal filter (checklist item 4) must exclude or re-present them; and `WORD_GUESSES` (flat, language-less) would need per-speaker guess text under a distinct key namespace.
* The alternative â€” a new `var speaker_familiarity: Dictionary` on GameState with its own `expose_speaker()` / `speaker_tier()` â€” is cleaner conceptually but requires a parallel render path in `DialogueBox._render_word` plus Â§19's three-place save wiring. Either is defensible; do not mix them.

Whichever is chosen, the *presentation* rule is fixed by what already exists: standard English renders plain at `TIER_KNOWN` colours, and garbled speech goes through `_to_glyphs` â€” deterministic, so the same Cockney turn of phrase wears the same alien shape every time you fail to catch it.

---

## 24. QUICK REFERENCE â€” the eleven files a builder should keep open

| file | why |
|---|---|
| `scenes/world/Mitte.tscn` | street `.tscn` template |
| `scenes/world/Mitte.gd` | street root script + SPAWNS |
| `scenes/world/MitteBackground.gd` | code-drawn outdoor background (`district == "ost"` branch) |
| `scenes/world/Exchange.tscn` | interior `.tscn` template |
| `scenes/world/Interior.gd` | shared interior root (reuse as-is) |
| `scenes/world/InteriorBackground.gd` | room-dressing dispatch shape |
| `scenes/world/InteriorArt.gd` | every drawing primitive |
| `autoload/WorldArt.gd` | tiles, sprites, NPC sheets, icons |
| `autoload/Services.gd` | service dispatch + handler skeleton |
| `autoload/GameState.gd` | language, money, fragments, quests, reputation |
| `scenes/ui/ChoicePanel.gd` | chooser call signature + row schema |

### Findings

- **[critical] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — `_airport_desk()` (lines 356-398) charges the fare and prints a thought ending "( that city is not built yet â€” the trail waits )" but never calls `GameState.travel_to(pick)` and never calls `TransitionManager.go(...)`. The player pays 15 EUR and stays in Berlin. This is the single hard blocker between Berlin and every other city â€” nothing else in the codebase changes `GameState.city`.
  - Fix: After the fare deduction, add `GameState.travel_to(pick)` followed by `GameState.spawn_tag = "from_flight"` and `TransitionManager.go(<arrival scene for pick>)`. Map destination id -> scene with a small dict as `_ubahn_travel()` does. Keep the fare deduction before `travel_to` so it is taken from the departure currency (`money` reads `wallet[currency()]`, and `travel_to` flips which pocket that is).
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `const WORD_GUESSES` (lines 74-138) is a flat dictionary keyed by bare word with no language dimension, but it is consulted by word alone from three places: `DialogueBox._wrap_guess`, `DialogueBox._on_word_hover_started`, `Journal._word_row`, `Journal._spawn_toast`. Turkish and English vocabulary added here collides with German. Concrete live collision: `"bin"` is already present as German 'â€” "am"'; Turkish "bin" (thousand) would display the German guess. `"in"`, `"der"`, `"das"`, `"gut"`, `"kann"`, `"sie"` are all plausible cross-language collisions.
  - Fix: Namespace the keys as `"german:ich"` / `"turkish:bin"` and change the four lookup sites to build the key from the entry's `language` field, or add a parallel `WORD_GUESSES_TR` / `WORD_GUESSES_EN` with a `func word_guess(language: String, word: String) -> String` accessor that the four sites call. Do not silently add unnamespaced foreign words.
- **[high] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Journal.gd** — The Field Notes journal is hard-coded to German in three places: `_on_word_tier_changed` returns immediately unless `language == "german"` (line 211-213), so no tier-up toast ever fires for English or Turkish; `_populate` reads `GameState.familiarity.get("german", {})` (line 304) and calls `GameState.get_tier("german", word)` (line 320), so no non-German word is ever listed; and the subtitle text is the literal string `"German"` (lines 161, 314, 337, 340).
  - Fix: Replace all three with `GameState.local_language()` for the active bucket, and derive the display name from `GameState.CITIES[GameState.city].language` capitalised. Decide deliberately whether the journal shows only the current city's language or a tabbed/sectioned view of all learned languages â€” the tier-up toast in particular should fire for whichever language the player is currently hearing.
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `var reputation` is initialised with exactly three keys â€” `kiez`, `mitte`, `prenzlberg` (lines 202-206) â€” and `reset()` recreates the same three (line 504). `change_reputation()` is `if reputation.has(region): ...` â€” it SILENTLY does nothing for an unregistered region. Every `"rep"` value on a London or Istanbul dialogue response, and every `change_reputation` in a new service handler, will vanish with no error, and `reputation_level()` will always return "a stranger" there.
  - Fix: Add each new city's region ids to both the `reputation` initialiser and the `reset()` assignment before writing any dialogue that carries a `rep` value. Also note `Interior.gd`'s `region` export defaults to `"mitte"` â€” every new interior .tscn must set it explicitly or its visits and reputation land in Berlin's bucket.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd** — `_open()` resolves the map title from a literal dict of the twelve Berlin scene names (lines 65-78, default `"Somewhere"`), resolves the reputation region from a second literal dict (lines 80-83, default `""`), and `_draw_map()` matches on the same Berlin scene names (lines 193-205). A new-city scene therefore opens a titled-"Somewhere" map with nothing drawn but the pulsing you-marker, and no standing line.
  - Fix: Add each new scene name to all three structures. Interiors need only a `_draw_interior_map(kind, caption)` arm â€” `kind` is `"counter"` or `"platform"` and covers every Berlin interior â€” so only genuinely new street layouts need a bespoke `_draw_*_map()`. The map is gated on `world_flags["has_map"]`, which is already true by the time the player can fly.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Inventory.gd** — `ITEM_DEFS` (lines 9-58) defines the three Berlin fragments but not `fragment_shard_london` or `fragment_shard_istanbul`, which `GameState.recover_fragment()` will add as inventory items (`add_item("fragment_" + id)`). `_item_row` falls back to `item.capitalize()`, so the two climactic pickups display as "Fragment shard london" Ã—1 with an empty description and a grey swatch, and the pickup toast reads "+1 Fragment shard london".
  - Fix: Add both entries following the existing pattern â€” name from `GameState.FRAGMENTS[id].name` ("Cold fragment", "Bright fragment"), a one-line desc in the alien's voice, and a colour continuing the teal ramp (the three Berlin shards run 0.32/0.90/0.78 down to 0.28/0.78/0.70). Add any new local items at the same time.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/dialogue/DialogueBox.gd** — `_on_response` dispatches the response `action` field through a hard-coded if/elif chain of exactly three strings â€” `"buy_bread"`, `"give_map"`, `"book_room"` (lines 241-247). An unrecognised action string is silently ignored: the conversation advances, the row's `rep` still applies, and the player sees a response that visibly did nothing.
  - Fix: Add each new city's action string to the chain, or replace the chain with a dictionary of Callables so the failure mode becomes visible. If a new action needs arguments, follow `requires_money` and add a parallel data key rather than encoding parameters in the action string.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/AngryBox.gd** — `_render()` calls `GameState.get_tier("german", wkey)` with the language hard-coded (line 77), and keeps its own duplicate `GLYPHS_FULL`/`GLYPHS_SIMPLE`/`_to_glyphs`. Any hostile-voice moment in London or Istanbul would grade its words against German familiarity, so words the player genuinely knows in the local language would still render as glyphs.
  - Fix: Give `show_angry` a `language: String = "german"` parameter (or read `GameState.local_language()`), and pass it through to `get_tier`. Note the same duplication exists in `WalkingFriends._snippet_text` (line 199, also hard-coded `"german"`) â€” any ambient street-talk node copied for a new city must have that string changed.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — `const JOBS` (lines 10-55) is a single global table and `_jobboard()` lists every entry unconditionally, with pay formatted in `GameState.symbol()` â€” the CURRENT city's symbol. Standing at an Istanbul notice board would offer "Stack the delivery crates Â· the bread man at the field market Â· the stall by the wreck" priced in lira, and accepting it would set an active job completable only in Berlin.
  - Fix: Add a `"city"` key to each job entry and filter the rows in `_jobboard()` by `GameState.city`; default missing keys to `"berlin"` so the existing four entries need no edit beyond the filter. Pay values should be authored in each city's own currency since `finish_job` -> `add_money` credits the active wallet pocket.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — `_word_ease()` (lines 258-275) applies a 0.8 difficulty multiplier for the four German-specific characters `Ã¤ Ã¶ Ã¼ ÃŸ` only. Turkish `Ã§ ÄŸ Ä± ÅŸ` receive no penalty while `Ã¶ Ã¼` do, so Turkish words get an inconsistent, half-applied difficulty curve â€” "ÅŸey" and "gÃ¼n" would be graded on different scales for no designed reason.
  - Fix: Extend the character list per language, or key the penalty set off the `language` argument (which `_word_ease` does not currently receive â€” it would need threading through from `expose`). Decide this before authoring Turkish vocabulary, since it changes how many exposures every word needs.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/ChoicePanel.gd** — The header comment documents a `"note"` key in the row schema (line 12) that `_populate` never reads â€” only `id`, `label`, `sub`, `cost` and `disabled` are consumed. Separately, `open()` early-returns when `_open` is already true (lines 35-36) without emitting `chosen`, so a second caller's `await cp.chosen` hangs until some unrelated close fires.
  - Fix: Do not use `"note"` in new rows â€” put the text in `sub`. Any new caller of `ChoicePanel.open` must carry its own re-entrancy guard the way `ServicePoint._busy` does; do not call `open()` from a node that can be triggered twice.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — The `money` property setter writes `wallet[currency()]` but does NOT emit `money_changed`. Every shipped service handler that spends money therefore follows `GameState.money -= fare` with a manual `GameState.money_changed.emit(GameState.money)`. Omitting that second line leaves the HUD money chip and the Inventory pickup toast stale until some other emitter fires.
  - Fix: In new handlers, either use `GameState.add_money(-cost)` (which emits) or replicate the two-line idiom exactly as `_exchange`, `_ubahn_ticket`, `_lost_property` and `_airport_desk` do. Do not add the emit to the setter â€” `exchange()` and `add_money()` already emit and would double-fire.

---

## Audit agent 4 (ad81fe52197faa2d3)

Three hard GDScript compile errors found, all of the exact ':=' -inference class this project has been bitten by before. The worst is in an autoload (Services.gd), which means the whole project currently fails to load, not just one scene. Beyond those: no leading-space contamination anywhere (all 16 files are cleanly tab-indented); every @onready/$Node path resolves against its .tscn; every signal connection matches its emit arity; every GameState/AudioManager/UIStyles/TransitionManager call resolves to a real function; and SaveManager's round-trip covers all 19 GameState fields. The remaining issues are runtime/logic defects around the new currency-aware `money` view (bogus HUD toasts on travel, an airport desk that charges a fare and does nothing) and two built-in identifier shadows that Godot will warn on. Nothing was executed â€” Godot is not on PATH; all verification is static reading.

### Findings

- **[critical] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — Line 234: `var dest := {` ... `}.get(pick, "")` (dict literal opens at 234, `.get()` closes at 238). ':=' cannot infer a type from Dictionary.get(), which returns Variant. Godot 4 rejects this at parse time with "Cannot infer the type of \"dest\" variable because the value doesn't have a set type." Because Services.gd is registered as an autoload in project.godot (line 29), this single error stops the ENTIRE project from loading â€” every scene, not just the U-Bahn. This is the highest-priority fix in the codebase.
  - Fix: Replace line 234 with an explicit type (leading indent is one TAB):
	var dest: String = {
Leave lines 235-238 exactly as they are. Line 239 (`if dest.is_empty():`) then type-checks correctly.
- **[critical] C:/Users/gulci/Downloads/foreigntoall/scenes/world/InteriorBackground.gd** — Line 210: `var hue := [Color(0.30, 0.50, 0.32), Color(0.52, 0.30, 0.26),` / line 211 `\t\t\t\tColor(0.36, 0.32, 0.52), Color(0.60, 0.46, 0.20)][(b + r) % 4]`. ':=' inferring from an Array-literal subscript. An untyped Array literal's element type is Variant, so Godot 4 errors: "Cannot infer the type of \"hue\" variable because the value doesn't have a set type." This kills InteriorBackground.gd, which is the background script for all six interiors (Exchange, Police, Hospital, Restaurant, UBahnStation, Airport).
  - Fix: Replace line 210 with (leading indent is THREE TABS):
			var hue: Color = [Color(0.30, 0.50, 0.32), Color(0.52, 0.30, 0.26),
Line 211 stays byte-identical. Lines 212-213 (`draw_rect(..., hue)` and `hue.darkened(0.3)`) then resolve as real Color calls instead of unsafe Variant calls.
- **[critical] C:/Users/gulci/Downloads/foreigntoall/scenes/world/InteriorBackground.gd** — Line 308: `var uc := [Color(0.28, 0.30, 0.44), Color(0.44, 0.24, 0.24),` / line 309 `\t\t\tColor(0.24, 0.36, 0.30)][u % 3]` (the shelved-umbrellas loop in _dress_ubahn). Same defect as line 210 â€” ':=' inferring from an Array-literal subscript. Second hard parse error in the same file; fixing line 210 alone will not make the script load.
  - Fix: Replace line 308 with (leading indent is TWO TABS):
		var uc: Color = [Color(0.28, 0.30, 0.44), Color(0.44, 0.24, 0.24),
Line 309 stays byte-identical.
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — Lines 390-397, `_airport_desk()`: the flight is charged (`GameState.money -= fare` on 393) but `GameState.travel_to(pick)` is never called. `GameState.city` stays "berlin", so `currency()`, `symbol()`, `local_language()` and the whole wallet-switch never fire, and `world_flags["visited_london"]` is never set. The row is only disabled when `lead` (fragment already held) is true, so the player can buy the same flight repeatedly and lose 15 EUR each time for no state change at all. `GameState.travel_to()`, `city_name()` and `local_language()` are currently dead code â€” nothing in the project calls them, which means the entire leave-Berlin spine is unwired.
  - Fix: After line 394 (`GameState.money_changed.emit(GameState.money)`) and before the `_think(...)` on 395, add (one TAB indent):
	GameState.travel_to(pick)
and replace the parenthetical on line 397 with something honest about the destination not being built yet. Note the fare is read as `int(GameState.CITIES[pick]["fare"])` but spent from the DEPARTURE city's wallet â€” that is correct as written, keep it.
- **[high] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Inventory.gd** — Line 75 `_known_money = GameState.money` plus lines 318-322 `_on_money_changed()` still treat `money` as one continuous scalar. It is now a per-currency view onto `wallet`. `GameState.travel_to()` (GameState.gd:381) and `GameState.exchange()` (GameState.gd:372) both emit `money_changed(money)` after the *pocket* has changed, so the diff `amount - _known_money` compares a GBP balance against a EUR balance. Landing in London with an empty GBP pocket after 40 EUR in Berlin toasts "Â£ -40" â€” a loss the player did not take. Same defect fires on every exchange and every flight.
  - Fix: Make the toast currency-aware rather than a raw diff. Change line 319 to key the baseline off the pocket:
	var delta := amount - int(_known_wallet.get(GameState.currency(), 0))
add a `var _known_wallet: Dictionary = {}` beside `_known_money` (line 66), seed it at line 76 with `_known_wallet = GameState.wallet.duplicate()`, and update `_known_wallet[GameState.currency()] = amount` in place of line 320. Minimum viable alternative: suppress the toast entirely when `GameState.currency()` differs from the currency the baseline was captured in.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/ChoicePanel.gd** — Lines 34-36: `open()` early-returns when `_open` is already true WITHOUT ever emitting `chosen`. Every caller in Services.gd (lines 110, 156, 195, 227, 267, 301, 338, 385) does `var pick: String = await cp.chosen` immediately after `cp.open(...)`. A swallowed open therefore parks that coroutine forever, and `ServicePoint._use()` (ServicePoint.gd:40-43) leaves `_busy = true` permanently â€” that counter is dead for the rest of the scene with no visible failure. Symmetrically, `_close()` at lines 46-47 returns without emitting when `_open` is already false.
  - Fix: Make the contract total â€” a call to open() always produces exactly one `chosen`. Replace lines 35-36 with:
	if _open:
		chosen.emit("")
		return
That resolves the pending await with a back-out instead of stranding it.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — Lines 341-351, `_hospital_desk()`: the "forms" branch calls `_think(...)` on 342-344, then execution falls straight through to a second `_think(...)` on 348-351. `ThoughtBox.show_thought()` (ThoughtBox.gd:68-71) overwrites `_text_label.text` with no queue, so the forms text is destroyed in the same frame and the player never sees it. The branch is authored but unreachable in practice.
  - Fix: Await the first thought before showing the second. Either gate the fall-through behind the box closing, or fold the forms line into the final thought. Simplest surgical version â€” replace the `_think(...)` call on lines 342-344 with a prefix variable and concatenate into the line-348 call so only one show_thought() ever fires:
	var preamble := "I fill three boxes with marks that mean nothing here.\nShe reads them, and does not laugh, which I appreciate.\n\n" if pick == "forms" else ""
then `_think(preamble + "No card. No name they can spell. ...")`.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/SaveManager.gd** — `FileAccess.open()` results are used without a null check at lines 30-31 (load_settings), 41-42 (save_settings), 74-75 (get_save_slots) and 114-115 (save_game). If the handle is null â€” user:// not writable, file locked, disk full â€” the very next `.get_as_text()`/`.store_string()` is a null-instance call and the game hard-crashes rather than degrading. `load_game` (line 123) has the same shape.
  - Fix: Guard each open. For the write path at line 114, replace with:
	var file := FileAccess.open(SAVE_DIR + "slot_%d.json" % slot, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot write slot %d (%d)" % [slot, FileAccess.get_open_error()])
		return
Apply the same two-line guard at 30, 41, 74 and 123.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/world/InteriorArt.gd** — Line 147: `static func sign(ci: CanvasItem, x: float, ...)` declares a member named `sign`, which is a Godot 4 Variant utility function. Godot emits SHADOWED_GLOBAL_IDENTIFIER ("The function \"sign\" has the same name as a built-in function"). It compiles today only because nothing inside InteriorArt.gd calls `sign()`; the moment any future drawing helper in this class does, it will silently bind to this 8-arg static method and fail with a wrong-argument-count error that points nowhere useful. Both call sites (InteriorBackground.gd:274 and :316) are unaffected by a rename.
  - Fix: Rename the method to something non-colliding. Change line 147 to:
	static func sign_board(ci: CanvasItem, x: float, y: float, w: float, h: float,
and update the two call sites: InteriorBackground.gd:274 `IA.sign_board(self, 420, 110, 300, 52, Color(0.10, 0.30, 0.62), Color(0.86, 0.90, 1.00), 7)` and InteriorBackground.gd:316 `IA.sign_board(self, 634, 128, 132, 24, Color(0.18, 0.32, 0.20), Color(0.86, 0.90, 0.82), 4)`.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — Line 260: `var ease: float` inside `_word_ease()`. `ease()` is a Godot 4 built-in utility function, so this triggers SHADOWED_GLOBAL_IDENTIFIER. Harmless today (the function never calls the real `ease()`), but it is noise in the warning log of an autoload that everything depends on, and it makes `_word_ease` unable to ever use the real easing helper.
  - Fix: Rename the local. Line 260 becomes (one TAB indent):
	var factor: float
and update lines 262, 264, 266, 268, 270, 273 and 275 to use `factor` instead of `ease` (`factor = 2.5`, `factor *= 0.8`, `return factor`).
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/HudBar.gd** — Line 42: `_money_label.text = "â‚¬ 0"` hardcodes the euro symbol. The comment says it is replaced every frame by _process, which is true â€” but it means the first rendered frame after entering a London or Istanbul scene shows a euro sign. It is also the only remaining hardcoded currency glyph in UI code that GameState.symbol() should own.
  - Fix: Replace line 42 with (one TAB indent):
	_money_label.text = "%s 0" % GameState.symbol()   # replaced every frame by _process
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/Inventory.gd** — ITEM_DEFS (lines 9-58) defines fragment_shard_medical, fragment_shard_lost and fragment_shard_evidence but omits fragment_shard_london and fragment_shard_istanbul. `GameState.recover_fragment()` (GameState.gd:398) calls `add_item("fragment_" + id)` for all five, so the two out-of-Berlin shards will render with `item.capitalize()` â€” "Fragment Shard London" â€” and a grey placeholder swatch, with no description. Names and descs already exist in GameState.FRAGMENTS (lines 42-53) but their "desc" fields are empty strings.
  - Fix: Add two entries after line 51 (the fragment_shard_evidence block), matching the existing indentation (one TAB for the key, two for the fields):
	"fragment_shard_london": {
		"name":    "Cold fragment",
		"desc":    "It passed through a dealer's hands before it reached yours.",
		"color":   Color(0.26, 0.72, 0.66),
		"eatable": false,
	},
	"fragment_shard_istanbul": {
		"name":    "Bright fragment",
		"desc":    "It surfaced in a market, priced by someone who could not read it either.",
		"color":   Color(0.24, 0.66, 0.62),
		"eatable": false,
	},
While there, fill the two empty "desc" strings in GameState.FRAGMENTS lines 46 and 52.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — Lines 8-9 declare `signal fragment_found(fragment_id: String)` and `signal job_changed(job_id: String)`. Both are emitted (lines 399, 419, 430) but nothing in the project connects to either â€” verified by grep across all .gd files. The HUD has no job indicator and no fragment-recovered feedback beyond the generic item toast, so recovering a shard reads identically to picking up bread.
  - Fix: Either wire them or delete them. To wire: in HudBar._build() add a job chip and connect in _ready() with `GameState.job_changed.connect(_on_job_changed)`; in Inventory._ready() (after line 78) add `GameState.fragment_found.connect(_on_fragment_found)` with a handler that calls `_notify("â—ˆ  " + String(GameState.FRAGMENTS[id]["name"]))`. To delete: remove lines 8-9 and the three emit calls.
- **[low] C:/Users/gulci/Downloads/foreigntoall/scenes/world/Interior.gd** — Interior.gd ignores GameState.spawn_tag entirely â€” line 18 always uses the `spawn` export, and line 19 clears the tag. But Airport.tscn and Hospital.tscn both set `spawn_tag = "from_airport"` / `"from_hospital"` on their Exit nodes pointing back to UBahnStation.tscn, and UBahnStation also uses Interior.gd. So arriving from the clinic, the airport, or the street stairs all dump the player at the same (210, 430) doorway spot, which is wrong for the U-Bahn platform where the stairs are at xâ‰ˆ116 and the trains arrive at the platform edge. Mitte.gd and MitteOst.gd already implement the SPAWNS-dictionary pattern this is missing.
  - Fix: Give Interior.gd the same tag table the street scenes have. Add an export beside line 7:
	@export var spawns: Dictionary = {}
and replace line 18 with:
	$Player.position = spawns.get(GameState.spawn_tag, spawn)
Then set `spawns = {"from_airport": Vector2(360, 430), "from_hospital": Vector2(360, 430), "from_ubahn_stairs": Vector2(180, 430)}` on the UBahnStation root node in UBahnStation.tscn.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/SaveManager.gd** — Round-trip audit result: all 19 GameState fields ARE saved and loaded â€” no gaps. But `familiarity` (line 128) and `reputation` (line 129) bypass `_int_values()`, and `_int_values` is single-level so it could not fix `familiarity` anyway (it is `familiarity[language][word]`). After a load these hold JSON floats, not ints. `GameState.get_familiarity()` is declared `-> int` (GameState.gd:227) and returns that float directly; it survives only because GDScript coerces floatâ†’int on typed return. Values are whole numbers so nothing visibly breaks, but the type contract is a lie and `reputation[region]` accumulates as float through `change_reputation`'s clamp (GameState.gd:280).
  - Fix: Add a nested variant and use it. After `_int_values` (line 160) add:

func _int_values_nested(src: Dictionary) -> Dictionary:
	var out := {}
	for k in src:
		out[k] = _int_values(src[k])
	return out

then change line 128 to `GameState.familiarity = _int_values_nested(data.get("familiarity", {}))` and line 129 to `GameState.reputation = _int_values(data.get("reputation", GameState.reputation))`.

---

## Audit agent 5 (a58cb7e9e15865b80)

# London â€” Design Bible

> *Foreign to All* â€” region 2 of 3. Holder of `shard_london` ("Cold fragment"), sold on to a dealer.
>
> Status: **design only.** No London scene exists on disk. Nothing in this document has been built, run, or play-tested â€” Godot is not installed here.

Written to: `C:/Users/gulci/Downloads/foreigntoall/docs/design/london.md` (916 lines, 47.5 KB). No other file touched.

---

## 0. The thesis, restated for this city

Berlin taught the player that **words are opaque**. You cannot read the sign, so you learn the sign, one word at a time, and the fog lifts in patches.

London teaches the harder half: **words are not enough.** Here the alien can already read most of what is written and much of what is said â€” and is *more* lost, not less. The fog is gone and it turns out the fog was never the problem.

So London must not feel like Berlin-with-a-new-palette. It must feel like the moment the difficulty changes shape. Three inversions carry that:

| | Berlin | London |
|---|---|---|
| **What is hidden** | the word | the *speaker*, and the meaning behind a clear word |
| **What you accumulate** | vocabulary | ears â€” one person at a time |
| **What failure looks like** | a wall of glyphs | a sentence you read perfectly and act on wrongly |
| **Emotional register** | bewilderment | embarrassment |

Bewilderment is lonely. Embarrassment is *social* â€” it requires an audience who understood you fine and is being polite about it. That is the upgrade.

---

## 1. The read â€” what makes a London street not a Berlin street

Berlin, as built in `MitteBackground.gd` / `Kiez.gd`, is: wide, flat-fronted, tall-windowed, indigo-and-amber, with generous pavement and a lot of sky. The city sits *back* from you.

London sits **on top of you**. Design every plate from these five differences:

**1. The street is narrower and the buildings are shorter, but it feels tighter.** Berlin's Mietshaus is 5â€“6 storeys with a wide street. A London terrace is 2â€“4 storeys with a street half the width. Same claustrophobia from the opposite direction. Reduce street width, reduce building height, keep the rooflines *busy* â€” that is where London's density lives.

**2. The roofline is a mess, on purpose.** Berlin's roofline is one long ruled edge. London's is chimney stacks â€” clusters of 4â€“8 pots on every party wall, staggered, never level, because the terrace steps down the hill. Add TV aerials, satellite dishes, a slumped parapet, a bit of moss. **The chimney stacks are the single most identifying silhouette element.** If the player squints at a black cut-out of the skyline they should know which city it is.

**3. Every house has a hole in front of it.** The basement area: a sunken well between pavement and front door, guarded by cast-iron railings, crossed by steps up to a raised front door. Berlin's door meets the pavement. London's door is *above* the pavement and there is a pit beside it. This gives the facade a vertical rhythm Berlin does not have: railing / void / steps / stoop / door, repeated every 5 metres.

**4. The wall is yellow-brown, not grey.** London stock brick â€” made from Thames-basin brickearth, fired yellow, then blackened by two centuries of coal smoke, so it reads as a dirty ochre-grey that goes *warmer* where it is washed and *sootier* under sills and cornices. Accented with bands of red brick over window heads and at the corners. Where the ground floor is a shop or a grander terrace, the brick is rendered over in **stucco**, painted dirty cream, with the render scored to fake stone blocks. Two materials, one wall.

**5. Sash windows, and they are always a bit wrong.** Vertical sliding sashes, white-painted, divided into panes, and the top one is nearly always open two inches â€” no matter the weather. That two-inch gap, repeated up a whole terrace, is a free authenticity detail that costs one `draw_rect`.

### The layer stack for a London street plate

Draw in this order. It matches how `MitteBackground.gd` already builds Berlin, so the London background script can be a sibling, not a rewrite.

```
  â”€â”€ sky â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  0  overcast lid          low, close cloud. Never a clear sky in London.
                           No stars. This alone re-reads the whole scene.
  1  sodium bounce         warm-grey glow smeared on the cloud belly from
                           beneath â€” the city lighting itself back at itself.

  â”€â”€ far â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  2  far roofline          silhouette only: chimney stacks, one crane,
                           the ghost of a tower block.

  â”€â”€ facade â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  3  stock brick field     base wall, with courses hinted, not drawn.
  4  soot gradient         darker under every horizontal â€” sills, cornice,
                           the underside of the parapet. Dirt falls down.
  5  red brick bands       flat arches over window heads; quoins at corners.
  6  stucco ground floor   on some houses only. Never all of them.
  7  sash windows          white frame, glazing bars, top sash open 2in.
  8  door + fanlight       raised door, semicircular fanlight above it,
                           number painted on the fanlight glass.
  9  chimney stacks        clustered pots. Stagger them. Never level.

  â”€â”€ street furniture â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
 10  railings              cast iron, spear-headed, in front of the area.
 11  area steps            down into the basement well, and up to the door.
 12  shopfront fascia      where there is a shop: a painted board above the
                           window, gold or white serif on a dark ground.
 13  wheelie bins          black, blue, brown. Overfull. Lids ajar.
                           Left out on the wrong day. This is not set dress â€”
                           it is 40% of what a London street actually looks like.
 14  scaffolding           one building in every four. Poles, boards, a green
                           debris net, a plastic banner with a phone number.
                           London is permanently half-repaired.
 15  plane tree            camouflage bark in cream / olive / grey, big
                           maple-ish leaf, planted in a small square of dirt
                           in the pavement with a low hoop guard.

  â”€â”€ ground â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
 16  pavement              grey-buff slabs, rectangular, badly relaid,
                           with tarmac patches where the utilities dug.
 17  kerb                  granite, higher than Berlin's, rounded lip.
 18  double yellow         two parallel yellow lines against the kerb.
                           The only saturated colour on the road surface.
 19  tarmac                cooler and bluer than Berlin asphalt, always
                           slightly wet-looking. Sheen, not shine.

  â”€â”€ punctuation (sparse â€” never more than two per plate) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
 20  pillar box            fat red cylinder, domed cap, black slot.
 21  phone box             red, square, small panes, crown in the pediment.
                           Usually broken. Usually being used as a bin.
 22  bus stop flag         a pole with a red-and-blue roundel flag on top.
 23  Underground roundel   red ring, blue bar. See Â§4.3.
```

**The rule that keeps it from looking like Berlin:** London has **more small objects and fewer big shapes**. Berlin is composed; London is accumulated. Every plate should have at least four pieces of clutter that nobody placed deliberately â€” a bin, a bag of rubbish, a chained bicycle wheel with no bicycle, a traffic cone that has been there for a year.

---

## 2. Colour palette

London reads **cooler, greyer and browner** than Berlin. Berlin's world palette is an indigo night with amber windows â€” violet shadows, warm glass. London replaces the violet with **grey-green**, the amber with a **paler, milkier warm**, and then hits the whole thing with two or three points of absolutely saturated red and blue that appear nowhere else in the frame.

The discipline: **the accents are statutory, everything else is filthy.** No mid-saturation colour anywhere. Either it is dirt, or it is a sign.

### 2.1 The sixteen â€” `art/world/foreigntoall_london.gpl`

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
232 226 212   sash white (#e8e2d4)          window frames â€” the bright line
 26  29  36   window dark (#1a1d24)         unlit glass
240 215 154   window lit (#f0d79a)          milkier and cooler than Berlin's
 51  53  60   tarmac (#33353c)              cooler, bluer, always faintly wet
 75  74  70   york stone (#4b4a46)          pavement slabs, grey-buff
106 102  96   granite kerb (#6a6660)        higher lip than Berlin's
143 138 118   plane bark (#8f8a76)          the camouflage flake
```

### 2.2 The statutory six â€” do not art-direct these

These are real specifications. They are the punctuation of the city and they are the *only* fully saturated colours London gets. Using them accurately is worth more than any amount of invented palette, because a Londoner recognises these six before they recognise a building.

| Hex | Name | Where it is real | Use in game |
|---|---|---|---|
| `#e1251b` | TfL Corporate Red (PMS 485) | Underground roundel ring, bus stop flag, bus livery, Central line | roundels, bus flags, the one moving bus |
| `#0019a8` | TfL Corporate Blue (PMS 072) | the bar across the roundel, station name plates, Piccadilly line | roundel bar, platform name frieze |
| `#a23b3c` | Post Office Red, BS381C-538 | pillar boxes, the K2/K6 phone box | pillar box, phone box â€” note it is **deeper and browner** than TfL red, and standing them near each other is a real London colour event |
| `#005eb8` | NHS Blue (PMS 300) | every NHS sign in the country | hospital exterior, A&E wayfinding |
| `#ffd329` | Circle line yellow | line diagrams, roundel infill on some maps | the double-yellow kerb line reads as a dirtier cousin at `#d8b800` |
| `#000000` | Northern line black | line diagrams, ironwork | railings, lamp columns, the bin |

**Composition rule.** A London plate is 90% values between `#1a1d24` and `#6e5f49`, plus **one** statutory accent at full chroma. Two accents only where the fiction demands it (a pillar box beside a bus stop). Three is a mistake. Berlin's amber windows are allowed to be everywhere because warmth is Berlin's character; London's red is a *signal*, and a signal that appears everywhere is noise.

---

## 3. What London is, as a place in this story

The alien arrives at an airport, not a crash site. That inversion matters â€” the player has *chosen* to come here, with a ticket bought with money they earned. They are no longer a survivor. They are a tourist, which is a much lonelier thing to be.

**The fragment.** `shard_london` â€” "Cold fragment." Sold on to a dealer. The word *dealer* is doing a lot of work: this is the first fragment held by someone who understands it is worth money, and who will therefore *talk*. The Berlin fragments were held by systems (a clinic, a lost property office, an evidence locker) that could be navigated with paperwork and patience. London's is held by a person with an interest in the conversation going a certain way. You cannot fill in a form to get it. You have to understand what he means.

That is the region's whole design in one sentence: **Berlin was bureaucracy, London is negotiation.**

**The geography.** Two or three street plates is enough. Suggested:

- **`Terrace`** â€” residential. Where the cheap hotel is. Wheelie bins, scaffolding, one plane tree, a pillar box. The quiet plate. Learn to walk here.
- **`HighStreet`** â€” the shops. Bureau de change, the caff, the pub, the bus stop, the Underground entrance. The loud plate. Everything is transacted here.
- **`ArchesMarket`** â€” under a railway viaduct. Brick arches, lock-up units, stalls, a dealer's unit at the far end. Trains overhead, felt not seen. The plate the fragment lives on.

---

## 4. The seven buildings, localised

Every building keeps its `Services.gd` hook. What changes is the **signage vocabulary**, the **counter behaviour**, and the **social script** â€” because the social script is the actual content of this region.

Interiors follow the existing rule: **drawn in GDScript.** Extend `InteriorBackground.gd`'s `room` switch with London variants rather than authoring new `.tscn` art. Suggested keys: `bureau`, `nick`, `ae`, `caff`, `tube`, `terminal`, plus `b_and_b` for the hotel lobby.

---

### 4.1 Hotel â†’ **the B&B**

Not a hotel. A converted Victorian terrace with a laminated sign in the front window and a bell on the desk.

**Exterior.** Two terraced houses knocked together, stucco ground floor painted a colour that was cream in 1994. A plastic-and-vinyl sign across the first-floor windows. A small internally-lit box sign at the door reading **VACANCIES**, with a hinged panel that flips to **NO VACANCIES**. Four stars printed on the sign by the owner, on the owner's own authority.

**Signage vocabulary.**
`VACANCIES` Â· `NO VACANCIES` Â· `B&B` Â· `EN-SUITE` Â· `FULL ENGLISH INCLUDED` Â· `RECEPTION` Â· `PLEASE RING FOR ATTENTION` Â· `NO SMOKING` Â· `CHECK-OUT 10AM` Â· `ROOM 4 â€” FIRST FLOOR`

**The trap that costs the player a day.** In Britain the **ground floor is not the first floor.** "Room 4, first floor" is one storey *up*. Berlin taught `dritter Stock` = third floor and the alien learned to count. London silently shifts the origin by one. Have the player go to the wrong door, and have a guest open it, and have the guest say *"sorry"* â€” meaning *you are in the wrong place, please leave.*

**Social script.** The desk person will ask **"You alright?"** before anything else. It is not a question about your condition. Answering it as one is the region's tutorial failure, and it should happen in the first sixty seconds.

**Reuse.** `HotelLobby`, `HotelFloor`, `HotelRoom`, `HotelDoor`, `BedRest`, `Elevator` all carry over â€” except the lift. A B&B in a Victorian terrace has **no lift**, only a narrow staircase with a worn runner. Removing the `ElevatorPanel` from London is a small change that speaks loudly.

---

### 4.2 Money exchange â†’ **the bureau de change**

**Exterior.** A narrow unit between a phone-unlocking shop and a chicken shop. Yellow-and-black vinyl in the window. Big printed numbers taped to the glass.

**Interior.** Reuse `_dress_exchange()`'s bones â€” booth, security glass, split-flap rate board â€” but re-dress: the rate board becomes a backlit acrylic panel with **two columns, WE BUY and WE SELL**, and the alien must work out why there are two numbers for the same thing. That is a genuinely alien-legible piece of cultural learning: *the price of a thing depends on which way it is moving.*

**Signage vocabulary.**
`BUREAU DE CHANGE` Â· `WE BUY / WE SELL` Â· `0% COMMISSION` Â· `NO COMMISSION ON EUROS` Â· `TRAVEL MONEY` Â· `BEST RATES IN LONDON` Â· `MINIMUM Â£20` Â· `RATES SUBJECT TO CHANGE` Â· `PLEASE HAVE ID READY`

**The lie.** `0% COMMISSION` is displayed enormously; the margin is buried in the spread between BUY and SELL. `GameState.EXCHANGE_FEE` is `0.10` â€” in Berlin the booth *told* the alien it was taking a cut. London's booth advertises that it takes nothing and takes more. The alien can only detect this by exchanging twice and comparing, which is a perfect optional journal beat.

**Social script.** No greeting. The clerk says a number and waits. Silence here is not hostility, it is efficiency, and the alien will read it as hostility.

---

### 4.3 Metro â†’ **the Underground**

Never "U-Bahn", never "metro", never "subway" (in Britain a *subway* is a pedestrian tunnel under a road). It is **the Underground**, or in speech, **the Tube**.

**Exterior.** A tiled entrance arch in ox-blood glazed terracotta, or a plain 1930s concrete portal. Above it, the **roundel**: a red ring, a blue horizontal bar, `UNDERGROUND` in white on the bar. This is the single most recognisable object in the region â€” get the geometry right. The bar is wider than the circle and passes fully through it.

**Interior.** Extend `_dress_ubahn()` into `_dress_tube()`:

- Cream and ox-blood **glazed tiles**, in bands, with the station name spelled out in tile mosaic at intervals along the platform wall.
- The **name frieze**: station name in white on the blue roundel bar, repeated down the platform so it is readable from any carriage window.
- **Ticket barriers** â€” waist-high gates with yellow card readers. Berlin's U-Bahn was open; you could walk on. London physically will not let you through. The barrier is the region's first hard "no".
- A **line diagram**: coloured lines on white, no geography, no scale. To the alien this is a *nonsense object* â€” a map that does not correspond to the ground. Nail this beat. It is genuinely, philosophically strange, and it is correct: the Tube map is a diagram of *relations*, not of *places*.
- Warm gritty wind from the tunnel mouth before a train.
- The tannoy, in the clearest, slowest English in the whole region.

**Signage vocabulary.**
`UNDERGROUND` Â· `WAY OUT` (not EXIT â€” that word is reserved for emergencies) Â· `MIND THE GAP` Â· `NO EXIT` Â· `TO THE TRAINS` Â· `NORTHBOUND` / `SOUTHBOUND` Â· `CHANGE HERE FORâ€¦` Â· `TOUCH IN / TOUCH OUT` Â· `PLEASE KEEP LEFT` Â· `STAND ON THE RIGHT` Â· `DOGS MUST BE CARRIED` Â· `LOST PROPERTY` Â· `THIS ESCALATOR IS TEMPORARILY OUT OF SERVICE â€” WE APOLOGISE FOR ANY INCONVENIENCE`

**Fare.** `GameState.CITIES.london.fare` is 15 for the flight in. The Tube ride should *not* be `UBAHN_FARE`'s flat 3 â€” London charges by zone and by tap. Make the alien tap in and tap out, and charge on the *second* tap. Failing to tap out costs a penalty fare. That is a rule with no analogue in Berlin and it will catch the player exactly once, which is the right number.

**Social script â€” this is the important one.**
- **Stand on the right** on the escalator. Walk on the left. Standing on the left is the most reliably punished error in the city, and the punishment is entirely non-verbal: a build-up of people behind you, and a *tut*.
- **Let people off before you get on.** Berlin was pushy and forgiving; London is orderly and unforgiving.
- **Do not make eye contact.** Not coldness â€” a courtesy. In a space where strangers are pressed together, refusing to look is how you give them privacy. The alien, trained by Berlin to *seek out faces* to gain familiarity, will find that the London exposure mechanic actively punishes staring. Nobody will look back. Familiarity gain on the Tube should be near-zero, and this should be *felt* as a wall.
- **Nobody speaks.** A silent carriage of forty people is not a broken scene. It is the scene.

---

### 4.4 Restaurant â†’ **the caff, and the pub**

Split this into two, because in London they are two different social machines and the difference is the lesson.

#### The caff (greasy spoon)

**Exterior.** A single wide window, steamed. A hand-painted fascia in a font chosen in 1974. Laminated menu taped inside the glass. Plastic sign: `OPEN` / `CLOSED`, hung on a suction cup, at an angle.

**Interior.** Cream wall tiles to shoulder height. **Formica** table tops. Fixed plastic chairs. Black-and-white photos of boxers and a football team. A chrome tea urn. Red and brown squeezy sauce bottles shaped like tomatoes. Salt in a glass shaker with rice in it. A laminated menu card, and a hand-chalked board that contradicts it.

**Signage vocabulary.**
`ALL DAY BREAKFAST` Â· `FULL ENGLISH Â£6.50` Â· `SET B â€” 2 EGGS, BACON, BEANS, TOAST & TEA` Â· `TEA 90p` Â· `TAKE AWAY` (two words â€” a *takeaway* is the noun, *take away* is the act) Â· `CASH ONLY` Â· `NO PUBLIC TOILETS` Â· `PLEASE PAY AT COUNTER` Â· `TABLE SERVICE`

**Social script.** You sit down. Someone comes to you. You order. You pay at the end, at the counter. Tea arrives without being specified â€” *tea* means one thing here and it means it strongly.

#### The pub

**Exterior.** Corner site. Ground floor in **glazed green or ox-blood tile**. Gold serif lettering on the fascia and painted directly onto the window glass, often with `SALOON BAR` and `PUBLIC BAR` over two different doors that lead to the same room. A **hanging sign** on a bracket with a painted picture and a noun-phrase name: *The Lamb and Flag*, *The Crown*, *The World's End*. Hanging baskets. A blackboard promising a quiz on Tuesday.

**Interior.** Dark timber, a patterned carpet that hides everything, etched glass panels, hand pumps in a row along the bar with badges clipped to them, horse brasses, a fireplace nobody has lit, low warm light from wall sconces.

**Signage vocabulary.**
`FREE HOUSE` Â· `REAL ALE` Â· `GUEST ALE` Â· `SKY SPORTS SHOWN HERE` Â· `FOOD SERVED 12â€“3, 6â€“9` Â· `LAST ORDERS` Â· `TIME, PLEASE` Â· `NO FOOTBALL COLOURS` Â· `SALOON BAR` / `PUBLIC BAR` Â· `LADIES` / `GENTS` Â· `PLEASE DRINK RESPONSIBLY`

**Social script â€” the biggest single trap in the region.**

1. **There is no table service.** You go to the bar. Sitting down and waiting is the tourist's error, and the alien has just been trained by the caff, two doors down, that sitting and waiting is exactly correct. **The rules changed between two adjacent buildings on the same street and nobody mentioned it.** This is the best single beat available in London. Build the caff first so the pub can break it.
2. **There is no queue at the bar** â€” and Britain is a country obsessed with queues. You ease forward, catch the barman's eye, and wait your turn, and everyone knows whose turn it is, and there is no line. The alien, having spent all region learning to queue, will queue at the bar, and will be served last, and will never be told why.
3. **The round.** If you drink with people, one person buys for everyone, and then the next, and everyone silently tracks it. Leaving before you have bought your round is a real offence, committed silently, punished silently. Buying a round *out of turn* is nearly as bad â€” it reads as saying you do not want to owe anyone anything, which reads as saying you do not want to be here again.
4. **Do not tip the barman.** There may be a jar. There is no obligation. The Berlin-trained instinct to round up is wrong.

**Quest hook.** The dealer holding `shard_london` should conduct business in the pub, and the price of the conversation should be **the round**. Not money â€” the alien can pay money, has learned to pay money. The price is understanding that buying the drinks is what makes the talk possible.

---

### 4.5 Police station â†’ **the nick**

**Exterior.** A solid Victorian or interwar building, red brick with stone dressings, a blue lamp on a bracket over the door â€” a glass box lantern with `POLICE` on all four faces, lit from inside. Below it, a sign with the **Sillitoe tartan**: a band of black-and-white checks. A blue-and-white sign reading `METROPOLITAN POLICE`.

**Interior.** Reuse `_dress_police()` â€” the cool palette and indifferent counter are already right. Re-dress: a **front counter** behind toughened glass with a small speaking grille, a ticket-style queue system, plastic bucket chairs bolted to a rail, a rack of leaflets in eleven languages (none of them the alien's), a poster about knife crime, a poster about bogus callers, a CCTV-in-operation notice, and a laminated sheet on the door reading `FRONT COUNTER OPEN 10AMâ€“4PM MONâ€“FRI`.

**Signage vocabulary.**
`POLICE` Â· `METROPOLITAN POLICE` Â· `FRONT COUNTER` Â· `LOST PROPERTY â€” ENQUIRIES` Â· `PLEASE TAKE A SEAT AND WAIT TO BE CALLED` Â· `IN AN EMERGENCY DIAL 999` Â· `FOR NON-URGENT MATTERS CALL 101` Â· `CCTV IN OPERATION` Â· `NO WEAPONS BEYOND THIS POINT` Â· `THIS COUNTER IS CLOSED â€” PLEASE USE THE INTERCOM`

**The difference from Berlin.** The Polizeiwache *had* the fragment and would release it to its owner on proof. The Met station does not have it and never did; it has a **record** of it â€” a crime number, a property reference, a name that leads to the dealer. London's police give you information, not objects. That keeps the fragment where it belongs (with a person, in the arches) and gives the station a real function.

**Social script.** The officer at the counter will be scrupulously polite and will help with nothing. "I'm afraid that's not something we can help you with" is a complete refusal delivered as regret. The alien will hear the regret.

---

### 4.6 Hospital â†’ **A&E**

Not *ER*, not *Notaufnahme*. **A&E** â€” Accident & Emergency. Everyone says the letters.

**Exterior.** A 1970s concrete block bolted onto a Victorian original. A blue sign with a white **H** and an arrow â€” but note: the British hospital road sign is a white `H` on blue, *not* Berlin's yellow (`H sign yellow #d8b02c` in the world palette is a Berlin colour; London's must be NHS Blue `#005eb8`). Over the entrance, a large illuminated sign in **Emergency Services Red** reading `ACCIDENT & EMERGENCY`, and beside it `24 HOURS`. Ambulance bays with yellow and green chevrons. A smoking shelter fifteen metres from the door with people in dressing gowns in it.

**Interior.** Reuse `_dress_hospital()`. Re-dress hard:

- **Reception first, triage second, waiting third, treatment fourth.** Four separate waits. Each one feels like progress and is not.
- A **digital display** showing `CURRENT WAITING TIME: 4 HRS 20 MINS`, which does not decrease.
- Rows of blue vinyl-and-steel chairs, mostly full.
- A vending machine. A children's play corner with three toys. A TV bolted high in a corner showing the news with subtitles and no sound.
- Blue-and-white NHS wayfinding everywhere, in Frutiger, immaculately designed, pointing at departments that are all closed.

**Signage vocabulary.**
`ACCIDENT & EMERGENCY` Â· `A&E` Â· `24 HOURS` Â· `MINOR INJURIES UNIT` Â· `URGENT TREATMENT CENTRE` Â· `PLEASE BOOK IN AT RECEPTION` Â· `TRIAGE` Â· `CURRENT WAITING TIME` Â· `THIS IS AN EMERGENCY DEPARTMENT â€” PATIENTS ARE SEEN IN ORDER OF CLINICAL NEED, NOT ARRIVAL` Â· `PLEASE DO NOT ABUSE OUR STAFF` Â· `AMBULANCES ONLY` Â· `NO ENTRY` Â· `WARD 6 â€” VISITING 2â€“4PM & 6â€“8PM`

**The lesson.** *"Seen in order of clinical need, not arrival."* â€” Britain queues for everything, obsessively, morally. And then in the one building where the stakes are highest, it publicly abolishes the queue. The alien has just spent the whole region learning that the queue is sacred. Here it is not. **The rule is not the rule everywhere, and nobody flags the exception.**

**Berlin's clinic removed a fragment from the alien's body.** London's A&E must not repeat that. Use it instead as the place where the alien learns what *waiting* means socially: four hours in a chair, surrounded by people, being spoken to kindly by nobody in particular.

---

### 4.7 Airport â†’ **Heathrow**

The alien's arrival plate, and the region's opening shot.

**Exterior / airside.** Grey-green carpet, back-lit signage, a long walk. Everything in the same clean typeface. Yellow directional signs overhead.

**Interior.** Extend `_dress_airport()`. The beats:

- **A queue with rope barriers**, snaking, orderly, silent. The first thing the region shows the player is Britain queueing. Do not open on anything else.
- **Border Force desks** and **e-gates**. A sign splitting the queue into categories the alien cannot classify themselves under.
- The **retractable belt barrier** â€” a physical object that draws a line on the floor and is universally obeyed despite being defeatable by a toddler.
- Duty free forcing a path through perfume before you reach the gate.
- A carousel. A single unclaimed bag going round.

**Signage vocabulary.**
`ARRIVALS` Â· `DEPARTURES` Â· `BAGGAGE RECLAIM` (not *claim*) Â· `WAY OUT` Â· `TOILETS` (not *restroom*) Â· `LIFT` (not *elevator*) Â· `TROLLEYS` Â· `NOTHING TO DECLARE` / `GOODS TO DECLARE` Â· `UK BORDER` Â· `ALL PASSPORTS` Â· `PLEASE HAVE YOUR PASSPORT OPEN AT THE PHOTO PAGE` Â· `QUEUE THIS SIDE` Â· `ONE METRE APART` Â· `NO ENTRY â€” DO NOT RE-ENTER` Â· `HEATHROW EXPRESS` Â· `TAXIS` Â· `COACHES`

**The vocabulary lesson.** Berlin's signs were unreadable and the alien learned them as shapes. London's signs are *readable and wrong* â€” the alien knows the word `exit` and London says `WAY OUT`; knows `elevator` and London says `LIFT`; knows `bathroom` and London says `TOILETS`. **Every one of these should render as fully legible text that the alien's journal notes it does not recognise.** That is a beautiful, cheap, exactly-on-theme effect and it costs one flag.

**Social script.** The Border Force officer asks three questions in a flat tone. *"What's the purpose of your visit?"* The correct answer is short. Any answer longer than eight words reads as evasion. Berlin rewarded elaboration; London punishes it.

---

## 5. The language mechanic â€” **Accents and Speed**

This is the region's system, and it is the thing that must be *built*, not reskinned.

### 5.1 The principle

In Berlin, meaning is hidden in the **word**. In London, meaning is hidden in three other places:

1. **The surface form.** The alien knows *have*. It does not know *'ave*. It knows *is not*. It does not know *ain't*. It knows *do not know*. It does not know *dunno*.
2. **The speaker.** Ears are earned one person at a time. Understanding Dot at the caff does not help you understand the dealer under the arches.
3. **The gap between the words and the meaning.** *"Not bad"* is four fully legible characters of nothing.

### 5.2 The three render states

Berlin has four tiers of one axis. London has three *states*, which is a different shape and should be felt as one.

**PLAIN.** Fully legible. The player reads it and it means what it says.

**BROKEN.** Legible words with holes punched in them. **Not a wall of glyphs.** This is the crucial visual difference from Berlin: in Berlin, unknown text is solid fog. In London, unknown text is *mostly readable with the important bits missing*, which is far more maddening and far more true. Function words survive (they are unstressed, short, and the same in every accent); stressed content words and contracted forms go. What the player sees is the *shape* of a sentence they cannot use.

> `"Nah â¬¡âŸ¢â‹„, he âŸ¦âŸ§â¬£'â‹„ been in â¬¢âŸ£âŸ¤âŸ¥ â€” you âŸŸâ¬¡âŸ¢â‹„ â‹„âŸ¤ â¬ âŸ¦âŸ§?"`

**FALSE-CLEAR.** Every word renders in `PLAIN`. The journal records a literal reading. The literal reading is wrong, and the player will act on it. This state has **no visual marker whatsoever** â€” that is the entire point, and it is where London earns the game's thesis. The only tell is retrospective: the journal entry, later, gets a second line struck through and rewritten.

### 5.3 Implementation, against what already exists

The existing machinery does not need changing. It needs *feeding differently*.

`GameState.familiarity` is `{language: {word: 0-100}}` and `get_tier()` reads it. London uses the same store with two key conventions:

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

- A **familiar speaker** speaking **standard English slowly** â†’ everything PLAIN.
- The **same speaker** dropping into slang â†’ the content words fall out even though you know the person. *You know their voice and not their words.*
- A **stranger** speaking **perfect standard English** â†’ still partly BROKEN the first time, because you have not tuned to them yet. *You know the words and not their voice.*

That symmetry is the whole mechanic and it is worth protecting.

**Exposure.** `EXPOSURE_GAIN` already has `hear / pointed / used / read`. London adds gain to `"@speaker"` on every line heard from them â€” so the mechanic rewards **staying in one conversation** rather than sampling the crowd. Berlin rewarded breadth; London rewards depth. Reflect this in the Tube: forty people, zero eye contact, zero gain. The alien cannot farm a city that will not look at them.

**Journal.** `WORD_GUESSES` gains English surface forms. The voice must match Berlin's â€” a guess, with visible uncertainty, occasionally wrong on purpose:

```
"'ave":     'â€” "have"?  he swallowed the front of it',
"innit":    'â€” a question glued to the end of a sentence. Always the same shape.',
"mate":     'â€” "friend"?  he calls everyone this, including the man he shouted at',
"alright":  'â€” not a question about my condition. I keep answering it wrongly.',
"sorry":    'â€” excuse me / move / no / I heard you / I am sorry.  (all of them)',
"cheers":   'â€” "thank you"?  also "goodbye"?  also raising a glass?',
"proper":   'â€” "very".  nothing to do with correctness',
"quid":     'â€” one pound.  never pluralised.  "five quid", not "five quids"',
"bruv":     'â€” "brother"?  they are not brothers',
"tenner":   'â€” ten pounds.  they have a word for each amount',
```

### 5.4 The eighteen lines

Escalating. `R` = register, `S` = speed. Glyph runs use the project's `GLYPHS_FULL` set, `â—ˆâŸŸâ¬¡â—‰âŸ¢âŸ£â‹„âŸ¤âŸ¥â¬¢â¬£â¬Ÿâ¬ âŸ¦âŸ§âŸ¡`, at matching character length.

---

**Ladder 1 â€” clear words, hidden meaning. (FALSE-CLEAR.)**
*These render perfectly. That is the trap.*

**1.** `R0 S0` â€” B&B reception, first line in the region.
> **Renders:** "You alright?"
> **Alien reads:** *Am I injured? Does she know about the crash?*
> **Means:** Hello.
> *The player will answer this with a status report. Let them.*

**2.** `R0 S0` â€” the caff, after the alien tries the tea.
> **Renders:** "Not bad, is it."
> **Alien reads:** *Mediocre. She is disappointed.*
> **Means:** That's excellent.
> *Note it is not even a question. The rising tone is absent in text â€” and the alien cannot hear tone. This is the purest expression of the thesis available.*

**3.** `R0 S0` â€” the Border Force officer, on being handed a long explanation.
> **Renders:** "Right. And how long are you staying?"
> **Alien reads:** *He agreed with me and is now interested in my plans.*
> **Means:** Stop talking. Answer the question I already asked.
> *"Right." is a full stop wearing a smile.*

**4.** `R0 S0` â€” the police front counter.
> **Renders:** "I'm afraid that's not something we can help you with."
> **Alien reads:** *He is frightened. Perhaps he can help unofficially.*
> **Means:** No. Go away.

**5.** `R1 S0` â€” a neighbour on the Terrace plate, in the rain.
> **Renders:** "Lovely weather for it."
> **Alien reads:** *He approves of the weather.*
> **Means:** This weather is appalling and I am acknowledging that you exist.
> *Weather talk is not about weather. It is a handshake with words in it.*

**6.** `R0 S0` â€” the pub, after the alien buys a drink for himself only.
> **Renders:** "No, you're alright."
> **Alien reads:** *He confirms I am well.*
> **Means:** No thank you â€” and also, you have just done something wrong.

---

**Ladder 2 â€” the ear starts to slip. (BROKEN, lightly.)**
*Contractions and elisions. Grammar survives; the swallowed bits do not.*

**7.** `R1 S1` â€” the caff.
> **Renders:** "Y'â¬¡âŸ¢âŸ£â¬Ÿâ¬£â¬ , love? What â¬¢âŸ¤â¬¡ I âŸ¦âŸ§â‹„ you?"
> **Means:** "Y'alright, love? What can I get you?"
> *`love` renders plain and is the more alarming half. It is not affection.*

**8.** `R1 S1` â€” a man on the High Street plate, blocking the pavement.
> **Renders:** "â¬¡âŸ¢âŸ£âŸ¤â¬¢ mate, â¬ âŸ¦âŸ§ â‹„âŸ¤â¬£ me."
> **Means:** "Sorry mate, 'scuse me."
> *`sorry` here means "move". It is the second of its five faces.*

**9.** `R2 S1` â€” the market, a stallholder.
> **Renders:** "âŸŸâ¬¡âŸ¢â‹„ a âŸ¦âŸ§â¬£â¬ âŸ¤âŸ¥'â¬¢ at â‹„â¬¡âŸŸâ‹„, go on."
> **Means:** "Have a butcher's at that, go on."
> *Rhyming slang: `butcher's hook` â†’ `look`, then the rhyming half is deleted. Even at full familiarity the phrase does not decode from its parts. This is the region's proof that vocabulary is not comprehension.*

**10.** `R2 S1` â€” the pub, a regular, unprompted.
> **Renders:** "He's â¬¡âŸ¢ his âŸ¦â§§â¬£â¬  âŸŸâ¬¡âŸ¤â‹„âŸ¥ again, poor sod."
> **Means:** "He's on his Jack Jones again, poor sod." â€” He's alone again.
> *`poor sod` renders plain and is sympathy. The alien will read it as insult.*

---

**Ladder 3 â€” the ear fails. (BROKEN, heavily.)**
*Content words gone. Only scaffolding left.*

**11.** `R3 S1` â€” under the arches, a lookout.
> **Renders:** "â¬¢âŸ¤â¬¡âŸ¢âŸ£â¬ , you âŸ¦â§§â¬£ â‹„âŸ¤ â¬¡âŸ¢âŸ£ â¬ âŸ¦âŸ§, âŸŸâ¬¡â¬¢âŸ¢â‹„?"
> **Means:** "Wagwan, you here to see the man, innit?"

**12.** `R3 S1` â€” two teenagers on the top deck of the bus.
> **Renders:** "âŸ¢âŸ£â‹„ â¬ âŸ¦âŸ§'â¬¢ âŸŸâ¬¡â¬£ â¬ âŸ¤â¬¡âŸ¥, â‹„â¬¢âŸ¢ âŸ¦â§§â¬£â¬  â‹„â¬¡âŸŸ."
> **Means:** "Man's bare tired, my ends is long." â€” I'm exhausted, my neighbourhood is far away.
> *`man` is a first-person pronoun here. That single fact should be a journal entry all of its own.*

**13.** `R3 S2` â€” the dealer, testing whether the alien is worth talking to.
> **Renders:** "âŸŸâ¬¡âŸ¢â‹„'â¬¢ it â¬ âŸ¦â§§ me â‹„âŸ¤â¬£, âŸ¥âŸ¦â§§? âŸ¢âŸ£â¬¡â¬  â‹„âŸ¤ me â¬¢âŸ¤â¬¡âŸŸâ‹„."
> **Means:** "What's it worth to you, though? Talk to me straight."
> *He is not being hostile. He is checking. The alien cannot tell.*

**14.** `R3 S2` â€” a bus driver, through glass, to a queue of eleven.
> **Renders:** "âŸ¦â§§â¬£â¬  â¬¡âŸ¢âŸ£ â‹„âŸ¤â¬¢, âŸŸâ¬¡â¬  â¬¢âŸ¤â¬¡âŸ¥â‹„ âŸ¦â§§, â‹„â¬¡âŸ¢â¬ â¬£ âŸ¤âŸ¥."
> **Means:** "Move down inside, this bus ain't moving, thank you."
> *Everyone else complies instantly. The alien does not move. Everyone notices.*

**15.** `R4 S2` â€” the market at full volume, three voices overlapping.
> **Renders:** "â¬¢âŸ¤â¬¡âŸ¢ âŸ¦â§§â¬£ â¬ âŸ¤âŸ¥ â€” âŸŸâ¬¡â¬¢ â‹„âŸ¤â¬£â¬  âŸ¦â§§ â€” â¬¡âŸ¢âŸ£â‹„âŸ¤ â¬¢âŸ£â¬ âŸ¦ âŸ¥â§§â¬£!"
> **Means:** Unrecoverable, and *intended* to be. Three people are selling three things and none of it was addressed to you.
> *`R4` lines have no plain meaning in the journal â€” only a note about rhythm. The alien records: "Fast, and not for me. I think that is most of it."*

---

**Ladder 4 â€” the words come back, the meaning does not. (FALSE-CLEAR again.)**
*Placed after the hardest lines on purpose. The player has just spent an hour fighting for legibility, wins it, and discovers it bought them nothing.*

**16.** `R0 S0` â€” the dealer, once the alien has earned his ear, holding the shard.
> **Renders:** "I'm not being funny, but that's a lot of money to me."
> **Alien reads:** *He is being serious, and he is poor. He wants money.*
> **Means:** I am about to say something you will not like. The price has gone up.
> *"I'm not being funny, but" is a warning light, not a disclaimer.*

**17.** `R0 S0` â€” the same conversation, three lines later.
> **Renders:** "Yeah, no, I hear you."
> **Alien reads:** *Yes and no. Confusing. But he is listening.*
> **Means:** No. I have listened and I am declining.
> *`Yeah, no` = no. `No, yeah` = yes. Both are one word long and the wrong one.*

**18.** `R0 S0` â€” the last line the dealer says, after the round is bought.
> **Renders:** "Go on then. But you never got it off me, alright?"
> **Alien reads:** *A command, then a denial of a transaction that occurred.*
> **Means:** Yes. Take it. And do not name me.
> *`Go on then` is consent given as reluctance, which is how this city gives consent. The alien has to learn that being talked out of something and being given it look identical from outside.*

### 5.5 The five faces of *sorry*

The alien meets `sorry` in the first minute and it renders PLAIN every time. It is one word with an unstable meaning, which is the exact inverse of Berlin's many words with stable ones. Build a journal page that accumulates:

| Said as | Actually means | Where the alien meets it |
|---|---|---|
| "Sorry â€”" *(rising, before speech)* | Excuse me, I am about to speak to you | shop, bureau, ticket hall |
| "Sorry." *(flat, while moving)* | Get out of my way | High Street pavement |
| "Sorry?" *(rising, alone)* | I did not hear you, repeat it | the caff, over noise |
| "Sorry, no." | Absolutely not, and I resent being asked | police front counter |
| "*I'm* sorry." *(stressed)* | Actual regret. The rarest one. | A&E, once, quietly |

And the sixth, which is the one that breaks the alien: **the person you walked into says it to you.** Being apologised to for your own error is not sarcasm and is not weakness. It is the city closing an awkward moment as fast as possible so that neither of you has to stand in it.

---

## 6. The social script, and how to fail it

Each of these should be a **playable failure with a silent consequence** â€” no error message, no red text, no NPC explaining the rule. London does not tell you. That is the region's contract with the player.

**Queueing.** The queue is a moral object. It is single-file, it is invisible (no rope, no markings, it is simply *known*), and it is respected absolutely. Joining it wrongly does not produce shouting; it produces a silence with a particular texture, and someone saying "sorry, I think there's a queue" in the mildest voice available. *Consequence:* served last, reputation down, nobody explains.
**And then:** the bar has no queue, and A&E abolishes the queue by policy. Two exceptions to a sacred rule, both unmarked.

**Apologising.** Under-apologising reads as aggression. The alien must learn to say sorry for things that are not their fault, including being walked into. A dialogue response tagged `sorry` should become available early and should be correct startlingly often. It is the region's universal lubricant.

**The weather.** Small talk about weather is not information exchange and not enthusiasm. It is a **low-stakes opening move** â€” a sentence with no content, so that the other person can decline it without cost. The alien, trained in Berlin to seek meaning in every utterance, will search this for meaning and find none, and conclude the speaker is stupid. They are not. They are being careful. *Correct response:* agree, add nothing, move on.

**Eye contact on the Tube.** Do not. In Berlin, looking at a face gained familiarity. On the Tube, looking gains nothing and costs reputation. The player will try it, because the game trained them to. That is the design.

**The round.** See Â§4.4. Buying for the group is not generosity; it is membership. Refusing to be bought for is not modesty; it is a refusal to be owed, and therefore a refusal of the relationship. The dealer will not sell to someone who will not be owed anything.

**Volume.** The alien's dialogue style tags â€” `formal / direct / gesture / indirect` (`#5a52cc / #1e9482 / #b8701e / #2e70b8` in the world palette) â€” should reweight in London. `direct` was efficient in Berlin and is *rude* here. `indirect` was evasive in Berlin and is *correct* here. Same button, inverted meaning, no notification. The player discovers it from reputation drift.

**Thank you.** London says thank you at a rate the alien will find deranged: to the bus driver on the way off, to the machine that dispensed the ticket, to the person who held the door, twice. Under-thanking is the most common way to be quietly disliked.

---

## 7. Build notes

Static observations from the codebase. Nothing here has been run.

- **`scenes/ui/MapView.gd` is Berlin-only.** It has `_draw_kiez_map`, `_draw_mitte_map`, `_draw_ost_map`, `_draw_lobby_map`, `_draw_hotel_floor_map`, `_draw_room_map`, `_draw_interior_map` and no city dispatch. Adding London needs a city-level branch. This file was mid-edit when the previous session was cut off â€” **read it before trusting it.**

- **`GameState.reputation`** is `{"kiez", "mitte", "prenzlberg"}` â€” Berlin districts only. London needs its own keys. `REP_LEVELS` strings ("practically a neighbour", "that odd one") are Berlin-voiced and warm; London's ladder should be cooler and more oblique â€” *"someone they've seen before"*, *"not from round here"*.

- **`GameState.UBAHN_FARE`** is a flat 3. The Tube's tap-in/tap-out charging (Â§4.3) cannot use it as-is.

- **`WorldArt.TILE_*`** has no London-appropriate ground tile. `TILE_SIDEWALK` is Berlin-grey. A `TILE_YORKSTONE` / `TILE_TARMAC_WET` pair would earn its place; the `TILE_FALLBACK` array must gain matching entries **in the same order** or every index after the insertion point shifts.

- **`InteriorBackground.gd`** is 393 lines with six rooms. Adding seven London rooms will push it past the 800-line ceiling in the project's own style rules. **Split it now**, before writing London: `InteriorBackground.gd` keeps the dispatch, `InteriorRoomsBerlin.gd` and `InteriorRoomsLondon.gd` hold the dressing. `InteriorArt.gd`'s static helpers stay shared â€” they are already the right abstraction.

- **GDScript, from this project's own scar tissue:** do not use `:=` to infer from a `Dictionary`/`Array` subscript, from `.get()`, or from a multi-part boolean. The London line struct is all dictionary reads â€” annotate every one: `var register: int = line.get("register", 0)`. Files are **tab-indented.**

- **Nothing above has been tested.** Godot is not on PATH in this environment.

---

## 8. The one-line brief

> **Berlin was a wall you learned to read. London is a door that is already open, and you still cannot get through it, and everyone is being very nice about it.**

---

## Sources

Architecture and materials: [London yellow stock brick](https://buildinglondon.blog/2022/07/12/41-londons-canary-yellow-stock-brick/) Â· [Reclaimed vs new London stocks](https://architecturemagazine.co.uk/2024/12/05/reclaimed-vs-new-london-yellow-stock-bricks/) Â· [Victorian architectural detailing](https://www.nancygouldstone.com/blog/victorian-architectural-detailing) Â· [London plane tree](https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/british-trees/a-z-of-british-trees/london-plane/) Â· [London Museum on planes](https://www.londonmuseum.org.uk/collections/london-stories/whats-london-plane-tree/)

Colour specifications: [TfL Colour Standard](https://content.tfl.gov.uk/tfl-colour-standard.pdf) Â· [BS381C-538 Post Office Red](https://encycolorpedia.com/a23b3c) Â· [Red telephone box history](https://gilbertscott.org/buildings/red-telephone-box) Â· [London Underground line colours](https://londonmymind.com/london-tube-colors/) Â· [NHS Identity colours](https://www.england.nhs.uk/nhsidentity/identity-guidelines/colours/) Â· [NHS exterior signage](https://www.england.nhs.uk/nhsidentity/examples/nhs-exterior-signage/)

Street furniture and signage: [TfL bus stop graphics standard](https://content.tfl.gov.uk/buses-bus-stop-graphics-standard-issue02.pdf) Â· [Evolution of the roundel](https://www.ltmuseum.co.uk/collections/stories/design/evolution-roundel) Â· ["Way out" vs "exit"](https://www.railforums.co.uk/threads/why-do-we-use-way-out-instead-of-exit.66579/) Â· [UK toilet signage](https://zerosigns.co.uk/toilet-bathroom-door-signs-explained-meanings-types-uses-uk/) Â· [Heathrow signs explained](https://www.airporttohome.co.uk/post/heathrow-airport-signs-explained)

Interiors and institutions: [London's greasy spoons](https://londonist.com/london/inside-london-s-most-beautiful-greasy-spoon-cafe) Â· [Regency CafÃ©](https://www.timeout.com/london/restaurants/londons-best-greasy-spoon-cafes) Â· [Bureau de change in London](https://www.visitlondon.com/traveller-information/essential-information/money/bureau-de-change) Â· [Bureau de change spreads](https://en.wikipedia.org/wiki/Bureau_de_change)

Language: [Multicultural London English](https://britishslangdictionary.net/modern-multicultural-london-english-mle-explained/) Â· [MLE features and roots](https://londonwebcam.co.uk/blog/what-multicultural-london-english-is/) Â· [Cockney rhyming slang](https://www.londonschool.com/blog/cockney-rhyming-slang/) Â· [Rhyming slang (Wikipedia)](https://en.wikipedia.org/wiki/Rhyming_slang) Â· [Cockney phonology](https://cockneydialect.wordpress.com/2017/06/18/features/) Â· [Traditional Cockney and popular London speech](https://www.raco.cat/index.php/Dialectologia/article/download/259233/346495/0)

Social scripts: [British understatement translator](https://simslife.co.uk/british-understatement-translator/) Â· [What the British say and what they mean](https://katharinewrites.com/language/what-the-british-say-and-what-they-mean/) Â· [Britons use "sorry" 15 ways](https://www.aol.com/news/britons-sorry-15-different-ways-152741311.html) Â· [Brits say sorry eight times a day](https://hrnews.co.uk/the-average-brit-says-sorry-4380-times-every-year-according-to-new-research/) Â· [Debrett's pub etiquette](https://debretts.com/pub-etiquette/) Â· [British pub rules](https://www.cnn.com/travel/british-pubs-rules-etiquette-beer) Â· [Tube etiquette](https://londonmymind.com/london-tube-etiquette/) Â· [Unwritten rules of the Underground](https://www.adaminsights.com/the-unwritten-rules-of-the-london-underground-a-newbies-guide/)

### Findings

- **[high] C:/Users/gulci/Downloads/foreigntoall/scenes/ui/MapView.gd** — Berlin-only and was mid-edit when the previous session died to a usage limit. It defines _draw_kiez_map / _draw_mitte_map / _draw_ost_map / _draw_lobby_map / _draw_hotel_floor_map / _draw_room_map / _draw_interior_map with no city-level dispatch. London and Istanbul have no representation, and the file's current state is unverified â€” it may be half-finished.
  - Fix: Read the whole file before trusting or extending it. Then add a city-level branch (read GameState.CITIES / current city) above the existing per-scene draw dispatch, so each region supplies its own set of map draw functions rather than growing one flat match statement.
- **[high] C:/Users/gulci/Downloads/foreigntoall/scenes/world/InteriorBackground.gd** — 393 lines already, carrying six Berlin rooms in one _draw() match. London needs roughly seven more rooms (bureau, nick, ae, caff, tube, terminal, b_and_b), and Istanbul another set. Adding them in place pushes the file well past the project's own 800-line ceiling.
  - Fix: Split before writing any London art: keep the room dispatch in InteriorBackground.gd, move the Berlin dressing functions to InteriorRoomsBerlin.gd and write London's into InteriorRoomsLondon.gd. InteriorArt.gd's static helpers (shell, floor_tiles, counter, glass_screen, notice, exit_door) stay shared â€” that abstraction is already correct and should not be duplicated.
- **[high] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — reputation is hardcoded to the three Berlin districts {"kiez", "mitte", "prenzlberg"}. London street plates have no reputation key to write to, so any London social-script consequence (queue-jumping, staring on the Tube, refusing a round) has nowhere to land.
  - Fix: Add London district keys alongside the Berlin ones. Also add a London-specific REP_LEVELS ladder â€” the existing strings ("practically a neighbour", "that odd one") are warm and Berlin-voiced; London's should be cooler and more oblique ("someone they've seen before", "not from round here").
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — The familiarity model is strictly per-word: familiarity[language][word] with get_tier() reading fixed 25/50/80 thresholds. London's locked-in design is per-SPEAKER familiarity plus per-line register/speed, which has no representation at all.
  - Fix: No schema change is needed â€” reuse familiarity["english"] with two key conventions: surface forms as their own entries ("'ave" is a different key from "have", which IS the accent mechanic), and an "@" prefix for speaker ease ("@dealer") which cannot collide with a real word so save/load stays untouched. Add one speaker_gate(id) -> int helper and resolve a word as min(word_tier, speaker_gate - register - speed), clamped to TIER_UNKNOWN.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/scenes/dialogue/DialogueBox.gd** — _render_word() has no path for a line that is fully legible yet semantically wrong. London's central mechanic (the alien reads "Not bad" perfectly and acts on it incorrectly) requires a FALSE-CLEAR state that renders identically to TIER_KNOWN with no visual marker whatsoever.
  - Fix: Add a per-line false_clear flag that short-circuits to the TIER_KNOWN render branch regardless of familiarity. Critically, it must add no colour, underline, or bgcolor tell â€” the only feedback is retrospective, via a journal entry that later gets struck through and rewritten.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — UBAHN_FARE is a flat 3 charged on a single action. The London Underground charges on tap-out, by zone, with a penalty fare for failing to tap out â€” a rule with no analogue in the Berlin implementation.
  - Fix: Do not reuse UBAHN_FARE for London. Add a separate tap-in/tap-out flow in Services.gd that records the entry station, charges on the second tap, and applies a penalty when the player leaves the region without tapping out.
- **[medium] C:/Users/gulci/Downloads/foreigntoall/autoload/WorldArt.gd** — TILE_FALLBACK is a positional array indexed by the TILE_* constants, and every ground tile in it is tuned to Berlin's indigo-grey. There is no York-stone pavement or wet-tarmac tile for London.
  - Fix: Append new tile ids at the END of both the TILE_* constant block and the TILE_FALLBACK array â€” never insert in the middle, or every index after the insertion point silently shifts and repaints existing Berlin scenes. Suggested additions: TILE_YORKSTONE (#4b4a46) and TILE_TARMAC_WET (#33353c).
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/GameState.gd** — The four dialogue style tags (formal/direct/gesture/indirect, coloured #5a52cc/#1e9482/#b8701e/#2e70b8) carry Berlin's social weighting. In London the polarity inverts â€” 'direct' reads as rude and 'indirect' reads as correct â€” but nothing in the data model is region-aware.
  - Fix: Make the reputation delta for a style tag a function of the current region rather than a constant. The player should get no notification of the inversion; they discover it from reputation drift, which is the region's design contract.
- **[low] C:/Users/gulci/Downloads/foreigntoall/autoload/Services.gd** — JOBS entries are Berlin-flavoured in both prose and targets (the bread man at the field market, the U-Bahn platform, the restaurant kitchen). London needs its own board, and the pub round-buying beat that gates shard_london is a money sink with no existing service hook.
  - Fix: Add a London JOBS set with its own giver/where strings in the same voice, and a new service hook for buying a round at the bar. The round is the price of the dealer conversation â€” it must be a distinct action from paying money, because the lesson is that money alone does not buy the talk.

