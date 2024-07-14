extends Node2D

@export var Chat:RichTextLabel

enum Turn {
	HEROES,
	ENEMIES
}

var current_state = Turn.HEROES

func _process(_delta):
	match current_state:
		Turn.HEROES:
			var heroes = get_tree().get_nodes_in_group("Hero")
			for hero in heroes:
				hero.playerturn()
				await hero.turnFinished
			switch_turn("enemy")
		Turn.ENEMIES:
			var enemies = get_tree().get_nodes_in_group("Enemy")
			for enemy in enemies:
				print(enemies)
				if !enemy.isDead:
					enemy.enemyturn()
					await enemy.turn_finished
					continue
			switch_turn("hero")

func switch_turn(turn):
	match turn:
		"hero":
			current_state = Turn.HEROES
		"enemy":
			current_state = Turn.ENEMIES
