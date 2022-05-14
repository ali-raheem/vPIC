module pic12f508

fn (m Mcu) get_bit(f u8, b u8) bool {
	return (m.get_ram(f) & (1 << b)) != 0
}

pub fn (m Mcu) get_ram(f u8) u8 {
	return m.ram[f]
}

fn (mut m Mcu) set_file(f u16, v u8) {
	match f {
		pic12f508.pcl {
			mut pc := m.get_pc()
			pc &= 0b11110000
			pc |= u16(v)
			m.set_pc(pc)
		}
		pic12f508.tmr0 {
			m.set_tmr0(v)
		}
		pic12f508.indf {
			ff := u16(m.get_file(pic12f508.fsr))
			m.set_file(ff, v)
		}
		pic12f508.gpio {
			p := v & 0b0011_0111
			m.ram[pic12f508.gpio] = p
		}
		else {
			m.ram[f] = v
		}
	}
}

fn (mut m Mcu) get_file(f u16) u8 {
	match f {
		pic12f508.indf {
			ff := u16(m.get_file(pic12f508.fsr))
			return m.get_file(ff)
		}
		pic12f508.gpio {
			return m.get_gpio()
		}
		else {
			return m.ram[f]
		}
	}
}