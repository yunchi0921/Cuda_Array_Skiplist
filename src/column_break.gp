reset
unset key
set terminal png font " Times_New_Roman,12 "
set output "test.png"


bm=0.20
lm=0.12
rm=0.95
gap=0.03
size=0.75
kk=0.2 #relative height of bottom plot
y1=0.0; y2=1;y3=6;y4=20;

set multiplot
set border 1+2+8
set xtics nomirror
set ytics nomirror
set lmargin at screen lm
set rmargin at screen rm
set bmargin at screen bm
set tmargin at screen bm + size * kk




set xlabel "N"

set logscale x 2
set xtics 2
set ytics 1
set xtics rotate out
set style fill solid border -1
set boxwidth 0.15

offset=1.15
set yrange[y1:y2]

plot  [1.1:800000]'shared_nor.txt' using ($1*offset):($2) title "shared" linecolor rgb "#cc0000" with boxes  ,\
	'global_nor.txt' using ($1/offset):($2) title "global" linecolor rgb "#00cc00" with boxes ,\
	'LockFree_nor.txt' using($1):2 title "Lockfree" linecolor rgb "#f6ff00" with boxes

unset xtics
unset xlabel
set border 2+4+8
set bmargin at screen bm + size * kk + gap
set tmargin at screen bm + size + gap
set yrange [y3:y4]
set key top left

plot  [1.1:800000]'shared_nor.txt' using ($1*offset):($2) title "shared" linecolor rgb "#cc0000" with boxes  ,\
	'global_nor.txt' using ($1/offset):($2) title "global" linecolor rgb "#00cc00" with boxes ,\
	'LockFree_nor.txt' using($1):2 title "Lockfree" linecolor rgb "#f6ff00" with boxes
unset multiplot 
