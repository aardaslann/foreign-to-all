extends SceneTree

# Can every job actually be done?
#
#   <godot> --headless --path . --script res://tools/work.gd
#
# Taking a job used to BE the job: the board handed you a card, you walked to
# the ServicePoint it named, and the money appeared. There was nothing to get
# wrong, so there was nothing to test. Now each one is a loop with hands in it
# - take a load, carry it, set it down, N times, then go back and be paid - and
# every one of those steps is somewhere a job can get stuck with no way out.
#
# So this walks each job the way a player would, and checks the things a player
# would notice: that the site is a real scene, that the load can be drawn, that
# the trips count, that the money only lands at the end, and that the log
# agrees with the world at every step.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")

var _fails: int = 0
var _checked: int = 0


func _initialize() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	var sv: Node = root.get_node_or_null("Services")
	if gs == null or sv == null:
		print("no autoloads; run with --path .")
		quit(1)
		return

	print("")
	print("Foreign to All - the work")
	print("")

	var jobs: Dictionary = sv.get("JOBS")
	for id: String in jobs.keys():
		_walk(gs, sv, id, Dictionary(jobs[id]))

	print("")
	print("%d checks, %d failures" % [_checked, _fails])
	quit(1 if _fails > 0 else 0)


func _walk(gs: Node, sv: Node, id: String, job: Dictionary) -> void:
	print("-- %s" % String(job.get("title", id)))
	gs.call("reset")

	# Every job says where it is, and the scene exists.
	var where: String = String(sv.call("job_scene", id))
	_check(not where.is_empty(), "%s: has a job site" % id, where)
	_check(ResourceLoader.exists(where), "%s: the site is a real scene" % id,
		where)

	# It says what it is carried as, and CharacterArt can draw that.
	var load_id: String = String(sv.call("job_load", id))
	_check(CHAR.PROPS.has(load_id), "%s: the load can be drawn" % id, load_id)

	var reps: int = int(sv.call("job_reps", id))
	_check(reps >= 1, "%s: takes at least one trip" % id, "%d trips" % reps)

	# Taking it opens a quest with somewhere to go.
	gs.call("accept_job", id)
	sv.call("open_job_quest", id)
	var quests: Dictionary = gs.get("quests")
	_check(quests.has("job_" + id), "%s: goes in the log" % id, "")
	_check(String(gs.call("quest_target")) == where,
		"%s: the arrow has somewhere to point" % id,
		String(gs.call("quest_target")))

	# Now do the work. Take, carry, set down, until it is finished.
	var money_before: int = int(gs.get("money"))
	for trip in range(reps):
		_check(String(gs.get("carrying")).is_empty(),
			"%s: hands empty before trip %d" % [id, trip + 1], "")
		gs.call("carry_load", load_id)
		sv.call("settle_job_quest")
		_check(String(gs.get("carrying")) == load_id,
			"%s: carrying on trip %d" % [id, trip + 1], load_id)
		gs.call("drop_load")
		sv.call("settle_job_quest")
	_check(int(gs.get("job_progress")) == reps,
		"%s: every trip counted" % id,
		"%d/%d" % [int(gs.get("job_progress")), reps])
	_check(int(gs.get("money")) == money_before,
		"%s: nothing paid before it is handed in" % id,
		"%d" % int(gs.get("money")))

	# And handing it in at the counter that gave it out pays, once.
	gs.call("complete_last_step", "job_" + id)
	gs.call("finish_job", id, int(job.get("pay", 0)))
	_check(int(gs.get("money")) == money_before + int(job.get("pay", 0)),
		"%s: paid on hand-in" % id, "+%d" % int(job.get("pay", 0)))
	_check(String(gs.get("active_job")).is_empty(),
		"%s: the job is over" % id, "")
	_check(String(gs.get("carrying")).is_empty(),
		"%s: hands empty afterwards" % id, "")
	var q: Dictionary = quests["job_" + id]
	_check(bool(q.get("completed", false)),
		"%s: the log agrees it is finished" % id, "")
	_reliability(gs, sv, id)
	print("")


# Doing it again is worth more than doing it once.
#
# The other half of this game's argument: everything else earns standing by
# saying the right thing, and none of that is available to somebody who
# arrived yesterday. Turning up is. So the same job done three times has to be
# worth visibly more the third time, and it has to keep being worth something
# rather than running away to infinity.
func _reliability(gs: Node, sv: Node, id: String) -> void:
	var region: String = String(gs.get("current_region"))
	var first: int = int(gs.call("work_standing", 0))
	var third: int = int(gs.call("work_standing", 2))
	_check(third > first,
		"%s: the third time is worth more than the first" % id,
		"+%d then +%d" % [first, third])
	_check(first > 0, "%s: even the first time is worth something" % id,
		"+%d" % first)
	_check(int(gs.call("work_standing", 99)) <= 8,
		"%s: and it does not run away" % id,
		"+%d" % int(gs.call("work_standing", 99)))

	# And walk it: three finished jobs, the gain never shrinking.
	var reps: Dictionary = gs.get("reputation")
	var before: int = int(reps.get(region, 0))
	var last_gain: int = 0
	var rising: bool = true
	for run in range(3):
		var at: int = int(Dictionary(gs.get("reputation")).get(region, 0))
		gs.call("accept_job", id)
		sv.call("open_job_quest", id)
		for _t in range(int(sv.call("job_reps", id))):
			gs.call("carry_load", String(sv.call("job_load", id)))
			gs.call("drop_load")
		gs.call("finish_job", id, 0)
		var gain: int = int(Dictionary(gs.get("reputation")).get(region, 0)) - at
		if run > 0 and gain < last_gain:
			rising = false
		last_gain = gain
	_check(rising, "%s: being asked again keeps being worth more" % id, "")
	var after: int = int(Dictionary(gs.get("reputation")).get(region, 0))
	_check(after > before,
		"%s: three jobs move his standing in the district" % id,
		"%d -> %d" % [before, after])


func _check(ok: bool, what: String, detail: String) -> void:
	_checked += 1
	if not ok:
		_fails += 1
	var mark: String = "  ok  " if ok else " FAIL "
	print("%s%-48s %s" % [mark, what, detail])
