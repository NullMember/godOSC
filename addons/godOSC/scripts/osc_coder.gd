class_name OSCCoder
extends Node

static func encode_osc(osc_address : String, args : Array) -> PackedByteArray:
	var packet = PackedByteArray()
	
	packet.append_array(osc_address.to_ascii_buffer())
	
	packet.append(0)
	while fmod(packet.size(), 4):
		packet.append(0)
	
	packet.append(44)
	for arg in args:
		match typeof(arg):
			TYPE_INT:
				packet.append(105)
			TYPE_FLOAT:
				packet.append(102)
			TYPE_STRING:
				packet.append(115)
			TYPE_PACKED_BYTE_ARRAY:
				packet.append(98)
	
	packet.append(0)
	while fmod(packet.size(), 4):
		packet.append(0)
	
	for arg in args:
		var pack = PackedByteArray()
		match typeof(arg):
			TYPE_INT:
				pack.append_array([0, 0, 0, 0])
				pack.encode_s32(0, arg)
				pack.reverse()
			TYPE_FLOAT:
				pack.append_array([0, 0, 0, 0])
				pack.encode_float(0, arg)
				pack.reverse()
			TYPE_STRING:
				pack.append_array(arg.to_ascii_buffer())
				pack.append(0)
				while fmod(pack.size(), 4):
					pack.append(0)
		packet.append_array(pack)
	
	return packet

static func decode_osc(packet: PackedByteArray) -> Array:
	var comma_index = packet.find(44)
	var address = packet.slice(0, comma_index).get_string_from_ascii()
	var args = packet.slice(comma_index, packet.size())
	var tags = args.get_string_from_ascii()
	args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())
	var vals = []
	
	for tag in tags.to_ascii_buffer():
		match tag:
			44: #,: comma
				pass
			105: #i: int32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_s32(0))
				args = args.slice(4, args.size())
			102: #f: float32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_float(0))
				args = args.slice(4, args.size())
			115: #s: string
				var val = args.get_string_from_ascii()
				vals.append(val)
				args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
			98:  #b: blob
				vals.append(args)
	
	return [address, vals]
