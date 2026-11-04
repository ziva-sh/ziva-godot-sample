extends Node2D

var score := 0

@onready var score_label: Label = $HUD/ScoreLabel


func _ready() -> void:
	for star in $Stars.get_children():
		star.collected.connect(_on_star_collected)


func _on_star_collected() -> void:
	score += 1
	score_label.text = "Score: %d" % score
