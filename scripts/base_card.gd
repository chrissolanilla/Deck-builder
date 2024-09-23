extends Control
class_name BaseCard

var metadata: CardMetaData

func setupCard(metadata: CardMetaData):
	self.metadata = metadata
	if($CardName):
		$CardName.text = metadata.card_name
		print("Card name is: ", $CardName.text)
	if($CardPortrait):
		$CardPortrait.texture = metadata.card_portrait
		print(" Card portrait is: ", $CardPortrait)
	
