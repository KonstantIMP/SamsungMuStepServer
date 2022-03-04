/**
 * Configuration file description
 * Authro: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.config;

import kimp.config;
//import library.kimp.kimp.config;

struct MuStepConfig {
    @Argument ("port", "The binding port", 0, true, "server") ulong port = 1992;

    @Argument ("cert", "SSL certificate path", 0, false, "ssl") string cert = "";
    @Argument ("pkey", "Private Key path",     0, false, "ssl") string pkey = "";
}
