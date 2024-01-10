module uim.cake.http.exceptions.invalidcsrftoken;

import uim.cake;

@safe:

/**
 * Represents an HTTP 403 error caused by an invalid CSRF token
 */
class InvalidCsrfTokenException : HttpException {
 
    protected int _defaultCode = 403;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Invalid CSRF Token' will be the message
     * @param int $code Status code, defaults to 403
     * @param \Throwable|null previousException The previous exception.
     */
    this(string aMessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Invalid CSRF Token";
        }
        super(aMessage, $code, previousException);
    }
}
