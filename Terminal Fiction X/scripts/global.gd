extends Node


func get_rand(): #gets a random number from -1 to 1
	randomize()
	var rand = randi() % 2
	match rand:
		0: rand = -(randi() % 2)
		1: rand = randi() % 2
	print(rand)
	return rand
