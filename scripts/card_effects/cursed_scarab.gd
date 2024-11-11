extends BaseMonster
#inherited attributes
#var level: int
#var attack: int
#var defense: int
#var archetype: String
#var monster_name: String
#var scene_path: String
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var target: CharacterBody3D
var move_speed:float = 3.0
var gravity:float = -9.8
var parent
var team: String 
# Time in seconds between direction changes
var direction_change_interval:float = 2.0
var time_since_direction_change:float = 0.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var attack_range = 3.2
var current_direction = Vector3.ZERO
var debug =0
func _ready():
	
	print("Cursed Scarab ready!")
	animation_player.play("IdleSpider")
	parent = get_parent()
	print("parent is : ", parent)
	if debug == 1:
		team = "player"
		target = $"../Player"
		return
	if parent.name =="DeckManager":
		team = "player"
		target = AiDeckManager.getPlayer()
		print("target is: ", target)
	else:
		team = "robot"
		target = DeckManager.getPlayer()

func _physics_process(delta: float) -> void:
		
	if target == null:
		print("Error: Target is null!")
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	
	if _target_in_range(target):
		attack_player(30, target)
		queue_free()
		
	var direction = (target.global_transform.origin - global_transform.origin).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	move_and_slide()

	# Rotate to face target
	if direction.length() > 0:
		var target_rotation_y = atan2(direction.x, direction.z)
		rotation.y = target_rotation_y
	## Play the walking or idle animation based on movement
	if velocity.x ==0 or velocity.z ==0:
		animation_player.play("IdleSpider")
	else:
		animation_player.play("WalkSpider")

func attack_player(amount:int, player:CharacterBody3D):
	if player.has_method("take_damage"):
		player.take_damage(amount)
		
func _target_in_range(target:CharacterBody3D):
	return global_position.distance_to(target.global_position) < attack_range
	
