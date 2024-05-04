extends Node

class move:
	func __init__(targets:Array, dmg:float):
		var DMG = dmg
		var TARGETS = targets

	func use():
		for target in self.TARGETS:
			target.HP -= self.DMG

class basic_attack:
	extends move
	
