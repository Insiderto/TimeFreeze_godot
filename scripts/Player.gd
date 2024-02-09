extends CharacterBody2D

@export var SPEED = 300.0  # Нормальная скорость персонажа
@export var JUMP_VELOCITY = -600.0  # Скорость прыжка
@export var coyote_time = 0.2 # Длительность "coyote time" в секундах
@onready var particles = $CPUParticles2D
@onready var progressBar = $"../CanvasLayer/ProgressBar"

var normal_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  # Нормальная гравитация

var coyote_time_timer = 0.0 # Таймер для отслеживания "coyote time"
var last_time_scale = 1.0
var energy = 100;


func _ready():
	Engine.time_scale = 1
	progressBar.value = energy
	
func _input(event):
	if event.is_action_pressed("freeze_time") && energy > 0:
		Engine.time_scale = 0.05
	if event.is_action_released("freeze_time"):
		Engine.time_scale = 1
	if event.is_action_pressed("restart_game"):
		get_tree().reload_current_scene()
	
func is_time_slowed():
	return Engine.time_scale < 1
	
func update_energy(delta: float):
	if energy > 0 && is_time_slowed():
		energy -= 20 * delta 
		progressBar.value = energy
	else:
		Engine.time_scale = 1
		
func control_effects(): 
	particles.emitting = is_time_slowed()
	
func fix_time_scale():
	if last_time_scale != Engine.time_scale:
		velocity.y *= last_time_scale / Engine.time_scale
		last_time_scale = Engine.time_scale
		
func handle_jump(delta: float, jump_velocity: float, gravity: float):
	# Обновляем таймер времени кайота
	if is_on_floor():
		coyote_time_timer = coyote_time
	else:
		coyote_time_timer -= delta

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_time_timer = coyote_time  # Сбрасываем таймер при касании земли

	# Проверяем условие для прыжка с учетом времени кайота
	if Input.is_action_just_pressed("ui_accept") and coyote_time_timer > 0:
		velocity.y = jump_velocity
		coyote_time_timer = 0  # Сброс таймера после прыжка

func handle_movement(speed: float):
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
		
		
func _physics_process(delta: float) -> void:
	var adjusted_delta = delta / Engine.time_scale
	var adjusted_gravity = normal_gravity / Engine.time_scale
	var adjusted_speed = SPEED / Engine.time_scale
	var adjusted_jump_velocity = JUMP_VELOCITY / Engine.time_scale
	
	update_energy(adjusted_delta)
	control_effects()
	fix_time_scale()
	handle_jump(adjusted_delta, adjusted_jump_velocity, adjusted_gravity)
	handle_movement(adjusted_speed)

	move_and_slide()
	handle_collisions(adjusted_speed)
	
	last_time_scale = Engine.time_scale


func handle_collisions(speed):
	for i in get_slide_collision_count():		
		var c = get_slide_collision(i)		
		if c.get_collider() is RigidBody2D:
			var collider = c.get_collider() as RigidBody2D
			collider.apply_central_impulse( -c.get_normal() * (speed / 200))
