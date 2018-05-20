module travian.network;

import travian.structs: Troops;

import std.stdio;
import luad.all;
import luad.c.all;
import std.random;
import std.net.curl;
import std.string: join;

auto random = Random(515674132);

interface INetworkingCallbacks
{
    void cb_update_structure( uint id, string type, uint level );
    void cb_update_resources( uint warehouse, uint granary, uint[4] resources, uint[4] production );
    void cb_update_build_cooldown( uint h, uint m, uint s );
    void cb_update_time_dilation( uint h, uint m, uint s );
}

class Networking : INetworkingCallbacks
{
    void cb_update_structure( uint id, string type, uint level ) {}
    void cb_update_resources( uint warehouse, uint granary, uint[4] resources, uint[4] production ) {}
    void cb_update_build_cooldown( uint h, uint m, uint s ) {}
    void cb_update_time_dilation( uint h, uint m, uint s ) {}

    private static Networking m_singleton;

	static this() {
		m_singleton = new Networking;
	}

	static Networking opCall() {
		return m_singleton;
	}

    lua_State *L;
    LuaState lua;

	HTTP http;
	ushort response;

    this()
    {
		auto cookie_path = "cookiejar" ~ ".cookies";

		http = HTTP();
		http.handle.set(CurlOption.cookiefile, cookie_path);
		http.handle.set(CurlOption.cookiejar, cookie_path);

        L = luaL_newstate();
        lua = new LuaState(L);
        lua.openLibs();

        lua["get"] = &get;
        lua["post"] = &post;
        lua["sleep"] = &sleep;

        lua.doFile("lua/basic.lua");

        lua["statistics_update_structure"] = &cb_update_structure;
        lua["statistics_update_resources"] = &cb_update_resources;
        lua["statistics_update_build_cooldown"] = &cb_update_build_cooldown;
        lua["statistics_update_time_dilation"] = &cb_update_time_dilation;
    }

    int get( string url, LuaObject[] query )
    {
        string query_str;
        if(query.length > 0)
            query_str = "?" ~ parse_query_string(query);
        write("  [GET] "~url~query_str);
        lua["html"] = .get( url ~ query_str, http );
        lua["header"] = http.responseHeaders;
        writefln("(%d)", http.statusLine.code);
        return http.statusLine.code;
    }

    int post( string url, LuaObject[] params )
    {
        write(" [POST] "~url~"("~parse_query_string(params)~")");
        lua["html"] = .post( url, parse_query_string(params), http );
        lua["header"] = http.responseHeaders;
        writefln("(%d)", http.statusLine.code);
        return http.statusLine.code;
    }

    void village1_build_mode(bool on) {
        lua.get!LuaFunction("village1_build_mode")(on);
    }
    void village1_enter() {
        lua.get!LuaFunction("village1_enter")();
    }
    void village2_enter() {
        lua.get!LuaFunction("village2_enter")();
    }
    void village2_building_enter(uint id) {
        lua.get!LuaFunction("village2_building_enter")(id);
    }
    uint village1_upgrade(uint id) {
        return lua.get!LuaFunction("village1_upgrade").call!int(id);
    }
    uint village2_upgrade(uint id) {
        return lua.get!LuaFunction("village2_upgrade").call!int(id);
    }
    uint village2_build(uint id, uint building_type) {
        return lua.get!LuaFunction("village2_build").call!int(id, building_type);
    }
    void village2_troops_create(uint id, Troops troop_count_array) {
        lua.get!LuaFunction("village2_troops_create")(id, troop_count_array);
    }
    void village2_troops_upgrade(uint id, uint troop_type) {
        lua.get!LuaFunction("village2_troops_upgrade")(id, troop_type);
    }
    void village2_troops_send(uint player_id, int x, int y, uint attack_type, Troops troop_count_array) {
        lua.get!LuaFunction("village2_troops_send")(player_id, x, y, attack_type, troop_count_array);
    }
    void village2_troops_return(uint id, Troops troop_count_array) {
        lua.get!LuaFunction("village2_troops_return")(id, troop_count_array);
    }

    bool login()
	{
		http.clearAllCookies();
        return lua.get!LuaFunction("login").call!bool();
	}

	void logout()
	{
        lua.get!LuaFunction("logout")();
		http.clearAllCookies();
	}

    void sleep( int min, int max )
	{
        import core.thread;
        //Thread.sleep( dur!("msecs")( uniform(min, max+1, random) ) );
    }

	string parse_query_string(LuaObject[] params)
	{
        if(params.length%2 == 1)
        {
            writeln("error: parse_query_string has odd number of params");
            for (int i=0; i<params.length; ++i)
                writeln (params[i].toString());
        }

        string[] pairs;
        for (int i=0; i<params.length; i+=2)
            pairs ~= params[i].toString() ~ "=" ~ params[i+1].toString();
        return pairs.join("&");
    }
}
