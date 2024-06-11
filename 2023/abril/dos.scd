~myFreqs = Array.fill(10, {rrand(440, 880)});
// Now let's do some simple action on every item of the list:
~myFreqs.do({arg item, count; ("Item " ++ count ++ " is " ++ item ++ " Hz. Closest
midinote is " ++ item.cpsmidi.round).postln});

// If you don't need the counter, just use one argument:
~myFreqs.do({arg item; {SinOsc.ar(item, 0, 0.1)}.play});
~myFreqs.do({arg item; item.squared.postln});
// Of course something as simple as the last one could be done like this:
~myFreqs.squared

s.quit;