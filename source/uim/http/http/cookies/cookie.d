module uim.cake.http\Cookie;

import uim.cake;

@safe:

/**
 * Cookie object to build a cookie and turn it into a header value
 *
 * An HTTP cookie (also called web cookie, Internet cookie, browser cookie or
 * simply cookie) is a small piece of data sent from a website and stored on
 * the user`s computer by the user`s web browser while the user is browsing.
 *
 * Cookies were designed to be a reliable mechanism for websites to remember
 * stateful information (such as items added in the shopping cart in an online
 * store) or to record the user`s browsing activity (including clicking
 * particular buttons, logging in, or recording which pages were visited in
 * the past). They can also be used to remember arbitrary pieces of information
 * that the user previously entered into form fields such as names, and preferences.
 *
 * Cookie objects are immutable, and you must re-assign variables when modifying
 * cookie objects:
 *
 * ```
 * cookie = cookie.withValue("0");
 * ```
 *
 * @link https://tools.ietf.org/html/draft-ietf-httpbis-rfc6265bis-03
 * @link https://en.wikipedia.org/wiki/HTTP_cookie
 * @see \UIM\Http\Cookie\CookieCollection for working with collections of cookies.
 * @see \UIM\Http\Response.getCookieCollection() for working with response cookies.
 */
class Cookie : ICookie {
    // Cookie name
    protected string _name = "";

    // Raw Cookie value.
    protected string[] avalue = "";

    // Whether a JSON value has been expanded into an array.
    protected bool  isExpanded = false;

    // Expiration time
    protected IDateTime expiresAt = null;

    protected string aPath = "/";

    protected string adomain = "";

    protected bool secure = false;

    protected bool isHttpOnly = false;

    // Samesite
    protected SameSiteEnum sameSite = null;

    // Default attributes for a cookie.
    protected static @var IData[string] defaultAttributes = [
        "expires": Json(null),
        "path": Json("/"),
        "domain": Json(""),
        "secure": Json(false),
        "httponly": Json(false),
        "samesite": Json(null),
    ];

    /**
     * Constructor
     *
     * The constructors args are similar to the native PHP `setcookie()` method.
     * The only difference is the 3rd argument which excepts null or an
     * DateTime or DateTimeImmutable object instead an integer.
     *
     * @link https://php.net/manual/en/function.setcookie.d
     * @param string cookieName Cookie name
     * @param string[]|float|int|bool aValue Value of the cookie
     * @param \IDateTime|null expiresAt Expiration time and date
     * @param string somePath Path
     * @param string domain Domain
     * @param bool|null secure Is secure
     * @param bool|null isHttpOnly HTTP Only
     * @param \UIM\Http\Cookie\SameSiteEnum|string sameSite Samesite
     */
    this(
        string cookieName,
        string[]|float|int|bool aValue = "",
        ?IDateTime expiresAt = null,
        string aPath = null,
        string adomain = null,
        ?bool secure = null,
        ?bool isHttpOnly = null,
        SameSiteEnum|string sameSite = null
    ) {
        this.validateName($name);
        this.name = name;

       _setValue(aValue);

        this.domain = domain ?? defaultAttributes["domain"];
        this.httpOnly = isHttpOnly ?? defaultAttributes["httponly"];
        this.path = somePath ?? defaultAttributes["path"];
        this.secure = secure ?? defaultAttributes["secure"];
        this.sameSite = resolveSameSiteEnum($sameSite ?? defaultAttributes["samesite"]);

        if ($expiresAt) {
            if (cast(DateTime)$expiresAt) {
                expiresAt = clone expiresAt;
            }
            /** @var \DateTimeImmutable|\DateTime expiresAt */
            expiresAt = expiresAt.setTimezone(new DateTimeZone("GMT"));
        } else {
            expiresAt = defaultAttributes["expires"];
        }
        this.expiresAt = expiresAt;
    }
    
    /**
     * Set default options for the cookies.
     *
     * Valid option keys are:
     *
     * - `expires`: Can be a UNIX timestamp or `strtotime()` compatible string or `IDateTime` instance or `null`.
     * - `path`: A path string. Defauts to `'/'`.
     * - `domain`: Domain name string. Defaults to `""`.
     * - `httponly`: Boolean. Defaults to `false`.
     * - `secure`: Boolean. Defaults to `false`.
     * - `samesite`: Can be one of `ICookie.SAMESITE_LAX`, `ICookie.SAMESITE_STRICT`,
     *   `ICookie.SAMESITE_NONE` or `null`. Defaults to `null`.
     * Params:
     * IData[string] options Default options.
     */
    static void setDefaults(IData[string] options = null) {
        auto myOptions = options.copy;

        if (isSet($options["expires"])) {
            options["expires"] = dateTimeInstance(options["expires"]);
        }
        if (isSet($options["samesite"])) {
            options["samesite"] = resolveSameSiteEnum(options["samesite"]);
        }
        defaultAttributes = options.update(defaultAttributes);
    }
    
    /**
     * Factory method to create Cookie instances.
     * Params:
     * string cookieName Cookie name
     * @param string[]|float|int|bool aValue Value of the cookie
     * @param IData[string] options Cookies options.
     */
    static static create(string cookieName, string[]|float|int|bool aValue, IData[string] options = null) {
        auto myOptions += options.update(defaultAttributes);
        options["expires"] = dateTimeInstance($options["expires"]);

        return new static(
            name,
            aValue,
            options["expires"],
            options["path"],
            options["domain"],
            options["secure"],
            options["httponly"],
            options["samesite"]
        );
    }
    
    /**
     * Converts non null expiry value into IDateTime instance.
     * Params:
     * \IDateTime|string|int expires Expiry value.
     */
    protected static IDateTime dateTimeInstance(IDateTime|string|int expires) {
        if ($expires.isNull) {
            return null;
        }
        if (cast8IDateTime)$expires) {
            return expires.setTimezone(new DateTimeZone("GMT"));
        }
        if (!isNumeric($expires)) {
            expires = strtotime($expires) ?: null;
        }
        if ($expires !isNull) {
            expires = new DateTimeImmutable("@" ~ (string)$expires);
        }
        return expires;
    }
    
    /**
     * Create Cookie instance from "set-cookie" header string.
     * Params:
     * string acookie Cookie header string.
     * @param  defaultAttributes Default attributes.
     */
    static static createFromHeaderString(string cookieHeader, IData[string] defaultAttributes = []) {
        string[] someParts;
        if (cookieHeader.has(";")) {
            cookieHeader = cookieHeader.replace("";"", "{__cookie_replace__}");
            someParts = split(";", cookieHeader).replace("{__cookie_replace__}", "";"");
        } else {
            someParts = preg_split("/\;[\t]*/", cookieHeader) ?: [];
        }
        nameValue = split("=", (string)array_shift(someParts), 2);
        name = array_shift($nameValue);
        aValue = array_shift($nameValue) ?? "";

        someData = [
                "name": urldecode($name),
                "value": urldecode(aValue),
            ] + defaultAttributes;

        someParts.each!((part) {
            if (part.has("=")) {
                [aKey, aValue] = split("=", part);
            } else {
                aKey = part;
                aValue = true;
            }
            aKey = aKey.toLower;
            someData[aKey] = aValue;
        });
        if (someData.isSet("max-age")) {
            someData["expires"] = time() + (int)someData["max-age"];
            unset(someData["max-age"]);
        }
        // Ignore invalid value when parsing headers
        // https://tools.ietf.org/html/draft-west-first-party-cookies-07#section-4.1
        if (isSet(someData["samesite"])) {
            try {
                someData["samesite"] = resolveSameSiteEnum(someData["samesite"]);
            } catch (ValueError) {
                unset(someData["samesite"]);
            }
        }
        name = someData["name"];
        aValue = someData["value"];
        assert(isString($name) && isString(aValue));
        unset(someData["name"], someData["value"]);

        return Cookie.create(
            name,
            aValue,
            someData
        );
    }
    
    /**
     * Returns a header value as string
     */
    string toHeaderValue() {
        aValue = this.value;
        if (this.isExpanded) {
            assert(isArray(aValue), "aValue is not an array");

            aValue = _flatten(aValue);
        }
        aHeaderValue = [];
        aHeaderValue ~= "%s=%s".format(this.name, rawurlencode(aValue));

        if (this.expiresAt) {
             aHeaderValue ~= "expires=%s".format(this.getFormattedExpires());
        }
        if (!this.path.isEmpty) {
             aHeaderValue ~= "path=%s".format(this.path);
        }
        if (!this.domain.isEmpty) {
             aHeaderValue ~= "domain=%s".format(this.domain);
        }
        if (this.sameSite) {
             aHeaderValue ~= "samesite=%s".format(this.sameSite.value);
        }
        if (this.secure) {
             aHeaderValue ~= "Secure";
        }
        if (this.httpOnly) {
             aHeaderValue ~= "httponly";
        }
        return join("; ",  aHeaderValue);
    }
 
    static withName(string aName) {
        this.validateName($name);
        new = clone this;
        new.name = name;

        return new;
    }
 
    string getId() {
        return "{this.name};{this.domain};{this.path}";
    }
 
    @property string name() {
        return this.name;
    }
    
    /**
     * Validates the cookie name
     * Params:
     * string cookieName Name of the cookie
     */
    protected void validateName(string cookieName) {
        if (preg_match("/[=,;\t\r\n\013\014]/", name)) {
            throw new InvalidArgumentException(
                "The cookie name `%s` contains invalid characters.".format($name)
            );
        }
        if (isEmpty($name)) {
            throw new InvalidArgumentException("The cookie name cannot be empty.");
        }
    }
 
    auto getValue() {
        return this.value;
    }
 
    string getScalarValue() {
        if (this.isExpanded) {
            assert(isArray(this.value), "aValue is not an array");

            return _flatten(this.value);
        }
        assert(isString(this.value), "aValue is not a string");

        return this.value;
    }
 
    auto withValue(string[]|float|int|bool aValue): static
    {
        new = clone this;
        new._setValue(aValue);

        return new;
    }
    
    /**
     * Setter for the value attribute.
     * Params:
     * string[]|float|int|bool aValue The value to store.
     */
    protected void _setValue(string[]|float|int|bool aValue) {
        this.isExpanded = isArray(aValue);
        this.value = isArray(aValue) ? aValue : (string)aValue;
    }
 
    auto withPath(string aPath): static
    {
        new = clone this;
        new.path = somePath;

        return new;
    }
 
    string getPath() {
        return this.path;
    }
 
    auto withDomain(string adomain): static
    {
        new = clone this;
        new.domain = domain;

        return new;
    }
 
    string getDomain() {
        return this.domain;
    }
 
    bool isSecure() {
        return this.secure;
    }
 
    auto withSecure(bool secure): static
    {
        new = clone this;
        new.secure = secure;

        return new;
    }
 
    auto withHttpOnly(bool isHttpOnly): static
    {
        new = clone this;
        new.httpOnly = isHttpOnly;

        return new;
    }
 
    bool isHttpOnly() {
        return this.httpOnly;
    }
 
    auto withExpiry(IDateTime dateTime): static
    {
        if (cast(DateTime)$dateTime) {
            dateTime = clone dateTime;
        }
        new = clone this;
        new.expiresAt = dateTime.setTimezone(new DateTimeZone("GMT"));

        return new;
    }
 
    auto getExpiry(): IDateTime
    {
        return this.expiresAt;
    }
 
    int getExpiresTimestamp() {
        if (!this.expiresAt) {
            return null;
        }
        return (int)this.expiresAt.format("U");
    }
 
    string getFormattedExpires() {
        if (!this.expiresAt) {
            return "";
        }
        return this.expiresAt.format(EXPIRES_FORMAT);
    }
 
    bool isExpired(?IDateTime time = null) {
        time = time ?: new DateTimeImmutable("now", new DateTimeZone("UTC"));
        if (cast(DateTime)$time) {
            time = clone time;
        }
        if (!this.expiresAt) {
            return false;
        }
        return this.expiresAt < time;
    }
 
    auto withNeverExpire(): static
    {
        new = clone this;
        new.expiresAt = new DateTimeImmutable("2038-01-01");

        return new;
    }
 
    auto withExpired(): static
    {
        new = clone this;
        new.expiresAt = new DateTimeImmutable("@1");

        return new;
    }
 
    SameSiteEnum getSameSite() {
        return this.sameSite;
    }
 
    static withSameSite(SameSiteEnum|string sameSite) {
        new = clone this;
        new.sameSite = resolveSameSiteEnum($sameSite);

        return new;
    }
    
    /**
     * Create SameSiteEnum instance.
     * Params:
     * \UIM\Http\Cookie\SameSiteEnum|string sameSite SameSite value
     */
    protected static SameSiteEnum resolveSameSiteEnum(SameSiteEnum|string sameSite) {
        return match (true) {
            sameSite.isNull: sameSite,
            sameSite instanceof SameSiteEnum: sameSite,
            default: SameSiteEnum.from(ucfirst($sameSite).toLower),
        };
    }
    
    /**
     * Checks if a value exists in the cookie data.
     *
     * This method will expand serialized complex data, on first use.
     */
   bool check(string pathToCheck) {
        if (this.isExpanded == false) {
            assert(isString(this.value), "aValue is not a string");
            this.value = _expand(this.value);
        }
        assert(isArray(this.value), "aValue is not an array");

        return Hash.check(this.value, pathToCheck);
    }
    
    /**
     * Create a new cookie with updated data.
     * Params:
     * string aPath Path to write to
     * @param Json aValue Value to write
     */
    static withAddedValue(string pathToWrite, Json aValue) {
        new = clone this;
        if ($new.isExpanded == false) {
            assert(isString($new.value), "aValue is not a string");
            new.value = new._expand($new.value);
        }
        assert(isArray($new.value), "aValue is not an array");
        new.value = Hash.insert($new.value, pathToWrite, aValue);

        return new;
    }
    
    /**
     * Create a new cookie without a specific path
     * Params:
     * string aPath Path to remove
     */
    static withoutAddedValue(string aPath) {
        new = clone this;
        if ($new.isExpanded == false) {
            assert(isString($new.value), "aValue is not a string");
            new.value = new._expand($new.value);
        }
        assert(isArray($new.value), "aValue is not an array");

        new.value = Hash.remove($new.value, somePath);

        return new;
    }
    
    /**
     * Read data from the cookie
     *
     * This method will expand serialized complex data,
     * on first use.
     * Params:
     * string somePath Path to read the data from
    */
    Json read(string aPath = null) {
        if (this.isExpanded == false) {
            assert(isString(this.value), "aValue is not a string");

            this.value = _expand(this.value);
        }
        if (somePath.isNull) {
            return this.value;
        }
        assert(isArray(this.value), "aValue is not an array");

        return Hash.get(this.value, somePath);
    }
    
    // Checks if the cookie value was expanded
    bool isExpanded() {
        return this.isExpanded;
    }
 
    array getOptions() {
        options = [
            "expires": to!int(this.getExpiresTimestamp()),
            "path": this.path,
            "domain": this.domain,
            "secure": this.secure,
            "httponly": this.httpOnly,
        ];

        if (this.sameSite !isNull) {
            options["samesite"] = this.sameSite.value;
        }
        return options;
    }
    array toArray() {
        return [
            "name": this.name,
            "value": this.getScalarValue(),
        ] + this.getOptions();
    }
    
    /**
     * Implode method to keep keys are multidimensional arrays
     * Params:
     * array array Map of key and values
     */
    protected string _flatten(array array) {
        return json_encode($array, JSON_THROW_ON_ERROR);
    }
    
    /**
     * Explode method to return array from string set in CookieComponent._flatten()
     * Maintains reading backwards compatibility with 1.x CookieComponent._flatten().
     * Params:
     * string astring A string containing JSON encoded data, or a bare string.
     */
    protected string[] _expand(string astring) {
        this.isExpanded = true;
        first = substr($string, 0, 1);
        if ($first == "{" || first == "[") {
            return json_decode($string, true) ?? string;
        }
        array = [];
        foreach (split(",", string) as pair) {
            string[] aKey = split("|", pair);
            if (!isSet(aKey[1])) {
                return aKey[0];
            }
            array[aKey[0]] = aKey[1];
        }
        return array;
    }
}
