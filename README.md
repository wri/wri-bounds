# wri-bounds
Country shapefiles and boundaries for WRI

Based off NaturalEarthData.com

**DISCLAIMER** _These files are an attempt to represent country areas and boundaries from several perspectives. They do not imply any opinion on the part of the World Resources Institute concerning the legal status or delineation of any country or territory, nor do they imply endorsement of the represented country areas or boundaries._

### Downloads

Data are organized into three perspectives: 'US', 'China (CN)', and 'India (IN)'.

A [CSV](https://github.com/wri/wri-bounds/blob/master/dist/all_bounds.zip?raw=true) of names and other attributes is also available.

**Shapefiles**

Data | Description | Links by perspective
------ | ------ | ------
"Primary" countries | UN member states, observers, sans dependencies | [US](https://github.com/wri/wri-bounds/blob/master/dist/all_primary_countries.zip?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/china_primary_countries.zip?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/india_primary_countries.zip?raw=true)
"All" countries | All land area | [US](https://github.com/wri/wri-bounds/blob/master/dist/all_countries.zip?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/china_countries.zip?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/india_countries.zip?raw=true)
All boundaries | Cartographic boundaries (see below) | [All](https://github.com/wri/wri-bounds/blob/master/dist/all_bounds.zip?raw=true)
Non-disputed | Cartographic boundaries | [US](https://github.com/wri/wri-bounds/blob/master/dist/intl_country_bounds.zip?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/cn_country_bounds.zip?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/in_country_bounds.zip?raw=true)
Disputed | Cartographic boundaries | [US](https://github.com/wri/wri-bounds/blob/master/dist/intl_disputed_bounds.zip?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/cn_disputed_bounds.zip?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/in_disputed_bounds.zip?raw=true)

**GeoJSON**

Data | Description | Links by perspective
------ | ------ | ------
"Primary" countries | UN member states, observers, sans dependencies | [US](https://github.com/wri/wri-bounds/blob/master/dist/all_primary_countries.geojson?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/china_primary_countries.geojson?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/india_primary_countries.geojson?raw=true)
"All" countries | All land area | [US](https://github.com/wri/wri-bounds/blob/master/dist/all_countries.geojson?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/china_countries.geojson?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/india_countries.geojson?raw=true)
All boundaries | Cartographic boundaries (see below) | [All](https://github.com/wri/wri-bounds/blob/master/dist/all_bounds.geojson?raw=true)
Non-disputed | Cartographic boundaries | [US](https://github.com/wri/wri-bounds/blob/master/dist/intl_country_bounds.geojson?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/cn_country_bounds.geojson?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/in_country_bounds.geojson?raw=true)
Disputed | Cartographic boundaries | [US](https://github.com/wri/wri-bounds/blob/master/dist/intl_disputed_bounds.geojson?raw=true)/[CN](https://github.com/wri/wri-bounds/blob/master/dist/cn_disputed_bounds.geojson?raw=true)/[IN](https://github.com/wri/wri-bounds/blob/master/dist/in_disputed_bounds.geojson?raw=true)

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

### Attribute table [CSV](https://github.com/wri/wri-bounds/blob/master/dist/countries.csv)

Column | Description | Source
iso_short | ISO Short Name | ISO 3166
name | **Country name** | Natural Earth Data
formal\_name | Full formal country name | Natural Earth Data
short\_name | Short country name | Natural Earth Data
abbrev | Country name abbreviation | Natural Earth Data
un\_ar | UN GEGN Arabic name | UN GEGN
un\_zh | UN GEGN Chinese name | UN GEGN
un\_en | UN GEGN English name | UN GEGN
un\_fr | UN GEGN French name | UN GEGN
un\_ru | UN GEGN Russian name | UN GEGN
un\_es | UN GEGN Spanish name | UN GEGN
adm0\_a3 | Country Code | Natural Earth Data
postal | Postal Code | Natural Earth Data
iso\_a2 | ISO A2 Code | ISO 3166
iso\_a3 | ISO A3 Code | Natural Earth Data
iso\_n3 | ISO N3 Code | Natural Earth Data
un\_n3 | UN N3 Code | Natural Earth Data
wb\_a2 | World Bank A2 code | Natural Earth Data
wb\_a3 | World Bank A3 code | Natural Earth Data
type | Country type |
continent | Continent | Natural Earth Data
un\_region | UN Region | Natural Earth Data
un\_subregion | UN Subregion | Natural Earth Data
wb\_region | World Bank Region | Natural Earth Data

### Build

Requires [GDAL/OGR](http://www.gdal.org/index.html).

OS X Macports
```sudo port install gdal```

Ubuntu
```sudo apt-get install gdal-dev```

Source data processed in [process-boundaries](http://github.com/wri/process-bounds/ repository.
