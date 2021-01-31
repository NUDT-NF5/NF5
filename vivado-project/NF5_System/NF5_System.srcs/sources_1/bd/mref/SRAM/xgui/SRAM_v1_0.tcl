# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AddrWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AddrWidth2" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DataWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Depth" -parent ${Page_0}


}

proc update_PARAM_VALUE.AddrWidth { PARAM_VALUE.AddrWidth } {
	# Procedure called to update AddrWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AddrWidth { PARAM_VALUE.AddrWidth } {
	# Procedure called to validate AddrWidth
	return true
}

proc update_PARAM_VALUE.AddrWidth2 { PARAM_VALUE.AddrWidth2 } {
	# Procedure called to update AddrWidth2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AddrWidth2 { PARAM_VALUE.AddrWidth2 } {
	# Procedure called to validate AddrWidth2
	return true
}

proc update_PARAM_VALUE.DataWidth { PARAM_VALUE.DataWidth } {
	# Procedure called to update DataWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DataWidth { PARAM_VALUE.DataWidth } {
	# Procedure called to validate DataWidth
	return true
}

proc update_PARAM_VALUE.Depth { PARAM_VALUE.Depth } {
	# Procedure called to update Depth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Depth { PARAM_VALUE.Depth } {
	# Procedure called to validate Depth
	return true
}


proc update_MODELPARAM_VALUE.Depth { MODELPARAM_VALUE.Depth PARAM_VALUE.Depth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Depth}] ${MODELPARAM_VALUE.Depth}
}

proc update_MODELPARAM_VALUE.DataWidth { MODELPARAM_VALUE.DataWidth PARAM_VALUE.DataWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DataWidth}] ${MODELPARAM_VALUE.DataWidth}
}

proc update_MODELPARAM_VALUE.AddrWidth { MODELPARAM_VALUE.AddrWidth PARAM_VALUE.AddrWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AddrWidth}] ${MODELPARAM_VALUE.AddrWidth}
}

proc update_MODELPARAM_VALUE.AddrWidth2 { MODELPARAM_VALUE.AddrWidth2 PARAM_VALUE.AddrWidth2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AddrWidth2}] ${MODELPARAM_VALUE.AddrWidth2}
}

