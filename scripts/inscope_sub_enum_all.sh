apikey(){
export VT_APIKEY=f746c737123dae2844c6b75d4fe85cadadc2d8b36208fdbd6b2b2905be296432
export CENSYS_API_ID=d973cf60-4ce4-4746-962b-815ddfdebf80
export CENSYS_API_SECRET=s6EUuA4Sfaajd8jDBJ17b4DaoPofjDe6
export WPSCAN_API_TOKEN=T28YofMUvHAa2m7ZUJO1TKK7yTSlCoYaBiw8JilRKyw
}

subfindero(){
subfinder -all -recursive -d $1 -t 50 -o $2
}

findomain(){
~/tools_pentesting/subenum_tools/./findomain-linux -t $1 -u $2
}

afinder(){
assetfinder --subs-only $1 | sed 's/\*\.//g' | tee -a $2
}

crtsh(){
curl -s https://crt.sh/\?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep $1
}

sublistero(){
python3 ~/tools_pentesting/subenum_tools/sublist3r/sublist3r.py -d $1 -o $2 -t 50
}

sub_enum(){
mkdir $2knockpy_report/
sudo chmod 777 $2*

afinder $1 $2assetfinder
findomain $1 $2findomain
subfindero $1 $2subfinder
sublistero $1 $2sublister
crtsh $1 | tee -a $2$3
bash ~/tools_pentesting/Sudomy/sudomy -d $1 -o $2 --no-probe

knockpy $1 -o $2knockpy_report/
python3 ~/scripts/knockpyscript.py -sub $2 | tee -a $2knockpy

echo "$(tput setaf 166)------------------------------------------------------------anew Amass------------------------------------------------------------"
cat $2amass | anew $2$3
echo "$(tput setaf 166)------------------------------------------------------------anew AssetFinder------------------------------------------------------------"
cat $2assetfinder | anew $2$3
echo "$(tput setaf 166)------------------------------------------------------------anew Findomain------------------------------------------------------------"
cat $2findomain | anew $2$3
echo "$(tput setaf 166)------------------------------------------------------------anew Subfinder------------------------------------------------------------"
cat $2subfinder | anew $2$3
echo "$(tput setaf 166)------------------------------------------------------------anew Sublister------------------------------------------------------------"
cat $2sublister | anew $2$3
echo "$(tput setaf 166)------------------------------------------------------------anew Knockpy------------------------------------------------------------"
cat $2knockpy | anew $2$3

echo "$(tput setaf 166)------------------------------------------------------------anew Sudomy------------------------------------------------------------"
domain=$(ls $2Sudomy-Output/)
cat $2Sudomy-Output/$domain/subdomain.txt | anew $2$3

rm $2assetfinder $2findomain $2subfinder $2sublister $2amass_normal $2amass_active $2amass_passive $2knockpy
rm -rf $2Sudomy-Output
# rm -rf $2knockpy_report

cat $2$3 | grep $1 | tee $2y
rm $2$3
cat $2y | sort -u | tee -a $2$3
rm $2y
echo "$(tput setaf 15)"
}

# orange qwe


count=0;
while read sub; do
((count+=1));
echo $count
sub_enum $sub ~/ovo/ x$count
done < $1
