module main;

import std.stdio;
import travian.client;

int main(string[] args)
{

    Travian client = new Travian();

    //client.login();
    client.test();

	return 0;
}

/*
login
    village1
        production 1-18
    village2
        building specific task
        enter building
            train
            upgrade unit
            academy research
            destroy building
            warehouse/granary
            production building (mill, bakery, ..)
            wall
    farmlist
    statistics history and activity graph
        statistic module - also info about my village there
*/

/*
0,421052632 : clubswinger
0,352941176 : axeman
0,291262136 : teuton

0,333333333 : imp
0,218181818 : ei
0,225	    : cae

0,351351351 : swordsman
0,207407407 : haeduan
*/
