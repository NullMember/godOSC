@icon("res://addons/godOSC/images/OSCServer.svg")
class_name OSCServer
extends Node
## Server for recieving Open Sound Control messages over UDP. 

signal message_received(peer, address, values)

## The port over which to recieve messages
@export var port = 4646

## The amount of OSC packets to parse per frame. Higher parse rates are more responsive
## but require more calculations per frame. The default rate should work for most use cases.
## A simple way to determine
## a reasonable parse rate would be to use the following equation:
## amount of recieved messages * average message rate / 60.
@export var parse_rate = 10
var server = UDPServer.new()
var peers: Array[PacketPeerUDP] = []

func _ready():
	server.listen(port)

## Sets the port for the server to listen on. Can only listen to one port at a time.
func listen(new_port):
	port = new_port
	server.listen(port)

func _process(_delta):
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)
	
	parse()

func send_message(peer: PacketPeerUDP, address: String, values: Array):
	var packet = OSCCoder.encode_osc(address, values)
	peer.put_packet(packet)

func send_message_all(address: String, values: Array):
	var packet = OSCCoder.encode_osc(address, values)
	for peer in peers:
		peer.put_packet(packet)

## Parses an OSC packet. This is not intended to be called directly outside of the OSCServer
func parse():
	for peer in peers:
		for l in range(peer.get_available_packet_count()):
			var packet = peer.get_packet()
			var result = OSCCoder.decode_osc(packet)
			message_received.emit(peer, result[0], result[1])
