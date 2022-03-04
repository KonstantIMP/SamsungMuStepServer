/**
 * Base API methods
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.api.base;

mixin template MuStepBaseApi()
{
    @method(HTTPMethod.GET) @path("/")
    public void index(HTTPServerRequest req, HTTPServerResponse res) @safe
    {
        res.render!("index.dt", req);
    }
}
