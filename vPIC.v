module main

import os
import flag
import pic12f508

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vPIC')
	fp.version('alpha')
	fp.description('A Microchip PIC emulator\nSupported PICs:\n* 12F508')
	fp.skip_executable()
	fp.usage_example('--bin fib.b --cycles 87')

	binary_file := fp.string('bin', `b`, '', 'A binary file')
	cycles := fp.int('cycles', `c`, 512, 'How many instruction cycles to run for')
	help := fp.bool('help', `h`, false, 'Print this help')

	if help {
		println(fp.usage())
		return
	}
	data := os.read_file(binary_file) or {
		panic('Could not read binary file')
		return
	}

	mut pic := pic12f508.Mcu{}
	pic.flash(data.bytes())
	pic.init(0)

	go_low := [pic12f508.PinState.float, pic12f508.PinState.float, pic12f508.PinState.low, pic12f508.PinState.float, pic12f508.PinState.float, pic12f508.PinState.float]
	go_high := [pic12f508.PinState.float, pic12f508.PinState.float, pic12f508.PinState.high, pic12f508.PinState.float, pic12f508.PinState.float, pic12f508.PinState.float]
	for _ in 0 .. cycles/2 {
		pic.input(go_high)
		pic.cycle()
		pic.input(go_low)
		pic.cycle()
	}
	println(pic)
}
