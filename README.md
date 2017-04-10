# collections-dashboard-prep
These scripts prepare EMu collections data for a Collections Dashboard.

Catalogue records are combined with Accession records to count catalogged and backlogged items in the collections.

## How to use these scripts
0. Clone repo locally.
1. Match raw catalog dataset structure to /data01raw/CatDash03bu.csv
2. Match raw accessions dataset structure to /data01raw/AccBacklogBU.csv
3. Run this by running the "Master.R" script
+ In RStudio:
- First: `setwd("path/to/local/repo")`
- Second, run the `Master.R` script


### Notes about the raw input data
Datasets here were exported from the FMNH EMu collections database. 

Darwin Core fields were used when possible, but not all fields mapped directly to Darwin Core fields.  For example, "description" fields in accession records often includes information about "Where" as well as about "What".

The full list of ecatalogue fields is as follows:
- _Core and Quality-related fields:_
 - irn
 - DarGlobalUniqueIdentifier
 - CatDepartment
 - DarCatalogNumber
 - DarCollectionCode
 - AdmDateInserted
 - AdmDateModified
 - DarIndividualCount
 - DarBasisOfRecord
 - DarImageURL
 - DarCollector
 - CatLegalStatus
- _Where-related fields:_
 - DarLatitude
 - DarLongitude
 - DarCountry
 - DarContinent
 - DarContinentOcean
 - DarWaterBody
- _Who-related fields:_
 - DesEthnicGroupSubgroup_tab
- _What-related fields:_
 - EcbNameOfObject
 - DesMaterials_tab
 - DarOrder
 - DarScientificName
 - IdeTaxonRef_tab.ClaRank
 - IdeTaxonRef_tab.ComName_tab
 - DarRelatedInformation
 - CatProject_tab
- _When-related fields:_
 - DarEarliestAge
 - DarEarliestEon
 - DarEarliestEpoch
 - DarEarliestEra
 - DarEarliestPeriod
 - AttPeriod_tab
 - DarYearCollected
 - DarMonthCollected


### Notes about the output data
The Where/What/When/Who structure aims to more broadly accommodate both cultural and natural history datasets.
Not all cultural and natural history data is mapped to a specific
