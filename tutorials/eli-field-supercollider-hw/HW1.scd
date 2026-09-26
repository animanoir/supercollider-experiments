// HW1 - Coding Fundamentals

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW1.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// The following code produces an error when evaluated. Remember to use the correct keystroke to evaluate the code. Correct the error and add a comment indicating the problem.

(
oranges = 3;
oranges = oranges * 2;
oranges = oranges - 1;
)






// ----------
// Problem 2.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
var oldBalance, deposit, newBalance;
oldBalance = 5
deposit = 100;
newBalance = oldBalance + deposit;
)






// ----------
// Problem 3.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
var classroomSize, numClasses, totalStudents;
classroomSize = 30;
numClasses = 4;
totalstudents = classroomSize * numClasses;
)






// ----------
// Problem 4.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
~func = {
	arg, x = 5, y = 6, z = 7;
	var product;
	product = x * y * z;
};
)






// ----------
// Problem 5.
// Consider the following expression. "odd" returns a Boolean value indicating whether its receiver is an odd number. It is written exclusively in the "receiver-dot-method" syntax. Rewrite this expression so that it is exclusively in the "method(receiver)" syntax.

45.squared.odd;






// ----------
// Problem 6.
// Write a comment that explains why the following code expression produces an error message when evaluated.

45.odd.squared;






// ----------
// Problem 7.
// Create a function that accepts an Array as its input argument, and returns an Array that is identical except the first and last items have swapped places. Don't use the "swap" method. If the input array contains exactly one or zero items, the function should return the exact same array it was given. After creating this function, include one or more additional lines of code that evaluate the function, to demonstrate that it works correctly.






// ----------
// Problem 8.
// Download and study Companion Code 1.2, which builds a function named ~p2n that converts pitch symbols, e.g., \c4, \fs5, \db3, etc., to their corresponding MIDI note numbers. Write a function named ~n2p that does the opposite, i.e., one which converts MIDI note numbers into their corresponding pitch names. Your function must return the correct pitch name for all 128 MIDI note numbers (0 through 127). Use "s" for sharp and "b" for flat. Don't worry about enharmonic spelling, in other words, you can work exclusively with sharps or flats — you don't have to mix and match or worry about key signatures. Examples of what your function should return are as follows:

~n2p.(60); // -> 'c4'

~n2p.(61); // -> 'cs4' or 'db4'

~n2p.(72); // -> 'c5', etc.








