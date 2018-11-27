#!/usr/bin/perl

# Intended use:
# process the output of 'apt search Git | gf.pl' to limit the lines shown.

use strict;
use warnings;

my @patterns = (
    "digital",
    "ruby",
    "python",
    "golang",
    );

# Outer loop label 'LINE' for use with skipping unwanted patterns.
# It is needed to use 'next' within an inner loop. 
LINE:
while(<>) {
    chomp;

    # Skip description lines
    next if( /^ / );
    
    # Ensure that the line contains git
    next if( !/git/i );

    # Filter out unwanted patterns
    for my $pat (@patterns) {
	next LINE if( /$pat/i );
    }
	
    print "$_\n";

}
