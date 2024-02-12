module uim.cake.http;

import uim.cake;

@safe:

/**
 * Factory class for creating response instances.
 */
class ResponseFactory : IResponseFactory {
    /**
     * Create a new response.
     * Params:
     * int httpStatusCode The HTTP status code. Defaults to 200.
     * @param string areasonPhrase The reason phrase to associate with the status code
     *  in the generated response. If none is provided, implementations MAY use
     *  the defaults as suggested in the HTTP specification.
     */
    IResponse createResponse(int httpStatusCode = 200, string areasonPhrase = "") {
        return (new Response()).withStatus(httpStatusCode, reasonPhrase);
    }
}
