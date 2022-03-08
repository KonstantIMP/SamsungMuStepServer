/**
 * Server for the μStep Andropid app
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module org.kimp.mu.step;

import mustep.config_instance;
import mustep.defines;
import mustep.server;

int main(string [] args)
{
    SharedConfig.get().configInstance.readConfigFile(CONFIG_PATH);

    MuStepServer server = new MuStepServer();
    server.initDatabase();
    server.start();

    return 0;
}
