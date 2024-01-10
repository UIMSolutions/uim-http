module uim.consoles.exceptions.console;

import uim.consoles;

@safe:

// Exception class for Console libraries. This exception will be thrown from Console library classes when they encounter an error.
class ConsoleException : DException {
    protected int _defaultCode = ICommand.CODE_ERROR;

	mixin(ExceptionThis!("ConsoleException"));

    this(
        string message, int exceptionCode = 0, Throwable previousException = null
    ) {
        this();
        _exceptionCode = exceptionCode;
        _previousException = previousException;
        super(message);
    }
}
