module uim.cake.http\Client\Adapter;

import uim.cake;

@safe:

/**
 * : sending UIM\Http\Client\Request via ext/curl.
 *
 * In addition to the standard options documented in {@link \UIM\Http\Client},
 * this adapter supports all available curl options. Additional curl options
 * can be set via the `curl` option key when making requests or configuring
 * a client.
 */
class Curl : IAdapter {
 
    array send(IRequest request, IData[string] options = null) {
        if (!extension_loaded("curl")) {
            throw new ClientException("curl extension is not loaded.");
        }
        ch = curl_initialize();
        options = this.buildOptions($request, options);
        curl_setopt_array($ch, options);

        body = this.exec($ch);
        assert($body != true);
        if ($body == false) {
            errorCode = curl_errno($ch);
            error = curl_error($ch);
            curl_close($ch);

            string message = "cURL Error ({$errorCode}) {$error}";
            errorNumbers = [
                CURLE_FAILED_INIT,
                CURLE_URL_MALFORMAT,
                CURLE_URL_MALFORMAT_USER,
            ];
            if (in_array($errorCode, errorNumbers, true)) {
                throw new RequestException(message, request);
            }
            throw new NetworkException(message, request);
        }
        responses = this.createResponse($ch, body);
        curl_close($ch);

        return responses;
    }
    
    /**
     * Convert client options into curl options.
     * Params:
     * \Psr\Http\Message\IRequest request The request.
     * @param IData[string] options The client options
     */
    array buildOptions(IRequest request, IData[string] options = null) {
        string[] aHeaders = request.getHeaders().byKeyValue
            .map!(keyValues => aKey ~ ": " ~ someValues.join(", ")).array;

         result = [
            CURLOPT_URL: (string)$request.getUri(),
            CURLOPT_HTTP_VERSION: this.getProtocolVersion($request),
            CURLOPT_RETURNTRANSFER: true,
            CURLOPT_HEADER: true,
            CURLOPT_HTTPHEADER:  aHeaders,
        ];
        switch ($request.getMethod()) {
            case Request.METHOD_GET:
                 result[CURLOPT_HTTPGET] = true;
                break;

            case Request.METHOD_POST:
                 result[CURLOPT_POST] = true;
                break;

            case Request.METHOD_HEAD:
                 result[CURLOPT_NOBODY] = true;
                break;

            default:
                 result[CURLOPT_POST] = true;
                 result[CURLOPT_CUSTOMREQUEST] = request.getMethod();
                break;
        }
        body = request.getBody();
        body.rewind();
         result[CURLOPT_POSTFIELDS] = body.getContents();
        // GET requests with bodies require custom request to be used.
        if (result[CURLOPT_POSTFIELDS] != "" && isSet(result[CURLOPT_HTTPGET])) {
             result[CURLOPT_CUSTOMREQUEST] = "get";
        }
        if (result[CURLOPT_POSTFIELDS].isEmpty) {
            unset(result[CURLOPT_POSTFIELDS]);
        }
        if (isEmpty($options["ssl_cafile"])) {
            options["ssl_cafile"] = CaBundle.getBundledCaBundlePath();
        }
        if (!empty($options["ssl_verify_host"])) {
            // Value of 1 or true is deprecated. Only 2 or 0 should be used now.
            options["ssl_verify_host"] = 2;
        }
        optionMap = [
            "timeout": CURLOPT_TIMEOUT,
            "ssl_verify_peer": CURLOPT_SSL_VERIFYPEER,
            "ssl_verify_host": CURLOPT_SSL_VERIFYHOST,
            "ssl_cafile": CURLOPT_CAINFO,
            "ssl_local_cert": CURLOPT_SSLCERT,
            "ssl_passphrase": CURLOPT_SSLCERTPASSWD,
        ];
        
        optionMap.byKeyValue
            .filter!(optionCurlOpt => options.isSet(optionCurlOpt.key))
            .each!(optionCurlOpt => result[optionCurlOpt.value] = options[optionCurlOpt.key]);
            
        if (isSet($options["proxy"]["proxy"])) {
             result[CURLOPT_PROXY] = options["proxy"]["proxy"];
        }
        if (isSet($options["proxy"]["username"])) {
            password = !empty($options["proxy"]["password"]) ? options["proxy"]["password"] : "";
             result[CURLOPT_PROXYUSERPWD] = options["proxy"]["username"] ~ ":" ~ password;
        }
        if (isSet($options["curl"]) && isArray($options["curl"])) {
            // Can`t use array_merge() because keys will be re-ordered.
            options["curl"].byKeyValue
                .each!(kv => result[kv.key] = kv.value);

        }
        return result;
    }
    
    /**
     * Convert HTTP version number into curl value.
     * Params:
     * \Psr\Http\Message\IRequest request The request to get a protocol version for.
     */
    protected int getProtocolVersion(IRequest request) {
        return match ($request.getProtocolVersion()) {
            "1.0": CURL_HTTP_VERSION_1_0,
            "1.1": CURL_HTTP_VERSION_1_1,
            "2", "2.0": defined("CURL_HTTP_VERSION_2TLS")
                ? CURL_HTTP_VERSION_2TLS
                : (defined("CURL_HTTP_VERSION_2_0")
                    ? CURL_HTTP_VERSION_2_0
                    : throw new HttpException("libcurl 7.33 or greater required for HTTP/2 support")
                ),
            default: CURL_HTTP_VERSION_NONE,
        };
    }
    
    /**
     * Convert the raw curl response into an Http\Client\Response
     * Params:
     * \CurlHandle handle Curl handle
     * @param string aresponseData string The response data from curl_exec
     */
    protected REsponse[] createResponse(CurlHandle handle, string aresponseData) {
         aHeaderSize = curl_getinfo($handle, CURLINFO_HEADER_SIZE);
         aHeaders = trim(substr($responseData, 0,  aHeaderSize));
        body = substr($responseData,  aHeaderSize);
        response = new Response(split("\r\n",  aHeaders), body);

        return [response];
    }
    
    /**
     * Execute the curl handle.
     * Params:
     * \CurlHandle ch Curl Resource handle
     */
    protected string exec(CurlHandle ch) {
        return curl_exec($ch);
    }
}
