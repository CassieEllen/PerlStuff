#!/usr/bin/perl

# sudo apt install -y libproc-processtable-perl
use strict;

use warnings;

use Proc::ProcessTable;

use Data::Dumper;


my $p = Proc::ProcessTable->new( 'cache_ttys' => 1 );
print Dumper $p;
    
my @fields = $p->fields;
print Dumper @fields;
print Dumper \@fields;

my $ref = $p->table;
#print Dumper $ref;

for my $process (@$ref) {
    print "--------------------------------------------------------------------------------\n";
    #print Dumper \$process;
    print $process->{'pid'}, "\t", $process->{'fname'}, "\n";
}
