#!/usr/bin/perl -w                 
use JSON;

open (IN, "<$ARGV[0]");
open (PEP, "<$ARGV[1]");
open (OUT, ">$ARGV[2]");

my ($scan, $pepmass, $charge, @moz, @intensity, $switch, $i, $istart, $id, %hash, $arrindex, $prepsize, $size, @tscan, @spectra);
my $JSON = JSON->new->utf8;
$JSON->convert_blessed(1);

$switch = 0;
$i = 0;
$id = 0;
$arrindex = 0;
$prepsize = 0;


while (<PEP>) {

	if (/.*\d\.\d\.\d\.(\d*)\.\d.*/){
		$tscan[$i] = $1 if defined $1;
	}
	print OUT $_;
	$prepsize++;
	$i++;

}
print OUT "REPORTLINES";
print OUT $prepsize;
print OUT ".\n";
$i = 0;

LINE: while (<IN>) {
    if (/BEGIN/) {
	$switch = 1;
	$istart = $i + 5;
	%hash = ();
	$size = 0;
	next LINE;
	

    }
    if ($switch){

	    if (/(?s)PEPMASS=(.*)/) {
	    $pepmass = $1 if defined $1;
	    #next LINE;    

	}
	if (/(?s)CHARGE=(.)\+|-/) {
	    $charge = $1 if defined $1;
            #next LINE;

	
	}
	if (/(?s)SCANS=(\d*)/){
	    $scan = $1 if defined $1;
	    #next LINE;


	}
	if (/^(\d*\.\d*)\s*(\d*\.\d*)/) {
	    push @{ $hash{mozs} }, $1 + 0 if defined $1;
	    push @{ $hash{intensities} }, $2 + 0 if defined $2;
	    $size++;

	}
	if (/(?s)Cycle\(s\): (\d*)/){
		$id = $1 if defined $1;
	}
	if (/END/) {
	    $switch = 0;

	    $hash{id} = $id + 0 if defined $id;
	    $hash{id} = $scan + 0 if defined $scan;
	    $hash{precMoz} = $pepmass / $charge;
	    $hash{scanNumber} = $scan + 0;
	    $hash{precCharge} = $charge + 0;
	    $hash{size} = $size;
	    $hash{intensityRanks} = "";
	   
	    
	    
	    $json = $JSON->encode(\%hash);
	    $spectra[$id] = $json;
	    undef %hash;
	    

    

	    
	}


    }
    $i++;
 }
foreach my $pattern(@tscan){
	foreach my $line(@spectra){
		if ($line =~ /.*id":$pattern[^a-zA-Z]*/){
			print OUT $line;
			last;
		}
	}
}	 



close (IN);
close (PEP);
close (OUT);

    
