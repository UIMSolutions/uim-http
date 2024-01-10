module uim.cake.http;

import uim.cake;

@safe:

/**
 * Emits a Response to the PHP Server API.
 */
class ResponseEmitter {
    /**
     * Maximum output buffering size for each iteration.
     */
    protected int $maxBufferLength;

    /**
     * Constructor
     * Params:
     * int $maxBufferLength Maximum output buffering size for each iteration.
     */
    this(int $maxBufferLength = 8192) {
        this.maxBufferLength = $maxBufferLength;
    }
    
    /**
     * Emit a response.
     *
     * Emits a response, including status line, headers, and the message body,
     * according to the environment.
     * Params:
     * \Psr\Http\Message\IResponse $response The response to emit.
     */
   bool emit(IResponse $response) {
        $file = "";
        $line = 0;
        if (headers_sent($file, $line)) {
            $message = "Unable to emit headers. Headers sent in file=$file line=$line";
            trigger_error($message, E_USER_WARNING);
        }
        this.emitStatusLine($response);
        this.emitHeaders($response);
        this.flush();

        $range = this.parseContentRange($response.getHeaderLine("Content-Range"));
        if (isArray($range)) {
            this.emitBodyRange($range, $response);
        } else {
            this.emitBody($response);
        }
        if (function_exists("fastcgi_finish_request")) {
            fastcgi_finish_request();
        }
        return true;
    }
    
    /**
     * Emit the message body.
     * Params:
     * \Psr\Http\Message\IResponse $response The response to emit
     */
    protected void emitBody(IResponse $response) {
        if (in_array($response.statusCode(), [204, 304], true)) {
            return;
        }
        $body = $response.getBody();

        if (!$body.isSeekable()) {
            echo $body;

            return;
        }
        $body.rewind();
        while (!$body.eof()) {
            echo $body.read(this.maxBufferLength);
        }
    }
    
    /**
     * Emit a range of the message body.
     * Params:
     * array $range The range data to emit
     * @param \Psr\Http\Message\IResponse $response The response to emit
     */
    protected void emitBodyRange(array $range, IResponse $response) {
        [, $first, $last] = $range;

        $body = $response.getBody();

        if (!$body.isSeekable()) {
            $contents = $body.getContents();
            echo substr($contents, $first, $last - $first + 1);

            return;
        }
        $body = new RelativeStream($body, $first);
        $body.rewind();
        $pos = 0;
        /** @var size_t aLength */
        $length = $last - $first + 1;
        while (!$body.eof() && $pos < $length) {
            if ($pos + this.maxBufferLength > $length) {
                echo $body.read($length - $pos);
                break;
            }
            echo $body.read(this.maxBufferLength);
            $pos = $body.tell();
        }
    }
    
    /**
     * Emit the status line.
     *
     * Emits the status line using the protocol version and status code from
     * the response; if a reason phrase is available, it, too, is emitted.
     * Params:
     * \Psr\Http\Message\IResponse $response The response to emit
     */
    protected void emitStatusLine(IResponse $response) {
        $reasonPhrase = $response.getReasonPhrase();
        header("HTTP/%s %d%s"
            .format($response.getProtocolVersion(),
            $response.statusCode(),
            ($reasonPhrase ? " " ~ $reasonPhrase : "")
        ));
    }
    
    /**
     * Emit response headers.
     *
     * Loops through each header, emitting each; if the header value
     * is an array with multiple values, ensures that each is sent
     * in such a way as to create aggregate headers (instead of replace
     * the previous).
     * Params:
     * \Psr\Http\Message\IResponse $response The response to emit
     */
    protected void emitHeaders(IResponse $response) {
        auto $cookies = [];
        if (cast(Response)$response) {
            $cookies = iterator_to_array($response.getCookieCollection());
        }
        foreach ($name:  someValues; $response.getHeaders()) {
            if ($name.toLower == "Set-cookie") {
                $cookies = array_merge($cookies,  someValues);
                continue;
            }
            $first = true;
            foreach (aValue; someValues) {
                header(
                    "%s: %s".format(
                    $name,
                    aValue
                ), $first);
                $first = false;
            }
        }
        this.emitCookies($cookies);
    }
    
    /**
     * Emit cookies using setcookie()
     * Params:
     * array<\UIM\Http\Cookie\ICookie|string> $cookies An array of cookies.
     */
    protected void emitCookies(array $cookies) {
        foreach ($cookie; $cookies) {
            this.setCookie($cookie);
        }
    }
    
    /**
     * Helper methods to set cookie.
     * Params:
     * \UIM\Http\Cookie\ICookie|string acookie Cookie.
     */
    protected bool setCookie(ICookie|string acookie) {
        if (isString($cookie)) {
            $cookie = Cookie.createFromHeaderString($cookie, ["path": ""]);
        }
        return setcookie($cookie.name, $cookie.getScalarValue(), $cookie.getOptions());
    }
    
    /**
     * Loops through the output buffer, flushing each, before emitting
     * the response.
     * Params:
     * int $maxBufferLevel Flush up to this buffer level.
     */
    protected void flush(int $maxBufferLevel = null) {
        $maxBufferLevel ??= ob_get_level();

        while (ob_get_level() > $maxBufferLevel) {
            ob_end_flush();
        }
    }
    
    /**
     * Parse content-range header
     * https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.16
     * Params:
     * string aheader The Content-Range header to parse.
     */
    protected array|false parseContentRange(string aheader) {
        if (preg_match("/(?P<unit>[\w]+)\s+(?P<first>\d+)-(?P<last>\d+)\/(?P<length>\d+|\*)/",  aHeader, $matches)) {
            return [
                $matches["unit"],
                (int)$matches["first"],
                (int)$matches["last"],
                $matches["length"] == "*' ? "*' : (int)$matches["length"],
            ];
        }
        return false;
    }
}
