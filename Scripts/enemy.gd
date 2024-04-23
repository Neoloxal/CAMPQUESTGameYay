extends Node2D

@export_category("General")
@export var Name = ""
@export_category("Health")
@export var Yoffset = 0
@export var MaxHP = 100
@onready var HP = MaxHP
@export_category("Stats")
@export var Level = 1
@export var Defense = 0
@export  var HPPL = 0
@onready var Status = []

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

func _process(_delta):
	if HP <= 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
		%HealthDisplay.text = "0/{MaxHP}".format(({"MaxHP":MaxHP}))
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(-1,-1), 0.5).from_current().set_trans(Tween.TRANS_BOUNCE)
		tween.play()
		await  tween.finished
		queue_free()
		
	if HP != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(%Health, "value", int(round((float(HP) / MaxHP) * 100)), .1).set_ease(Tween.EASE_IN_OUT)
	%HealthDisplay.text = "{HP}/{MaxHP}".format({"HP":HP,"MaxHP":MaxHP})
