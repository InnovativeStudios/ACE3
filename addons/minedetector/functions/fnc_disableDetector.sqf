/*
 * Author: Glowbal
 * Disables the mine detector
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: detecter type <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [UNIT, DETECTOR_CLASS_NAME] call ace_minedetector_fnc_disableDetector
 *
 * Public: No
 */

#include "script_component.hpp"

params ["_unit", "_detectorType"];

_unit setvariable [format[QGVAR(enable_%1), _detectorType], false];

["minedetector_disabled", [_unit, _detectorType]] call EFUNC(common,localEvent);
