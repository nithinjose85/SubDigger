#! /bin/bash
#Variables
domain=$1
directory=${domain}_recon

files_and_folders()
{
	echo "Creating Directory $directory"
	mkdir $directory
	mkdir -p $directory/${domain}_screenshots
	touch $directory/${domain}_tmp_intial_list.txt
	touch $directory/tmp_sorted.txt
	touch $directory/tmp_livesites.txt
	touch $directory/sub_domains.txt
	touch $directory/sub_output_nmap.txt
}
main()
{
	echo "Domain : $domain"
	echo "Scanning domain using Subfinder"
	subfinder -d $domain --silent > $directory/${domain}_tmp_intial_list.txt
	echo "Scanning domain using Assetfinder"
	assetfinder --subs-only $domain >> $directory/${domain}_tmp_intial_list.txt
	cat $directory/${domain}_tmp_intial_list.txt | sort -u > $directory/tmp_sorted.txt
	echo "Checking Live domains"
	cat $directory/tmp_sorted.txt | httprobe | sed -E 's/http.+\///' > $directory/tmp_livesites.txt
	cat $directory/tmp_livesites.txt | sort -u > $directory/sub_domains.txt
	count=$(cat $directory/sub_domains.txt | wc -l)
	echo "Total $count sub domains found."
	echo "Scanning subdomains using nmap"
	nmap -iL $directory/sub_domains.txt > $directory/sub_output_nmap.txt
	echo "Scanning subdomians using gowitness"
	gowitness file -f $directory/sub_domains.txt --screenshot-path $directory/${domain}_screenshots --disable-db
}
clean_tmp()
{
	rm $directory/${domain}_tmp_intial_list.txt
	rm $directory/tmp_livesites.txt
	rm $directory/tmp_sorted.txt
}

ctrl_c()
{
	echo "CTRL+C Detected"
	rm -rf $directory
	exit 0
}
trap ctrl_c 2
usage() {
    echo "Usage: $0 -d <domain>"
    echo "Options:"
    echo "  -d <domain>    Specify the domain to scan"
    echo "  -h             Display this help message"
}

while getopts ":d:h" opt; do
    case $opt in
        d)
            domain=$OPTARG
            directory="${domain}_recon"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
		echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done
if [[ -z $domain ]]; then
	usage
	exit 0
elif valid=$(echo "$domain" | httprobe); [[ -z $valid ]]; then
    echo "Not Valid"
    exit 0
else
    echo "Valid Domain"
    if [[ -d $directory ]]; then
    	echo "$directory already exists"
    	echo "Removing $directory"
    	rm -rf $directory
    	files_and_folders
    else
    	files_and_folders
    fi
    main
    clean_tmp
fi