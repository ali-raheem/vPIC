module pic12f508

fn (mut m Mcu) set_z(x bool) {
	if x {
		m.ram[status] |= 1 << z
	} else {
		m.ram[status] &= ~(1 << z)
	}
}

fn (mut m Mcu) set_c(x bool) {
	if x {
		m.ram[status] |= 1 << c
	} else {
		m.ram[status] &= ~(1 << c)
	}
}

fn (mut m Mcu) set_dc(x bool) {
	if x {
		m.ram[status] |= 1 << dc
	} else {
		m.ram[status] &= ~(1 << dc)
	}
}
