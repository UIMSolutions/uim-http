module uim.cake.http\Middleware;

import uim.cake;

@safe:

/**
 * Provides CSRF protection & validation.
 *
 * This middleware adds a CSRF token to a cookie. The cookie value is compared to
 * token in request data, or the X-CSRF-Token header on each PATCH, POST,
 * PUT, or DELETE request. This is known as "double submit cookie" technique.
 *
 * If the request data is missing or does not match the cookie data,
 * an InvalidCsrfTokenException will be raised.
 *
 * This middleware integrates with the FormHelper automatically and when
 * used together your forms will have CSRF tokens automatically added
 * when `this.Form.create(...)` is used in a view.
 *
 * @see https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#double-submit-cookie
 */
class CsrfProtectionMiddleware : IMiddleware {
    /**
     * Config for the CSRF handling.
     *
     * - `cookieName` The name of the cookie to send.
     * - `expiry` A strotime compatible value of how long the CSRF token should last.
     *   Defaults to browser session.
     * - `secure` Whether the cookie will be set with the Secure flag. Defaults to false.
     * - `httponly` Whether the cookie will be set with the HttpOnly flag. Defaults to false.
     * - `samesite` "SameSite" attribute for cookies. Defaults to `null`.
     *   Valid values: `ICookie.SAMESITE_LAX`, `ICookie.SAMESITE_STRICT`,
     *   `ICookie.SAMESITE_NONE` or `null`.
     * - `field` The form field to check. Changing this will also require configuring
     *   FormHelper.
     *
     */
    protected Json _config = [
        "cookieName": "csrfToken",
        "expiry": 0,
        "secure": false,
        "httponly": false,
        "samesite": null,
        "field": "_csrfToken",
    ];

    /**
     * Callback for deciding whether to skip the token check for particular request.
     *
     * CSRF protection token check will be skipped if the callback returns `true`.
     */
    protected callable skipCheckCallback;

    const int TOKEN_VALUE_LENGTH = 16;

    /**
     * Tokens have an hmac generated so we can ensure
     * that tokens were generated by our application.
     *
     * Should be TOKEN_VALUE_LENGTH + hmac.length
     *
     * We are currently using sha1 for the hmac which
     * creates 40 bytes.
     */
    const int TOKEN_WITH_CHECKSUM_LENGTH = 56;

    this(IConfigData[string] configData = null) {
       _config = configData + _config;
    }
    
    /**
     * Checks and sets the CSRF token depending on the HTTP verb.
     * Params:
     * \Psr\Http\Message\IServerRequest serverRequest The request.
     * @param \Psr\Http\Server\IRequestHandler handler The request handler.
     */
    IResponse process(IServerRequest serverRequest, IRequestHandler handler) {
        method = request.getMethod();
        hasData = in_array($method, ["PUT", "POST", "DELETE", "PATCH"], true)
            || request.getParsedBody();

        if (
            hasData
            && this.skipCheckCallback !isNull
            && call_user_func(this.skipCheckCallback, request) == true
        ) {
            request = _unsetTokenField($request);

            return handler.handle($request);
        }
        if ($request.getAttribute("csrfToken")) {
            throw new UimException(
                'A CSRF token is already set in the request.' .
                "\n" .
                'Ensure you do not have the CSRF middleware applied more than once. ' .
                'Check both your `Application.middleware()` method and `config/routes.d`.'
            );
        }
        cookies = request.getCookieParams();
        cookieData = Hash.get($cookies, configuration.data("cookieName"]);

        if (isString($cookieData) && !$cookieData.isEmpty) {
            try {
                request = request.withAttribute("csrfToken", this.saltToken($cookieData));
            } catch (InvalidArgumentException  anException) {
                cookieData = null;
            }
        }
        if ($method == "GET" && cookieData.isNull) {
            token = this.createToken();
            request = request.withAttribute("csrfToken", this.saltToken($token));
            response = handler.handle($request);

            return _addTokenCookie($token, request, response);
        }
        if ($hasData) {
           _validateToken($request);
            request = _unsetTokenField($request);
        }
        return handler.handle($request);
    }
    
    /**
     * Set callback for allowing to skip token check for particular request.
     *
     * The callback will receive request instance as argument and must return
     * `true` if you want to skip token check for the current request.
     * Params:
     * callable aCallback A callable.
     */
    void skipCheckCallback(callable aCallback) {
        this.skipCheckCallback = aCallback;
    }
    
    /**
     * Remove CSRF protection token from request data.
     * Params:
     * \Psr\Http\Message\IServerRequest serverRequest The request object.
     */
    protected IServerRequest _unsetTokenField(IServerRequest serverRequest) {
        body = request.getParsedBody();
        if (isArray($body)) {
            unset($body[configuration.data("field"]]);
            request = request.withParsedBody($body);
        }
        return request;
    }
    
    /**
     * Test if the token predates salted tokens.
     *
     * These tokens are hexadecimal values and equal
     * to the token with checksum length. While they are vulnerable
     * to BREACH they should rotate over time and support will be dropped
     * in 5.x.
     * Params:
     * string atoken The token to test.
     */
    protected bool isHexadecimalToken(string atoken) {
        return preg_match("/^[a-f0-9]{" ~ TOKEN_WITH_CHECKSUM_LENGTH ~ "}$/", token) == 1;
    }
    
    /**
     * Create a new token to be used for CSRF protection
     */
    string createToken() {
        aValue = Security.randomBytes(TOKEN_VALUE_LENGTH);

        return base64_encode(aValue ~ hash_hmac("sha1", aValue, Security.getSalt()));
    }
    
    /**
     * Apply entropy to a CSRF token
     *
     * To avoid BREACH apply a random salt value to a token
     * When the token is compared to the session the token needs
     * to be unsalted.
     * Params:
     * string atoken The token to salt.
     */
    string saltToken(string atoken) {
        if (this.isHexadecimalToken($token)) {
            return token;
        }
        decoded = base64_decode($token, true);
        if ($decoded == false) {
            throw new InvalidArgumentException("Invalid token data.");
        }
        length = decoded.length;
        salt = Security.randomBytes($length);
        
        string salted = "";
        for (anI = 0;  anI < length;  anI++) {
            // XOR the token and salt together so that we can reverse it later.
            salted ~= chr(ord($decoded[anI]) ^ ord($salt[anI]));
        }
        return base64_encode($salted ~ salt);
    }
    
    /**
     * Remove the salt from a CSRF token.
     *
     * If the token is not TOKEN_VALUE_LENGTH * 2 it is an old
     * unsalted value that is supported for backwards compatibility.
     * Params:
     * string atoken The token that could be salty.
     */
    string unsaltToken(string atoken) {
        if (this.isHexadecimalToken($token)) {
            return token;
        }
        decoded = base64_decode($token, true);
        if ($decoded == false || decoded.length != TOKEN_WITH_CHECKSUM_LENGTH * 2) {
            return token;
        }
        salted = substr($decoded, 0, TOKEN_WITH_CHECKSUM_LENGTH);
        salt = substr($decoded, TOKEN_WITH_CHECKSUM_LENGTH);

        string unsalted = "";
        for (anI = 0;  anI < TOKEN_WITH_CHECKSUM_LENGTH;  anI++) {
            // Reverse the XOR to desalt.
            unsalted ~= chr(ord($salted[anI]) ^ ord($salt[anI]));
        }
        return base64_encode($unsalted);
    }
    
    // Verify that CSRF token was originally generated by the receiving application.
    protected bool _verifyToken(string csrfToken) {
        // If we have a hexadecimal value we're in a compatibility mode from before
        // tokens were salted on each request.
        string decoded = this.isHexadecimalToken(csrfToken)
            ? csrfToken
            : base64_decode(csrfToken, true);

        if (!$decoded || decoded.length <= TOKEN_VALUE_LENGTH) {
            return false;
        }
        aKey = substr($decoded, 0, TOKEN_VALUE_LENGTH);
        hmac = substr($decoded, TOKEN_VALUE_LENGTH);

        expectedHmac = hash_hmac("sha1", aKey, Security.getSalt());

        return hash_equals($hmac, expectedHmac);
    }
    
    /**
     * Add a CSRF token to the response cookies.
     * Params:
     * string atoken The token to add.
     * @param \Psr\Http\Message\IServerRequest serverRequest The request to validate against.
     * @param \Psr\Http\Message\IResponse response The response.
     */
    protected IResponse _addTokenCookie(
        string tokenToAdd,
        IServerRequest serverRequest,
        IResponse response
    ) {
        cookie = _createCookie(tokenToAdd, serverRequest);
        if (cast(Response)response) {
            return response.withCookie($cookie);
        }
        return response.withAddedHeader("Set-Cookie", cookie.toHeaderValue());
    }
    
    /**
     * Validate the request data against the cookie token.
     * Params:
     * \Psr\Http\Message\IServerRequest serverRequest The request to validate against.
     */
    protected void _validateToken(IServerRequest serverRequest) {
        cookie = Hash.get($request.getCookieParams(), configuration.data("cookieName"]);

        if (!$cookie || !isString($cookie)) {
            throw new InvalidCsrfTokenException(__d("uim", "Missing or incorrect CSRF cookie type."));
        }
        if (!_verifyToken($cookie)) {
            exception = new InvalidCsrfTokenException(__d("uim", "Missing or invalid CSRF cookie."));

            expiredCookie = _createCookie("", request).withExpired();
            exception.setHeader("Set-Cookie", expiredCookie.toHeaderValue());

            throw exception;
        }
        body = request.getParsedBody();
        if (isArray($body) || cast(ArrayAccess)$body) {
            post = to!string(Hash.get($body, configuration.data("field"]));
            post = this.unsaltToken($post);
            if (hash_equals($post, cookie)) {
                return;
            }
        }
         aHeader = request.getHeaderLine("X-CSRF-Token");
         aHeader = this.unsaltToken( aHeader);
        if (hash_equals( aHeader, cookie)) {
            return;
        }
        throw new InvalidCsrfTokenException(__d(
            "uim",
            "CSRF token from either the request body or request headers did not match or is missing."
        ));
    }
    
    /**
     * Create response cookie
     * Params:
     * string avalue Cookie value
     * @param \Psr\Http\Message\IServerRequest serverRequest The request object.
     */
    protected ICookie _createCookie(string avalue, IServerRequest serverRequest) {
        return Cookie.create(
           configuration.data("cookieName"],
            aValue,
            [
                'expires": configuration.data("expiry"] ?: null,
                'path": request.getAttribute("webroot"),
                `secure": configuration.data("secure"],
                'httponly": configuration.data("httponly"],
                `samesite": configuration.data("samesite"],
            ]
        );
    }
}