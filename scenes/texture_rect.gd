extends TextureRect
var deck: Array[CardMetaData] = []
# Variables to reference the UI elements
var score_label: Label
var retry_button: Button

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	deck = DeckManager.loadCurrentDeck(deck)
	# Initialize the node references
	score_label = $ScoreLabel
	retry_button = $CenterContainer/EndMenuContainer/PlayButton
	
	retry_button.pressed.connect(_on_retry_pressed)
	
	
	
	# Connect the retry button to restart the game
	#retry_button.connect("pressed", Callable(self, "_on_retry_pressed"))


func set_score():
	# Update the ScoreLabel to display the final score
	score_label.text = "Score: " + str(Global.score)

func _on_retry_pressed():
	# Restart the game by reloading the main scene
	get_tree().change_scene_to_file("res://level3/level.tscn")
