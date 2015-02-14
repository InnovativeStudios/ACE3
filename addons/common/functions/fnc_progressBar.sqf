/*
* Author: commy2, Glowbal, PabstMirror
*
* Draw progress bar and execute given function if succesful.
* Finish/Failure/Conditional are all passed [_args, _elapsedTime, _totalTime, _errorCode]
*
* Argument:
* 0: NUMBER - Total Time (in game "time" seconds)
* 1: ARRAY - Arguments, passed to condition, fail and finish
* 2: CODE or STRING - On Finish: Code called or STRING raised as event.
* 3: CODE or STRING - On Failure: Code called or STRING raised as event.
* 4: STRING - (Optional) Localized Title
* 5: CODE - (Optional) Code to check each frame
* 6: ARRAY - (Optional) Exceptions for checking EGVAR(common,canInteract)
*
* Return value:
* Nothing
*/

#include "script_component.hpp"

PARAMS_4(_totalTime,_args,_onFinish,_onFail);
DEFAULT_PARAM(4,_localizedTitle,"");
DEFAULT_PARAM(5,_condition,{true});
DEFAULT_PARAM(6,_exceptions,[]);
private ["_player", "_perFrameFunction"];

_player = ACE_player;

//Open Dialog and set the title
closeDialog 0;
createDialog QGVAR(ProgressBar_Dialog);
(uiNamespace getVariable QGVAR(ctrlProgressBarTitle)) ctrlSetText _localizedTitle;

_perFrameFunction = {
  PARAMS_2(_parameters,_pfhID);
  EXPLODE_8_PVT(_parameters,_args,_onFinish,_onFail,_condition,_player,_startTime,_totalTime,_exceptions);
  private ["_elapsedTime", "_errorCode"];

  _elapsedTime = time - _startTime;
  _errorCode = -1;

  if (isNull (uiNamespace getVariable [QGVAR(ctrlProgressBar), controlNull])) then {
    _errorCode = 1;
  } else {
    if (ACE_player != _player) then {
      _errorCode = 2;
    } else {
      if (!([_args, _elapsedTime, _totalTime, _errorCode] call _condition)) then {
        _errorCode = 3;
      } else {
        if (!(_exceptions call EGVAR(common,canInteract))) then {
          _errorCode = 4;
        } else {
          if (_elapsedTime >= _totalTime) then {
            _errorCode = 0;
          };
        };
      };
    };
  };

  if (_errorCode != -1) then {
    //Error or Success, close dialog and remove PFEH
    closeDialog 0;
    [_pfhID] call CBA_fnc_removePerFrameHandler;

    if (_errorCode == 0) then {
      if ((typeName _onFinish) == (typeName "")) then {
        [_onFinish, [_args, _elapsedTime, _totalTime, _errorCode]] call FUNC(localEvent);
      } else {
        [_args, _elapsedTime, _totalTime, _errorCode] call _onFinish;
      };
    } else {
      if ((typeName _onFail) == (typeName "")) then {
        [_onFail, [_args, _elapsedTime, _totalTime, _errorCode]] call FUNC(localEvent);
      } else {
        [_args, _elapsedTime, _totalTime, _errorCode] call _onFail;
      };
    };
  } else {
    //Update Progress Bar (ratio of elepased:total)
    (uiNamespace getVariable QGVAR(ctrlProgressBar)) progressSetPosition (_elapsedTime / _totalTime);
  };
};

[_perFrameFunction, 0, [_args, _onFinish, _onFail, _condition, _player, time, _totalTime, _exceptions]] call CBA_fnc_addPerFrameHandler;
