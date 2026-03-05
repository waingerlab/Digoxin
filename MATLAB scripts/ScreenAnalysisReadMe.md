# DPR & BTZ Screen Analysis Scripts
### These MATLAB scripts were used to analyse the data produced by image analysis scripts which extract number of live cells (nuclear BFP-positive object count) and neurite outgrowth (area of continuous membrane-bound TdTomato signal). 

#### *for questions about the scripts, please contact Martha Yates (marthaamyates@gmail.com)*

Initial analysis was performed on an individual plate basis before aggregating into a large dataset for final analysis. 

## 1. Analyzing Single Files From One Screening Plate - Screen_Individual_Plate_Analysis.m
Each plate screened was analyzed following imaging to ensure quality before continuing with the next screening plate. 

#### In this script:
- cell count and neurite outgrowth at 24 and 48h post-stressor addition are normalised to their respective baseline value (6h prior to stressor addition, immediately prior to screening compound addition). 
- conditions are assigned to data
- outliers are removed if baseline cell count or neurite area are above (3rd quartile + 1.5 * IQR) or below (1st quartile -1.5 * IQR)
- Z' for the screening plate is calculated to ensure data quality
- data is plotted

#### *These scripts require the [gramm toolbox](https://github.com/piermorel/gramm) by Pierre Morel for graphing and the "subfunctions" folder*

## Getting Started
1. Ensure the paths to folders containing gramm and subfunctions are included in addpath
2. **Line 13** - add the path to the excel containing raw BFP counts and neurite area
3. **Lines 26-28** - change treatment names, keeping the ' '
4. **Lines 41-43** - change to the correct well values for each treatment, ensuring you include 0 for cols 01-09
5. **Line 60** - if you want the script to calculate Z' for this plate, make this = 'true'
6. **Lines 65-67**  - change to the appropriate local paths
7. Run script until **Line 328**, after which point choose the figures you want to produce, if any


## 2. Analyzing Aggregated Data From All Plates - Screen_Individual_Plate_Analysis.m
This script:
-  takes an input of an excel file with the analysed data from all screening plates
- calculates Z scores for every compound based on the metrics from its respective screening plate using the standard Z-score formula:

$$
\displaystyle
\ z
\ {=}
\ \frac{x- \mu}{\sigma}
$$

$$ \displaystyle
\ x= \ data point
\ \mu = mean 
\ \sigma = stdev
$$
-   Z scores are calculated both excluding and including negative controls in the population mean and standard deviation
- plots the resulting data

## Getting Started
1. Ensure the paths to folders containing gramm and subfunctions are included in addpath
2. **Line 6** - add the path to the excel containing analysed data from all plates
3. **Line 7** - change export path
4. **Line 8-10** - change to the correct names for the various treatments
5. Run script until **Line 159**, then choose desired figures to plot