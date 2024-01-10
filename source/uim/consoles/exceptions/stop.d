module uim.consoles.exceptions.stop;

import uim.cake;

@safe:

// Exception class for halting errors in console tasks
class StopException : ConsoleException {
	mixin(ExceptionThis!("StopException"));
}
