# CoverabilityBenchmarks2MCC

A project that builds and hosts "coverability" problems in the MCC format.

The Model Checking Contest MCC is a competition using Petri nets specified in the iso standard PNML format as input and supporting a variety of properties.
In 2021, the MCC contained 1411 models coming from 192 sources forming a vast benchmark of mostly bounded Petri nets.

On the other hand many tools mostly focused coverability problems such as Mist or Petrinizer use a variety of formats and have collected large benchmarks as well.

This project focuses on translating these benchmark models to MCC format to allow comparison of MCC competitors and tools specialized in coverability.

Currently supported formats :
* .pnet format of Petrinizer (no support for "liveness" property translation)
* .lola and .task formats of Lola
* .tpn format
* .spec format of Mist

The MCC/pnml versions of benchmarks extracted from Petrinizer (see https://gitlab.lrz.de/i7/petrinizer) are built using GH actions and are made available on branches of this repo: 
* cav14 : https://github.com/yanntm/CoverabilityBenchmarks2MCC/tree/cav14 This is a benchmark used in Petrinizer CAV'14 paper
* scalable : https://github.com/yanntm/CoverabilityBenchmarks2MCC/tree/scalable This is a subset of the benchmark used in Petrinizer FMCAD'15 paper

