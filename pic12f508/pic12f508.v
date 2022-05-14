module pic12f508

const (
	// files
	indf   = 0
	tmr0   = 1
	pcl    = 2
	status = 3
	fsr    = 4
	osccal = 5
	gpio   = 6

	// bits
	// status
	pa     = 5
	z      = 2
	dc     = 1
	c      = 0

	// option
	gpwu   = 7
	gppu   = 6
	t0cs   = 5
	t0se   = 4
	psa    = 3
	ps2    = 2
	ps1    = 1
	ps0    = 0

	// pin names
	gp0 = 0
	gp1 = 1
	gp2 = 2
	gp3 = 3
	gp4 = 4
	gp5 = 5
	gp6 = 6
)

pub const (
	// parameters
	stack_depth = 2
	io_pins     = 6
	flash_size  = 512
	ram_size    = 25
)

enum CycleState {
	fetch
	decode
	execute
	flush
}

enum Destination {
	w = 0
	f
}

pub enum PinState {
	float = 0
	low
	high
}

enum Transition {
	nil = 0
	posedge
	negedge
}

pub struct Mcu {
pub mut:
	flash [flash_size]u16
mut:
	ram           [ram_size]u8
	state         CycleState = .fetch
	w             u8
	pc            u16
	timer_lockout u8
	sp            u8
	stack         [stack_depth]u16
	sleeping      bool
	opcode        u16
	inputs        [io_pins]PinState
	transitions  [io_pins]Transition
	wdt           u16
	option        u8
	tris          u8
	config        u16
}

pub fn (mut m Mcu) init(config_word u16) {
	m.config = pic12f508.c & 0b11111
	m.option = 0b1111_1111
	m.tris = 0b0011_1111
	m.set_file(pic12f508.status, 0b0001_1000)
	m.set_file(pic12f508.fsr, 0b1110_0000)
	m.set_file(pic12f508.osccal, 0b1111_1110)
	m.set_pc(pic12f508.flash_size - 1)
}

pub fn (mut m Mcu) flash(prog []u8) {
	len := if prog.len < pic12f508.flash_size { prog.len } else { pic12f508.flash_size }
	for i in 0 .. len / 2 {
		m.flash[i] = u16(prog[2 * i]) | (u16(prog[2 * i + 1]) << 8)
	}
}

pub fn (mut m Mcu) input(p [io_pins]PinState) {
	for i, x in p {
		if m.inputs[i] != x {
			m.transitions[i] = if x == .high {Transition.posedge} else {Transition.negedge}
		} else {
			m.transitions[i] = Transition.nil
		}
		m.inputs[i] = x
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
	p := ((m.get_float() & m.ram[pic12f508.gpio]) | m.get_high())
	return p & 0b0011_1111

}
fn (m Mcu) get_bit(f u8, b u8) bool {
	return (m.get_ram(f) & (1 << b)) != 0
}

pub fn (m Mcu) get_ram(f u8) u8 {
	return m.ram[f]
}

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

fn (mut m Mcu) set_tmr0(v u8) {
	m.ram[pic12f508.tmr0] = v
	m.timer_lockout = 2
}

fn (mut m Mcu) inc_tmr0() {
	m.ram[pic12f508.tmr0]++
}

fn (mut m Mcu) update_pcl() {
	m.pc %= pic12f508.flash_size
	m.ram[pic12f508.pcl] = u8(m.pc)
}

fn (m Mcu) get_option(bit u8) bool {
	return (m.option & (1 << bit) != 0)
}

fn (mut m Mcu) clock() {
	match m.state {
		.fetch {
			if m.sleeping {
				// check for wake up condition
				return
			}
			m.opcode = m.flash[m.pc]
			if m.timer_lockout > 0 {
				m.timer_lockout--
			} else if (m.option & (1 << pic12f508.t0cs)) == 0 {
				// Check if timer then
				if m.get_option(t0cs) {
					match m.transitions[gp2] {
						.nil {
							// pass
						}
						.posedge {
							if !m.get_option(t0se) {
								m.inc_tmr0()
							}
						}
						.negedge {
							if m.get_option(t0se) {
								m.inc_tmr0()
							}
						}
					}
				} else {
					m.inc_tmr0()
				}
			}
			m.state = .decode
		}
		.decode {
			m.state = .execute
		}
		.execute {
			m.execute()
			m.state = .flush
		}
		.flush {
			m.inc_pc()
			m.state = .fetch
			for i, _ in m.transitions[..] {
				m.transitions[i] = Transition.nil
			}
		}
	}
}

pub fn (m Mcu) str() string {
	return 'OPCODE: 0b${m.opcode:012b}\nPC: $m.pc\nW: $m.w\nRAM: $m.ram'
}

pub fn (mut m Mcu) cycle() {
	m.clock()
	m.clock()
	m.clock()
	m.clock()
}

fn (mut m Mcu) execute() {
	match m.opcode {
		0 {
			m.nop()
		}
		2 {
			m.option()
		}
		3 {
			m.sleep()
		}
		4 {
			m.clrwdt()
		}
		6...7 {
			m.tris()
		}
		64 {
			m.clrw()
		}
		else {
			f := m.opcode & 0b11111
			mut d := Destination.f
			op := u8(m.opcode >> 5)
			if op & 1 != 0 {
				d = Destination.f
			} else {
				d = Destination.w
			}
			match op {
				1 {
					m.movwf(f)
				}
				3 {
					m.clrf(f)
				}
				4...5 {
					m.subwf(f, d)
				}
				6...7 {
					m.decf(f, d)
				}
				8...9 {
					m.iorwf(f, d)
				}
				10...11 {
					m.andwf(f, d)
				}
				12...13 {
					m.xorwf(f, d)
				}
				14...15 {
					m.addwf(f, d)
				}
				16...17 {
					m.movf(f, d)
				}
				18...19 {
					m.comf(f, d)
				}
				20...21 {
					m.incf(f, d)
				}
				22...23 {
					m.decfsz(f, d)
				}
				24...25 {
					m.rrf(f, d)
				}
				26...27 {
					m.rlf(f, d)
				}
				28...29 {
					m.swapf(f, d)
				}
				30...31 {
					m.incfsz(f, d)
				}
				else {
					b := u8((m.opcode >> 5) & 0b111)
					k := u8(m.opcode)
					match m.opcode >> 8 {
						4 {
							m.bcf(f, b)
						}
						5 {
							m.bsf(f, b)
						}
						6 {
							m.btfsc(f, b)
						}
						7 {
							m.btfss(f, b)
						}
						8 {
							m.retlw(k)
						}
						9 {
							m.call(k)
						}
						12 {
							m.movlw(k)
						}
						13 {
							m.iorlw(k)
						}
						14 {
							m.andlw(k)
						}
						15 {
							m.xorlw(k)
						}
						else {
							if (m.opcode >> 9) == 5 {
								m.op_goto(u16(m.opcode & 0b1_1111_1111))
							} else {
								println('# Illegal opcode!')
								println(*m)
								exit(-1)
							}
						}
					}
				}
			}
		}
	}
}
