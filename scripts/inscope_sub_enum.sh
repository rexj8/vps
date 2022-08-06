#count=0; 
#while read sub;do
#echo "$(tput setaf 166)$count$(tput setaf 15)"; 
#sub_enum $sub ~/latitudefinancial/ x$count; 
#((count+=1)); 
#done < ~/latitudefinancial/scope

# count=0; while read sub; do echo "$(tput setaf 166)$count$(tput setaf 15)"; cat ~/latitudefinancial/x$count | anew ~/latitudefinancial/x; ((count+=1)); done < ~/latitudefinancial/scope
