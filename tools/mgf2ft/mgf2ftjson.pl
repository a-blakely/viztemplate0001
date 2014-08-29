#!/usr/bin/perl -w                 
use JSON;

open (IN, "<$ARGV[0]");
open (PEP, "<$ARGV[1]");
open (OUT, ">$ARGV[2]");

my ($scan, $pepmass, $charge, @moz, @intensity, $id, %hash, $prepsize, $size);
my $JSON = JSON->new->utf8;
$JSON->convert_blessed(1);


$prepsize = 0;

#Print each line of peptide report, write out the number of lines in the peptide report for skipping this segment of the file when searching for spectra at visualization end.
while (<PEP>) {
	print OUT $_;
	$prepsize++;
}
print OUT "REPORTLINES";
print OUT $prepsize;
print OUT ".\n";

#Go through each line in MGF file, check each condition below on each line to extract data. Breaking loop on match not working but would increase performance.
LINE: while (<IN>) {
    if (/BEGIN/) {
	%hash = ();
	$size = 0;
	next LINE;
	

    }


    if (/(?s)PEPMASS=(.*)/) {
    $pepmass = $1 if defined $1;
    #next LINE;  errors when implementing loop breaks at these points....

    }

    if (/(?s)CHARGE=(.)\+|-/) {
    $charge = $1 if defined $1;
    #next LINE;

    }
    
    #SCANS= and Cycle are analogous. Varies depending on MGF format. Both forms are supported.
    if (/(?s)SCANS=(\d*)/){ 
    $scan = $1 if defined $1;
    #next LINE;


    }
	
    if (/^(\d*\.\d*)\s*(\d*\.\d*)/) {
    push @{ $hash{mozs} }, $1 + 0 if defined $1;
    push @{ $hash{intensities} }, $2 + 0 if defined $2;
    $size++; #every time a moz/intensity pair is found, add 1 to size. (fishTones needs to know the size of each spectrum)

    }
	
    if (/(?s)Cycle\(s\): (\d*)/){
	$id = $1 if defined $1;
    }
    
    if (/END/) {


	#Extracted values are recorded to a hash.
    $hash{id} = $id + 0 if defined $id;
    $hash{id} = $scan + 0 if defined $scan; #only $id or $scan will be defined.
    $hash{precMoz} = $pepmass / $charge;
    $hash{scanNumber} = $scan + 0;
    $hash{precCharge} = $charge + 0;
    $hash{size} = $size;
    $hash{intensityRanks} = "";
	   
	    
    #Entire contents of hash are converted to JSON and printed to output. Hash tags are used for property names. 
    $json = $JSON->encode(\%hash); 
    print OUT $json;
    print OUT "\n";
    undef %hash;		#Erase contents of hash (loop back for next spectrum).

	    
    }


    

 }



close (IN);
close (PEP);
close (OUT);

    
