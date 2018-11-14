vlib work
vlog ECE241FinalProject.v
vsim randNum

log {/*}
add wave {/*}


force {clk} 0 0ns, 1 1ns -r 2ns

force {reset} 0
run 10 ns
force {reset} 1
run 10 ns

force {coord} 1
run 10ns

force {coord} 0
run 100ns



