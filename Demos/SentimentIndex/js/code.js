var chart;
var MIN_DATE 
	= Date.UTC(2012, 0, 1, 12, 0); // Jan 1, 2012, 12:00
var MAX_DATE 
	= Date.UTC(2012, 11, 31, 12, 0); // Dec 31, 2012, 12:00
var DAY_SPAN
	= 86400000;

function filter(data) {
	var newData = [];
	for (var i in data) {
		if (data[i][0] >= MIN_DATE - DAY_SPAN / 2 && data[i][0] <= MAX_DATE) {
			var d = new Date(data[i][0]);
			d = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) + 43200000; // data point appears at midday
			newData.push([d, data[i][1]]); 
		}
	}
	return newData;
}

function MA(data, days) {
	var maData = [];
	var queue = [];
	var sum = 0;
	for (var i in data) {
		if (queue.length < days) {
			queue.push(data[i].y); sum += data[i].y; 
			maData.push(sum / queue.length);
		} else {
			queue.push(data[i].y); sum += data[i].y;
			sum -= queue.shift();
			maData.push(sum / days);
		}
	}
	return maData;
}

function showLoading() {
	$(".loading-curtain,.loading-img").show();
}

function hideLoading() {
	$(".loading-curtain,.loading-img").hide();
}

// initialize buttons
$(".btn")/*.button()*/.focus(function() {
	$(this)[0].blur(); // fixes FF focus bug
});

// initialize selection box
$("#entity").val("DAX");

// initialize date pickers
$("#datepicker-from,#datepicker-to").datetimepicker({
	pickTime: false
}).on("changeDate", function(e) {
	var dateStart = $("#datepicker-from").data("datetimepicker").getDate().getTime();
	var dateEnd = $("#datepicker-to").data("datetimepicker").getDate().getTime();
	if (dateEnd < dateStart) { dateEnd = dateStart; }
	dateStart = Math.max(MIN_DATE, Math.min(dateStart, MAX_DATE));
	dateEnd = Math.max(MIN_DATE, Math.min(dateEnd, MAX_DATE));
	chart.xAxis[0].setExtremes(dateStart, dateEnd);
});

// assign zoom button handlers
$("#zoom .btn").click(function() {
	var action = $(this).attr("id");
	var span;
	var dateEnd = chart.xAxis[0].getExtremes().max;
	if (action == "all") { chart.xAxis[0].setExtremes(MIN_DATE, MAX_DATE); return; }
	else if (action == "1m") { span = 30 * DAY_SPAN; }
	else if (action == "3m") { span = 90 * DAY_SPAN; }
	else if (action == "6m") { span = 180 * DAY_SPAN; }
	var dateStart = dateEnd - span;
	if (dateStart < MIN_DATE) { dateEnd += (MIN_DATE - dateStart); dateStart += (MIN_DATE - dateStart); }
	chart.xAxis[0].setExtremes(dateStart, dateEnd);
});

// assign MA button handlers
$("#lower-chart .btn").click(function() {
	var action = $(this).attr("id");
	if (action == "none") {
		for (var i in chart.series[2].data) { chart.series[2].data[i].update(chart.series[1].data[i].y, false); } 
		chart.redraw();
		chart.series[2].setVisible(false, true);
	}
	else { 
		var data = MA(chart.series[1].data, action == "7-day-avg" ? 7 : 14);
		for (var i in chart.series[2].data) { chart.series[2].data[i].update(data[i], false); }
		chart.series[2].setVisible(true, true);
	}
});

$("#upper-chart .btn").click(function() {
	var action = $(this).attr("id");
	console.log(action);
});

// assign selection handler !!!!!
$("select").change(function() {
	$(this)[0].blur(); // rmv ugly focus rectangle
	$("select option:selected").each(function () {
		load($(this).attr("value"));
	});
});

function load(name) {
	// set initial time span
	showLoading();
	$("#datepicker-from").data("datetimepicker").setDate(MIN_DATE);
	$("#datepicker-to").data("datetimepicker").setDate(MAX_DATE);
	$("#all").button("toggle");
	$("#none").button("toggle");
	$("#occurrence").button("toggle");
	$.getJSON("http://first-vm4.ijs.si/first_occurrence/data/?label=" + name + "&callback=?&w=1", function(volume) {
		$.getJSON("http://first-vm4.ijs.si/first_sentiment/data/?scope=document&aggregation=sum&label=" + name + "&callback=?&w=1", function(sentiment) {
			var defaultFont = "12px 'Helvetica Neue',Helvetica,Arial,sans-serif";
			chart = new Highcharts.StockChart({
				credits: { 
					enabled: false 
				},
				chart: {
					renderTo: "chart-container",
					zoomType: "x",
				},
				rangeSelector: { 
					enabled: false
				},
				navigator: {
					xAxis: {
						labels: {
							style: {
								font: defaultFont,
								color: "#000"
							}
						}
					}
				},
				xAxis: {
					events: {
						setExtremes: function(event) {
							$("#datepicker-from").data("datetimepicker").setDate(event.min);
							$("#datepicker-to").data("datetimepicker").setDate(event.max);
							if (Math.abs(event.max - event.min - chart.span) >= 2 * DAY_SPAN) {
								chart.span = event.max - event.min;
								$("#zoom button").removeClass("active");
							}
						}
					},
					lineColor: "silver",
					tickColor: "silver",
					labels: {
						style: {
							font: defaultFont,
							color: "#000"
						}
					}
				},
				yAxis: [{
					title: {
						style: {
							font: defaultFont,
							color: "#000"
						},
						text: "Occurrence"
					},
					min: 0,
					maxPadding: 0,
					labels: {
						align: "right",
						style: {
							font: defaultFont,
							color: "#000"
						},
						x: -5,
					},
					plotLines: [{
						value: 0,
						width: 2,
						color: "silver"
					}],
					height: 200,
					lineWidth: 2,
					lineColor: "silver"
				},
				{
					title: {
						style: {
							font: defaultFont,
							color: "#000"
						},
						text: "Sentiment"
					},
					maxPadding: 0,
					minPadding: 0,
					alignTicks: false,
					labels: {
						align: "right",
						style: {
							font: defaultFont,
							color: "#000"
						},
						x: -5,
						formatter: function () {
							return (this.value > 0 ? "+" : "") + this.value;
						}
					},
					plotLines:[{
						value: 0,
						width: 2,
						color: "silver"
					}],
					top: 250,
					height: 150,
					offset: 0,
					lineWidth: 2,
					lineColor: "silver"
				}],
				series: [{
					name: "Occurrence", 
					lineWidth: 1,
					data: filter(volume),
					states: {
						hover: {
							lineWidth: 1
						}
					}
				},
				{
					name: "Sentiment", 
					yAxis: 1,
					lineWidth: 1,
					data: filter(sentiment),
					states: {
						hover: {
							lineWidth: 1
						}
					}
				},
				{
					name: "MA", 
					yAxis: 1,
					data: filter(sentiment),
					visible: false,
					lineWidth: 1,
					color: "#000",
					type: "spline",
					states: {
						hover: {
							enabled: false
						}
					}
				}],
				tooltip: {
					formatter: function() {
						return Highcharts.dateFormat("%a, %b %d, %Y", this.x) + "<br/>" +
							"<span style=\"color:" + this.points[0].series.color + "\">Occurrence</span>: <b>" + this.points[0].y + "</b><br/>" +
							"<span style=\"color:" + this.points[1].series.color + "\">Sentiment</span>: <b>" + this.points[1].y.toFixed(2) + "</b>";
					}
				}
			});
			chart.span = MAX_DATE - MIN_DATE;
			hideLoading();
		});
	});
}

load("4922"); // DAX

priceData = { "DAX": [
	[1325419200000, 6166.57],
	[1325505600000, 6111.55],
	[1325592000000, 6095.99],
	[1325678400000, 6057.92],
	[1325937600000, 6017.23],
	[1326024000000, 6162.98],
	[1326110400000, 6152.34],
	[1326196800000, 6179.21],
	[1326283200000, 6143.08],
	[1326542400000, 6220.01],
	[1326628800000, 6332.93],
	[1326715200000, 6354.57],
	[1326801600000, 6416.26],
	[1326888000000, 6404.39],
	[1327147200000, 6436.62],
	[1327233600000, 6419.22],
	[1327320000000, 6421.85],
	[1327406400000, 6539.85],
	[1327492800000, 6511.98],
	[1327752000000, 6444.45],
	[1327838400000, 6458.91],
	[1327924800000, 6616.64],
	[1328011200000, 6655.63],
	[1328097600000, 6766.67],
	[1328356800000, 6764.83],
	[1328443200000, 6754.2],
	[1328529600000, 6748.76],
	[1328616000000, 6788.8],
	[1328702400000, 6692.96],
	[1328961600000, 6738.47],
	[1329048000000, 6728.19],
	[1329134400000, 6757.94],
	[1329220800000, 6751.96],
	[1329307200000, 6848.03],
	[1329566400000, 6948.3],
	[1329652800000, 6908.18],
	[1329739200000, 6843.87],
	[1329825600000, 6809.46],
	[1329912000000, 6864.43],
	[1330171200000, 6849.6],
	[1330257600000, 6887.63],
	[1330344000000, 6856.08],
	[1330430400000, 6941.77],
	[1330516800000, 6921.37],
	[1330776000000, 6866.46],
	[1330862400000, 6633.11],
	[1330948800000, 6671.11],
	[1331035200000, 6834.54],
	[1331121600000, 6880.21],
	[1331380800000, 6901.35],
	[1331467200000, 6995.91],
	[1331553600000, 7079.42],
	[1331640000000, 7144.45],
	[1331726400000, 7157.82],
	[1331985600000, 7154.22],
	[1332072000000, 7054.94],
	[1332158400000, 7071.32],
	[1332244800000, 6981.26],
	[1332331200000, 6995.62],
	[1332590400000, 7079.23],
	[1332676800000, 7078.9],
	[1332763200000, 6998.8],
	[1332849600000, 6875.15],
	[1332936000000, 6946.83],
	[1333195200000, 7056.65],
	[1333281600000, 6982.28],
	[1333368000000, 6784.06],
	[1333454400000, 6775.26],
	[1333886400000, 6606.43],
	[1333972800000, 6674.73],
	[1334059200000, 6743.24],
	[1334145600000, 6583.9],
	[1334404800000, 6625.19],
	[1334491200000, 6801],
	[1334577600000, 6732.03],
	[1334664000000, 6671.22],
	[1334750400000, 6750.12],
	[1335009600000, 6523],
	[1335096000000, 6590.41],
	[1335182400000, 6704.5],
	[1335268800000, 6739.9],
	[1335355200000, 6801.32],
	[1335614400000, 6761.19],
	[1335787200000, 6710.77],
	[1335873600000, 6694.44],
	[1335960000000, 6561.47],
	[1336219200000, 6569.48],
	[1336305600000, 6444.74],
	[1336392000000, 6475.31],
	[1336478400000, 6518],
	[1336564800000, 6579.93],
	[1336824000000, 6451.97],
	[1336910400000, 6401.06],
	[1336996800000, 6384.26],
	[1337083200000, 6308.96],
	[1337169600000, 6271.22],
	[1337428800000, 6331.04],
	[1337515200000, 6435.6],
	[1337601600000, 6285.75],
	[1337688000000, 6315.89],
	[1337774400000, 6339.94],
	[1338033600000, 6323.19],
	[1338120000000, 6396.84],
	[1338206400000, 6280.8],
	[1338292800000, 6264.38],
	[1338379200000, 6050.29],
	[1338638400000, 5978.23],
	[1338724800000, 5969.4],
	[1338811200000, 6093.99],
	[1338897600000, 6144.22],
	[1338984000000, 6130.82],
	[1339243200000, 6141.05],
	[1339329600000, 6161.24],
	[1339416000000, 6152.49],
	[1339502400000, 6138.61],
	[1339588800000, 6229.41],
	[1339848000000, 6248.2],
	[1339934400000, 6363.36],
	[1340020800000, 6392.13],
	[1340107200000, 6343.13],
	[1340193600000, 6263.25],
	[1340452800000, 6132.39],
	[1340539200000, 6136.69],
	[1340625600000, 6228.99],
	[1340712000000, 6149.91],
	[1340798400000, 6416.28],
	[1341057600000, 6496.08],
	[1341144000000, 6578.21],
	[1341230400000, 6564.8],
	[1341316800000, 6535.56],
	[1341403200000, 6410.11],
	[1341662400000, 6387.57],
	[1341748800000, 6438.33],
	[1341835200000, 6453.85],
	[1341921600000, 6419.35],
	[1342008000000, 6557.1],
	[1342267200000, 6565.72],
	[1342353600000, 6577.64],
	[1342440000000, 6684.42],
	[1342526400000, 6758.39],
	[1342612800000, 6630.02],
	[1342872000000, 6419.33],
	[1342958400000, 6390.41],
	[1343044800000, 6406.52],
	[1343131200000, 6582.96],
	[1343217600000, 6689.4],
	[1343476800000, 6774.06],
	[1343563200000, 6772.26],
	[1343649600000, 6754.46],
	[1343736000000, 6606.09],
	[1343822400000, 6865.66],
	[1344081600000, 6918.72],
	[1344168000000, 6967.95],
	[1344254400000, 6966.15],
	[1344340800000, 6964.99],
	[1344427200000, 6944.56],
	[1344686400000, 6909.68],
	[1344772800000, 6974.39],
	[1344859200000, 6946.8],
	[1344945600000, 6996.29],
	[1345032000000, 7040.88],
	[1345291200000, 7033.68],
	[1345377600000, 7089.32],
	[1345464000000, 7017.75],
	[1345550400000, 6949.57],
	[1345636800000, 6971.07],
	[1345896000000, 7047.45],
	[1345982400000, 7002.68],
	[1346068800000, 7010.57],
	[1346155200000, 6895.49],
	[1346241600000, 6970.79],
	[1346500800000, 7014.83],
	[1346587200000, 6932.58],
	[1346673600000, 6964.69],
	[1346760000000, 7167.33],
	[1346846400000, 7214.5],
	[1347105600000, 7213.7],
	[1347192000000, 7310.11],
	[1347278400000, 7343.53],
	[1347364800000, 7310.32],
	[1347451200000, 7412.13],
	[1347710400000, 7403.69],
	[1347796800000, 7347.69],
	[1347883200000, 7390.76],
	[1347969600000, 7389.49],
	[1348056000000, 7451.62],
	[1348315200000, 7413.16],
	[1348401600000, 7425.11],
	[1348488000000, 7276.51],
	[1348574400000, 7290.02],
	[1348660800000, 7216.15],
	[1348920000000, 7326.73],
	[1349006400000, 7305.86],
	[1349092800000, 7322.08],
	[1349179200000, 7305.21],
	[1349265600000, 7397.87],
	[1349524800000, 7291.21],
	[1349611200000, 7234.53],
	[1349697600000, 7205.23],
	[1349784000000, 7281.7],
	[1349870400000, 7232.49],
	[1350129600000, 7261.25],
	[1350216000000, 7376.27],
	[1350302400000, 7394.55],
	[1350388800000, 7437.23],
	[1350475200000, 7380.64],
	[1350734400000, 7328.05],
	[1350820800000, 7173.69],
	[1350907200000, 7192.85],
	[1350993600000, 7200.23],
	[1351080000000, 7231.85],
	[1351339200000, 7203.16],
	[1351425600000, 7284.4],
	[1351512000000, 7260.63],
	[1351598400000, 7335.67],
	[1351684800000, 7363.85],
	[1351944000000, 7326.47],
	[1352030400000, 7377.76],
	[1352116800000, 7232.83],
	[1352203200000, 7204.96],
	[1352289600000, 7163.5],
	[1352548800000, 7168.76],
	[1352635200000, 7169.12],
	[1352721600000, 7101.92],
	[1352808000000, 7043.42],
	[1352894400000, 6950.53],
	[1353153600000, 7123.84],
	[1353240000000, 7172.99],
	[1353326400000, 7184.71],
	[1353412800000, 7244.99],
	[1353499200000, 7309.13],
	[1353758400000, 7292.03],
	[1353844800000, 7332.33],
	[1353931200000, 7343.41],
	[1354017600000, 7400.96],
	[1354104000000, 7405.5],
	[1354363200000, 7435.21],
	[1354449600000, 7435.12],
	[1354536000000, 7454.55],
	[1354622400000, 7534.54],
	[1354708800000, 7517.8],
	[1354968000000, 7530.92],
	[1355054400000, 7589.75],
	[1355140800000, 7614.79],
	[1355227200000, 7581.98],
	[1355313600000, 7596.47],
	[1355572800000, 7604.94],
	[1355659200000, 7653.58],
	[1355745600000, 7668.5],
	[1355832000000, 7672.1],
	[1355918400000, 7636.23],
	[1356177600000, 7636.23],
	[1356350400000, 7636.23],
	[1356436800000, 7655.88],
	[1356523200000, 7612.39],
	[1356782400000, 7612.39],
]};