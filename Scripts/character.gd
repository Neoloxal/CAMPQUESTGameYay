extends Node2D

@export_category("General")
@export var Name = ""
@export var SelfColor:String
@export var Chat: RichTextLabel
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Strength = 0
@export var Sharpness = 0
@onready var CritChance = int(round((1 - pow(0.99, float(Sharpness))) * 100))

signal turnFinished
signal UIFinished

# Attack Utils
func clamp_dmg(dmg:int,enemy):
	if dmg > enemy.HP:
		dmg = enemy.HP
	return dmg

func get_crit():
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
[color={selfColor}][{selfName}][/color] [color={enemyColor}]{Name}[/color] ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}".format({
	"selfColor":SelfColor,
	"selfName":Name,
	"DMG":damage, 
	"enemyColor":enemy.SelfColor, "Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()
	})
	if crit:
		text = "[color=#FF0000]CRIT![/color]" + text
	text = "[color={selfColor}][{selfName}][/color] ".format({"selfColor":SelfColor, "selfName":Name}) + text
	Chat.say(text)

# Attacks
func basic_attack():
	var Enemys = get_tree().get_nodes_in_group("Enemy")
	for enemy in Enemys:
		if not enemy.isDead:
			var isCrit = get_crit()
			var dmg = Strength - (enemy.Defense - 1)
			if isCrit:
				dmg *= 2
			var realDMG = clamp_dmg(dmg,enemy)
			enemy.HP -= realDMG
			print_damage(enemy,dmg,isCrit)
			return

func _ready():
	%Animator.play("{Name}Idle".format({"Name":Name}))
	
	%Health.position.y += Yoffset
	%RemoveHealth.position.y += Yoffset
	
	Chat.text = ""

func _process(_delta):
	if HP != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(%RemoveHealth, "value", int(round((float(HP) / MaxHP) * 100)), .3).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "{hp}/{maxhp}".format({"hp":HP,"maxhp":MaxHP})

func attackUI():
	while not Input.is_action_just_pressed("Use"):
		pass
	basic_attack()
	emit_signal("UIFinished")

func playerturn():
	attackUI()
	await UIFinished
	emit_signal("turnFinished")
