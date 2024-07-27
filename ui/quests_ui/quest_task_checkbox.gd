extends VBoxContainer
class_name QuestTaskCheckbox

@onready var task_title_checkbox: CheckBox = $TaskTitleCheckbox
@onready var task_desc_label: Label = $HBoxContainer/TaskDescLabel

func setup_from_task(task: QuestTask):
	task_title_checkbox.text = task.task_title
	task_desc_label.text = task.task_description
	if task.status == QuestTask.TaskStatus.TASK_COMPLETE:
		task_title_checkbox.button_pressed = true
