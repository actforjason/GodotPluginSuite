@tool
extends EditorPlugin

var quickly_create_node: QuicklyCreateNode = QuicklyCreateNode.new()
var right_align_tabbar: RightAlignTabBar = RightAlignTabBar.new()

func _enter_tree():
	quickly_create_node.perform(self)
	right_align_tabbar.perform()

func _exit_tree():
	quickly_create_node.cleanup()
