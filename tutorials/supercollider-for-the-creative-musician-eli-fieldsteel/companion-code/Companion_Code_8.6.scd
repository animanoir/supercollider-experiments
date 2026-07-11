// Companion Code 8.6
// A Spectrum Visualizer

// This Companion Code creates a spectrum visualizer that responds to sound, featuring a combination of concepts from previous chapters, and perhaps a few new ideas. While this example may have some practical use, it is more decorative than anything else.

s.boot;

// After booting the server, the next chunk of setup code loads a built-in sound file into a buffer and adds a SynthDef. The SynthDef plays the buffer to hardware channels while randomizing the playback rate with sample-and-hold noise. At the same time, it passes the signal through a bank of 24 band-pass filters whose center frequencies range from 75 Hz to approximately 15 kHz, separated by four semitones each. An amplitude-tracking UGen measures the amplitude of each filter's output, and transmits this bank of 24 values to sclang 30 times per second using SendReply.

(
~b = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01.wav");

SynthDef(\play, { |buf = 0, run = 1, amp = 1|
	var rate, sig, filt, amptrack;
	rate = LFNoise0.kr(7).bipolar(24).midiratio;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate * run, loop: 1);
	filt = BPF.ar(sig, Array.geom(24, 75, 4.midiratio), 0.2);
	amptrack = Amplitude.kr(filt).lag(0.05);
	SendReply.kr(Impulse.kr(30), '/amp', amptrack);
	Out.ar(0, sig * 0.3 ! 2 * amp.lag(0.02));
}).add;
)

// The second chunk of code sets everything into motion, creating an animated GUI, a Synth, and an OSCdef.

(
var win, synth, visualizer, buttonView, playView, stopView;

// First, we provide a sensible default value for our array of amplitude-tracked values.

~amp = 0 ! 24;

// Next, we create our GUI, starting with a window.

win = Window("Spectrum Visualizer", Rect(100, 100, 500, 100))
.onClose_({ synth.free }).front;
win.view.background_(Color.black);

// When animated, this UserView draws 24 lines on each frame, the vertical lengths of which are determined by the 24 amplitude values. Because our perception of loudness is logarithmic with respect to normalized amplitude values, we use lincurve to warp these values, in order to produce a more uniform-looking response. As a decorative touch, a gradient is applied to the line color.
visualizer = UserView(win, Rect(10, 10, 390, 80))
.background_(Color.gray(0.2))
.frameRate_(30)
.drawFunc_({ |v|
	Pen.width_(14);
	24.do({ |i|

		// color gradient based on horizontal position:
		Pen.strokeColor_(Color(0.4, i.linlin(0, 23, 0.4, 0.8), 1));

		Pen.line(

			// each line starts at the bottom of the window
			Point(i * 15 + 20, 75),

			// and extends upward by an amount determined by one of the 24 amplitude values
			Point(i * 15 + 20, ((1 - ~amps[i]) * 75).lincurve(0, 75, 0, 75, 5))
		);
		Pen.stroke;
	});
});

// We also create a play/stop button. Both are UserViews, placed directly on top of each other. When the play button is clicked, it makes itself invisible, revealing the stop button. When the stop button is clicked, it makes the play button visible once more, concealing itself. These mouseDown functions also set the appropriate argument values for the running Synth.

stopView = UserView(win, Rect(410, 10, 80, 80))
.background_(Color.gray(0.2))
.mouseDownAction_({ |view|
	playView.visible_(true);
	synth.set(\run, 0, \amp, 0);
})
.drawFunc_({
	Pen.fillColor_(Color.red(0.8, 0.8));
	Pen.fillRect(Rect(20, 20, 40, 40));
});

playView = UserView(win, Rect(410, 10, 80, 80))
.background_(Color.gray(0.2))
.mouseDownAction_({ |view|
	view.visible_(false);
	synth.set(\run, 1, \amp, 1);
})
.drawFunc_({
	Pen.fillColor_(Color.green(0.6));
	Pen.moveTo(20 @ 15);
	Pen.lineTo(65 @ 40);
	Pen.lineTo(20 @ 65);
	Pen.lineTo(20 @ 15);
	Pen.fill;
});

// The spacebar can also be used to trigger play/stop actions, and the 'mouseDown' method allows us to simulate a mouse click using code actions.

win.view.keyDownAction_({ |view, char|
	if(char == $ ) {
		if(playView.visible)
		{playView.mouseDown}
		{stopView.mouseDown};
	};
});

// Finally, we animate the view, create the Synth, and create an OSCdef to receive the amplitude information from the server.

visualizer.animate_(true);

synth = Synth(\play, [buf: ~b, run: 0]);

OSCdef(
	\getAmps,
	{ |msg|
		~amps = msg.drop(3);
	},
	'/amp'
);
)