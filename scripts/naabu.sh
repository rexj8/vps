# bash naabu.sh nykaa_x nykaa_naabu
while read sub; do
echo " " | tee -a $2;
echo $sub | tee -a $2;
sudo naabu -host $sub -p 0-65535 -scan-all-ips | tee -a $2;
done < $1