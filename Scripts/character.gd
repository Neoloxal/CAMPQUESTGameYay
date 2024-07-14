extends Node2D

@export_category("General")
@export var ResourceJSON:JSON
@onready var Name:String
@onready var SelfColor:String
@export var Chat: RichTextLabel

var ResourceJSONData

var MaxHP = 100
var HP = MaxHP
var MaxSP = 15
var SP = MaxSP

var Attack = 0
var Defense = 0
var CritChance = float((1 - pow(0.99, float(1))) * 100)

@onready var HPBar = $HP
@onready var LostHPBar = $LostHP
@onready var SPBar = $SP
@onready var LostSPBar = $LostSP
@onready var SPWarnAnim = $SPWarning/WarnAnim

enum State {
	WAITING,
	PLAYER_TURN
}

var current_state = State.WAITING

signal turnFinished
signal UIFinished

func _ready():
	ResourceJSONData = ResourceJSON.get_data()
	Name = ResourceJSONData["general"]["name"]
	SelfColor = ResourceJSONData["general"]["color"]
	MaxHP = 50 + (ResourceJSONData["stats"]["stamina"] - 1) * 5
	HP = MaxHP
	Defense = (ResourceJSONData["stats"]["stamina"] - 1) * 0.75
	MaxSP = 15 + (ResourceJSONData["stats"]["soul"] - 1) * 3
	SP = MaxSP
	Attack = (ResourceJSONData["stats"]["strength"] - 1) + 3
	print(Attack)
	CritChance = float((1 - pow(0.99, float(ResourceJSONData["stats"]["sharpness"] + 1))) * 100)
	
	%Animator.play("{Name}Idle".format({"Name":Name}))
	
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
				SPWarnAnim.play("RESET")
				var EnemyArray = get_tree().get_nodes_in_group("Enemy")
				var removed_enemies = 0
				for enemy in EnemyArray.size():
					if EnemyArray[enemy-removed_enemies].HP <= 0:
						EnemyArray.remove_at(enemy-removed_enemies)
						removed_enemies += 1
				if EnemyArray.size() > 0:
					var PickedEnemies = [EnemyArray[0]]
					if Moves.use_move(self, "Basic Attack", PickedEnemies) == true:
						emit_signal("turnFinished")
					else:
						SPWarnAnim.play("warn")
	var tween = get_tree().create_tween()
	tween.tween_property(HPBar, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(LostHPBar, "value", int(round((float(HP) / MaxHP) * 100)), .3).set_ease(Tween.EASE_IN_OUT)
	tween = get_tree().create_tween()
	tween.tween_property(SPBar, "value", int(round((float(SP) / MaxSP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(LostSPBar, "value", int(round((float(SP) / MaxSP) * 100)), .3).set_ease(Tween.EASE_IN_OUT)
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
	text = "[color={selfColor}]{selfName}[/color] ".format({"selfColor":SelfColor, "selfName":Name.to_upper()}) + text
	Chat.say(text)

func playerturn():
	Utils.heroesTurn = true
	change_state(State.PLAYER_TURN)

func change_state(next_state):
	current_state = next_state
