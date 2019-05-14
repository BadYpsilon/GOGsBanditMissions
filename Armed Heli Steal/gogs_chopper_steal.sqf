/*
	Armed Chopper Steal Mission with new difficulty selection system
	Hardcore now gives persistent vehicle
	easy/mod/difficult/hardcore - reworked by [CiC]red_ned http://cic-gaming.co.uk
	based on work by Defent and eraser1
*/

private ["_num", "_side", "_pos", "_OK", "_difficulty", "_AICount", "_group", "_group2", "_AssaultGearSet", "_type", "_launcher", "_staticGuns", "_crate1", "_vehicle", "_pinCode", "_class", "_veh", "_veh2", "_crate_loot_values1", "_missionAIUnits", "_missionObjs", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_markers", "_time", "_added", "_cleanup", "_baseObjs", "_crate_weapons", "_crate_weapon_list", "_crate_items", "_crate_item_list", "_crate_backpacks", "_PossibleDifficulty", "_chopper", "_PossibleChopper"];

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
		[10,DMS_WaterNearBlacklist,0.999,DMS_SpawnZoneNearBlacklist,DMS_TraderZoneNearBlacklist,DMS_MissionNearBlacklist,DMS_PlayerNearBlacklist,DMS_TerritoryNearBlacklist,DMS_ThrottleBlacklists],
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
	diag_log format ["DMS ERROR :: Called MISSION gogs_armed_chopper.sqf with invalid parameters: %1",_this];
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
		_AICount = (8 + (round (random 4)));
		_crate_weapons 		= (4 + (round (random 2)));
		_crate_items 		= (3 + (round (random 3)));
		_crate_backpacks 	= (1 + (round (random 1)));
	};

	case "moderate":
	{
		_AICount = (8 + (round (random 8)));
		_crate_weapons 		= (6 + (round (random 3)));
		_crate_items 		= (6 + (round (random 3)));
		_crate_backpacks 	= (2 + (round (random 1)));
	};

	case "difficult":
	{
		_AICount = (12 + (round (random 6)));
		_crate_weapons 		= (8 + (round (random 3)));
		_crate_items 		= (8 + (round (random 4)));
		_crate_backpacks 	= (3 + (round (random 1)));
	};

	//case "hardcore":
	default
	{
		_AICount = (18 + (round (random 8)));
		_crate_weapons 		= (10 + (round (random 6)));
		_crate_items 		= (15 + (round (random 8)));
		_crate_backpacks 	= (4 + (round (random 1)));
	};
};

_msgStart = ['#FFFF00',format["A armed heli has landed in a %1 guarded rebel base. Go kill them and steal the heli!",_difficulty]];


_crate_weapon_list	= ["arifle_SDAR_F","arifle_MX_GL_Black_F","MMG_01_hex_F","MMG_01_tan_F","MMG_02_black_F","MMG_02_camo_F","MMG_02_sand_F","hgun_PDW2000_F","SMG_01_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F"];
_crate_item_list	= ["H_HelmetLeaderO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetLeaderO_oucamo","H_HelmetLeaderO_oucamo","U_B_survival_uniform","U_B_Wetsuit","U_O_Wetsuit","U_I_Wetsuit","H_HelmetB_camo","H_HelmetSpecB","H_HelmetSpecO_blk","Exile_Item_EMRE","Exile_Item_InstantCoffee","Exile_Item_PowerDrink","Exile_Item_InstaDoc"];


_AISpawnLocations =

[
	// make spawnpoints positioned relative to centre point
	[(_pos select 0)+5.42,(_pos select 1)+17.33,(_pos select 2)+0.05],
	[(_pos select 0)+9.95,(_pos select 1)+15.64,(_pos select 2)+0.05],
	[(_pos select 0)+40.87,(_pos select 1)+37.29,(_pos select 2)+0.05],
	[(_pos select 0)+44.35,(_pos select 1)+45.74,(_pos select 2)+0.05],
	[(_pos select 0)+34.48,(_pos select 1)+27.21,(_pos select 2)+0.05],
	[(_pos select 0)+31.66,(_pos select 1)+41.24,(_pos select 2)+0.05],
	[(_pos select 0)+110.54,(_pos select 1)-68.86,(_pos select 2)+0.05],
	[(_pos select 0)+82.52,(_pos select 1)-95.03,(_pos select 2)+0.05],
	[(_pos select 0)+96.51,(_pos select 1)-75.30,(_pos select 2)+0.05],
	[(_pos select 0)-33.37,(_pos select 1)-93.23,(_pos select 2)+0.05],
	[(_pos select 0)-84.91,(_pos select 1)-99.45,(_pos select 2)+0.05],
	[(_pos select 0)-101.25,(_pos select 1)+52.48,(_pos select 2)+0.05]
];


_AISniperSpawnLocations =

[
	// make spawnpoints positioned relative to centre point
	[(_pos select 0)+0.76,(_pos select 1)+55.15,(_pos select 2)+0.05],
	[(_pos select 0)+56.11,(_pos select 1)+96.04,(_pos select 2)+0.05],
	[(_pos select 0)+123.02,(_pos select 1)+36.74,(_pos select 2)+0.05],
	[(_pos select 0)+159.65,(_pos select 1)-82.16,(_pos select 2)+0.05],
	[(_pos select 0)+100.51,(_pos select 1)-194.20,(_pos select 2)+0.05],
	[(_pos select 0)-52.10,(_pos select 1)-210.23,(_pos select 2)+0.05],
	[(_pos select 0)-159.18,(_pos select 1)-121.89,(_pos select 2)+0.05],
	[(_pos select 0)-198.90,(_pos select 1)+36.58,(_pos select 2)+0.05],
	[(_pos select 0)-120.98,(_pos select 1)+116.62,(_pos select 2)+0.05],
	[(_pos select 0)-25.77,(_pos select 1)+129.15,(_pos select 2)+0.05]
];

// Custom gearset for the Assault AI
_AssaultGearSet =
[
    "arifle_SPAR_03_blk_F",
    ["muzzle_snds_B","optic_Hamr","bipod_02_F_blk"],
    [["20Rnd_762x51_Mag",8],["Exile_Item_InstaDoc",1]],
    "",
    [],
    ["Rangefinder","ItemGPS","NVGogglesB_grn_F","G_Balaclava_TI_G_tna_F"],
    "",
    "H_HelmetB_TI_tna_F",
    "U_B_CTRG_Soldier_F",
    "V_PlateCarrierGL_rgr",
    "B_TacticalPack_rgr"
];

// add Ai  Assault group
_group =
[
	_AISpawnLocations,		// Position AI 
	_AICount,				// Number of AI
	_difficulty,			// "random","hardcore","difficult","moderate", or "easy"
	"custom", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side, 					// "bandit","hero", etc.
	_AssaultGearSet			// Custom gearset
] call DMS_fnc_SpawnAIGroup_MultiPos;

{
    _x disableAI "AIMINGERROR";
} forEach (units _group);

{
    _x setBehaviour "STEALTH";
} forEach (units _group);

// Custom gearset for the Sniper AI
_SniperGearSet =
[
    "srifle_DMR_02_camo_F",
    ["muzzle_snds_338_green","optic_Nightstalker","bipod_01_F_khk"],
    [["10Rnd_338_Mag",8],["Exile_Item_InstaDoc",1]],
    "",
    [],
    ["Rangefinder","ItemGPS","NVGogglesB_grn_F","G_Balaclava_TI_G_tna_F"],
    "",
    "H_HelmetB_TI_tna_F",
    "U_O_FullGhillie_sard",
    "V_PlateCarrierGL_rgr",
    "B_TacticalPack_rgr"
];

// add Ai Sniper group
_group2 =
[
	_AISniperSpawnLocations,// Position AI 
	_AICount,				// Number of AI
	_difficulty,			// "random","hardcore","difficult","moderate", or "easy"
	"custom", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side, 					// "bandit","hero", etc.
	_SniperGearSet			// Custom gearset
] call DMS_fnc_SpawnAIGroup_MultiPos;

{
    _x disableAI "AIMINGERROR";
} forEach (units _group2);

{
    _x setBehaviour "STEALTH";
} forEach (units _group2);


// add vehicle patrol
_veh =
[
	[
		[(_pos select 0)+70,(_pos select 1)+70,0.5]
	],
	_group,
	"assault",
	_difficulty,
	_side
] call DMS_fnc_SpawnAIVehicle;

// add vehicle antiair
_veh2 =
[
	[
		[(_pos select 0)+22.969,(_pos select 1)-0.124,0.5]
	],
	_group,
	"assault",
	_difficulty,
	_side,
	"O_APC_Tracked_02_AA_F"
] call DMS_fnc_SpawnAIVehicle;


// add static guns
_staticGuns =
[
	[
		// make statically positioned relative to centre point, keep static as they are on top of building
		
		[(_pos select 0)-11.50,(_pos select 1)+11.64,(_pos select 2)+0.05],
		[(_pos select 0)-4.99,(_pos select 1)+26.69,(_pos select 2)+2.30],
		[(_pos select 0)+15.48,(_pos select 1)+27.83,(_pos select 2)+4.35],
		[(_pos select 0)+14.19,(_pos select 1)-14.81,(_pos select 2)+2.30],
		[(_pos select 0)-7.09,(_pos select 1)-18.34,(_pos select 2)+4.35]
	],
	_group,
	"assault",
	"static",
	"bandit"
] call DMS_fnc_SpawnAIStaticMG;

// Create Buildings - use seperate file as found in the mercbase mission
_baseObjs =
[
	"gogs_chopper_steal_objects",
	_pos
] call DMS_fnc_ImportFromM3E_3DEN;


//A list of possible chopper add more of one choppers to weight it towards that
_PossibleChopper		= 	[
								"B_Heli_Light_01_dynamicLoadout_F",
								"B_Heli_Light_01_dynamicLoadout_F",
								"B_Heli_Transport_03_F",
								"B_Heli_Transport_03_F",
								"B_Heli_Transport_01_F",
								"B_Heli_Transport_01_F",
								"B_Heli_Transport_01_F",
								"I_Heli_light_03_dynamicLoadout_F",
								"I_Heli_light_03_dynamicLoadout_F"
							];
//choose difficulty and set value
_chopper = selectRandom _PossibleChopper;


// If hardcore give pincoded vehicle, if not give non persistent
if (_difficulty isEqualTo "hardcore") then
{
	_pinCode = (1000 +(round (random 8999)));
	_vehicle = [_chopper,[(_pos select 0)+7.75, (_pos select 1)+2.63],_pinCode] call DMS_fnc_SpawnPersistentVehicle;
	_msgWIN = ['#0080ff',format ["Convicts killed everyone and made off with the heli, entry code is %1...",_pinCode]];
}
else
{
	_vehicle = [_chopper,[(_pos select 0)+7.75,(_pos select 1)+2.63],[], 0, "CAN_COLLIDE"] call DMS_fnc_SpawnNonPersistentVehicle;
	_msgWIN = ['#0080ff',"Convicts killed everyone and made off with the heli."];
};

// Create Crate
_crate = ["Box_NATO_AmmoOrd_F",[(_pos select 0)-8.88,(_pos select 1)-7.12]] call DMS_fnc_SpawnCrate;

// Pink Crate ;)
_crate setObjectTextureGlobal [0,"#(rgb,8,8,3)color(1,0.08,0.57,1)"];
_crate setObjectTextureGlobal [1,"#(rgb,8,8,3)color(1,0.08,0.57,1)"];


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
	_staticGuns+_baseObjs+[_veh]+[_veh2],	// armed AI vehicle, base objects, and static guns
	[_vehicle],								//this is prize vehicle
	[[_crate,_crate_loot_values1]]			//this is prize crate
];

// define start messages in difficulty choice

// Define Mission Win message defined in persistent choice

// Define Mission Lose message
_msgLOSE = ['#FF0000',"The Cargo Tower has been destroyed and the rebels have escaped to the Marine Base..."];

// Define mission name (for map marker and logging)
_missionName = "Armed Heli Steal";

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
