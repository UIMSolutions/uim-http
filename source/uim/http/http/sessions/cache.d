module uim.cake.http.sessions.cache;

import uim.cake;

@safe:

/**use InvalidArgumentException;
use !SessionHandler;
/**
 * CacheSession provides method for saving sessions into a Cache engine. Used with Session
 *
 * @see \UIM\Http\Session for configuration information.
 */
class CacheSession : !SessionHandler {
    // Options for this session engine
    protected IData[string] _options = [];

    /**
     * Constructor.
     * Params:
     * IData[string] configData The configuration to use for this engine
     * It requires the key 'config' which is the name of the Cache config to use for
     * storing the session
     * @throws \InvalidArgumentException if the 'config' key is not provided
     */
    this(IData[string] configData = null) {
        if (isEmpty(configData("config"])) {
            throw new InvalidArgumentException("The cache configuration name to use is required");
        }
       _options = configData;
    }
    
    /**
     * Method called on open of a database session.
     * Params:
     * string aPath The path where to store/retrieve the session.
     * @param string aName The session name.
         */
    bool open(string aPath, string aName) {
        return true;
    }
    
    /**
     * Method called on close of a database session.
     *
         */
    bool close() {
        return true;
    }
    
    /**
     * Method used to read from a cache session.
     * Params:
     * string aid ID that uniquely identifies session in cache.
     */
    string read(string aid) {
        return Cache.read(anId, _options["config"]) ?? "";
    }
    
    /**
     * Helper auto called on write for cache sessions.
     * Params:
     * string aid ID that uniquely identifies session in cache.
     * @param string adata The data to be saved.
     */
    bool write(string aid, string adata) {
        if (!anId) {
            return false;
        }
        return Cache.write(anId, someData, _options["config"]);
    }
    
    /**
     * Method called on the destruction of a cache session.
     * Params:
     * string aid ID that uniquely identifies session in cache.
     */
    bool destroy(string aid) {
        Cache.delete(anId, _options["config"]);

        return true;
    }
    
    /**
     * No-op method. Always returns 0 since cache engine don`t have garbage collection.
     * Params:
     * int maxlifetime Sessions that have not updated for the last maxlifetime seconds will be removed.
     */
    int gc(int maxlifetime) {
        return 0;
    }
}
