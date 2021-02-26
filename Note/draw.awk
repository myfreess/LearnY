function draw(str, leng){
leng = length(str) + 4
printf "+"
linegen(leng - 2, "-")
print "+"
#printf "|"
#linegen(leng - 2, " ")
#printf "|\n"
print "| " str " |"
#printf "|"
#linegen(leng - 2, " ")
#printf "|\n"
printf "+"
linegen(leng - 2, "-")
print "+"
}
function linegen(len, string){
for(i=1; i < len + 1; i++){
		printf string
}
}

