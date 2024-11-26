extends BaseMonster
@onready var animation_player: AnimationPlayer = $ChrisBlender/AnimationPlayer
@onready var chris_blender: Node3D = $ChrisBlender
var health: int = 100
@onready var healthbar: ProgressBar = $SubViewport/Healthbar
@onready var sprite_3d: Sprite3D = $Sprite3D
var parent: Node
var team: String
var target: CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const flying_offset: float = 1.0  # Lower flying height to be closer to ground
var move_speed: float = 4.0
var attack_range: float = 1
@onready var object_9: MeshInstance3D = $ChrisBlender/Sketchfab_model/root/GLTF_SceneRootNode/RootNode_0_222/skeletal_3_221/GLTF_created_0/Skeleton3D/Object_9
@onready var animation_tree: AnimationTree = $ChrisBlender/AnimationTree
var state = "approach"

func _ready() -> void:
	parent = get_parent()
	if parent.name == "DeckManager":
		team = "player"
		target = AiDeckManager.getPlayer()
		print("target is: ", target)
		print("I am on team player")
	else:
		team = "robot"
		target = DeckManager.enemyLocal
		print("I am on team robot")

func _physics_process(delta: float) -> void:
	# Update direction towards target
	print("object9 position is: " ,object_9.position)
	print("global position is: ", global_position)
	if target == null:
		target = DeckManager.enemyLocal
	var direction = (target.global_transform.origin - global_transform.origin).normalized()

	# Maintain consistent flying height when in "approach" state
	if state == "approach":
		#global_position.y = flying_offset
		chris_blender.position.y = flying_offset
		$CollisionShape3D.position.y = flying_offset

		# Keep health bar above the dragon's body
		sprite_3d.global_position = global_position + Vector3(0, 1.5, 0)

		# Transition to attack when above the target
		if is_above_target(target):
			state = "attack"
			animation_tree.set("parameters/Run/blend_amount", 2.75)
			animation_tree.set("parameters/Fly/blend_amount", 0)

	elif state == "attack":
		# Ensure it doesn't go underground when attacking
		global_position.y = max(flying_offset, target.position.y + 1)
		sprite_3d.position = global_position

		if global_position.y < target.position.y + 1:
			print("we are underground")
			global_position.y = target.position.y + 1

	# Move towards the target
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()

	# Rotate to face the target
	if direction.length() > 0:
		var target_rotation_y = atan2(direction.x, direction.z)
		rotation.y = target_rotation_y

	# Play animations based on movement
	if velocity.length() == 0:
		animation_player.play("idle")
	else:
		if state == "approach":
			animation_tree.set("parameters/Fly/blend_amount", 1)
			animation_tree.set("parameters/Run/blend_amount", 0)
		elif state == "attack":
			animation_tree.set("parameters/Run/blend_amount", 2.75)
			animation_tree.set("parameters/Fly/blend_amount", 0)

func is_above_target(target: CharacterBody3D) -> bool:
	# Check if the dragon is horizontally aligned with the target
	return abs(global_position.x - target.global_position.x) < 2.5 and abs(global_position.z - target.global_position.z) < 2.5

func take_damage(amount: int) -> void:
	health -= min(amount, health)
	healthbar.value = health
	if health == 0:
		queue_free()

func attack_player(amount: int, player: CharacterBody3D):
	if player.has_method("take_damage"):
		player.take_damage(amount)

func _target_in_range(target: CharacterBody3D) -> bool:
	return global_position.distance_to(target.global_position) < attack_range

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print("ANIMATION FINISHED: ", anim_name)

	if anim_name == "running" and state == "attack":
		print("attacking!")
		attack_player(30, target)
		queue_free()  # Only queue free after attack finishes
