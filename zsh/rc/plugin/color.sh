#!/bin/bash

printf "FOREGROUND: 38;05;\${COLOR_NUMBER}\nBACKGROUND: 48;05;\${COLOR_NUMBER}\n"

for j in {3..4}; do for i in {0..255}; do
  if [ $(( ${i}%16 )) -eq 0 ];then printf "\n"; fi
  printf "\x1b[${j}8;05;${i}m%4d" ${i}
done; done
