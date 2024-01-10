module uim.consoles.interfaces.commandcollectionaware;

import uim.cake;

@safe:

// An interface for shells that take a CommandCollection during initialization.
interface ICommandCollectionAware {
    // Set the command collection being used.
    void setCommandCollection(CommandCollection commands);
}
