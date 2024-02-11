extends Node

# Изначальная и целевая громкость
var start_volume_db: float
var target_volume_db: float = -20.0 # Целевая громкость, до которой должен затихнуть звук
# Длительность затухания
var fade_duration: float = 5.0
# Время старта затухания
var fade_start_time: float

func _ready():
	set_process(false) # Изначально отключаем _process

func fade_out():
	self.volume_db = -15
	#start_volume_db = self.volume_db # Сохраняем начальную громкость
	#fade_start_time = Time.get_ticks_msec()
	#set_process(true) # Активируем _process при начале затухания

func fade_in():
	self.volume_db = 0
	
func _process(delta):
	pass
	#var elapsed_time = (Time.get_ticks_msec() - fade_start_time) / 1000.0
	#if elapsed_time <= fade_duration:
		#var new_volume = lerp(start_volume_db, target_volume_db, elapsed_time / fade_duration)
		#self.volume_db = max(new_volume, target_volume_db) # Не позволяем громкости упасть ниже целевой
	#else:
		#self.volume_db = target_volume_db # Устанавливаем громкость точно в целевое значение
		##$".".stop() # Опционально останавливаем воспроизведение, если необходимо
		#set_process(false) # Останавливаем _process после заверш
