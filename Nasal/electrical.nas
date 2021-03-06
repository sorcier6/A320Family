# Electrical system for A320 by Joshua Davidson (it0uchpods/411).

#############
# Init Vars #
#############

var ac_volt_std = 115;
var ac_volt_min = 110;
var dc_volt_std = 28;
var dc_volt_min = 25;

var elec_init = func {
	setprop("/controls/switches/annun-test", 0);
	setprop("/controls/electrical/switches/galley", 0);
	setprop("/controls/electrical/switches/idg1", 0);
	setprop("/controls/electrical/switches/idg2", 0);
	setprop("/controls/electrical/switches/gen1", 0);
	setprop("/controls/electrical/switches/gen2", 0);
	setprop("/controls/electrical/switches/gen-apu", 0);
	setprop("/controls/electrical/switches/gen-ext", 0);
	setprop("/controls/electrical/switches/apu-ext-crosstie", 1);
	setprop("/controls/electrical/switches/ac-ess-feed", 1);
	setprop("/controls/electrical/switches/battery1", 0);
	setprop("/controls/electrical/switches/battery2", 0);
	setprop("/systems/electrical/battery1-volts", 25.9);
	setprop("/systems/electrical/battery2-volts", 25.9);
	setprop("/systems/electrical/bus/dc1", 0);
	setprop("/systems/electrical/bus/dc2", 0);
	setprop("/systems/electrical/bus/dc-ess", 0);
	setprop("/systems/electrical/bus/ac1", 0);
	setprop("/systems/electrical/bus/ac2", 0);
	setprop("/systems/electrical/bus/ac-ess", 0);
	setprop("systems/electrical/on", 0);
	setprop("/controls/electrical/xtie/xtieL", 0);
	setprop("/controls/electrical/xtie/xtieR", 0);
	# Below are standard FG Electrical stuff to keep things working when the plane is powered
    setprop("/systems/electrical/outputs/adf", 0);
    setprop("/systems/electrical/outputs/audio-panel", 0);
    setprop("/systems/electrical/outputs/audio-panel[1]", 0);
    setprop("/systems/electrical/outputs/autopilot", 0);
    setprop("/systems/electrical/outputs/avionics-fan", 0);
    setprop("/systems/electrical/outputs/beacon", 0);
    setprop("/systems/electrical/outputs/bus", 0);
    setprop("/systems/electrical/outputs/cabin-lights", 0);
    setprop("/systems/electrical/outputs/dme", 0);
    setprop("/systems/electrical/outputs/efis", 0);
    setprop("/systems/electrical/outputs/flaps", 0);
    setprop("/systems/electrical/outputs/fuel-pump", 0);
    setprop("/systems/electrical/outputs/fuel-pump[1]", 0);
    setprop("/systems/electrical/outputs/gps", 0);
    setprop("/systems/electrical/outputs/gps-mfd", 0);
    setprop("/systems/electrical/outputs/hsi", 0);
    setprop("/systems/electrical/outputs/instr-ignition-switch", 0);
    setprop("/systems/electrical/outputs/instrument-lights", 0);
    setprop("/systems/electrical/outputs/landing-lights", 0);
    setprop("/systems/electrical/outputs/map-lights", 0);
    setprop("/systems/electrical/outputs/mk-viii", 0);
    setprop("/systems/electrical/outputs/nav", 0);
    setprop("/systems/electrical/outputs/nav[1]", 0);
    setprop("/systems/electrical/outputs/pitot-head", 0);
    setprop("/systems/electrical/outputs/stobe-lights", 0);
    setprop("/systems/electrical/outputs/tacan", 0);
    setprop("/systems/electrical/outputs/taxi-lights", 0);
    setprop("/systems/electrical/outputs/transponder", 0);
    setprop("/systems/electrical/outputs/turn-coordinator", 0);
	elec_timer.start();
}

######################
# Main Electric Loop #
######################

var master_elec = func {
	var gallery_sw = getprop("/controls/electrical/switches/galley");
	var idg1_sw = getprop("/controls/electrical/switches/idg1");
	var idg2_sw = getprop("/controls/electrical/switches/idg2");
	var gen1_sw = getprop("/controls/electrical/switches/gen1");
	var gen2_sw = getprop("/controls/electrical/switches/gen2");
	var gen_apu_sw = getprop("/controls/electrical/switches/gen-apu");
	var gen_ext_sw = getprop("/controls/electrical/switches/gen-ext");
	var apu_ext_crosstie_sw = getprop("/controls/electrical/switches/apu-ext-crosstie");
	var ac_ess_feed_sw = getprop("/controls/electrical/switches/ac-ess-feed");
	var battery1_sw = getprop("/controls/electrical/switches/battery1");
	var battery2_sw = getprop("/controls/electrical/switches/battery2");
	var rpmapu = getprop("/systems/apu/rpm");
	var extpwr_on = getprop("/controls/switches/cart");
	var stateL = getprop("/engines/engine[0]/state");
	var stateR = getprop("/engines/engine[1]/state");
	var xtieL = getprop("/controls/electrical/xtie/xtieL");
	var xtieR = getprop("/controls/electrical/xtie/xtieR");
	var ac1 = getprop("/systems/electrical/bus/ac1");
	var ac2 = getprop("/systems/electrical/bus/ac2");
	var ac_ess = getprop("/systems/electrical/bus/ac-ess");
	var dc1 = getprop("/systems/electrical/bus/dc1");
	var dc2 = getprop("/systems/electrical/bus/dc2");
	var dc_ess = getprop("/systems/electrical/bus/dc-ess");
	
	
	# Left cross tie yes?
	if (extpwr_on and gen_ext_sw) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (rpmapu >= 94.9 and gen_apu_sw) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (stateL == 3 and gen1_sw) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieR", 0);
	}
	
	# Right cross tie yes?
	if (extpwr_on and gen_ext_sw) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (rpmapu >= 94.9 and gen_apu_sw) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (stateR == 3 and gen2_sw) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieL", 0);
	}
	
	# Left AC/DC bus yes?
	if (extpwr_on and gen_ext_sw) {
		setprop("/systems/electrical/bus/ac1", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc1", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (rpmapu >= 94.9 and gen_apu_sw) {
		setprop("/systems/electrical/bus/ac1", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc1", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (stateL == 3 and gen1_sw) {
		setprop("/systems/electrical/bus/ac1", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc1", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (apu_ext_crosstie_sw == 1 and xtieL) {
		setprop("/systems/electrical/bus/ac1", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc1", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else {
		setprop("/systems/electrical/bus/ac1", 0);
		if (getprop("/systems/electrical/bus/ac2") == 0) {
			setprop("/systems/electrical/bus/ac-ess", 0);
		}
		setprop("/systems/electrical/bus/dc1", 0);
		if (getprop("/systems/electrical/bus/dc2") == 0) {
			setprop("/systems/electrical/bus/dc-ess", 0);
		}
	}
	
	# Right AC/DC bus yes?
	if (extpwr_on and gen_ext_sw) {
		setprop("/systems/electrical/bus/ac2", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc2", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (rpmapu >= 94.9 and gen_apu_sw) {
		setprop("/systems/electrical/bus/ac2", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc2", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (stateR == 3 and gen2_sw) {
		setprop("/systems/electrical/bus/ac2", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc2", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else if (apu_ext_crosstie_sw == 1  and xtieR) {
		setprop("/systems/electrical/bus/ac2", ac_volt_std);
		setprop("/systems/electrical/bus/ac-ess", ac_volt_std);
		setprop("/systems/electrical/bus/dc2", dc_volt_std);
		setprop("/systems/electrical/bus/dc-ess", dc_volt_std);
	} else {
		setprop("/systems/electrical/bus/ac2", 0);
		if (getprop("/systems/electrical/bus/ac1") == 0) {
			setprop("/systems/electrical/bus/ac-ess", 0);
		}
		setprop("/systems/electrical/bus/dc2", 0);
		if (getprop("/systems/electrical/bus/dc1") == 0) {
			setprop("/systems/electrical/bus/dc-ess", 0);
		}
	}
	
	if (ac_ess >= 100) {
		if (gallery_sw == 1) {
			setprop("/systems/electrical/bus/galley", ac_volt_std);
		} else if (gallery_sw == 0) {
			setprop("/systems/electrical/bus/galley", 0);
		}
	} else {
		setprop("/systems/electrical/bus/galley", 0);
	}
	
	if (getprop("/systems/electrical/bus/ac-ess") == 0) {
		setprop("systems/electrical/on", 0);
#		ai_spin.setValue(0.2);
#		aispin.stop();
		setprop("systems/electrical/outputs/adf", 0);
		setprop("systems/electrical/outputs/audio-panel", 0);
		setprop("systems/electrical/outputs/audio-panel[1]", 0);
		setprop("systems/electrical/outputs/autopilot", 0);
		setprop("systems/electrical/outputs/avionics-fan", 0);
		setprop("systems/electrical/outputs/beacon", 0);
		setprop("systems/electrical/outputs/bus", 0);
		setprop("systems/electrical/outputs/cabin-lights", 0);
		setprop("systems/electrical/outputs/dme", 0);
		setprop("systems/electrical/outputs/efis", 0);
		setprop("systems/electrical/outputs/flaps", 0);
		setprop("systems/electrical/outputs/fuel-pump", 0);
		setprop("systems/electrical/outputs/fuel-pump[1]", 0);
		setprop("systems/electrical/outputs/gps", 0);
		setprop("systems/electrical/outputs/gps-mfd", 0);
		setprop("systems/electrical/outputs/hsi", 0);
		setprop("systems/electrical/outputs/instr-ignition-switch", 0);
		setprop("systems/electrical/outputs/instrument-lights", 0);
		setprop("systems/electrical/outputs/landing-lights", 0);
		setprop("systems/electrical/outputs/map-lights", 0);
		setprop("systems/electrical/outputs/mk-viii", 0);
		setprop("systems/electrical/outputs/nav", 0);
		setprop("systems/electrical/outputs/nav[1]", 0);
		setprop("systems/electrical/outputs/pitot-head", 0);
		setprop("systems/electrical/outputs/stobe-lights", 0);
		setprop("systems/electrical/outputs/tacan", 0);
		setprop("systems/electrical/outputs/taxi-lights", 0);
		setprop("systems/electrical/outputs/transponder", 0);
		setprop("systems/electrical/outputs/turn-coordinator", 0);
	} else {
		setprop("systems/electrical/on", 1);
#		aispin.start();
		setprop("systems/electrical/outputs/adf", dc_volt_std);
		setprop("systems/electrical/outputs/audio-panel", dc_volt_std);
		setprop("systems/electrical/outputs/audio-panel[1]", dc_volt_std);
		setprop("systems/electrical/outputs/autopilot", dc_volt_std);
		setprop("systems/electrical/outputs/avionics-fan", dc_volt_std);
		setprop("systems/electrical/outputs/beacon", dc_volt_std);
		setprop("systems/electrical/outputs/bus", dc_volt_std);
		setprop("systems/electrical/outputs/cabin-lights", dc_volt_std);
		setprop("systems/electrical/outputs/dme", dc_volt_std);
		setprop("systems/electrical/outputs/efis", dc_volt_std);
		setprop("systems/electrical/outputs/flaps", dc_volt_std);
		setprop("systems/electrical/outputs/fuel-pump", dc_volt_std);
		setprop("systems/electrical/outputs/fuel-pump[1]", dc_volt_std);
		setprop("systems/electrical/outputs/gps", dc_volt_std);
		setprop("systems/electrical/outputs/gps-mfd", dc_volt_std);
		setprop("systems/electrical/outputs/hsi", dc_volt_std);
		setprop("systems/electrical/outputs/instr-ignition-switch", dc_volt_std);
		setprop("systems/electrical/outputs/instrument-lights", dc_volt_std);
		setprop("systems/electrical/outputs/landing-lights", dc_volt_std);
		setprop("systems/electrical/outputs/map-lights", dc_volt_std);
		setprop("systems/electrical/outputs/mk-viii", dc_volt_std);
		setprop("systems/electrical/outputs/nav", dc_volt_std);
		setprop("systems/electrical/outputs/nav[1]", dc_volt_std);
		setprop("systems/electrical/outputs/pitot-head", dc_volt_std);
		setprop("systems/electrical/outputs/stobe-lights", dc_volt_std);
		setprop("systems/electrical/outputs/tacan", dc_volt_std);
		setprop("systems/electrical/outputs/taxi-lights", dc_volt_std);
		setprop("systems/electrical/outputs/transponder", dc_volt_std);
		setprop("systems/electrical/outputs/turn-coordinator", dc_volt_std);
	}
}

###################
# Update Function #
###################

var update_electrical = func {
	master_elec();
}

var elec_timer = maketimer(0.2, update_electrical);
