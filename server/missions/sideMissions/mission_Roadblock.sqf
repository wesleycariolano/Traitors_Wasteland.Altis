// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright � 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_Roadblock.sqf
//	@file Author: JoSchaap, AgentRev, LouD

if (!isServer) exitwith {};
#include "sideMissionDefines.sqf";

private [ "_box1", "_barGate", "_bunker1", "_bunker2", "_obj1", "_obj2", "_drop_item", "_drugpilerandomizer", "_drugpile", "_cashamountrandomizer", "_cashpilerandomizer", "_cash", "_cashamount", "_cashpile", "_cash1"];

_setupVars =
{
	_missionType = "Falsa Blitz";
	_locationsArray = RoadblockMissionMarkers;
};

_setupObjects =
{
	_missionPos = markerPos _missionLocation;
	_markerDir = markerDir _missionLocation;
	
	//delete existing base parts and vehicles at location
	_baseToDelete = nearestObjects [_missionPos, ["All"], 25];
	{ deleteVehicle _x } forEach _baseToDelete; 	
	
	_bargate = createVehicle ["Land_BarGate_F", _missionPos, [], 0, "NONE"];
	_bargate setDir _markerDir;
	_bunker1 = createVehicle ["Land_BagBunker_Small_F", _bargate modelToWorld [6.5,-2,-4.1], [], 0, "NONE"];
	_obj1 = createVehicle ["I_GMG_01_high_F", _bargate modelToWorld [6.5,-2,-4.1], [], 0, "NONE"];
	_bunker1 setDir _markerDir;
	_bunker2 = createVehicle ["Land_BagBunker_Small_F", _bargate modelToWorld [-8,-2,-4.1], [], 0, "NONE"];
	_obj2 = createVehicle ["I_GMG_01_high_F", _bargate modelToWorld [-8,-2,-4.1], [], 0, "NONE"];
	_bunker2 setDir _markerDir;

	{ _x setVariable ["R3F_LOG_disabled", true, true] } forEach [_obj1, _obj2, _barGate, _bunker1, _bunker2];  
	{ _x setVariable ["allowDamage", false, true] } forEach [_obj1, _obj2, _barGate, _bunker1, _bunker2];

	_aiGroup = createGroup CIVILIAN;
	[_aiGroup,_missionPos,8,12] call createCustomGroup;
	
	_missionHintText = format ["Traficantes estão se passando por policiais e fizeram uma <t color='%1'>Blitz Falsa,</t> eles estão armados e com drogas! Vão lá e acabem com essa baderna", sideMissionColor]
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;

_failedExec =
{
	// Mission failed
	
	{ deleteVehicle _x } forEach [_barGate, _bunker1, _bunker2, _obj1, _obj2];
	
};

_drop_item = 
{
	private["_item", "_pos"];
	_item = _this select 0;
	_pos = _this select 1;

	if (isNil "_item" || {typeName _item != typeName [] || {count(_item) != 2}}) exitWith {};
	if (isNil "_pos" || {typeName _pos != typeName [] || {count(_pos) != 3}}) exitWith {};

	private["_id", "_class"];
	_id = _item select 0;
	_class = _item select 1;

	private["_obj"];
	_obj = createVehicle [_class, _pos, [], 5, "None"];
	_obj setPos ([_pos, [[2 + random 3,0,0], random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
	_obj setVariable ["mf_item_id", _id, true];
};

_successExec =
{
	// Mission completed
	_randomBox = ["mission_HVLaunchers","Launchers_Tier_2"] call BIS_fnc_selectRandom;
	_box1 = createVehicle ["Box_NATO_Wps_F", _missionPos, [], 5, "None"];
	_box1 setDir random 360;
	[_box1, _randomBox] call fn_refillbox;
	{ _x setVariable ["R3F_LOG_disabled", false, true] } forEach [_obj1, _obj2, _barGate, _bunker1, _bunker2];
	//{ deleteVehicle _x } forEach [_barGate, _bunker1, _bunker2];
	{ _x setVariable ["allowDamage", true, true] } forEach [_obj1, _obj2, _barGate, _bunker1, _bunker2];
	
	_drugpilerandomizer = [4,8];
	_drugpile = _drugpilerandomizer call BIS_fnc_SelectRandom;
	
	for "_i" from 1 to _drugpile do 
	{
	  private["_item"];
	  _item = [
	          ["lsd", "Land_WaterPurificationTablets_F"],
			  ["lsd", "Land_WaterPurificationTablets_F"],
	          ["marijuana", "Land_VitaminBottle_F"],
			  ["marijuana", "Land_VitaminBottle_F"],
	          ["cocaine","Land_PowderedMilk_F"],
	          ["heroin", "Land_PainKillers_F"]
	        ] call BIS_fnc_selectRandom;
	  [_item, _lastPos] call _drop_item;
	};

	_cashamountrandomizer = [5000,5000,5000];
	_cashpilerandomizer = [2,4];
		
	_cash = "cmoney";
	_cashamount = _cashamountrandomizer call BIS_fnc_SelectRandom;
	_cashpile = _cashpilerandomizer call BIS_fnc_SelectRandom;
	
	for "_i" from 1 to _cashpile do
	{
		_cash1 = createVehicle ["Land_Money_F",[(_lastPos select 0), (_lastPos select 1) - 5,0],[], 0, "NONE"];
		_cash1 setPos ([_lastPos, [[2 + random 3,0,0], random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
		_cash1 setDir random 360;
		_cash1 setVariable [_cash, _cashamount, true];
		_cash1 setVariable ["owner", "world", true];
	};
  
	_successHintMessage = format ["                        Falsa Blitz desmantelada, traficantes eliminados, drogas e armas apreendidas!"];
};

_this call sideMissionProcessor;