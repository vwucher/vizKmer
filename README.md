Script to scan a sequence an get a kmerScore for each nucleotide (for kmer<=2) or for each nucleotides triplet (for kmer>=3)

# Usage
vizKmer.pl -i <INPUT FILE> -k <FILE WITH SCORE LOCATION> -o >OUTPUT NAME>

# Example
cd ./test/
../script/vizKmer.pl -i ENST00000053867.fa -k locKmerScore_notk12.txt -o ENST00000053867
