/**
 * INI documents support
 * Author: KonstantIMP
 * Date: 13 Sep 2021
 */
module kimp.ini;

import std.exception;

/**
 * Specific exception for the INI modules
 */
class INIException : Exception {
    /**
     * Creates and throws new INIException
     * Params:
     *   msg = Error message for throwing
     *   file = File where exception was throwed
     *   line = Line from which the exception was throwed
     */
    public pure nothrow @nogc @safe this (string msg, string file = __FILE__, ulong line = __LINE__) {
        super (msg, file, line);
    }
}

import std.traits : isSomeString, isFloatingPoint, isUnsigned, isIntegral;
import std.exception : enforce;

/**
 * INI type enumeration
 */
enum INIType : byte {
    null_   , NULL  = null_   ,
    int_    , INT   = int_    ,
    uint_   , UINT  = uint_   ,
    double_ , DOUBLE = double_,
    str_    , STR   = str_    ,
    true_   , TRUE  = true_   ,
    false_  , FALSE = false_
}

/**
 * INI vlaue node
 */
struct INIValue {
    /** Supported types for storage in the node */
    private union Store {
        string string_;
        long   int_   ;
        ulong  uint_  ;
        double double_;
    }
    /** Currently stored data */
    private Store store;
    /** Currently stored data`s type */
    private INIType typeTag;

    /**
     * Creates new INIValue object
     * Params:
     *   arg = Default value for the node
     */ 
    public this (T) (T arg) @safe nothrow pure {
        assign (arg);
    }

    /**
     * Assign a value to the object
     * Params:
     *   arg = New value for assigning
     */
    private void assign (T) (T arg) nothrow pure @trusted {
        static if (is (T : typeof (null))) {
            typeTag = INIType.NULL;
        }
        else static if (is (T : string)) {
            typeTag = INIType.STR;
            store.string_ = arg;
        }
        else static if (isSomeString!T) {
            import std.utf : byUTF;
            this.assign (cast(string)(arg.byUTF!char.array));
        }
        else static if (is (T : bool)) {
            typeTag = arg ? INIType.TRUE : INIType.FALSE;
        }
        else static if (is (T : ulong) && isUnsigned!T) {
            typeTag = INIType.UINT;
            store.uint_ = arg;
        }
        else static if (is (T : long)) {
            typeTag = INIType.INT;
            store.int_ = arg;
        }
        else static if (isFloatingPoint!T) {
            typeTag = INIType.DOUBLE;
            store.double_ = arg;
        }
        else static if (is (T : INIValue)) {
            typeTag = arg.type; store = arg.store;
        }
        else static assert (false, "Unable to convert type " ~ T.stringof ~ " to INI");
    }

    /**
     * Returns current node`s type
     */
    @property INIType type () const pure nothrow @safe @nogc {
        return typeTag;
    }

    /** Assign test */
    @safe unittest {
        INIValue tmp = INIValue (null);
        assert (tmp.type == INIType.NULL);

        tmp = INIValue (10);
        assert (tmp.type == INIType.INT);

        tmp = INIValue (10u);
        assert (tmp.type == INIType.UINT);

        tmp = INIValue (false);
        assert (tmp.type == INIType.FALSE);

        tmp = INIValue (true);
        assert (tmp.type == INIType.TRUE);

        tmp = INIValue ("gogogo");
        assert (tmp.type == INIType.STR);

        tmp = INIValue (INIValue ("frog"));
        assert (tmp.type == INIType.STR);
    }

    /**
     * Value getter/setter for `INIType.string`.
     * Throws: `INIException` for read access if `type` is not `INIType.STR`.
     */
    @property string str () const pure @trusted return scope {
        enforce!INIException(type == INIType.STR, "INIValue is not a string");
        return store.string_;
    }

    /** ditto */
    @property string str (return string value) pure nothrow @nogc @trusted return {
        assign (value); return value;
    }

    /**
     * Value getter/setter for `INIType.boolean`.
     * Throws: `INIException` for read access if `type` is not `INIType.FALSE` or `INIType.TRUE`
     */
    @property bool boolean () const pure @safe return scope {
        enforce!INIException(type == INIType.TRUE || type == INIType.FALSE, "INIValue is not a boolean");
        if (typeTag == INIType.TRUE) return true;
        return false;
    }

    /** ditto */
    @property bool boolean (return bool value) pure nothrow @nogc @safe return {
        assign (value); return value;
    }

    /**
     * Value getter/setter for `INIType.integer`.
     * Throws: `INIException` for read access if `type` is not `INIType.INT'
     */
    @property long integer () const pure @safe return scope {
        enforce!INIException(type == INIType.INT, "INIValue is not an integer");
        return store.int_;
    }

    /** ditto */
    @property long integer (return long value) pure nothrow @nogc @safe return {
        assign (value); return value;
    }

    /**
     * Value getter/setter for `INIType.uinteger`.
     * Throws: `INIException` for read access if `type` is not `INIType.UINT'
     */
    @property ulong uinteger () const pure @safe return scope {
        enforce!INIException(type == INIType.UINT, "INIValue is not an unsigned integer");
        return store.uint_;
    }

    /** ditto */
    @property ulong uinteger (return ulong value) pure nothrow @nogc @safe return {
        assign (value); return value;
    }

    /**
     * Value getter/setter for `INIType.double`.
     * Throws: `INIException` for read access if `type` is not `INIType.DOUBLE'
     */
    @property double floating () const pure @safe return scope {
        enforce!INIException(type == INIType.DOUBLE, "INIValue is not a floating point integer");
        return store.double_;
    }

    /** ditto */
    @property double floating (return double value) pure nothrow @nogc @safe return {
        assign (value); return value;
    }

    /**
     * Returns true if the node is null
     */
    public bool isNull () pure nothrow @nogc @safe {
        return type == INIType.NULL;
    }

    /** Set and get tests */
    @safe unittest {
        INIValue tmp = INIValue(null);

        assert (tmp.isNull());
        tmp.str ("Hello");   assert (tmp.str() == "Hello");
        tmp.boolean (false); assert (tmp.boolean() == false);
        tmp.boolean (true);  assert (tmp.boolean() == true);
        tmp.integer (10);    assert (tmp.integer() == 10);
        tmp.uinteger (10u);  assert (tmp.uinteger() == 10u);
        tmp.floating (9.12); assert (tmp.floating() == 9.12);
    }

    /***
     * Generic type value getter
     * A convenience getter that returns this `INIValue` as the specified D type.
     * Note: only numeric, `bool`, `string` types are accepted
     * Throws: `INIException` if `T` cannot hold the contents of this `INIValue`
     *         `ConvException` in case of integer overflow when converting to `T`
     */
    public inout(T) get (T) () inout const pure @safe {
        static if (is (immutable T == immutable string)) return str();
        else static if (is (immutable T == immutable bool)) return boolean();
        else static if (isFloatingPoint!T) {
            switch (typeTag) {
            case INIType.INT    : return cast(T)integer();
            case INIType.UINT   : return cast(T)uinteger();
            case INIType.DOUBLE : return cast(T)floating();
            default: throw new INIException ("INIValue is not a number type");
            }
        }
        else static if (isIntegral!T) {
            switch (typeTag) {
            case INIType.INT    : return cast(T)integer();
            case INIType.UINT   : return cast(T)uinteger();
            default: throw new INIException ("INIValue is not an integral type");
            }
        }
        else throw new INIException ("Unsupported type");
    } 

    void opAssign (T) (T arg) {
        assign (arg);
    }

    bool opEquals(const INIValue rhs) const @nogc nothrow pure @safe {
        return opEquals(rhs);
    }

    bool opEquals(ref const INIValue rhs) const @nogc nothrow pure @trusted { 
        if (typeTag != rhs.typeTag) return false;

        switch (typeTag) {
        case INIType.INT:
            switch (rhs.typeTag) {
                case INIType.INT : return store.int_ == rhs.store.int_;
                case INIType.UINT : return store.int_ == rhs.store.uint_;
                case INIType.DOUBLE : return store.int_ == rhs.store.double_;
                default : return false;
            }
        case INIType.UINT:
            switch (rhs.typeTag) {
                case INIType.INT : return store.uint_ == rhs.store.int_;
                case INIType.UINT : return store.uint_ == rhs.store.uint_;
                case INIType.DOUBLE : return store.uint_ == rhs.store.double_;
                default : return false;
            }
        case INIType.DOUBLE:
            switch (rhs.typeTag) {
                case INIType.INT : return store.double_ == rhs.store.int_;
                case INIType.UINT : return store.double_ == rhs.store.uint_;
                case INIType.DOUBLE : return store.double_ == rhs.store.double_;
                default : return false;
            }
        case INIType.STR:
            return store.string_ == rhs.store.string_;
        default:
            return typeTag == rhs.typeTag;
        }
    }

    string toString() const pure @safe {
        import std.conv : to;

        if (type == INIType.NULL) return "null";
        else if (type == INIType.STR) return '\"' ~ str() ~ '\"';
        else if (type == INIType.TRUE) return "true";
        else if (type == INIType.FALSE) return "false";
        else if (type == INIType.INT) return to!string(integer());
        else if (type == INIType.UINT) return to!string(uinteger());
        else return to!string(floating());
    }
}

/**
 * Base node for ini document
 */
struct INISection {
    /** Name of the section */
    private string sectionName;
    /** Props contained in the section */
    private INIValue [string] props;

    /**
     * Creates new INISection
     * Params:
     *   name = Name for the section
     */
    public this (string name) @safe pure nothrow {
        sectionName = name;
    }

    /***
     * Hash syntax for ini objects.
     * Throws: `INIException` if the section doesn-t contain the key
     */
    ref inout (INIValue) opIndex (string k) inout pure @safe {
        enforce!INIException(k in props, "Key not found: " ~ k);
        return props[k];
    }

    /***
     * Operator sets `value` for element of INI object by `key`.
     */
    T opIndexAssign (T) (auto ref T value, string key) {
        props[key] = INIValue(value);
        return value;
    }

    /**
     * Support for the `in` operator.
     *
     * Tests wether a key can be found in an object.
     *
     * Returns:
     *      when found, the `inout(INIValue)*` that matches to the key,
     *      otherwise `null`.
     */
    inout (INIValue)* opBinaryRight(string op : "in")(string k) inout @safe {
        return k in props;
    }

    /** Section unittest */
    @safe unittest {
        INISection tmp = INISection ("Woof");

        tmp["rang"] = INIValue(10);   assert (tmp["rang"].toString() == "10");
        tmp["rang"] = null;           assert (tmp["rang"].toString() == "null");
        tmp["bb"] = "Hello, my dear"; assert (tmp["bb"].type == INIType.STR);
    }

    string toString() const pure @safe {
        import std.array : appender;
        auto section = appender!string;

        section.put("["); section.put(sectionName); section.put("]\n");

        foreach (key; props.byKey()) {
            section.put(key); section.put("=");
            section.put(props[key].toString());
            section.put("\n");
        }

        return section.data;
    }
}

/**
 * Base node for the INI
 */
struct INIDocument {
    /** Sections list */
    private INISection[string] sections;

    /**
     * Support for the `in` operator.
     *
     * Tests wether a key can be found in an object.
     *
     * Returns:
     *      when found, the `inout(INISection)*` that matches to the key,
     *      otherwise `null`.
     */
    inout (INISection)* opBinaryRight(string op : "in")(string k) inout @safe {
        return k in sections;
    }

    /***
     * Hash syntax for ini objects.
     * Throws: `INIException` if the section doesn-t contain the key
     */
    ref INISection opIndex (string k) pure @safe {
        if (k !in sections) sections[k] = INISection (k);
        return sections[k];
    }

    /***
     * Operator sets `value` for element of INI object by `key`.
     */
    INISection opIndexAssign (INISection value, string key) {
        sections[key] = value;
        return value;
    }

    string toString() const pure @safe {
        import std.array : appender;
        auto document = appender!string;

        foreach (key; sections.byKey()) {
            document.put (sections[key].toString());
            document.put ("\n");
        }

        return document.data;
    }

    /** INIDocument test */
    @safe unittest {
        auto d = INIDocument();

        d["Woof"]["ok"] = true;
        d["colors"]["black"] = 0x00;
        d["colors"]["white"] = "0xffffff";
        d["Woof"]["false"] = -1;
    }
}

import std.range.primitives : ElementEncodingType, isInfinite, isInputRange;
import std.ascii : isWhite, toLower, toUpper, isHexDigit, isDigit;
import std.range : empty; import std.algorithm.searching : count;
import std.traits : isSomeChar; import std.array : split;
import std.regex : matchFirst; import std.conv : to;

/**
 * Parses a serialized string and returns a tree of JSON values.
 * Throws: $(LREF INIException) if string does not follow the INI grammar
 *   $(LREF ConvException) if a number in the input cannot be represented by a native D type.
 * Params:
 *   ini = ini-formatted string to parse
 */
INIDocument parseINI (T) (T ini) if (isInputRange!T && !isInfinite!T && isSomeChar!(ElementEncodingType!T)) {
    INIDocument root = INIDocument ();

    void error (string msg) { throw new INIException (msg); }

    if (ini.empty) return root;

    string currentSection = "";

    void processSection (string line) {
        if (matchFirst (line, r"^\s*\[\w+\]$")) {
            currentSection = line.split ('[') [$ - 1].split (']')[0];
        }
        else error ("Incorrect section definition: " ~ line);
    }

    void processProperty (string line) {
        if (matchFirst (line, r"^\w+\s*\=\s*[\-]?\w+$")) {
            import std.string : isNumeric, toLowStr = toLower;

            string currentProp = line.split ('=') [0];
            string currentVal  = line.split ('=') [1];

            if (matchFirst (currentVal.toLowStr (), r"^\s*true\s*$")) root [currentSection] [currentProp] = true;
            else if (matchFirst (currentVal.toLowStr (), r"^\s*false\s*$")) root [currentSection] [currentProp] = true;
            else if (matchFirst (currentVal.toLowStr (), r"^\s*null\s*$")) root [currentSection] [currentProp] = null;
            else if (isNumeric (currentVal)) {
                if (['.'].count (currentVal)) root [currentSection] [currentProp] = to!double (currentVal);
                else if (['-'].count (currentVal)) root [currentSection] [currentProp] = to!long (currentVal);
                else root [currentSection] [currentProp] = to!ulong (currentVal);
            }
            else root [currentSection] [currentProp] = currentVal;
        }
        else error ("Incorrect property definition: " ~ line);
    }

    void processLine (string line) {
        ulong pos = 0;

        /** Skip whitespace */
        while (isWhite (line [pos])) {
            if (pos + 1 >= line.length) return;
            pos++;
        }
    
        /** Check comments */
        if ([';', '#'].count (line [pos])) return;
        else if (line [pos] == '[') processSection (line [pos .. $]);
        else processProperty (line [pos .. $]);
    }

    foreach (line; ini.split ('\n')) {
        if (line.empty) continue;
        processLine (line);
    }

    return root;
}
