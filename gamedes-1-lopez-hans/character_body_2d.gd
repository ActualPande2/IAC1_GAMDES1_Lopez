extends CharacterBody2D

var health = 100
var player_name = "Kuya Ben"

func _ready():
	print(player_name, " has entered the scene with ", health, " HP.")
	
func take_damage(amount):
	health -= amount
	print("Health is now: ", health)
