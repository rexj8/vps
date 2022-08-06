# ./inscope_amass_all.sh ovo_inscope ovo
while read sub; do
amass enum -d $sub -o amass_normal
cat amass_normal | anew $2_amass
amass enum -passive -d $sub -o amass_passive
cat amass_passive | anew $2_amass
amass enum -active -d $sub -o amass_active
cat amass_active | anew $2_amass
done < $1