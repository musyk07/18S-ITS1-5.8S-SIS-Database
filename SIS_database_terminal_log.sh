#!/bin/bash
#Made by Mykhaylo Usyk MSci. 2016 mu408@nyu.edu

while read p
do

#splitting the unite id from the taxonomy name
silva_id=$(echo ${p} | cut -f 1 -d ' ')
silva_name=$(echo ${p} | cut -f 2 -d ' ')

echo "The unite ID was identified as ${silva_id}"

#Getting the genus name out from the unite taxonomy file
ninth_name=$(echo ${silva_name} | cut -f 6 -d ';')

#Making sure that unidentified entries won't be processed by allowing the loop to break 
if [ $ninth_name == "g__unidentified" ]
then
   echo "No identification for this genus, trying to exit" && continue
else
   echo "Proceeding..."
fi

#Removing the genus tag to make a grep id for silva
for_silva=$(echo ${ninth_name} | sed 's/g__//1')

#Getting the Silva id to pull out the sequence
silva_entry=$(grep ";${for_silva}[$;]" ./silva_fungal_taxa.txt)

if [ -z "$silva_entry" ]
then
   echo "A matching Silva entry to ${for_silva} wasn't found, moving on" && continue
fi

echo "Matching Silva entry was found, trying to concatenate 18S with unite ITS entry"

silva_ref=$(echo ${silva_entry} | head -n 1 | cut -f 1 -d ' ')

#Getting the silva sequence by using the obtained id
eis_seq=$(awk "/>${silva_ref}$/{getline; print}" ./silva_fungal_joined.fasta)
ITS_seq=$(awk "/${silva_id}/{getline; print}" ./sh_refs_qiime_ver7_97_31.01.2016.fasta)

#Time to write the sequence to file, but a final check of all the variable so as not to mess up the output
if [ -z "$eis_seq" ]
then
   echo "NO 18S SEQUENCE, STOPPING" && continue
fi

if [ -z "$ITS_seq" ]
then
   echo "NO ITS SEQUENCE, STOPPING" && continue
fi

echo ">${silva_id}" >> great_pizza_toppings.txt
echo "${eis_seq}${ITS_seq}" >> great_pizza_toppings.txt


done < sh_taxonomy_qiime_ver7_97_31.01.2016.txt
