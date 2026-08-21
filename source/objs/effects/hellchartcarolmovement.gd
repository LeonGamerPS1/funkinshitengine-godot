extends Node
@export var dad:Node2D
var initialPos:Vector2 = Vector2.ZERO
var floatshit = 0

func _ready() -> void:
	initialPos = dad.position

func _process(_delta: float) -> void:
	floatshit += 0.1;
	dad.position.y += sin(floatshit) * 22;
	dad.position.x += cos(floatshit) * 22;
