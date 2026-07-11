// Companion Code 8.1
// An Interactive Tour of Views

// This Companion Code file provides an interactive tour of common GUI classes. We iterate over a collection of GUI classes, producing an instance of each one, arranged in a vertical column on the left side of a window. Each view has a random color, and we also create a text label for each view that displays its class name in the middle column. Each view has an action that posts a string, which helps clarify the types of interactions that trigger a view's action. In the interest of precise placement, we forgo layout management classes and instead specify each view's bounds explicitly.

// Typefaces are determined using instances of the Font class, which accepts a font name (string) and font size (integer). Unavailable or invalid font names will default to one of your system's default fonts. Although all views understand the 'font' method, it has no effect on views without a text component, such as sliders and knobs.

(
w = Window(
	"A Visual Tour of Views",
	Rect(100, 100, 720, 700),
	resizable: false
).alwaysOnTop_(true).front;

~views = [
	View, Slider, Knob, RangeSlider, Slider2D, Button, PopUpMenu, TextField,
	ListView, StaticText, NumberBox, TextView, MultiSliderView
].collect({ |obj, i|

	StaticText(w, Rect(200, i * 50 + 50, 200, 50))
	.font_(Font("Arial", 16))
	.align_(\center)
	.string_(obj.asString);

	obj.new(w, Rect(0, i * 50 + 50, 200, 50))
	.background_(Color.rand) // each view has a random background color
	.font_(Font("Arial", 16))
	.action_({ postln(obj.asString ++ " action was invoked.") });
});

// Some views require more initial setup than others:

// Button: Under default conditions, a button displays no text and has only one state, so it functions as a basic "go" button. Its 'states' attribute determines the number of states and their appearances. Its value should be an array that contains as many internal arrays as desired states. Each internal array contains the display text, the text color, and the background color:

~views[5].states_([
	["OFF", Color.gray(0.4), Color.gray(0.8)],
	["ON", Color.green(0.3), Color(0, 0.8, 0.1)],
]);

// PopUpMenu: A pop-up menu is empty by default, but can be populated by providing an array of strings:

~views[6].items_(["none", "sine", "saw", "pulse"]);

// ListView: Similar to PopUpMenu, but scrollable instead of collapsible. Also populated using 'items':

~views[8].items_(["1 Hz", "10 Hz", "100 Hz", "1 kHz", "10 kHz"]);

// StaticText: A text label with no native interactive capabilities. Without specifying otherwise, the background color is transparent, and no text is displayed, so it is invisible. Text content is specified with the 'string' method, which can be left/right aligned or centered with 'align'.

~views[9]
.string_("a text label")
.align_(\center); // alternatives include \left and \right

// MultiSliderView: A bank of sliders that requires a slider count. Other adjustments are usually needed, such as slider width, slider height, and the size of the gap between sliders:

~views[12]
.size_(16)
.indexThumbSize_(10)
.gap_(2)
.valueThumbSize_(5);

// The remaining code provides text labels at the top of the window in a larger font, and a description for each view that appears in a vertical column on the right side of the window.

StaticText(w, Rect(0, 0, 200, 50))
.align_(\center)
.font_(Font("Arial", 24))
.string_("GUI Object");

StaticText(w, Rect(200, 0, 200, 50))
.align_(\center)
.font_(Font("Arial", 24))
.string_("Name");

StaticText(w, Rect(420, 0, 280, 50))
.align_(\center)
.font_(Font("Arial", 24))
.string_("Description");

StaticText(w, Rect(420, 50, 280, 50))
.string_("Empty rectangular space, commonly used as a canvas on which other views are placed.");

StaticText(w, Rect(420, 100, 280, 50))
.string_("Basic linear controller. Vertical/Horizontal orientation is automatically based on bounds, but can be overridden with 'orientation'.");

StaticText(w, Rect(420, 150, 280, 50))
.string_("Basic rotary controller. Its shape will be the largest circle that fits within its bounds.");

StaticText(w, Rect(420, 200, 280, 50))
.string_("Min/Max handles are independently movable, range is shiftable by moving the center of the handle.");

StaticText(w, Rect(420, 250, 280, 50))
.string_("Two-dimensional slider with 'x' and 'y' values.");

StaticText(w, Rect(420, 300, 280, 50))
.string_("Cycles through multiple states when clicked. Spacebar simulates a click when in focus.");

StaticText(w, Rect(420, 350, 280, 50))
.string_("Collapsible drop-down list of selectable items.");

StaticText(w, Rect(420, 400, 280, 50))
.string_("A space where text can be entered and edited.");

StaticText(w, Rect(420, 450, 280, 50))
.string_("Scrollable list of selectable items. Allows different modes of selection (e.g. selecting multiple items) via 'selectionMode'.");

StaticText(w, Rect(420, 500, 280, 50))
.string_("Non-interactable text label. These descriptions are also instances of StaticText.");

StaticText(w, Rect(420, 550, 280, 50))
.string_("Editable view for numerical entry. Allows click-and-drag with optional modifier keys.");

StaticText(w, Rect(420, 600, 280, 50))
.string_("Similar to TextField, but allows multi-line text entry and includes some formatting options.");

StaticText(w, Rect(420, 650, 280, 50))
.string_("Slider bank that can be adjusted by clicking and dragging.");
)