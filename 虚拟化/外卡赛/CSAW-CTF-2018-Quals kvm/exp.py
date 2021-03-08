stru_AE0 = ('0', 0, 0)
stru_B00 = ('w', 0, 0)
stru_B20 = ('}', 0, 0)
stru_B40 = ('5', 0, 0)
stru_B60 = (-1, stru_B20, stru_B40)
stru_B80 = (-1, stru_B00, stru_B60)
stru_BA0 = ('o', 0, 0)
stru_BC0 = (-1, stru_B80, stru_BA0)
stru_BE0 = ('1', 0, 0)
stru_C00 = ('t', 0, 0)
stru_C20 = (-1, stru_BE0, stru_C00)
stru_C40 = (-1, stru_BC0, stru_C20)
stru_C60 = (-1, stru_AE0, stru_C40)
stru_C80 = ('3', 0, 0)
stru_CA0 = ('7', 0, 0)
stru_CC0 = (-1, stru_C80, stru_CA0)
stru_CE0 = ('f', 0, 0)
stru_D00 = ('i', 0, 0)
stru_D20 = (-1, stru_CE0, stru_D00)
stru_D40 = (-1, stru_CC0, stru_D20)
stru_D60 = ('?', 0, 0)
stru_D80 = ('c', 0, 0)
stru_DA0 = (-1, stru_D60, stru_D80)
stru_DC0 = ('b', 0, 0)
stru_DE0 = ('d', 0, 0)
stru_E00 = (-1, stru_DC0, stru_DE0)
stru_E20 = (-1, stru_DA0, stru_E00)
stru_E40 = ('g', 0, 0)
stru_E60 = ('r', 0, 0)
stru_E80 = (-1, stru_E40, stru_E60)
stru_EA0 = ('\n', 0, 0)
stru_EC0 = ('.', 0, 0)
stru_EE0 = (-1, stru_EA0, stru_EC0)
stru_F00 = ('2', 0, 0)
stru_F20 = ('e', 0, 0)
stru_F40 = (-1, stru_F00, stru_F20)
stru_F60 = (-1, stru_EE0, stru_F40)
stru_F80 = (-1, stru_E80, stru_F60)
stru_FA0 = (-1, stru_E20, stru_F80)
stru_FC0 = (-1, stru_D40, stru_FA0)
stru_FE0 = ('m', 0, 0)
stru_1000 = ('n', 0, 0)
stru_1020 = (-1, stru_FE0, stru_1000)
stru_1040 = ('x', 0, 0)
stru_1060 = ('{', 0, 0)
stru_1080 = (-1, stru_1040, stru_1060)
stru_10A0 = (-1, stru_1020, stru_1080)
stru_10C0 = ('a', 0, 0)
stru_10E0 = (-1, stru_10A0, stru_10C0)
stru_1100 = ('s', 0, 0)
stru_1120 = ('6', 0, 0)
stru_1140 = (-1, stru_1100, stru_1120)
stru_1160 = (-1, stru_10E0, stru_1140)
stru_1180 = ('4', 0, 0)
stru_11A0 = ('h', 0, 0)
stru_11C0 = (-1, stru_1180, stru_11A0)
stru_11E0 = ('l', 0, 0)
stru_1200 = ('u', 0, 0)
stru_1220 = (-1, stru_11E0, stru_1200)
stru_1240 = (-1, stru_11C0, stru_1220)
stru_1260 = (' ', 0, 0)
stru_1280 = (-1, stru_1240, stru_1260)
stru_12A0 = (-1, stru_1160, stru_1280)
stru_12C0 = (-1, stru_FC0, stru_12A0)
stru_12E0 = (-1, stru_C60, stru_12C0)
node_wrong = ("/", 0, 0)
root_node = (-1, stru_12E0, node_wrong)

compressed_bytes = [146, 46, 99, 117, 29, 177, 243, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 0, 176, 109, 184,
0, 76, 52, 65, 0, 38, 154, 32, 0, 0, 0, 34, 211, 64,
16, 110, 131, 112, 136, 182, 45, 140, 217, 224, 245,
225, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 119, 218, 201, 90, 239, 61, 69, 203, 77, 255,
255, 255, 63, 69, 203, 77, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 75,
186, 140, 53, 134, 228, 202, 67, 202, 78, 183, 122,
200, 20, 134, 122, 207, 0, 47, 117, 164, 119, 190, 50,
48, 237, 149, 214, 51, 175, 168, 164, 157, 150, 202,
14, 180, 122, 170, 50, 161, 36, 92, 255, 255, 255, 255]

bitstring = "".join([bin(byte + 256)[3:][::-1] for byte in compressed_bytes])

bitstring = bitstring[::-1]
current_node = root_node
decoded = ""
while bitstring != "":
	if current_node[0] == -1:
		# Not a leaf node. Get a bit and handle it properly
		bit = bitstring[0]
		bitstring = bitstring[1:]

		if bit == "0":
			current_node = current_node[1]
		elif bit == "1":
			current_node = current_node[2]
	else:
		# Leaf node. Add character to output and go back to root
		decoded += current_node[0]
		current_node = root_node

print decoded[::-1]

