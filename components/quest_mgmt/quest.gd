extends Resource
class_name Quest

signal quest_updated()

enum QuestStatus {
	QUEST_UNKNOWN,
	QUEST_STARTED,
	QUEST_COMPLETE,
}

@export var quest_title: String = ""
@export var quest_description: String = ""
@export var complete_in_order: bool = true
@export var quest_status: QuestStatus = QuestStatus.QUEST_UNKNOWN
@export var quest_tasks: Array[QuestTask]


func discover_quest():
	#print("Discovering task: ", quest_title)
	if quest_status == QuestStatus.QUEST_UNKNOWN:
		quest_status = QuestStatus.QUEST_STARTED
		
		# Make sure the first task is visible
		if quest_tasks.size() >= 1:
			quest_tasks[0].discover_task()
		
		quest_updated.emit()


func progress_task(task_title: String):
	if quest_status != QuestStatus.QUEST_STARTED:
		push_warning("Tried progressing the task of a Quest that hasn't started: ", quest_title)
		return
	
	for i in range(0, quest_tasks.size()):
		var task: QuestTask = quest_tasks[i]
		
		# Is this the task we are progressing?
		if task_title == task.task_title:
			task.progress_task()
			
			# If there are more tasks after this one
			if quest_tasks.size() - 1 > i:
				var next_task: QuestTask = quest_tasks[i + 1]
				next_task.discover_task()
			
			break
		else:
			# This is a different task
			if complete_in_order:
				if task.status != QuestTask.TaskStatus.TASK_COMPLETE:
					# This previous task is not complete
					push_warning("Task: ", task.task_title, " needs to be completed before Task: ", task_title)
					break
	
	_handle_quest_complete()
	quest_updated.emit()


func on_task_status_changed(task_title: String):
	var updated_task: QuestTask = _get_task_by_name(task_title)
	if weakref(updated_task).get_ref():
		#print("Quest: ", quest_title, " sees that Task: ", task_title, " has changed status to: ", updated_task.status)
		#quest_updated.emit()
		pass
	else:
		push_warning("Error in Quest, got task changed but couldn't find it")


func _get_task_by_name(task_title: String) -> QuestTask:
	for task in quest_tasks:
		if task.task_title == task_title:
			return task
	return null


func _handle_quest_complete():
	if quest_tasks.size() >= 1:
		# If the last task is complete
		if quest_tasks[quest_tasks.size() - 1].status == QuestTask.TaskStatus.TASK_COMPLETE:
			quest_status = QuestStatus.QUEST_COMPLETE
		
