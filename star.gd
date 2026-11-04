extends Area2D

signal collected

const SPIN_SPEED := 1.2  # radians per second


func _process(delta: float) -> void:
	rotation += SPIN_SPEED * delta


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		collected.emit()
		queue_free()
