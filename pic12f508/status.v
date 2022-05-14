module pic12f508

fn (mut m Mcu) set_z(x bool) {
	if x {
		m.ram[pic12f508.status] |= 1 << pic12f508.z
	} else {
		m.ram[pic12f508.status] &= ~(1 << pic12f508.z)
	}
}

fn (mut m Mcu) set_c(x bool) {
	if x {
		m.ram[pic12f508.status] |= 1 << pic12f508.c
	} else {
		m.ram[pic12f508.status] &= ~(1 << pic12f508.c)
	}
}

fn (mut m Mcu) set_dc(x bool) {
	if x {
		m.ram[pic12f508.status] |= 1 << pic12f508.dc
	} else {
		m.ram[pic12f508.status] &= ~(1 << pic12f508.dc)
	}
}