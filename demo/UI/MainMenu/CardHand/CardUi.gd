class_name CardUi extends BoxContainer

#var _card: Card
var _card_slot: CardSlot = CardSlot.new(self)

func _get_effective_size() -> Vector2:
	return Vector2(size.x * scale.x, size.y * scale.y)


#func set_card(card: Card) -> void:
	#_card = card


#func get_card() -> Card:
	#return _card


func set_card_slot(card_slot: CardSlot) -> void:
	_card_slot = card_slot


func get_card_slot() -> CardSlot:
	return _card_slot


func animate(duration:float) -> void:
	get_card_slot().animate(duration)
