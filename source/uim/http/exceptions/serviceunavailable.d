module uim.http\Exception;

import uim.cake;

@safe:

// Represents an HTTP 503 error.
class ServiceUnavailableException : HttpException {
 
    protected int _defaultCode = 503;

    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Service Unavailable";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
