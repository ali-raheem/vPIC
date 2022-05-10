module pic12f508

const (
// files
	indf = 0
	tmr0 = 1
	pcl = 2
	status = 3
	fsr = 4
	osccal = 5
	gpio = 6
// bits
// status
	z = 2
	dc = 1
	c = 0
// parameters
	stack_depth = 2
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

pub struct Mcu {
pub mut:
	flash [512]u16
mut:
	ram [25]u8
	state CycleState = .fetch
	w u8
	pc u16
	timer_lockout u8
	sp u8
	stack [stack_depth]u16
	sleeping bool
	opcode u16
}

pub fn (m Mcu) get_ram(f u8) u8 {
	return m.ram[f]
}
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

fn (mut m Mcu) set_file(f u16, v u8) {
	match f {
		pcl {
			mut pc := m.get_pc()
			pc &= 0b11110000
			pc |= u16(v)
			m.set_pc(pc)
		}
		tmr0 {
			m.set_tmr0(v)
		}
		indf  {
			ff := u16(m.get_file(fsr))
			m.set_file(ff, v)
		}
		else {
			m.ram[f] = v
		}
	}
}
fn (mut m Mcu) get_file(f u16) u8 {
	match f {
		indf {
			ff := u16(m.get_file(fsr))
			return m.get_file(ff)
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
fn (mut m Mcu) set_pc(v u16){
	m.pc = v
	m.update_pcl()
}
fn (m Mcu) get_pc() u16 {
	return m.pc
}
fn (mut m Mcu) set_tmr0(v u8) {
	m.ram[tmr0] = v
	m.timer_lockout = 2
}
fn (mut m Mcu) inc_tmr0(v u8) {
	if m.timer_lockout == 0 {
		m.ram[tmr0]++
	}
}
fn (mut m Mcu) update_pcl() {
	m.ram[pcl] = u8(m.pc)
}
fn (mut m Mcu) clock() {
	match m.state {
		.fetch {
			m.opcode = m.flash[m.pc]
			if m.timer_lockout > 2 {
				m.timer_lockout--
			} else {
				// ? m.tmr0_inc()
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
		}
	}
}

pub fn (m Mcu) str () string {
	return 'OPCODE: 0b${m.opcode:012b}\nPC: $m.pc\nW: $m.w\nRAM: $m.ram'
}

pub fn (mut m Mcu) cycle () {
	m.clock()
	m.clock()
	m.clock()
	m.clock()
}

fn (mut m Mcu) execute () {
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
		6 | 7 {
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
			println('$op')
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