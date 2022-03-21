/**
 * Function for password generation
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 3 Nov 2021
 */
module kimp.passwd;

import std.random, std.string : representation;

/**
 * Enumeration of supported symbols for password making
 */
public enum GenerationOptions {
    LOWERCASE = 0x01,
    UPPERCASE = 0x02,
    NUMERAL   = 0x04,
    SPECIAL   = 0x08
}

private char [] uppercase = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
                             'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
                             'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

private char [] lowercase = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
                             'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
                             's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];

private char [] numeral = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

private char [] special = ['.', ',', '|', '\\', '/', '\'', '\"', '!', '@', ':', '^',
                           '#', '$', '%', '&', '?', '-', '+', '=', '~', ';', '*'];

/**
 * Class for password generation
 */
public class PasswordGenerator {
    /**
     * Generates new password
     * Params:
     *   length = length for the new password
     *   options = Symbols for password generation
     */
    public static string generatePassword(ulong length, ubyte options = 0x0f) @trusted {
        if (length == 0 || options == 0) throw new Exception("Password cannot exsists from noone character");

        char [] result; ulong minLength = 0;
        result.length = 0;

        if (options & GenerationOptions.LOWERCASE) minLength++;
        if (options & GenerationOptions.UPPERCASE) minLength++;
        if (options & GenerationOptions.NUMERAL) minLength++;
        if (options & GenerationOptions.SPECIAL) minLength++;

        if (length <= minLength) throw new Exception("Incorrect parametrs for the length");

        ulong upN = 0, lowN = 0, numN = 0, specN = 0;

        Mt19937 gen; gen.seed (unpredictableSeed);

        if (minLength == 1) {
            if (options & GenerationOptions.LOWERCASE) lowN = length;
            else if (options & GenerationOptions.UPPERCASE) upN = length;
            else if (options & GenerationOptions.NUMERAL) numN = length;
            else specN = length;
        }
        else if (minLength == 2) {
            ulong * first = null; ulong * second = null;

            if (options & GenerationOptions.LOWERCASE) first = &lowN;
            else if (options & GenerationOptions.UPPERCASE) {
                if (first == null) first = &upN;
                else second = &upN; 
            }
            else if (options & GenerationOptions.NUMERAL) {
                if (first == null) first = &numN;
                else second = &numN; 
            }
            else {
                second = &specN;
            }

            *first = gen.front() % (length - 2) + 1; gen.popFront();
            *second = length - *first;
        }
        else if (minLength == 3) {
            ulong * first = null; ulong * second = null; ulong * third = null;

            if (options & GenerationOptions.LOWERCASE) first = &lowN;
            else if (options & GenerationOptions.UPPERCASE) {
                if (first == null) first = &upN;
                else second = &upN;
            }
            else if (options & GenerationOptions.NUMERAL) {
                if (second == null) second = &numN;
                else third = &numN;
            }
            else {
                if (third == null) third = &specN;
            }

            *first = gen.front() % (length - 3) + 1; gen.popFront();
            *second = gen.front() % (length - *first - 2) + 1; gen.popFront();
            *third = length - *first - *second;
        }
        else {
            lowN = gen.front() % (length - 4) + 1; gen.popFront();
            upN = gen.front() % (length - lowN - 3) + 1; gen.popFront();
            numN = gen.front() % (length - lowN - upN + 2) + 1; gen.popFront();
            specN = length - upN - lowN - numN;
        }

        for (ulong i = 0; i < upN; i++) {
            result = result ~ uppercase[gen.front() % uppercase.length];
            gen.popFront();
        }
        for (ulong i = 0; i < lowN; i++) {
            result = result ~ lowercase[gen.front() % lowercase.length];
            gen.popFront();
        }
        for (ulong i = 0; i < numN; i++) {
            result = result ~ numeral[gen.front() % numeral.length];
            gen.popFront();
        }
        for (ulong i = 0; i < specN; i++) {
            result = result ~ special[gen.front() % special.length];
            gen.popFront();
        }

        for (ulong i = 0; i < 500; i++) {
            result = cast(char [])randomShuffle(result.representation());
        }

        return result.idup;
    }
}
