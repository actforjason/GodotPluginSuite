class_name OnlyRun extends RefCounted

var button: Button
var _plugin: EditorPlugin
var container: HBoxContainer
var run_icon
var rerun_icon
var game_pid: int = -1
var timer: Timer

func perform(plugin: EditorPlugin):
	_plugin = plugin
	var base: Control = EditorInterface.get_base_control()
	var editor_runbar: Control = base.find_child("@EditorRunBar@*", true, false)
	if editor_runbar:
		container = editor_runbar.find_children("@HBoxContainer@*", "HBoxContainer", true, false)[1]
	run_icon = base.get_theme_icon("MainPlay", "EditorIcons")
	rerun_icon = base.get_theme_icon("Reload", "EditorIcons")

	button = Button.new()
	button.name = "OnlyRunButton"
	button.tooltip_text = "Only Run\nMiddle Click to use Console"
	button.icon = run_icon
	button.add_theme_color_override("icon_normal_color", Color(0, 1.6, 0, 1))
	button.add_theme_color_override("icon_hover_color", Color(0, 2, 0, 1))

#	button.flat = true  # 背景色不管用
	var normal_style: StyleBoxFlat = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.9, 0.9, 0.9, 0)
	var hover_style: StyleBoxFlat = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.55, 0.55, 0.55, 1.0)
	var pressed_style: StyleBoxFlat = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.1, 0.3, 0.6, 1.0)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)

	# 将按钮添加到编辑器的工具栏
#	_plugin.add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	container.add_child(button)
	container.move_child(button, 1)

	timer = Timer.new()
	timer.wait_time = 1
	timer.timeout.connect(check_process)
	button.add_child(timer)
	button.gui_input.connect(_on_button_gui_input)

func check_process():
	if game_pid != -1 and not OS.is_process_running(game_pid):
		game_pid = -1
		_update_button()
		timer.stop()

func _on_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
		#	stop_playing_scene不能结束独立进程
			if game_pid > 0:
				OS.kill(game_pid)
				run_project()
			elif game_pid == -1:
				run_project()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if game_pid > 0:
				OS.kill(game_pid)
				game_pid = -1
				timer.stop()
			elif game_pid == -1:
				run_project(true)

		_update_button()

func _update_button():
	if game_pid > 0:
		button.icon = rerun_icon
		button.tooltip_text = "Rerun Project\nMiddle Click to Stop"
	else:
		button.icon = run_icon
		button.tooltip_text = "Only Run\nMiddle Click to use Console"

func run_project(use_console: bool = false):
	if timer.is_stopped():
		timer.start()
#	_plugin.get_editor_interface().play_main_scene() #仍会构建项目
	var godot_exe: String = OS.get_executable_path()
	var console_exe: String = godot_exe.get_basename() + ".console.exe"
	var project_path: String = ProjectSettings.globalize_path("res://")
	# var output: Array
	# OS.execute阻塞进程，create_process 不会阻塞编辑器
	if use_console:
		game_pid = OS.create_process(console_exe, ["--path", project_path], true)
	else:
		game_pid = OS.create_process(godot_exe, ["--path", project_path])

	if game_pid > 0:
		print("Only Run 进程已启动，PID: ", game_pid)
	else:
		push_error("无法启动Only Run进程")
#	print(godot_exe + "\n" + project_path)

func cleanup():
	# 插件卸载时移除按钮，避免内存泄漏或 UI 残留
	if button:
#		_plugin.remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
