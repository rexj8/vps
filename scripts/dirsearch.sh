while read sub; do
python3 ~/tools_pentesting/dirsearch/dirsearch.py -u $sub -t 50 -o dirsearch.txt
done < $1