module pic12f508

fn (mut m Mcu) set_tmr0(v u8) {
	m.ram[tmr0] = v
	m.timer_lockout = 2
}

fn (mut m Mcu) inc_tmr0() {
	m.ram[tmr0]++
}
