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
     * @param int statusCode Status code, defaults to 409
     * @param \Throwable|null previousException The previous exception.
     */
    this(string amessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Conflict";
        }
        super(aMessage, statusCode, previousException);
    }
}
