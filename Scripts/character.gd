extends Node2D

@export_category("General")
@export var Name = ""
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Strength = 0

func basic_attack():
	var Enemys = get_tree().get_nodes_in_group("Enemy")
	for enemy in Enemys:
		var dmg = Strength - (enemy.Defense - 1)
		enemy.HP -= dmg
		print_rich("{DMG} DMG!
{Name} ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}"
		.format({"DMG":dmg, 
		"Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()}))

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
