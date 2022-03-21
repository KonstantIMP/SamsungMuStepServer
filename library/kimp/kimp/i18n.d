/**
 * A library for i18n in D
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 22 Aug 2021
 */
module kimp.i18n;

import std.json, std.file, std.exception;

///> Aliases for better use
alias _  = I18n.get;
alias _f = I18n.getFallback;

/** 
 * An exception for I18n errors
 */
public class I18nException : Exception {
    /** 
     * Creates and throws new I18nException
     * Params:
     *   err = Error message for the exception
     */
    public this (string err) { super (err); }
}

/** 
 * Struct for locale description
 * To load locale use JSON file with the struct :
 * { "name" : "locale`s name", "tr" : [{"id" : "id for the text", "tr" : "translation for the id"}, ...] }
 */
private struct Locale {
    ///> Locale`s name (like 'en')
    public string name = "";
    ///> Loaded translations for this locale
    public string [string] tr;
}

/** 
 * Class for actual i18n
 */
public static class I18n {
    ///> List of the loaded locales
    private static Locale [string] loadedLocales;
    ///> Currently used locale
    private static string currentLocale;
    
    /**
     * Inits the I18n module
     */
    public static this () {
        import core.stdc.locale : setlocale, LC_ALL;
        import std.conv : to;

        currentLocale = "";
        
        foreach (f; ["./i18n/", "./po/", "./locale/"]) {
            try loadLocales(f);
            catch (Exception) {}
        }

        string tmp = (to!string(setlocale(LC_ALL, "")))[0 .. 2];
        if (tmp in loadedLocales) currentLocale = tmp;
        else if (loadedLocales.keys.length) currentLocale = loadedLocales.keys[0];
    }

    /** 
     * Loads locale from JSON file
     * Params:
     *   path = Path to the JSON locale
     * Throws:
     *   FileException if the file doesn`t exsists
     *   I18nException if was given incorrect locale file
     */
    public static void loadLocale (string path) {
        import std.conv : to;
        loadLocaleFromMemory (to!string(read (path)));
    }

    /** 
     * Loads locale from data
     * Params:
     *   data = Data for loading
     * Throws:
     *   I18nException if was given incorrect locale file
     *   JSONException if was given incorrect locale file
     */
    public static void loadLocaleFromMemory (string data) {
        JSONValue lj = parseJSON ((data));

        Locale ll; ll.name = lj["name"].str();

        foreach (tr; lj["tr"].array) {
            ll.tr[tr["id"].str()] = tr["tr"].str();
        }
        
        loadedLocales[ll.name] = ll;
    }

    /** 
     * Loads all locales from the folder (non recursive)
     * Params:
     *   path = Path to the folder for loading
     * Throws:
     *   FileException if cannot read a file with the locale
     *   I18nException if was found an incorrect locale file
     */
    public static void loadLocales (string path) {
        foreach (DirEntry en; dirEntries (path, SpanMode.shallow)) {
            if (en.isFile) loadLocale (en.name);
        }
    }

    /** 
     * Getter for the translation
     * Params:
     *   id = ID for the translation
     *   locale = Locale for translation getting 
     * Returns: Translation for the ID
     * Throws: I18nException if cannot find locale or id
     */
    public static string get (string id, string locale = currentLocale) {
        if (locale !in loadedLocales) throw new I18nException("Cannot find locale : " ~ locale);
        if (id !in loadedLocales[locale].tr) throw new I18nException("Cannot find the id : " ~ id);
        return loadedLocales[locale].tr[id];
    }

    /** 
     * Getter for the translation
     * Params:
     *   id = ID for the translation
     *   fallback = Translation if the error was catched
     *   locale = Locale for translation getting 
     * Returns: Translation for the ID or fallback
     */
    public static string getFallback (string id, string fallback, string locale = currentLocale) {
        if (locale !in loadedLocales) return fallback;
        if (id !in loadedLocales[locale].tr) return fallback;
        return loadedLocales[locale].tr[id];
    }

    /** 
     * Returns: List of the loaded locales
     */
    public static string [] getLoadedLocales () { return loadedLocales.keys; }

    /** 
     * Returns: Currently used locale
     */
    public static string getCurrentLocale () { return currentLocale; }
    
    /** 
     * Sets a new value for a current locale
     * Params:
     *   locale = New locale
     */
    public static void setCurrentLocale (string locale) { currentLocale = locale; }
}
