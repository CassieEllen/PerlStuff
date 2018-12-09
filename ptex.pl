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

# returns a reference to an array of Proc::ProcessTable::Process objects. Attributes of a process object are returned by accessors named for the attribute; for example, to get the uid of a process just do:
#
#$process->uid

# Iterate through the array of Process objects.
for my $process (@$ref) {
    print "--------------------------------------------------------------------------------\n";

    # print all data using Dumper
    #print Dumper \$process;
    
    # print using hash notation
    print $process->{'pid'}, "\t", $process->{'fname'}, "\n";
    
    # print using accessors
    print $process->pid, "\t", $process->fname, "\n";
}
