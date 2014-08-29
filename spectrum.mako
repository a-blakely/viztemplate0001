<%
import re
m=0
id=0
spectra={}
seq = {}
scan = {}
spectra[0]=""
array = "."
reportlines = 0
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Spectrum</title>

    <link rel="stylesheet" type="text/css" href="/plugins/visualizations/spectrum/static/fishtones-js.css"/>

    <script src="/plugins/visualizations/spectrum/static/fishtones-js-bundle-min.js"></script>
  

</head>
<body>

<script>
   function drawPsm(sequence, sp, target){
	var peptide = new fishtones.dry.RichSequence()
  	.fromString(sequence);

	
	var psm = new fishtones.match.PSMAlignment({
        richSequence: peptide,
        expSpectrum: sp
      });
	new fishtones.match.MatchSpectrumView({
        model    : psm,
        el       : $(target),
        tol      : 300,
        xZoomable: true
      }).render();
}

</script>

%for i, array in enumerate(hda.datatype.dataprovider( hda, 'column' )):				#iterate over whole file, load spectra into an array at the index indicated by scan number from MGF

<%
array = ''.join(array)
m = re.search('^.*scanNumber\":(\d*).*',array)
if m:
	array2 = re.sub(r'^.*scanNumber\":(\d*).*',r'\1',array)
	id = array2
	spectra[int(id)] = array
%>
%endfor



%for i, array in enumerate(hda.datatype.dataprovider( hda, 'column', offset=1, indeces=[12])):    #skip first line of file, only look at 13th column. 

<%

try:
	array = ''.join(array) 		#convert line to string
except TypeError:	       		#if this doesn't work, it is because line is empty
	seq[i] = array	      		#filler 

try:
	seq[i] = re.sub(r'\[(.*?)\]', r'{\1}', array)
except TypeError:
	seq[i] = array
try:							#check if end of peptide report has been reached. If yes, then break loop. 
	m = re.search('REPORTLINES.*',array)
except TypeError:
	m = 0
if m:
	reportlines = i					#keep track of where the spectra start. (Not yet used in this revision)
	break
%>

%endfor

<%
	page = list(hda.datatype.dataprovider(hda, 'column', offset=1,indeces=[22]) )     #load the 23nd column into memory
%>

%for i, array in enumerate(page):							  #for each line in 23nd column, get scan# and assign corresponding spectrum to variable "currspec"

<%
try:
	array = ''.join(array)
	scan = re.sub(r'\d\.\d\.\d\.(\d*)\.\d',r'\1',array)

except TypeError:

	scan = array
try:
	currspec = spectra[int(scan)]
except KeyError:
	currspec = "Key Error"								   #if spectrum missing from array, currspec = "Key Error". Shows up in browsers js console for debug
except TypeError:
	break
try:
	prevspec = spectra[int(scan)-1]							   #for future implementation of proximal spectra browsing...
except KeyError:
	prevspec = "Key Error"
try:
	nextspec = spectra[int(scan)+1]
except KeyError:
	nextspec = "Key Error"

%>

<script>
function draw${i}(){									  
	document.getElementById(${i}).innerHTML = "";					  
	document.getElementById(${i}).style.display = "block";				  
	var sp = new fishtones.wet.ExpMSMSSpectrum(${currspec});			  
	drawPsm('${seq[i]}', sp,'#${i}');
}
</script>

<div class="row" style="border:1px solid black;">
    <div id="${i}" class="col-md-12" style="height:250px;display:none;float:top;">	
    </div>
    <div>
	Sequence: <b>${seq[i]}</b> <br>	
	Draw PSM: <a href="javascript:draw${i}();"> matched scan</a> 

	(preceeding scan / 
	 succeeding scan) 

    </div>
 	
</div>
<p>


%endfor








</body>
</html>
