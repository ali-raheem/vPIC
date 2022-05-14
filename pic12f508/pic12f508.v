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
	t0cki = 2
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
	println('$io_pins')
}

pub fn (mut m Mcu) flash(prog []u8) {
	len := if prog.len < pic12f508.flash_size { prog.len } else { pic12f508.flash_size }
	for i in 0 .. len / 2 {
		m.flash[i] = u16(prog[2 * i]) | (u16(prog[2 * i + 1]) << 8)
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

fn (mut m Mcu) update_pcl() {
	m.pc %= pic12f508.flash_size
	m.ram[pic12f508.pcl] = u8(m.pc)
}


fn (mut m Mcu) set_tmr0(v u8) {
	m.ram[pic12f508.tmr0] = v
	m.timer_lockout = 2
}

fn (mut m Mcu) inc_tmr0() {
	m.ram[pic12f508.tmr0]++
}

fn (mut m Mcu) clock() {
	match m.state {
		.fetch {
			if m.sleeping {
				if !(m.get_option(gpwu)) && (m.transitions[..(gp3+1)].any(it != .nil)) {
					m.sleeping = false
				} else {
					return
				}
			}
			m.opcode = m.flash[m.pc]
			if m.timer_lockout > 0 {
				m.timer_lockout--
			} else if !m.get_option(t0cs) {
				if m.get_option(t0cs) {
					match m.transitions[t0cki] {
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
			m.clear_transitions()
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
