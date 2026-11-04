# Star Catcher: a Ziva sample for Godot 4

A small, original Godot 4 game used to show what [Ziva](https://ziva.sh), an AI assistant inside the Godot editor, does with one ordinary request. Move the square with the arrow keys and collect stars. Each star is meant to add one point to the score label.

The project on `main` has one deliberate bug, the kind you get after moving a node into its own scene: `main.gd` looks up the score label with `%ScoreLabel`, but the label now lives in `hud.tscn`, so its unique name only resolves inside that scene. The game starts with a `Node not found` error, collecting a star then throws a null-instance error, and the score label never changes.

## The recording

[`recording/ziva-star-catcher-run.mp4`](recording/ziva-star-catcher-run.mp4) (85 s, silent) is one unedited, real-time screen recording of the Godot editor with the Ziva panel on the left. Captions under the frame say what is happening; [`recording/captions.srt`](recording/captions.srt) has the same text. [`recording/ziva-star-catcher-run-raw.mp4`](recording/ziva-star-catcher-run-raw.mp4) is the same take without captions.

What you see, in order:

1. One prompt is sent to Ziva.
2. Ziva reads the scene tree and the project's three scripts and three scenes.
3. Ziva edits `star.gd` (spin) and `main.tscn` (two new stars). The 2D view updates to five stars.
4. Ziva runs the game in the editor and holds the `ui_right` input action (`run_scene` injects the action; no physical key is pressed). The player touches a star, the star disappears, and the score stays at 0.
5. The Debugger shows the error: `Node not found: "%ScoreLabel" (relative to "/root/Main")`, then `Invalid assignment of property or key 'text' ... on a base object of type 'null instance'` at `main.gd:15`.
6. Ziva reads that error from the run, explains it, and changes the lookup in `main.gd` to `$HUD/ScoreLabel`.
7. Ziva runs the game again, holding `ui_right` for a shorter time. The score reads `Score: 1`. Ziva then reports what it changed and what it saw in the run screenshots.

The prompt was entered by Ziva's test harness, which types it into the Ziva composer and presses send. Nothing else touched the editor, the files or the Ziva panel until the recording ended.

## The exact prompt

```
Add two more stars to the level and make the stars spin slowly. Then play the game, grab a star with the arrow keys and check that the score goes up.
```

That was the only message. The prompt does not mention the bug.

## What Ziva changed

Branch [`ziva-run-2026-11-04`](../../tree/ziva-run-2026-11-04) has Ziva's changes from the recorded run as one commit, unmodified:

```diff
--- a/main.gd
+++ b/main.gd
-@onready var score_label: Label = %ScoreLabel
+@onready var score_label: Label = $HUD/ScoreLabel
--- a/main.tscn
+++ b/main.tscn
+[node name="Star4" parent="Stars" instance=ExtResource("3")]
+position = Vector2(300, 300)
+
+[node name="Star5" parent="Stars" instance=ExtResource("3")]
+position = Vector2(620, 180)
--- a/star.gd
+++ b/star.gd
+const SPIN_SPEED := 1.2  # radians per second
+
+
+func _process(delta: float) -> void:
+	rotation += SPIN_SPEED * delta
```

Ziva's tool calls, in order: `get_scene_tree`, `glob` (twice), `read` (six files), `edit_file` on `star.gd` and `main.tscn`, `get_scene_tree`, `run_scene` holding `ui_right` from 300 ms to 1500 ms, `edit_file` on `main.gd`, `clear_output_logs`, `run_scene` holding `ui_right` from 300 ms to 900 ms. Each `run_scene` returns a screenshot of the running game plus the console output and runtime errors from that run. The panel's +/- line counts include the replaced lines of each search-and-replace edit, so they differ from this diff.

## Reproduce it

1. Install Godot 4.7 and the Ziva plugin ([installation guide](https://ziva.sh/docs/installation)), and sign in.
2. Clone this repository and open it in Godot. Keep `main` checked out: it has the bug.
3. Open `main.tscn` and send the prompt above in a new Ziva chat. To match the recording, turn on **Auto-approve all actions** in Ziva's settings under Agent; otherwise approve each edit and run by hand.
4. Compare your result with the diff above. Model output varies between runs: star positions and wording will differ, and Ziva may spot the bug while reading `main.gd` before it runs the game.

To check the bug without Ziva, press Play (F5) and walk right into the first star: the Debugger shows the same two errors.

## How it was recorded

- Date: 4 November 2026. Godot 4.7.2 on Linux. Model: Ziva Smart, Ziva's default model.
- Before recording, auto-approve was turned on, the editor setting Run > Bottom Panel > Action on Play was set to Open Debugger, and the bottom panel was enlarged so the Debugger is readable.
- Ziva ran as a development build from Ziva's source (that is why the panel tab says "ZivaDev" and shows a per-turn cost), signed in to a local test account rather than a customer account.
- The editor ran in a virtual X display (Xvfb, 1440x900) and the screen was recorded with ffmpeg at 30 fps. The take is one continuous file from before the prompt to after Ziva's reply; nothing is cut, sped up or reordered. Captions sit in a strip added below the frame.
- The first four Debugger lines (`_create_xic`, `set_use_vsync`, `init_output_device`, `All audio drivers failed`) come from the virtual display having no input method, vsync or audio device. They are not from this project.
- Four takes were run on 4 November. In the three that used this exact bug, Ziva found it by running the game and reading the error. An earlier version of the sample used `$HUD/Score` on a label inside `main.tscn`; Ziva noticed that one while reading the script and fixed it before running, so the sample moved the label into its own scene. The published take is the last of the three; the other two are not published because the editor's Debugger panel was hidden or too small to read during the run.

The game itself (code, scenes and shapes) is original and contains no third-party assets.
