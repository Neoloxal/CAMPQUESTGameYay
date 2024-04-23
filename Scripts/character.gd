extends Node2D

@export_category("General")
@export var Name = ""
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Strength = 0
@export var Sharpness = 0
@onready var CritChance = int(round((1 - pow(0.99, float(Sharpness))) * 100))

func print_damage(enemy,damage:int,crit:bool):
	# DMG MUST BE MULTIPLIED IN FUNC!!!!!!!
	if crit:
		print_rich("CRIT! {DMG} DMG!
{Name} ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}"
		.format({"DMG":damage, 
		"Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()}))
	else:
		print_rich("{DMG} DMG!
{Name} ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}"
		.format({"DMG":damage, 
		"Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()}))

func basic_attack():
	var Enemys = get_tree().get_nodes_in_group("Enemy")
	for enemy in Enemys:
		var isCrit = false
		if Utils.rng.randi_range(0,100) <= CritChance:
			isCrit = true
		var dmg = Strength - (enemy.Defense - 1)
		if isCrit:
			dmg *= 2
		enemy.HP -= dmg
		print_damage(enemy,dmg,isCrit)

func _ready():
	%Animator.play("{Name}Idle".format({"Name":Name}))
	
	%Health.position.y += Yoffset

func _process(_delta):
	if HP != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "{hp}/{maxhp}".format({"hp":HP,"maxhp":MaxHP})
	
	if Input.is_action_just_pressed("Use"):
		basic_attack()
