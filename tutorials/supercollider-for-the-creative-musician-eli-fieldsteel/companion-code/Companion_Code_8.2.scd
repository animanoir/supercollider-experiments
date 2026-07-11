// Companion Code 8.2
// A Virtual Piano Keyboard

// Creating a virtual piano keyboard that can be "played" with your computer keyboard is one idea for catching keystrokes and putting them to practical use in a GUI. Much of this code involves conditional logic and number-tweaking to ensure keystrokes are correctly mapped to GUI elements and pitch values. Key-down and key-up actions are registered to the TopView on the window (rather than individual piano keys) so that no individual piano key needs to be in focus to receive keystrokes.

// Although the Button class is one possible choice for representing virtual piano keys, we use the View class to demonstrate its usefulness as a generic rectangular unit — a sort of "blank slate" that can be freely customized with mouse/keyboard actions.

// Because some views will overlap (black keys are rectangles that partially obscure white rectangles underneath), we forgo layout management tools and instead specify bounds information directly.

s.boot;

(
var wkeys, bkeys, synths;

synths = Array.newClear(17); // Contains Synths resulting from key presses

w = Window(
	"virtual piano",
	Rect(
		Window.screenBounds.width/2 - (301/2),
		Window.screenBounds.height/2 - (101/2),
		301,
		101
)).front;

// White and black keys are Views:

wkeys = 10.collect({ |i|
	View(w, Rect(i * 30 + 1, 1, 29, 98)).background_(Color.white);
});

bkeys = [0, 1, 3, 4, 5, 7, 8].collect({ |i|
	View(w, Rect(i * 30 + 21, 1, 19, 66)).background_(Color.black);
});

// Computer keyboard labels are StaticText objects, placed directly on individual piano keys:

"ASDFGHJKL;".do({ |char, i|
	StaticText(wkeys[i], Rect(7, 80, 15, 15))
	.align_(\center)
	.font_(Font("Arial", 14))
	.string_(char);
});

"WETYUOP".do({ |char, i|
	StaticText(bkeys[i], Rect(2, 47, 15, 15))
	.align_(\center)
	.font_(Font("Arial", 14))
	.stringColor_(Color.white)
	.string_(char);
});

// Define key actions:

w.view.keyDownAction_({ |view, char|
	var deg;

	// Ignore invalid keys:
	if("AWSEDFTGYHUJKOLP;".contains(char.toUpper)) {

		deg = "AWSEDFTGYHUJKOLP;".indexOf(char.toUpper);

		// Normally, holding down a computer key cause the key to "repeat."
		// This conditional check attempts to ignore key repeats if that key's
		// Synth already exists. However, this check produces results that
		// may differ by operating system. Some systems interpret a held key as
		// being indistinguishable from the user physically pressing the key
		// repeatedly (which produces a sequence of Synths), while other systems
		// interpret this action as a single key-down.
		if(synths[deg].isNil) {

			// Create the synth:
			synths[deg] = Synth(\default, [
				freq: (deg.degreeToKey(Scale.chromatic) + 60).midicps,
				amp: 0.25,
			]);

			// Colorize the key to indicate it is pressed:
			if( [0, 2, 4, 5, 7, 9, 11, 12, 14, 16].includes(deg) ) {
				wkeys[[0, 2, 4, 5, 7, 9, 11, 12, 14, 16].indexOf(deg)].background_(Color.cyan)
			} {
				bkeys[[1, 3, 6, 8, 10, 13, 15].indexOf(deg)].background_(Color.cyan(0.6))
			};
		};
	};
});

w.view.keyUpAction_({ |view, char|
	var deg;
	if("AWSEDFTGYHUJKOLP;".contains(char.toUpper)) {
		deg = "AWSEDFTGYHUJKOLP;".indexOf(char.toUpper);

		// When a key is released, free the synth and replace the array slot with nil:
		synths[deg].set(\gate, 0, \fadeTime, 0.02);
		synths[deg] = nil;

		// And un-colorize the key:
		if([0, 2, 4, 5, 7, 9, 11, 12, 14, 16].includes(deg)) {
			wkeys[[0, 2, 4, 5, 7, 9, 11, 12, 14, 16].indexOf(deg)].background_(Color.white)
		} {
			bkeys[[1, 3, 6, 8, 10, 13, 15].indexOf(deg)].background_(Color.black)
		};
	};
});
)