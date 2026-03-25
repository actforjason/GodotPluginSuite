@tool
extends EditorPlugin

var quickly_create_node: QuicklyCreateNode = QuicklyCreateNode.new()
var right_align_tabbar: RightAlignTabBar = RightAlignTabBar.new()
var only_run: OnlyRun = OnlyRun.new()

func _enter_tree():
	quickly_create_node.perform(self)
	only_run.perform(self)
	right_align_tabbar.perform()
	
func _exit_tree():
	quickly_create_node.cleanup()
	only_run.cleanup()
