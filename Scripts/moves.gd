extends Node

class move:
	func init_values(targets:Array, dmg:float, critChance:float) -> void:
		var DMG = dmg
		var TARGETS = targets
		var CritChance = critChance
	
	func get_crit() -> bool:
		var isCrit = false
		if Utils.rng.randi_range(0,100) <= self.CritChance:
			isCrit = true
		return isCrit
	
	func clamp_dmg(dmg:int,target) -> int:
		if dmg > target.HP:
			dmg = target.HP
		return dmg
	
	func use() -> int:
		for target in self.TARGETS:
			target.HP -= self.DMG
		return OK

class basic_attack:
	extends move
	
	func __init__(target:Node, Strength:int, CritChance:float) -> void:
		init_values([target], Strength, CritChance)
		
		var TARGET = self.TARGETS
	
	func _use():
		if not self.TARGET.isDead:
			var isCrit = get_crit()
			self.DMG = self.DMG - (self.TARGET.Defense - 1)
			if isCrit:
				self.DMG *= 2
			var realDMG = clamp_dmg(self.DMG,self.TARGET)
			self.TARGET.HP -= realDMG
			return OK
