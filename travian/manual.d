module travian.manual;

import travian.structs;

import std.math;
import std.conv;

alias Time = TimeT3;

class TimeT3 {
    double a;
    double b;
    double k;

    this(double a)
    {
        this(a, 1.16, 1875);
    }

    this(double a, double k)
    {
        this(a, 1.16, 1875*k);
    }

    this(double a, double k, double b)
    {
        this.a = a;
        this.k = k;
        this.b = b;
    }

    uint value(uint level)
    {
        assert(0 < level);

        double seconds = this.a * pow(this.k, level-1) - this.b;
        return to!uint( round(seconds/10.0) * 10 );
    }
}

class Building
{
    string m_name;
    Resources m_cost;
    double m_k;
    uint m_cu;
    uint m_cp;
    Time m_time;
    uint m_level_max;
    Requirement[] m_requirements;

    struct Requirement
    {
        uint id; // building id
        int lvl; // level required
        this(uint id, int lvl)
        {
            this.id = id;
            this.lvl = lvl;
        }
    };

    this(string name, long[4] cost, double k, uint cu, uint cp, Time time, uint level_max, Requirement[] requirements = [] )
    {
        m_name = name;
        m_cost = new Resources(cost);
        m_k = k;
        m_cu = cu;
        m_cp = cp;
        m_time = time;
        m_level_max = level_max;
        m_requirements = requirements;
    }

    @property Requirement[] requirements()
    {
        return m_requirements;
    }

    @property string name()
    {
        return m_name;
    }

    @property uint level_max()
    {
        return m_level_max;
    }

    Resources cost(uint level)
    {
        assert(1 <= level && level <= m_level_max);
        return m_cost * m_k^^(level-1);
    }

    uint culture(uint level)
    {
        assert(1 <= level && level <= m_level_max);
        return to!uint( round(m_cp * 1.2^^level) );
    }

    uint time(uint level)
    {
        assert(1 <= level && level <= m_level_max);
        return m_time.value(level);
    }

    uint population(uint level)
    {
        assert(1 <= level && level <= m_level_max);
        uint pop = (level == 1) ? m_cu : to!uint( round((5*m_cu + level-1)/10.0) );
        return pop;
    }

    uint population_total(uint level)
    {
        assert(1 <= level && level <= m_level_max);
        uint sum = 0;
        for(uint i=1; i<=level; ++i)
            sum += population(i);
        return sum;
    }
};

class Manual
{
    static Building[42] buildings;
    @property static Building[] Buildings()
    {
        return buildings;
    }

    static this()
    {
        alias S = Structure;
        alias B = Building;
        alias R = Building.Requirement;
        buildings[S.Wood] =                 new B("Woodcutter", [40,100,50,60],         1.67, 2, 1, new TimeT3(1780/3.0, 1.6, 1000/3.0), 20);
        buildings[S.Clay] =                 new B("Clay Pit", [80,40,80,50],            1.67, 2, 1, new TimeT3(1660/3.0, 1.6, 1000/3.0), 20);
        buildings[S.Iron] =                 new B("Iron Mine", [100,80,30,60],          1.67, 3, 1, new TimeT3(2350/3.0, 1.6, 1000/3.0), 20);
        buildings[S.Crop] =                 new B("Cropland", [70,90,70,20],            1.67, 0, 1, new TimeT3(1450/3.0, 1.6, 1000/3.0), 20);
        buildings[S.Sawmill] =              new B("Sawmill", [520,380,290,90],          1.80, 4, 1, new TimeT3(5400, 1.5, 2400), 5);
        buildings[S.Brickworks] =           new B("Brickworks", [440,480,320,50],       1.80, 4, 1, new TimeT3(5400, 1.5, 2400), 5);
        buildings[S.Iron_Foundry] =         new B("Iron Foundry", [200,450,510,120],    1.80, 4, 1, new TimeT3(5400, 1.5, 2400), 5);
        buildings[S.Flour_Mill] =           new B("Flour Mill", [500,440,380,1240],     1.80, 4, 1, new TimeT3(5400, 1.5, 2400), 5);
        buildings[S.Bakery] =               new B("Bakery", [1200,1480,870,1600],       1.80, 4, 1, new TimeT3(5400, 1.5, 2400), 5);
        buildings[S.Warehouse] =            new B("Warehouse", [130,160,90,40],         1.28, 1, 1, new TimeT3(3875), 20);
        buildings[S.Granary] =              new B("Granary", [80,100,70,20],            1.28, 1, 1, new TimeT3(3475), 20);
        buildings[S.Blacksmith] =           new B("Blacksmith", [170,200,380,130],      1.28, 4, 2, new TimeT3(3875), 20);
        buildings[S.Armory] =               new B("Armory", [130,210,410,130],          1.28, 4, 2, new TimeT3(3875), 20, [ R(15,3), R(22,1) ]);
        buildings[S.Tournament_Square] =    new B("Tournament square", [1750,2250,1530,240], 1.28, 1, 1, new TimeT3(5375), 20, [ R(16,15) ]);
        buildings[S.Main_Building] =        new B("Main building", [70,40,60,20],       1.28, 2, 2, new TimeT3(3875), 20);
        buildings[S.Rally_Point] =          new B("Rally point", [110,160,90,70],       1.28, 1, 1, new TimeT3(3875), 20);
        buildings[S.Marketplace] =          new B("Marketplace", [80,70,120,70],        1.28, 4, 3, new TimeT3(3675), 20, [ R(15,3), R(10,1), R(11,1) ]);
        buildings[S.Embassy] =              new B("Embassy", [180,130,150,80],          1.28, 3, 4, new TimeT3(3875), 20, [ R(15,1) ]);
        buildings[S.Barracks] =             new B("Barracks", [210,140,260,120],        1.28, 4, 1, new TimeT3(3875), 20, [ R(15,3), R(16,1) ]);
        buildings[S.Stable] =               new B("Stable", [260,140,220,100],          1.28, 5, 2, new TimeT3(4075), 20, [ R(12,3), R(22,5) ]);
        buildings[S.Workshop] =             new B("Workshop", [460,510,600,320],        1.28, 3, 3, new TimeT3(4875), 20, [ R(15,5), R(22,10) ]);
        buildings[S.Academy] =              new B("Academy", [220,160,90,40],           1.28, 4, 4, new TimeT3(3875), 20, [ R(15,3), R(19,3) ]);
        buildings[S.Cranny] =               new B("Cranny", [40,50,30,10],              1.28, 0, 1, new TimeT3(2625), 10);
        buildings[S.Town_Hall] =            new B("Town Hall", [1250,1110,1260,600],    1.28, 4, 5, new TimeT3(14375), 20, [ R(15,10), R(22,10) ]);
        buildings[S.Residence] =            new B("Residence", [580,460,350,180],       1.28, 1, 2, new TimeT3(3875), 20, [ R(15,5), R(26,-1) ]);
        buildings[S.Palace] =               new B("Palace", [550,800,750,250],          1.28, 1, 5, new TimeT3(6875), 20, [ R(15,5), R(18,1), R(25,-1) ]);
        buildings[S.Treasury] =             new B("Treasury", [2880,2740,2580,990],     1.26, 4, 6, new TimeT3(9875), 20, [ R(15,10), R(40,-1) ]);
        buildings[S.Trade_Office] =         new B("Trade office", [1400,1330,1200,400], 1.28, 3, 3, new TimeT3(4875), 20, [ R(17,20), R(20,10) ]);
        buildings[S.Great_Barracks] =       new B("Great barracks", [630,420,780,360],  1.28, 4, 1, new TimeT3(3875), 20, [ R(19,20) ]);
        buildings[S.Great_Stable] =         new B("Great stable", [780,420,660,300],    1.28, 5, 2, new TimeT3(4075), 20, [ R(20,20) ]);
        buildings[S.Wall_Romans] =          new B("City wall", [70,90,170,70],          1.28, 0, 1, new TimeT3(3875), 20);
        buildings[S.Wall_Teutons] =         new B("Earth wall", [120,200,0,80],         1.28, 0, 1, new TimeT3(3875), 20);
        buildings[S.Wall_Gauls] =           new B("Palisade", [160,100,80,60],          1.28, 0, 1, new TimeT3(3875), 20);
        buildings[S.Stonemason] =           new B("Stonemason", [155,130,125,70],       1.28, 2, 1, new TimeT3(5950,2), 20, [ R(15,5), R(26,3) ]);
        buildings[S.Brewery] =              new B("Brewery", [1460,930,1250,1740],      1.40, 6, 4, new TimeT3(11750,2), 10, [ R(11,20), R(16,10) ]);
        buildings[S.Trapper] =              new B("Trapper", [100,100,100,100],         1.28, 4, 1, new TimeT3(2000,0), 20, [ R(16,1) ]);
        buildings[S.Heros_Mansion] =        new B("Hero's mansion", [700,670,700,240],  1.33, 2, 1, new TimeT3(2300,0), 20, [ R(15,3), R(16,1) ]);
        buildings[S.Great_Warehouse] =      new B("Great warehouse", [650,800,450,200], 1.28, 1, 1, new TimeT3(10875), 20, [ R(15,10) ]);
        buildings[S.Great_Granary] =        new B("Great granary", [400,500,350,100],   1.28, 1, 1, new TimeT3(8875), 20, [ R(15,10) ]);
        buildings[S.World_Wonder] =         new B("World Wonder", [66700,69050,72200,13200], 1.0275, 1, 0, new TimeT3(60857/2, 1.014, 42857/2), 100);
        buildings[S.Horse_Drinking_Pool] =  new B("Horse drinking trough", [780,420,660,540], 1.28, 5, 3, new TimeT3(5950,2), 20, [ R(16,10), R(20,20) ]);
    }
};
