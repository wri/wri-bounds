

SRCS=src/china_countries.zip src/india_countries.zip \
	src/all_bounds.zip src/all_countries.zip

CTR_ALL=build/all_countries.shp
CTR_PRIMARY=build/all_primary_countries.shp
CTR_CN_PRIMARY=build/china_primary_countries.shp
CTR_IN_PRIMARY=build/india_primary_countries.shp

BND=src/all_bounds.shp
BND_ALL=build/all_bounds.shp
BND_INTL=build/intl_country_boundaries.shp
BND_CN=build/cn_country_boundaries.shp
BND_IN=build/in_country_boundaries.shp
BND_INTL_DIS=build/intl_disputed_boundaries.shp
BND_CN_DIS=build/cn_disputed_boundaries.shp
BND_IN_DIS=build/in_disputed_boundaries.shp

BNDS:=$(BND_ALL) $(BND_INTL) $(BND_CN) $(BND_IN) \
	$(BND_INTL_DIS) $(BND_CN_DIS) $(BND_IN_DIS)

CTRS:=$(CTR_ALL) $(CTR_PRIMARY) $(CTR_CN) $(CTR_CN_PRIMARY) \
	$(CTR_IN) $(CTR_IN_PRIMARY)

all: $(SRCS) zips geojson dist/countries.csv
	rm -rf build

zips: $(patsubst build/%.shp, dist/%.zip, $(CTRS) $(BNDS))

geojson: $(patsubst build/%.shp, dist/%.geojson.gz, $(CTRS) $(BNDS))

dist/%.zip: build/%.shp | dist
	zip $@ $(basename $<).*

dist/%.geojson.gz: dist/%.geojson | dist
	gzip $<

dist/%.geojson: build/%.shp dist
	ogr2ogr -f GeoJSON $@ $<

dist/countries.csv: 
	curl -o $@ https://raw.githubusercontent.com/wri/process-boundaries/master/wri_countries.csv

src/%.zip: | src
	curl -o $@ https://raw.githubusercontent.com/wri/process-boundaries/master/dist/$(notdir $@)

src/%.shp: src/%.zip
	unzip -o $< -d src

build/%_primary_countries.shp: src/%_countries.shp | build
	ogr2ogr -where PRIMARY="1" $@ $< -lco ENCODING=UTF-8

$(BNDS): $(BND) | build
	ogr2ogr -where INTL="1" $(BND_INTL) $< -lco ENCODING=UTF-8
	ogr2ogr -where INTL="2" $(BND_INTL_DIS) $< -lco ENCODING=UTF-8
	ogr2ogr -where CHN="1" $(BND_CN) $< -lco ENCODING=UTF-8
	ogr2ogr -where CHN="2" $(BND_CN_DIS) $< -lco ENCODING=UTF-8
	ogr2ogr -where IND="1" $(BND_IN) $< -lco ENCODING=UTF-8
	ogr2ogr -where IND="2" $(BND_IN_DIS) $< -lco ENCODING=UTF-8
	ogr2ogr $(BND_ALL) $< -lco ENCODING=UTF-8

build/%.shp: src/%.shp build
	ogr2ogr $@ $< -lco ENCODING=UTF-8

build:
	mkdir $@

dist:
	mkdir $@

src:
	mkdir $@

.PHONY: clean

clean:
	rm -rf build dist src

