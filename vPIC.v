module main
import pic12f508

fn main() {
	mut pic := pic12f508.Mcu{}
	pic.flash[0] = 0b1100_0000_0001 // MOVLW 1
	pic.flash[1] = 0b0000_001_01010 // MOVWF 10
	pic.flash[2] = 0b0000_001_01011 // MOVWF 11
									// LOOP
	pic.flash[3] = 0b001000_0_01010 // MOVF 10, W
 	pic.flash[4] = 0b000111_0_01011 // ADDWF 11, W
	pic.flash[5] = 0b0000_001_01100 // MOVWF 12
	pic.flash[6] = 0b001000_0_01011 // MOVF 11, W
	pic.flash[7] = 0b0000_001_01010 // MOVWF 10
	pic.flash[8] = 0b001000_0_01100 // MOVF 12, W
//	pic.flash[9] = 0b0000_001_01011 // MOVWF 11
	pic.flash[10] = 0b101_00000_0011 // GOTO 2
	for _ in 0 .. 22 {
		pic.cycle()
		println(pic.get_ram(11))
	}

}
