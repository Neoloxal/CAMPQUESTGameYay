extends Node2D

@export var Chat:RichTextLabel

func _ready():
	var battle = true
	while battle:
		Chat.say("HEROES TURN")
		var heroes = get_tree().get_nodes_in_group("Hero")
		for hero in heroes:
			hero.playerturn()
			await hero.turnFinished
		
		Chat.say("ENEMIES TURN")
		var enemies = get_tree().get_nodes_in_group("Enemy")
		for enemy in enemies:
			enemy.enemyturn()
			await enemy.turnFinished
