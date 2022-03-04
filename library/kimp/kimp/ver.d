/**
 * Functions for versions manage
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 17 Sep 2021
 */
module kimp.ver;

/**
 * Translate versions' in digits to comparable format
 * Params:
 *     major = Major version for translation
 *     minor = Minor version for translation
 *     build = Build version for translation
 * Returns:
 *     Apps' version in compatable format 
 */
pure nothrow uint genVersion(uint major, uint minor, uint build) @safe @nogc {
    return cast(uint)((major << 16) | (minor << 8) | build);
}

/** Unittests for genVersion */
@safe unittest {
    assert(genVersion( 0,  0,  0) == 0x000000);
    assert(genVersion( 0,  1,  0) == 0x000100);
    assert(genVersion( 2,  1,  7) == 0x020107);
    assert(genVersion( 2,  0,  0) == 0x020000);
    assert(genVersion(11, 11, 12) == 0x0b0b0c);
}
