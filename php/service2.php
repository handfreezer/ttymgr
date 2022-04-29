<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!--meta http-equiv="refresh" content="60;"-->

<head>

<link rel="stylesheet" type="text/css" href="service2/semantic.css"></link>
<script src="service2/jquery.js"></script>
<script src="service2/semantic.js"></script>

<link rel="stylesheet" type="text/css" href="service2/tabulator/dist/css/semantic-ui/tabulator_semantic-ui.min.css">
<script src="service2/tabulator/dist/js/tabulator.min.js"></script>

<link rel="stylesheet" type="text/css" href="service2/style.css"></link>

</head>

<body>

<div class="ui centered grid"><div class="center aligned column">
<div class="ui pointing compact menu" id="menu">
  <a class="active item" data-tab="ovpn-status"><i class="green circular sitemap icon"></i>OVPN Status</a>
  <a class="item" data-tab="enrolled"><i class="blue circular shield alternate icon"></i>Enrolled</a>
  <a class="item" data-tab="accesdistant"><i class="red circular terminal icon"></i>Accès Distant</a>
  <a class="item" data-tab="grafana"><i class="orange circular chart pie icon"></i>Grafana</a>
  <a class="item" data-tab="url"><i class="orange circular chart pie icon"></i>Via URL</a>
</div>
</div></div>

<div id="box">
  UI Container Box Content
</div>

<script>
$(window).on('resize', function() {
   console.log('window resize: '+$( window ).height());
   $('#box').css('height',$( window ).height() - $('#menu').height() - 5);
});

$('.ui .item').on('click', function() {
   $('.ui .item').removeClass('active');
   $(this).addClass('active');
   console.log('window:' + $( window ).height() + " menu:" + $('#menu').height());
   $('#box').css('height',$( window ).height() - $('#menu').height() - 5);

   console.log('Get Tab : ' + $(this).attr('data-tab'));
   $('#box').html('');
   var xmlHttp = new XMLHttpRequest();
   xmlHttp.onload = function() {
	console.log('Response is : ' + this.responseText);
   	$('#box').html(this.responseText);
   };
   xmlHttp.open( "GET", "service2/getTab.php?tab="+$(this).attr('data-tab'), true ); // false for synchronous request
   xmlHttp.send( null );
});
</script>

</body>
</html>

