extends Node2D

@export_category("General")
@export var Name:String
@export var SelfColor:String
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
@export var Moves:Array

@onready var isDead = false

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

# Moves
func bite():
	print("{Name} {Level}".format({"Name":Name,"Level":Level}))
	const RESULT = "SUCCSEUS"
	return RESULT

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
	#Moves[0].call()
