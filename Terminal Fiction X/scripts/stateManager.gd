extends Node

enum modes {GROUND, HANGING, AIR}
enum views {FP, TP}
enum moveTypes {move2D, move3D}

var mode : int = modes.GROUND setget set_mode
var view : int = views.TP
var moveType : int = moveTypes.move2D


func set_mode(newMode):
	if mode == newMode: return
	mode = newMode


func set_view(newView):
	if view == newView: return
	view = newView


func change_view():
	match view:
		views.TP: 
			print("view changed to FP")
			set_view(views.FP)
		views.FP: 
			print("view changed to TP")
			set_view(views.TP)
