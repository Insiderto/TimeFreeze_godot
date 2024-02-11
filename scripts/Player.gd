extends CharacterBody2D

@export var SPEED = 300.0  # Нормальная скорость персонажа
@export var JUMP_VELOCITY = -600.0  # Скорость прыжка
@export var coyote_time = 0.2 # Длительность "coyote time" в секундах
@export var jump_buffer_time = 0.1 # Длительность "jump buffer" в секундах
@onready var particles = $CPUParticles2D
@onready var progressBar = $"../CanvasLayer/ProgressBar"

var normal_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  # Нормальная гравитация

var coyote_time_timer = 0.0 # Таймер для отслеживания "coyote time"
var jump_buffer_timer = 0.0 # Таймер для "jump buffer"
var last_time_scale = 1.0 # предыдущий TimeScale

# Ресурсы
var energy = 100;

func _ready():
	Engine.time_scale = 1
	progressBar.value = energy
	
func _input(event):
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
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
	if is_on_floor():
		coyote_time_timer = coyote_time
	else:
		coyote_time_timer -= delta
		
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_time_timer = coyote_time  
		
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		
	if (Input.is_action_just_pressed("jump") or jump_buffer_timer > 0) and coyote_time_timer > 0:
		velocity.y = jump_velocity
		coyote_time_timer = 0  
		jump_buffer_timer = 0

func handle_movement(speed: float):
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
		
		
func _physics_process(delta: float) -> void:
	var adjusted_delta = delta / Engine.time_scale
	var adjusted_gravity = normal_gravity / Engine.time_scale
	var adjusted_speed = SPEED / Engine.time_scale
	var adjusted_jump_velocity = JUMP_VELOCITY / Engine.time_scale
	
	update_energy(adjusted_delta)
	control_effects()
	fix_time_scale()

	handle_movement(adjusted_speed)
	handle_jump(adjusted_delta, adjusted_jump_velocity, adjusted_gravity)
	
	move_and_slide()
	handle_collisions(adjusted_speed)
	
	last_time_scale = Engine.time_scale

func handle_collisions(speed: float):
	for i in get_slide_collision_count():		
		var c = get_slide_collision(i)		
		
		if c.get_collider() is RigidBody2D:
			var collider = c.get_collider() as RigidBody2D
			
			var push_normal = -c.get_normal();
			var push_force = (speed / 200);
			var push_angle = rad_to_deg(push_normal.angle_to(Vector2.UP))
			
			if  abs(0 - abs(push_angle)) < 2:
				push_force *= 11
				
			if abs(180 - push_angle) < 2:
				push_force = 2
			collider.apply_central_impulse(push_normal * push_force)

func handle_wall_jump(jump_velocity: float):
	if is_on_wall_only() && !is_on_floor():
		var last_wall_collision = get_last_slide_collision()
		var wall_normal = last_wall_collision.get_normal()
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity * 0.75
			velocity.x = wall_normal.x * jump_velocity
