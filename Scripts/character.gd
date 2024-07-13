extends Node2D

@export_category("General")
@export var ResourceJSON:JSON
@onready var Name:String
@onready var SelfColor:String
@export var Chat: RichTextLabel
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Strength = 0
@export var Sharpness = 0
@onready var CritChance = int(round((1 - pow(0.99, float(Sharpness))) * 100))

enum State {
	WAITING,
	PLAYER_TURN
}

var current_state = State.WAITING

signal turnFinished
signal UIFinished

func _ready():
	var ResourceJSONData = ResourceJSON.get_data()
	Name = ResourceJSONData["general"]["name"]
	SelfColor = ResourceJSONData["general"]["color"]
	Chat.say(Name)
	
	%Animator.play("{Name}Idle".format({"Name":Name}))
	
	%Health.position.y += Yoffset
	%RemoveHealth.position.y += Yoffset
	
	Chat.text = ""
	
	var heroes = get_tree().get_nodes_in_group("Hero")
	for hero in heroes:
		pass #hero.connect(UIFinished, _onUIFinished())

func _process(_delta):
	match current_state:
		State.WAITING:
			pass
		State.PLAYER_TURN:
			if Input.is_action_just_pressed("Use"):
				var EnemyArray = get_tree().get_nodes_in_group("Enemy")
				if EnemyArray.size() > 0:
					var PickedEnemies = [EnemyArray[0]]
					Moves.use_move(self, "Basic Attack", PickedEnemies, Strength, CritChance)
				Utils.heroesTurn = false
				emit_signal("turnFinished")
	if HP != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(%RemoveHealth, "value", int(round((float(HP) / MaxHP) * 100)), .3).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "{hp}/{maxhp}".format({"hp":HP,"maxhp":MaxHP})

func print_damage(enemy,damage:int,crit:bool):
	# CRIT DMG MUST BE MULTIPLIED IN FUNC!!!!!!!
	var text = "{DMG} DMG!
[color={selfColor}][{selfName}][/color] [color={enemyColor}]{Name}[/color] ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}".format({
	"selfColor":SelfColor,
	"selfName":Name,
	"DMG":damage, 
	"enemyColor":enemy.SelfColor, "Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()
	})
	if crit:
		text = "[color=#FF0000]CRIT![/color] " + text
	text = "[color={selfColor}][{selfName}][/color] ".format({"selfColor":SelfColor, "selfName":Name}) + text
	Chat.say(text)

func playerturn():
	Utils.heroesTurn = true
	change_state(State.PLAYER_TURN)

func change_state(next_state):
	current_state = next_state
