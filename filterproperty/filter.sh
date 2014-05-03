#!/bin/bash

templatepath=$1
propertypath=$2

awk -v pfp="$propertypath" -f function.awk -f main.awk $templatepath 
