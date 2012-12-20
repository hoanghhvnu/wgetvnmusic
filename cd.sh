#!/bin/bash
function cda {
	echo 'in function cd'
	echo `pwd`
	cd ~
	echo `pwd`
	echo 'end function'
}
echo `pwd`
cda
echo `pwd`
