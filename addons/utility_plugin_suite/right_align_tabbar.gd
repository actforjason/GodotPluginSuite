class_name RightAlignTabBar extends RefCounted

func perform():
	# 获取编辑器的根节点
	var base: Control = EditorInterface.get_base_control()
	# 递归寻找场景标签栏 (TabBar)
	var editor_scene_tabs: Control = base.find_children("@EditorSceneTabs@*", "Control", true, false)[0]
	var editor_bottom_panel: Control = base.find_children("@EditorBottomPanel@*", "Control", true, false)[0]

	if editor_scene_tabs:
		var editor_scene_tabbar: TabBar = editor_scene_tabs.find_child("@TabBar@*", true, false)
		editor_scene_tabbar.tab_alignment = TabBar.ALIGNMENT_RIGHT
		print("已将场景标签页 设为右对齐:", editor_scene_tabbar.get_path())
	if editor_bottom_panel:
		var editor_bottom_tabbar: TabBar = editor_bottom_panel.find_child("@TabBar@*", false, false)
		editor_bottom_tabbar.tab_alignment = TabBar.ALIGNMENT_RIGHT
		print("已将底部标签页 设为右对齐:", editor_bottom_tabbar.get_path())