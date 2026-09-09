---
---

# CIPE-Project-Samuele-Magatti



## Project Objectives 

The main objective of this project is to analyze the impact of the WAO policy in Netherlands and its effects during the oil crisis.  

## Dataset

Due to its size the dataset is not included in this repository. To correctly download it follow the instructions present in the first part of the code





## Project Structure

CIPE-Project-Samuele-Magatti/


└── cipe_project_clean_main 

└── cipe_project_clean_support 

└── cipe_project_analysis

└── CIPE PROJECT

└── README.md



## Installation and requirements

In order to be able to run this project make sure you have installed the Stata program



## Methodology


#### DID

In order to asses the analysis and to evaluate the policy impact a did approach was implemented, the data from the Netherlands were thus confronted with the data from Denmark, that at the time had a different welfare system and a different policy approach in fighting unemployment. 

#### DDD

Also a triple difference in difference approach was used in order to focus the analysis on the policy impact on the male contribution to labour force.

#### CHECKS OF THE IDENTIFYING ASSUMPTIONS AND RESULTS

To test the identifyng assumptions is used standard pre-trend and placebo test for the did part and pre-trend for the DDD, an event study was also done for the diff-in-diff part.

## Results

All the analysis and the results are contained in the file called CIPE PROJECT, for further informations about the  results refer to the uppersaid file.

##  Notes

The files in the project structure are organized in the following way:
the document called cipe_project_clean_main contains the  code to download and build the dataset, the 
cipe_project_clean_support document contains the code for the plots, while the last .do document contains the code used for the analysis. Finally the CIPE PROJECT file contains all the analysis and the consideration regarding  historical ,political social context. Run each part of the STATA code separately to avoid bugs. In order to run this code it is necesary to have three empty folders on your PC, one called data_raw, one called data_clean and the last called Output.





this project is published under the MIT License - see the [LICENSE](LICENSE) file for details.
