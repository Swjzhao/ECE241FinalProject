vlib work

vlog DE1_SoC_Audio_Example.v

#vsim -L altera_mf_ver Audio_Controller
#vsim DE1_SoC_Audio_Example


log {/*}

add wave {/*}

#SW[3:0] data inputs
#KEY[0] reset

#the KEY is actually ~KEY
force {clock} 0 0ns, 1 {5ns} -r 10ns

force KEY[0] 0
force SW[0] 0 
force SW[1] 0
force SW[2] 0
force SW[3] 0

run 30ns 

force KEY[0] 1
force SW[0] 1
force SW[1] 0
force SW[2] 0
force SW[3] 0

run 30ns 

force SW[0] 1
force SW[1] 1
force SW[2] 0
force SW[3] 0

run 30ns 

force SW[2] 1
force SW[3] 0

run 30ns 

force SW[3] 1

run 30ns 