// Companion Code 7.2
// A Note Entry Utility

// Note entry can be cumbersome in SC, especially when compared to note entry utilities in DAWs and notation software. When we build Pbinds, for example, we might find ourselves typing out a long sequence of pitch information that could theoretically be "played in" using a MIDI keyboard much more quickly. This kind of note entry utility does not natively exist in SC, but it's possible to build something ourselves using a few cleverly designed MIDIdefs.

// Our goal, then, is to be able to use a MIDI controller to print a string that represents a specific array of pitch information (complete with square brackets and commas) that we can then copy and paste into a Pbind (or elsewhere).

// Our first example serves as a note entry utility for monophonic sequences. It assumes you're using a MIDI keyboard controller with note keys and a modulation wheel. When moved into its highest position, the mod wheel will print an opening square bracket in the post window (using 'post' instead of 'postln' to avoid printing a return character), and prints a closing bracket and new line when the mod wheel is moved to its lowest position. When a note-on message is received, a \noteEntry MIDIdef prints the note number in the post window. More specifically, the MIDIdef checks to see if the array is empty. If it is, it prints only the note number. If not, it prints a comma before printing the note. The pitch wheel, when moved to either of its extremes, will print the empty symbol "\", which represents a rest.

// Recall that the backslash is the "escape" character, used to invoke an alternative interpretation of the character that follows it. Thus, to properly render the backslash character, we must precede it with itself. Otherwise, the interpreter will view the string as being improperly closed and report a syntax error.

// Evaluate the following code, clear the post window, and practice entering a few different note sequences.

(
~empty = true;
MIDIdef.freeAll;
MIDIIn.connectAll;

MIDIdef.noteOn(\noteEntry, { |val, num|
	if(not(~empty)) {",".post; };
	num.post;
	~empty = false;
});

MIDIdef.bend(\restEntry, { |val|
	if( (val == 0) || (val == 16383) ) {
		if(not(~empty)) { ",".post };
		"\\".post; // post a single backslash
		~empty = false;
	};
});

MIDIdef.cc(\bracket, { |val, num|
	if(val == 127) { "[".post };
	if(val == 0) { "]".postln; ~empty = true };
}, 1);
)

// In the context of Pbind, nested arrays of pitch values are interpreted as chords (multiple Synths per Event). For example, a C-major chord followed by a D-minor chord might look something like this:

[ [60, 64, 67], [62, 65, 69] ]

// But, our previous code is incapable of rendering nested arrays, so a few modifications are necessary to enable polyphonic note entry. In the following code, the MIDIdefs that respond to the pitch and mod wheels remain the same, but a note-off MIDIdef is now responsible for printing note information.

// Two sets, ~coll and ~heldNotes, both represent the collection of MIDI keys that are currently held down. The Set class is similar to Array, but is unordered and cannot contain duplicate items, which makes it simpler to remove items based on their value, rather than their index. Using Sets also models the physical behavior of a MIDI controller more accurately (it is impossible to press a key that is already being held down). The difference between these two collections is that ~heldNotes updates immediately, as soon as any key is released, while ~coll updates removed notes after a short delay. This delay provides a short window of time in which the MIDIdef can become aware that no more notes are being held, thus indicating that note information is ready to be printed, while still having access to the non-empty set that existed a fraction of a second ago.

// Also, be aware that the global variable ~empty, initially true, refers to the ongoing collection of data being printed in the post window, and is used to determine whether a comma should be printed before printing the next note/chord. It does not refer to whether a Set of currently depressed keys is empty or not. After we first enter a note or a chord (by lifting all keys), or a rest (by nudging the pitch wheel to one of its extremes), ~empty is set to false to indicate that some data has been entered. When we use the mod wheel to close our final set of square brackets, the printed data in the post window is considered finished, so ~empty is set to be true again.

(
~delay = 0.05;
~empty = true;
~coll = Set.new;
~heldNotes = Set.new;

MIDIdef.freeAll;
MIDIIn.connectAll;

MIDIdef.noteOn(\noteEntryOn, { |val, num|
	~heldNotes.add(num);
	~coll.add(num);
});

MIDIdef.noteOff(\noteEntryOff, { |val, num|

	Routine({

		~heldNotes.remove(num);

		if(
			~heldNotes.size == 0, // if all keys have been lifted
			{

				// post a comma if this is not the first entry
				if(not(~empty), { ",".post });

				if(
					~coll.size > 1, // if a chord was being played,
					{
						// post a sorted array of notes
						~coll.asArray.sort.asString
						.reject({ |n| n.asString == " "}) // remove space characters
						.post;
						~empty = false;
					},

					{
						// otherwise, just post the note number (not an array)
						~coll.asArray[0].post;
						~empty = false;
					};
				);
			}
		);

		wait(~delay);
		~coll.remove(num);

	}).play;
});

MIDIdef.bend(\restEntry, { |val|
	if(
		(val == 0) || (val == 16383),
		{
			if(not(~empty), { ",".post });
			"\\".post;
			~empty = false;
		}
	);
});

MIDIdef.cc(\bracket, { |val, num|
	if(val == 127) { "[".post };
	if(val == 0) { "]".postln; ~empty = true };
}, 1);
)

// By virtue of design, this utility allows the user to "build" a chord note-by-note, i.e. pressing and holding several keys in sequence. It is only when all notes are released that SC checks and prints note numbers. Similarly, it is possible to release individual keys from a cluster in order to remove notes from a chord-in-progress, before printing occurs. So long as at least one key remains depressed, SC will not print anything.

// It is still possible to "confuse" this note entry utility by playing sloppily. Fast/messy sequences of multiple notes may blur the distinction between what is considered a chord vs. a rapid sequence of individual notes. Slow, deliberate note entry produces more reliable results. Alternatively, the ~delay value can be adjusted; shorter values will favor sequential entry of individual notes, and longer values will favor chords.