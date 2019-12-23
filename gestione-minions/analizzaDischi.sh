#/bin/bash
# ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

#se viene passato un id lo utilizzo, altrimenti forzo per tutti
MINION=${1:-*}
export MINION
# rilevo le percentuali
#echo sudo salt \'${MINION}\' customStat.get_disk
#echo eseguo analisi spazio disco sul minion "\'${MINION}\'"
#echo eseguo analisi spazio disco sul minion \"${MINION}\"
#echo salt \"${MINION}\" customStat.get_disk 
#salt "*" customStat.get_disk 
#sleep 5
salt "*" customStat.get_disk > /home/ec2-user/gestione-minions/diskMinions.txt
#Use IFS (internal field separator) tool in bash, defines the character using to separate lines into tokens, by default includes <tab> /<space> /<newLine>
#step 1: Load the file data and insert into list:

# declaring array list and index iterator
declare -a arrayMinions=()
declare -a percDisk=()
i=0

# reading file in row mode, insert each line into array
while IFS= read -r line; do
    arrayMinions[i]=$line
    read -r line
    percDisk[i]=$line    
    let "i++"
    # reading from file path
done < /home/ec2-user/gestione-minions/diskMinions.txt

rm /home/ec2-user/gestione-minions/terraform_da_eseguire.sh

i=0
#
for line in "${arrayMinions[@]}"
  do
    PERCDISK=${percDisk[i]}
    if [[ ${PERCDISK} == *"Stat"* ]]; then
        echo "minions : -" "$line" "- manca : " "$PERCDISK"
    fi
    VALPERCDISK=$(echo $PERCDISK| cut -d'%' -f 1)
    #debug echo "minions : -" "$line" "- perc : " "$PERCDISK" "valore:" "$VALPERCDISK" "*" 
 #eseguo solo se non presente stinga Minion o not e se numero   
    if [[ ${PERCDISK} != *"inion"* ]]; then
    if [[ ${VALPERCDISK//[0-9]} == "" ]]; then
      if [[ $VALPERCDISK != "" ]]; then
        if [ "$VALPERCDISK" -gt "70" ];then
          echo "minions oltre 70 percento: -" "$line" "- perc : " "$PERCDISK" "valore:" "$VALPERCDISK"
         echo "echo Analisi del `date '+%d/%m/%Y %H:%M:%S'` eseguito il \`date '+%d/%m/%Y %H:%M:%S'\`" \>\> /home/ec2-user/gestione-minions/log/terraform/eseguito_${line/:/}.log >> /home/ec2-user/gestione-minions/terraform_da_eseguire.sh
         echo sudo salt \"${line/:/}\" state.apply recreate_terraform \>\> /home/ec2-user/gestione-minions/log/terraform/eseguito_${line/:/}.log >> /home/ec2-user/gestione-minions/terraform_da_eseguire.sh 
        fi
      fi
     fi
    fi 
    let "i++"      
  done
#
#echo specific index in array: Accessing to a variable in array:
#echo "${array[0]}"
