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
	$(CTR_IN) $(CTR_IN_PRIMARY) $(DIS)

1=$(notdir $(basename $<))
2=$(notdir $(basename $(word 2,$^)))
T=$(notdir $(basename $@))
_=shp/__tmp.shp
_2=shp/__tmp2.shp

all: zips geojson

geojsongz: $(patsubst shp/%.shp, dist/%.geojson.gz, $(CTRS) $(BNDS))

zips: $(patsubst shp/%.shp, dist/%.zip, $(CTRS) $(BNDS))

geojson: $(patsubst shp/%.shp, dist/%.geojson, $(CTRS) $(BNDS))

dist/%.zip: shp/%.shp | dist
	zip -j $@ $(basename $<).*

dist/%.geojson.gz: dist/%.geojson | dist
	gzip -fk $<

dist/%.geojson: shp/%.shp | dist
	mapshaper -i $< encoding=UTF-8 -o $@ force

shp/%_primary_countries.shp: shp/%_countries.shp
	ogr2ogr -where PRIMARY="1" -overwrite $@ $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326

$(CTR_ALL): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 ADM0_A3 -o $_ force
	mapshaper -i $_ -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $(_2) force
	ogr2ogr -overwrite $@ $(_2) -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326

$(CTR_CN): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 CHN_A3 -o $_ force
	mapshaper -i $_ -rename-fields ADM0_A3=CHN_A3 -o $(_2) force
	mapshaper -i $(_2) -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $_ force
	ogr2ogr -overwrite $@ $_ -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326


$(CTR_IN): $(INTERSECT) $(ATTRS)
	mapshaper -i $< -dissolve2 IND_A3 -o $_ force
	mapshaper -i $_ -rename-fields ADM0_A3=IND_A3 -o $(_2) force
	mapshaper -i $(_2) -join $(ATTRS) keys=ADM0_A3,adm0_a3 -o $_ force
	ogr2ogr -overwrite $@ $_ -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326

$(BNDS): $(BND_ALL)
	ogr2ogr -where INTL="1" -overwrite $(BND_INTL) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -where INTL="2" -overwrite $(BND_INTL_DIS) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -where CHN="1" -overwrite $(BND_CN) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -where CHN="2" -overwrite $(BND_CN_DIS) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -where IND="1" -overwrite $(BND_IN) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -where IND="2" -overwrite $(BND_IN_DIS) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326
	ogr2ogr -overwrite $(BND_CP) $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326

$(BND_ALL): $(INTERSECT) $(9DASH)
	node disputed.js $< $@
	ogr2ogr $@ $(9DASH) -append

$(INTERSECT): $(CTR) $(DIS)
	mapshaper -i $< auto-snap -erase $(word 2,$^) -o $_ force
	mapshaper -i $_ -each "NOTE_BRK='', sr_brk_a3=''" -o $(_2) force
	ogr2ogr $(_2) $(word 2,$^) -append
	mapshaper -i $(_2) auto-snap -filter-islands min-vertices=3 -o $_ force
	mapshaper -i $_ -each "CHN_A3=((NOTE_BRK.indexOf('China')>=0 || ADM0_A3=='TWN') ? 'CHN' : ADM0_A3), IND_A3=((NOTE_BRK.indexOf('India')>=0) ? 'IND' : ADM0_A3)" -o $@ force


$(CTR): $(CTR_SRC)
	mapshaper -i $< -each "ADM0_A3=(ADM0_A3=='SOL' ? 'SOM' : ADM0_A3=='KAB'? 'KAZ' : ADM0_A3=='CYN' ? 'CYP' : ADM0_A3=='KAS' ? 'IND' : ADM0_A3)" -o $_ force
	ogr2ogr $(_2) $_ -lco ENCODING=UTF-8
	mapshaper -i $(_2) auto-snap -dissolve ADM0_A3 -o $@ force

# B30=Somaliland B45=Saichen Glacier
$(DIS): $(DIS_SRC)
	ogr2ogr -where "(TYPE IN ('Disputed', 'Breakaway') AND sr_brk_a3<>'B30') OR sr_brk_a3='B45'" $_ $< -overwrite -lco ENCODING=UTF-8
	mapshaper -i $_ auto-snap -filter-islands min-vertices=3 -o $@ force

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
