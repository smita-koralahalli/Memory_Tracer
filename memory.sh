#!/bin/bash 

PID="$(pidof java)"
echo      Name  %CPU  %Memory  VSZ  RSS  Private_Memory    Shared_Memory    Total_Memory_Consumed    Minor_Page_Fault    Major_Page_Fault     Start_time      Elapsed_time

process_mem ()
{

#we need to check if 2 files exist
if [[ -f /proc/$PID/status ]];
then
	if [[ -f /proc/$PID/smaps ]]; 
	then
		#here we count memory usage, Pss, Private and Shared = Pss-Private
		Pss=`cat /proc/$PID/smaps | grep -e "^Pss:" | awk '{print $2}'| paste -sd+ | bc `
		Private=`cat /proc/$PID/smaps | grep -e "^Private" | awk '{print $2}'| paste -sd+ | bc `
		#we need to be sure that we count Pss and Private memory, to avoid errors
		if [ x"$Rss" != "x" -o x"$Private" != "x" ]; 
		then

			let Shared=${Pss}-${Private}
			Name=`cat /proc/$PID/status | grep -e "^Name:" |cut -d':' -f2`
			#we keep all results in bytes
			let Shared=${Shared}*1024
			let Private=${Private}*1024
			let Sum=${Shared}+${Private}
			PS=`ps aux | grep -v grep | grep $PID | tr -s ' ' | cut -d' ' -f3,4,5,6`
        		PS1=`ps -p $PID -o  min_flt,maj_flt,lstart,etime | tail -n +2` 
			echo "${Name}  ${PS}  ${Private}  ${Shared}   ${Sum}  ${PS1}"
		fi
	fi
fi
}



while :
do
	if [[ ! -d /proc/$PID ]];
  	then
		break       	   #Abandon the while lopp.
  	fi

	process_mem
	sleep 1
done | tee -a /tmp/output.txt
