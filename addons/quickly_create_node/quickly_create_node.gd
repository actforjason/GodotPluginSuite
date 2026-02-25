@tool
extends EditorPlugin

var scene_tree: Tree

func _enter_tree():
	# 延迟一下，确保编辑器界面加载完毕
	_find_scene_tree_control.call_deferred()

func _find_scene_tree_control():
	var base: Control = get_editor_interface().get_base_control()
	# SceneTreeDock 是唯一标识，SceneTreeEditor不唯一
	var scene: Node = _find_node_by_class(base, "SceneTreeDock")

	if scene:
		# SceneTreeEditor 内部包含一个 Tree 控件
		scene_tree = _find_node_by_class(scene, "Tree")
		if scene_tree:
			print("成功获取到编辑器场景树 Tree 实例: ", scene_tree)
			# 获取当前选中的 item
			# var selected = tree.get_selected()
			scene_tree.gui_input.connect(_on_scene_tree_gui_input)
	else:
		print("未找到 SceneTreeDock 控件，无法启用插件功能")

# 辅助函数：按类名递归查找节点
func _find_node_by_class(root: Node, target_class: String) -> Node:
	if root.get_class() == target_class:
		return root
	for i in range(root.get_child_count()):
		var res: Node = _find_node_by_class(root.get_child(i), target_class)
		if res:
			return res
	return null

func _exit_tree():
	if scene_tree and scene_tree.gui_input.is_connected(_on_scene_tree_gui_input):
		scene_tree.gui_input.disconnect(_on_scene_tree_gui_input)

func _on_scene_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
	and event.button_index == MOUSE_BUTTON_MIDDLE:
		var item := scene_tree.get_item_at_position(event.position)
		if item == null:
			return

		var node_path: NodePath = item.get_metadata(0)
		var node: Node = get_editor_interface().get_edited_scene_root().get_node(node_path)
		if node == null:
			return
		print("Middle clicked:", node.name)

		# 1. 选中节点（编辑器 selection）
		var selection := get_editor_interface().get_selection()
		selection.clear()
		selection.add_node(node)

		# 2. 让 SceneTree 获取焦点（关键）
		scene_tree.grab_focus()

		# 3. 延迟一帧执行 Ctrl+A
		# _send_ctrl_a.call_deferred()
		_send_ctrl_a()

func _send_ctrl_a():
	var key_event := InputEventKey.new()

	key_event.keycode = KEY_A
	key_event.ctrl_pressed = true
	key_event.pressed = true

	Input.parse_input_event(key_event)

	# 释放键（可选）
	# key_event.ctrl_pressed = false
	# key_event.pressed = false

	# Input.parse_input_event(key_event)
