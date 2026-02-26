@tool
extends EditorPlugin

var scene_tree: Tree
var scene_tree_dock: Node

func _enter_tree():
	# 延迟一下，确保编辑器界面加载完毕
	_find_scene_tree_control.call_deferred()

func _find_scene_tree_control():
	var base: Control = EditorInterface.get_base_control()
	# SceneTreeDock 是唯一标识，SceneTreeEditor不唯一
	scene_tree_dock = base.find_children("Scene", "SceneTreeDock", true, false)[0]
	# print("scene_tree_dock: ", scene_tree_dock.get_path())

	if scene_tree_dock:
		# SceneTreeEditor 内部包含一个 Tree 控件
		scene_tree = scene_tree_dock.find_child("*@Tree@*", true, false)
		# scene_tree = _find_node_by_class(scene_tree_dock, "Tree")
		if scene_tree:
			print("成功获取到编辑器场景树 Tree 实例: ", scene_tree.get_path())
			scene_tree_dock.node_created.connect(_on_node_created) # 监听场景树新建节点的信号，修复焦点问题
			scene_tree.gui_input.connect(_on_scene_tree_gui_input)
	else:
		print("未找到 SceneTreeDock 控件，无法启用插件功能")

func _on_node_created(new_node: Node):
	if new_node:
		# var edit: LineEdit = scene_tree.find_child("*@LineEdit@*", true, false)
		# 延迟执行，确保新节点创建后界面更新完毕
		await get_tree().create_timer(.2).timeout
		scene_tree.grab_focus()
		# scene_tree.edit_selected()
		# print("edit_selected result: ", )

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
		var node: Node = EditorInterface.get_edited_scene_root().get_node(node_path)
		if node == null:
			return
		print("Middle clicked:", node.name)

		# 1. 选中节点（编辑器 selection）
		var selection := EditorInterface.get_selection()
		selection.clear()
		selection.add_node(node)

		# 2. 让 SceneTree 获取焦点
		# scene_tree.grab_focus()

		# 3. 延迟一帧执行 Ctrl+A
		_send_ctrl_a()

func _send_ctrl_a():
	var key_event := InputEventKey.new()

	key_event.keycode = KEY_A
	key_event.ctrl_pressed = true
	key_event.pressed = true

	Input.parse_input_event(key_event)
