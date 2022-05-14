module pic12f508

pub fn (mut m Mcu) input(p []PinState) {
	for i, x in p[..io_pins] {
		if m.inputs[i] != x {
			m.transitions[i] = if x == .high { Transition.posedge } else { Transition.negedge }
		} else {
			m.transitions[i] = Transition.nil
		}
		m.inputs[i] = x
	}
}

fn (mut m Mcu) clear_transitions() {
	for i, _ in m.transitions[..] {
		m.transitions[i] = Transition.nil
	}
}

fn (m Mcu) get_pin_by_state(state PinState) u8 {
	mut gpio_state := u8(0)
	for p in m.inputs[..].map(it == state) {
		gpio_state <<= 1
		if p {
			gpio_state |= 1
		}
	}
	return gpio_state
}

pub fn (m Mcu) get_float() u8 {
	return m.get_pin_by_state(.float)
}

pub fn (m Mcu) get_high() u8 {
	return m.get_pin_by_state(.high)
}

pub fn (m Mcu) get_low() u8 {
	return m.get_pin_by_state(.low)
}

fn (m Mcu) get_gpio() u8 {
	p := ((m.get_float() & m.ram[gpio]) | m.get_high())
	return p & 0b0011_1111
}
