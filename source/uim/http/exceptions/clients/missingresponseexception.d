module source.uim.http.exceptions.clients.missingresponseexception;


/**
 * Used to indicate that a request did not have a matching mock response.
 */
class MissingResponseException : UimException {
    protected string _messageTemplate = "Unable to find a mocked response for `%s` to `%s`.";
}
