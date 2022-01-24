extends VBoxContainer
tool

const Milestone = preload("res://addons/gplanner/DataHelpers/Milestone.gd")
const Task = preload("res://addons/gplanner/DataHelpers/Task.gd")
const DataBinder = preload("res://addons/gplanner/DataHelpers/DataBindCollection.gd")
const StatusEnum = preload("res://addons/gplanner/DataHelpers/StatusEnum.gd")

signal item_clicked(task_id)

var is_expanded:bool = false

var _project
var _milestone:Milestone

onready var member_box = $MemberArea
onready var vbox = $MemberArea/VBoxContainer

func load_milestone(project, milestone_id:int, data_binds:DataBinder, show_hidden:bool)->void:
	_project = project
	_milestone = project.get_milestone(milestone_id)
	var group_button = $GroupButton
	group_button.text = _milestone.milestone_name
	

	var norm_sb:StyleBoxFlat = StyleBoxFlat.new()
	norm_sb.bg_color = _milestone._color
	group_button.add_stylebox_override("normal", norm_sb)
	
	var pressed_sb:StyleBoxFlat = StyleBoxFlat.new()
	pressed_sb.bg_color = _milestone._color
	pressed_sb.border_color = _milestone._color.darkened(0.2)
	pressed_sb.border_width_left = 10
	group_button.add_stylebox_override("pressed", pressed_sb)
	
	refresh_member_list(data_binds, show_hidden)


func refresh_member_list(data_binds:DataBinder, show_hidden)->void:
	var children = vbox.get_children()
	for child in children:
		vbox.remove_child(child)
		data_binds.unbind_target(child)
		child.queue_free()
	
	for task_data in _project.get_milestone_tasks(_milestone.id):
		if (!show_hidden 
			and( task_data.status == StatusEnum.Values.Completed 
			or task_data.status == StatusEnum.Values.Abandoned)):
			continue
		var task_button := Button.new()
		vbox.add_child(task_button)
		task_button.text = task_data.title
		task_button.connect("button_down", self, "item_button_clicked", [task_data.task_id, task_button])
		task_button.focus_mode = Control.FOCUS_NONE
		task_button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		task_button.align = Button.ALIGN_LEFT
		data_binds.bind(DataBinder.TaskType, task_data.task_id, Task.Fields.Name, task_button, "text")
	
	if is_expanded:
		shrink()
		expand()

func expand()->void:
	add_child(member_box)
	is_expanded = true


func shrink()->void:
	remove_child(member_box)
	is_expanded = false


func item_button_clicked(task_id:int, task_button:Button)->void:
	emit_signal("item_clicked", task_id)


func _on_GroupButton_toggled(button_pressed: bool) -> void:
	if(button_pressed):
		expand()
	else:
		shrink()
