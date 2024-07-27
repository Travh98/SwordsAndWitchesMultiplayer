extends Node

## Global Autoload for Managing Quests

signal quest_updated()

var quests: Array[Quest]
const QuestsFileDirPath: String = "res://components/quest_mgmt/quests/"

func _init():
	var quests_dir = DirAccess.open(QuestsFileDirPath)
	# Get alphabetical array of filenames to our quest resources
	var quests_resource_files: PackedStringArray = quests_dir.get_files()
	for quest_filename in quests_resource_files:
		var quest: Quest = load(QuestsFileDirPath + quest_filename)
		if quest != null:
			quests.append(quest)
		else:
			push_warning("QuestMgr failed to load something from Quests directory: ", quest_filename)


func _ready():
	# Connect the quests after their @export variables have been loaded
	for quest in quests:
		for task in quest.quest_tasks:
			task.task_status_changed.connect(quest.on_task_status_changed)
		quest.quest_updated.connect(on_quest_updated)
	#print("QuestMgr loaded ", quests.size(), " quests")
	quest_updated.emit()


func progress_quest_task(quest_title: String, task_title: String):
	var quest: Quest = _find_quest_by_title(quest_title)
	if quest != null:
		quest.progress_task(task_title)
	else:
		push_warning("QuestMgr tried progressing a nonexistent quest: ", quest_title, " task: ", task_title)


func start_quest(quest_title: String):
	#print("QuestMgr starting quest: ", quest_title)
	var quest: Quest = _find_quest_by_title(quest_title)
	if quest != null:
		quest.discover_quest()
	else:
		push_warning("QuestMgr tried starting a nonexistent quest: ", quest_title)


func _find_quest_by_title(quest_title: String):
	for quest in quests:
		if quest.quest_title == quest_title:
			return quest
	return null


func get_active_quests() -> Array[Quest]:
	var active_quests: Array[Quest] = []
	for quest in quests:
		#print("Looking for active quests, found quest: ", quest.quest_title, " has status: ", quest.quest_status)
		if quest.quest_status == Quest.QuestStatus.QUEST_STARTED:
			active_quests.append(quest)
	return active_quests


func on_quest_updated():
	quest_updated.emit()
