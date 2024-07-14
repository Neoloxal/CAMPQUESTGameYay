extends Node

var ATK
var CALLER
var TARGETS
var USED_MOVE
var CritChance
var isCrit
var SelfColor
var Name
var Chat
var attackSuccessful

enum CLASS {NEUTRAL, STAMINA, STRENGTH, SOUL, SHARPNESS, SWIFTNESS}
var classes = []

func use_move(caller, used_move:String, targets:Array):
	CALLER = caller
	classes = [CALLER.ResourceJSONData["stats"]["stamina"], CALLER.ResourceJSONData["stats"]["strength"], CALLER.ResourceJSONData["stats"]["soul"], CALLER.ResourceJSONData["stats"]["sharpness"], CALLER.ResourceJSONData["stats"]["swiftness"]]
	USED_MOVE = used_move
	TARGETS = targets
	ATK = CALLER.Attack
	CritChance = CALLER.CritChance
	SelfColor = CALLER.SelfColor
	Name = CALLER.Name
	Chat = CALLER.Chat
	match used_move:
		"Basic Attack":
			use(CLASS.NEUTRAL, ATK, 0)
		"SP test":
			use(CLASS.SOUL, 6, 6)
	return attackSuccessful

func get_crit() -> bool:
	isCrit = false
	if Utils.rng.randi_range(0,100) <= self.CritChance:
		isCrit = true
	return isCrit

func clamp_dmg(dmg:int,target) -> int:
	if dmg > target.HP:	
		dmg = target.HP
	return dmg

func use(type, effect, sp_cost) -> int:
	if CALLER.SP >= sp_cost:
		CALLER.SP -= sp_cost
		var efficiency
		if type != CLASS.NEUTRAL:
			efficiency = (100 + (classes[fmod(type-1, 5)]-1)*25 + (classes[fmod(type, 5)]-1)*10 + (classes[fmod(type-2, 5)]-1)*10)/100
		else:
			efficiency = 1
		for target in TARGETS:
			if not target.isDead:
				effect *= efficiency
				get_crit()
				if isCrit:
					effect *= 2
				effect -= (target.Defense)
				var DMG = clamp_dmg(effect, target)
				target.HP -= DMG
				print_damage(target, DMG, isCrit)
		attackSuccessful = true
	else:
		attackSuccessful = false
	return OK

func print_damage(enemy, damage:int, crit:bool):
	# CRIT DMG MUST BE MULTIPLIED IN FUNC!!!!!!!
	var text = "[b]'S TURN[/b]
"
	var damageText
	if !crit:
		damageText = "[color={selfColor}]{selfName}[/color] uses {move} on {Name}, dealing {DMG} DMG!"
	else:
		damageText = "[color={selfColor}]{selfName}[/color] uses {move} on {Name}, [color=#FF0000]CRITICAL HITTING[/color] and dealing {DMG} DMG!"
	text += damageText + "
"
	text += "[color={enemyColor}]{Name}[/color] ({Level}): [color=#FF0000]{HP}/{MaxHP}[/color] {Status}"
	if enemy.HP <= 0:
		text += "
[b][color={enemyColor}]{Name}[/color] ({Level}) FALLS![/b]".format({"Name":enemy.Name.to_upper()})
	text = text.format({
		"selfColor": SelfColor,
		"selfName": Name,
		"move": USED_MOVE,
		"DMG":damage,
		"enemyColor":enemy.SelfColor, "Name":enemy.Name, "Level":enemy.Level, "HP":enemy.HP, "MaxHP":enemy.MaxHP, "Status":enemy.get_status()
	})
	text = "[b][color={selfColor}]{selfName}[/color][/b]".format({"selfColor":SelfColor, "selfName":Name.to_upper()}) + text
	Chat.say(text)
