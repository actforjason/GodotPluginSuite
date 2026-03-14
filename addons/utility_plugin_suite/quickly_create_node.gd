class_name QuicklyCreateNode extends RefCounted

var _scene_tree: Tree
var _plugin: EditorPlugin
var _line_edit: LineEdit
var _popup: Popup

func perform(plugin: EditorPlugin):
	_plugin = plugin
	var base: Control = EditorInterface.get_base_control()
	# SceneTreeDock is the unique identifier, SceneTreeEditor is not unique
	var scene_tree_dock: Node = base.find_children("Scene", "SceneTreeDock", true, false)[0]
	# viewport_2d = base.find_child("*@CanvasItemEditorViewport@*", true, false)
	# viewport_3d = base.find_child("*@Node3DEditorViewport@*", true, false)

	if scene_tree_dock:
		# SceneTreeEditor > Tree
		_scene_tree = scene_tree_dock.find_child("*@Tree@*", true, false)
		if _scene_tree:
			print("Successfully obtained the Scene Tree instance: ", _scene_tree.get_path())
			# Listen to the signal for new nodes in the scene tree, fix focus issue
			scene_tree_dock.node_created.connect(_on_node_created)
			_scene_tree.gui_input.connect(_on_scene_tree_gui_input)
			_line_edit = _scene_tree.find_child("*@LineEdit@*", true, false)
			_popup = _scene_tree.find_child("*@Popup@*", true, false)
			_line_edit.gui_input.connect(_on_line_edit_gui_input)
	else:
		print("Failed to find SceneTreeDock control, cannot enable plugin functionality")

func _on_node_created(new_node: Node):
	if new_node:
		# Delay execution to ensure the new node is created and the interface is updated
		await _plugin.get_tree().create_timer(.1).timeout
		# _scene_tree.grab_focus()
		_scene_tree.edit_selected()
		# print("edit_selected result: ", )

func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
	and event.button_index == MOUSE_BUTTON_MIDDLE:
		if _line_edit and _line_edit.is_editing():
			# If currently editing a node name, cancel the edit state to avoid conflicts
			# _line_edit.unedit()
			# Hide the popup, otherwise it will block the subsequent Ctrl+A shortcut
			_popup.hide()

		_send_ctrl_a()

func _on_scene_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
	and event.button_index == MOUSE_BUTTON_MIDDLE:
		var item := _scene_tree.get_item_at_position(event.position)
		if item == null:
			return

		var node_path: NodePath = item.get_metadata(0)
		var node: Node = EditorInterface.get_edited_scene_root().get_node(node_path)
		if node == null:
			return
		print("Middle clicked:", node.name)

		var selection := EditorInterface.get_selection()
		selection.clear()
		selection.add_node(node)

		_send_ctrl_a()
		# EditorInterface.popup_create_dialog(_on_created, "Node")

func _on_created(type_name: String):
	return

func _send_ctrl_a():
	var key_event := InputEventKey.new()

	key_event.keycode = KEY_A
	key_event.ctrl_pressed = true
	key_event.pressed = true

	Input.parse_input_event(key_event)

func cleanup():
	if is_instance_valid(_scene_tree):
		_scene_tree.gui_input.disconnect(_on_scene_tree_gui_input)
		if is_instance_valid(_line_edit):
			_line_edit.gui_input.disconnect(_on_line_edit_gui_input)
