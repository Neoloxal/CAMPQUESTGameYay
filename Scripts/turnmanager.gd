extends Node2D

@export var Chat:RichTextLabel

func _process(_delta):
	var heroes = get_tree().get_nodes_in_group("Hero")
	for hero in heroes:
		hero.playerturn()
		await hero.turnFinished
	
	if not Utils.heroesTurn:
		Chat.say("ENEMIES TURN")
		var enemies = get_tree().get_nodes_in_group("Enemy")
		for enemy in enemies:
			enemy.enemyturn()
			await enemy.turnFinished
		Utils.heroesTurn = true
		Chat.say("HEROES TURN")
