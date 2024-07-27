extends Control

@onready var active_quests_container: VBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/ActiveQuests
@onready var QuestHudInfoScene = preload("res://ui/quests_ui/quest_hud_info.tscn")

func _ready():
	QuestMgr.quest_updated.connect(on_quest_updated)
	
	# Run at ready
	on_quest_updated()


func on_quest_updated():
	# Clear existing quest infos
	for child in active_quests_container.get_children():
		child.queue_free()
	
	# Fill the active quests container with all started quests
	var active_quests: Array[Quest] = QuestMgr.get_active_quests()
	#print("Updating questview with ", active_quests.size(), " quests")
	for quest in active_quests:
		var quest_hud_info: QuestHudInfo = QuestHudInfoScene.instantiate()
		active_quests_container.add_child.call_deferred(quest_hud_info)
		quest_hud_info.setup_from_quest.call_deferred(quest)
