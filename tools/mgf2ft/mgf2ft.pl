#!/usr/bin/perl -w                 

open (IN, "<$ARGV[0]");
open (OUT, ">$ARGV[1]");

my ($scan, $pepmass, $charge, $pepmoz, @moz, @intensity, @order, $switch, $i, $istart, $id, $iend, $ichange, $arrayindex, $loop, $l2count);

$switch = 0;
$i = 0;
$id = 0;
$l2count = 1;


while (<IN>) {
    if (/BEGIN/) {
	$switch = 1;
	$istart = $i + 5;
	

    }
    if ($switch){

	if (/(?s)PEPMASS=(.*)/) {
	    $pepmass = $1 if defined $1;

	}
	if (/(?s)CHARGE=(.)\+|-/) {
	    $charge = $1 if defined $1;

	
	}
	if (/(?s)(\d*.\d*)[ ](\d*[.]\d*)/) {
	    $moz[$i] = $1 if defined $1;
	    $intensity[$i] = $2 if defined $2;

	}
	if (/(?s)SCANS=(\d*)/){
	    $scan = $1 if defined $1;


	}
	if (/END/) {
	$switch = 0;
	$loop = $istart;
	$l2 = $istart;
	$iend = $i - 1;
	$ichange = $iend - $istart;

	@order = sort {$b <=> $a} @intensities;
	
	print OUT "{\n";
	print OUT "\t\"id\" : ";
	print OUT $id;
	print OUT ",\n";


	print OUT "\t\"mozs\" : \[";
       
	while ($loop <= $iend) {
	    print OUT "\n\t";
	    print OUT $moz[$loop];
	    print OUT ", ";
	    $loop = $loop + 1;
	}
	print OUT "\n\t\],\n";
	$loop = $istart;


	print OUT "\t\"intensities\" : \[";
	while ($loop <= $iend) {
	    print OUT "\n\t";
	    print OUT $intensity[$loop];
	    print OUT ", ";
	    $loop = $loop + 1;
	}
	print OUT "\n\t\],\n";
	$loop = $istart;

	$pepmoz = $pepmass / $charge;
	print OUT "\t\"precMoz\" : ";
	print OUT $pepmoz;
	print OUT ",\n";
	
	
	print OUT "\t\"intensityRanks\" : \[";
	while ($loop <= $iend){
	    print OUT "\n\t";
	    if ($intensity[$loop] == $order[$loop]){
		print OUT "\t1\n";
	    }
	    else {
		while ($intensity[$loop] != $order[$l2]){
		    $l2++;
		    $l2count++;
		    if ($intensity[$loop] == $order[$l2]){
			print OUT "\t";
			print OUT $l2count;
		  
		    }
		}
	    }
		    
	    print OUT ", \n\t";
	    $loop++;
        }

        print OUT "\t\"scanNumber\" : ";
	print OUT $scan;
	print OUT ", \n";


	print OUT "\t\"precCharge\" : ";
	print OUT $charge;
	print OUT ", \n";

	print OUT "\t\"size\" : ";
	print OUT $ichange;
	print OUT "\n";

	print OUT "}\n";


    

        $id = $id + 1;
    }


    }
    $i = $i + 1;
 }

close (IN);
close (OUT);

    
