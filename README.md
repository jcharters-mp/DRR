# DRR
Stereoscopic DRR generator for the ExacTrac image-guidance system.  
This repository provides scripts for replicating ExacTrac DRRs of patients in a treatment position, with the extended capability to generate DRRs after arbitrary 6D couch repositioning.

**ITK rendering requirements:**  
* Download ITK and compile with CMake.  
* Create a project with source and binary directories. Source code is provided in the ITK folder.  
* Navigate to the binary Debug directory and copy the executables into your working folder.

<br/>

If you use or reference this repository for research purposes, please cite our publication as

```
Charters JA, Bertram P, Lamb JM. Offline generator for digitally reconstructed radiographs of a commercial stereoscopic radiotherapy image-guidance system. J Appl Clin Med Phys. 2022 Mar;23(3):e13492. doi: 10.1002/acm2.13492. Epub 2022 Feb 3. PMID: 35118788; PMCID: PMC8906216.
```
BibTeX entry:
```
@article{10.1002/acm2.13492,
author = {Charters, John A. and Bertram, Pascal and Lamb, James M.},
title = {Offline generator for digitally reconstructed radiographs of a commercial stereoscopic radiotherapy image-guidance system},
journal = {Journal of Applied Clinical Medical Physics},
year = {2022},
volume = {23},
number = {3},
pages = {e13492},
keywords = {DRR, ExacTrac, IGRT, ITK, projective geometry},
doi = {https://doi.org/10.1002/acm2.13492},
url = {https://aapm.onlinelibrary.wiley.com/doi/abs/10.1002/acm2.13492},
}
```
