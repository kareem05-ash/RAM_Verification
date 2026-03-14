vlib work
vlog RAM.v RAM_gm.sv RAM_tb.sv
vsim -voptargs=+acc work.RAM_tb
add wave *
run -all
#quit -sim