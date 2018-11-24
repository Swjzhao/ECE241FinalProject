vlib work

vlog LoopTester.v

vsim lower


log {/*}

add wave {/*}

#the KEY is actually ~KEY
force {clock} 0 0ns, 1 {5ns} -r 10ns

#reset / begin
force {start} 0
run 10ns

force {start} 1
run 300ns


