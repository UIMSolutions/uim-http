module uim.cake.http.exceptions.conflict;

import uim.cake;

@safe:

/**
 * Represents an HTTP 409 error.
 */
class ConflictException : HttpException {
 
    protected int _defaultCode = 409;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Conflict' will be the message
     * @param int $code Status code, defaults to 409
     * @param \Throwable|null $previous The previous exception.
     */
    this(string amessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Conflict";
        }
        super(aMessage, $code, $previous);
    }
}