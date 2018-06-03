module travian.village;

import travian.structs;
import travian.network;

import std.stdio;
import std.container: BinaryHeap;
import std.typecons: Typedef;
import luad.all;
import std.range;
import std.datetime;

class Village : VillageData
{
    //TODO: vytvorit tridu pro account variables misto static v teto tride
	static long s_time_dilation; // seconds, add to the Clock.currTime()
	@property static long server_timestamp()
	{
		return Clock.currTime().toUnixTime() + s_time_dilation;
	}

	uint[uint] m_plan;
	long build_cooldown; //stop building queue until this timestamp
	VillageNetworking m_network;
	@property VillageNetworking net() { return m_network; }

	alias Queue = BinaryHeap!(QueueItem[], "a > b");
	Queue m_queue_build;
	Queue m_queue_attack;
	Queue m_queue_precise;

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
		m_plan[Structure.Workshop] = 			    25;
		m_plan[Structure.Academy] = 				32;
		m_plan[Structure.Cranny] = 					0;
		m_plan[Structure.Town_Hall] = 				0;
		m_plan[Structure.Residence] = 				31;
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
	}

    class VillageNetworking : Networking, INetworkingCallbacks
    {
        override void cb_update_structure(uint id, string type, uint level)
        {
            structures[id] = new Structure(type, level);
        }

        override void cb_update_resources(uint warehouse, uint granary, uint[4] resources, uint[4] production)
        {
            warehouse = warehouse;
            granary = granary;
            resources = resources;
            production = production;

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
    };

    class QueueItem
    {
        alias opCmp = Object.opCmp;
        long timestamp;

        this(long timestamp)
        {
            this.timestamp = timestamp;
        }

        // sorting by timestamp
        int opCmp(QueueItem other)
        {
            if( this.timestamp > other.timestamp )
                return 1;
            if( this.timestamp < other.timestamp )
                return -1;
            return 0;
        }

        bool execute() { assert(false); return false; } // predelat bool na void a udelat exception
    };

    class QueueTroopsMovement : QueueItem
    {
        VillageData target;
        Troops troops;
        uint action;

        enum: uint
        {
            Reinforcement = 2,
            Attack = 3,
            Raid = 4,
            Return = 5,
        };

        this( long timestamp, VillageData target, uint action, Troops troops )
        {
            super(timestamp);
            this.target = target;
            this.action = action;
            this.troops = troops;
        }

        override bool execute()
        {
            //TODO if rally point is not present return false
            if( action == Return )
            {
                net.village2_troops_return(
                    target.id,
                    troops
                );
            }
            else if( action == Reinforcement ||
                     action == Attack ||
                     action == Raid )
            {
                //TODO if troops are not present return false
                net.village2_troops_send(
                    target.id,
                    target.x,
                    target.y,
                    action,
                    troops
                );
            }
            else
                return false;
            return true;
        }
    };

    class QueueStructureBuild : QueueItem
    {
        uint place_id;
        uint building_type;

        this( long timestamp, uint place_id, uint building_type )
        {
            super(timestamp);
            this.place_id = place_id;
            this.building_type = building_type;
        }

        override bool execute()
        {
            if(structures[place_id] is null) {
                net.village2_build(place_id, building_type);
                return true;
            }

            uint lv_before = structures[place_id].level;
            uint lv_after;
            if(place_id <= 18)
                lv_after = net.village1_upgrade(place_id);
            else
                lv_after = net.village2_upgrade(place_id);

            if(lv_after == lv_before + 1) {
                //success
                structures[place_id].level = lv_after; // TODO: mozna resit pres callback
                return true;
            }
            return false;
        }
    };

    class QueueTroopsBuild : QueueItem
    {
        Troops troops;

        this( long timestamp, Troops troops )
        {
            super(timestamp);
            this.troops = troops;
        }

        override bool execute()
        {
            alias S = Structure;
            uint[] structures = [S.Barracks, S.Stable, S.Workshop, S.Residence];

            foreach(structure_id; structures)
            {
                Troops troops_filtered = troops.filter_by_structure(structure_id);
                if(troops_filtered.sum() > 0)
                    net.village2_troops_create(structure_id, troops_filtered);
            }
            return true;
        }
    };

    class QueueTroopsUpgrade : QueueItem
    {
        uint place_id; // academy, armorsmith or blacksmith
        uint troop_type;

        this( long timestamp, uint place_id, uint troop_type )
        {
            super(timestamp);
            this.place_id = place_id;
            this.troop_type = troop_type;
        }

        override bool execute()
        {
            net.village2_troops_upgrade(place_id, troop_type);
            return true;
        }
    };

	void queue_execute()
	{
        //jedna iterace loopu
	}

	void upgrade_all_crops_to_level(uint level_max = 1)
	{
		foreach(level; 0..level_max)
			foreach(id; 1..19)
				if(structures[id].level <= level)
					m_queue_build.insert( new QueueStructureBuild(0, id, 0) );
	}
};
