extends CharacterBody2D
	 
const  gravity : int = 4200
const jump_speed : int = -1800

func _physics_process(delta):
	velocity.y  += gravity * delta
	if is_on_floor():
		if not get_parent().game_mulai:
			$AnimatedSprite2D.play("diam")
		else:
			$lari.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = jump_speed
			elif Input.is_action_pressed("ui_down"):
				$lari.disabled = true
				$AnimatedSprite2D.play("jongkok")
			else:
				$AnimatedSprite2D.play("lari")
	else :
			$AnimatedSprite2D.play("lompat")
	
	move_and_slide()
