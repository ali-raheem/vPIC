module pic12f508

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
