/*
	Nuclear Warhead Mission with new difficulty selection system
	Hardcore now gives persistent vehicle
	easy/mod/difficult/hardcore - reworked by [CiC]red_ned http://cic-gaming.co.uk
	based on work by Defent and eraser1
	Made for GOGs Server by Cloudskipper
*/

private ["_num", "_side", "_pos", "_OK", "_difficulty", "_AICount", "_group", "_type", "_launcher", "_staticGuns", "_crate1", "_vehicle", "_pinCode", "_class", "_veh", "_crate_loot_values1", "_missionAIUnits", "_missionObjs", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_markers", "_time", "_added", "_cleanup", "_baseObjs", "_crate_weapons", "_crate_weapon_list", "_crate_items", "_crate_item_list", "_crate_backpacks", "_PossibleDifficulty", "_smoke", "_fire"];

// For logging purposes
_num = DMS_MissionCount;


// Set mission side (only "bandit" is supported for now)
_side = "bandit";


// This part is unnecessary, but exists just as an example to format the parameters for "DMS_fnc_MissionParams" if you want to explicitly define the calling parameters for DMS_fnc_FindSafePos.
// It also allows anybody to modify the default calling parameters easily.
if ((isNil "_this") || {_this isEqualTo [] || {!(_this isEqualType [])}}) then
{
	_this =
	[
		[10,DMS_WaterNearBlacklist,DMS_MinSurfaceNormal,DMS_SpawnZoneNearBlacklist,DMS_TraderZoneNearBlacklist,DMS_MissionNearBlacklist,DMS_PlayerNearBlacklist,DMS_TerritoryNearBlacklist,DMS_ThrottleBlacklists],
		[
			[]
		],
		_this
	];
};

// Check calling parameters for manually defined mission position.
// You can define "_extraParams" to specify the vehicle classname to spawn, either as _vehClass or [_vehClass]
_OK = (_this call DMS_fnc_MissionParams) params
[
	["_pos",[],[[]],[3],[],[],[]],
	["_extraParams",[]]
];

if !(_OK) exitWith
{
	diag_log format ["DMS ERROR :: Called MISSION gogs_cargo_tower.sqf with invalid parameters: %1",_this];
};


//create possible difficulty add more of one difficulty to weight it towards that
_PossibleDifficulty		= 	[
								"easy",
								"easy",
								"moderate",
								"moderate",
								"difficult",
								"difficult",
								"difficult",
								"hardcore",
								"hardcore"
							];
//choose difficulty and set value
_difficulty = selectRandom _PossibleDifficulty;

switch (_difficulty) do
{
	case "easy":
	{
		_AICount = (4 + (round (random 4)));
		_crate_weapons 		= (4 + (round (random 2)));
		_crate_items 		= (3 + (round (random 3)));
		_crate_backpacks 	= (1 + (round (random 1)));
	};

	case "moderate":
	{
		_AICount = (4 + (round (random 6)));
		_crate_weapons 		= (6 + (round (random 3)));
		_crate_items 		= (6 + (round (random 3)));
		_crate_backpacks 	= (2 + (round (random 1)));
	};

	case "difficult":
	{
		_AICount = (6 + (round (random 6)));
		_crate_weapons 		= (8 + (round (random 3)));
		_crate_items 		= (8 + (round (random 4)));
		_crate_backpacks 	= (3 + (round (random 1)));
	};

	//case "hardcore":
	default
	{
		_AICount = (8 + (round (random 8)));
		_crate_weapons 		= (10 + (round (random 6)));
		_crate_items 		= (15 + (round (random 8)));
		_crate_backpacks 	= (4 + (round (random 1)));
	};
};

_msgStart = ['#FFFF00',"A C-192 crashed, rebels trying to steal the transported warhead."];

_crate_weapon_list	= ["arifle_SDAR_F","arifle_MX_GL_Black_F","MMG_01_hex_F","MMG_01_tan_F","MMG_02_black_F","MMG_02_camo_F","MMG_02_sand_F","hgun_PDW2000_F","SMG_01_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F"];
_crate_item_list	= ["H_HelmetLeaderO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetLeaderO_oucamo","H_HelmetLeaderO_oucamo","U_B_survival_uniform","U_B_Wetsuit","U_O_Wetsuit","U_I_Wetsuit","H_HelmetB_camo","H_HelmetSpecB","H_HelmetSpecO_blk","Exile_Item_EMRE","Exile_Item_InstantCoffee","Exile_Item_PowerDrink","Exile_Item_InstaDoc"];


_AISpawnLocations =

[
	// make spawnpoints positioned relative to centre point.
	[(_pos select 0)+3.74,(_pos select 1)+14.65,(_pos select 2)+0.1],
	[(_pos select 0)-10.23,(_pos select 1)+14.13,(_pos select 2)+0.1],
	[(_pos select 0)-20.26,(_pos select 1)+9.19,(_pos select 2)+0.1],
	[(_pos select 0)+13.36,(_pos select 1)+7.71,(_pos select 2)+0.1],
	[(_pos select 0)+22.04,(_pos select 1)-4.32,(_pos select 2)+0.1],
	[(_pos select 0)+20.08,(_pos select 1)-20.84,(_pos select 2)+0.1]

];

// add Ai group
_group =
[
	_AISpawnLocations,		// Position AI 
	_AICount,				// Number of AI
	_difficulty,			// "random","hardcore","difficult","moderate", or "easy"
	"assault", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side 					// "bandit","hero", etc.
] call DMS_fnc_SpawnAIGroup_MultiPos;

// add vehicle patrol
_veh =
[
	[
		[(_pos select 0)+50,(_pos select 1)+50,0]
	],
	_group,
	"assault",
	_difficulty,
	_side
] call DMS_fnc_SpawnAIVehicle;

// prevents AI's aiming from being distracted by its shooting, moving, turning, reloading, hit, injury, fatigue, suppression or concealed/lost target
{
    _x disableAI "AIMINGERROR";
} forEach (units _group);


// Set AI Behaviour to Stealth
{
    _x setBehaviour "STEALTH";
} forEach (units _group);

// Add Smoke
_smoke = createVehicle ["test_EmptyObjectForSmoke",[(_pos select 0) - 11, (_pos select 1) -11,-0.2],[], 0];
// Add Fire
_fire = createVehicle ["test_EmptyObjectForFireBig",[(_pos select 0) - 11.1, (_pos select 1) -11.1,-0.2],[], 0];

// add static guns
_staticGuns =
[
	[
		// make statically positioned relative to centre point.
		[(_pos select 0)-7.93,(_pos select 1)+7.63,(_pos select 2)+0.1],
		[(_pos select 0)-21.34,(_pos select 1)+3.84,(_pos select 2)+0.1],
		[(_pos select 0)+2.89,(_pos select 1)-10.87,(_pos select 2)+0.1], 
		[(_pos select 0)+4.46,(_pos select 1)+1.65,(_pos select 2)+0.1]
	],
	_group,
	"assault",
	"static",
	"bandit"
] call DMS_fnc_SpawnAIStaticMG;


// Create Buildings - use seperate file as found in the mercbase mission
_baseObjs =
[
	"gogs_warhead_objects",
	_pos
] call DMS_fnc_ImportFromM3E_3DEN;

// If hardcore give pincoded vehicle, if not give non persistent
if (_difficulty isEqualTo "hardcore") then
{
	_pinCode = (1000 +(round (random 8999)));
	_vehicle = ["Exile_Car_HEMMT",[(_pos select 0) -50, (_pos select 1) -50],_pinCode] call DMS_fnc_SpawnPersistentVehicle;
	_msgWIN = ['#0080ff',format ["The warhead has been secured and the rebels have been evicted, entry code for the HEMMT is %1...",_pinCode]];
}
else
{
	_vehicle = ["Exile_Car_HEMMT",[(_pos select 0)-30,(_pos select 1)+0,0],[], 0, "CAN_COLLIDE"] call DMS_fnc_SpawnNonPersistentVehicle;
	_msgWIN = ['#0080ff',"The warhead has been secured and the rebels have been evicted!"];
};

// Create Crate type
_crate1 = ["Box_NATO_Wps_F",_pos] call DMS_fnc_SpawnCrate;


// setup crate iteself with items
_crate_loot_values1 =
[
	[_crate_weapons,_crate_weapon_list],		// Weapons
	[_crate_items,_crate_item_list],			// Items + selection list
	_crate_backpacks 							// Backpacks
];


// Define mission-spawned AI Units
_missionAIUnits =
[
	_group 		// We only spawned the single group for this mission
];

// Define mission-spawned objects and loot values
_missionObjs =
[
	_staticGuns++_baseObjs+[_veh]+[_smoke]+[_fire],	// armed AI vehicle, base objects, and static guns
	[_vehicle],								//this is prize vehicle [_smoke],
	[[_crate1,_crate_loot_values1]]			//this is prize crate
];

// define start messages in difficulty choice

// Define Mission Win message defined in persistent choice

// Define Mission Lose message
_msgLOSE = ['#FF0000',"The rebels have escaped and are on their way to Molos Airfield!..."];

// Define mission name (for map marker and logging)
_missionName = "Warhead";

// Create Markers
_markers =
[
	_pos,
	_missionName,
	_difficulty
] call DMS_fnc_CreateMarker;

// Record time here (for logging purposes, otherwise you could just put "diag_tickTime" into the "DMS_AddMissionToMonitor" parameters directly)
_time = diag_tickTime;

// Parse and add mission info to missions monitor
_added =
[
	_pos,
	[
		[
			"kill",
			_group
		],
		[
			"playerNear",
			[_pos,DMS_playerNearRadius]
		]
	],
	[
		_time,
		(DMS_MissionTimeOut select 0) + random((DMS_MissionTimeOut select 1) - (DMS_MissionTimeOut select 0))
	],
	_missionAIUnits,
	_missionObjs,
	[_missionName,_msgWIN,_msgLOSE],
	_markers,
	_side,
	_difficulty,
	[]
] call DMS_fnc_AddMissionToMonitor;

// Check to see if it was added correctly, otherwise delete the stuff
if !(_added) exitWith
{
	diag_log format ["DMS ERROR :: Attempt to set up mission %1 with invalid parameters for DMS_AddMissionToMonitor! Deleting mission objects and resetting DMS_MissionCount.",_missionName];

	// Delete AI units and the crate. I could do it in one line but I just made a little function that should work for every mission (provided you defined everything correctly)
	_cleanup = [];
	{
		_cleanup pushBack _x;
	} forEach _missionAIUnits;

	_cleanup pushBack ((_missionObjs select 0)+(_missionObjs select 1));

	{
		_cleanup pushBack (_x select 0);
	} foreach (_missionObjs select 2);

	_cleanup call DMS_fnc_CleanUp;


	// Delete the markers directly
	{deleteMarker _x;} forEach _markers;


	// Reset the mission count
	DMS_MissionCount = DMS_MissionCount - 1;
};


// Notify players
[_missionName,_msgStart] call DMS_fnc_BroadcastMissionStatus;



if (DMS_DEBUG) then
{
	(format ["MISSION: (%1) :: Mission #%2 started at %3 with %4 AI units and %5 difficulty at time %6",_missionName,_num,_pos,_AICount,_difficulty,_time]) call DMS_fnc_DebugLog;
};