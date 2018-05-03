module travian.structs;

class VillageData
{
    uint id;
    int x, y;
    int population;
    string name;
    //TODO production type

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

struct Troops
{
    enum: uint
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

    uint[10] m_troops;

    uint opIndex(uint index)
    {
        assert(0 < index && index <= 10);
        return m_troops[index-1]; // shift to zero-based index
    }

    uint opIndexAssign(uint value, uint index)
    {
        assert(0 < index && index <= 10);
        return m_troops[index-1] = value; // shift to zero-based index
    };
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
		Siege_Workshop = 		21,
		Academy = 				22,
		Cranny = 				23,
		Town_Hall = 			24,
		Residence = 			25,
		Palace = 				26,
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
		Warrior_Dealer = 		42,
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
		m_structure_name["Iron Foundry"] = 				Structure.Iron_Foundry;
		m_structure_name["Flour Mill"] = 				Structure.Flour_Mill;
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
		m_structure_name["Siege Workshop"] = 			Structure.Siege_Workshop;
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
		m_structure_name["Horse Drinking Pool"] = 		Structure.Horse_Drinking_Pool;
		m_structure_name["Warrior Dealer"] = 			Structure.Warrior_Dealer;
	}

	static uint id_of(string name)
	{
        if( name == "Wall" )
        {
            uint tribe = 0; // TODO: precte nejaky config pro cely account a vrati tribe
            uint[3] wall = [Wall_Romans, Wall_Gauls, Wall_Teutons];
            return wall[tribe];
        }
		return m_structure_name[name];
	}

	this( string type, uint level )
	{
		m_level = level;
		m_type = id_of(type);
	}

	this( uint type, uint level )
	{
		m_level = level;
		m_type = type;
	}
};
