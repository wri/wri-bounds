DL_URL=http://naciscdn.org/naturalearth/10m/cultural/

CTR_ZIP=ne_10m_admin_0_countries.zip
DIS_ZIP=ne_10m_admin_0_disputed_areas.zip

CTR_SRC=shp/ne_10m_admin_0_countries.shp
DIS_SRC=shp/ne_10m_admin_0_disputed_areas.shp

DIS=shp/disputed.shp
DIS_CN=shp/cn_disputed.shp
DIS_IN=shp/in_disputed.shp

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

INTL_SVG=intl_map.svg
IN_SVG=in_map.svg
CN_SVG=cn_map.svg

LAND=shp/land_areas.shp

BNDS:=$(BND_CP) $(BND_INTL) $(BND_CN) $(BND_IN) \
	$(BND_INTL_DIS) $(BND_CN_DIS) $(BND_IN_DIS)

CTRS:=$(CTR_ALL) $(CTR_PRIMARY) $(CTR_CN) $(CTR_CN_PRIMARY) \
	$(CTR_IN) $(CTR_IN_PRIMARY) $(DIS) $(DIS_CN) $(DIS_IN) $(LAND)

_=shp/__tmp.shp
_2=shp/__tmp2.shp

SIMPLIFY=.05
PROJ=+proj=wintri

all: zips geojson mingeojson dist/svgs.zip

geojsongz: $(patsubst shp/%.shp, dist/%.geojson.gz, $(CTRS) $(BNDS))

mingeojson: $(patsubst shp/%.shp, dist/%.min.geojson, $(CTRS) $(BNDS))

zips: $(patsubst shp/%.shp, dist/%.zip, $(CTRS) $(BNDS))

geojson: $(patsubst shp/%.shp, dist/%.geojson, $(CTRS) $(BNDS))

dist/svgs.zip: $(INTL_SVG) $(CN_SVG) $(IN_SVG) | dist
	zip -j $@ $^

$(INTL_SVG): $(LAND) $(CTR_PRIMARY) $(DIS) $(BND_INTL) $(BND_INTL_DIS)
	mapshaper -i $^ combine-files -clip bbox=-180,-85,180,85 -proj $(PROJ) -simplify $(SIMPLIFY) -filter-islands min-vertices=4 \
		-svg-style fill="#ddd" class="land" target=0 \
		-svg-style fill="#ccc" class="'ADM0_A3-'+ADM0_A3" target=1 \
		-svg-style opacity=0.2 class="'sr_brk_a3-'+sr_brk_a3" target=2 \
		-svg-style stroke="#000" class="boundary" stroke-width=0.5 target=3 \
		-svg-style stroke="#800" class="boundary-disputed" stroke-width=0.5 stroke-dasharray="2, 2" target=4 \
		-o $@ force

$(CN_SVG): $(LAND) $(CTR_CN_PRIMARY) $(DIS_CN) $(BND_CN) $(BND_CN_DIS)
	mapshaper -i $^ combine-files -clip bbox=-180,-85,180,85 -erase bbox=-65.01,-90,-64.99,90 -proj $(PROJ) +lon_0=115 densify -simplify $(SIMPLIFY) -filter-islands min-vertices=4 \
		-svg-style fill="#ddd" class="land" target=0 \
		-svg-style fill="#ccc" class="'ADM0_A3-'+ADM0_A3" target=1 \
		-svg-style opacity=0.2 class="'sr_brk_a3-'+sr_brk_a3" target=2 \
		-svg-style stroke="#000" class="boundary" stroke-width=0.5 target=3 \
		-svg-style stroke="#800" class="boundary-disputed" stroke-width=0.5 stroke-dasharray="2, 2" target=4 \
		-o $@ force

$(IN_SVG): $(LAND) $(CTR_IN_PRIMARY) $(DIS_IN) $(BND_IN) $(BND_IN_DIS)
	mapshaper -i $^ combine-files -clip bbox=-180,-85,180,85 -erase bbox=-100.01,-90,-99.99,90 -proj $(PROJ) +lon_0=80 densify -simplify $(SIMPLIFY) -filter-islands min-vertices=4 \
		-svg-style fill="#ddd" class="land" target=0 \
		-svg-style fill="#ccc" class="'ADM0_A3-'+ADM0_A3" target=1 \
		-svg-style opacity=0.2 class="'sr_brk_a3-'+sr_brk_a3" target=2 \
		-svg-style stroke="#000" class="boundary" stroke-width=0.5 target=3 \
		-svg-style stroke="#800" class="boundary-disputed" stroke-width=0.5 stroke-dasharray="2, 2" target=4 \
		-o $@ force

dist/%.zip: shp/%.shp | dist
	zip -j $@ $(basename $<).*

dist/%.geojson.gz: dist/%.geojson | dist
	gzip -fk $<

dist/%.geojson: shp/%.shp | dist
	mapshaper -i $< encoding=UTF-8 -o $@ force

dist/%.min.geojson: shp/%.shp | dist
	mapshaper -i $< encoding=UTF-8 -simplify $(SIMPLIFY) -filter-islands min-vertices=4 -o $@ precision=0.0001  force

shp/%_primary_countries.shp: shp/%_countries.shp
	ogr2ogr -where PRIMARY="1" -overwrite $@ $< -lco ENCODING=UTF-8 -s_srs EPSG:4326 -t_srs EPSG:4326

$(LAND): $(INTERSECT)
	mapshaper -i $< -dissolve2 -o $@ force

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

$(BND_ALL): $(INTERSECT) $(9DASH) disputed.js
	node disputed.js $< $@
	ogr2ogr $@ $(9DASH) -append

$(INTERSECT): $(CTR) $(DIS)
	mapshaper -i $< auto-snap -erase $(word 2,$^) -o $_ force
	mapshaper -i $_ -each "NOTE_BRK='', sr_brk_a3=''" -o $(_2) force
	ogr2ogr $(_2) $(word 2,$^) -append
	mapshaper -i $(_2) auto-snap -filter-islands min-vertices=3 -o $_ force
	mapshaper -i $_ -each "CHN_A3=((NOTE_BRK.indexOf('China')>=0 || ADM0_A3=='TWN') ? 'CHN' : ADM0_A3), IND_A3=((NOTE_BRK.indexOf('India')>=0) ? 'IND' : ADM0_A3)" -o $@ force

$(DIS_CN): $(INTERSECT)
	mapshaper -i $< -filter "(CHN_A3!='CHN' && sr_brk_a3!='')" -o $@ force

$(DIS_IN): $(INTERSECT)
	mapshaper -i $< -filter "(IND_A3!='IND' && sr_brk_a3!='')" -o $@ force

# Somaliland -> Somalia
# K.Base -> Kazakstan
# Northern Cyprus -> Cyprus
# Saichen -> India
# W.Sahara -> Morocco
$(CTR): $(CTR_SRC)
	mapshaper -i $< -each "ADM0_A3=(ADM0_A3=='SOL' ? 'SOM' : ADM0_A3=='KAB'? 'KAZ' : ADM0_A3=='CYN' ? 'CYP' : ADM0_A3=='KAS' ? 'IND' : ADM0_A3=='SAH' ? 'MAR' : ADM0_A3)" -o $_ force
	ogr2ogr $(_2) $_ -lco ENCODING=UTF-8
	mapshaper -i $(_2) auto-snap -dissolve ADM0_A3 -o $@ force


# B00,B01,B02,B03,B04,B05,B06,B07,B08,B09,B45 -> IND/PAK/CHN
# B13 -> Sud/S.Sud
# B16=Golan heights
# B17 -> KEN/S.Sud
# B19,B28 -> W.Sahara
# B35=Georgia brk
# B36=Moldova brk
# B37=Georgia brk
# B38=Azer. brk
# B75,B76 -> CHN/BTN
# B88 -> IND/NPL
$(DIS): $(DIS_SRC)
	ogr2ogr -where "sr_brk_a3 IN ('B00','B01','B02','B03','B04','B05','B06','B07','B08','B09','B45','B13','B16','B17','B19','B28','B35','B36','B37','B38','B75')" $_ $< -overwrite -lco ENCODING=UTF-8
	mapshaper -i $_ -each "sr_brk_a3=(sr_brk_a3=='B28' ? 'B19' : sr_brk_a3 )" -o $(_2) force
	mapshaper -i $(_2) auto-snap -dissolve sr_brk_a3 copy-fields=NOTE_BRK,ADM0_A3 -filter-islands min-vertices=3 -o $@ force

$(CTR_SRC): $(CTR_ZIP) | shp
	unzip -o $< -d shp

$(DIS_SRC): $(DIS_ZIP) | shp
	unzip -o $< -d shp

$(CTR_ZIP) $(DIS_ZIP):
	curl -o $@ $(DL_URL)$@

node_modules/mapshaper:
	npm install mapshaper@~0.2

shp:
	mkdir -p $@
dist:
	mkdir -p $@

.SECONDARY: *

.PHONY: clean

clean:
	rm -rf shp dist
