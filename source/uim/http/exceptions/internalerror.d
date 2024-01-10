module uim.cake.http\Exception;

import uim.cake;

@safe:

/**
 * Represents an HTTP 500 error.
 */
class InternalErrorException : HttpException {
    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Internal Server Error' will be the message
     * @param int statusCode Status code, defaults to 500
     * @param \Throwable|null previousException The previous exception.
     */
    this(string amessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Internal Server Error";
        }
        super(aMessage, statusCode, previousException);
    }
}
