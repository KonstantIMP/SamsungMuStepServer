/**
 * Smart config file managing
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 17 Sep 2021
 */
module kimp.config;

import std.exception, std.json, std.traits;
import std.file, std.conv : to;

import std.traits : isFloatingPoint, isUnsigned;

/**
 * Specific exception for the config modules
 */
class ConfigException : Exception {
    /**
     * Creates and throws new 'ConfigException'
     * Params:
     *   msg = Error message for throwing
     *   file = File where exception was throwed
     *   line = Line from which the exception was throwed
     */
    public pure nothrow @nogc @safe this (string msg, string file = __FILE__, ulong line = __LINE__) {
        super (msg, file, line);
    }
}

/**
 * Struct for mark config`s argument
 */
struct Argument {       /** */
    string name;            /** */
    string description;     /** */
    ulong  since;           /** */
    bool   isRequired;      /** */
    string section;         /** */
}
/**
 * Unified config file class (JSON)
 */
public class Config (T) {
    private JSONValue rootJson;
    private T         rootT;

    private ulong     maxVersion;

    /**
     * Creates new Config and gets arguments from T type
     */
    public this () @safe {
        maxVersion = 0;
        parseConfigType ();
    }

    /**
     * Reads and parses the config file
     * Fills the structure with arguments
     * Updates the config if need
     * Params:
     *   filename = path to the file with JSON config
     * Returns: Deserialized cfg struct
     */
    public T readConfigFile (string filename) @trusted {
        if (exists (filename) == false) {
            resetToDefault (filename);
            readConfigFile (filename);
        }

        rootJson = parseJSON (to!string (read (filename)));

        if ("version" !in rootJson) {
            resetToDefault (filename);
            readConfigFile (filename);
        }

        if (rootJson ["version"].integer < maxVersion) {
            updateConfig (filename);
            readConfigFile (filename);
        }

        deserializeJson ();
    
        return rootT;
    }

    /**
     * Getter and setter for the configuration
     */
    @property T cfg () @safe pure nothrow @nogc { return rootT; }

    /** Ditto */
    @property T cfg (T newCfg) @safe pure nothrow { return rootT = newCfg; }

    private void deserializeJson () @safe pure {
        rootT = T();

        foreach (arg; __traits (allMembers, T)) {
            auto udas = getUDAs!(__traits (getMember, T, arg), Argument);
            if (udas.length == 0) continue;
            if (udas[0].isRequired) {
                if (udas[0].section.length == 0) {
                    if (arg !in rootJson) throw new ConfigException ("Could not find the argument: " ~ arg);
                }
                else {
                    if (udas[0].section !in rootJson || arg !in rootJson[udas[0].section]) {
                        throw new ConfigException ("Could not find the argument: " ~ arg);
                    }
                }
            }

            JSONValue base = rootJson;
            if (udas[0].section.length) {
                if (udas[0].section !in rootJson) rootJson[udas[0].section] = parseJSON ("{}");
                base = rootJson[udas[0].section];
            }

            if (arg in base) {        
                static if (is (typeof (__traits (getMember, T, arg)) == string)) {
                    __traits (getMember, rootT, arg) = base[arg].str();
                }
                else static if (is (typeof (__traits (getMember, T, arg)) == bool)) {
                    __traits (getMember, rootT, arg) = base[arg].boolean();
                }
                else static if (is (typeof (__traits (getMember, T, arg)) == ulong) && isUnsigned!(typeof (__traits (getMember, T, arg)))) {
                    __traits (getMember, rootT, arg) = base[arg].integer();
                }
                else static if (is (typeof (__traits (getMember, T, arg)) == long)) {
                    __traits (getMember, rootT, arg) = base[arg].integer();
                }
                else static if (isFloatingPoint!(typeof (__traits (getMember, T, arg)))) {
                    __traits (getMember, rootT, arg) = base[arg].floating();
                }
                else throw new ConfigException ("Incorrect argument type: " ~ arg);
            }
        }
    }

    private void updateConfig (string filename) @safe {
        foreach (arg; __traits (allMembers, T)) {
            auto udas = getUDAs!(__traits (getMember, T, arg), Argument);
            if (udas.length == 0) continue;
            if (udas[0].since > rootJson ["version"].integer) {
                if (udas[0].isRequired) resetConfigArgument!arg ();
            }
        }
        rootJson["version"] = maxVersion;
        write (filename, rootJson.toPrettyString ());
    }

    private void resetConfigArgument (string arg) () pure @safe {
        auto udas = getUDAs!(__traits (getMember, T, arg), Argument);

        if (udas.length) {
            if (udas[0].isRequired == false) return;
            if (udas[0].section.length) {
                if (udas[0].section !in rootJson) rootJson [udas[0].section] = parseJSON ("{}");
                rootJson [udas[0].section][arg] = __traits (getMember, T(), arg);
            }
            else rootJson [arg] = __traits (getMember, T(), arg);
        }
    }

    private void resetToDefault (string filename) @safe {
        rootJson = parseJSON ("{}");
        rootJson ["version"] = maxVersion;

        foreach (arg; __traits (allMembers, T)) {
            resetConfigArgument!arg ();
        }

        write (filename, rootJson.toPrettyString ());
    }

    private void parseConfigType () pure @safe {
        foreach (arg; __traits (allMembers, T)) {
            parseConfigArgument!arg ();
        }
    }

    private void parseConfigArgument (string arg) () pure @safe {
        auto udas = getUDAs!(__traits (getMember, T, arg), Argument);

        if (udas.length > 1)
            throw new ConfigException (T.stringof ~ " has a member with more than 1 @Attribute: " ~ arg);
        else if (udas.length == 1) {
            if (udas[0].since > maxVersion) maxVersion = udas[0].since;
        }
    }
}
