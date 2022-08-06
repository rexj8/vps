while read sub; do
waybackurls $sub | tee -a $2dir_bruteforce
gau $sub | tee -a $2dir_bruteforce
echo $sub | hakrawler | tee -a $2dir_bruteforce
done < $1