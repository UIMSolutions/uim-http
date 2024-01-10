module uim.cake.http.exceptions.notacceptable;

import uim.cake;

@safe:

 */
// Represents an HTTP 406 error.
class NotAcceptableException : HttpException {
 
    protected int _defaultCode = 406;

    /**
     * Constructor
     * Params:
     * string|null aMessage If no message is given 'Not Acceptable' will be the message
     * @param int statusCode Status code, defaults to 406
     * @param \Throwable|null previousException The previous exception.
     */
    this(string aMessage = null, int statusCode = null, Throwable previousException = null) {
        if (aMessage.isEmpty) {
            aMessage = "Not Acceptable";
        }
        super(aMessage, statusCode, previousException);
    }
}
