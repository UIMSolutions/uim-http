module uim.http\Exception;

import uim.cake;

@safe:

/**
 * Represents an HTTP 405 error.
 */
class MethodNotAllowedException : HttpException {
 
    protected int _defaultCode = 405;

    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Method Not Allowed";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
