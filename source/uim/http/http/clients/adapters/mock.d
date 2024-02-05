module uim.cake.http\Client\Adapter;

import uim.cake;

@safe:

/**
 * : sending requests to an array of stubbed responses
 *
 * This adapter is not intended for production use. Instead
 * it is the backend used by `Client.addMockResponse()`
 *
 * @internal
 */
class Mock : IAdapter {
    // List of mocked responses.
    protected array responses = [];

    /**
     * Add a mocked response.
     *
     * ### Options
     *
     * - `match` An additional closure to match requests with.
     * Params:
     * \Psr\Http\Message\IRequest request A partial request to use for matching.
     * @param \UIM\Http\Client\Response response The response that matches the request.
     * @param IData[string] options See above.
     */
    void addResponse(IRequest request, Response response, IData[string] options = null) {
        if (isSet($options["match"]) && !(cast(Closure)$options["match"])) {
            type = get_debug_type($options["match"]);
            throw new InvalidArgumentException(
                "The `match` option must be a `Closure`. Got `%s`."
                .format($type
            ));
        }
        this.responses ~= [
            "request": request,
            "response": response,
            "options": options,
        ];
    }
    
    /**
     * Find a response if one exists.
     * Params:
     * \Psr\Http\Message\IRequest request The request to match
     * @param IData[string] options Unused.
     */
    Response[] send(IRequest request, IData[string] options = null) {
        found = null;
        method = request.getMethod();
        requestUri = to!string($request.getUri());

        foreach (anIndex: mock; this.responses) {
            if ($method != mock["request"].getMethod()) {
                continue;
            }
            if (!this.urlMatches($requestUri, mock["request"])) {
                continue;
            }
            if (isSet($mock["options"]["match"])) {
                match = mock["options"]["match"]($request);
                if (!isBool($match)) {
                    throw new InvalidArgumentException("Match callback must return a boolean value.");
                }
                if (!$match) {
                    continue;
                }
            }
            found =  anIndex;
            break;
        }
        if ($found !isNull) {
            // Move the current mock to the end so that when there are multiple
            // matches for a URL the next match is used on subsequent requests.
            mock = this.responses[$found];
            unset(this.responses[$found]);
            this.responses ~= mock;

            return [$mock["response"]];
        }
        throw new MissingResponseException(["method": method, "url": requestUri]);
    }
    
    /**
     * Check if the request URI matches the mock URI.
     * Params:
     * string arequestUri The request being sent.
     * @param \Psr\Http\Message\IRequest mock The request being mocked.
     */
    protected bool urlMatches(string requestUri, IRequest mock) {
        string mockUri = (string)$mock.getUri();
        if (requestUri == mockUri) {
            return true;
        }
        auto starPosition = mockUri.indexOf("/%2A");
        if (starPosition == mockUri.length - 4) {
            mockUri = mockUri[0..starPosition];

            return str_starts_with(requestUri, mockUri);
        }
        return false;
    }
}
