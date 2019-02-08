********************************************************************************
* Project: Transition Spillovers
* Task:    Perform the analysis
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* Important:

* Run stata_files/dir/00_mydirectory.do before executing this master do-file.
* 	00_mydirectory.do saves your working directory and loads paths to the 
*	folders of the repository in global macros.

set more off

* ______________________________________________________________________________
* Run all do-files
	
do "${dofiles}01_descriptives.do"
	// Task: Generate and export descriptive graphs
	
do "${dofiles}02_ML_analysis.do"
	// Task: Run the multilevel analysis
