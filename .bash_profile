export PS1="\[$(tput setaf 2)\]\u@\h:\[$(tput setaf 4)\]\w $ \[$(tput setaf 3)\]"

#---------------------------------------------RECON--------------------------------------------------

scp_vps(){
    scp kali:~/$1_normal $2amass_normal
    scp kali:~/$1_passive $2amass_passive
    scp kali:~/$1_active $2amass_active
}

cname_check(){ # for sbtko, s3 misconfig
# if host $2 | sed 's/.$//' contains "domain name pointer" then store in $1cname
# elif host $2 | sed 's/.$//' contains "has address" then store in $1ip

# then after scanning those subdomains scan all IPs
echo pass
}

bypass(){
~/tools_pentesting/403_tools/4-ZERO-3/./403-bypass.sh -u $1 --exploit
~/tools_pentesting/403_tools/bypass-403/./bypass-403.sh $1
~/tools_pentesting/403_tools/byp4xx/./byp4xx.py $1
}

acunetix_csv(){
# cat $1acunetix | httpx | sed 's/^/https:\/\//' | sed 's/$/,testing/' | tee -a $1acunetix.csv
cat $1acunetix | httpx | sed 's/$/,testing/' | tee -a $1acunetix.csv
explorer.exe .
}

openredirex(){
# use after paramspider
python3 ~/tools_pentesting/OpenRedireX/openredirex.py -p ~/tools_pentesting/OpenRedireX/openredirex.py -l $1 --keyword=FUZZ
}

shodanipo(){
shodan search --limit 1000 --fields ip_str,port ssl:$1 200 OK | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed 's/^/http:\/\//' | tee $2ip_for_ssl_check
}

c99ipo(){
# get link from subdomainfinder.c99.nl
# like: https://subdomainfinder.c99.nl/scans/2022-02-27/gymshark.com
# curl https://subdomainfinder.c99.nl/scans/2022-02-27/gymshark.com | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u | tee -a ~/gymshark/com.gymshark/ip_c99
curl $1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u | tee -a $2ip_c99
}

knockscriptipo(){
# python3 sub_knockpy.py -sub ~/geotab/lat-lon/
# python3 sub_knockpy.py -ip ~/geotab/lat-lon/

# mkdir $2knockpy_report/
# sudo chmod 777 $2*
# knockpy $1 -o $2knockpy_report/
python3 ~/scripts/knockpyscript.py -ip $1 | tee -a $2test_knockpy
cat $2test_knockpy | sort -u | tee -a $2ip_knockpy
rm $2test_knockpy
# rm -rf $2knockpy_report
}

knockipo(){
# knockipo gymshark.com ~/gymshark/com.gymshark/
knockpy $1 | tee -a $2test_knockipo
cat $2test_knockipo | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | tee -a $2ip_knockpy
rm -rf $2test_knockipo
}

sub_enum(){
# sub_enum flaws.cloud ~/flaws.cloud/ x
apikey
mkdir $2knockpy_report/
sudo chmod 777 $2*

amass enum -passive -d $1 -o $2amass_passive
amass enum -active -d $1 -o $2amass_active
amass enum -d $1 -o $2amass_normal
afinder $1 $2assetfinder
findomain $1 $2findomain
subfindero $1 $2subfinder
sublistero $1 $2sublister
crtsh $1 | tee -a $2$3
bash ~/tools_pentesting/Sudomy/sudomy -d $1 -o $2 --no-probe

knockpy $1 -o $2knockpy_report/
python3 ~/scripts/knockpyscript.py -sub $2 | tee -a $2knockpy

echo "$(tput setaf 166)------------------------------------------------------------anew Amass------------------------------------------------------------"
cat $2amass_normal | anew $2$3
cat $2amass_passive | anew $2$3
cat $2amass_active | anew $2$3
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

sub_filter(){
# get uniq subdomains and differentiate with their siblings like ari1.geotab.com and ari2.geotab.com
cat $1 | awk -F. '{print $1}' | sed 's/[0-9]*//g' | sort -u
}

sub_uniq(){
cat $1amass_active | anew $1x
cat $1amass_passive | anew $1x
cat $1amass_normal | anew $1x
cat $1assetfinder | anew $1x
cat $1findomain | anew $1x
cat $1subfinder | anew $1x
cat $1sublister | anew $1x

domain=$(ls $1Sudomy-Output/)
cat $1Sudomy-Output/$domain/subdomain.txt | anew $1x
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

crttoall(){
crtsh $1 | tee -a all.txt
crtshid $1 | tee -a all.txt
}

crtsh(){
curl -s https://crt.sh/\?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep $1
}

crtshid(){
curl -s https://crt.sh/\?Identity\=$1.%\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep $1
}

crtsho(){
curl -s https://crt.sh/\?O\=$1\&output\=json | jq -r '.[].common_name' | sed 's/\*\.//g' | sort -u 
}

cloudunflair(){
bash cloudunflare.bash
}

cloudflair(){
python3 tools_pentesting/cloudflair/cloudflair.py $1
}

sublister(){
python3 ~/tools_pentesting/subenum_tools/sublist3r/sublist3r.py -d $1 -t 50 | grep $1
}

sublistero(){
python3 ~/tools_pentesting/subenum_tools/sublist3r/sublist3r.py -d $1 -o $2 -t 50
}

dirsearch(){
python3 ~/tools_pentesting/dirbruteforce_tools/dirsearch/dirsearch.py -u $1 -e $2 -t 50 -b $3
}

paramspider(){
python3 ~/tools_pentesting/ParamSpider/paramspider.py -d $1
}

smtp_nmap_method(){
nmap -p25 --script smtp-enum-users --script-args smtp-enum-users.methods={$2} $1
}

smtp_nmap(){
nmap -p25 --script smtp-commands $1 
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-open-relay $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-brute $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-ntlm-info $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-strangeport $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-vuln-cve2010-4344 $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-vuln-cve2011-1720 $1
echo "-----------------------------------------------------------------------------------------------------------"
nmap -p25 --script smtp-vuln-cve2011-1764 $1
}

wafwoof(){
wafw00f $1 $2
}

#---------------------------------------------BASIC------------------------------------------------

apikey(){
export VT_APIKEY=f746c737123dae2844c6b75d4fe85cadadc2d8b36208fdbd6b2b2905be296432
export CENSYS_API_ID=d973cf60-4ce4-4746-962b-815ddfdebf80
export CENSYS_API_SECRET=s6EUuA4Sfaajd8jDBJ17b4DaoPofjDe6
export WPSCAN_API_TOKEN=T28YofMUvHAa2m7ZUJO1TKK7yTSlCoYaBiw8JilRKyw
}

h(){
httprobe
}

live(){
# live x [_29july]
echo "$(tput setaf 166)  Analyzing Live URLS... $(tput setaf 15)"
cat $1 | httprobe | grep https | tee -a httprobe
cat $1 | httpx | grep https | tee -a httpx
cat httprobe | anew live$2
cat httpx | anew live$2
rm -rf httprobe httpx
}

orange(){
echo "$(tput setaf 166)This is orange"
}

c(){
clear
}

hgrep(){
history | grep $1
}

n(){
nano ~/.bash_profile
}

s(){
source ~/.bash_profile
}

w(){
wc -l
}

wcall(){
cat all.txt | wc -l
}

# ---------------------------------------------------------------------------------------------------
acunetix_csv2(){
cat $1x | httpx -status-code | tee -a $1test
touch $1acunetix.csv
sed 's/.....$//' $1test | tee -a $1acunetix.csv
rm $1test
cat $1acunetix.csv | sed 's/ /,/g' | tee -a $1test
rm $1acunetix.csv
awk -F, -v OFS=, '{ sub(/^....../, "", $2) } 1' $1test | tee -a $1acunetix.csv
rm test
explorer.exe .
}

#---------------------------------------VirusTotal_ApiKey--------------------------------------------
# For Sublister
# export VT_APIKEY=<Public Api Key>
export PATH="$PATH:~/objectify-s3/"
