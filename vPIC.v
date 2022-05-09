module main
import pic12f508

fn main() {
	mut pic := pic12f508.Mcu{}
	pic.flash[0] = 0b1100_1010_1010 // MOVLW 170
	pic.flash[1] = 0b0000_001_01010 // MOVWF 10
	pic.flash[2] = 0b001010_1_01100 // INCF 12, F
	pic.flash[3] = 0b001110_1_01100 // SWAPF 12, W
	pic.flash[4] = 0b1100_0001_0000 // MOVLW 16
	pic.flash[5] = 0b0000_001_00100 // MOVWF FSR
	pic.flash[6] = 0b001010_1_00000 // INCF INDF, F
	for _ in 0 .. 7 {
		pic.cycle()
		println(pic)
	}

}
