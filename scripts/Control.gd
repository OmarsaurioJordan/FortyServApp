extends Control

var node_card = preload("res://objects/Carta.tscn")
var mouse = 0 # 0:crea 1:erase 2:move 3:see 4:info
var cogedera = Vector2(0, 0) # punto para mover carta
var cogida = null # carta a ser movida
var escalaMouse = Vector2(0, 0) # guarda la escala por defecto
var radButton = 110 # radio para detectar boton
var botSobre = null # sobre que boton esta

func _ready():
	randomize()
	var resDisp = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width") * 0.8,
		ProjectSettings.get_setting("display/window/size/viewport_height") * 0.8)
	#get_window().set_size(resDisp)
	get_window().set_position(Vector2(0, 0))
	escalaMouse = get_node("Mouse").scale
	get_node("Lienzo/Orden").visible = false
	set_process_input(true)
	set_process(true)
	cambioLienzo(false, true)
	$Info.text = Textos(0)

func _process(delta):
	if cogida != null:
		var pos = get_viewport().get_mouse_position() + cogedera
		pos[0] = clamp(pos[0], 195, 4000 - 195)
		pos[1] = clamp(pos[1], 720 + 251, 2800 - 251)
		cogida.position = pos
		cogida.get_parent().move_child(cogida, -1)
	MouseGo()

func MouseGo():
	var pp = get_viewport().get_mouse_position()
	# verificar si esta sobre boton
	botSobre = null
	var bot = get_node("Bot").get_children()
	for b in bot:
		if b.position.distance_to(pp) < radButton:
			botSobre = b
			break
	# modificar mouse
	var m = get_node("Mouse")
	m.position = pp
	if m.position.y < get_node("Panel/Borde").position.y:
		m.frame = 5
		if botSobre != null:
			m.scale = escalaMouse * 1.75
		else:
			m.scale = escalaMouse
	else:
		m.frame = mouse
		m.scale = escalaMouse

func Crear(pos, forzatipo = -1):
	if pos[0] > 195 and pos[0] < 4000 - 195:
		if pos[1] > 720 + 251 and pos[1] < 2800 - 251:
			if get_node("Tirada").get_children().size() < 40:
				var aux = node_card.instantiate()
				get_node("Tirada").add_child(aux)
				aux.position = pos
				if forzatipo != -1:
					aux.Cambio(forzatipo)
				else:
					aux.Ruleta()

func Tomar(pos):
	var res = null
	for c in get_node("Tirada").get_children():
		if pos[0] > c.position[0] - 195 and pos[0] < c.position[0] + 195:
			if pos[1] > c.position[1] - 251 and pos[1] < c.position[1] + 251:
				res = c
	return res

func Rotar(pos):
	var aux = Tomar(pos)
	if aux != null:
		aux.Girar()

func Borrar(pos):
	var aux = Tomar(pos)
	if aux != null:
		aux.queue_free()
		cogida = null

func Limpiar():
	cogida = null
	for c in get_node("Tirada").get_children():
		c.queue_free()

func Todas():
	if get_node("Tirada").get_children().size() == 0:
		var alt = 0
		var res = 0
		for s in range(40):
			Crear(Vector2(251 + s * 390 - res, 985 + alt), s)
			if s == 9 or s == 19 or s == 29:
				alt += 500
				res += 3900

func Agarra(pos):
	cogida = Tomar(pos)
	if cogida != null:
		cogedera = cogida.position - pos

func Suelta():
	cogida = null

func Leer(pos):
	var aux = Tomar(pos)
	if aux != null:
		Informacion(aux.tipo, aux.get_node("Elemento").visible)

func Informacion(ind, vis):
	get_node("Carta").Ver(vis)
	get_node("Carta").Cambio(ind)

func Pulsado(bot_name):
	if bot_name == "BotCreate":
		mouse = 0
	elif bot_name == "BotDelete":
		mouse = 1
	elif bot_name == "BotMove":
		mouse = 2
	elif bot_name == "BotVer":
		mouse = 3
	elif bot_name == "BotInfo":
		mouse = 4
	elif bot_name == "BotCardL":
		get_node("Carta").Ver(true)
		get_node("Carta").Siguiente(false)
	elif bot_name == "BotCardR":
		get_node("Carta").Ver(true)
		get_node("Carta").Siguiente(true)
	elif bot_name == "BotAzar":
		get_node("Carta").Ver(true)
		get_node("Carta").Ruleta()
	elif bot_name == "BotLienzoL":
		cambioLienzo(true)
	elif bot_name == "BotLienzoR":
		cambioLienzo(true)
	elif bot_name == "Titulo":
		OS.shell_open("https://www.adventuresinwoowoo.com/thefortyservants/")
	elif bot_name == "Omwekiatl":
		OS.shell_open("https://omwekiatl.itch.io/")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mouse == 0:
					Crear(event.position)
				elif mouse == 1:
					Borrar(event.position)
				elif mouse == 2:
					Agarra(event.position)
				elif mouse == 3:
					Rotar(event.position)
				elif mouse == 4:
					Leer(event.position)
				# ver si pulso boton
				if botSobre != null:
					Pulsado(botSobre.name)
			else:
				if mouse == 2:
					Suelta()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			mouse += 1
			if mouse > 4:
				mouse = 0
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			mouse -= 1
			if mouse < 0:
				mouse = 4
	elif event is InputEventKey:
		if event.is_action_pressed("mouse_crear"):
			mouse = 0
		elif event.is_action_pressed("mouse_borrar"):
			mouse = 1
		elif event.is_action_pressed("mouse_mover"):
			mouse = 2
		elif event.is_action_pressed("mouse_ver"):
			mouse = 3
		elif event.is_action_pressed("mouse_info"):
			mouse = 4

func Textos(ind):
	if ind == 0:
		return "Los 40 servidores son un grimorio de espíritus en baraja de cartas, para adivinación y magiak, creados por Tommie Kelly. La aplicación explica brevemente cualidades o significados de cada entidad y permite hacer tiradas con manejo realista."
	elif ind == 1:
		return "iluminación de los lugares bondadosos y alegres del ser, energía, poder, vitalidad, ser positivo y expansivo, resplandor y éxito."
	elif ind == 2:
		return "enseñanza, sabiduría emocional, consejo amoroso ante altibajos de la vida, a veces dice lo que no se quiere oír pero que es lo mejor, orienta a ser autosuficiente."
	elif ind == 3:
		return "enseñanza, conocimiento práctico, consejo experto para mejorar en las cosas que queremos lograr, ayuda externa, aprender lo práctico del conocimiento."
	elif ind == 4:
		return "comunicación, intentos de comunicación, algo importante que decir o recibir, atención y escucha, saber expresarse, exponer al público, escribir, declamar."
	elif ind == 5:
		return "dar, generosidad y gratitud, milagros y regalos divinos, regalos en general, comercio justo, trueque, devolver favores a los demás, flujo de energía."
	elif ind == 6:
		return "orientación y nutrición, protección amorosa para evitar auto dañarse, cobijo y sustento primordial, fertilidad y nacimiento de cosas nuevas, sustento y alimento."
	elif ind == 7:
		return "espíritu, yo superior, evolución personal completada, ser la mejor versión de sí mismo, un consejo del yo anciano, del yo en su mejor forma."
	elif ind == 8:
		return "restricción, disciplina y autocontrol, negación de cosas placenteras para ahorrar y amplificar a futuro, tensión."
	elif ind == 9:
		return "iluminación de los lugares oscuros y desagradables de nosotros, lo que no queremos ver o aceptar, decepción, mentiras que nos decimos para subir nuestro ego."
	elif ind == 10:
		return "análisis e intelecto, razón y deducción, filosofar, dejar de lado emociones e intuición, dominar la charla mental a su favor, evitar actuar por impulso."
	elif ind == 11:
		return "elegir el propio camino, hacer su propio destino, madurez, control, conocer y administrar los múltiples egos."
	elif ind == 12:
		return "recibir, tener todo, estar rodeado de prosperidad y fortuna, éxito tanto económico como en otros logros de la vida, buena suerte."
	elif ind == 13:
		return "amor y atracción, emociones profundas pero en un estado más allá de la lujuria, más allá de lo físico, amor incondicional y armonioso, amistad, empatía."
	elif ind == 14:
		return "placer, hedonismo, fuerza sexual y atracción, seducción, disfrutar de las cosas de la vida sin limitación o reservas, belleza y juventud."
	elif ind == 15:
		return "salud, curación, sanación, cuidar de nosotros así como de los demás, riesgo de enfermedad o necesidad de reposo, enfermedades pueden ser emocionales también."
	elif ind == 16:
		return "ira, cólera, lucha, guerra, agresión, violencia, protesta ante la injusticia percibida, preocupaciones y acción acorde, indignación con energía para manifestarla."
	elif ind == 17:
		return "inmensidad, inspirarse en ver lo pequeño que es ante el universo, el macrocosmos, patrones y estaciones de la vida, orden cósmico, reducir el egotismo."
	elif ind == 18:
		return "creatividad, inspiración que debe ser encaminada o agarrada, una semilla que puede crecer y dar frutos a futuro, imaginación que puede llevarse a manifestación."
	elif ind == 19:
		return "nada que perder, tocar fondo, caos y desorden, desequilibrio, ansiedad al no saber qué hacer, atrapado en su cabeza, el microcosmos."
	elif ind == 20:
		return "ponerse en el ojo público, hacerse notar, propagar ideas o mensajes, fama, tecnologías de la comunicación, estar en multitud, todo no es lo que parece, mentiras."
	elif ind == 21:
		return "destino, las cosas están predeterminadas, dejarse llevar, la voluntad del universo o los dioses, todo es como debe ser así no guste en el momento."
	elif ind == 22:
		return "enseñanza, la teoría detrás de las cosas, búsqueda de información, estudio y entendimiento, lectura."
	elif ind == 23:
		return "restricción interna, creencias limitantes, auto saboteo mental, traumas y bloqueos subconscientes, inseguridad y sensación de inferioridad, decepción."
	elif ind == 24:
		return "levantarse sobre todo, cambiar de ángulo de visión, relajarse ante problemas, mente abierta, dejar el orgullo, lo onírico y el vuelo astral."
	elif ind == 25:
		return "magia y hechizos, efectos o fenómenos sobrenaturales, influencias mentales o espirituales, cosas inusuales o extrañas, fuerza de voluntad y poder."
	elif ind == 26:
		return "intercesión de terceros y confianza en expertos, servicios de terceros, comunicación entre las partes, entre el cielo y la tierra, leyes y reglamentos sociales."
	elif ind == 27:
		return "no tener nada, cansancio, desgaste, falta de energía y ganas, vacío y soledad, fin de los esfuerzos, rendirse, esterilidad y decaimiento, finalización."
	elif ind == 28:
		return "protección y seguridad, estar a salvo, procurar evitar riesgos, puede alguién o algo estar protegiéndonos, todo estará bien, ¿protegido o protegerse? es muy contextual."
	elif ind == 29:
		return "ampliar horizontes, superar límites, salir de zonas de confort, convertirse en una persona mejor, aprender nuevas habilidades o talentos, crecimiento personal."
	elif ind == 30:
		return "libre de obstáculos, nuevas oportunidades, múltiples caminos y puertas que conocer, suerte y libertad en el rumbo, tener acceso a cosas fuera de alcance."
	elif ind == 31:
		return "restricción externa, obstáculos impuestos por fuerzas que escapan a su control, competitividad, accidentes, percances, sentirse bloqueado."
	elif ind == 32:
		return "todo en equilibrio y órden, serenidad y tranquilidad, buena salud, restablecimiento, procurar el cuidado conscientemente, buscar el balance."
	elif ind == 33:
		return "ampliar horizontes, salir de zonas de confort, divertirse, hacer cosas nuevas y emocionantes, viajes de vacaciones, probar suerte."
	elif ind == 34:
		return "tener acceso a cosas fuera de alcance, cosas que ya son conscientes, brinda la clave para abrir las puertas que ya se han hallado, victoria."
	elif ind == 35:
		return "mente inconsciente colectiva, retirarse de pensar en problemas, dejarlos ir, meditar y dormir para dejar al subconsciente trabajar, vivir en presente."
	elif ind == 36:
		return "finalización, terminaciones, aprender del pasado, recordar el pasado, contacto con ancestros, la historia (propia o humana), no repetir errores."
	elif ind == 37:
		return "aceptación y resiliencia, las cosas no siempre salen bien pero todo sigue, la vida es dura pero mientras hay vida se vive, perder pero no darse por vencido."
	elif ind == 38:
		return "restricción autoimpuesta a voluntad, hacer la vida más sencilla, descanso y restauración, estar fuera de la vista pública, silencio e introspección."
	elif ind == 39:
		return "intuición y adivinación, instinto y confianza, evitar pensar en exceso, fluir por la vida, acceso a información que el consciente no tiene, videnciar el futuro."
	elif ind == 40:
		return "nada que perder, sacrificio, reparación, hacer lo que sea necesario a cambio de un costo, transmutación luego de la destrucción."

func cambioLienzo(is_left, force=false):
	var li = get_node("Lienzo/Orden")
	if force:
		li.frame = 0
	elif is_left:
		if li.frame == 0:
			li.frame = 16
		else:
			li.frame = li.frame - 1
	else:
		if li.frame == 16:
			li.frame = 0
		else:
			li.frame = li.frame + 1
	li.visible = li.frame != 0
	for t in get_node("Lienzo/Textos").get_children():
		t.visible = false
	get_node("Lienzo/Textos/F" + str(li.frame)).visible = true
