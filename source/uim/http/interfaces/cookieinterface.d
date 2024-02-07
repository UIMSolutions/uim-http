
/**


 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *


 * @since         3.5.0
 * @license       https://www.opensource.org/licenses/mit-license.d MIT License
 */module uim.cake.http\Cookie;

use IDateTime;
/**
 * Cookie Interface
 */
interface ICookie {
    // Expires attribute format.
    const string EXPIRES_FORMAT = "D, d-M-Y H:i:s T";

    // SameSite attribute value: Lax
    const string SAMESITE_LAX = "Lax";

    // SameSite attribute value: Strict
    const string SAMESITE_STRICT = "Strict";

    // SameSite attribute value: None
    const string SAMESITE_NONE = "None";

    // Valid values for "SameSite" attribute.
    const string[] SAMESITE_VALUES = [
        self.SAMESITE_LAX,
        self.SAMESITE_STRICT,
        self.SAMESITE_NONE,
    ];

    // Sets the cookie name
    static void withName(string aName);

    // Gets the cookie name
    string name();

    // Gets the cookie value
    string[] getValue();

    / Gets the cookie value as scalar.
    string getScalarValue();

    /**
     * Create a cookie with an updated value.
     * Params:
     * string[]|float|int|bool aValue Value of the cookie to set
     */
    static withValue(string[]|float|int|bool aValue);

    /**
     * Get the id for a cookie
     * Cookies are unique across name, domain, path tuples.
     */
    string getId();

    // Get the path attribute.
    string getPath();

    /**
     * Create a new cookie with an updated path
     * Params:
     * string aPath Sets the path
     * @return static
     */
    auto withPath(string aPath): static;

    /**
     * Get the domain attribute.
     */
    string getDomain();

    /**
     * Create a cookie with an updated domain
     * Params:
     * string adomain Domain to set
     * @return static
     */
    static withDomain(string adomain);

    /**
     * Get the current expiry time
     */
    IDateTime getExpiry();

    /**
     * Get the timestamp from the expiration time
     */
    int getExpiresTimestamp() ;

    /**
     * Builds the expiration value part of the header string
     */
    string getFormattedExpires();

    /**
     * Create a cookie with an updated expiration date
     * Params:
     * \IDateTime $dateTime Date time object
     * @return static
     */
    static withExpiry(IDateTime $dateTime);

    /**
     * Create a new cookie that will virtually never expire.
     */
    static withNeverExpire();

    /**
     * Create a new cookie that will expire/delete the cookie from the browser.
     *
     * This is done by setting the expiration time to 1 year ago
     *
     * @return static
     */
    auto withExpired(): static;

    /**
     * Check if a cookie is expired when compared to $time
     *
     * Cookies without an expiration date always return false.
     * Params:
     * \IDateTime|null $time The time to test against. Defaults to 'now' in UTC.
     */
    bool isExpired(?IDateTime $time = null);

    /**
     * Check if the cookie is HTTP only
     */
    bool isHttpOnly();

    /**
     * Create a cookie with HTTP Only updated
     * Params:
     * bool $httpOnly HTTP Only
     */
    static withHttpOnly(bool $httpOnly);

    /**
     * Check if the cookie is secure
     */
    bool isSecure();

    /**
     * Create a cookie with Secure updated
     * Params:
     * bool $secure Secure attribute value
     */
    static withSecure(bool $secure);

    /**
     * Get the SameSite attribute.
     */
    SameSiteEnum getSameSite();

    /**
     * Create a cookie with an updated SameSite option.
     * Params:
     * \UIM\Http\Cookie\SameSiteEnum|string|null $sameSite Value for to set for Samesite option.
     */
    static withSameSite(SameSiteEnum|string|null $sameSite);

    /**
     * Get cookie options
     */
    IData[string] getOptions();

    /**
     * Get cookie data as array.
     */
    IData[string] toArray();

    /**
     * Returns the cookie as header value
     */
    string toHeaderValue();
}
