vsim -onfinish final -l vsim.log -voptargs=\"+acc\" work.apb_converter_tb
do wave.do
view structure
view wave
run -all
onbreak resume

#-f <filename>           Read command line arguments from <filename>
# simlibs.f
# work.main glbl
#    -onfinish <mode>        Customize the kernel shutdown behavior at the end of simulation
#                            Valid modes - ask, stop, exit, final (Default: ask)

#do wave.do
#view structure
#view wave



