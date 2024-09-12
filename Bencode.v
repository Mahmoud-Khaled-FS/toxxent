module main

const token_integar = u8(105)
const token_end = u8(101)
const token_list = u8(108)
const token_dict = u8(100)
const token_start_number = u8(48)
const token_end_number = u8(57)
const token_delim = u8(58)

struct Bencode {
pub mut:
	content  []u8
	cuur_pos u64
}

type BencodeResult = int | string | []BencodeResult | map[string]BencodeResult

fn (mut b Bencode) decode() BencodeResult {
	if b.content[b.cuur_pos] == token_dict {
		return b.read_dict()
	} else if b.content[b.cuur_pos] == token_integar {
		return b.read_int()
	} else if b.content[b.cuur_pos] >= token_start_number
		&& b.content[b.cuur_pos] <= token_end_number {
		return b.read_str()
	} else if b.content[b.cuur_pos] == token_list {
		return b.read_list()
	}
	panic('ERROR: Invalid bencode at pos ${b.cuur_pos + 1}')
}

fn (mut b Bencode) read_dict() map[string]BencodeResult {
	mut dict := map[string]BencodeResult{}
	b.cuur_pos++
	for b.content[b.cuur_pos] != token_end {
		key := b.read_str()
		value := b.decode()
		dict[key] = value
	}
	b.cuur_pos++
	return dict
}

fn (mut p Bencode) read_int() int {
	p.cuur_pos++
	mut bytes_int := []u8{}
	for p.content[p.cuur_pos] != token_end {
		bt := p.content[p.cuur_pos]
		if bt < token_start_number || bt > token_end_number {
			panic('ERROR: invalid bencode char ${bt.ascii_str()} in pos ${p.cuur_pos + 1}')
		}
		bytes_int << bt
		p.cuur_pos++
	}
	p.cuur_pos++
	return bytes_int.bytestr().int()
}

fn (mut p Bencode) read_str() string {
	mut text_length_bytes := []u8{}
	for p.content[p.cuur_pos] != token_delim {
		bt := p.content[p.cuur_pos]
		if bt < token_start_number || bt > token_end_number {
			panic('ERROR: invalid bencode char ${bt.ascii_str()} in pos ${p.cuur_pos + 1}')
		}
		text_length_bytes << bt
		p.cuur_pos++
	}
	p.cuur_pos++
	text_length := u64(text_length_bytes.bytestr().int())
	str_bytes := p.content[p.cuur_pos..p.cuur_pos + text_length]
	p.cuur_pos += text_length
	return str_bytes.bytestr()
}

fn (mut p Bencode) read_list() []BencodeResult {
	mut results := []BencodeResult{}
	p.cuur_pos++
	for p.content[p.cuur_pos] != token_end {
		results << p.decode()
	}
	p.cuur_pos++
	return results
}

// fn parse_torrnet_file(torrentFile os.File) {
// 	first_byte := torrentFile.read_bytes(1)[0]
// 	if first_byte != token_dict {
// 		panic('ERROR: invalid torrnet file')
// 	}
// 	postion := u64(1)
// 	read_dict(torrentFile, postion)
// }

// fn read_dict(torrentFile os.File, postion u64) {
// 	mut pos := postion
// 	mut bytes_list := torrentFile.read_bytes_at(1, pos)
// 	if bytes_list[0] == token_integar_start {
// 		read_int()
// 	} else if bytes_list[0] == token_list {
// 		read_list()
// 	} else if bytes_list[0] == token_dict {
// 		read_dict(torrentFile, pos)
// 	} else if bytes_list[0] >= token_start_number && bytes_list[0] <= token_end_number {
// 		read_string(torrentFile, mut pos)
// 	}
// }

// fn read_int() {
// }

// fn read_string(file os.File, mut pos &u64) string {
// 	mut length_bytes := file.read_bytes_at(1, pos)
// 	pos++
// 	for length_bytes[length_bytes.len - 1] != token_dil {
// 		length_bytes << file.read_bytes_at(1, pos)
// 		pos++
// 	}
// 	text_length := length_bytes.bytestr().int()
// 	text := file.read_bytes_at(text_length, pos).bytestr()
// 	pos += u64(text_length)
// 	return text
// }

// fn read_list() {
// }
