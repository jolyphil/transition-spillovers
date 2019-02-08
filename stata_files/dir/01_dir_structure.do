********************************************************************************
* Project: Transition Spillovers
* Task:    Save the structure of the working directory
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* ______________________________________________________________________________
* Declare your own working directory

* Before running this do-file...
* Update and run the do-file `stata_files/dir/00_mydirectory.do` to store the
* path to your own working directory in a global macro ${path}

* ______________________________________________________________________________
* Folders

global data "${path}data/"

global dofiles "${path}stata_files/"
	global programs "${dofiles}programs/"
	
global figures "${path}figures/"
	global figures_eps "${figures}eps/"
	global figures_gph "${figures}gph/"
	global figures_pdf "${figures}pdf/"
	global figures_png "${figures}png/"
	
global logfiles "${dofiles}logfiles/"

global scheme "${dofiles}scheme/"

global tables "${path}tables/"
	global tables_tex "${tables}tex/"
	global tables_rtf "${tables}rtf/"

* ______________________________________________________________________________
* Graph scheme

* 	Adds a scheme directory to the beginning of the search path stored in the 
* 	global macro S_ADO.

adopath ++ "${scheme}"
