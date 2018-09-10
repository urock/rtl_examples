vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=32 -gAPB_DATAS_WIDTH_=32
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=32 -gAPB_DATAS_WIDTH_=16
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=32 -gAPB_DATAS_WIDTH_=8
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=16 -gAPB_DATAS_WIDTH_=32
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=16 -gAPB_DATAS_WIDTH_=16
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=16 -gAPB_DATAS_WIDTH_=8
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=8 -gAPB_DATAS_WIDTH_=32
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=8 -gAPB_DATAS_WIDTH_=16
run -all
vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb -gAPB_DATAM_WIDTH_=8 -gAPB_DATAS_WIDTH_=8
run -all

do wave.do
view structure
view wave

onbreak resume



