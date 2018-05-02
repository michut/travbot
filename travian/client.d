module travian.client;

import travian.village;
import travian.network;

import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

class Travian
{
	// TODO: account info  common to all villages saved to file
	enum Tribe: uint
	{
		Romans = 0,
		Gauls = 1,
		Teutons = 2
	};
	Tribe tribe;

	Network network;
	Village[] villages;
	Village *village_active;

	this()
	{
        villages ~= new Village(); // TODO: ctor params
        village_active = &villages[0];
	}

	void test()
	{
        village_active.login();
        village_active.logout();

        //lua.get!LuaFunction("login")();

		//villages[0].upgrade_all_crops_to_level(10);
		//while(villages[0].build_queue_empty && villages[0].build_next(server_time_timestamp))
			//continue;

        //lua.get!LuaFunction("village2_enter")();
/*
        lua.get!LuaFunction("village2_build")(29, 19);
        lua.get!LuaFunction("village2_upgrade")(29);
        lua.get!LuaFunction("village2_upgrade")(29);
        lua.get!LuaFunction("village2_upgrade")(29);*/

        //lua.get!LuaFunction("village2_troops_create")(29, [0, 0, 1000]);
        //lua.get!LuaFunction("village2_troops_send")(159588, -4, -11, 2, [0, 0, 1000, 0, 0, 0, 0, 0, 0, 0]);
        //lua.get!LuaFunction("village2_troops_return")(159588, [0, 0, 1000, 0, 0, 0, 0, 0, 0, 0]);
	}

	void loop()
	{

	}

	bool profile()
	{
		/*string name, alliance;
		uint rank, village_count;
		int population;
		Tribe tribe;

		string html;
		html = .get( acc.server ~ "/profile.php", http ).dup;
		Document doc = new Document( html );

		//Element villages = doc.querySelector( "table#villages" );
		// NAME
		Element profile = doc.querySelector( "table#profile" );
		name = profile.querySelector( "th[colspan=2]" ).innerHTML.strip;
		writeln("'" ~ name ~ "'");

		// PROFILE DETAILS
		Element details = doc.querySelector( "td.details" );
		Element[] table = details.querySelectorAll( "td" );
		string[] data;
		foreach( td; table )
			if( 0 == td.attributes.length )
			{
				data ~= td.innerHTML.strip;
				writeln("'" ~ td.innerHTML ~ "'");
			}

		rank = to!uint(data[0]);
		alliance = data[2]=="-" ? null:data[2];
		village_count = to!uint(data[3]);
		population = to!int(data[4]);
		switch(data[1])
		{
			case "Romans":	tribe = Tribe.Romans; break;
			case "Gauls":	tribe = Tribe.Gauls; break;
			case "Teutons":	tribe = Tribe.Teutons; break;
			default: writeln("#error: unknown tribe."); assert(0);
		}
		*/
		return true;
	}
};
