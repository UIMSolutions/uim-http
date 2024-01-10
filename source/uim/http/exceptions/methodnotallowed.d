module uim.cake.http\Exception;

import uim.cake;

@safe:

/**
 * Represents an HTTP 405 error.
 */
class MethodNotAllowedException : HttpException {
 
    protected int _defaultCode = 405;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Method Not Allowed' will be the message
     */
    this(string aMessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Method Not Allowed";
        }
        super(aMessage, statusCode, previousException);
    }
}
