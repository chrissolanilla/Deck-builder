extends CharacterBody3D

# Speed of the enemy
var gravity = -9.8
var speed = 2.0
var health = 100
var attack_range = 2.5
var state_machine
var rotation_offset = Vector3(0, PI, 0)  # 180 degrees around the Y-axis
var attacking = false
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
@onready var anim_tree = $AnimationTree

func _ready():
	state_machine = anim_tree.get("parameters/playback")
	if anim_player:
		anim_player.connect("animation_finished", Callable(self,  "_on_attack_animation_finished"))

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if !_target_in_range():
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * speed
		look_at(Vector3(global_position.x + velocity.x, global_position.y + velocity.y, global_position.z + velocity.z), Vector3(0,1,0))
		state_machine.set("run", 1.0)
		
	else:
		# Rotate the enemy to face the player
		var look_at_position = player.global_position 
		look_at(look_at_position, Vector3.UP)
		state_machine.set("attack", 1.0)
		
			
	rotation += rotation_offset
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < attack_range
	
func _on_attack_animation_finished(anim_name):
	print("does player exist?")
	if anim_name == "attack":
		attacking = false
	if player:
		print("player exists")
		player.take_damage(50)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("hello")
	if anim_name =="attack":
		print("yippeee")
		player.take_damage(50)
	pass # Replace with function body.


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print("anim name is", anim_name)
	print("hello")
	if anim_name =="attack":
		print("yippeee")
		player.take_damage(50)
	pass # Replace with function body.


#this is the only signal that works and its kind of trash
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body is : ", body)
	if body.name == "Player":
		player.take_damage(50)
	pass # Replace with function body.
