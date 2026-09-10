extends Label

class_name FreeplayIconText

@export var icon:Sprite2D

var distancePerItem:Vector2 = Vector2(20, 120)
var startPosition:Vector2 = Vector2(0, 0)
var targetY:float = 0

func setText(txt:String):
	text = txt
	icon.position.x = 54 * text.length()
	
func _process(delta: float) -> void:
	var lerpVal:float = exp(-delta * 9.6);

	position = Vector2(lerp((targetY * distancePerItem.x) + startPosition.x, position.x, lerpVal), lerp((targetY * 1.3 * distancePerItem.y) + startPosition.y, position.y, lerpVal))
