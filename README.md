# FoodNoFood
 
The dataset comes from the open dataset available [here](https://openneuro.org/datasets/ds000157/versions/00001) collected by [Smeets et al.](http://www.ncbi.nlm.nih.gov/pubmed/23578759).

The images were co-registrated using [FLIRT](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT) (FMRIB's Linear Image Registration Tool), you can find the standard template in the [standard](https://github.com/angeella/FoodNoFood/tree/main/volume) folder.

## Task design

We have 24 seconds blocks of food images (8 blocks) and non-food images (8 blocks) with 8-16 seconds rest blocks showing a crosshair (12 seconds on average). Ten seconds of break are presented in the middle of the task. The repetition time equals 1600 ms, echo time equals 23 ms. 370 scans were made in 10 minutes approximately.

## References

M. Jenkinson and S.M. Smith. A global optimisation method for robust affine registration of brain images. Medical Image Analysis, 5(2):143-156, 2001.

Smeets, P. A., Kroese, F. M., Evers, C., & de Ridder, D. T. (2013). Allured or alarmed: counteractive control responses to food temptations in https://doi.org/10.1016/j.bbr.2013.03.041

