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
     * @param int $code Status code, defaults to 405
     * @param \Throwable|null previousException The previous exception.
     */
    this(string aMessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Method Not Allowed";
        }
        super(aMessage, $code, previousException);
    }
}
