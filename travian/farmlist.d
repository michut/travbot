module travian.farmlist;

import travian.structs;
import travian.village;

import std.typecons : Nullable;

class Farm : VillageData
{
	uint timestamp_last_troops_update;

    //TODO owner with his activity log

	Nullable!uint cranny;
	bool is_safe_to_scout = false;

	uint range_from(Village village)
	{
	    uint range_tiles;
	    //TODO pythagoras

	    return range_tiles;
	}

	Village[] scout; //TODO scan village
	Village[] farmer; //TODO send troops
	Village[] hammer; //TODO send troops and or ram+catapults to stop enemy resistance
};

class FarmList
{
    Farm[] m_farmlist;
};
