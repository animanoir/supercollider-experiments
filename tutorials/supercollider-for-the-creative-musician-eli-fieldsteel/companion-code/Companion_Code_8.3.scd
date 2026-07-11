// Companion Code 8.3
// MIDI Learn

// "MIDI Learn" refers to the ability of a program to dynamically associate specific MIDI messages with specific GUI objects, based on input from the user. This is a convenient feature when operating a MIDI-dependent GUI using a new or unknown physical controller. The centerpiece of the approach featured here is a MIDIdef named \learn, which serves as the primary "listener" and is responsible for spawning additional MIDIdefs based on received data. This MIDIdef is only active when the learn button at the bottom of the GUI is enabled. When MIDI learn is active, and a slider is in focus (i.e. you've clicked on it or pressed tab repeatedly to select it), an incoming MIDI CC message will spawn a MIDIdef that only listens to that controller number.

// A new syntax shortcut is introduced on line 74, in the process of supplying an array of sliders to HLayout. A layout management class expects a comma-separated list of views, rather than a single array of views. Preceding an array with an asterisk essentially "unpacks" the array and provides the array contents as individual items, separated by commas (without array brackets). This technique allows us to store a collection of items in an array while retaining the ability to supply the enclosed items individually, when needed.

(
Window.closeAll;
MIDIdef.freeAll;
MIDIIn.connectAll;

MIDIdef.cc(\learn, { |val, num|

	// This conditional block's test statement interacts with GUI, so the entire thing must be deferred.
	defer{

		// If a CC message is received while a slider is in focus,
		if(
			~sliders.select({ |v| v.hasFocus }).size > 0,
			{
				var index;

				// determine the index of that slider,
				index = ~sliders.collect({ |v| v.hasFocus }).indexOf(true).postln;

				// and create a unique MIDIdef to control that slider.
				MIDIdef.cc(
					("slider" ++ index).asSymbol,
					{
						|value, number|
						{ ~sliders[index].valueAction_(value/127) }.defer;
					},
					ccNum: num // <- only listen to the controller that was touched
				);

			}
		);
	};

}).disable; // Initially disabled until "MIDI Learn" button is activated

~label = StaticText()
.string_("First, enable the button. Then, click a graphical slider, move a knob/slider on your MIDI device, and repeat this process for other sliders. Disable the button when done learning assignments.");

~sliders = 4.collect({ |i|
	Slider().action_({ |v|
		// These sliders only post their value.
		// Additional actions can be place here if desired.
		postln("slider " ++ i ++ ": " ++ v.value)
	});
});

~button = Button()
.states_([
	["MIDI Learn is Disabled"],
	["MIDI Learn is Enabled", Color.white, Color(0, 0.7, 0.2)]
]).action_({ |v|
	if(
		v.value == 0,
		{ MIDIdef(\learn).disable },
		{ MIDIdef(\learn).enable }
	);
});

w = Window("MIDI Learn")
.onClose_({ MIDIdef.freeAll })
.front
.layout_(
	VLayout(
		~label,

		// "Unpack" the array and provide each slider as an individual, comma-separated item
		HLayout(*~sliders),

		~button
	)
);
)