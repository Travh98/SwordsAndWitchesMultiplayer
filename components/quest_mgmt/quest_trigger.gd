extends Node
class_name QuestTrigger

## A helper node for starting or progressing quests

enum QuestTriggerAction {
	TRIGGER_STARTQUEST,
	TRIGGER_PROGRESSTASK,
}

@export var trigger_activator: PlayerTrigger
@export var quest_title: String = ""
@export var task_title: String = ""
@export var action: QuestTriggerAction = QuestTriggerAction.TRIGGER_PROGRESSTASK

func _ready():
	# Connect this to be triggered when the PlayerTrigger has a player enter it
	trigger_activator.trigger_activated.connect(on_triggered)


func on_triggered():
	match action:
		QuestTriggerAction.TRIGGER_STARTQUEST:
			#print("Starting quest: ", quest_title)
			QuestMgr.start_quest(quest_title)
		QuestTriggerAction.TRIGGER_PROGRESSTASK:
			#print("Completing task: ", task_title)
			QuestMgr.progress_quest_task(quest_title, task_title)
