[

,
"C:/Users/momom/OneDrive/Documentos/Ableton/Ableton Samples/Drums/Drum machines/dm o z/Novation Drumstation/Kit06/DS06808CongaMid.wav"
]



~sound = Buffer.read(s,"C:/Users/momom/OneDrive/Documentos/Ableton/Ableton Samples/sonidos,  sfx, partes de canciones etc/ambientt8.wav", 2);
~soundFrames = ~sound.numFrames;
~randRate = Pwhite(0.5,1.5);
~randRate.post;
(
a.release;
a = {Pan2.ar((PlayBuf.ar(2, ~sound,1.0,1.0,~soundFrames.rand,0)))}.play;
)


~soundFrames.rand

s.quit;
s.boot;

// Arithmetic series
Array.series(size: 6, start: 10, step: 3);
// Geometric series
Array.geom(size: 10, start: 1, grow: 2);
// Compare the two:
Array.series(7, 100, -10); // 7 items; start at 100, step of −10
Array.geom(7, 100, 0.9); // 7 items; start at 100; multiply by 0.9 each time
// Meet the .fill method
Array.fill(10, "same");
// Compare:
Array.fill(10, rrand(1, 10));
Array.fill(10, {rrand(1, 10)}); // function is re−evaluated 10 times
// The function for the .fill method can take a default argument that is a counter.
// The argument name can be whatever you want.
Array.fill(10, {arg counter; counter * 10});
// For example, generating a list of harmonic frequencies:
Array.fill(10, {arg wow; wow+1 * 440});
// The .newClear method
a = Array.newClear(7); // creates an empty array of given size
a[3] = "wow"; // same as a.put(3, "wow")

// Shortcut notation:
30!4;
"hello" ! 10;
// It gives the same results as the following:
30.dup(4);
"hello".dup(10);
// or
Array.fill(4, 30);
Array.fill(10, "hello");

(50..79);