module uim.http.exceptions.conflict;

import uim.cake;

@safe:

/**
 * Represents an HTTP 409 error.
 */
class ConflictException : HttpException {
 
    protected int _defaultCode = 409;

    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Conflict";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
