#!/usr/bin/env perl

# Requires
#
# sudo apt install -y libconfig-simple-perl

use strict;
use warnings;

use feature qw(say);

use Data::Dumper;

use Getopt::Long qw(:config no_ignore_case bundling pass_through no_auto_abbrev );

use FileHandle;

use Config::Simple;


# iptables globals

# -s, --source [!] address[/mask]
#    Source specification. Address can be either a network name, a hostname 
#    (please note that specifying any name to be resolved with a remote query 
#    such as DNS is a really bad idea), a network IP address (with /mask), or a 
#    plain IP address. The mask can be either a network mask or a plain number, 
#    specifying the number of 1's at the left side of the network mask. Thus, a
#    mask of 24 is equivalent to 255.255.255.0. A "!" argument before the address 
#    specification inverts the sense of the address. The flag --src is an alias  
#    for this option.
#-------------------------------------------------------------------------------

my $source;

# Read ini file if it exists

my %ini_hash = ();
my $ini_file = $0;
$ini_file =~ s/\.pl/\.ini/;
print "ini_file: ${ini_file}\n";
if( -e $ini_file ) {
    say "loading ini file ${ini_file}:";
    Config::Simple->import_from($ini_file, \%ini_hash);
    #print Data::Dumper->Dump( [ \%ini_hash], [ qw(ini_hash) ] );
}

# Command line strings (Can be generated from command line options.)

my $ipt_general = "iptables -%s INPUT -s \"%s\" -p tcp -m multiport --dports [DPORTS] -j ACCEPT";
my $ipt_ssh = "iptables -t nat -%s PREROUTING -s \"%s\" -p tcp --dport [DPORT] -j REDIRECT --to-port 22";

for my $option (keys %ini_hash) {
    next if( ! ($option =~ /default.(.*)/) );
    my $key = uc $1;
    my $value = $ini_hash{$option};
    my $ref = ref($ini_hash{$option});
    if( $ref eq '' ) {
	#say "not a ref: ${key}";
	$value = $ini_hash{$option};
    } elsif( ref($ini_hash{$option}) eq 'SCALAR' ) {
	#say "SCALAR";
	$value = $ini_hash{$option};
    } elsif( ref($ini_hash{$option}) eq 'ARRAY' ) {
	#say "ARRAY";
	$value = join(',', @$value);
    } else {
	say "unknown: ${key}";
	die "trying";
    }
    my $pat = "\\[$key]";
    $ipt_general =~ s/${pat}/$value/;
    $ipt_ssh     =~ s/${pat}/$value/
}

say "ipt_general: ${ipt_general}";
say "ipt_ssh: ${ipt_ssh}";

exit 1;

# Create command hash
#
# Usage:
#   firewall command sub-command argument
#
# $cmds is a ref to a hash of commands mapped to sub-commands
# Each sub-command 
# 
my $cmds = {
    'open' => {
	'ssh' => [
	    [$ipt_ssh, 'I'],
	    ],
	'general' => [
	    [$ipt_general, 'D'],
	    [$ipt_general, 'I'],
	],
    },
	'close' => {
	    'ssh' => [
		[$ipt_ssh, 'D'],
		],
	    'general' => [
		[$ipt_general, 'D'],
	    ],
    },
};

print Dumper(\$cmds);

# Process options

GetOptions('help' => \&help,
    );


# Ensure we have the right number of arguments

if( scalar @ARGV < 3 ) {
    print "Wrong number of arguments\n";
    help();
    exit 1;
}

my $cmd = shift @ARGV;
my $subcmd = shift @ARGV;
my $arg = shift @ARGV;

# Verify the command

die ("Argument 1 incorrect: \"$cmd\"")    
if( ! exists $cmds->{$cmd} );
die ("Argument 2 incorrect: \"$subcmd\"") 
if( ! exists $cmds->{$cmd}->{$subcmd} );

# Execute command

print "$0 ${cmd} ${subcmd} ${arg}\n";

Dumper( $cmds->{$cmd} );

doexec( $cmds->{$cmd}->{$subcmd}, $arg );

#-----------------------------------------------------------------------------

sub help {
    print "Usage: \n";
    print "\t$0 [OPTIONS]... command subcommand argument\n";
    print "\n";
    print "Commands/Sub-commands:\n";
    for my $cmd (keys %$cmds) {
	print "\t${cmd}\n";
	#print Data::Dumper->Dump( [$cmds->{$cmd}], ['cmd'] );
	for my $subcmd (keys %{ $cmds->{$cmd} }) {
	    print "\t\t${subcmd} arg\n";
	}
    }
    exit
}

sub doexec {
    print "doexec{\n";
    my ($cmds, $arg) = @_;
    for my $line (@$cmds) {
	my ($cmd, $option) = @{$line};
	my $cmdline = sprintf($cmd, $option, $arg);
	system("echo", $cmdline);
    }
    print "}\n";
}

