module uim.cake.http.exceptions.gone;

import uim.cake;

@safe:

/**
 * Represents an HTTP 410 error.
 */
class GoneException : HttpException {
 
    protected int _defaultCode = 410;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Gone' will be the message
     * @param int $code Status code, defaults to 410
     * @param \Throwable|null previousException The previous exception.
     */
    this(string aMessage = null, int $code = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Gone";
        }
        super(aMessage, $code, previousException);
    }
}
