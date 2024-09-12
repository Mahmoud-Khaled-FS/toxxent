module main

import os

fn main() {
	toreent_file_path := './cosmos-laundromat.torrent'
	mut file := os.read_bytes(toreent_file_path) or { panic('error file can not be opened') }
	mut bencode := Bencode{
		content:  file
		cuur_pos: 0
	}

	data := bencode.decode()
	if data is map[string]BencodeResult {
		// println(data.keys())
		torrent_file := Torrent.from_bencode_map(data)

		// println(torrent_file.announce)
		// for _, f in torrent_file.info.files {
		// 	println('File Path ${f.path.join('/')}, Length: ${f.length}')
		// }
		println(torrent_file.announce_list)
		torrent_file.get_peers()
	}
}
