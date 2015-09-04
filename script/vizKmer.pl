#!/usr/bin/perl -w

#
# Geting a score along a sequence with as input a sequence in fasta and multiple files for kmerscores
#

# Perl libs
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use File::Basename;
use Bio::SeqIO;
use Bio::DB::Fasta;
use Data::Dumper;
use Math::Round;


## Inputs variables
my $fasta     = undef;
my $kmerFiles = undef;
my $outName   = undef;
my $help      = undef;

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
    'i|infile=s'     => \$fasta,
    'k|kmerscore=s'  => \$kmerFiles,
    'o|outname=s'    => \$outName,
    'help|?'         => \$help,
    ) or pod2usage(2);

pod2usage(1) if $help;

pod2usage("Error, input FASTA file '$fasta' don't exist. Exit\n") unless(-r $fasta);
pod2usage("Error, input file '$kmerFiles' with the files names of the kmer scores don't exist. Exit\n") unless(-r $kmerFiles);


## Read the fasta sequence
my $seq    = undef;
my @seqTab = undef;

open FILE, "$fasta" or die "Error! Cannot access FASTA file '". $fasta . "': ".$!;

while(<FILE>)
{
    chop;
    if(!(/^>/))
    {
	$seq = $seq.$_;
    }
}
close FILE;

# Put the sequence in upper case and split it
$seq = uc $seq;
@seqTab = split("", $seq);


## Read the kmer files
my %kmerScores;
my $fileName = undef;
my $ksize    = undef;
my $kmer     = undef;
my $score    = undef;
my $sizeMax  = 0;

open FILE, "$kmerFiles" or die "Error! Cannot access kmer score config file '". $kmerFiles . "': ".$!;

while(<FILE>)
{
    chop;
    next if(/^#/);
    $fileName = $_;

    print "Reading '". $fileName ."' kmers scores file\n";
    open sizeFILE, "$fileName" or die "Error! Cannot access kmer score file '". $fileName ."' in '". $kmerFiles . "': ".$!;
    while(<sizeFILE>)
    {
	chop;
	($kmer, $score) = split(/\t/);
	$ksize = length($kmer);
	last if($ksize==1);
	$kmerScores{$ksize}->{$kmer} = sprintf "%.2f", $score;
    }
    close sizeFILE;
    $sizeMax = $ksize if($ksize > $sizeMax);
}
close FILE;


## Scan the sequence
## The 3 results files for the 3 frames
my $fileFrame0 = $outName."_frame0.txt";
my $fileFrame1 = $outName."_frame1.txt";
my $fileFrame2 = $outName."_frame2.txt";
my @allFiles   = ($fileFrame0,$fileFrame1,$fileFrame2);
## The frame
my $frame = 0;
## The nucleotide
my $nuc = 0;
## The result line
my $line = "";
my $head = "";
my $tmp  = "";


## The frame loop
for($frame = 0; $frame <= 2; $frame++)
{
    open FILE, "> $allFiles[$frame]" or die "Error! Cannot access output file '". $allFiles[$frame] . "': ".$!;

    $head = "nuc\tk" . join("\tk",sort(keys(%kmerScores))) . "\tnone/start/stop" . "\n";
    print FILE $head;

    ## The scanning sequence loop
    for($nuc = $frame; $nuc <= ((scalar @seqTab)-$sizeMax); $nuc++)
    {
	$line = ($nuc+1);

	## Size loop
	foreach $ksize (sort(keys(%kmerScores)))
	{

	    if($ksize == 2)
	    {
		$tmp = join("",@seqTab[$nuc..($nuc+($ksize-1))]);
		$line = $line . "\t" . $kmerScores{$ksize}->{$tmp};
	    }
	    elsif(($nuc-$frame)%3 == 0 && $ksize!=2)
	    {
		$tmp = join("",@seqTab[$nuc..($nuc+($ksize-1))]);
		$line = $line . "\t" . $kmerScores{$ksize}->{$tmp};
	    }
	    else
	    {
		$line = $line . "\tNA";
	    }
	}

	## Test for start/stop codon
	if(($nuc-$frame)%3 == 0)
	{
	    $tmp = join("",@seqTab[$nuc..($nuc+2)]);
	    if($tmp=~m/ATG/i)
	    {
		$line = $line . "\t1";
	    }
	    elsif($tmp=~m/TGA|TAG|TAA]/i)
	    {
		$line = $line . "\t0";
	    }
	    else
	    {
		$line = $line . "\tNA";
	    }
	}
	else
	{
	    $line = $line . "\tNA";
	}

	print FILE $line, "\n";
    }
    ## The end of the scanning sequence loop
    close FILE;
}
## The end of the frame loop

