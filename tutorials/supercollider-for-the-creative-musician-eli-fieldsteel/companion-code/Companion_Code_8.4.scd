// Companion Code 8.4
// A Stopwatch

// This Companion Code builds a simple clock display that shows elapsed time. When started, the start/stop button plays a looping routine that updates the clock display and increments a time counter. When clicked again, the button stops the routine. The reset button resets the time counter to zero and updates the display, but does not stop the clock. For the sake of variety, the window is drawn without a border, and a custom close button is available instead.

// The 'asTimeString' method operates on integers and floats, and alleviates most of the burden of manually converting a simple number to a formatted time string. By default, the returned value provides precision down to the millisecond. Assuming that this is more precision than we actually need (and considering that your screen can only be refreshed about 60 times per second), we use 'drop(-2)' to discard the last two characters in the string.

(
var win, clock, buttons, scheduler, time = 0, inc = 0.1;

clock = StaticText()
.font_(Font(Font.defaultMonoFace, 80))
.stringColor_(Color.gray(0.8))
.align_(\center)
.string_(time.asTimeString.drop(-2));

buttons = [
	Button() // start/stop button
	.font_(Font.defaultMonoFace, 24)
	.states_([
		["start", Color.gray(0.2), Color(0.4, 0.8, 0.4)],
		["stop", Color.gray(0.2), Color(0.9, 0.5, 0.5)]
	])
	.action_({ |b|
		if (
			b.value == 1,
			{
				scheduler = Routine({
					loop{
						defer{ clock.string_(time.asTimeString.drop(-2)) };
						time = time + inc;
						inc.wait;
					}
				}).play;
			},
			{
				scheduler.stop;
			}
		);
	}),

	Button()
	.font_(Font.defaultMonoFace, 24)
	.states_([
		[ "reset", Color.gray(0.2), Color(1, 0.9, 0.5) ]
	])
	.action_({
		time = 0;
		defer{ clock.string_(time.asTimeString.drop(-2)) };
	}),

	Button()
	.font_(Font.defaultMonoFace, 24)
	.states_([
		[ "close", Color.gray(0.2), Color(0.6, 0.6, 0.9) ]
	])
	.action_({ win.close })
];

win = Window("timer", Rect(100, 100, 600, 160), border: false).front
.background_(Color.gray(0.2))
.onClose_({ scheduler.stop })
.layout_(VLayout(clock, HLayout(*buttons)));
)