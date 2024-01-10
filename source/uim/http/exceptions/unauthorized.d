module uim.cake.http.exceptions.unauthorized;

import uim.cake;

@safe:

/**
 * Represents an HTTP 401 error.
 */
class UnauthorizedException : HttpException {
 
    protected int _defaultCode = 401;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Unauthorized' will be the message
     * @param int $code Status code, defaults to 401
     * @param \Throwable|null $previous The previous exception.
     */
    this(string aMessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Unauthorized";
        }
        super(aMessage, $code, $previous);
    }
}
