--- Network module for travian
-- @module travian.network

server =    "https://crusadertrav.eu/t3s"
name =      "pepsi"
password =  "545821245"

page = {}
page.login =            server.."/index.php?dcookie"
page.logout =           server.."/logout.php"
page.village1 =         server.."/village1.php"
page.village2 =         server.."/village2.php"
page.build =            server.."/build.php"
page.send_troops = 		server.."/v2v.php"

build_code = nil
build_mode = false


--table.foreach(header, print)

--- Account login
function login()
    get(server, {})
    sleep(1500, 3000)

    -- redirect (firstlogin.php)
    post(page.login, {"namee", name, "pass", password})

    if( nil == string.match(html, 'href="village1.php"') ) then
        print("login failed.")
        return false
    else
        print("login successfull.")
    end

	local h,m,s = string.match(html, '<span id="timer2" class="b">(%d+):(%d%d):(%d%d)</span>')
    statistics_update_time_dilation( tonumber(h), tonumber(m), tonumber(s) )

	village1_enter()
	village1_build_mode(true)

    return true
end

--- Account logout
function logout()
    sleep(2000, 4500)
    get(page.logout, {});
    get(page.login, {});
end

function test()
    --village2_troops(29, {11, 54, 66})
end

--- Set state of build mode
-- fast building with one http query
-- state stored in global variable <build_mode>
-- @param on boolean on/off
function village1_build_mode(on)
    sleep(1000, 1500)
    mode = {[true]="1", [false]="2"}
    get(page.village1, {"bmode", mode[on]})
    build_mode = on;
	parse_build_code(html)
end

--- Parse build_code (text captcha) from html
-- parse build code and copy to global variable <build_code>
-- @param html string to parse
function parse_build_code(html)
	local code = tostring(string.match(html, 'href="%w+%.php%?id=%d+[a-zA-Z0-9&=]-%&k=(%w+ ?)"'))
	--print("build code: "..code)

	if( nil ~= code ) then
    	build_code = code
	else
		print("parse_build_code failed.")
	end
end

--- Parse build progress
-- parse build progress line under the village1 and village2
-- @param html string to parse
-- @return building slot id
-- @return level to be upgraded to
-- @return hours to complete
-- @return minutes to complete
-- @return seconds to complete
function parse_build_progress(html)
	local match_str =
	'href="%?id=(%d+)&k=%w+">[%w ]+%(level (%d+)%)'..
	'</a></td>%s+'..
	'<td>Finished in  <b><span id="timer1">(%d+):(%d%d):(%d%d)</span>'
    return string.gmatch(html, match_str)
end

--- Enter village1
-- also scans the info available in village1
function village1_enter()
    sleep(1000, 2000)
    get(page.village1, {})
    if(true == build_mode) then
        parse_build_code(html)
    end
	scan_village1(html)
end

--- Enter village2
-- also scans the info available in village2
function village2_enter()
    sleep(1000, 2000)
    get(page.village2, {})
    if(true == build_mode) then
        parse_build_code(html)
    end
	scan_village2(html)
end

--- Enter building in village2
-- enters structure build in the desired location
-- @param id location
function village2_building_enter(id)
    id = tostring(id)

   	sleep(1000, 2000)
    get(page.build, {"id", id})
    parse_build_code(html)
end

--- Upgrade building in village1
-- upgrade structure one level higher
-- @param id location
-- @return level to be upgraded or 0 if failed
function village1_upgrade(id)
    id = tostring(id)

    if(false == build_mode) then
    sleep(1000, 2000)
        get(page.build, {"id", id})
        parse_build_code(html)
    elseif(nil == build_code) then
        village1_enter()
    end
    sleep(1000, 2000)
    get(page.village1, {"id", id, "k", build_code})

    if(true == build_mode) then
    	parse_build_code(html)
	end

    for b_id, b_level, h,m,s in parse_build_progress(html) do
        if(b_id ~= id) then
            b_level = string.match(html, '<area href="build.php%?id='..id..'" title="%w- level (%d+)')
            if(nil == b_level) then
                return 0;
            end
		end
        statistics_update_build_cooldown( tonumber(h), tonumber(m), tonumber(s) )
        return b_level
    end
end

--- Upgrade building in village2
-- upgrade structure one level higher
-- @param id location
-- @return level to be upgraded or 0 if failed
function village2_upgrade(id)
    id = tostring(id)

    if(false == build_mode) then
    	sleep(1000, 2000)
        get(page.build, {"id", id})
        parse_build_code(html)
    elseif(nil == build_code) then
        village2_building_enter(id)
	end

    sleep(1000, 2000)
    get(page.village2, {"id", id, "k", build_code})

    if(true == build_mode) then
    	parse_build_code(html)
    else
        build_code = nil
	end

    for b_id, b_level, h,m,s in parse_build_progress(html) do
        if(b_id ~= id) then
            b_level = string.match(html, '<area href="build.php%?id='..id..'" title="%w- level (%d+)')
            if(nil == b_level) then
                return 0;
            end
        end
        statistics_update_build_cooldown( tonumber(h), tonumber(m), tonumber(s) )
        return b_level
    end
end

--- Build new building in village2
-- build new structure
-- @param id location
-- @param building_type structure type id
-- @return level to be upgraded or 0 if failed
function village2_build(id, building_type)
    id = tostring(id)
    building_type = tostring(building_type)
    --local empty = string.match(html, '<area href="build.php%?id='..tostring(id)..'" title="Empty place"') == nil ? false : true

    if(false == build_mode) then
    	sleep(1000, 2000)
        get(page.build, {"id", id})
        parse_build_code(html)
    elseif(nil == build_code) then
        village2_building_enter(id)
	end

    sleep(1000, 2000)
    get(page.village2, {"id", id, "b", building_type, "k", build_code})

    if(true == build_mode) then
    	parse_build_code(html)
    else
        build_code = nil
	end

    for b_id, b_level, h,m,s in parse_build_progress(html) do
        if(b_id ~= id) then
            b_level = string.match(html, '<area href="build.php%?id='..id..'" title="%w- level (%d+)')
            if(nil == b_level) then
                return 0;
            end
        end
        statistics_update_build_cooldown( tonumber(h), tonumber(m), tonumber(s) )
        return b_level
    end
end

--- Simulate random click
-- generate random x and y locations of the click on the button
-- @param max_x width of the button
-- @param max_y height of the button
-- @return x location of the click
-- @return y location of the click
function random_click( max_x, max_y )
    min = 3
    max_x = max_x - 3 - min
    max_y = max_y - 3 - min

    math.randomseed(os.time())

    local x_rand = math.random();
    local y_rand = math.random();
    -- use arcsin to move propability to the center of the button
    local x_ratio = (math.asin(x_rand*2-1) + 0.5*math.pi) / math.pi
    local y_ratio = (math.asin(y_rand*2-1) + 0.5*math.pi) / math.pi

    local x = tostring( math.floor(x_ratio*max_x+min) )
    local y = tostring( math.floor(y_ratio*max_y+min) )
    return x, y

end

--- Create new troops
-- @param id location of the building needed (barracks, stable, workshop)
-- @param troops_count_array array[10] of the troops to build
function village2_troops_create(id, troops_count_array)
	local click_x, click_y = random_click(97,20)

    local params = {
        "s1.x", click_x,
        "s1.y", click_y,
    }

    for key,count in ipairs(troops_count_array) do
        table.insert(params, "tf["..key.."]")
        table.insert(params, count)
    end

    post(page.build.."?id="..id, params)
end

--- Upgrade troop stats
-- upgrade stats of the troops at blacksmith/armory
-- @param id location of blacksmith/armory
-- @param troop_id id of the troop (1-10)
function village2_troops_upgrade(id, troop_id)
	get(page.build, {"id", id, "a", troop_id, "k", build_code})
	parse_build_code(html)
end

--- Send troops
-- send reinforcement, attack, or reinforcement to another player
-- @param dest_id id of the player in the destination
-- @param dest_x x map location of the destination
-- @param dest_y y map location of the destination
-- @param attack_type 2:reinf, 3:attack, 4:attack
-- @param troops_count_array array[10] of the troops to send
function village2_troops_send(dest_id, dest_x, dest_y, attack_type, troops_count_array)
	sleep(1000, 2000)
	get(page.send_troops, {"id", dest_id})

	local code = string.match(html, 'name="k" value="(%w+)"')
	if(nil ~= code) then
		build_code = code
	else
		print("error: village2_troops_send build_code == nil")
		if(nil == build_code) then
			return
		end
	end

	local click_x, click_y = random_click(47,20)
	params1 = {statistics_update_resources
		--keeping their strange param order
		"t[1]", troops_count_array[1],
		"t[4]", troops_count_array[4],
		"t[7]", troops_count_array[7],
		"t[9]", troops_count_array[9],
		"t[2]", troops_count_array[2],
		"t[5]", troops_count_array[5],
		"t[8]", troops_count_array[8],
		"t[10]", troops_count_array[10],
		"t[3]", troops_count_array[3],
		"t[6]", troops_count_array[6],

		"dname", 	"",
		"c", 		attack_type,
		"k",		build_code,
		"x",		dest_x,
		"y",		dest_y,
		"s1.x",		click_x,
		"s1.y",		click_y,
	}

	-- summary check
	sleep(2000, 3000)
	post(page.send_troops, params1)

	local click_x, click_y = random_click(47,20)
	params2 = {
		"id", 		dest_id,
		"c", 		attack_type,
		-- insert troops here on row 3
		"k",		build_code,
		"s1.x",		click_x,
		"s1.y",		click_y,
	}
	-- insert troops
	for key,count in ipairs(troops_count_array) do
		local index = 3+(key-1)*2
		table.insert(params2, index, "t["..key.."]")
		table.insert(params2, index+1, count)
	end
	-- actual send
	sleep(1000, 1500)
	post(page.send_troops, params2)
end

--- Call troops back from reinforcement
-- @param dest_id id of the player who has reinforcements from you
-- @param troops_count_array array[10] of the troops to return
function village2_troops_return(dest_id, troops_count_array)
	sleep(1000, 2000)
	get(page.send_troops, {"d3", dest_id})

	local params = {}
	-- insert troops
	for key,count in ipairs(troops_count_array) do
		table.insert(params, "t["..key.."]")
		table.insert(params, count)
	end
	local click_x, click_y = random_click(47,20)
	table.insert(params, "s1.x")
	table.insert(params, click_x)
	table.insert(params, "s1.y")
	table.insert(params, click_y)

	sleep(2000, 3000)
	post(page.send_troops.."?d3="..dest_id, params)
end

--- Scan resources
-- parse resources from html source and update client in Dlang via callback
-- @param html string to parse
function scan_resources(html)
	local match_str_time = '<span id="timer2" class="%w+">(%d%d:%d%d:%d%d)</span>'

	local match_str_production =
	'<div class="ware">%s+(%d+)%s+</div>%s+'..
	'<div data%-init="(%d+)" class="wood" data%-prod="(%d+)">%s+%d+%s+</div>%s+'..
	'<div data%-init="(%d+)" class="clay" data%-prod="(%d+)">%s+%d+%s+</div>%s+'..
	'<div data%-init="(%d+)" class="iron" data%-prod="(%d+)">%s+%d+%s+</div>%s+'..
	'<div data%-init="(%d+)" class="crop" data%-prod="(%d+)">%s+%d+%s+</div>%s+'..
	'<br/>%s+'..
	'<div class="gran">%s+(%d+)%s+</div>%s+'..
	'<div class="cons">%s+(%d+)/(%d+)%s+</div>'

	local time = string.match(html, match_str_time)
	for
	ware,
	wood, wood_prod,
	clay, clay_prod,
	iron, iron_prod,
	crop, crop_prod,
	gran, cons, cons_max
	in string.gmatch(html, match_str_production) do
		wood = tonumber(wood)
		clay = tonumber(clay)
		iron = tonumber(iron)
		crop = tonumber(crop)
		wood_prod = tonumber(wood_prod)
		clay_prod = tonumber(clay_prod)
		iron_prod = tonumber(iron_prod)
		crop_prod = tonumber(crop_prod)
		ware = tonumber(ware)
		gran = tonumber(gran)
		cons = tonumber(cons)
		cons_max = tonumber(cons_max)
		statistics_update_resources(ware, gran, {wood, clay, iron, crop}, {wood_prod, clay_prod, iron_prod, crop_prod})
	end
end

--- Scan structures
-- parse structures built in village1 or village2 from html source and update client in Dlang via callback
-- @param html string to parse
function scan_structures(html)
	local match_str = '<area href="village[1-2].php%?id=(%d+)%&k=%w+ ?"[%w%d =,"]- title="([%w ]+) level (%d+)"'

	for id, name, level in string.gmatch(html, match_str) do
		print(id, name, level)
		id = tonumber(id)
		level = tonumber(level)
		statistics_update_structure(id, name, level)
	end

	if(nil ~= string.gmatch(html, "bmode=1")) then
		build_mode = false
	else
		build_mode = true
	end
end

--- Scan village1
-- parse all info from village
-- @todo scan troops
-- @param html string to parse
function scan_village1(html)
	scan_resources(html)
	scan_structures(html)
end

--- Scan village1
-- parse all info from village
-- @param html string to parse
function scan_village2(html)
	scan_resources(html)
	scan_structures(html)
end
