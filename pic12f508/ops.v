module pic12f508

fn (mut m Mcu) addwf (file u16, dst Destination) {
	f := m.get_file(file)
	v := m.w + f
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
	m.set_c((u16(f) + u16(m.w)) > 255)
	m.set_dc(((f & 0b1111) + (m.w & 0b1111)) > 0b1111)
}

fn (mut m Mcu) andwf (file u16, dst Destination) {
	v := m.w & m.get_file(file)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) clrf (file u16) {
	m.set_file(file, 0)
	m.set_z(true)
}

fn (mut m Mcu) clrw () {
	m.w = 0
	m.set_z(true)
}

fn (mut m Mcu) comf (file u16, dst Destination) {
	v := ~m.get_file(file)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) decf (file u16, dst Destination) {
	v := m.get_file(file) - 1
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) decfsz (file u16, dst Destination) {
	m.decf(file, dst)
	v := m.get_file(file)
	if v == 0 {
		m.inc_pc()
	}
}

fn (mut m Mcu) incf (file u16, dst Destination) {
	v := m.get_file(file) + 1
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) incfsz (file u16, dst Destination) {
	m.incf(file, dst)
	v := m.get_file(file)
	if v == 0 {
		m.inc_pc()
	}
}

fn (mut m Mcu) iorwf (file u16, dst Destination) {
	v := m.w | m.get_file(file)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) movf (file u16, dst Destination) {
	v := m.get_file(file)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) movwf (file u16) {
	v := m.w
	m.set_file(file, v)
}

fn (m Mcu) nop () {

}

fn (mut m Mcu) rlf (file u16, dst Destination) {
	mut v := m.get_file(file)
	m.set_c((v & 0b10000000) != 0)
	v <<= 1
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) rrf (file u16, dst Destination) {
	mut v := m.get_file(file)
	m.set_c((v & 1) != 0)
	v >>= 1
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) subwf (file u16, dst Destination) {
	f := m.get_file(file)
	v :=  f - m.w
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
	m.set_c(f < m.w)
	m.set_dc((f & 0b1111) < (m.w & 0b1111))
}

fn (mut m Mcu) swapf (file u16, dst Destination) {
	mut v := m.get_file(file)
	vl := v & 0b1111
	vh := v & 0b11110000
	v = (vh >> 4)| (vl << 4)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
}

fn (mut m Mcu) xorwf (file u16, dst Destination) {
	v := m.w ^ m.get_file(file)
	if dst == .w {
		m.w = v
	} else {
		m.set_file(file, v)
	}
	m.set_z(v == 0)
}

fn (mut m Mcu) bcf (file u16, bit u8) {
	mut v := m.get_file(file)
	v &= ~(1 << bit)
	m.set_file(file, v)
}

fn (mut m Mcu) bsf (file u16, bit u8) {
	mut v := m.get_file(file)
	v |= (1 << bit)
	m.set_file(file, v)
}

fn (mut m Mcu) btfsc (file u16, bit u8) {
	v := m.get_file(file) & (1 << bit)
	if v == 0 {
		m.inc_pc()
	}
}

fn (mut m Mcu) btfss (file u16, bit u8) {
	v := m.get_file(file) & (1 << bit)
	if v != 0 {
		m.inc_pc()
	}
}

fn (mut m Mcu) andlw (l u8) {
	m.w &= l
	m.set_z(m.w == 0)
}

fn (mut m Mcu) call (f u8) {
	m.stack[m.sp] = m.pc + 1
	m.sp++
	m.sp = m.sp % stack_depth
	m.set_pc(u16(f) | (u16((m.ram[status] & 0b1100000) << 4)))
}

fn (mut m Mcu) clrwdt () {
}

fn (mut m Mcu) op_goto (f u16) {
	m.set_pc((f & 0b111111111) | (u16((m.ram[status] & 0b1100000) << 4)))
}

fn (mut m Mcu) iorlw (l u8) {
	m.w &= l
	m.set_z(m.w == 0)
}

fn (mut m Mcu) movlw (l u8) {
	m.w = l
}

fn (mut m Mcu) option () {
}

fn (mut m Mcu) retlw (l u8) {
	m.sp--
	m.sp %= stack_depth
	m.pc = m.stack[m.sp]
	m.w = l
}

fn (mut m Mcu) sleep () {
	m.sleeping = true
}

fn (mut m Mcu) tris () {

}

fn (mut m Mcu) xorlw (l u8) {
	m.w ^= l
	m.set_z(m.w == 0)
}