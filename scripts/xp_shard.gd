class_name XPShard
extends Node2D

var value := 1

func _process(delta: float) -> void:
	rotation += delta * 3.5
