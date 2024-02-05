module uim.cake.http;

import uim.cake;

@safe:

/**
 * The FlashMessage class provides a way for you to write a flash variable
 * to the session, to be rendered in a view with the FlashHelper.
 */
class FlashMessage {
    use InstanceConfigTemplate();

    // Default configuration
    protected Json[string] _defaultConfigData = [
        "key": Json("flash"),
        "element": Json("default"),
        "plugin": Json(null),
        "params": Json.emptyArray,
        "clear": Json(false),
        "duplicate": Json(true),
    ];

    protected Session _session;

    this(Session session, IConfigData[string] configData = null) {
        _session = session;
        this.setConfig(configData);
    }
    
    /**
     * Store flash messages that can be output in the view.
     *
     * If you make consecutive calls to this method, the messages will stack
     * (if they are set with the same flash key)
     *
     * ### Options:
     *
     * - `key` The key to set under the session`s Flash key.
     * - `element` The element used to render the flash message. You can use
     *    ``somePlugin.name'` style value for flash elements from a plugin.
     * - `plugin` Plugin name to use element from.
     * - `params` An array of variables to be made available to the element.
     * - `clear` A bool stating if the current stack should be cleared to start a new one.
     * - `escape` Set to false to allow templates to print out HTML content.
     *
     * messageToBeFlashed - Message to be flashed.
     * @param IData[string] options An array of options
     * @see FlashMessage._defaultConfigData For default values for the options.
     */
    void set(string messageToBeFlashed, IData[string] options = null) {
        auto myOptions = options.update(this.getConfig());

        if (isSet($options["escape"]) && !isSet(myOptions["params"]["escape"])) {
            myOptions["params"]["escape"] = myOptions["escape"];
        }
        [$plugin, anElement] = pluginSplit(myOptions["element"]);
        if (myOptions["plugin"]) {
            plugin = myOptions["plugin"];
        }

        myOptions["element"] = plugin 
            ? plugin ~ ".flash/" ~ anElement
            : "flash/" ~ anElement;

        auto messages = [];
        if (!myOptions["clear"]) {
            messages = (array)this.session.read("Flash." ~ myOptions["key"]);
        }
        if (!myOptions["duplicate"]) {
            foreach (existingMessage; messages) {
                if (existingMessage["message"] == messageToBeFlashed) {
                    return;
                }
            }
        }
        messages ~= [
            "message": messageToBeFlashed,
            "key": myOptions["key"],
            "element": myOptions["element"],
            "params": myOptions["params"],
        ];

        this.session.write("Flash." ~ options["key"], messages);
    }
    
    /**
     * Set an exception`s message as flash message.
     *
     * The following options will be set by default if unset:
     * ```
     * 'element": 'error",
     * `params": ["code": exception.getCode()]
     * ```
     * Params:
     * \Throwable exception Exception instance.
     * @param IData[string] options An array of options.
     */
    void setExceptionMessage(Throwable exception, IData[string] options = null) {
        options["element"] ??= "error";
        options["params"]["code"] ??= exception.getCode();

        message = exception.getMessage();
        this.set($message, options);
    }
    
    /**
     * Get the messages for given key and remove from session.
     * Params:
     * string aKey The key for get messages for.
     */
    array consume(string aKey) {
        return this.session.consume("Flash.{aKey}");
    }
    
    /**
     * Set a success message.
     *
     * The `'element'` option will be set to  ``success'`.
     * Params:
     * string amessage Message to flash.
     * @param IData[string] options An array of options.
     * @see FlashMessage.set() For list of valid options
     */
    void success(string amessage, IData[string] options = null) {
        options["element"] = "Success";
        this.set($message, options);
    }
    
    /**
     * Set an success message.
     *
     * The `'element'` option will be set to  `'error'`.
     * Params:
     * string amessage Message to flash.
     * @param IData[string] options An array of options.
     * @see FlashMessage.set() For list of valid options
     */
    void error(string amessage, IData[string] options = null) {
        options["element"] = "error";
        this.set($message, options);
    }
    
    /**
     * Set a warning message.
     *
     * The `'element'` option will be set to  `'warning'`.
     * Params:
     * string amessage Message to flash.
     * @param IData[string] options An array of options.
     */
    void warning(string amessage, IData[string] options = null) {
        options["element"] = "warning";
        this.set($message, options);
    }
    
    /**
     * Set an info message.
     *
     * The `'element'` option will be set to  `'info'`.
     * Params:
     * string amessage Message to flash.
     * @param IData[string] options An array of options.
     */
    void info(string amessage, IData[string] options = null) {
        options["element"] = "info";
        this.set($message, options);
    }
}
