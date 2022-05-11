module main
import pic12f508

fn main() {
	mut pic := pic12f508.Mcu{}
	pic.flash[0] = u16(12 << 8) | 1		// MOVLW 1
	pic.flash[1] = u16(01 << 5) | 10	// MOVWF 10
	pic.flash[2] = u16(01 << 5) | 11	// MOVWF 11
	pic.flash[3] = u16(16 << 5) | 10	// MOVF 10, W
 	pic.flash[4] = u16(14 << 5) | 11	// ADDWF 11, W
	pic.flash[5] = u16(01 << 5) | 12	// MOVWF 12
	pic.flash[6] = u16(16 << 5) | 11	// MOVF 11, W
	pic.flash[7] = u16(01 << 5) | 10	// MOVWF 10
	pic.flash[8] = u16(16 << 5) | 12	// MOVF 12, W
	pic.flash[9] = u16(5 << 9) | 1		// GOTO 1
	for _ in 0 .. 100 {
		pic.cycle()
		println(pic)
	}

}
