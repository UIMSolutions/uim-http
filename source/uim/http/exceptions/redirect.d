module uim.cake.http.exceptions.redirect;

import uim.cake;

@safe:

/*
 * An exception subclass used by routing and application code to
 * trigger a redirect.
 *
 * The URL and status code are provided as constructor arguments.
 *
 * ```
 * throw new RedirectException("http://example.com/some/path", 301);
 * ```
 *
 * Additional headers can also be provided in the constructor, or
 * using the setHeaders() method.
 */
class RedirectException : HttpException {
    /**
     * Constructor
     * Params:
     * string atarget The URL to redirect to.
     * @param int $code The exception code that will be used as a HTTP status code
     * headerToSend - The headers that should be sent in the unauthorized challenge response.
     */
    this(string atarget, int $code = 302, array headerToSend = []) {
        super($target, $code);

        headerToSend.byKeyValue.each!(kv => this.setHeader(kv.key, (array)kv.value));
    }
}
