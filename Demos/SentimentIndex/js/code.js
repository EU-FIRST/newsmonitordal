$('#datetimepickerFrom').datetimepicker({
	pickTime: false
});

$('#datetimepickerTo').datetimepicker({
	pickTime: false
});

function load(name) {
	$.getJSON('http://first-vm4.ijs.si/first_occurrence/data/?label=' + name + '&callback=?&w=1', function(data) {
		$.getJSON('http://first-vm4.ijs.si/first_sentiment/data/?scope=document&aggregation=sum&label=' + name + '&callback=?&w=1', function(sentiment) {
			new Highcharts.StockChart({
				credits: { 
					enabled: false 
				},
				chart: {
					renderTo: "chart_container",
					zoomType: "x",
				},
				rangeSelector: { 
					selected: 1 
				},
				xAxis: {
					events: {
						setExtremes: function(event) {
							console.log(
								Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', event.min),
								Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', event.max)
							);
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
								return (this.value > 0 ? '+' : '') + this.value;
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
								return (this.value > 0 ? '+' : '') + this.value;
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
					data: data
				},
				{
					name: "Sentiment", 
					yAxis: 1,
					data: sentiment
				}]
			});
		});
	});
}

load("4922"); // DAX