extends Control

var score_label: Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score_label = $ScoreLabel
	set_score(Global.score)

	


func set_score(score: int) -> void:
	# Update the ScoreLabel to display the final score
	score_label.text = "Score: " + str(score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
