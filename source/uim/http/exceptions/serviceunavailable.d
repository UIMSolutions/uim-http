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
     */
    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Service Unavailable";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
