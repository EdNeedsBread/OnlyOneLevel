extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tip_area_entered(area):
	print("hit")
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_damage = 10
		
		hitbox.damage(attack)
