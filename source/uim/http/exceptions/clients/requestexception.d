module source.uim.http.exceptions.clients.requestexception;

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
class RequestException : RuntimeException : RequestExceptionInterface {
    /**
     * @var \Psr\Http\Message\IRequest
     */
    protected IRequest $request;

    /**
     * Constructor.
     * Params:
     * string amessage Exeception message.
     * @param \Psr\Http\Message\IRequest $request Request instance.
     * @param \Throwable|null $previous Previous Exception
     */
    this(string amessage, IRequest $request, Throwable previousException = null) {
        this.request = $request;
        super($message, 0, $previous);
    }
    
    /**
     * Returns the request.
     *
     * The request object MAY be a different object from the one passed to ClientInterface.sendRequest()
     */
    IRequest getRequest() {
        return this.request;
    }
}
