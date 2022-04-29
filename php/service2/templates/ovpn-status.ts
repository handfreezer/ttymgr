
<center>
	<div>
		<button id="download-csv">Download CSV</button>
		<button id="download-json">Download JSON</button>
		<button id="download-xlsx" disabled>Download XLSX</button>
		<button id="download-pdf" disabled>Download PDF</button>
		<button id="download-html" disabled>Download HTML</button>
	</div>
	<div id="tabulator-container" style='width:auto;max-width:90%'></div>

	<div id="Themodal" class="modal-enroll ui modal">
		<div class="ui dimmer"><div class="ui text loader">Launching enrollment...</div></div>
		<div class="header">
			<i class='huge icons'><i class='dark blue shield alternate icon'></i><i class='red corner add icon'></i></i>
			Enrollement
		</div>
		<div class="content">
			<form class="ui form" id="form-enrollment">
				<div class="ui error message"></div>
				<div class="field">
					<label>IP Actuelle</label>
					<input type="text" name="ip-current" placeholder="IP actuelle" id='ip-current'>
				</div>
				<div class="field">
					<label>Racine CN</label>
					<input type="text" name="cn-cible" placeholder="Racine du CN" id='cn-cible' autofocus>
				</div>
				<div class="field">
					<label>IP Cible</label>
					<input type="text" name="ip-cible" placeholder="IP Cible" id='ip-cible'>
				</div>
				<div class="actions">
					<div class="ui red cancel inverted button">
						<i class="remove icon"></i>
						Cancel
					</div>
				<div class="ui green ok inverted button">
						<i class="checkmark icon"></i>
						Enroll
					</div>
				</div>
			</form>
		</div>
	</div>
	</div>
</center>

<script type="text/javascript">
var tableData = [
{% for tty in ttys %}
	{cn:"{{ tty.cn }}", serial:"{{ tty.serial }}", last_seen:"{{ tty.last_seen }}", ip:"{{ tty.ip }}", enroll:"{{ tty.enrolled }}"},
{% endfor %}
];

var printEnrolled = function(cell, formatterParams) {
	if ( 1 == cell.getValue() )
		return "<i class='green shield alternate icon'></i>";
	else
		return "<div class='ui icon button' data-content='Click to enroll'><i class='icons'><i class='dark blue shield alternate icon'></i><i class='red corner add icon'></i></i></div>";
};
		
var cellEnrolledClick = function(event, cell) {
	console.log("Click on cell with value: " + cell.getValue() + " of cn=" + cell.getRow().getCell("ip").getValue());
	if ( 0 == cell.getValue() ) {
		$("#ip-current").val(cell.getRow().getCell("ip").getValue());
		$("#Themodal").modal({
			onApprove : function() {
				console.log("onApprove");
				$("#form-enrollment").submit()
				return false;
			},
			onDeny : function() {
				console.log("onDeny");
			}
		}).modal('show');
		console.log("modal displayed");
	}
};

var table = new Tabulator("#tabulator-container", {
	data:tableData,
	index:"ip",
	selectable:false,
	layout:"fitDataTable",
	pagination:"local",
	paginationSize:20,
	paginationSizeSelector:[20, 40, 80, 100, true],
	columns:[
		{title:"CN", field:"cn", hozAlign:"left", headerFilter:"input"},
	        {title:"Serial", field:"serial", headerFilter:"input"},
	        {title:"Last Seen", field:"last_seen", sorter:"string"},
	        {title:"IP", field:"ip", headerFilter:"input"},
	        {title:"Enrollment", field:"enroll", hozAlign:"center", formatter:printEnrolled, cellClick:cellEnrolledClick},
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

$("#form-enrollment")
  .form({
    on: 'change',
	onSuccess : function(event, fields) {
		$("#Themodal .dimmer").addClass('active');
		event.preventDefault();
		console.log("onSuccess:");
		console.log(event);
		console.log(fields);
		$.ajax({
        		type: 'post',
			url: 'service2/actions.php',
        		data: 'cmd=enrollment&' + $('#form-enrollment').serialize(),
        		success: function () {
        			  //"ok" label on success.
				console.log("ajax function success");
				$("#Themodal").modal('hide');
				$("#Themodal .dimmer").removeClass('active');
        		}
		});
    },
    fields: {
      'ip-current': {
        identifier  : 'ip-current',
        rules: [
          {
	    type   : 'regExp[/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/]',
            prompt : 'Please enter a valid IP'
          }
        ]
      },
      'cn-cible': {
        identifier  : 'cn-cible',
        rules: [
          {
	    type   : 'regExp[/^tty[a-zA-Z0-9]+$/]',
            prompt : 'Please enter a valid radical of CN'
          }
        ]
      },
      'ip-cible': {
        identifier  : 'ip-cible',
        rules: [
          {
            type   : 'regExp[/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/]',
            prompt : 'Please enter a valid IP'
          }
        ]
      }
    }
  })
;

</script>
<br>Note on icon usage: <i class='big check circle outline icon' style='color:#00CC00;'></i><i class='big times circle outline loading icon' style='color:#CC0000;'></i><i class='big green shield alternate icon'></i><i class='big icons'><i class='dark blue shield alternate icon'></i><i class='red corner add icon'></i></i><br>

