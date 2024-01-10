module source.uim.http.exceptions.clients.request;

import uim.cake;

@safe:

/**
 * Exception for when a request failed.
 *
 * Examples:
 *
 *  - Request is invalid (e.g. method is missing)
 *  - Runtime request errors (e.g. the body stream is not seekable)
 */
class RequestException : RuntimeException, IRequestException {
    protected IRequest _request;

    this(string execeptionMessage, IRequest request, Throwable previousException = null) {
        _request = request;
        super($message, 0, previousException);
    }
    
    // Returns the request.
    IRequest getRequest() {
        return this.request;
    }
}
