DL_URL=http://naciscdn.org/naturalearth/10m/cultural/

CTR_SRC=shp/ne_10m_admin_0_countries.shp
DIS_SRC=shp/ne_10m_admin_0_disputed_areas.shp

DIS=shp/disputed.shp
CTR=shp/countries.shp

INTERSECT=shp/intersection.shp

9DASH=9dash/9dashline.shp
ATTRS=countries.csv

BND_ALL=shp/bounds.shp
BND_CP=shp/all_bounds.shp
BND_INTL=shp/intl_country_boundaries.shp
BND_CN=shp/cn_country_boundaries.shp
BND_IN=shp/in_country_boundaries.shp
BND_INTL_DIS=shp/intl_disputed_boundaries.shp
BND_CN_DIS=shp/cn_disputed_boundaries.shp
BND_IN_DIS=shp/in_disputed_boundaries.shp

CTR_ALL=shp/all_countries.shp
CTR_CN=shp/cn_countries.shp
CTR_IN=shp/in_countries.shp
CTR_PRIMARY=shp/all_primary_countries.shp
CTR_CN_PRIMARY=shp/cn_primary_countries.shp
CTR_IN_PRIMARY=shp/in_primary_countries.shp

BNDS:=$(BND_CP) $(BND_INTL) $(BND_CN) $(BND_IN) \
	$(BND_INTL_DIS) $(BND_CN_DIS) $(BND_IN_DIS)

CTRS:=$(CTR_ALL) $(CTR_PRIMARY) $(CTR_CN) $(CTR_CN_PRIMARY) \
	$(CTR_IN) $(CTR_IN_PRIMARY)

1=$(notdir $(basename $<))
2=$(notdir $(basename $(word 2,$^)))
T=$(notdir $(basename $@))
_=shp/__tmp.shp
_2=shp/__tmp2.shp

all: zips geojson
	rm -rf shp

build: zips geojson

geojsongz: $(patsubst shp/%.shp, dist/%.geojson.gz, $(CTRS) $(BNDS))

zips: $(patsubst shp/%.shp, dist/%.zip, $(CTRS) $(BNDS))

geojson: $(patsubst shp/%.shp, dist/%.geojson, $(CTRS) $(BNDS))

dist/%.zip: shp/%.shp | dist
	zip -j $@ $(basename $<).*

dist/%.geojson.gz: dist/%.geojson | dist
	gzip -fk $<

dist/%.geojson: shp/%.shp | dist
	ogr2ogr -f GeoJSON $@ $< -overwrite

shp/%_primary_countries.shp: shp/%_countries.shp
	ogr2ogr -where PRIMARY="1" $@ $< -lco ENCODING=UTF-8 -overwrite

$(CTR_ALL): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 ADM0_A3 -o $_ force
	mapshaper -i $_ -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $@ force

$(CTR_CN): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 CHN_A3 -o $_ force
	mapshaper -i $_ -rename-fields ADM0_A3=CHN_A3 -o $(_2) force
	mapshaper -i $(_2) -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $@ force

$(CTR_IN): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 IND_A3 -o $_ force
	mapshaper -i $_ -rename-fields ADM0_A3=IND_A3 -o $(_2) force
	mapshaper -i $(_2) -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $@ force

$(BNDS): $(BND_ALL)
	ogr2ogr -where INTL="1" $(BND_INTL) $< -overwrite
	ogr2ogr -where INTL="2" $(BND_INTL_DIS) $< -overwrite
	ogr2ogr -where CHN="1" $(BND_CN) $< -overwrite
	ogr2ogr -where CHN="2" $(BND_CN_DIS) $< -overwrite
	ogr2ogr -where IND="1" $(BND_IN) $< -overwrite
	ogr2ogr -where IND="2" $(BND_IN_DIS) $< -overwrite
	ogr2ogr $(BND_CP) $< -overwrite

$(BND_ALL): $(INTERSECT) $(9DASH)
	node disputed.js $< $@
	ogr2ogr $@ $(9DASH) -append

$(INTERSECT): $(CTR) $(DIS)
	ogr2ogr -sql "SELECT ST_Intersection(A.geometry, B.geometry) AS geometry, A.ADM0_A3 AS ADM0_A3, B.sr_brk_a3 AS SR_BRK_A3, B.NOTE_BRK as NOTE_BRK FROM $1 A, $2 B WHERE ST_Overlaps(A.geometry, B.geometry)" -dialect SQLITE shp shp -nln __tmp -overwrite -skip -nlt POLYGON -lco ENCODING=UTF-8
	mapshaper -i $< -erase $_ -o $(_2) force
	ogr2ogr $_ $(_2) -append
	mapshaper -i $_ auto-snap -filter-islands remove-empty -o $(_2) force
	mapshaper -i $(_2) -each "CHN_A3=(NOTE_BRK.indexOf('China')>=0 || ADM0_A3=='TWN' ? 'CHN' : ADM0_A3), IND_A3=(NOTE_BRK.indexOf('China')>=0 || ADM0_A3=='TWN' ? 'CHN' : ADM0_A3)" -o $@ force


$(CTR): $(CTR_SRC)
	ogr2ogr -sql "SELECT geometry, CASE ADM0_A3 WHEN 'SOL' THEN 'SOM' WHEN 'KAB' THEN 'KAZ' WHEN 'CYN' THEN 'CYP' WHEN 'KAS' THEN 'IND' ELSE ADM0_A3 END AS ADM0_A3 FROM $(patsubst shp/%.shp,%,$<)" -dialect SQLITE shp shp -nln __tmp -overwrite -skip -lco ENCODING=UTF-8
	mapshaper -i $_ auto-snap -dissolve ADM0_A3 -o $@ force 

$(DIS): $(DIS_SRC)
	ogr2ogr -where "(TYPE IN ('Disputed', 'Breakaway') AND sr_brk_a3 NOT IN ('B19','B30')) OR sr_brk_a3='B45'" $@ $< -overwrite -lco ENCODING=UTF-8


shp/%.shp: shp/%.zip
	unzip -o $< -d shp

shp/%.zip: | shp
	curl -o $@ $(patsubst shp/%,$(DL_URL)%,$@)

shp:
	mkdir -p $@
dist:
	mkdir -p $@


.SECONDARY: *

.PHONY: clean

clean:
	rm -rf shp dist
