extends Node3D

var cooldown_time: float = 0
var remaining_time: float = 0
var max_bar_scale: float = 1.0  # Adjust this based on the full scale of your CooldownBar

func start_cooldown(duration: float) -> void:
	cooldown_time = duration
	remaining_time = duration
	update_cooldown_bar()
	set_process(true)

func _process(delta: float) -> void:
	if remaining_time > 0:
		remaining_time -= delta
		update_cooldown_bar()
		
		if remaining_time <= 0:
			set_process(false)  # Stop updating when cooldown is done

func update_cooldown_bar() -> void:
	var cooldown_bar = $SubViewport/CooldownBar  # Updated path to CooldownBar
	if cooldown_bar != null:
		var progress = remaining_time / cooldown_time
		cooldown_bar.scale.x = max_bar_scale * progress
	else:
		print("Error: CooldownBar node not found!")
