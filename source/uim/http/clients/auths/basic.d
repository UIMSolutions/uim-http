module uim.http.clients\Auth;

@safe:
import uim.cake;

/**
 * Basic authentication adapter for Cake\Http\Client
 *
 * Generally not directly constructed, but instead used by {@link uim.http\Client}
 * when $options["auth"]["type"] is "basic"
 */
class Basic
{
    /**
     * Add Authorization header to the request.
     *
     * @param DHTPRequest $request Request instance.
     * @param array $credentials Credentials.
     * returns DHTPRequest The updated request.
     * @see https://www.ietf.org/rfc/rfc2617.txt
     */
    function authentication(DHTPRequest aRequest, array $credentials): Request
    {
        if (isset($credentials["username"], $credentials["password"])) {
            $value = _generateHeader($credentials["username"], $credentials["password"]);
            /** var DHTPClient\Request $request */
            $request = $request.withHeader("Authorization", $value);
        }

        return $request;
    }

    /**
     * Proxy Authentication
     *
     * @param DHTPRequest $request Request instance.
     * @param array $credentials Credentials.
     * returns DHTPRequest The updated request.
     * @see https://www.ietf.org/rfc/rfc2617.txt
     */
    function proxyAuthentication(DHTPRequest aRequest, array $credentials): Request
    {
        if (isset($credentials["username"], $credentials["password"])) {
            $value = _generateHeader($credentials["username"], $credentials["password"]);
            /** var DHTPClient\Request $request */
            $request = $request.withHeader("Proxy-Authorization", $value);
        }

        return $request;
    }

    /**
     * Generate basic [proxy] authentication header
     *
     * @param string $user Username.
     * @param string $pass Password.
     */
    protected string _generateHeader(string $user, string $pass) {
        return "Basic " ~ base64_encode($user ~ ":" ~ $pass);
    }
}
