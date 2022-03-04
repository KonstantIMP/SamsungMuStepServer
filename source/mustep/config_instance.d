/**
 * Config file singleton instance
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.config_instance;

import mustep.config;
import kimp.config;

/** 
 * Singleton config file instance
 */
class SharedConfig {
    private this()
    {
        configInstance = new Config!MuStepConfig();
    }

    // Cache instantiation flag in thread-local bool
    // Thread local
    private static bool instantiated_;

    // Thread global
    private __gshared SharedConfig instance_;

    /**
     * Returns: Singleton Config object
     */
    static SharedConfig get()
    {
        if (!instantiated_)
        {
            synchronized(SharedConfig.classinfo)
            {
                if (!instance_)
                {
                    instance_ = new SharedConfig();
                }

                instantiated_ = true;
            }
        }

        return instance_;
    }

    public Config!MuStepConfig configInstance;
}
