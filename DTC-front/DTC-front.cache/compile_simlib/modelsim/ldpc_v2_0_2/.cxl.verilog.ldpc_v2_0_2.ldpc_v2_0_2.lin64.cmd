/opt/MentorGraphics/modeltech/bin/vlib /home/dmonk/Firmware/DTC-firmware/DTC-front/DTC-front.cache/compile_simlib/modelsim/ldpc_v2_0_2
/opt/MentorGraphics/modeltech/bin/vmap ldpc_v2_0_2 /home/dmonk/Firmware/DTC-firmware/DTC-front/DTC-front.cache/compile_simlib/modelsim/ldpc_v2_0_2
/opt/MentorGraphics/modeltech/bin/vlog  -64 -L fec_5g_common_v1_1_0 -L ldpc_v2_0_2 +incdir+/home/dmonk/.cxl.ip/incl -sv -work ldpc_v2_0_2 -f /home/dmonk/Firmware/DTC-firmware/DTC-front/DTC-front.cache/compile_simlib/modelsim/ldpc_v2_0_2/.cxl.systemverilog.ldpc_v2_0_2.ldpc_v2_0_2.lin64.cmf
