// Companion Code 8.5
// A Transport Control Panel

// A transport control — a bank of buttons that play, stop, pause, and handle other media navigation functions — has been a standard, intuitive feature in audio software and on recording devices for many years. This code uses UserView and Pen to create a custom transport control panel that can theoretically be integrated into other projects and modified to perform specific actions.

(
// Each transport button is a UserView, stored in an array contained in the variable 'uv'.

var uv = 7.collect({
	UserView(bounds: 60 @ 60)
	.background_(Color.gray(0.25))
});

// Each button requires its own custom graphic, each created using a specific combination of Pen methods:

uv[0].drawFunc_({ // go to the beginning
	Pen.fillColor_(Color.gray(0.75));
	Pen.fillRect(Rect(15, 10, 5, 40));
	Pen.moveTo(45 @ 10);
	Pen.lineTo(45 @ 50);
	Pen.lineTo(20 @ 30);
	Pen.lineTo(45 @ 10);
	Pen.fill;
});

uv[1].drawFunc_({ // step back/rewind
	Pen.fillColor_(Color.gray(0.75));
	[30, 50].do({ |x|
		Pen.moveTo(x @ 10);
		Pen.lineTo(x @ 50);
		Pen.lineTo((x - 20) @ 30);
		Pen.lineTo(x @ 10);
		Pen.fill;
	});
});

uv[2].drawFunc_({ // pause
	Pen.fillColor_(Color(0.7, 0.7, 0.25));
	[16, 36].do({ |x| Pen.fillRect(Rect(x, 10, 10, 40)) });
});

uv[3].drawFunc_({ // play
	Pen.fillColor_(Color.green(0.65));
	Pen.moveTo(12 @ 10);
	Pen.lineTo(52 @ 30);
	Pen.lineTo(12 @ 50);
	Pen.lineTo(12 @ 10);
	Pen.fill;
});

uv[4].drawFunc_({ // stop
	Pen.fillColor_(Color(0.8, 0.2, 0));
	Pen.fillRect(Rect(14, 13, 34, 34));
});

uv[5].drawFunc_({ // step forward/fast forward
	Pen.fillColor_(Color.gray(0.75));
	[10, 30].do({ |x|
		Pen.moveTo(x @ 10);
		Pen.lineTo(x @ 50);
		Pen.lineTo((x + 20) @ 30);
		Pen.lineTo(x @ 10);
		Pen.fill;
	});
});

uv[6].drawFunc_({ // go to the end
	Pen.fillColor_(Color.gray(0.75));
	Pen.fillRect(Rect(40, 10, 5, 40));
	Pen.moveTo(15 @ 10);
	Pen.lineTo(15 @ 50);
	Pen.lineTo(40 @ 30);
	Pen.lineTo(15 @ 10);
	Pen.fill;
});

// UserViews can be made to respond to mouse clicks by attaching a mouseDownAction to them, but this code instead uses an approach of overlaying a transparent (but tangible) View over each UserView. This approach is beneficial because it simplifies the process of creating a visual flash to confirm that a transport button has been clicked. Instead of having to program a secondary drawFunc for the "clicked" state of each UserView, we make each overlaying view slightly less transparent when a mouse button is clicked, and fully transparent when the mouse button is released.

// These tranasport buttons each post a string when clicked. In a practical context, we would want each of these buttons to do something more unique and substantive, in which case the overlaid views and their actions would likely need to be constructed and defined individually, rather than clumped together in this iteration block.

["home", "back", "pause", "play", "stop", "fwd", "end"].collect({ |name, i|
	View(uv[i], 60 @ 60).background_(Color.clear)
	.mouseDownAction_({ |v|
		(name ++ " action executed.").postln;
		v.background_(Color.gray(1, 0.2));
	})
	.mouseUpAction_({ |v| v.background_(Color.clear) });
});

// Finally, we create a window and arrange the UserViews in a horizontal layout.

Window("Transport Controls", Rect(100, 100, 500, 80), resizable: false)
.background_(Color.gray(0.15)).front
.layout_(HLayout(*uv))
)