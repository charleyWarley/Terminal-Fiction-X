extends StaticBody

export var foodType = "dried peppers"
export var amount = 10
var label
export(PackedScene) onready var text
signal bumped

func _on_triggerArea_body_entered(body):
	if body.name == "player":
		var newLabel = text.instance()
		label = newLabel
		add_child(label)
		label.label.set_text(foodType + "  " + (amount as String))

func _on_triggerArea_body_exited(body):
	if body.name == "player":
		label.queue_free()
		label = null


func _on_bumped():
	print("bumped into a bag of food")

func _ready():
	add_to_group("moveable")
	connect("bumped", self, "_on_bumped")
	
func _process(_delta):
	if label != null and Input.is_action_just_pressed("interact"):
		if $"food sack".visible == true:
			$"food sack".set_visible(false)
			$"empty sack".set_visible(true)
