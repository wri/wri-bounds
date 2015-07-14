/* requires mapshaper */

ms = require('mapshaper');

get_disputed = function(lyr, arcs){
    if (lyr.geometry_type != 'polygon') {
	stop("Layer not polygon type");
    }
    var arcCount = arcs.size();
    var data = lyr.data.getRecords();
    var shpl = new Uint16Array(arcCount);
    var shpr = new Uint16Array(arcCount);
    var arcs2 = [];
    var data2 = [];
    var lyr2;

    var parts, arcIds, arcId;
    for (var i=0; i<lyr.shapes.length; i++) {
	parts = lyr.shapes[i]
	if (parts && parts.length > 0) {
	    for (var j=0; j<parts.length; j++) {
		arcIds = parts[j];
		for (var k=0; k < arcIds.length; k++) {
		    arcId = arcIds[k];
		    if (arcId < 0) arcId = ~arcId;
		    
		    if (shpl[arcId]>0) {
			shpr[arcId] = i+1;
		    } else {
			shpl[arcId] = i+1;
		    }
		}
	    }
	}
    }


    var lid, rid, ld, rd, row;
    for (var i=0; i<arcCount; i++) {
	lid = shpl[i]-1;
	rid = shpr[i]-1;
	
	//inner
	if (lid>=0 && rid>=0) {
	    ld = data[lid];
	    rd = data[rid];
	    row = {INTL:1, CHN:1, IND:1,
		       LA3:ld['ADM0_A3'], RA3:rd['ADM0_A3'], 
      		       LBR:ld['sr_brk_a3'], RBR:rd['sr_brk_a3'],
		       LN:ld['NOTE_BRK'], RN:rd['NOTE_BRK']
		      };

	    // disputed if both sides are admin by same country
	    // or its a disputed border of India, China, or Bolivia
	    // also filter Cyprus No Man's area
	    if ((ld['sr_brk_a3'] || rd['sr_brk_a3']) &&
		(ld['ADM0_A3'] === rd['ADM0_A3'] ||
		 ['CHN','IND','BOL'].indexOf(ld['ADM0_A3'])>=0 ||
		 ['CHN','IND','BOL'].indexOf(rd['ADM0_A3'])>=0
		)) {
		row['INTL']=2;
	    } else if (ld['ADM0_A3']==='CNM' || rd['ADM0_A3']==='CNM') {
		row['INTL']=2;
	    }
	    // no border aroud saichen glacier
	    if ((ld['ADM0_A3']==='KAS' || rd['ADM0_A3']==='KAS') &&
		ld['ADM0_A3']!=='CHN' && rd['ADM0_A3']==='CHN') {
		row['INTL']=0;
		row['CHN']=0;
	    }
	    if (ld['CHN_A3']==='CHN' && rd['CHN_A3']==='CHN') {
		row['CHN']=0;
	    } else if ((ld['sr_brk_a3'] || rd['sr_brk_a3']) &&
		(ld['CHN_A3'] === rd['CHN_A3'] ||
		 ld['CHN_A3'] === 'BOL' ||
		 rd['CHN_A3'] === 'BOL'
		)) {
		row['CHN']=2;
	    }
	    if (ld['IND_A3']==='IND' && rd['IND_A3']==='IND') {
		row['IND']=0;
	    } else if ((ld['sr_brk_a3'] || rd['sr_brk_a3']) &&
		(ld['IND_A3'] === rd['IND_A3'] ||
		 ld['IND_A3'] === 'BOL' ||
		 rd['IND_A3'] === 'BOL'
		)) {
		row['IND']=2;
	    }
	    arcs2.push(i);
	    data2.push(row);
	}
    }
    lyr2 = ms.internal.convertArcsToLineLayer(arcs2, data2);
    lyr2.name = 'bounds';
    return lyr2;
}

main = function (infile, outfile) {
    dataset = ms.importFile(infile);
    dataset.layers[0] = get_disputed(dataset.layers[0], dataset.arcs);
    path = require('path')
    outopts = {'output_dir':path.dirname(outfile),
	       'output_file':path.basename(outfile),
	       'force':true};
    ms.exportFiles(dataset, outopts);
}

if (process.argv.length > 3) {
    main(process.argv[2], process.argv[3]);
} else {
    stop("Usage: node " + process.argv[1] + " infile outfile");
}
