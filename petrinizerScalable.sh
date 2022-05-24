#! /bin/bash

set -x

export root=$PWD

mkdir -p petrinizer
cd petrinizer

$root/install_petrinizer.sh

# sequence for CAV'14
mkdir -p $root/Scalable
mkdir -p $root/Scalable/oracle

cd petrinizer-master/benchmarks/scalable

# generate pnet files
for i in */ ; do 
	cd $i ; 
	j=$(echo $i | sed s#/##g) ; 
	if [ -f make_nets.sh ] ; then 
		./make_nets.sh 7 ;
		rm n1.pnet 
	else 
		python make_net.py > $j.pnet ; 
	fi ; 
	cd .. ; 
done

# each model is presented as a tpn file with a liveness goal	
for i in $(find -name *.pnet -print) ; 
do 
	# a unique name for the model instance
	j=$(echo $i | sed 's/\.\///' | sed 's#/#_#g' | sed 's#__#_#g' | sed 's/.pnet//g')  
	mkdir -p $j ; 
	cd $j ; 
    $root/itstools/its-tools -convert ../$i -o ./
	# trace to source
	cp ../$i . 
	cd .. ;
	(echo $j ReachabilityDeadlock ; echo "FORMULA ReachabilityDeadlock ? TECHNIQUES NONE") > $j-RD.out
	(echo $j OneSafe ; echo "FORMULA OneSafe ? TECHNIQUES NONE") > $j-OS.out
	mv *.out $root/Scalable/oracle/
	tar czf $j.tgz $j/
	mv $j.tgz $root/Scalable/
	rm -rf $j/	
done;


tree -H "." > index.html

cd ..

