module uim.cake.http\Client;

import uim.cake;

@safe:

/**
 * : methods for HTTP responses.
 *
 * All the following examples assume that `response` is an
 * instance of this class.
 *
 * ### Get header values
 *
 * Header names are case-insensitive, but normalized to Title-Case
 * when the response is parsed.
 *
 * ```
 * val = response.getHeaderLine("content-type");
 * ```
 *
 * Will read the Content-Type header. You can get all set
 * headers using:
 *
 * ```
 * response.getHeaders();
 * ```
 *
 * ### Get the response body
 *
 * You can access the response body stream using:
 *
 * ```
 * content = response.getBody();
 * ```
 *
 * You can get the body string using:
 *
 * ```
 * content = response.getStringBody();
 * ```
 *
 * If your response body is in XML or JSON you can use
 * special content type specific accessors to read the decoded data.
 * JSON data will be returned as arrays, while XML data will be returned
 * as SimpleXML nodes:
 *
 * ```
 * // Get as XML
 * content = response.getXml()
 * // Get as JSON
 * content = response.getJson()
 * ```
 *
 * If the response cannot be decoded, null will be returned.
 *
 * ### Check the status code
 *
 * You can access the response status code using:
 *
 * ```
 * content = response.statusCode();
 * ```
 */
class Response : Message : IResponse {
    use MessageTemplate();

    /**
     * The status code of the response.
     */
    protected int code = 0;

    /**
     * Cookie Collection instance
     *
     * @var \UIM\Http\Cookie\CookieCollection|null
     */
    protected CookieCollection cookies = null;

    /**
     * The reason phrase for the status code
     */
    protected string areasonPhrase;

    /**
     * Cached decoded XML data.
     *
     * @var \SimpleXMLElement|null
     */
    protected SimpleXMLElement _xml = null;

    /**
     * Cached decoded JSON data.
     *
     * @var mixed
     */
    protected Json _json = null;

    /**
     * Constructor
     *
     * string[] unparsedHeaders Unparsed headers.
     * @param string abody The response body.
     */
    this(string[] unparsedHeaders = [], string abody= null) {
       _parseHeaders(unparsedHeaders);
        if (this.getHeaderLine("Content-Encoding") == "gzip") {
            body = _decodeGzipBody($body);
        }
        stream = new Stream("php://memory", "wb+");
        stream.write($body);
        stream.rewind();
        this.stream = stream;
    }
    
    /**
     * Uncompress a gzip response.
     *
     * Looks for gzip signatures, and if gzinflate() exists,
     * the body will be decompressed.
     * Params:
     * string abody Gzip encoded body.
     */
    protected string _decodeGzipBody(string encodedBody) {
        if (!function_exists("gzinflate")) {
            throw new UimException("Cannot decompress gzip response body without gzinflate()");
        }
        
        auto anOffset = 0;
        // Look for gzip `signature'
        if (str_starts_with(encodedBody, "\x1f\x8b")) {
             anOffset = 2;
        }
        // Check the format byte
        if (substr(encodedBody,  anOffset, 1) == "\x08") {
            return (string)gzinflate(substr(encodedBody,  anOffset + 8));
        }
        throw new UimException("Invalid gzip response");
    }
    
    /**
     * Parses headers if necessary.
     *
     * - Decodes the status code and reasonphrase.
     * - Parses and normalizes header names + values.
     *
     * string[] headersToParse Headers to parse.
     */
    protected void _parseHeaders(string[] headersToParse) {
        foreach (headersToParse as aValue) {
            if (str_starts_with(aValue, "HTTP/")) {
                preg_match("/HTTP\/([\d.]+) ([0-9]+)(.*)/i", aValue, matches);
                this.protocol = matches[1];
                this.code = to!int($matches[2]);
                this.reasonPhrase = trim($matches[3]);
                continue;
            }
            if (!aValue.has(":")) {
                continue;
            }
            [$name, aValue] = split(":", aValue, 2);
            aValue = trim(aValue);
            /** @phpstan-var non-empty-string aName */
            name = trim($name);

            normalized = name.toLower;

            if (isSet(this.headers[$name])) {
                this.headers[$name] ~= aValue;
            } else {
                this.headers[$name] = (array)aValue;
                this.headerNames[$normalized] = name;
            }
        }
    }
    
    /**
     * Check if the response status code was in the 2xx/3xx range
     */
    bool isOk() {
        return this.code >= 200 && this.code <= 399;
    }
    
    /**
     * Check if the response status code was in the 2xx range
     */
    bool isSuccess() {
        return this.code >= 200 && this.code <= 299;
    }
    
    /**
     * Check if the response had a redirect status code.
     */
    bool isRedirect() {
        codes = [
            STATUS_MOVED_PERMANENTLY,
            STATUS_FOUND,
            STATUS_SEE_OTHER,
            STATUS_TEMPORARY_REDIRECT,
            STATUS_PERMANENT_REDIRECT,
        ];

        return in_array(this.code, codes, true) &&
            this.getHeaderLine("Location");
    }
    
    @property int statusCode() {
        return this.code;
    }
    
    /**
 Params:
     * int code The status code to set.
     * @param string areasonPhrase The status reason phrase.
     */
    static withStatus(int code, string areasonPhrase= null) {
        new = clone this;
        new.code = code;
        new.reasonPhrase = reasonPhrase;

        return new;
    }
    
    string getReasonPhrase() {
        return this.reasonPhrase;
    }
    
    /**
     * Get the encoding if it was set.
     */
    string getEncoding() {
        content = this.getHeaderLine("content-type");
        if (!$content) {
            return null;
        }
        preg_match("/charset\s?=\s?[\']?([a-z0-9-_]+)[\']?/i", content, matches);
        if (isEmpty($matches[1])) {
            return null;
        }
        return matches[1];
    }
    
    /**
     * Get the all cookie data.
     *
     * @return array The cookie data
     */
    array getCookies() {
        return _getCookies();
    }
    
    /**
     * Get the cookie collection from this response.
     *
     * This method exposes the response`s CookieCollection
     * instance allowing you to interact with cookie objects directly.
     */
    CookieCollection getCookieCollection() {
        return this.buildCookieCollection();
    }
    
    /**
     * Get the value of a single cookie.
     * Params:
     * string aName The name of the cookie value.
     */
    string[] getCookie(string aName) {
        cookies = this.buildCookieCollection();

        if (!$cookies.has($name)) {
            return null;
        }
        return cookies.get($name).getValue();
    }
    
    /**
     * Get the full data for a single cookie.
     * Params:
     * string aName The name of the cookie value.
     */
    array getCookieData(string valueName) {
        cookies = this.buildCookieCollection();

        if (!$cookies.has(valueName)) {
            return null;
        }
        return cookies.get(valueName).toArray();
    }
    
    /**
     * Lazily build the CookieCollection and cookie objects from the response header
     */
    protected CookieCollection buildCookieCollection() {
        this.cookies ??= CookieCollection.createFromHeader(this.getHeader("Set-Cookie"));

        return this.cookies;
    }
    
    // Property accessor for `this.cookies`
    protected array _getCookies() {
        auto result;
        this.buildCookieCollection.each!(cookie => result[cookie.name] = cookie.toArray());
        return result;
    }
    
    // Get the response body as string.
    string getStringBody() {
        return _getBody();
    }
    
    // Get the response body as JSON decoded data.
    Json getJson() {
        return _getJson();
    }
    
    // Get the response body as JSON decoded data.
    protected Json _getJson() {
        if (_json) {
            return _json;
        }
        return _json = json_decode(_getBody(), true);
    }
    
    // Get the response body as XML decoded data.
    SimpleXMLElement getXml() {
        return _getXml();
    }
    
    // Get the response body as XML decoded data.
    protected SimpleXMLElement _getXml() {
        if (_xml !isNull) {
            return _xml;
        }
        libxml_use_internal_errors();
        someData = simplexml_load_string(_getBody());
        if (!someData) {
            return null;
        }

       _xml = someData;
        return _xml;
    }
    
    /**
     * Provides magic __get() support.
     */
    protected string[] _getHeaders() {
         auto result;
        foreach (this.headers as aKey:  someValues) {
             result[aKey] = join(",",  someValues);
        }
        return result;
    }
    
    // Provides magic __get() support.
    protected string _getBody() {
        this.stream.rewind();

        return this.stream.getContents();
    }
}
