module travian.structs;

enum Tribe: uint
{
    Romans = 0,
    Gauls = 1,
    Teutons = 2
};

class Resources
{
    long[4] m_resources;
    alias m_resources this;

    this()
    {
        this(0,0,0,0);
    }

    this( long wood, long clay, long iron, long crop )
    {
        m_resources = [wood, clay, iron, crop];
    }

    this( long[4] rhs )
    {
        this( rhs[0], rhs[1], rhs[2], rhs[3] );
    }

    Resources opAssign(long[4] rhs)
    {
        m_resources = rhs;
        return this;
    }

    long opIndexAssign(long value, uint index)
    {
        assert(0 <= index && index < 4);
        return m_resources[index] = value;
    };

    long opIndexAssign(int value, uint index)
    {
        return opIndexAssign(cast(long)value, index);
    };

    Resources opBinary(string op)(long[4] rhs)
    {
        static if (op == "+")
            return [ m_resources[0]+rhs[0], m_resources[1]+rhs[1], m_resources[2]+rhs[2], m_resources[3]+rhs[3] ];
        else static if (op == "-")
            return [ m_resources[0]-rhs[0], m_resources[1]-rhs[1], m_resources[2]-rhs[2], m_resources[3]-rhs[3] ];
        else static if (op == "*")
            return [ m_resources[0]*rhs[0], m_resources[1]*rhs[1], m_resources[2]*rhs[2], m_resources[3]*rhs[3] ];
        else static assert(0, "Operator "~op~" not implemented");
    }

    Resources opBinary(string op)(double rhs) if (op == "*")
    {
        import std.conv;
        import std.math;

        Resources temp = new Resources;
        temp = m_resources;

        foreach(ref resource; temp)
        {
            double cost = resource * rhs;
            resource = to!long(round(cost / 5.0)) * 5L; //divisible by 5
        }
        return temp;
    }
};

class VillageData
{
    uint id;
    int x, y;
    int population;
    string name;
    //TODO production type

	float range_from(VillageData destination)
	{
	    import std.math;
	    float x_diff = this.x - destination.x;
	    float y_diff = this.y - destination.y;
	    return sqrt(x_diff*x_diff + y_diff*y_diff);
	}

	Structure[40] structures;
	uint warehouse;
	uint granary;
	uint[4] resources;
	uint[4] production;

	uint timestamp_last_resources_update;

	Troops troops;
	Troops[] reinforcements;
	Troops reinforcements_animal;
};

class Enemy : VillageData
{
	uint timestamp_last_troops_update;

    //TODO owner with his activity log

    import std.typecons : Nullable;
	Nullable!uint cranny;
	bool is_safe_to_scout = false;
	bool is_safe_to_farm = false;
};

enum Troop: uint
{
    Phalanx = 1,
    Swordsman = 2,
    Pathfinder = 3,
    Theutates_Thunder = 4,
    Druidrider = 5,
    Haeduan = 6,

    Clubswinger = 1,
    Spearman = 2,
    Axeman = 3,
    Scout = 4,
    Paladin = 5,
    Teutonic_Knight = 6,

    Legionnaire = 1,
    Praetorian = 2,
    Imperian = 3,
    Equites_Legati = 4,
    Equites_Imperatoris = 5,
    Equites_Caesaris = 6,

    Ram = 7,
    Catapult = 8,
    Senator = 9,
    Chief = 9,
    Chieftain = 9,
    Settler = 10,
};

struct Troops
{
    uint[10] m_troops;

    uint opIndex(Troop index)
    {
        assert(0 < index && index <= 10);
        return m_troops[index-1]; // shift to zero-based index
    }

    uint opIndexAssign(uint value, Troop index)
    {
        assert(0 < index && index <= 10);
        return m_troops[index-1] = value; // shift to zero-based index
    };

    uint where_to_build(Troop id)
	{
	    alias T = Troop;
        Tribe tribe = Tribe.Teutons; // TODO: precte nejaky config pro cely account a vrati tribe

        switch(tribe)
        {
            default: throw new Exception("error: unknown tribe");
            case Tribe.Romans:
                switch(id) {
                    default: throw new Exception("error: unknown troop type");
                    case T.Legionnaire:
                    case T.Praetorian:
                    case T.Imperian:
                        return Structure.Barracks;
                    case T.Equites_Legati:
                    case T.Equites_Imperatoris:
                    case T.Equites_Caesaris:
                        return Structure.Stable;
                    case T.Ram:
                    case T.Catapult:
                        return Structure.Workshop;
                    case T.Senator:
                    case T.Settler:
                        return Structure.Residence;
                }
            break;
            case Tribe.Gauls:
                switch(id) {
                    default: throw new Exception("error: unknown troop type");
                    case T.Phalanx:
                    case T.Swordsman:
                        return Structure.Barracks;
                    case T.Pathfinder:
                    case T.Theutates_Thunder:
                    case T.Druidrider:
                    case T.Haeduan:
                        return Structure.Stable;
                    case T.Ram:
                    case T.Catapult:
                        return Structure.Workshop;
                    case T.Chieftain:
                    case T.Settler:
                        return Structure.Residence;
                }
            break;
            case Tribe.Teutons:
                switch(id) {
                    default: throw new Exception("error: unknown troop type");
                    case T.Clubswinger:
                    case T.Spearman:
                    case T.Axeman:
                    case T.Scout:
                        return Structure.Barracks;
                    case T.Paladin:
                    case T.Teutonic_Knight:
                        return Structure.Stable;
                    case T.Ram:
                    case T.Catapult:
                        return Structure.Workshop;
                    case T.Chief:
                    case T.Settler:
                        return Structure.Residence;
                }
            break;
        }
	}

    Troops filter_by_structure(uint structure_id)
    {
        alias S = Structure;
        import std.algorithm: canFind;
        assert([S.Barracks, S.Stable, S.Workshop, S.Residence, S.Palace].canFind(structure_id));

        Troops troops_filtered;
        foreach(Troop troop_id, uint troop_count; m_troops) {
            if(troop_count > 0 && where_to_build(troop_id) == structure_id) {
                troops_filtered[troop_id] = troop_count;
            }
        }
        return troops_filtered;
    }

    uint sum()
    {
        import std.algorithm: reduce;
        return reduce!((a, b) => a + b)(0, m_troops);
    }
};

class Structure
{
	uint m_type;
	uint m_level;

	static uint[string] m_structure_name;

	@property uint type() {
		return m_type;
	}

	@property void type(uint type) {
		m_type = type;
	}

	@property void type(string type) {
		m_type = m_structure_name[type];
	}

	@property uint level() {
		return m_level;
	}

	@property void level(uint level) {
		m_level = level;
	}

	enum: uint
	{
		Empty =					0,
		Wood = 					1,
		Clay = 					2,
		Iron = 					3,
		Crop = 					4,
		Sawmill = 				5,
		Brickworks = 			6,
		Iron_Foundry = 			7,
		Flour_Mill = 			8,
		Bakery = 				9,
		Warehouse = 			10,
		Granary = 				11,
		Blacksmith = 			12,
		Armory = 				13,
		Tournament_Square = 	14,
		Main_Building = 		15,
		Rally_Point = 			16,
		Marketplace = 			17,
		Embassy = 				18,
		Barracks = 				19,
		Stable = 				20,
		Workshop = 		        21,
		Academy = 				22,
		Cranny = 				23,
		Town_Hall = 			24,
		Residence = 			25,
		Palace = 				26,
		Treasury =              27,
		Trade_Office = 			28,
		Great_Barracks = 		29,
		Great_Stable = 			30,
		Wall_Romans = 			31,
		Wall_Gauls = 			32,
		Wall_Teutons = 			33,
		Stonemason = 			34,
		Brewery = 				35,
		Trapper = 				36,
		Heros_Mansion = 		37,
		Great_Warehouse = 		38,
		Great_Granary = 		39,
		World_Wonder = 			40,
		Horse_Drinking_Pool = 	41,
	};

	static this()
	{
		m_structure_name["Empty place"] = 				Structure.Empty;
		m_structure_name["Woodcutter"] = 				Structure.Wood;
		m_structure_name["Clay Pit"] = 					Structure.Clay;
		m_structure_name["Iron Mine"] = 				Structure.Iron;
		m_structure_name["Cropland"] = 					Structure.Crop;
		m_structure_name["Sawmill"] =					Structure.Sawmill;
		m_structure_name["Brickworks"] = 				Structure.Brickworks;
		m_structure_name["Brickyard"] = 				Structure.Brickworks;
		m_structure_name["Iron Foundry"] = 				Structure.Iron_Foundry;
		m_structure_name["Flour Mill"] = 				Structure.Flour_Mill;
		m_structure_name["Grain Mill"] = 				Structure.Flour_Mill;
		m_structure_name["Bakery"] =					Structure.Bakery;
		m_structure_name["Warehouse"] = 				Structure.Warehouse;
		m_structure_name["Granary"] = 					Structure.Granary;
		m_structure_name["Blacksmith"] = 				Structure.Blacksmith;
		m_structure_name["Armoury"] = 					Structure.Armory;
		m_structure_name["Armory"] = 					Structure.Armory;
		m_structure_name["Tournament Square"] = 		Structure.Tournament_Square;
		m_structure_name["Main Building"] = 			Structure.Main_Building;
		m_structure_name["Rally Point"] = 				Structure.Rally_Point;
		m_structure_name["Marketplace"] = 				Structure.Marketplace;
		m_structure_name["Embassy"] = 					Structure.Embassy;
		m_structure_name["Barracks"] = 					Structure.Barracks;
		m_structure_name["Stable"] = 					Structure.Stable;
		m_structure_name["Workshop"] = 			        Structure.Workshop;
		m_structure_name["Siege Workshop"] = 			Structure.Workshop;
		m_structure_name["Academy"] = 					Structure.Academy;
		m_structure_name["Cranny"] = 					Structure.Cranny;
		m_structure_name["Town Hall"] = 				Structure.Town_Hall;
		m_structure_name["Residence"] = 				Structure.Residence;
		m_structure_name["Palace"] = 					Structure.Palace;
		m_structure_name["Trade Office"] = 				Structure.Trade_Office;
		m_structure_name["Great Barracks"] = 			Structure.Great_Barracks;
		m_structure_name["Great Stable"] = 				Structure.Great_Stable;
		//m_structure_name["Wall"] =
		m_structure_name["Stonemason"] = 				Structure.Stonemason;
		m_structure_name["Brewery"] = 					Structure.Brewery;
		m_structure_name["Trapper"] = 					Structure.Trapper;
		m_structure_name["Heros Mansion"] = 			Structure.Heros_Mansion;
		m_structure_name["Great Warehouse"] = 			Structure.Great_Warehouse;
		m_structure_name["Great Granary"] = 			Structure.Great_Granary;
		m_structure_name["World Wonder"] = 				Structure.World_Wonder;
		m_structure_name["Wonder of the World"] = 	    Structure.World_Wonder;
		m_structure_name["Horse Drinking Pool"] = 		Structure.Horse_Drinking_Pool;
		m_structure_name["Horse Drinking Trough"] = 	Structure.Horse_Drinking_Pool;
	}

	this( string type, uint level )
	{
		m_level = level;
		m_type = id_of_structure(type);
	}

	this( uint type, uint level )
	{
		m_level = level;
		m_type = type;
	}

	static uint id_of_structure(string name)
	{
        if( name == "Wall" )
        {
            uint tribe = 0; // TODO: precte nejaky config pro cely account a vrati tribe
            uint[3] wall = [Wall_Romans, Wall_Gauls, Wall_Teutons];
            return wall[tribe];
        }
		return m_structure_name[name];
	}
};
