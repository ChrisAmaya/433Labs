onbreak {resume}

if [file exists work] {
	vdel -all
}

vlib work
vmap work work
vlog -f scripts/compile_all.f				
vsim -c tbench_top 				
run -all					
quit -f

