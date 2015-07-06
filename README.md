# wri-bounds
Country shapefiles and boundaries for WRI

Based off NaturalEarthData.com and OpenStreetMap

**Disclaimer:** _These files are an attempt to represent the extent of countries. They do not imply endorsement or support of the claims of any country by the World Resources Institute._

### Downloads

**Shapefile**
- "Primary" countries: 189 UN member states, sans dependencies
- "All" countries: All land area
- Boundaries: International perspective
- Boundaries: China perspective
- Boundaries: India perspective

**GeoJSON**
- "Primary" countries: 189 UN member states, sans dependencies
- "All" countries: All land area
- Boundaries: International perspective
- Boundaries: China perspective
- Boundaries: India perspective

**GeoJSON - Simplified**
- "Primary" countries: 189 UN member states, sans dependencies
- "All" countries: All land area
- Boundaries: International perspective
- Boundaries: China perspective
- Boundaries: India perspective

### Source files

All files originate from two source files:

```src/countries.shp``` - Source file for "Primary countries" and "All countries"

**Key fields**

"PRIMARY" [int]
- 0:Non UN
- 1:UN Member

```src/bounds.shp``` - Source file for boundaries:

"INTL" [int]
- 0:Do not show
- 1:Dejour boundary
- 2:Disputed boundary

"CN" [int]
- 0:Do not show
- 1:Country boundary
- 2:Disputed boundary

"IN" [int]
- 0:Do not show
- 1:Country boundary
- 2:Disputed boundary
