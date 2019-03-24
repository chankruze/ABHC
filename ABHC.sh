#!/bin/bash

set_threshold(){
    echo "Set Minimum Battery % (Connect AC Adapter) :"
    read lower_limit
    [ $lower_limit -ge 20 -a $lower_limit -le 50 ] 2>/dev/null && echo start_threshold:$lower_limit > ABHC.config || error="yes";

    echo "Set Maximum Battery % (Disconnect AC Adapter) :"
    read higher_limit
    [ $higher_limit -le 100 -a $higher_limit -ge 60 ] 2>/dev/null && echo stop_threshold:$higher_limit >> ABHC.config || error="yes";
}

set_threshold

while [ "$error" == "yes" ]
    do
        clear
        echo "value of minimum Battery Must be between 20-50"
        echo "value of maximum Battery Must be between 60-100"
        set_threshold
        error="no"
        clear
        echo "Thresholds Set Successfully"
    done

clear
echo "Thresholds Set Successfully"

while true
    do
        export DISPLAY=:0.0
        ac_adapter=$(acpitool -a | cut -d' ' -f10)
        battery_level=$(acpitool -B | grep 'Remaining capacity' | cut -d' ' -f9 | cut -d. -f1)
        start_threshold=$(cat ABHC.config | grep 'start_threshold' | cut -d: -f2)
        stop_threshold=$(cat ABHC.config | grep 'stop_threshold' | cut -d: -f2)

        if [ $battery_level -ge $stop_threshold ]; then
            notify-send "Battery charging above ${stop_threshold}%. Please unplug your AC adapter!" "Battery Level: ${battery_level}%"
            sleep 60
            while [ "$ac_adapter" != "off-line" ]
                do
                    notify-send -u critical "Sasura AC Adapter Nikalo !"
                    ac_adapter=$(acpitool -a | cut -d' ' -f10)
                done
        else
            if [ $battery_level -le $start_threshold ]; then
                notify-send "Battery is lower ${start_threshold}%. Need to charging! Please plug your AC adapter." "Battery Level: ${battery_level}%"
                sleep 60
                while [ "$ac_adapter" = "off-line" ]
                    do
                        notify-send -u critical "Re Bhosdiwala AC Adapter Laga !"
                        ac_adapter=$(acpitool -a | cut -d' ' -f10)
                    done
            fi
        fi
        sleep 900
    done
