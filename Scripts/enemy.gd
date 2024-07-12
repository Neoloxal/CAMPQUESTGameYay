extends Node2D

@export_category("General")
@export var Name:String
@export var SelfColor:String
@export var Chat: RichTextLabel
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Defense = 0
@export_subgroup("Level")
@export  var HPPL = 0
@export var Level = 1
@onready var Status = []
@export_category("AI")
@export var Moves:Array[String]

@onready var isDead = false

signal turnFinished

# Misc
func Death():
	isDead = true
	var tween = get_tree().create_tween()
	tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "0/{MaxHP}".format(({"MaxHP":MaxHP}))
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(%RemoveHealth, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	await  tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(-1,-1), 0.5).from_current().set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	await  tween.finished
	queue_free()

func clamp_dmg(dmg:int,enemy):
	if dmg > enemy.HP:
		dmg = enemy.HP
	return dmg

func get_crit(CritChance):
	""" MAKE SURE ATTACK HAS
		if isCrit: 
			dmg *= 2
	"""
	var isCrit = false
	if Utils.rng.randi_range(0,100) <= CritChance:
		isCrit = true
	return isCrit

func print_damage(enemy,damage:int,crit:bool):
	# CRIT DMG MUST BE MULTIPLIED IN FUNC!!!!!!!
	var text = "{DMG} DMG!
[color={selfColor}][{selfName}][/color] [color={enemyColor}]{Name}[/color]: [color=#FF0000]{HP}/{MaxHP}[/color]".format({
	"selfColor":SelfColor,
	"selfName":Name,
	"DMG":damage, 
	"enemyColor":enemy.SelfColor, "Name":enemy.Name, "HP":enemy.HP, "MaxHP":enemy.MaxHP
	})
	if crit:
		text = "[color=#FF0000]CRIT![/color]" + text
	text = "[color={selfColor}][{selfName}][/color] ".format({"selfColor":SelfColor, "selfName":Name}) + text
	Chat.say(text)

# Moves
func bite():
	var heroes = get_tree().get_nodes_in_group("Hero")
	for hero in heroes:
		if hero.HP != 0:
			var DMG = 6 + (Level - 1)
			#var isCrit = get_crit(.75)
			print_damage(hero, DMG, false)
			return

func get_status():
	var strStatus = ""
	for status in Status:
		if status != Status[len(Status)-1]:
			strStatus = strStatus + status + ", "
		else:
			strStatus = strStatus + status
	return strStatus

func _ready():
	%Animator.play("{Name}Idle".format({"Name":Name}))
	
	MaxHP = MaxHP + ((Level-1) * HPPL)
	HP = MaxHP
	%Health.position.y += Yoffset
	%RemoveHealth.position.y += Yoffset

func _process(_delta):
	if HP <= 0:
		Death()
		
	if HP != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(%RemoveHealth, "value", int(round((float(HP) / MaxHP) * 100)), .3).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "{HP}/{MaxHP}".format({"HP":HP,"MaxHP":MaxHP})
	%NameDisplay.text = "[color={selfColor}]{name}[/color] ({level})".format({
		"selfColor":SelfColor,
		"name":Name,
		"level":Level
		})

func enemyturn():
	call(Moves[Utils.rng.randi_range(0,Moves.size()-1)])
	emit_signal("turnFinished")
