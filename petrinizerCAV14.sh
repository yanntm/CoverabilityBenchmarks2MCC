#! /bin/bash

export root=$PWD

mkdir -p petrinizer
cd petrinizer


if [ ! -f petrinizer-master.tar.gz ] ;
	then
	# step 1 : download the benchmarks from git
	# this is as far as we know the latest repo used by Petrinizer author Meyer
	wget https://gitlab.lrz.de/i7/petrinizer/-/archive/master/petrinizer-master.tar.gz
	tar xzf petrinizer-master.tar.gz
fi

# sequence for CAV'14
mkdir -p $root/CAV14
mkdir -p $root/CAV14/oracle

cd petrinizer-master/benchmarks/cav-benchmarks

# there are duplicate spec in this benchmark i.e. model+formula pair
# fdupes 
# -1 on one line
# -q quiet
# -f skip first
fdupes -q -1 -f  * | grep -P '.spec( |$)' | xargs rm -f

# each model is presented as a spec file with a reachability goal	
for i in $(find -name *.spec -print) ; 
do 
	# a unique name for the model instance
	j=$(echo $i | sed 's/\.\///' | sed 's#/#_#g' | sed 's#__#_#g' | sed 's/.spec//g')  
	mkdir -p $j ; 
	cd $j ; 
    $root/itstools/its-tools -convert ../$i -o ./
	# trace to source
	cp ../$i . 
	cd .. ;
	(echo $j ReachabilityCardinality ; echo "FORMULA target ? TECHNIQUES NONE") > $j-RC.out
	(echo $j ReachabilityDeadlock ; echo "FORMULA ReachabilityDeadlock ? TECHNIQUES NONE") > $j-RD.out
	(echo $j OneSafe ; echo "FORMULA OneSafe ? TECHNIQUES NONE") > $j-OS.out
	mv *.out $root/CAV14/oracle/
	tar czf $j.tgz $j/
	mv $j.tgz $root/CAV14/
	rm -rf $j/	
done;

cd $root/CAV14

# merging similar models detected using fdupes to detect them
for i in *.tgz ; 
do
	tar xzf $i
done	
	

# nasty one liner to get rid of duplicates
(fdupes -1 */ | grep -v xml | grep -v spec) | while read -r line ; do cpt=0 ; for i in $line ; do folder=$(echo $i | sed 's#/model.pnml##g') ; if [ $cpt -eq 0 ] ; then main=$folder ; fi ; cp $folder/ReachabilityCardinality.xml $main/ReachabilityCardinality.$cpt.xml ; if [ $cpt -ne 0 ] ; then rm -rf $folder ; else rm $folder/ReachabilityCardinality.xml fi ;  cpt=$((cpt+1)) ; done ; done ;
	
# rebuild a set of tgz
rm *.tgz

for i in * ; do tar czf $i.tgz $i/ ; rm -r $i/ ; done ;


tree -H "." > index.html

cd ..

