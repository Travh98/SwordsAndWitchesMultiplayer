class_name PingMgr
extends Node

## Manages ping calculations

signal ping_calculated(ping: float)

@onready var ping_timer: Timer = Timer.new()

var ping_start_time_msec: float
var report_ping_interval: int = 5
var num_pings: int = 0


func _ready():
	add_child(ping_timer)
	ping_timer.wait_time = 1
	ping_timer.one_shot = false
	ping_timer.timeout.connect(start_ping)


func begin_pinging():
	ping_timer.start()


func stop_pinging():
	ping_timer.stop()


func start_ping():
	ping_start_time_msec = Time.get_ticks_msec()
	# Ping the server, telling it who to respond to
	Server.ping_to_server.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())


func report_ping(ping: float):
	# Report every couple pings
	if num_pings > report_ping_interval:
		Server.report_ping_to_server.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id(), ping)
		num_pings = 0
	num_pings += 1


func receive_pong():
	var ping: float = Time.get_ticks_msec() - ping_start_time_msec
	ping_calculated.emit(ping)
	report_ping(ping)


func on_server_connection_changed(connected: bool):
	if connected:
		begin_pinging()
	else:
		stop_pinging()
