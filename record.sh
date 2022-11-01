#!/bin/bash

for (( ; ; ))

do

NAME=`date +%m-%d-%Y_%H-%M-%S`

rec -c 1 -r 22050 $NAME.mp3 trim 0 15:00 silence 1 0 8% -1 00:00:05 8%

echo "Done."

done
