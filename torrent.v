module main

import net
import net.urllib
import encoding.binary
import time

struct Torrent {
	announce      string
	announce_list [][]string
	info          TourrentInfo
	created_at    int
	comment       ?string
	created_by    ?string
	row           map[string]BencodeResult
}

struct TourrentInfo {
mut:
	piece_length int
	pieces       string
	name         string
	length       ?int
	files        []TourrentInfoFile
}

struct TourrentInfoFile {
	length int
	path   []string
}

fn Torrent.from_bencode_map(m map[string]BencodeResult) Torrent {
	announce := m['announce'] or { panic('ERROR: Invalid torrent file') } as string
	announce_list := m['announce-list'] or { panic('ERROR: Invalid torrent file') }
	mut announce_list_string := [][]string{}
	if announce_list is []BencodeResult {
		for _, ann in announce_list {
			if ann is []BencodeResult {
				mut urls := []string{}
				for _, url in ann {
					if url is string {
						urls << url
					} else {
						panic('ERROR: invalid announce url')
					}
				}
				announce_list_string << urls
			} else {
				panic('ERROR: invalid announce url')
			}
		}
	} else {
		panic('ERROR: invalid announce-list')
	}
	comment := m['comment'] or { '' } as string
	created_by := m['created by'] or { '' } as string

	created_at := m['creation date'] or { 0 } as int
	info := m['info'] or { panic('ERROR: no info in tourrent file') } as map[string]BencodeResult
	info_tourrent := Torrent.new_info(info)
	return Torrent{
		announce:      announce
		announce_list: announce_list_string
		info:          info_tourrent
		comment:       comment
		created_by:    created_by
		created_at:    created_at
	}
}

fn Torrent.new_info(info map[string]BencodeResult) TourrentInfo {
	name := info['name'] or { panic('ERROR: Invalid info') } as string
	mut t := TourrentInfo{
		name: name
	}
	keys := info.keys()
	if keys.contains('length') {
		t.length = info['length'] or { 0 } as int
	}

	// piece_length int
	// pieces       string
	// name         string
	// length       ?int
	// files        []TourrentInfoFile
	if keys.contains('piece length') {
		t.piece_length = info['piece length'] or { 0 } as int
	}
	if keys.contains('pieces') {
		t.pieces = info['pieces'] or { '' } as string
	}
	if keys.contains('files') {
		mut files := []TourrentInfoFile{}
		files_bencode := info['files'] or { []BencodeResult{} } as []BencodeResult
		for _, file in files_bencode {
			if file is map[string]BencodeResult {
				file_path := file['path'] or { panic('ERROR: invalid file') } as []BencodeResult
				mut file_path_list := []string{}
				for fp in file_path {
					if fp is string {
						file_path_list << fp
					} else {
						panic('ERROR: invalid path in file info')
					}
				}
				file_length := file['length'] or { panic('ERROR: invalid file') } as int
				files << TourrentInfoFile{
					path:   file_path_list
					length: file_length
				}
			} else {
				panic('ERROR: invalid file')
			}
		}
		t.files = files
	}
	return t
}

fn (t Torrent) get_peers() {
	url := urllib.parse(t.announce) or { panic(err) }
	println(url.host)
	mut udp_conn := net.dial_udp(url.host) or { panic(err) }
	udp_conn.set_read_timeout(1 * time.second)
	mut w_buf := []u8{len: 16}
	binary.big_endian_put_u64(mut w_buf, 0x41727101980)
	binary.big_endian_put_u32_at(mut w_buf, 0x0, 8)
	binary.big_endian_put_u32_at(mut w_buf, 0xFF3FF00, 12)

	println(w_buf)

	// println(w_buf.len)
	udp_conn.write(w_buf) or { panic(err) }
	mut r_buf := []u8{len: 16}

	go fn [mut r_buf, mut udp_conn] () {
		udp_conn.read(mut r_buf) or { panic(err) }
	}()
	time.sleep(1 * time.second)
	udp_conn.close() or {}

	println('Reading...')

	// udp_conn.close() or {}

	// println(r_buf[0..i].bytestr())
	// println(addr)
}
