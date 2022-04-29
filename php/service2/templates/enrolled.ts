
<center>
	<div>
		<button id="download-csv">Download CSV</button>
		<button id="download-json">Download JSON</button>
		<button id="download-xlsx" disabled>Download XLSX</button>
		<button id="download-pdf" disabled>Download PDF</button>
		<button id="download-html" disabled>Download HTML</button>
	</div>
	<div id="tabulator-container" style='width:auto;max-width:90%'></div>
</center>

<script type="text/javascript">
var tableData = [
{% for tty in ttys %}
	{
	cn:"{{ tty.cn }}",
	ip:"{{ tty.ip }}",
	serial:"{{ tty.serial }}",
	filer:"{{tty.filer}}",
	inventory:"{{tty.inventory}}",
	kiosk:"{{tty.kiosk}}",
	snmpd_os:"{{tty.snmpd_os}}",
	snmpd_temp:"{{tty.snmpd_temp}}",
	snmpd_wifi:"{{tty.snmpd_wifi}}",
	snmpd_gps:"{{tty.snmpd_gps}}"},
{% endfor %}
];

var table = new Tabulator("#tabulator-container", {
	data:tableData,
	index:"cn",
	selectable:false,
	layout:"fitDataTable",
	pagination:"local",
	paginationSize:20,
	paginationSizeSelector:[20, 40, 80, 100, true],
	columns:[
		{title:"CN", field:"cn", hozAlign:"left", headerFilter:"input"},
	        {title:"IP", field:"ip", headerFilter:"input"},
		{title:"Serial", field:"serial", headerFilter:"input"},
		{title:"Filer", field:"filer", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
		{title:"Inventory", field:"inventory", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
		{title:"Kiosk", field:"kiosk", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
		{title:"Monitoring",
			columns:[
				{title:"OS", field:"snmpd_os", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
				{title:"Temp", field:"snmpd_temp", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
				{title:"Wifi", field:"snmpd_wifi", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
				{title:"GPS", field:"snmpd_gps", hozAlign:"center", formatter:"tickCross", headerFilter:"tickCross",  headerFilterParams:{"tristate":true},headerFilterEmptyCheck:function(value){return value === null}},
				],
		}
	],
	initialSort:[
        	{column:"cn", dir:"asc"},
	],

});

document.getElementById("download-csv").addEventListener("click", function(){
    table.download("csv", "data.csv");
});
document.getElementById("download-json").addEventListener("click", function(){
    table.download("json", "data.json");
});

</script>
<br>Note on icon usage: <i class='big check circle outline icon' style='color:#00CC00;'></i><i class='big times circle outline loading icon' style='color:#CC0000;'></i><i class='big green shield alternate icon'></i><i class='big icons'><i class='dark blue shield alternate icon'></i><i class='red corner add icon'></i></i><br>

