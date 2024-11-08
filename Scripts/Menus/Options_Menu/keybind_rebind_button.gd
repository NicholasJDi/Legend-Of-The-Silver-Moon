class_name HotkeyRebindButton
extends Control

@onready var label : Label = $HBoxContainer/Label
@onready var label_2: Label = $HBoxContainer/Label2
@onready var button : Button = $HBoxContainer/Button

@export var action_name : String = ""
@export var display_name : String = ""
@export var can_change : bool = true
@export var action : String = ""

var button_is_toggled = false


func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	if not action_name.is_empty():
		if SettingsDataContainer.Get_Data("controls", action_name) == null:
			set_text_for_key()
		elif can_change:
			load_keybinds()
			set_text_for_key()
		else:
			set_text_for_key()
	else:
		set_text_for_key()


func load_keybinds():
	if not Global.Load:
		var keyEvent = InputEventKey.new()
		keyEvent.keycode = int(SettingsDataContainer.Get_Data("controls", action_name))
		print("key_event_%s" % keyEvent)
		rebind_action_key(keyEvent)


func set_action_name():
	label.text = display_name
	if not can_change:
		label_2.text = "Unable To Change"


func set_text_for_key():
	if can_change:
		var action_event = InputMap.action_get_events(action_name)
		var action_keycode = OS.get_keycode_string(action_event[0].physical_keycode)
		button.text = action_keycode
		Console.Print("Global","Global",action_keycode)
		print("set_%s" % action_name)
		print("val = %s" % action_keycode)
	else:
		var action_keycode = action
		button.text = action_keycode	
		print("set_%s" % action_name)
		print("val = %s" % action_keycode)


func _on_button_toggled(button_pressed: bool):
	if  can_change:
		button_is_toggled = button_pressed
		if not action_name.is_empty() and button_pressed:
			button.text = "Press Any Key..."
			set_process_unhandled_key_input(button_pressed)
			for keybind_button in get_tree().get_nodes_in_group("keybind_button"):  
				if keybind_button.action_name != action_name:
					keybind_button.button.toggle_mode = false
					keybind_button.set_process_unhandled_key_input(false)
			
		else:
			if not action_name.is_empty():
				for keybind_button in get_tree().get_nodes_in_group("keybind_button"):  
					if keybind_button.action_name != action_name:
						keybind_button.button.toggle_mode = true
						keybind_button.set_process_unhandled_key_input(true)
						set_text_for_key()


func _unhandled_key_input(inputevent):
	if button_is_toggled:
		rebind_action_key(inputevent)
		button.button_pressed = false


func rebind_action_key(inputevent : InputEventKey):
	print(inputevent)
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, inputevent)
	SettingsDataContainer.Set_Data("controls", action_name, inputevent)
	set_process_unhandled_key_input(true)
	set_action_name()
	set_text_for_key()
