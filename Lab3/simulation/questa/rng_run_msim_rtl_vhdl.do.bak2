transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/kylet/Documents/School/ActiveCode/Reconfigure-ECE5730/Reconfigurable-Computing-Lab-work/Lab3/seg.vhd}
vcom -93 -work work {/home/kylet/Documents/School/ActiveCode/Reconfigure-ECE5730/Reconfigurable-Computing-Lab-work/Lab3/rng.vhd}
vcom -93 -work work {/home/kylet/Documents/School/ActiveCode/Reconfigure-ECE5730/Reconfigurable-Computing-Lab-work/Lab3/lfsr_8bit.vhd}

vcom -93 -work work {/home/kylet/Documents/School/ActiveCode/Reconfigure-ECE5730/Reconfigurable-Computing-Lab-work/Lab3/LFSR_tb.vhd}
vcom -93 -work work {/home/kylet/Documents/School/ActiveCode/Reconfigure-ECE5730/Reconfigurable-Computing-Lab-work/Lab3/lfsr_8bit.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  LFSR_tb

add wave *
view structure
view signals
run 1 us
