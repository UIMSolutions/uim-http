module uim.cake.http.exceptions.notacceptable;

import uim.cake;

@safe:

// Represents an HTTP 406 error.
class NotAcceptableException : HttpException {
 
    protected int _defaultCode = 406;

    this(string exceptionMessage = null, int statusCode = null, Throwable previousException = null) {
        if (exceptionMessage.isEmpty) {
            exceptionMessage = "Not Acceptable";
        }
        super(exceptionMessage, statusCode, previousException);
    }
}
