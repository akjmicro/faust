# ************************************************************************
# FAUST Architecture File
# Copyright (C) 2021 GRAME, Centre National de Creation Musicale
# ---------------------------------------------------------------------

# This is sample code. This file is provided as an example of minimal
# FAUST architecture file. Redistribution and use in source and binary
# forms, with or without modification, in part or in full are permitted.
# In particular you can create a derived work of this FAUST architecture
# and distribute that work under terms of your choice.

# This sample code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# ************************************************************************

include("/usr/local/share/faust/julia/dsp/dsp.jl")
include("/usr/local/share/faust/julia/gui/MapUI.jl")

using OpenSoundControl, Sockets, MacroTools

# OSCUI: a GUI using the Open Sound Control (OSC) protocol to control parameters
mutable struct OSCUI <: UI
    OSCUI(dsp::dsp, inport::Int=5000, outport::Int=5001) = begin
        osc_ui = new()
        osc_ui.dsp = dsp
        osc_ui.map_ui = MapUI(dsp)
        osc_ui.rcv_socket = UDPSocket()
        bind(osc_ui.rcv_socket, ip"127.0.0.1", inport)
        osc_ui.snd_socket = UDPSocket()
        osc_ui.outport = outport
        osc_ui
	end
    dsp::dsp
    map_ui::MapUI
    rcv_socket::UDPSocket
    snd_socket::UDPSocket
    outport::Int
 end

# Receive and decode incoming OSC messages
function run(ui_interface::OSCUI, block::Bool=true)
    function receiveMessage()
        while true
            message = OscMsg(recv(ui_interface.rcv_socket))
            # println(message)
            osc_path = path(message)
            osc_value = message[1]
            if (typeof(osc_value) == String 
                && osc_path == "/*"
                && osc_value == "hello") 
                # TODO
            elseif (typeof(osc_value) == String 
                    && osc_value == "json") 
                json_msg = OpenSoundControl.message("/dummy", "ss", "json", getJSON(ui_interface.dsp))
                send(ui_interface.snd_socket, ip"127.0.0.1", ui_interface.outport, json_msg.data)
            elseif (typeof(osc_value) == String && osc_value == "get")
                # TODO
            elseif (typeof(osc_value) == Float32)
                setParamValue(ui_interface.map_ui, osc_path, osc_value);
            end 
        end
    end
    if (block) 
        receiveMessage()
    else
        Threads.@spawn receiveMessage()
    end
end

# Does not work ?
# MacroTools.@forward OSCUI.map_ui openTabBox, openHorizontalBox, openVerticalBox, closeBox, addButton, addCheckButton, addHorizontalSlider, addHorizontalSlider, addNumEntry, addHorizontalBargraph, addVerticalBargraph

# -- widget's layouts
function openTabBox(ui_interface::OSCUI, label::String)
    openTabBox(ui_interface.map_ui, label)
end
function openHorizontalBox(ui_interface::OSCUI, label::String)
    openHorizontalBox(ui_interface.map_ui, label)
end
function openVerticalBox(ui_interface::OSCUI, label::String)
    openVerticalBox(ui_interface.map_ui, label)
end
function closeBox(ui_interface::OSCUI)
    closeBox(ui_interface.map_ui)
end

# -- active widgets
function addButton(ui_interface::OSCUI, label::String, param::Symbol) 
    addButton(ui_interface.map_ui, label, param)
end

function addCheckButton(ui_interface::OSCUI, label::String, param::Symbol) 
    addCheckButton(ui_interface.map_ui, label, param)
end

function addHorizontalSlider(ui_interface::OSCUI, label::String, param::Symbol, init::FAUSTFLOAT, min::FAUSTFLOAT, max::FAUSTFLOAT, step::FAUSTFLOAT) 
    addHorizontalSlider(ui_interface.map_ui, label, param, init, min, max, step)
end

function addVerticalSlider(ui_interface::OSCUI, label::String, param::Symbol, init::FAUSTFLOAT, min::FAUSTFLOAT, max::FAUSTFLOAT, step::FAUSTFLOAT) 
    addVerticalSlider(ui_interface.map_ui, label, param, init, min, max, step)
end

function addNumEntry(ui_interface::OSCUI, label::String, param::Symbol, init::FAUSTFLOAT, min::FAUSTFLOAT, max::FAUSTFLOAT, step::FAUSTFLOAT) 
    addNumEntry(ui_interface.map_ui, label, param, init, min, max, step)
end

# -- passive widgets
function addHorizontalBargraph(ui_interface::OSCUI, label::String, param::Symbol, min::FAUSTFLOAT, max::FAUSTFLOAT)
    addHorizontalBargraph(ui_interface.map_ui, label, param, min, max)
end

function addVerticalBargraph(ui_interface::OSCUI, label::String, param::Symbol, min::FAUSTFLOAT, max::FAUSTFLOAT)
    addVerticalBargraph(ui_interface.map_ui, label, param, min, max)
end