ServerOptions.inDevices.post; // input devices
ServerOptions.outDevices; // output devices

s.options.device_("ASIO : Focusrite USB ASIO");

o = Server.default.options;
o.postln;
o.sampleRate = 48000
o.inDevice_("ASIO : Analigue 1 + 2 (Focusrite Usb Audio");
o.outDevice_("ASIO : Focusrite USB ASIO");
Server.default.reboot;
s.quit;
s.boot;
s.options.sampleRate = 48000

{ [SinOsc.ar(440.rand, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;

{RLPF.ar(Dust.ar([10, 15]), LFNoise1.ar([0.3, 2]).range(100, 3000), 0.02)}.play;

(
{ var ampOsc;
	ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
	SinOsc.ar(560, 0, ampOsc);
}.play;
)

Pbind(\degree, Pseries(0, 1, 30), \dur, 0.05).play;
Pbind(\degree, 1, \dur, 0.3).play;
Pbind(\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 1), \dur, 0.2).play;
Pbind(\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], 5), \dur, Pseq([0.2, 0.1, 0.1, 0.2, 0.2, 0.35], 1)).play;

s.record;
s.stopRecording;