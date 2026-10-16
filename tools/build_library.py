#!/usr/bin/env python3
"""Generates KBWorkout/Resources/library.json — the exercise and workout library.

Edit this file to add or change workouts, then run:  python3 tools/build_library.py
It prints each workout's estimated length so you can keep them around 30 minutes.
"""
import json
import pathlib

OUT = pathlib.Path(__file__).resolve().parent.parent / "KBWorkout" / "Resources" / "library.json"

# ---------------------------------------------------------------------------
# Exercises. sec = estimated seconds per rep, used to estimate workout length.
# ---------------------------------------------------------------------------
E = []
def ex(id, name, symbol, summary, cues, sec=3):
    E.append(dict(id=id, name=name, symbol=symbol, summary=summary, cues=cues, secondsPerRep=sec))

HINGE, SQUAT, PRESS, PULL = ("figure.strengthtraining.functional", "figure.cross.training",
                             "figure.strengthtraining.traditional", "figure.strengthtraining.traditional")
CORE, MOB, CARDIO = "figure.core.training", "figure.flexibility", "figure.highintensity.intervaltraining"

# Warm-up / mobility
ex("halo", "Halo", "figure.mind.and.body", "Circle the bell around your head to open the shoulders and upper back.",
   ["Hold the bell upside down by the horns", "Keep it close to your head", "Squeeze glutes, brace the core", "Switch direction each lap"])
ex("glute_bridge", "Glute Bridge", "figure.pilates", "Wakes up the glutes before hinging.",
   ["Feet flat, knees bent", "Drive through the heels", "Squeeze hard at the top", "Ribs down, don't arch the low back"], 2)
ex("hip_hinge", "Hip Hinge Drill", MOB, "Bodyweight hinge to groove the swing and deadlift pattern.",
   ["Push hips back like closing a car door", "Soft knees, flat back", "Feel the hamstrings load", "Stand tall by squeezing the glutes"])
ex("prying_squat", "Prying Goblet Squat", SQUAT, "Sit in the bottom of a goblet squat and gently pry the hips open.",
   ["Bell at the chest", "Elbows inside the knees", "Shift side to side slowly", "Chest proud"])
ex("hip_flexor_stretch", "Half-Kneeling Hip Flexor Stretch", "figure.cooldown", "Opens the front of the hips after hinging.",
   ["Kneel on one knee", "Tuck the pelvis, squeeze the back glute", "Reach the same-side arm overhead"])
ex("hamstring_stretch", "Hamstring Stretch", MOB, "Gentle standing or seated hamstring stretch.",
   ["Hinge from the hips", "Long spine", "Breathe slowly into the stretch"])
ex("childs_pose", "Child's Pose", "figure.yoga", "Relax the back and shoulders.",
   ["Knees wide, hips to heels", "Reach the arms long", "Slow breathing through the nose"])
ex("crocodile_breathing", "Crocodile Breathing", "figure.mind.and.body", "Face-down belly breathing to bring the heart rate down.",
   ["Forehead on your hands", "Breathe in through the nose for 4", "Feel your belly press into the floor", "Long slow exhale"])

# Hinge
ex("swing", "KB Swing (2-hand)", HINGE, "The foundation of kettlebell training: explosive hip power for strength and conditioning.",
   ["Hike the bell back high between the legs", "Snap the hips, squeeze the glutes", "Bell floats to chest height; arms are ropes",
    "Stand up tall at the top", "Keep it dynamic, control the bell"], 2)
ex("one_arm_swing", "One-Arm Swing", HINGE, "A swing with one hand: more grip and anti-rotation core work.",
   ["Square shoulders, don't let the bell twist you", "Same hip snap as the two-hand swing", "Free hand guards the hip or mirrors the bell"], 2)
ex("deadlift", "KB Deadlift", HINGE, "Foundational hinge for the back of the body.",
   ["Bell between the feet, under the hips", "Hinge back with a flat back", "Push the floor away", "Stand tall, don't lean back"], 4)
ex("double_deadlift", "KB Deadlift (2 bells)", HINGE, "Deadlift with a bell beside each foot for heavier loading.",
   ["Bells beside the feet, handles in line with ankles", "Hinge, flat back, grip hard", "2–3 sec slow lowering", "Pick up and put down on the same spot"], 4)
ex("rdl", "KB Romanian Deadlift", HINGE, "Hamstring-focused hinge that starts from standing.",
   ["Chest up, shoulders back", "Push the hips back, soft knees", "Find the big hamstring stretch", "Bell stays close to the legs"], 4)
ex("sl_deadlift", "Single-Leg Deadlift", HINGE, "One-leg hinge for balance, hips and hamstrings.",
   ["Bell in the hand opposite the standing leg", "Reach the back leg long like a see-saw", "Hips stay square to the floor", "Stand tall with a glute squeeze"], 4)

# Squat / lunge
ex("goblet_squat", "KB Goblet Squat", SQUAT, "Front-loaded squat for legs and core.",
   ["Bell at the chest, elbows down", "Slowly lower to your deepest position", "Hold the bottom for a second", "Drive up through the whole foot"])
ex("front_rack_squat", "KB Front Rack Squat", SQUAT, "Single-bell squat from the rack position — great for the core.",
   ["Bell in the rack, wrist straight", "Don't lean toward the bell", "Slowly lower, pause at the bottom", "Drive up tall"])
ex("reverse_lunge", "KB Reverse Lunge (Goblet)", "figure.step.training", "Step-back lunges holding the bell at the chest.",
   ["Step back softly", "Back knee gently touches the ground", "Front shin roughly vertical", "Drive up through the front heel"], 4)
ex("split_squat", "KB Split Squat", "figure.step.training", "Static lunge: stay in a split stance and go straight down and up.",
   ["Long split stance", "Knee gently touches the ground", "Torso tall", "Finish all reps on one leg, then switch"], 4)
ex("thruster", "Goblet Thruster", CARDIO, "Goblet squat straight into an overhead press. A big heart-rate driver.",
   ["Squat with the bell at the chest", "Drive up hard", "Use the leg drive to press overhead", "Lower to the chest, then squat"])

# Push
ex("press", "KB Strict Press", PRESS, "Strict overhead press from the rack.",
   ["Squeeze glutes and grip hard", "Press up and slightly back", "Lock out with the bicep by your ear", "Slowly lower back to the rack"])
ex("half_kneeling_press", "KB Press (Half Kneeling)", PRESS, "Press from a half-kneeling stance. Removes the legs and challenges the core.",
   ["Down knee on the same side as the bell", "Squeeze the down-side glute", "Lock out at the top", "Slow lower back to the rack"])
ex("push_press", "KB Push Press", PRESS, "A dip and drive from the legs to move a heavier bell overhead.",
   ["Quick shallow dip", "Drive through the legs", "Punch the bell up to lockout", "Lower under control to the rack"])
ex("floor_press", "KB Floor Press", PRESS, "Lying press for chest and triceps that's easy on the shoulders.",
   ["Lie on your back, knees bent", "Upper arm at 45°", "Press straight up and lock out", "Lower until the elbow touches the floor"])
ex("bridged_floor_press", "KB Bridged Floor Press", PRESS, "Floor press from a glute bridge for more range and glute work.",
   ["Get into a bridge first", "Press and hold at the top for a second", "Lower slowly to the floor", "Keep the hips high throughout"])
ex("pushup", "Push-Up", CORE, "Bodyweight press. Hands on a bench or the bell makes it easier.",
   ["Hands under the shoulders", "Body in one straight line", "Elbows at 45°", "Chest to the floor, then push it away"], 2)

# Pull
ex("row", "KB Bent Row", PULL, "Bent-over row for the back and grip.",
   ["Staggered stance, free hand on thigh", "Flat back", "Pull the elbow to your hip pocket", "Pause 1 sec at the top, lower slowly"])
ex("high_pull", "KB High Pull", PULL, "Explosive hinge into a high row. Builds the upper back and power.",
   ["Start like a swing", "Snap the hips and pull the elbow high", "Keep elbows high and grip soft", "Let it swing back down under control"], 2)
ex("clean", "KB Clean", HINGE, "Bring the bell from a swing to the rack position.",
   ["Keep the bell close, zip up the jacket", "Spear the hand through so it doesn't bang", "Solid rack: wrist straight, elbow on ribs",
    "Let it drop back into the hike"])

# Full body / core / carries
ex("getup", "Turkish Get-Up", "figure.core.training", "Slow, controlled stand-up from the floor with the bell locked out overhead.",
   ["Eyes on the bell the whole time", "Arm locked, knuckles to the ceiling", "Roll to elbow, then hand, then bridge high",
    "Sweep the leg, kneel, stand. Reverse it slowly"], 35)
ex("suitcase_march", "Suitcase March", "figure.walk", "March in place holding one bell. Builds anti-side-bend core strength.",
   ["Stand tall, don't lean toward the bell", "Knees to hip height", "Shoulders level", "Breathe behind the brace"])
ex("rack_march", "Front Rack March", "figure.walk", "March in place with the bell in the rack position.",
   ["Solid rack, wrist straight", "Tall posture", "Slow, controlled knees"])
ex("plank", "Plank", CORE, "Hard-style plank: maximal tension for a short time.",
   ["Elbows under shoulders", "Squeeze glutes and quads", "Pull the elbows toward the toes", "Breathe in short sips"])
ex("side_plank", "Side Plank", CORE, "Side-on plank for the obliques and hips.",
   ["Elbow under shoulder", "Hips high, body in a line", "Top hand on hip or reaching up"])
ex("dead_bug", "Dead Bug", CORE, "Controlled core work that teaches bracing while moving.",
   ["Low back pressed into the floor", "Extend opposite arm and leg slowly", "Exhale as you reach", "Control, not speed"])

# Combos used in conditioning
ex("clean_squat_press", "Clean → Squat → Press", CARDIO, "Clean to the rack, front squat, then press. One rep of each, then repeat.",
   ["Clean, squat, press = one cycle", "Keep cycling around", "Switch hands each time", "Smooth and steady beats fast and sloppy"], 7)
ex("swing_squat", "Swings → Goblet Squats", CARDIO, "10 swings straight into 5 goblet squats, then rest for the rest of the minute.",
   ["Park the bell after the swings", "Pick it up into the goblet position", "Rest whatever is left of the minute"], 40)
ex("abc", "Armor Building Complex", CARDIO, "Dan John's classic: 2 cleans, 1 press, 3 front squats. One-bell version: switch sides each minute.",
   ["2 cleans", "1 strict press", "3 front rack squats", "Rest for the rest of the minute"], 25)
ex("swing_pushup", "Swings + Push-Ups", CARDIO, "A pair: swings then push-ups.", ["Swings first, then drop for push-ups", "Keep push-ups strict"], 3)

# ---------------------------------------------------------------------------
# Building blocks
# ---------------------------------------------------------------------------
REST = 60  # the programme says 45–60 s between sets

def reps(exercise, n=None, rest=REST, side=False, note=None, target=None):
    """A rep-based set: the user taps Done when finished."""
    d = dict(exercise=exercise, rest=rest)
    if n is not None: d["reps"] = n
    if side: d["perSide"] = True
    if note: d["note"] = note
    if target: d["target"] = target
    return d

def timed(exercise, work, rest=0, side=False, note=None, target=None, counter=False):
    """A timed interval."""
    d = dict(exercise=exercise, work=work, rest=rest)
    if side: d["perSide"] = True
    if note: d["note"] = note
    if target: d["target"] = target
    if counter: d["counter"] = True
    return d

def block(name, rounds, *items, between=None):
    b = dict(name=name, rounds=rounds, items=list(items))
    if between is not None: b["restBetweenRounds"] = between
    return b

def sets(exercise, n_sets, n_reps, rest=REST, side=False, note=None, target=None, name=None):
    """Straight sets of one exercise."""
    nm = name or next(e["name"] for e in E if e["id"] == exercise)
    return block(nm, n_sets, reps(exercise, n_reps, rest, side, note, target))

WARMUP = block("Warm-Up", 1,
    timed("halo", 45, 15, target="Light bell, alternate directions"),
    timed("glute_bridge", 45, 15),
    timed("hip_hinge", 45, 15),
    timed("prying_squat", 45, 15),
    timed("swing", 30, 30, target="Light and crisp, about 10 reps"))
COOLDOWN = block("Cool-Down", 1,
    timed("hip_flexor_stretch", 30, side=True),
    timed("hamstring_stretch", 45),
    timed("childs_pose", 45),
    timed("crocodile_breathing", 60))

W = []
def workout(id, title, subtitle, category, level, focus, theme, description, *blocks, bells=1, warmup=True):
    W.append(dict(id=id, title=title, subtitle=subtitle, category=category, level=level, focus=focus,
                  theme=theme, description=description, bells=bells, warmup=warmup, blocks=list(blocks)))

SWING_NOTE = "Hip-hinge movement. Stand up tall. Keep it dynamic, control the bell."
LUNGE_NOTE = "Aim for your knee to gently touch the ground before coming back up."
SQUAT_NOTE = "Slowly lower to your deepest position and hold for a second."
PRESS_NOTE = "Lock out at the top and slowly lower back to the rack."

# ---------------------------------------------------------------------------
# 1. Beginner Programme (from the user's programme, kept as written)
# ---------------------------------------------------------------------------
workout("session-a", "Session A", "Deadlift · Press · Row · Squat · Swing", "programme", "Beginner", "Full Body", "ember",
    "Hinge, press, row and squat, then a 90/60 conditioning finisher.",
    sets("double_deadlift", 4, 6, note="2–3 sec slow lowering. Pick up and put down on the same spot."),
    sets("press", 3, 5, side=True, note=PRESS_NOTE),
    sets("row", 3, 6, side=True, note="Pause 1 sec at the top, lower slowly."),
    sets("goblet_squat", 3, 8, note=SQUAT_NOTE),
    sets("swing", 3, 12, note=SWING_NOTE),
    block("Conditioning 90/60", 3, timed("clean_squat_press", 90, 60, note="Keep cycling around. Switch hands each time.")),
    bells=2)
workout("session-b", "Session B", "Front Squat · Floor Press · High Pull · Lunge · Swing", "programme", "Beginner", "Full Body", "ocean",
    "Front rack squats, bridged presses and high pulls, finished with a 6-minute EMOM.",
    sets("front_rack_squat", 4, 5, side=True, note=SQUAT_NOTE),
    sets("bridged_floor_press", 3, 8, note="Bridge, press, hold at the top for a second, lower slowly."),
    sets("high_pull", 3, 12, note="Keep elbows high, and soft grip."),
    sets("reverse_lunge", 3, 6, target="6 each leg", note=LUNGE_NOTE),
    sets("swing", 3, 15, note=SWING_NOTE),
    block("Conditioning: EMOM 6", 6, timed("swing_squat", 60, target="10 swings → 5 goblet squats",
                                           note="Start each minute on the beep. Rest whatever is left.")))
workout("session-c", "Session C", "Clean · Kneeling Press · RDL · Split Squat · Swing", "programme", "Beginner", "Full Body", "violet",
    "Cleans and half-kneeling presses, hamstring work, then a 6-minute non-stop finisher.",
    sets("clean", 4, 5, side=True, note="Keep the bell close, solid rack position."),
    sets("half_kneeling_press", 3, 6, side=True, note=PRESS_NOTE),
    sets("rdl", 3, 8, note="Chest up, shoulders back. Find the big hamstring stretch."),
    sets("split_squat", 3, 6, side=True, note=LUNGE_NOTE),
    sets("swing", 3, 15, note=SWING_NOTE),
    block("Conditioning: 6-min Continuous", 1, timed("clean_squat_press", 360, counter=True,
          target="3 clean + 3 squat + 3 press", note="No stopping! Alternate hands each time. Tap + after each round.")))

# ---------------------------------------------------------------------------
# 2. Strength (rep-based, tap Done)
# ---------------------------------------------------------------------------
workout("session-d", "Single-Leg Strength", "SL Deadlift · Kneeling Press · Split Squat · Row", "strength", "Beginner", "Balance & Legs", "teal",
    "Everything on one side at a time to fix imbalances and build the hips. Finishes with a short swing EMOM.",
    sets("sl_deadlift", 3, 6, side=True, note="Move slowly. Touch the bell down lightly if you need balance."),
    sets("half_kneeling_press", 3, 6, side=True, note=PRESS_NOTE),
    sets("split_squat", 3, 6, side=True, note=LUNGE_NOTE),
    sets("row", 3, 8, side=True, note="Pause 1 sec at the top, lower slowly."),
    block("Suitcase March", 2, timed("suitcase_march", 30, 30, side=True)),
    block("Swing EMOM 5", 5, timed("swing", 60, target="12 swings", note="Swing on the minute, rest the remainder.")))
workout("push-pull", "Push & Pull", "Floor Press · Row · Push-Up · High Pull", "strength", "Beginner", "Upper Body", "rose",
    "Paired upper-body pushing and pulling for a strong chest, back and shoulders.",
    sets("floor_press", 4, 8, side=True, rest=45),
    sets("row", 4, 8, side=True, rest=45, note="Pause 1 sec at the top, lower slowly."),
    sets("pushup", 3, None, target="Max good reps", note="Stop 1–2 reps before your form breaks."),
    sets("high_pull", 3, 10, note="Keep elbows high, and soft grip."),
    sets("halo", 2, 5, target="5 each direction"),
    block("Plank", 3, timed("plank", 20, 20)))
workout("leg-day", "Leg Day", "Goblet Squat · RDL · Lunge · Bridge · Swing", "strength", "All Levels", "Lower Body", "ember",
    "Squat, hinge and lunge with plenty of volume. Expect to feel it tomorrow.",
    sets("goblet_squat", 4, 10, note=SQUAT_NOTE),
    sets("rdl", 4, 10, note="Chest up, shoulders back. Find the big hamstring stretch."),
    sets("reverse_lunge", 3, 8, target="8 each leg", note=LUNGE_NOTE),
    sets("glute_bridge", 3, 15, rest=30, note="Hold each rep at the top for a second."),
    sets("swing", 3, 20, note=SWING_NOTE))
workout("getup-practice", "Get-Up Practice", "Get-Up · Goblet Squat · Swing", "strength", "All Levels", "Full Body", "steel",
    "Slow Turkish get-ups for full-body strength and shoulder stability, plus squats and swings.",
    sets("getup", 5, 1, side=True, rest=45, target="1 slow rep each side", note="Smooth, never rushed. Use a lighter bell if needed."),
    sets("goblet_squat", 3, 8, note=SQUAT_NOTE),
    sets("swing", 5, 15, rest=45, note=SWING_NOTE),
    block("Side Plank", 2, timed("side_plank", 20, 10, side=True)))
workout("press-ladders", "Press Ladders", "1-2-3 ladders · Row · Squat · Swing", "strength", "Intermediate", "Upper Body", "ocean",
    "Classic ladder training: 1 rep, rest, 2 reps, rest, 3 reps. Lots of quality presses without grinding.",
    block("Press Ladders", 3,
          reps("press", 1, 15, side=True), reps("press", 2, 20, side=True), reps("press", 3, 60, side=True,
          note="Each rung: left then right. Rest is short until the end of the ladder.")),
    block("Row Ladders", 2,
          reps("row", 2, 15, side=True), reps("row", 4, 20, side=True), reps("row", 6, 60, side=True)),
    sets("goblet_squat", 3, 8, note=SQUAT_NOTE),
    sets("swing", 3, 15, rest=45, note=SWING_NOTE))
workout("heavy-hinge", "Heavy Hinge", "Double Deadlift · Swings · Carries", "strength", "Intermediate", "Posterior Chain", "violet",
    "Build a powerful back side: heavy deadlifts, ten sets of ten swings and loaded marches.",
    sets("double_deadlift", 5, 5, rest=75, note="Heaviest bells you can move with a flat back."),
    block("10 × 10 Swings", 10, timed("swing", 30, 30, target="10 crisp swings", note="Every swing is a hard hip snap.")),
    block("Suitcase March", 3, timed("suitcase_march", 30, 15, side=True)),
    bells=2)
workout("rack-strength", "Front Rack Strength", "Clean · Front Squat · Push Press · Row", "strength", "Intermediate", "Full Body", "teal",
    "Everything from the rack position: cleans, squats and push presses.",
    sets("clean", 4, 5, side=True, note="Keep the bell close, solid rack position."),
    sets("front_rack_squat", 4, 5, side=True, note=SQUAT_NOTE),
    sets("push_press", 3, 5, side=True, note="Dip and drive, then lower slowly to the rack."),
    sets("row", 3, 8, side=True),
    block("Rack March", 2, timed("rack_march", 30, 15, side=True)))
workout("basics", "Kettlebell Basics", "Start here", "strength", "Beginner", "Full Body", "steel",
    "A friendly introduction to the core movements with plenty of rest. Learn the hinge and squat before going heavier.",
    sets("deadlift", 3, 8, note="Practise the hinge: hips back, flat back."),
    sets("goblet_squat", 3, 8, note=SQUAT_NOTE),
    sets("swing", 3, 10, note="Only if the deadlift feels solid."),
    sets("row", 3, 8, side=True),
    sets("press", 2, 5, side=True, note=PRESS_NOTE),
    block("Core", 2, timed("dead_bug", 40, 20), timed("plank", 20, 20)))

# ---------------------------------------------------------------------------
# 3. Conditioning (timed)
# ---------------------------------------------------------------------------
workout("swings-getups", "Swings & Get-Ups", "The simple, proven classic", "conditioning", "All Levels", "Full Body", "ember",
    "Inspired by Simple & Sinister: 100 swings in sets of 10, then slow Turkish get-ups.",
    block("100 Swings", 10, timed("swing", 60, target="10 swings", note="Start on the beep, rest the rest of the minute.")),
    block("Get-Ups", 5, reps("getup", 1, 30, side=True, target="1 slow rep each side")))
workout("swing-burn", "Swing Burn", "40/20 intervals", "conditioning", "Intermediate", "Conditioning", "volt",
    "Heart-rate-raising intervals built around the swing, finished with a fast swing ladder.",
    block("Conditioning Circuit", 3,
          timed("swing", 40, 20, target="Max crisp reps"),
          timed("goblet_squat", 40, 20),
          timed("pushup", 30, 20, target="Hands elevated if needed"),
          timed("reverse_lunge", 40, 20, target="Alternate legs"),
          timed("plank", 30, 30), between=45),
    block("Swing Finisher", 8, timed("swing", 20, 10, target="Fast, powerful hips")))
workout("tabata", "Tabata Four", "4 × 4-minute Tabatas", "conditioning", "Intermediate", "Conditioning", "rose",
    "Four Tabatas: 20 seconds hard, 10 seconds rest, 8 times. One minute between each.",
    block("Tabata 1: Swings", 8, timed("swing", 20, 10)),
    block("Rest", 1, timed("crocodile_breathing", 60, target="Breathe and recover")),
    block("Tabata 2: Goblet Squats", 8, timed("goblet_squat", 20, 10)),
    block("Rest", 1, timed("crocodile_breathing", 60, target="Breathe and recover")),
    block("Tabata 3: Swings", 8, timed("swing", 20, 10)),
    block("Rest", 1, timed("crocodile_breathing", 60, target="Breathe and recover")),
    block("Tabata 4: Push-Ups", 8, timed("pushup", 20, 10, target="Knees down if needed")))
workout("emom-20", "EMOM 20", "Swing · Squat · Press · Push-Up", "conditioning", "Intermediate", "Full Body", "ocean",
    "Every minute on the minute for 20 minutes, rotating four movements. Rest whatever is left of each minute.",
    block("EMOM 20", 5,
          timed("swing", 60, target="15 swings"),
          timed("goblet_squat", 60, target="10 goblet squats"),
          timed("press", 60, target="5 each arm"),
          timed("pushup", 60, target="10 push-ups")))
workout("swing-ladder", "Swing Pyramid", "10 · 15 · 20 · 25 · 20 · 15 · 10", "conditioning", "Intermediate", "Conditioning", "volt",
    "Climb a pyramid of swing sets with goblet squats in between. 115 swings and 40 squats.",
    *[block(f"{n} Swings", 1, reps("swing", n, 20, note=SWING_NOTE), reps("goblet_squat", 5, 40))
      for n in (10, 15, 20, 25, 20, 15, 10)],
    sets("press", 3, 5, side=True, note=PRESS_NOTE),
    sets("row", 3, 8, side=True, note="Pause 1 sec at the top, lower slowly."))
workout("amrap-20", "AMRAP 20", "As many rounds as possible", "conditioning", "Intermediate", "Full Body", "violet",
    "20 minutes to complete as many rounds as you can. Steady pace, good form, tap + after each round.",
    block("AMRAP 20", 1, timed("swing", 1200, counter=True,
          target="10 swings · 8 goblet squats · 6 push-ups · 4/4 rows",
          note="Move steadily. Rest briefly whenever you need to.")))
workout("countdown", "Countdown 10 → 1", "Swings + squats, descending", "conditioning", "All Levels", "Conditioning", "ember",
    "10 swings and 10 squats, then 9 and 9, all the way down to 1. Rest as needed between rungs.",
    *[block(f"Rung {n}", 1, reps("swing", n, 0), reps("goblet_squat", n, 20 if n > 1 else 0)) for n in range(10, 0, -1)],
    sets("press", 3, 5, side=True, note=PRESS_NOTE),
    sets("high_pull", 3, 10, note="Keep elbows high, and soft grip."),
    block("Plank Finisher", 3, timed("plank", 30, 30)))
workout("intervals-40-20", "Full-Body 40/20", "Squat · Row · Press · Deadlift", "conditioning", "All Levels", "Full Body", "teal",
    "A four-round circuit hitting every movement pattern with timed 40/20 intervals.",
    block("Circuit", 4,
          timed("goblet_squat", 40, 20),
          timed("row", 30, 15, side=True),
          timed("press", 30, 15, side=True),
          timed("deadlift", 40, 20), between=60))
workout("legs-core", "Legs & Core", "Strong legs, solid middle", "conditioning", "All Levels", "Lower Body", "violet",
    "Squats, hinges and lunges paired with loaded core work.",
    block("Legs", 3, timed("goblet_squat", 45, 15), timed("deadlift", 45, 15), timed("reverse_lunge", 45, 30), between=45),
    block("Core & Carry", 3, timed("one_arm_swing", 20, 10, side=True), timed("suitcase_march", 30, 10, side=True),
          timed("dead_bug", 40, 20), between=30))
workout("upper-core", "Upper Body & Core", "Clean · Press · Row · Push-Up", "conditioning", "Intermediate", "Upper Body", "rose",
    "Shoulders, back, chest and arms with timed intervals. Keep the core braced on every rep.",
    block("Press & Pull", 3, timed("press", 40, 15, side=True), timed("row", 30, 15, side=True),
          timed("floor_press", 30, 15, side=True), timed("pushup", 30, 20), between=45),
    block("Core", 3, timed("halo", 30, 10), timed("plank", 30, 15)))

# ---------------------------------------------------------------------------
# 4. Complexes
# ---------------------------------------------------------------------------
workout("abc", "Armor Building Complex", "2 cleans · 1 press · 3 squats", "complexes", "Intermediate", "Full Body", "steel",
    "Dan John's famous complex, done every minute for 20 minutes. With one bell, switch sides each minute.",
    block("ABC EMOM 20", 10, timed("abc", 60, side=True, target="2 cleans · 1 press · 3 front squats",
                                   note="Rest whatever is left of the minute.")))
workout("csp-complex", "Clean-Squat-Press Complex", "5 rounds per side", "complexes", "Intermediate", "Full Body", "ember",
    "Five cleans, five front squats and five presses without putting the bell down. Then switch sides.",
    block("Complex", 5, reps("clean_squat_press", None, 90, side=True, target="5 clean · 5 squat · 5 press",
                             note="Don't put the bell down until all 15 reps are done.")),
    sets("row", 3, 8, side=True, rest=45),
    sets("swing", 3, 15, rest=45, note=SWING_NOTE))
workout("hinge-complex", "Hinge & Pull Complex", "RDL · Row · High Pull · Swing", "complexes", "All Levels", "Posterior Chain", "teal",
    "A flowing complex for the back of the body and the upper back.",
    block("Complex", 5,
          reps("rdl", 8, 0), reps("row", 8, 0, side=True), reps("high_pull", 8, 0, side=True), reps("swing", 15, 75,
          note="Move from one exercise to the next without resting.")),
    block("Side Plank", 2, timed("side_plank", 20, 10, side=True)))
workout("thruster-burn", "Thruster Burn", "Thrusters · Swings · Lunges", "complexes", "Intermediate", "Conditioning", "rose",
    "Goblet thrusters paired with swings and lunges for a big full-body sweat.",
    block("Round", 5, reps("thruster", 10, 15), reps("swing", 15, 15), reps("reverse_lunge", None, 60, target="5 each leg")),
    block("Swing + Push-Up Ladder", 5, reps("swing_pushup", None, 30, target="10 swings + 5 push-ups")))

# ---------------------------------------------------------------------------
# 5. Recovery
# ---------------------------------------------------------------------------
workout("easy-day", "Easy Day Flow", "Mobility and light movement", "recovery", "All Levels", "Mobility", "steel",
    "A gentle day to move, recover and practise technique with a light bell.",
    block("Flow", 3, timed("halo", 40, 10), timed("prying_squat", 45, 15), timed("glute_bridge", 40, 10),
          timed("hip_hinge", 40, 20), timed("suitcase_march", 30, 10, side=True)),
    block("Get-Up Practice", 3, reps("getup", 1, 30, side=True, target="1 slow rep each side, light bell")),
    block("Light Swings", 5, timed("swing", 20, 40, target="Easy and crisp")),
    warmup=False)

# ---------------------------------------------------------------------------
# Duration estimate (mirrors the app's logic) and output
# ---------------------------------------------------------------------------
SEC = {e["id"]: e["secondsPerRep"] for e in E}

def item_secs(it):
    if "work" in it: return it["work"]
    n = it.get("reps")
    return SEC[it["exercise"]] * n + 5 if n else 40

def total(blocks):
    steps = []
    for b in blocks:
        for r in range(b["rounds"]):
            for i, it in enumerate(b["items"]):
                steps += [("w", item_secs(it))] * (2 if it.get("perSide") else 1)
                rest = it["rest"]
                if i == len(b["items"]) - 1 and r < b["rounds"] - 1 and "restBetweenRounds" in b:
                    rest = b["restBetweenRounds"]
                if rest: steps.append(("r", rest))
    while steps and steps[-1][0] == "r": steps.pop()
    return sum(s for _, s in steps)

ids = set(SEC)
for w in W:
    missing = {it["exercise"] for b in w["blocks"] for it in b["items"]} - ids
    assert not missing, (w["id"], missing)
    main = total(w["blocks"])
    full = main + (total([WARMUP]) + total([COOLDOWN]) if w["warmup"] else 0)
    print(f'{w["category"]:13s} {w["title"]:28s} main {main/60:5.1f}  with warm-up/cool-down {full/60:5.1f} min')

OUT.write_text(json.dumps(dict(exercises=E, warmup=WARMUP, cooldown=COOLDOWN, workouts=W), indent=1, ensure_ascii=False))
print(f"\n{len(W)} workouts, {len(E)} exercises → {OUT}")
