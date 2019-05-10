# MasterThesis
This repository contains my master thesis and the presentation.
Please see the corresponding files.
 * thesis.tex
 * presentation.tex

Furthermore, the repository performs CI and saves the artifacts as releases.

It is still work in progress.

## Build Status
[![Build Status](https://dev.azure.com/kource/FHWN/_apis/build/status/mrdavidkovacs.MasterThesis?branchName=master)](https://dev.azure.com/kource/FHWN/_build/latest?definitionId=13&branchName=master)

## Issues
One thing which won't work is the glossary (list of acronyms) for the thesis.pdf.

# Thesis template for FHWN (FH Wiener Neustadt, University of Applied Sciences in Wiener Neustadt)
The most important styles are extracted to a new LaTeX class (see [fhwn-masterthesis.cls](includes/fhwn-masterthesis.cls))

Some thesis specific functions/variables are extracted to 
* [masterthesis-definitions.sty](includes/masterthesis-definitions.sty)
* [masterthesis-vars.sty](includes/masterthesis-vars.sty)

Furthermore, this repository includes the font "Tw Cen MT".