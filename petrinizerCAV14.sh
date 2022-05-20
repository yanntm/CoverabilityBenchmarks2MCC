#! /bin/bash

export root=$PWD

mkdir -p petrinizer
cd petrinizer

# step 1 : download the benchmarks from git
# this is as far as we know the latest repo used by Petrinizer author Meyer
wget https://gitlab.lrz.de/i7/petrinizer/-/archive/master/petrinizer-master.tar.gz
tar xvzf petrinizer-master.tar.gz

# sequence for CAV'14
mkdir -p $root/CAV14
mkdir -p $root/CAV14/oracle

cd benchmarks/cav-benchmarks

# each model is presented as a spec file with a reachability goal	
for i in $(find -name *.spec -print) ; 
do 
	# a unique name for the model instance
	j=$(echo $i | sed 's/\.\///' | sed 's#/#-#g' | sed 's/.spec//g') ; 
	mkdir -p $j ; 
	cd $j ; 
	$root/spec2pnml.sh ../$i ;
	# trace to source
	cp ../$i . 
	cd .. ;
	(echo $j ReachabilityCardinality ; echo "FORMULA target ? TECHNIQUES NONE") > $j-RC.out
	(echo $j ReachabilityDeadlock ; echo "FORMULA ReachabilityDeadlock ? TECHNIQUES NONE") > $j-RD.out
	(echo $j OneSafe ; echo "FORMULA OneSafe ? TECHNIQUES NONE") > $j-OS.out
	mv *.out $root/CAV14/oracle/
	mv $j $root/CAV14/	
done; 

