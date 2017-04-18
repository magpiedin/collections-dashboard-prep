# collections-dashboard-prep
These scripts prepare EMu collections data for a Collections Dashboard.

Catalogue records are combined with Accession records to count catalogued and backlogged items in the collections.

## How to use these scripts
1. Clone repo locally.
2. Match raw catalog dataset structure to /data01raw/CatDash03bu.csv
3. Match raw accessions dataset structure to /data01raw/AccBacklogBU.csv
4. Run this by running the Master.R script

To run Master.R in RStudio:
- First: `setwd("path/to/local/repo")`
- Second, run the `Master.R` script


### Notes about fields in the raw input data
Datasets here were exported from the FMNH EMu collections database. Darwin Core fields were used when possible, but not all fields mapped directly to Darwin Core fields.  For example, "description" fields in accession records often includes information about "Where" as well as about "What".

#### The full list of ecatalogue fields is as follows:
_Core and Quality-related fields:_
 - irn
 - DarGlobalUniqueIdentifier
 - CatDepartment
 - DarCatalogNumber
 - DarCollectionCode
 - AdmDateInserted
 - AdmDateModified
 - DarIndividualCount
 - DarBasisOfRecord
 - DarImageURL (to be replaced by "MulHasMultiMedia")
 - DarCollector
 - CatLegalStatus
 
_Where-related fields:_
 - DarLatitude
 - DarLongitude
 - DarCountry
 - DarContinent
 - DarContinentOcean
 - DarWaterBody
 
_Who-related fields:_
 - DesEthnicGroupSubgroup_tab
 
_What-related fields:_
 - EcbNameOfObject
 - DesMaterials_tab
 - DarOrder
 - DarScientificName
 - IdeTaxonRef_tab.ClaRank
 - IdeTaxonRef_tab.ComName_tab
 - DarRelatedInformation
 - CatProject_tab
 - IdeFiledAs_tab (to be added)
 
_WhenAge-related fields:_
 - DarEarliestAge
 - DarEarliestEon
 - DarEarliestEpoch
 - DarEarliestEra
 - DarEarliestPeriod
 - AttPeriod_tab
 - DarYearCollected
 - DarMonthCollected

#### The full list of efmnhtransactions (accession record) fields is as follows:
_Count-related fields (used for calculating backlogged items):_
 - irn
 - AccCatalogue
 - AccTotalItems
 - AccTotalObjects
 - AccCount_tab
 - PriAccessionNumberRef.CatCatalog
 - PriAccessionNumberRef.DarIndividualCount
 - PriAccessionNumberRef.irn
 - PriAccessionNumberRef.DarBasisOfRecord
 - PriAccessionNumberRef.CatItemsInv
 
_What- & Who-related fields:_
 - AccDescription_tab
 - AccAccessionDescription

_Where-related fields:_
 - AccGeography_tab
 - AccLocality
 - AccCollectionEventRef.ColSiteRef.LocContinent_tab
 - AccCollectionEventRef.ColSiteRef.LocCountry_tab
 - AccCollectionEventRef.ColSiteRef.LocOcean_tab

### Notes about fields in the output "FullDash" dataset
#### Where, What, WhenAge, Who
These fields broadly accommodate both cultural and natural history datasets, incorporating standard Darwin Core fields when possible.  The input dataset groupings (listed above) indicate which input fields correspond to these output fields.
#### Quality
A ranking based on the following criteria (poor = 9; good = 1):
 - 9 = Digital accession record exists
 - 8 = Total Object (lots) > 0 OR Total Items (specimens) > 0
 - 7 = Locality Not Null
 - 6 = Catalogue # Not NULL
 - 5 = Reverse attached catalogue records Not NULL
 - 4 = Has Digital Catalogue record
 - 3 = Has _Partial Data_
 - 2 = PriCoordinateIndicator = Yes OR HasMultimedia = Yes
 - 1 = PriCoordinateIndicator = Yes AND HasMultimedia = Yes AND Has _Full Data_ = Yes
 
 _Partial Data_ = Has 3 or 4 of the following:
 - IdeTaxonRef_tab.ClaRank = Family, Genus, Species, Subpecies or Variety
 - DarStateProvince Not NULL
 - DarCollector Not NULL
 - DarYearCollected Not NULL
 - DarCatalogNumber Not NULL
 
 _Full Data_ = Has all 5 of the above
 
#### RecordType
Indicates whether the record is "Catalog" or "Accession" data, and therefore part of the catalogued or backlogged items.
#### DarIndividualCount
The number of items catalogued, from the DarIndividualCount field of a catalogue record.
#### Backlog
The number of items backlogged = the number of catalogued items subtracted from the number accessioned items.
#### TaxIDRank
The level to which a specimen has been identified
#### HasMM
A binary value where "1" = has Multimedia attached, and "0" = no Multimedia attached.
#### DarCollectionCode & Department
The name of the collection and department to which a record belongs.
#### URL
Collections listed in summary stats will link to these URLs
#### WhenAgeFrom/To/Mid & DarYearCollected
Numeric values for age of geology specimens & anthropolgy artifacts, or for collection year for botany & zoology specimens.
#### WhenOrder
Ordinal values between 1 and 53 to group numeric ages into time-groups; necessary for chart to function.
#### WhenTimeLabel
Labels corresponding to the 53 "WhenOrder" groups, ranging from 4.6 billion years ago to 2020. Loosely, ranges are grouped by geologic periods/epochs/eras prior to ~18th century dates, and grouped by decade after 18th century dates.
