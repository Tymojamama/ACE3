/**
 * fn_handleDisplayEffects.sqf
 * @Descr: displays visual effects to user
 * @Author: Glowbal
 *
 * @Arguments: []
 * @Return:
 * @PublicAPI: false
 */

#include "script_component.hpp"

if (!hasInterface) exitwith{};
45 cutRsc [QEGVAR(gui,ScreenEffectsBlack),"PLAIN"];

FUNC(hb_effect) = {
    _heartRate = _this select 0;
    if (_heartRate < 0.1) exitwith {};
    _hbSoundsFast = ["ACE_heartbeat_fast_1", "ACE_heartbeat_fast_2", "ACE_heartbeat_fast_3", "ACE_heartbeat_norm_1", "ACE_heartbeat_norm_2"];
    _hbSoundsNorm = ["ACE_heartbeat_norm_1", "ACE_heartbeat_norm_2"];
    _hbSoundsSlow = ["ACE_heartbeat_slow_1", "ACE_heartbeat_slow_2", "ACE_heartbeat_norm_1", "ACE_heartbeat_norm_2"];
    if (isnil QGVAR(playingHeartBeatSound)) then {
        GVAR(playingHeartBeatSound) = false;
    };
    if (GVAR(playingHeartBeatSound)) exitwith {};
    GVAR(playingHeartBeatSound) = true;

    _sleep = 60 / _heartRate;
    if (_heartRate < 60) then {
        _sound = _hbSoundsSlow select (random((count _hbSoundsSlow) -1));
        playSound _sound;

        [{
            if (time - ((_this select 0) select 1) < ((_this select 0) select 0)) exitwith {};

            GVAR(playingHeartBeatSound) = false;
            [(_this select 1)] call cba_fnc_removePerFrameHandler;
        }, _sleep, [_sleep, time] ] call CBA_fnc_addPerFrameHandler;
    } else {
        if (_heartRate > 120) then {
            _sound = _hbSoundsFast select (random((count _hbSoundsFast) -1));
            playSound _sound;
            [{
                if (time - ((_this select 0) select 1) < ((_this select 0) select 0)) exitwith {};

                GVAR(playingHeartBeatSound) = false;
                [(_this select 1)] call cba_fnc_removePerFrameHandler;
            }, _sleep, [_sleep, time] ] call CBA_fnc_addPerFrameHandler;
        };
    };
};


GVAR(BloodLevel_CC) = ppEffectCreate ["ColorCorrections", 4208];
GVAR(BloodLevel_CC) ppEffectForceInNVG True;
GVAR(BloodLevel_CC) ppEffectAdjust [1,1,0, [0,0,0,0], [1,1,1,1], [0.2,0.2,0.2,0]];
GVAR(BloodLevel_CC) ppEffectCommit 0;


[{
    private ["_unit","_bloodLoss"];
    _unit = ACE_player;
    if ([_unit] call EFUNC(common,isAwake)) then {
        _bloodLoss = _unit call FUNC(getBloodLoss);
        if (_bloodLoss >0) then {
            [_bloodLoss] call EFUNC(gui,effectBleeding);
        };

         // Blood Level Effect
        _currentBlood = _unit getVariable [QGVAR(bloodVolume), 100];
        if (_currentBlood > 99) then {
            GVAR(BloodLevel_CC) ppEffectEnable False;
        } else {
            GVAR(BloodLevel_CC) ppEffectEnable True;
            GVAR(BloodLevel_CC) ppEffectAdjust [1, 1, 0, [0.0, 0.0, 0.0, 0.0], [1, 1, 1,_currentBlood], [0.2, 0.2, 0.2, 0]];
            GVAR(BloodLevel_CC) ppEffectCommit 0;
        };

        [{
            [((_this select 0) select 0 getvariable[QGVAR(amountOfPain), 0])] call EFUNC(gui,effectPain);
            [(_this select 1)] call cba_fnc_removePerFrameHandler;
        }, 0.25, [_unit] ] call CBA_fnc_addPerFrameHandler;

        [(_unit getvariable[QGVAR(heartRate), 70])] call FUNC(hb_effect);
        ["medicalEffectsLoop", [_unit]] call ace_common_fnc_localEvent
    };
 } , 0.5, [] ] call CBA_fnc_addPerFrameHandler;
