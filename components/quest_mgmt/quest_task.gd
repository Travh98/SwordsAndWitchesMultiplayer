extends Resource
class_name QuestTask

signal task_status_changed(task_title: String)

enum TaskStatus {
	TASK_UNKNOWN,
	TASK_STARTED,
	TASK_COMPLETE,
}

@export var task_title: String = ""
@export var task_description: String = ""
@export var status: TaskStatus = TaskStatus.TASK_UNKNOWN


func discover_task():
	if status == TaskStatus.TASK_UNKNOWN:
		status = TaskStatus.TASK_STARTED
		task_status_changed.emit(task_title)


func progress_task():
	#print("Progressing task: ", task_title)
	status = TaskStatus.TASK_COMPLETE
	task_status_changed.emit(task_title)
