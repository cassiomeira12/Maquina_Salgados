onerror {quit -f}
vlib work
vlog -work work Maquina.vo
vlog -work work Maquina.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Maquina_vlg_vec_tst
vcd file -direction Maquina.msim.vcd
vcd add -internal Maquina_vlg_vec_tst/*
vcd add -internal Maquina_vlg_vec_tst/i1/*
add wave /*
run -all
