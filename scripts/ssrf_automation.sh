# bash ~/scripts/ssrf_automation.sh ssrf_oneliner
while read sub; do 
echo '$(tput setaf 166)'$sub
curl -L $sub --location-trusted
done < $1