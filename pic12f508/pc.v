module pic12f508

fn (mut m Mcu) inc_pc() {
	m.pc++
	m.update_pcl()
}

fn (mut m Mcu) set_pc(v u16) {
	m.pc = v
	m.update_pcl()
}

fn (m Mcu) get_pc() u16 {
	return m.pc
}

fn (mut m Mcu) update_pcl() {
	m.pc %= flash_size
	m.ram[pcl] = u8(m.pc)
}
