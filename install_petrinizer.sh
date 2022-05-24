#! /bin/bash

if [ ! -f petrinizer-master.tar.gz ] ;
	then
	# step 1 : download the benchmarks from git
	# this is as far as we know the latest repo used by Petrinizer author Meyer
	wget https://gitlab.lrz.de/i7/petrinizer/-/archive/master/petrinizer-master.tar.gz
	tar xzf petrinizer-master.tar.gz
fi

