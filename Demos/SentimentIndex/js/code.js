var chart;
var MIN_DATE 
	= Date.UTC(2012, 0, 1); // Jan 1, 2012
var MAX_DATE 
	= Date.UTC(2012, 11, 31, 12, 0); // Dec 31, 2012
var DAY_SPAN
	= 86400000;

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

// set initial time span
$("#datepicker-from").data("datetimepicker").setDate(MIN_DATE);
$("#datepicker-to").data("datetimepicker").setDate(MAX_DATE);

// assign button handlers
$(".btn").click(function() {
	var action = $(this)[0].textContent;
	var span;
	var dateEnd = chart.xAxis[0].getExtremes().max;
	if (action == "All") { chart.xAxis[0].setExtremes(MIN_DATE, MAX_DATE); return; }
	else if (action == "1y") { span = 365 * DAY_SPAN; }
	else if (action == "1m") { span = 30 * DAY_SPAN; }
	else if (action == "3m") { span = 90 * DAY_SPAN; }
	else if (action == "6m") { span = 180 * DAY_SPAN; }
	var dateStart = dateEnd - span;
	if (dateStart < MIN_DATE) { dateEnd += (MIN_DATE - dateStart); dateStart += (MIN_DATE - dateStart); }
	chart.xAxis[0].setExtremes(dateStart, dateEnd);
}).focus(function() {
	$(this)[0].blur(); // fixes FF bug
});

function filter(data) {
	var newData = [];
	for (var i in data) {
		if (data[i][0] >= MIN_DATE && data[i][0] <= MAX_DATE) {
			var d = new Date(data[i][0]);
			d = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) + 43200000; // data point appear at midday
			newData.push([d, data[i][1]]); 
		}
	}
	return newData;
}

function load(name) {
	$.getJSON("http://first-vm4.ijs.si/first_occurrence/data/?label=" + name + "&callback=?&w=1", function(volume) {
		$.getJSON("http://first-vm4.ijs.si/first_sentiment/data/?scope=document&aggregation=sum&label=" + name + "&callback=?&w=1", function(sentiment) {
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
				xAxis: {
					events: {
						setExtremes: function(event) {
							$("#datepicker-from").data("datetimepicker").setDate(event.min);
							$("#datepicker-to").data("datetimepicker").setDate(event.max);
							if (Math.abs(event.max - event.min - chart.span) >= 2 * DAY_SPAN) {
								chart.span = event.max - event.min;
								$(".btn-group button").removeClass("active");
							}
						}
					}
				},
				yAxis: [{
						title: {
							text: "Volume"
						},
						min: 0,
						labels: {
							align: "right",
							x: -5,
							formatter: function() {
								return (this.value > 0 ? "+" : "") + this.value;
							}
						},
						plotLines: [{
							value: 0,
							width: 2,
							color: "silver"
						}],
						height: 200,
						lineWidth: 2
					},
					{
						title: {
							text: "Sentiment"
						},
						labels:{
							align: "right",
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
				}],
				series: [{
					name: "Volume", 
					data: filter(volume)
				},
				{
					name: "Sentiment", 
					yAxis: 1,
					data: filter(sentiment)
				}],
				tooltip: {
					formatter: function() {
						return Highcharts.dateFormat("%a, %b %d, %Y", this.x) + "<br/>" +
							"<span style=\"color:" + this.points[0].series.color + "\">Volume</span>: <b>" + this.points[0].y + "</b><br/>" +
							"<span style=\"color:" + this.points[1].series.color + "\">Sentiment</span>: <b>" + this.points[1].y.toFixed(2) + "</b>";
					}
				}
			});
			chart.span = MAX_DATE - MIN_DATE;
		});
	});
}

load("4922"); // DAX