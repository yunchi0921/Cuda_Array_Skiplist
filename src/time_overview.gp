clear
reset
set term pngcairo
set terminal png font " Times_New_Roman,12 "
set terminal png size 1024,768
set ylabel "T_C_P_U/T_G_P_U"
set xlabel "N"
set output "statistic.png"
unset key
set style data histograms 
set style fill solid border

set style data histograms
set style fill solid 1.0 border -1

plot 'gpu_nor.txt' using 2:xticlabels(1) 

