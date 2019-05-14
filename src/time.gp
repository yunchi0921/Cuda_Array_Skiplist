set title "GPU and CPU speed compare"
set xlabel "N"
set ylabel "Time(ns)"
set terminal png font " Times_New_Roman,12 "
set output "statistic.png"
set key left 
set logscale x 2
set logscale y
plot[1:8192][:] \
"gpu.txt" using 1:2 with linespoints linewidth 3 title "GPU",\
"cpu.txt" using 1:2 with linespoints linewidth 3 title "CPU"
