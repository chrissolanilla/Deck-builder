extends Control
class_name BaseCard

var metadata: CardMetaData

func setupCard(param_metadata: CardMetaData):
	self.metadata = param_metadata
	if($CardName):
		$CardName.text = param_metadata.card_name
		print("Card name is: ", $CardName.text)
	if($CardPortrait):
		$CardPortrait.texture = param_metadata.card_portrait
		print(" Card portrait is: ", $CardPortrait)
