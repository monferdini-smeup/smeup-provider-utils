#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

if [[ $# -ne 1 ]] ; then
  echo "Usage: $0 IDMINION" >&2
  exit 1
fi

LOGFILE=/home/ec2-user/gestione-minions/log/resetsonde/$1.log

echo status sonde su minion $1 LOGFILE: $LOGFILE
echo status sonde su minion $1 eseguito il `date '+%d/%m/%Y %H:%M:%S'` > $LOGFILE

sudo salt $1 cmd.run 'systemctl status rmmagent' >> $LOGFILE.1
echo Check Status : 
cat $LOGFILE.1 | grep Active

sudo salt $1 cmd.run 'systemctl stop rmmagent' >> $LOGFILE.2
echo Stop Service rmmagent 

sleep 2
sudo salt $1 cmd.run 'systemctl status rmmagent' >> $LOGFILE.3
echo Check Status : 
cat $LOGFILE.3 | grep Active


sudo salt $1 cmd.run 'systemctl start rmmagent' >> $LOGFILE.4
echo Start Agent  

sleep 2
sudo salt $1 cmd.run 'systemctl status rmmagent' >> $LOGFILE.5
echo Status Service : 
cat $LOGFILE.5 | grep Active


cat $LOGFILE.1 $LOGFILE.2 $LOGFILE.3 $LOGFILE.4 $LOGFILE.5 >> $LOGFILE

rm $LOGFILE.1
rm $LOGFILE.2
rm $LOGFILE.3
rm $LOGFILE.4
rm $LOGFILE.5


