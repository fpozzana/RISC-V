add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/FETCH/*
add wave -position insertpoint sim:/tbrisc_v/DUT/IRAMINST/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/IFID/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/DECODE/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/IDEX/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/EXECUTION/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/EXMEM/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DRAMINST/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/MEMWB/*
add wave -position insertpoint sim:/tbrisc_v/DUT/DATAPATHINST/WRITEBACK/*
run 100 ns
