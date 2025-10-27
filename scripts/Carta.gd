extends Node2D

const elemento = [
	3, 2, 2, 2, 4, 0, 4, 1, 1, 2, 0, 0, 1, 3, 1,
	3, 0, 2, 1, 3, 4, 2, 0, 2, 4, 4, 0, 3, 0, 4,
	3, 1, 3, 0, 2, 4, 1, 4, 1, 3
]

var tipo = 0

func _ready():
	Ruleta()
	Ver(false)

func Siguiente(derecha):
	if derecha:
		if tipo == 39:
			Cambio(0)
		else:
			Cambio(tipo + 1)
	else:
		if tipo == 0:
			Cambio(39)
		else:
			Cambio(tipo - 1)

func Cambio(ind):
	tipo = ind
	get_node("Elemento").frame = elemento[tipo]
	get_node("Elemento/Imagen").frame = tipo
	get_node("Elemento/Sigil").frame = tipo
	get_node("Elemento/Titulo").frame = tipo
	# poner el cambio en pantalla
	if get_parent().name != "Tirada":
		if get_node("Vacio").visible:
			get_node("/root/Control/Info").text = get_node("/root/Control").Textos(0)
			get_node("/root/Control/Numero").text = "0"
		else:
			get_node("/root/Control/Info").text = get_node("/root/Control").Textos(tipo + 1)
			get_node("/root/Control/Numero").text = str(tipo + 1)

func Ver(ver):
	get_node("Elemento").visible = ver
	get_node("Vacio").visible = !ver

func Girar():
	Ver(!get_node("Elemento").visible)

func Azar():
	randomize()
	var ss = []
	for s in range(40):
		ss.append(s)
		if randf() > 0.5:
			randomize()
		else:
			ss.shuffle()
	for r in range(randi() % 40 + 1):
		ss.shuffle()
	return ss[randi() % 40]

func Ruleta():
	if get_parent().name == "Tirada":
		var cards = get_parent().get_children()
		tipo = -1
		var t = -1
		while t == -1:
			t = Azar()
			for c in cards:
				if c.tipo == t:
					t = -1
					break
		Cambio(t)
	else:
		Cambio(Azar())
