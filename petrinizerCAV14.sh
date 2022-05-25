#! /bin/bash

export root=$PWD

mkdir -p petrinizer
cd petrinizer

$root/install_petrinizer.sh

# sequence for CAV'14
mkdir -p $root/CAV14

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
(fdupes -1 */ | grep -v xml | grep -v spec) | while read -r line ; do 
	cpt=0 ; 
	for i in $line ; 
	do 
		folder=$(echo $i | sed 's#/model.pnml##g') ; 
		if [ $cpt -eq 0 ] ; then 
			main=$folder ; 
		fi ; 
		cp $folder/ReachabilityCardinality.xml $main/ReachabilityCardinality.$cpt.xml ; 
		if [ $cpt -ne 0 ] ; then 
			rm -rf $folder ; 
		else 
			rm $folder/ReachabilityCardinality.xml 
		fi 
		cpt=$((cpt+1)) ; 
	done ; 
done ;

# we can now fuse the properties back into one file
for folder in */ ;
do
	cd $folder
	
	if [ -f ReachabilityCardinality.0.xml ] ;
	then
		# rename id of properties to different values
		for i in ReachabilityCardinality.*.xml ;
		do 
			j=$(echo $i | sed 's/.xml//g')
			sed -i "s/target/$j/g" $i
		done
		# now merge into result
		target=ReachabilityCardinality.xml
		head -2 ReachabilityCardinality.0.xml > $target
		for i in ReachabilityCardinality.*.xml ;
		do 
			(tail -n +3 $i | head -n -2) >> $target						
		done
		tail -2 ReachabilityCardinality.0.xml >> $target
		rm ReachabilityCardinality.*.xml
	fi	
	cd ..	
done

	
# rebuild a set of tgz
rm *.tgz

for i in * ; do tar czf $i.tgz $i/ ; rm -r $i/ ; done ;

for i in *.tgz ; do 
	j=$(echo $i | sed 's/.tgz//g') ; 
	(echo "$j StateSpace" ; echo "FORMULA STATESPACE ?") > $j-SS.out ; 
	(echo "$j ReachabilityCardinality" ; echo "FORMULA Reachable ?") > $j-RC.out ; 
	(echo "$j ReachabilityDeadlock" ; echo "FORMULA Reachability ?") > $j-RD.out ; 
	(echo "$j OneSafe" ; echo "FORMULA OneSafe ?") > $j-OS.out ; 
	(echo "$j QuasiLiveness" ; echo "FORMULA QuasiLiveness ?") > $j-QL.out ; 
	(echo "$j Liveness" ; echo "FORMULA Liveness ?") > $j-QL.out ; 
	(echo "$j StableMarking" ; echo "FORMULA StableMarking ?") > $j-QL.out ; 
done ;

mkdir -p $root/CAV14/oracle
mv *.out $root/CAV14/oracle/
tar czf oracle.tgz oracle/
rm -r oracle/

tree -H "." > index.html

cd ..



