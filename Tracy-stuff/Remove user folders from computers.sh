#!/bin/sh

for home in $(ls /Users | grep -v Admin | grep -v Shared | grep -v labsetup | grep -v Guest | grep -v tdilossi | grep -v techdept | grep -v $3)
do
sudo rm -rf /Users/$home
done
