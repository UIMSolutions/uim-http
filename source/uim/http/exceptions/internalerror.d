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
     * @param int $code Status code, defaults to 500
     * @param \Throwable|null $previous The previous exception.
     */
    this(string amessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Internal Server Error";
        }
        super(aMessage, $code, $previous);
    }
}