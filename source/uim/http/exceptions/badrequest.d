module uim.cake.http.exceptions.badrequest;

import uim.cake;

@safe:

// Represents an HTTP 400 error.
class BadRequestException : HttpException {
 
    protected int _defaultCode = 400;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Bad Request' will be the message
     */
    this(string amessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Bad Request";
        }
        super(aMessage, statusCode, previousException);
    }
}
