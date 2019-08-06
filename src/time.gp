clear
reset
set term pngcairo
set terminal png font " Times_New_Roman,12 "
set terminal png size 1024,768

set xlabel "N"
set output "statistic.png"
unset ylabel

set ytics 1 
set style data histograms 
set style fill solid border

bm = 0.15
lm = 0.12
rm = 0.95
gap = 0.03
size = 0.75
kk = 0.2 # relative height of bottom plot
y1 = 0.0; y2 = 2.0; y3 = 100.0; y4 = 250.0

set style data histograms
set style fill solid 1.0 border -1
unset key

set multiplot
set border 1+2+8
set xtics nomirror
set ytics nomirror
set lmargin at screen lm
set rmargin at screen rm
set bmargin at screen bm
set tmargin at screen bm + size * kk

set yrange [y1:y2]

plot 'gpu_nor.txt' using 2:xticlabels(1) 

set ytics 10
unset xtics
unset xlabel
set ylabel "T_C_P_U/T_G_P_U"
set border 2+4+8
set bmargin at screen bm + size * kk + gap
set tmargin at screen bm + size + gap
set yrange [y3:y4]

plot 'gpu_nor.txt' using 2:xticlabels(1) 

unset multiplot
