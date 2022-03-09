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
Charters, JA, Bertram, P, Lamb, JM. Offline generator for digitally reconstructed radiographs of a commercial stereoscopic radiotherapy image-guidance system. J Appl Clin Med Phys. 2022; 23:e13492. https://doi.org/10.1002/acm2.13492
```
BibTeX entry:
```
@article{https://doi.org/10.1002/acm2.13492,
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
eprint = {https://aapm.onlinelibrary.wiley.com/doi/pdf/10.1002/acm2.13492},
abstract = {Abstract Purpose Image-guided radiotherapy (IGRT) research sometimes involves simulated changes to patient positioning using retrospectively collected clinical data. For example, researchers may simulate patient misalignments to develop error detection algorithms or positioning optimization algorithms. The Brainlab ExacTrac system can be used to retrospectively “replay” simulated alignment scenarios but does not allow export of digitally reconstructed radiographs (DRRs) with simulated positioning variations for further analysis. Here we describe methods to overcome this limitation and replicate ExacTrac system DRRs by using projective geometry parameters contained in the ExacTrac configuration files saved for every imaged subject. Methods Two ExacTrac DRR generators were implemented, one with custom MATLAB software based on first principles, and the other using libraries from the Insight Segmentation and Registration Toolkit (ITK). A description of perspective projections for DRR rendering applications is included, with emphasis on linear operators in real projective space P3\${\mathbb{P}^3}\$. We provide a general methodology for the extraction of relevant geometric values needed to replicate ExacTrac DRRs. Our generators were tested on phantom and patient images, both acquired in a known treatment position. We demonstrate the validity of our methods by comparing our generated DRRs to reference DRRs produced by the ExacTrac system during a treatment workflow using a manual landmark analysis as well as rigid registration with the elastix software package. Results Manual landmarks selected between the corresponding DRR generators across patient and phantom images have an average displacement of 1.15 mm. For elastix image registrations, we found that absolute value vertical and horizontal translations were 0.18 and 0.35 mm on average, respectively. Rigid rotations were within 0.002 degrees. Conclusion Custom and ITK-based algorithms successfully reproduce ExacTrac DRRs and have the distinctive advantage of incorporating any desired 6D couch position. An open-source repository is provided separately for users to implement in IGRT patient positioning research.}
}
```
