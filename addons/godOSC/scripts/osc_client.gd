@icon("res://addons/godOSC/images/OSCClient.svg")
class_name OSCClient
extends Node
## Client for sending Open Sound Control messages over UDP. Use one OSCClient per server you want to send to.

signal message_received(peer, ip, port, address, values)

## The IP Address of the server to send to.
@export var ip_address = "127.0.0.1"
## The port to send to.
@export var port = 4646
var client = PacketPeerUDP.new()

func _ready():
	connect_socket(ip_address, port)

func _physics_process(delta):
	for i in range(client.get_available_packet_count()):
		var packet_ip = client.get_packet_ip()
		var packet_port = client.get_packet_port()
		var packet = client.get_packet()
		var result = OSCCoder.decode_osc(packet)
		message_received.emit(client, packet_ip, packet_port, result[0], result[1])

## Connect to an OSC server. Can only send to one OSC server at a time.
func connect_socket(new_ip = "127.0.0.1", new_port = 4646):
	ip_address = new_ip
	port = new_port
	close_socket()
	client.connect_to_host(new_ip, new_port)

func close_socket():
	if client.is_socket_connected():
		client.close()

func send_message(osc_address : String, args : Array):
	var packet = OSCCoder.encode_osc(osc_address, args)
	client.put_packet(packet)
