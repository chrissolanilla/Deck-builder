extends BaseCard

@export var ui_card_scene: PackedScene #not sure if this line is needed
var scaleMultiplier:float = 0.34
var is_dragging: bool = false
var is_hovered: bool = false

signal card_selected
signal card_dragged
signal card_hovered(card_data : CardMetaData)
signal card_hovered_exit()

var card_metadata: CardMetaData


func _ready() -> void:
	self.connect("mouse_entered", Callable(self, "_on_mouse_hovered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	self.mouse_filter = Control.MOUSE_FILTER_PASS

func _input(event):
	if is_hovered:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("card_selected") # emit when card clicked
				is_dragging = true
			else:
				is_dragging = false # stop draggin when released
		
func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		self.global_position = mouse_pos # follow mouse pos
		emit_signal("card_dragged", mouse_pos)
		
func setupCard(metadata: CardMetaData):
	$CardName.text = metadata.card_name
	$CardPortrait.texture = metadata.card_portrait
	card_metadata = metadata
	#resize root to cardPortrait
	if metadata.card_portrait:
		print("root size before:  " , self.get_rect().size)
		var texture_size = $CardPortrait.texture.get_size()
		var scaled_size = texture_size * scaleMultiplier
		
		self.set_deferred("set_custom_minimum_size", scaled_size)
		self.set_size(scaled_size)
		#scale it down by 0.34 on x and y
		print("Texture size: ", texture_size)
		print("root size is now " , self.get_rect().size)
		
func _on_mouse_hovered() -> void:
	is_hovered = true
	print("Mouse is over the card")
	emit_signal("card_hovered", card_metadata)
	# TODO: add visual effects on hover or something

func _on_mouse_exited() -> void:
	is_hovered = false
	print("Mouse exited the card")
	emit_signal("card_hovered_exit")
	# TODO: remove visual effects
