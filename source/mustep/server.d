/**
 * Main Server class
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.server;

import vibe.http.router, vibe.http.server;
import vibe.stream.tls;
import vibe.core.core;
import vibe.web.web;
import vibe.vibe : serveStaticFiles;

import d2sqlite3;

import mustep.api.impl;

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
    private URLRouter router;

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

        router = new URLRouter();
        router.registerWebInterface(new MuStepApiImpl());
        router.get("*", serveStaticFiles(config.public_path));
    }

    /** 
     * Init database
     */
    public void initDatabase() @trusted
    {
        auto database = Database(SharedConfig.get().configInstance.cfg.db_path);

        database.run("CREATE TABLE IF NOT EXISTS universities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid VARCHAR(64) UNIQUE NOT NULL,
            name VARCHAR(256) UNIQUE NOT NULL,
            address VARCHAR(256) UNIQUE NOT NULL
        );");
    }

    /** 
     * Run the main server thread
     */
    public void start() @safe
    {
        listenHTTP(serverSettings, router);
        runApplication();
    }
}
