@icon("./Notchz.svg")
@tool
class_name Notchz
extends Control

## Safe area node and automatic set from cutouts
##
## Is safe area node that set offsets by member or automatic set from cutout areas to ensure fit within safe area. 
## It's useful for build fullscreen mobile games or apps.

enum SET_FROM_CUTOUTS_MODE{
	OFF, ## Never set by automatically
	ONCE, ## Set once when node is ready
	ALWAYS, ## Always set by automatically
}
## Set offsets from cutouts by mode.
@export var set_from_cutouts: SET_FROM_CUTOUTS_MODE = 2

@export_group("Offsets")

## Set left offset if more than automatic set from cutouts.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var left: int = 0:
	set(x):
		left = max(0, x)
		curret_offsets[0] = left
		refresh()

## Set top offset if more than automatic set from cutouts.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var top: int = 0:
	set(x):
		top = max(0, x)
		curret_offsets[1] = top
		refresh()

## Set right offset if more than automatic set from cutouts.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var right: int = 0:
	set(x):
		right = max(0, x)
		curret_offsets[2] = right
		refresh()

## Set buttom offset if more than automatic set from cutouts.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var buttom: int = 0:
	set(x):
		buttom = max(0, x)
		curret_offsets[3] = buttom
		refresh()

## Property for set base [Control]'s offsets.
## Can set by contain [left, top, right, buttom].
## @experimental: It may be private in future version.
@onready var curret_offsets: Array = [left, top, right, buttom]:
	set(x):
		curret_offsets.resize(3)
		curret_offsets = x
		offset_left = curret_offsets[0]
		offset_top = curret_offsets[1]
		offset_right = -curret_offsets[2]
		offset_bottom = -curret_offsets[3]

func _init() -> void:
	layout_mode = 1
	_set_anchors_layout_preset(-1)
	anchor_right = 1
	anchor_bottom = 1
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_PASS

func _ready() -> void:
	refresh()

func _get_configuration_warnings() -> PackedStringArray:
	var warning = []
	if get_parent() is Container:
		warning.append("Self can't work with Container as parent")
	return warning

func _process(delta: float) -> void:
	if set_from_cutouts == 2:
		refresh()

## Method for set offsets.
func refresh(able_set_from_cutout: bool = (set_from_cutouts > 1)) -> void:
	
	var new_offsets = [left,top,right,buttom]
	var cutouts: Array[Rect2] = DisplayServer.get_display_cutouts()
	
	if !Engine.is_editor_hint() and able_set_from_cutout:
		for cutout in cutouts:
			# When screen is landscape and it not for macOS
			if DisplayServer.window_get_size().x > DisplayServer.window_get_size().y and not (OS.get_name() == "macOS"):
				if cutout.position.x >= DisplayServer.window_get_size().x / 3 and cutout.end.x <= DisplayServer.window_get_size().x / 3 * 2:
					if cutout.end.y < DisplayServer.window_get_size().y / 2:
						if cutout.end.y > new_offsets[1]:
							new_offsets[1] = cutout.end.y
					if cutout.end.y > DisplayServer.window_get_size().y / 2:
						var re = DisplayServer.window_get_size().x - cutout.position.x
						if re > new_offsets[3]:
							new_offsets[3] = re
				elif cutout.end.x < DisplayServer.window_get_size().x / 2:
					if cutout.end.x > new_offsets[0]:
						new_offsets[0] = cutout.end.x
				elif cutout.end.x > DisplayServer.window_get_size().x / 2:
					var re = DisplayServer.window_get_size().x - cutout.position.x
					if re > new_offsets[2]:
						new_offsets[2] = re
			# When screen is portrail
			else:
				if cutout.position.y >= DisplayServer.window_get_size().y / 3 and cutout.end.y <= DisplayServer.window_get_size().y / 3 * 2:
					if cutout.end.x < DisplayServer.window_get_size().x / 2:
						if cutout.end.x > new_offsets[0]:
							new_offsets[0] = cutout.end.x
					if cutout.end.x > DisplayServer.window_get_size().x / 2:
						var re = DisplayServer.window_get_size().y - cutout.position.y
						if re > new_offsets[2]:
							new_offsets[2] = re
				elif cutout.end.y < DisplayServer.window_get_size().y / 2:
					if cutout.end.y > new_offsets[1]:
						new_offsets[1] = cutout.end.y
				elif cutout.end.y > DisplayServer.window_get_size().y / 2:
					var re = DisplayServer.window_get_size().y - cutout.position.y
					if re > new_offsets[3]:
						new_offsets[3] = re
	
	curret_offsets = new_offsets
