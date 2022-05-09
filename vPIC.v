module main
import pic12f508

fn main() {
	mut pic := pic12f508.Mcu{}
	pic.flash[0] = 0b1100_1010_1010 // MOVLW 0b10101010 (170)
	pic.flash[1] = 0b0000_001_01010 // MOVWF 0b01010 (10)
	pic.cycle()
	println(pic)
	pic.cycle()
	println(pic)
	pic.cycle()
	println(pic)
	pic.cycle()
	println(pic)
}
