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
	gp0    = 0
	gp1    = 1
	gp2    = 2
	gp3    = 3
	gp4    = 4
	gp5    = 5
	t0cki  = 2
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
	transitions   [io_pins]Transition
	wdt           u16
	option        u8
	tris          u8
	config        u16
}

pub fn (m Mcu) str() string {
	return 'OPCODE: 0b${m.opcode:012b}\nPC: $m.pc\nW: $m.w\nRAM: $m.ram'
}

pub fn (mut m Mcu) init(config_word u16) {
	m.config = pic12f508.c & 0b11111
	m.option = 0b1111_1111
	m.tris = 0b0011_1111
	m.set_file(pic12f508.status, 0b0001_1000)
	m.set_file(pic12f508.fsr, 0b1110_0000)
	m.set_file(pic12f508.osccal, 0b1111_1110)
	m.set_pc(pic12f508.flash_size - 1)
	println('$pic12f508.io_pins')
}

pub fn (mut m Mcu) flash(prog []u8) {
	len := if prog.len < pic12f508.flash_size { prog.len } else { pic12f508.flash_size }
	for i in 0 .. len / 2 {
		m.flash[i] = u16(prog[2 * i]) | (u16(prog[2 * i + 1]) << 8)
	}
}

fn (mut m Mcu) clock() {
	match m.state {
		.fetch {
			if m.sleeping {
				if !(m.get_option(pic12f508.gpwu))
					&& (m.transitions[..(pic12f508.gp3 + 1)].any(it != .nil)) {
					m.sleeping = false
				} else {
					return
				}
			}
			m.opcode = m.flash[m.pc]
			if m.timer_lockout > 0 {
				m.timer_lockout--
			} else if !m.get_option(pic12f508.t0cs) {
				if m.get_option(pic12f508.t0cs) {
					match m.transitions[pic12f508.t0cki] {
						.nil {
							// pass
						}
						.posedge {
							if !m.get_option(pic12f508.t0se) {
								m.inc_tmr0()
							}
						}
						.negedge {
							if m.get_option(pic12f508.t0se) {
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
