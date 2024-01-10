module uim.cake.http\Exception;

import uim.cake;

@safe:

/*
 * Parent class for all the HTTP related exceptions in UIM.
 * All HTTP status/error related exceptions should extend this class so
 * catch blocks can be specifically typed.
 *
 * You may also use this as a meaningful bridge to {@link \UIM\Core\Exception\UimException}, e.g.:
 * throw new \UIM\Network\Exception\HttpException("HTTP Version Not Supported", 505);
 */
class HttpException : UimException {
 
    protected int _defaultCode = 500;

    protected Json[string]  aHeaders = [];

    /**
     * Set a single HTTP response header.
     * Params:
     * string aheader Header name
     * @param string[]|string|null aValue Header value
     */
    void setHeader(string aheader, string[]|null aValue = null) {
        this.headers[aHeader] = aValue;
    }
    
    /**
     * Sets HTTP response headers.
     * Params:
     * Json[string]  aHeaders Array of header name and value pairs.
     */
    void setHeaders(Json[string]  aHeaders) {
        this.headers =  aHeaders;
    }
    
    /**
     * Returns array of response headers.
     */
    Json[string] getHeaders() {
        return this.headers;
    }
}
