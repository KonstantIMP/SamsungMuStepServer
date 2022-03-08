/**
 * Configuration file description
 * Authro: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.config;

import kimp.config;

struct MuStepConfig
{
    @Argument ("public", "Path to the static resources", 0, false, "server") string public_path = "./public/";
    @Argument ("port", "The binding port", 0, true, "server") ulong port = 1992;

    @Argument ("cert", "SSL certificate path", 0, false, "ssl") string cert = "";
    @Argument ("pkey", "Private Key path",     0, false, "ssl") string pkey = "";
}
