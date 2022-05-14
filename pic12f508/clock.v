module pic12f508

pub fn (mut m Mcu) cycle() {
	m.clock()
	m.clock()
	m.clock()
	m.clock()
}
