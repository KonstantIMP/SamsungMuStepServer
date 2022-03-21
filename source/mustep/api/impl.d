/**
 * Implementation of the server's api
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 4 March 2022
 */
module mustep.api.impl;

import vibe.http.router;
import vibe.http.server;
import vibe.web.web;

import mustep.api.base;
import mustep.api.data;

import d2sqlite3;

/** 
 * Implementation of the server's api
 */
class MuStepApiImpl
{
    mixin MuStepBaseApi;
    mixin MuStepDataApi;
}
