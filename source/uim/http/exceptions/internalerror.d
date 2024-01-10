module uim.cake.http\Exception;

import uim.cake;

@safe:

// Represents an HTTP 500 error.
class InternalErrorException : HttpException {
    protected int _defaultCode = 500;
    
    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Internal Server Error";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
