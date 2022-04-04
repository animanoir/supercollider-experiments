ServerOptions.inDevices.post; // input devices
ServerOptions.outDevices; // output devices

s.options.device_("ASIO : Focusrite USB ASIO");

o = Server.default.options;
o.postln;
o.inDevice_("ASIO : Analigue 1 + 2 (Focusrite Usb Audio");
o.outDevice_("ASIO : Focusrite USB ASIO");
Server.default.reboot;
s.quit;
s.boot;
s.options.sampleRate = 48000

{ [SinOsc.ar(440.rand, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;



(
{ var ampOsc;
	ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
	SinOsc.ar(560, 0, ampOsc);
}.play;
)