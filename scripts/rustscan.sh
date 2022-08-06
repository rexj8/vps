# bash rustscan.sh gymshark.com_local gymshark.com_rustscan
while read sub; do 
echo " " | tee -a $2; 
echo $sub | tee -a $2; 
rustscan --scan-order -a $sub --ulimit 5000 | grep "Open" | awk '{print $2}' | tee -a $2; 
done < $1