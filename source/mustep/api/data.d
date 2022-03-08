/**
 * API for getting data about universities
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 8 March 2022
 */
module mustep.api.data;

mixin template MuStepDataApi()
{
    import mustep.config_instance, d2sqlite3;
    import vibe.data.json;

    @method(HTTPMethod.GET) @path("/universities")
    public void getUniversitites(HTTPServerRequest req, HTTPServerResponse res) @trusted
    {
        Json data = Json(["result": Json.emptyArray]);

        auto database = Database(SharedConfig.get().configInstance.cfg.db_path);
        ResultRange result = database.execute("SELECT * FROM universities;");

        foreach(Row row; result)
        {
            Json record = Json.emptyObject;
            record["id"] = row["id"].as!int;
            record["uid"] = row["uid"].as!string;
            record["latitude"] = row["latitude"].as!double;
            record["longitude"] = row["longitude"].as!double;
            record["floors"] = row["floors"].as!int;

            data["result"] ~= record;
        }

        res.writeJsonBody(data, 200);
    }
}

