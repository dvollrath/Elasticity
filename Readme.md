# The elasticity of aggregate output with respect to capital and labor
Dietrich Vollrath

## Replication of Main Results
The Code folder contains the necessary code to replicate all the results in the paper. The "Elas_Master.do" file runs everything. The only edit necessary is to change the "cd" command at the beginning to point at the directory which holds the "Data" and "Code" folders. 

The scripts expect the following folders to be present within the main directory. "Code" (which you are pulling from here). "Drafts" (which you are pulling from here). CSV" (which holds interim data and which you'll need to create as an empty folder). "Work" (which holds interim data and which you'll need to create as an empty folder). 

You will also need the raw "Data" folder, which should be put under the main directory. You can get this Data folder [here](https://www.dropbox.com/sh/g57jaey2jbhsv25/AAC30G8zMgE-1nvMYaVcchJxa?dl=0). It's too large to host on Github, so you have to grab it separately. Yes, I'm mixing Dropbox and Github. The universe continues to spin. 

The "Elas_Master.do" file contains comments explaining what each section of code does. To a large extent the code itself is commented, but without a doubt it will contain something mysterious. Feel free to contact me if you need help. 

## BEA/NAICS mapping
One of the primary elements of the code is matching up industries between the I/O tables and the BEA national accounts. The "maps" controlling this match process are contained in the "Data" folder, underneath the "USA" sub-folder. Editing these files (they are Excel worksheets) you can adjust which industry gets mapped to which, and potentially alter the results. 