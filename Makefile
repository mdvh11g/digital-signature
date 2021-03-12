#########################################################
#                                                       #
# This is a general purpose makefile to compile and run #
# Cadence NCSIM simulator                               #  
#                                                       #
#########################################################


# top level and design files

TOP = svc_tb
DESIGN = ./core/*.sv
TESTBENCH = svc_tb.sv

# compillers switch

NCVLOG_SWITCHES = -UPDATE $(INCDIR) -SV 
NCVHDL_SWITCHES = -UPDATE $(INCDIR)

NCELAB_SWITCHES =-ACCESS +rwc -UPDATE -TIMESCALE '1ns/1ps' 


default : help


# elaborate the top module
elab  : ana
	ncelab $(NCELAB_SWITCHES) work.$(TOP)

# analize design files
ana : 
	for f in $(DESIGN); do ncvlog $(NCVLOG_SWITCHES) -work work $$f; done
	for f in $(TESTBENCH); do ncvlog $(NCVLOG_SWITCHES) -work work $$f; done

# clean prj
clean :
	rm -rf work
	rm -rf *.log
	rm -rf cds.lib hdl.var 
	rm -rf INCA_libs
	rm -rf ncsim.key

# create prj env
env : 
	echo '# Hello Cadence' > hdl.var
	echo 'DEFINE work work' > cds.lib
	mkdir -p work	
	

help:
	echo $(DESIGN)
