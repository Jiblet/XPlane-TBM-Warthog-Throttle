-- Originally from https://forums.x-pilot.com/forums/topic/14756-thrustmaster-hotas-flywithlua-script-for-tbm-pedestal/

--For Jiblet's Warthog: 
-- Little grey lever = _joy_AXIS_use52 9
-- left throttle lever = _joy_AXIS_use54 9
-- right throttle lever = _joy_AXIS_use53 9

if PLANE_ICAO == "TBM9" then
	-- Set up the axes - this will vary per device per computer. need to dig in the prefs files to find the right values
	local small_throttle_axis_number = 52
	local mixture_lever_axis_number = 54
	local flap_up_switch_number = 181
	local flap_mid_switch_number = 267
	local flap_down_switch_number = 182

	dataref("emergency_override_axis", "sim/joystick/joystick_axis_values", "readonly", small_throttle_axis_number)
	dataref("throttle_notch_axis", "sim/joystick/joystick_axis_values", "readonly", mixture_lever_axis_number)
	dataref("emerg_power", "tbm900/controls/engine/emerg_power", "writable")
	dataref("flaps_pos", "sim/flightmodel/controls/flaprqst", "readonly")

	--Handle setting up the left throttle as the TBM900 has an 'h' shaped throttle axis.
	--notch numbers
	local notch_high = 1.00 --these are points on my throttle where I have 3D printed detents
	local notch_mid = 0.82
	local notch_low = 0.64

	local lastNotch = throttle_notch_axis
	function handleThrottleNotches()
		if (lastNotch < notch_high and throttle_notch_axis >= notch_high) or
			(lastNotch < notch_mid and throttle_notch_axis >= notch_mid) or
			(lastNotch < notch_low and throttle_notch_axis >= notch_low) then
			command_once("sim/engines/mixture_down")
		elseif (lastNotch >= notch_high and throttle_notch_axis < notch_high) or
			(lastNotch >= notch_mid and throttle_notch_axis < notch_mid) or
			(lastNotch >= notch_low and throttle_notch_axis < notch_low) then
			command_once("sim/engines/mixture_up")
		end
		lastNotch = throttle_notch_axis
	end

	-- Handle flaps to set all 3 positions - could be useful for many other aircraft!
	function setTbmFlapsUP()
		posref = XPLMFindDataRef("sim/flightmodel/controls/flaprqst")
		XPLMSetDataf(posref, 0.0)
	end

	function setTbmFlapsTO()
		posref = XPLMFindDataRef("sim/flightmodel/controls/flaprqst")
		XPLMSetDataf(posref, 0.5)
	end

	function setTbmFlapsLDG()
		posref = XPLMFindDataRef("sim/flightmodel/controls/flaprqst")
		XPLMSetDataf(posref, 1.0)
	end

	create_command("fwl/tbm900/controls/flaps_up", "Flaps UP", "", "", "setTbmFlapsUP()")
	create_command("fwl/tbm900/controls/flaps_to", "Flaps TO", "", "", "setTbmFlapsTO()")
	create_command("fwl/tbm900/controls/flaps_ldg", "Flaps LDG", "", "", "setTbmFlapsLDG()")

	--This if() is likely redundant now but I'm keeping it
	if PLANE_ICAO == "TBM9" then
		set_button_assignment(flap_up_switch_number,"fwl/tbm900/controls/flaps_up")
		set_button_assignment(flap_mid_switch_number,"fwl/tbm900/controls/flaps_to")
		set_button_assignment(flap_down_switch_number,"fwl/tbm900/controls/flaps_ldg")
		do_every_frame("emerg_power = 1 - emergency_override_axis")
		do_every_frame("handleThrottleNotches()")
	end
end