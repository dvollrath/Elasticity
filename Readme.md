# The elasticity of aggregate output with respect to capital and labor
Dietrich Vollrath

## Replication of Main Results
The Code folder contains the necessary code to replicate all the results in the paper. The "Elas_Master.do" file runs everything. The only edit necessary is to change the "cd" command at the beginning to point at the directory which holds the "Data" and "Code" folders. 

The scripts expect the following folders to be present within the main directory. "Code" (which you are pulling from here). "Drafts" (which you are pulling from here). CSV" (which holds interim data and which you'll need to create as an empty folder). "Work" (which holds interim data and which you'll need to create as an empty folder). 

The "Data" folder contains....raw data. It is a set of Excel spreadsheets downloaded from the BEA (mainly) and a handful of other CSV files, whose sources are documented in the paper or Appendix. Within the Data folder there are several files I created specifically to control the code process:

1. One of the primary elements of the code is matching up industries between the I/O tables and the BEA national accounts. The "maps" controlling this match process are in the Data folder. Editing these files (they are Excel worksheets) you can adjust which industry gets mapped to which, and potentially alter the results. 

2. The paper calculates elasticities under a host of different scenarios, each of which has different assumptions about which industries are included, how capital costs are calculated, and so on. The "scenarios.csv" file is the control file that tells the code what to do in each case. The scenario ID numbers are arbitrary. The fields are explained below. You can edit this file (or add additional lines for new scenarios) to calculate elasticities for new scenarios.

Within the "Code" folder everything runs from a master script called "Elas_Master.do". It contains extensive comments as to what each sub-program does. To a large extent the code itself is commented, but without a doubt it will contain something mysterious. Feel free to contact me if you need help. 

The one thing you will need to edit in the code to replicate results is the path command in "Elas_Master.do", and set that to point towards the directory where you put all the folders for this project. 

### Scenario control
As mentioned above, the scenarios.csv file tells the code how to calculate elasticities. Each scenario is a row in the file, and the fields are as follows:

1. scenario: this is an aribtrary ID number. The only requirement is that they are unique. They do not need to be in order.

2. housing: Yes or No. Yes means housing is included in the calculations, No means it is not.

3. gov: Yes or No. Yes means goverment is included in the calculations, No means it is not.

4. farm: Yes or No. Yes means agriculture is included in the calculations, No means it is not.

5. capital: noprofit, deprcost, invcost, or usercost. These are the four options for how to calculate capital costs, as explained in the paper. 

6. proprietor: split, alllab, or allcap. This determines how propietors income is allocated to labor and capital. split allocates according to Gomme and Rupert (see paper), alllab assigns all proprietors income to labor, and allcap assigns it all to capital.

7. ip: Yes or No. Yes means IP is included as a capital type. No means IP is de-capitalized from the national accounts data, and only structures and equipment are included as capital types.

8. negative: Yes or No. Yes means capitals costs can be negative (generally affects user cost formula). No means capital costs have a floor of zero, and labor costs cannot be higher than value-added.

9. costgov: Private or BEA. Private means that government capital costs are calculated as if it were a private industry (as in a user cost formula). BEA means that government capital costs are set to depreciation only regardless of how private industries are treated. 

### Scenario references
In Part 4 of the code (scripts denoted with "Elas_Part4_XXXXX.do"), tables and figures for the paper are produced. In most of those scripts the scenario IDs are hard-coded (e.g. summ if scenario==1). This is mainly because it was much, much easier for me to pull the correct data this way (rather than matching on a bunch of control fields). So if you want to add new scenarios, you are best off creating new scenario ID numbers (37, 38, etc..) and building from there. 


