
AED_Tools is the prefered starting point for downloading source trees for AED projects. It contains
fetch_sources scripts for Unix based (Linux/Mac) or windows to download or update Source trees for
GLM, libfvaed2 and libaed2. There are also some useful scripts in admin to help track changes.

AED_Tools_Private is like AED_Tools but for AED internal use - it also has support for TuflowFV.

The fetch_sources.sh script includes the option to extract tuflowfv sources and gotm sources from
our internal git server the gotm is need by tuflowfv but it requires an older version than that
currently in gotm's repository.

NB: fetch will only work if you have set up github's security requirement in terms of an ssh key.
