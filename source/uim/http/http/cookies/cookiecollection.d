module uim.cake.http\Cookie;

import uim.cake;

@safe:

/**
 * Cookie Collection
 *
 * Provides an immutable collection of cookies objects. Adding or removing
 * to a collection returns a *new* collection that you must retain.
 *
 * @template-implements \IteratorAggregate<string, \UIM\Http\Cookie\ICookie>
 */
class CookieCollection : IteratorAggregate, Countable {
    /**
     * Cookie objects
     *
     * @var array<string, \UIM\Http\Cookie\ICookie>
     */
    protected array cookies = [];

    /**
     * Constructor
     * Params:
     * array<\UIM\Http\Cookie\ICookie> cookies Array of cookie objects
     */
    this(array cookies = []) {
        this.checkCookies(cookies);
        cookies.each!(cookie => this.cookies[cookie.id] = cookie);
    }
    
    /**
     * Create a Cookie Collection from an array of Set-Cookie Headers
     * Params:
     * @param IData[string] defaults The defaults attributes.
     */
    static auto createFromHeader(string[] headerValues, IData[string] defaultAttributes = null) {
        cookies = [];
        headerValues.each!((value) {
            try {
                cookies ~= Cookie.createFromHeaderString(value, defaultAttributes);
            } catch (Exception | TypeError  anException) {
                // Don`t blow up on invalid cookies
            }
        });
        return new static(cookies);
    }
    
    /**
     * Create a new collection from the cookies in a ServerRequest
     * Params:
     * \Psr\Http\Message\IServerRequest serverRequest The request to extract cookie data from
     */
    static static createFromServerRequest(IServerRequest serverRequest) {
        someData = request.getCookieParams();
        cookies = [];
        foreach (someData as name: aValue) {
            cookies ~= new Cookie((string)name, aValue);
        }
        return new static(cookies);
    }
    
    // Get the number of cookies in the collection.
    size_t count() {
        return count(this.cookies);
    }
    
    /**
     * Add a cookie and get an updated collection.
     *
     * Cookies are stored by id. This means that there can be duplicate
     * cookies if a cookie collection is used for cookies across multiple
     * domains. This can impact how get(), has() and remove() behave.
     * Params:
     * \UIM\Http\Cookie\ICookie cookie Cookie instance to add.
     */
    static add(ICookie cookie) {
        new = clone this;
        new.cookies[cookie.getId()] = cookie;

        return new;
    }
    
    /**
     * Get the first cookie by name.
     * Params:
     * string aName The name of the cookie.
     */
    ICookie get(string aName) {
        cookie = __get(name);

        if (cookie.isNull) {
            throw new InvalidArgumentException(
                
                    "Cookie `%s` not found. Use `has()` to check first for existence."
                    .format(name
                )
            );
        }
        return cookie;
    }
    
    // Check if a cookie with the given name exists
    auto has(string cookieName) {
        return !__get(cookieName).isNull;
    }
    
    /**
     * Get the first cookie by name if cookie with provided name exists
     * Params:
     * string aName The name of the cookie.
     */
    ICookie __get(string aName) {
        aKey = mb_strtolower(name);
        foreach (cookie; this.cookies) {
            if (mb_strtolower(cookie.name) == aKey) {
                return cookie;
            }
        }
        return null;
    }
    
    /**
     * Check if a cookie with the given name exists
     * Params:
     * string aName The cookie name to check.
     */
    bool __isSet(string aName) {
        return __get(name) !isNull;
    }
    
    /**
     * Create a new collection with all cookies matching name removed.
     *
     * If the cookie is not in the collection, this method will do nothing.
     * Params:
     * string aName The name of the cookie to remove.
     */
    static remove(string aName) {
        new = clone this;
        aKey = mb_strtolower(name);
        foreach (new.cookies as  anI: cookie) {
            if (mb_strtolower(cookie.name) == aKey) {
                unset(new.cookies[anI]);
            }
        }
        return new;
    }
    
    /**
     * Checks if only valid cookie objects are in the array
     * Params:
     * array<\UIM\Http\Cookie\ICookie> cookies Array of cookie objects
     */
    protected void checkCookies(array cookies) {
        foreach (anIndex: cookie; cookies) {
            if (!cast(ICookie)!cookie) {
                throw new InvalidArgumentException(                    
                    "Expected `%s[]` as cookies but instead got `%s` at index %d"
                    .format(
                        class,
                        get_debug_type(cookie),
                        anIndex
                    )
                );
            }
        }
    }
    
    /**
     * Gets the iterator
     */
    Traversable getIterator() {
        return new ArrayIterator(this.cookies);
    }
    
    /**
     * Add cookies that match the path/domain/expiration to the request.
     *
     * This allows CookieCollections to be used as a 'cookie jar' in an HTTP client
     * situation. Cookies that match the request`s domain + path that are not expired
     * when this method is called will be applied to the request.
     * Params:
     * \Psr\Http\Message\IRequest request The request to update.
     * @param array extraCookies Associative array of additional cookies to add into the request. This
     *  is useful when you have cookie data from outside the collection you want to send.
     */
    IRequest addToRequest(IRequest request, array extraCookies = []) {
        anUri = request.getUri();
        cookies = this.findMatchingCookies(
            anUri.getScheme(),
            anUri.getHost(),
            anUri.getPath() ?: '/'
        );
        cookies = extraCookies + cookies;
        cookiePairs = [];
        foreach (cookies as aKey: aValue) {
            cookie = "%s=%s".format(rawurlencode((string)aKey), rawurlencode(aValue));
            size = cookie.length;
            if (size > 4096) {
                triggerWarning(
                    "The cookie `%s` exceeds the recommended maximum cookie length of 4096 bytes."
                    .format(aKey
                ));
            }
            cookiePairs ~= cookie;
        }
        if (isEmpty(cookiePairs)) {
            return request;
        }
        return request.withHeader("Cookie", join("; ", cookiePairs));
    }
    
    /**
     * Find cookies matching the scheme, host, and path
     * Params:
     * string ascheme The http scheme to match
     * @param string ahost The host to match.
     * @param string aPath The path to match
     */
    protected IData[string] findMatchingCookies(string ascheme, string ahost, string aPath) {
         auto result;
        now = new DateTimeImmutable("now", new DateTimeZone("UTC"));
        foreach (this.cookies as cookie) {
            if (scheme == "http' && cookie.isSecure()) {
                continue;
            }
            if (!str_starts_with(somePath, cookie.getPath())) {
                continue;
            }
            domain = cookie.getDomain();
            leadingDot = str_starts_with(domain, ".");
            if (leadingDot) {
                domain = ltrim(domain, ".");
            }
            if (cookie.isExpired(now)) {
                continue;
            }
             somePattern = "/" ~ preg_quote(domain, "/") ~ "/";
            if (!preg_match(somePattern, host)) {
                continue;
            }
             result[cookie.name] = cookie.getValue();
        }
        return result;
    }
    
    /**
     * Create a new collection that includes cookies from the response.
     * Params:
     * \Psr\Http\Message\IResponse response Response to extract cookies from.
     * @param \Psr\Http\Message\IRequest request Request to get cookie context from.
     */
    static addFromResponse(IResponse response, IRequest request) {
        anUri = request.getUri();
        host = anUri.getHost();
        somePath = anUri.getPath() ?: '/";

        cookies = createFromHeader(
            response.getHeader("Set-Cookie"),
            ["domain": host, "path": somePath]
        );
        new = clone this;
        foreach (cookies as cookie) {
            new.cookies[cookie.getId()] = cookie;
        }
        new.removeExpiredCookies(host, somePath);

        return new;
    }
    
    /**
     * Remove expired cookies from the collection.
     * Params:
     * string ahost The host to check for expired cookies on.
     * @param string aPath The path to check for expired cookies on.
     */
    protected void removeExpiredCookies(string ahost, string aPath) {
        time = new DateTimeImmutable("now", new DateTimeZone("UTC"));
        hostPattern = "/" ~ preg_quote(host, "/") ~ "/";

        foreach (this.cookies as  anI: cookie) {
            if (!cookie.isExpired(time)) {
                continue;
            }
            somePathMatches = str_starts_with(somePath, cookie.getPath());
            hostMatches = preg_match(hostPattern, cookie.getDomain());
            if (somePathMatches && hostMatches) {
                unset(this.cookies[anI]);
            }
        }
    }
}
