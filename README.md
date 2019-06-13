# Master Thesis
This repository contains my master thesis and the presentation.
Please see the corresponding files.
 * poposal.tex
 * thesis.tex
 * presentation.tex

Furthermore, the repository performs CI and saves the artifacts as releases.

It is still work in progress.

## Build Configurations
There are several build configurations available:
* [Azure Pipelines](azure-pipelines.yml) (currently in use on GitHub)
* [GitLab CI](.gitlab-ci.yml) (currently in use on GitLab)
* [TravisCI](.travis.yml) (old CI configuration which had issues with the list of acronyms)

## Build Status
* Azure: [![Build Status](https://dev.azure.com/kource/FHWN/_apis/build/status/mrdavidkovacs.MasterThesis?branchName=master)](https://dev.azure.com/kource/FHWN/_build/latest?definitionId=13&branchName=master)

* GitLab: [![pipeline status](https://gitlab.com/mr.david.kovacs/MasterThesis/badges/master/pipeline.svg)](https://gitlab.com/mr.david.kovacs/MasterThesis/commits/master)

# Templates for FHWN

This repo contains several templates for FH Wiener Neustadt (University of Applied Sciences) in Wiener Neustadt, Austria.

## Thesis
The most important styles are extracted to a new LaTeX class (see [fhwn-masterthesis.cls](includes/fhwn-masterthesis.cls))
The required files may be extracted to another repository after the study program.

Some thesis specific functions/variables are extracted to 
* [masterthesis-definitions.sty](includes/masterthesis-definitions.sty)
* [masterthesis-vars.sty](includes/masterthesis-vars.sty)

Furthermore, this repository includes the font "Tw Cen MT" which is required by the thesis class.

## Presentation

There is a beamer theme located at the root level:
 * [Theme](beamerthemeFHWN.sty)
 * [Font Theme](beamerfontthemeFHWN.sty)
 * [Color Theme](beamercolorthemeFHWN.sty)