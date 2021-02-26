function linegen(len,i){
printf "+"
for(i=1; i <= len; i++){
printf "-"
}
print "+"
}
function sort(array, j){
for(j in array){
#print array[j]
if(length(array[j]) > len){
len = length(array[j])
#print len
}
}
return len
}
function spacebar(len, i){
for(i=1; i<=len; i++){
printf " "
}
}
BEGIN {
delete ARGV[0]
if(ARGV[1]==""){
print "hello,please give some string"
}
else{
len = 0
len = sort(ARGV) + 4
#printf "len=%d\n", len
linegen(len)
for(j in ARGV){
printf "|"
strlen= (len - length(ARGV[j])) / 2
spacebar(strlen)
printf ARGV[j]
spacebar(strlen)
print "|"
linegen(len)
}
}
}



