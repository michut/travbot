module travian.village;

import travian.structures;
import travian.network;

import std.stdio;
import luad.all;
import std.range;
import std.datetime;

struct VillageData
{
	Structure[40] structures;

	uint warehouse;
	uint granary;
	uint[4] resources;
	uint[4] production;

	uint[] troops;
}

class Village : Network, NetworkCallbacks
{
    //TODO: vytvorit tridu pro account variables misto static v teto tride
    static long s_server_timestamp;
	static long s_time_dilation; // seconds, add to the Clock.currTime()
	@property static long server_timestamp()
	{
		return Clock.currTime().toUnixTime() + s_time_dilation;
	}

	struct BuildQueue
	{
		uint id;
		uint type;

		this( uint c_id, uint c_type )
		{
			id = c_id;
			type = c_type;
		}
	};

	BuildQueue[] m_build_queue;
	VillageData m_data;
	uint[uint] m_plan;
	long build_cooldown; //stop building queue until this timestamp

	this()
	{
		build_cooldown = 0;

		m_plan[Structure.Sawmill] = 				34;
		m_plan[Structure.Brickworks] = 				35;
		m_plan[Structure.Iron_Foundry] = 			36;
		m_plan[Structure.Flour_Mill] = 				38;
		m_plan[Structure.Bakery] = 					37;
		m_plan[Structure.Warehouse] = 				19;
		m_plan[Structure.Granary] = 				27;
		m_plan[Structure.Blacksmith] = 				24;
		m_plan[Structure.Armory] = 					28;
		m_plan[Structure.Tournament_Square] = 		0;
		m_plan[Structure.Main_Building] = 			26;
		m_plan[Structure.Rally_Point] = 			39;
		m_plan[Structure.Marketplace] = 			0;
		m_plan[Structure.Embassy] = 				0;
		m_plan[Structure.Barracks] = 				29;
		m_plan[Structure.Stable] = 					30;
		m_plan[Structure.Siege_Workshop] = 			25;
		m_plan[Structure.Academy] = 				32;
		m_plan[Structure.Cranny] = 					0;
		m_plan[Structure.Town_Hall] = 				0;
		m_plan[Structure.Residence] = 				0;
		m_plan[Structure.Palace] = 					31;
		m_plan[Structure.Trade_Office] = 			0;
		m_plan[Structure.Great_Barracks] = 			0;
		m_plan[Structure.Great_Stable] = 			0;
		m_plan[Structure.Wall_Romans] = 			40;
		m_plan[Structure.Wall_Gauls] = 				40;
		m_plan[Structure.Wall_Teutons] = 			40;
		m_plan[Structure.Stonemason] = 				0;
		m_plan[Structure.Brewery] = 				0;
		m_plan[Structure.Trapper] = 				0;
		m_plan[Structure.Heros_Mansion] = 			33;
		m_plan[Structure.Great_Warehouse] = 		0;
		m_plan[Structure.Great_Granary] = 			0;
		m_plan[Structure.World_Wonder] = 			0;
		m_plan[Structure.Horse_Drinking_Pool] = 	0;
		m_plan[Structure.Warrior_Dealer] = 			0;
	}

	override void cb_update_structure(uint id, string type, uint level)
	{
		m_data.structures[id] = new Structure(type, level);
	}

	override void cb_update_resources(uint warehouse, uint granary, uint[4] resources, uint[4] production)
	{
		m_data.warehouse = warehouse;
		m_data.granary = granary;
		m_data.resources = resources;
		m_data.production = production;

		/*
        writefln("%d %d", warehouse, granary);
        writefln("%d %d %d %d", stock[0], stock[1], stock[2], stock[3]);
        writefln("%d %d %d %d", production[0]/60, production[1]/60, production[2]/60, production[3]/60);

		// stock full in:
        writefln("%ds %ds %ds %ds",
			(warehouse-stock[0])/(production[0]/60),
			(warehouse-stock[1])/(production[0]/60),
			(warehouse-stock[2])/(production[0]/60),
			(granary-stock[3])/(production[0]/60) );

		// stock percentage
        writefln("%d%% %d%% %d%% %d%%", stock[0]/(warehouse/100), stock[1]/(warehouse/100), stock[2]/(warehouse/100), stock[3]/(granary/100));
        */
	}

	override void cb_update_build_cooldown( uint h, uint m, uint s )
	{
	    if( 0 == server_timestamp )
        {
            writeln("error: time dilation was not set. update server timestamp.");
            return;
        }
		build_cooldown = server_timestamp + (3600*h + 60*m + s);
	}

    override void cb_update_time_dilation( uint h, uint m, uint s )
	{
		auto now = Clock.currTime();
		int diff_seconds = 3600*h + 60*m + s;
		diff_seconds -= 3600*now.hour + 60*now.minute + now.second;

		if(diff_seconds > 12*3600)
			diff_seconds -= 24*3600;
		else if(diff_seconds < -12*3600)
			diff_seconds += 24*3600;

		s_time_dilation = diff_seconds;

		//auto client_timestamp = now.toUnixTime();
		//auto server_timestamp = client_timestamp + time_dilation;
	}

	void build(uint place, uint structure)
	{
        if(place <= 18)
        	village1_upgrade(place);
        else if(m_data.structures[place] is null)
        	village2_build(place, structure);
		else
        	village2_upgrade(place);

		//print("village1_build: "..id.." (failed)")
        //print("village1_build: "..id.." (lv"..b_level..")")
	}

    bool build_queue_empty()
	{
		return m_build_queue.length == 0;
	}

	bool build_next(long timestamp)
	{
		if(m_build_queue.length == 0)
			return false;
		if(timestamp < build_cooldown)
			return false;

		BuildQueue structure = m_build_queue[0];
		build(structure.id, structure.type);
		m_build_queue.popFront();

		return true;
	}

	void upgrade_all_crops_to_level(uint level_max = 1)
	{
		foreach(level; 0..level_max)
			foreach(id; 1..19)
				if(m_data.structures[id].level <= level)
					m_build_queue ~= BuildQueue(id, 0);
	}
};
