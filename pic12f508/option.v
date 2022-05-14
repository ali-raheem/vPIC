module pic12f508

fn (m Mcu) get_option(bit u8) bool {
	return (m.option & (1 << bit) != 0)
}