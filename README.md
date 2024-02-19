# Project
Thalamocortical triple-network dysconnectivities in psychosis ([Kim, M., **Kim, T.** et al. 2022, *Schizophr Bull*](https://doi.org/10.1093/schbul/sbac174)).
- Identification of network modules of cortex and thalamus using an InfoMap algorithm (https://www.mapequation.org/infomap/) for community detection.

> ref to [Hwang, K. et al. 2017, J Neurosci](https://doi.org/10.1523/jneurosci.0067-17.2017): Modularity-based thalamic parcellation.

---
# Atlas created using resting-state fMRI data
- ./cortMod_parc_6mods/**cortNet_mods.nii.gz:** cortical modular networks
- ./thalMod_parc_6mods/**thalNet_mods.nii.gz:** thalamic modular networks
- data from 273 individuals with (high risk for) psychosis or without any psychiatric disorder (healthy volunteers).
- data acquisition from Dept of Psychiatry at Seoul National University Hospital (PI: Prof. Jun Soo Kwon).

---
# Codes
## Cortical network identification
### 1. Construction of cortico-cortical connectivity matrix (subject-level)
- used the [Godon atals](https://doi.org/10.1093/cercor/bhu239) (333 regions).
- **01_thr_conn.m:** iteratively thresholded the connectivity map of each subject, ranging from 15% to 1% in steps of 0.1% connectivity density.
- returns ./linkArray/Subj##/**clink_thr###.net**.

### 2. Identification of cortical network modules (subject-level)
- **02_prepCortmod.sh:** used the [InfoMap algorithm](https://www.mapequation.org/infomap/).
- returns ./linkArray/Subj##/modOut/**clink_thr###.clu**.
- sample data: Subj01

### 3. Finding a consensus from the modularitiy data (subject-level)
- **cortmod_01_update.ipynb:** updating a consensus matrix across the ranges (descending order).
- returns ./linkArray/consMats/**consMat_Subj##.csv**.

### 4. Group-level cortical network mapping (repeat steps 1~3)
- **cortmod_02_group.ipynb:** avaraging subject-level modularity matrices, returning ./linkArray/**consMatDM_low.csv**.
- **03_cortmod_thrConn.m:** thresholding group-level cortico-cortical connectivity matrix, returing ./linkArray/links_group/**clink_thr###.net**.
- **04_runCortmod_grp.sh:** identifying group-level cortical network modules, returing ./linkArray/links_group/modOut/**clink_thr###.clu**.
- **cortmod_02_group.ipynb:** updating a group-level consensus matrix across the ranges, returning ./linkArray/links_group/modOut/**cortmod_grp.csv**.
- **05_cortMod_parc_6mods.sh:** merging nodes to creat modular networks.

## Thalamic network parcellation
### **06_thal_parcel.m:**
- used the [Morel thalamus atlas](https://doi.org/10.1016/j.neuroimage.2009.10.042)
- partial correlation between thalamic voxels and mean timeseries of each cortical module.
- controlling for signals from rest of the cortical modules.
- a winnter-take-all parcellation approach: assigning network labels where having the largest corr coeff.
