extends Camera3D

var decay = 0.8
var max_rotation = 0.25

var trauma = 0.5
var trauma_power = 2

var wobble_x = 0.0
var wobble_y = 0.0

var save_rotation: Quaternion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_rotation = get_quaternion()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	trauma = max(trauma - decay * delta, 0)
	shake()

func add_trauma(delta: float) -> void:
	trauma = min(trauma + delta, 1.0)

func add_wobble(delta_x: float, delta_y: float) -> void:
	wobble_x += delta_x
	wobble_y += delta_y

func reset_wobble() -> void:
	wobble_x = 0
	wobble_y = 0

func shake():
	set_quaternion(save_rotation)
	rotate_z(max_rotation * pow(trauma, trauma_power) * randf_range(-1, 1))
	rotation_degrees.x += wobble_x
	rotation_degrees.z += wobble_y
