module main

import os
import flag
import pic12f508

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vPIC')
	fp.version('v0.0.1')
	fp.description('A Microchip PIC emulator')
	fp.skip_executable()

	binary_file := fp.string('bin', `b`, '', 'A binary file')
	cycles := fp.int('cycles', `c`, 512, 'How many instruction cycles to run for')

	data := os.read_file(binary_file) or {
		panic('Could not read binary file')
		return
	}

	mut pic := pic12f508.Mcu{}
	pic.flash(data.bytes())
	pic.init(0)
 	// pic.flash[0] = u16(12 << 8) | 1		// MOVLW 1
	// pic.flash[1] = u16(01 << 5) | 10	// MOVWF 10
	// pic.flash[2] = u16(01 << 5) | 11	// MOVWF 11
	// pic.flash[3] = u16(16 << 5) | 10	// MOVF 10, W
 	// pic.flash[4] = u16(14 << 5) | 11	// ADDWF 11, W
	// pic.flash[5] = u16(01 << 5) | 12	// MOVWF 12
	// pic.flash[6] = u16(16 << 5) | 11	// MOVF 11, W
	// pic.flash[7] = u16(01 << 5) | 10	// MOVWF 10
	// pic.flash[8] = u16(16 << 5) | 12	// MOVF 12, W
	// pic.flash[9] = u16(5 << 9) | 1		// GOTO 1 

 	// mut data := os.create(binary_file) or {
	// 		panic('failed to open for write')
	// 	}
	// for op in pic.flash {
	// 	data.write([u8(op), u8(op >> 8)]) or {
	// 		panic('failed to write')
	// 	}
	// }
	// data.close()

	for _ in 0 .. cycles {
		pic.cycle()
	}
	println(pic)
}
