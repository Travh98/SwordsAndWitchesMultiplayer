extends Control
class_name QuestHudInfo

@onready var QuestTaskCheckboxScene: PackedScene = preload("res://ui/quests_ui/quest_task_checkbox.tscn")

@onready var quest_title_label: Label = $VBoxContainer/QuestTitle
@onready var quest_desc_label: Label = $VBoxContainer/QuestDescription
@onready var tasks_container: VBoxContainer = $VBoxContainer/TasksContainer

func setup_from_quest(quest: Quest):
	quest_title_label.text = quest.quest_title
	quest_desc_label.text = quest.quest_description
	
	# Clear tasks container
	for child in tasks_container.get_children():
		child.queue_free()
	
	for task in quest.quest_tasks:
		if task.status != QuestTask.TaskStatus.TASK_UNKNOWN:
			var task_checkbox: QuestTaskCheckbox = QuestTaskCheckboxScene.instantiate()
			tasks_container.add_child.call_deferred(task_checkbox)
			task_checkbox.setup_from_task.call_deferred(task)
