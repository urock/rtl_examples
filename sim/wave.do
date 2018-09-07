onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /apb_converter_tb/apb_in/PCLK
add wave -noupdate /apb_converter_tb/apb_in/PRESETn
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PSEL
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PWRITE
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PADDR
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PWDATA
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PENABLE
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PREADY
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PRDATA
add wave -noupdate -expand -group apb_in /apb_converter_tb/apb_in/PSLVERR
add wave -noupdate /apb_converter_tb/converter/state
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PSEL
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PWRITE
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PADDR
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PWDATA
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PENABLE
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PREADY
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PRDATA
add wave -noupdate -expand -group apb_out /apb_converter_tb/apb_out/PSLVERR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {105 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 294
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {129 ns}
