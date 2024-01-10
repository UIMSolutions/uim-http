module uim.cake.http.exceptions.notfound;

import uim.cake;

@safe:

 */
// Represents an HTTP 404 error.
class NotFoundException : HttpException {
 
    protected int _defaultCode = 404;

    // statusCode: Status code, defaults to 404
    this(string amessage = null, int statusCode = 0, Throwable previousException) {
        if (aMessage.isEmpty) {
            aMessage = "Not Found";
        }
        super(aMessage, statusCode, previousException);
    }
}
