extends State
class_name Weapon

var active = false
var cooldown1 = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Deactivate():
	active = false

func Attack():
	pass

func Release():
	pass

func Alt():
	pass

func AltRelease():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
