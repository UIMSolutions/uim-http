module uim.cake.http.exceptions.unavailableforlegalreasons;

import uim.cake;

@safe:

/**
 * Represents an HTTP 451 error.
 */
class UnavailableForLegalReasonsException : HttpException {
 
    protected int _defaultCode = 451;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Unavailable For Legal Reasons' will be the message
     * @param \Throwable|null $previous The previous exception.
     */
    this(string amessage = null, int statusCode = 451, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Unavailable For Legal Reasons";
        }
        super(aMessage, statusCode, $previous);
    }
}
