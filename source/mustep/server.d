/**
 * Main Server class
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.server;

import vibe.http.router, vibe.http.server;
import vibe.stream.tls;

import mustep.config_instance;
import mustep.config;

/** 
 * Class for the server's manage
 * It starts, inits the server
 * and handle errors
 */
class MuStepServer
{
    private HTTPServerSettings serverSettings;

    public this() @trusted
    {
        MuStepConfig config = SharedConfig.get().configInstance.cfg;

        serverSettings = new HTTPServerSettings();

        serverSettings.sessionStore = new MemorySessionStore();
        serverSettings.port = cast(ushort)config.port;

        if (config.pkey.length && config.cert.length) {
            serverSettings.tlsContext = createTLSContext(TLSContextKind.server);
            
            serverSettings.tlsContext.useCertificateChainFile(config.cert);
            serverSettings.tlsContext.usePrivateKeyFile(config.pkey);
        }
    }
}
