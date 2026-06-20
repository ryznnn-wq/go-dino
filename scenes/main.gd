extends Node

var tong = preload("res://scenes/rintangan.tscn")
var batu = preload("res://scenes/batu.tscn")
var batang = preload("res://scenes/batang.tscn")
var burung = preload("res://scenes/burung.tscn")

var jenis_rintangan := [tong, batu, batang]
var rintangan : Array
var tinggi_burung := [200, 390]


const dino_start_pos := Vector2i(150, 485)
const cam_start_pos := Vector2i(576, 324)

var speed : float
const start_speed : float = 10.0
const max_speed : float = 25
var screen_size : Vector2i
var score : int
var penambah_score : int = 10
var game_mulai : bool
var penambah_speed : int = 5000
var rintangan_terakhir 
var ground_height
var difficulty
const max_difficluty : int = 2
var high_score : int

func _ready():
	$game_over.get_node("Button").pressed.connect(new_game)
	new_game()
	screen_size = get_window().size
	score = 0
	tampil_score()
	game_mulai = false
	ground_height = $StaticBody2D.get_node("Sprite2D").texture.get_height()

func new_game():
	score = 0 
	tampil_score()
	get_tree().paused = false
	game_mulai = false
	difficulty = 0 
	
	for obs in rintangan:
		obs.queue_free()
	rintangan.clear()
	
	$player.position = dino_start_pos
	$player.velocity = Vector2i(0, 0)
	$StaticBody2D.position = Vector2i(0, 0)
	$Camera2D.position = cam_start_pos
	$UI.get_node("Start").show()
	$game_over.hide()

func _process(_delta):
	if game_mulai:
		speed = start_speed + score / penambah_speed
		if speed > max_speed:
			speed = max_speed
		adjust_difficulty()
		
		buat_rintangan()
		
		score += speed
		tampil_score()
		
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		if $Camera2D.position.x - $StaticBody2D.position.x > screen_size.x * 1.5 :
			$StaticBody2D.position.x += screen_size.x
		for obs in rintangan:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				buang_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_mulai = true
			$UI.get_node("Start").hide()
	

func buat_rintangan():
	if rintangan.is_empty() or rintangan_terakhir.position.x < score + randi_range(300, 500):
		var obs_type = jenis_rintangan[randi() % jenis_rintangan.size()]
		var obs 
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var tinggi_obs = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (tinggi_obs * obs_scale.y / 2) + 5
			rintangan_terakhir = obs
			tambah_obs(obs, obs_x, obs_y)
		if difficulty == max_difficluty:
			if (randi() % 2) == 0:
				obs = burung.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = tinggi_burung[randi() % tinggi_burung.size()]
				tambah_obs(obs, obs_x, obs_y)

func tambah_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	rintangan.append(obs)
	

func buang_obs(obs):
	obs.queue_free()
	rintangan.erase(obs)

func hit_obs(body):
	if body.name == "player":
		game_over()
	

func tampil_score():
	$UI.get_node("Score").text = "Score: " + str(score / penambah_score)

func tampil_high_score():
	if score > high_score:
		high_score = score
		$UI.get_node("High_score").text = "High Score: " + str(score / penambah_score)

func adjust_difficulty():
	difficulty = score / penambah_speed
	if difficulty > max_difficluty:
		difficulty = max_difficluty
 
func game_over():
	tampil_high_score()
	get_tree().paused = true
	game_mulai = false
	$game_over.show()
	
