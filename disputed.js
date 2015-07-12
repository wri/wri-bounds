/* requires mapshaper */

ms = require('mapshaper');

get_disputed = function(lyr, arcs){
    if (lyr.geometry_type != 'polygon') {
	stop("Layer not polygon type");
    }
    var arcCount = arcs.size();
    var data = lyr.data.getRecords();
    var shpl = new Uint8Array(arcCount);
    var shpr = new Uint8Array(arcCount);
    var arcs2 = [];
    var data2 = [];
    var lyr2;
    
    ms.internal.traverseShapes(lyr.shapes, null, function(obj){
	var id;
	for (var i=0; i<obj.arcs.length; i++) {
	    id = obj.arcs[i];
	    if (id < 0) id = ~id;
	    shpl[id] ? shpr[id] = i+1 : shpl[id] = i+1;
	}});

    for (var i=0; i<arcCount; i++) {
	var lid = shpl[i]-1;
	var rid = shpr[i]-1;
	
	//inner
	if (lid>-1 && rid>-1) {
	    arcs2.push(i);
	    var ld = data[lid];
	    var rd = data[rid];
	    var row = {INTL:1, CHN:1, IND:1} 
	    // disputed
	    if ((ld['SR_BRK_A3'] || rd['SR_BRK_A3']) &&
		(ld['ADM0_A3'] === rd['ADM0_A3'] ||
		 ['CHN','IND','BOL'].indexOf(ld['ADM0_A3'])>=0 ||
		 ['CHN','IND','BOL'].indexOf(rd['ADM0_A3'])>=0
		)) {
		row['INTL']=2;
	    }
	    if (ld['CHN_A3']==='CHN' || rd['CHN_A3']==='CHN') {
		row['CHN']=0;
	    } else if ((ld['SR_BRK_A3'] || rd['SR_BRK_A3']) &&
		(ld['CHN_A3'] === rd['CHN_A3'] ||
		 ld['CHN_A3'] === 'BOL' ||
		 rd['CHN_A3'] === 'BOL'
		)) {
		row['CHN']=2;
	    }
	    if (ld['IND_A3']==='IND' || rd['IND_A3']==='IND') {
		row['IND']=0;
	    } else if ((ld['SR_BRK_A3'] || rd['SR_BRK_A3']) &&
		(ld['IND_A3'] === rd['IND_A3'] ||
		 ld['IND_A3'] === 'BOL' ||
		 rd['IND_A3'] === 'BOL'
		)) {
		row['IND']=2
	    }
	    data2.push(row);
	}
    }
    lyr2 = ms.internal.convertArcsToLineLayer(arcs2, data2);
    lyr2.name = lyr.name;
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
