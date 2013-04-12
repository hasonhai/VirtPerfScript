#!/bin/bash
for xplfile in `find *.xpl` 
do
   echo processing $xplfile
   sh ~/VirtualizationProject/xpl2gpl.sh $xplfile
done

