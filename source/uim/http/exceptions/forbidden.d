module uim.cake.http.exceptions.forbidden;

import uim.cake;

@safe:

/**
 * Represents an HTTP 403 error.
 */
class ForbiddenException : HttpException {
 
    protected int _defaultCode = 403;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Forbidden' will be the message
     * @param int $code Status code, defaults to 403
     * @param \Throwable|null previousException The previous exception.
     */
    this(string amessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Forbidden";
        }
        super(aMessage, $code, previousException);
    }
}
