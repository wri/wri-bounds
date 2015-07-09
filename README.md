# wri-bounds
Country shapefiles and boundaries for WRI

Based off NaturalEarthData.com

**DISCLAIMER** _These files are an attempt to represent country areas and boundaries from several perspectives. They do not imply any opinion on the part of the World Resources Institute concerning the legal status or delineation of any country or territory, nor do they imply endorsement of the represented country areas or boundaries._

### Downloads

Data are organized into three perspectives: 'US', 'China (CN)', and 'India (IN)'. For most purposes the 'US' perspective should be sufficient.

**Shapefiles**

Data | Description | Links by perspective
------ | ------ | ------
"Primary" countries | UN member states, observers, sans dependencies | [US]/[CN]/[IN]
"All" countries | All land area | [US]/[CN]/[IN]
All boundaries | Cartographic boundaries (see below) | [All]
Non-disputed | Cartographic boundaries | [US]/[CN]/[IN]
Disputed | Cartographic boundaries | [US]/[CN]/[IN]

**GeoJSON**

Data | Description | Links by perspective
------ | ------ | ------
"Primary" countries | UN member states observers, sans dependencies | [US]/[CN]/[IN]
"All" countries | All land area | [US]/[CN]/[IN]
All boundaries | Cartographic boundaries (see below) | [All]
Non-disputed | Cartographic boundaries | [US]/[CN]/[IN]
Disputed | Cartographic boundaries | [US]/[CN]/[IN]

**Key fields**

Countries:"PRIMARY"
- 0:Non UN
- 1:UN Member / Observer

Boundaries:"INTL" - 'US' perspective
- 0:Do not show
- 1:Country boundary
- 2:Disputed boundary

Boundaries:"CHN" - 'China' perspective
- 0:Do not show
- 1:Country boundary
- 2:Disputed boundary

Boundaries:"IND" - 'India' perspective
- 0:Do not show
- 1:Country boundary
- 2:Disputed boundary

### Build

Requires [GDAL/OGR](http://www.gdal.org/index.html).

OS X Macports
```sudo port install gdal```

Ubuntu
```sudo apt-get install gdal-dev```

Source data processed in [process-boundaries](http://github.com/wri/process-bounds/ repository.
