extends Node

# neo i have no goddamn idea what you were on about with this but i do NOT think this is how classes work
var ATK
var TARGETS
var CritChance
var isCrit
var SelfColor
var Name
var Chat

func use_move(caller, used_move:String, targets:Array, atk:float, critChance:float):
	ATK = atk
	TARGETS = targets
	CritChance = critChance
	SelfColor = caller.SelfColor
	Name = caller.Name
	Chat = caller.Chat
	match used_move:
		"Basic Attack":
			use()

func get_crit() -> bool:
	isCrit = false
	if Utils.rng.randi_range(0,100) <= self.CritChance:
		isCrit = true
	return isCrit

func clamp_dmg(dmg:int,target) -> int:
	if dmg > target.HP:	
		dmg = target.HP
	return dmg

func use() -> int:
	for target in TARGETS:
		if not target.isDead:
			get_crit()
			if isCrit:
				ATK *= 2
			ATK -= (target.Defense - 1)
			var DMG = clamp_dmg(ATK, target)
			target.HP -= DMG
			print_damage(target, DMG, isCrit)
	return OK

func print_damage(enemy, damage:int, crit:bool):
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
