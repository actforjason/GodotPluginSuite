class_name RightAlignTabBar extends RefCounted

func perform():
	var base: Control = EditorInterface.get_base_control()
	var editor_scene_tabs: Control = base.find_children("@EditorSceneTabs@*", "Control", true, false)[0]
	var editor_bottom_panel: Control = base.find_children("@EditorBottomPanel@*", "Control", true, false)[0]

	if editor_scene_tabs:
		var editor_scene_tabbar: TabBar = editor_scene_tabs.find_child("@TabBar@*", true, false)
		editor_scene_tabbar.tab_alignment = TabBar.ALIGNMENT_RIGHT
		# print("Editor scene tabbar aligned right:", editor_scene_tabbar.get_path())
	if editor_bottom_panel:
		# var tabbars_name : StringName = ""
		for tabbar in editor_bottom_panel.find_children("@TabBar@*", "TabBar", true, false):
			tabbar.tab_alignment = TabBar.ALIGNMENT_RIGHT
			# tabbars_name += tabbar.name + ", "
		# print("Editor bottom tabbars aligned right:", tabbars_name)
