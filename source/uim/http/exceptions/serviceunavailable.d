module uim.cake.http\Exception;

import uim.cake;

@safe:

/**
 * Represents an HTTP 503 error.
 */
class ServiceUnavailableException : HttpException {
 
    protected int _defaultCode = 503;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given `service Unavailable' will be the message
     * @param int statusCode Status code, defaults to 503
     * @param \Throwable|null previousException The previous exception.
     */
    this(string aMessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Service Unavailable";
        }
        super(aMessage, statusCode, previousException);
    }
}
