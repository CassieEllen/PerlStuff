#!/usr/bin/env perl

#  Requires
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
#-------------------------------------------------------------------------------
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

my $debug = undef;     # Define to turn on debugging messages.
#$debug = 1;            # Turn on debugging messages

my $source;

#-------------------------------------------------------------------------------
# Read ini file if it exists
#
# %ini_hash - maps config names to value strings.
# $ini_file - uses the current executable filename, changing .pl to .ini.
#-------------------------------------------------------------------------------

my %ini_hash = (); #**< ini configuration
my $ini_file = $0;
$ini_file =~ s/\.pl/\.ini/;
if( -e $ini_file ) {
    say "Loading ini file ${ini_file}:";
    Config::Simple->import_from($ini_file, \%ini_hash);
    print Data::Dumper->Dump( [ \%ini_hash], [ qw(ini_hash) ] ) if($debug);
}

#-------------------------------------------------------------------------------
# Create command hash
#
# Usage:
#   firewall command sub-command argument
#
# $cmds is a ref to a hash of commands mapped to sub-commands
# Each sub-command has an array of iptable options to execute
# 
#-------------------------------------------------------------------------------
my $cmds = {
    'open' => {
	'ssh'     => ['I'],
	'general' => ['D', 'I'],
    },
	'close' => {
	    'ssh'     => ['D'],
	    'general' => ['D'],
    },
};

print Dumper(\$cmds) if($debug);

# Command line strings

my $iptable_cmds = {
    'general' => "iptables -%s INPUT -s \"%s\" -p tcp -m multiport --dports [DPORTS] -j ACCEPT",
    'ssh'     => "iptables -t nat -%s PREROUTING -s \"%s\" -p tcp --dport [DPORT] -j REDIRECT --to-port 22",
};

#-----------------------------------------------------------------------------
# Process options

GetOptions('help' => \&help,
    );

replace_strings();

#-----------------------------------------------------------------------------
# Ensure we have the right number of arguments

if( scalar @ARGV < 3 ) {
    print "Wrong number of arguments\n";
    help();
    exit 1;
}

my $cmd = shift @ARGV;
my $subcmd = shift @ARGV;
my $arg = shift @ARGV;

#-----------------------------------------------------------------------------
# Verify the command

die ("Argument 1 incorrect: \"$cmd\"")    
if( ! exists $cmds->{$cmd} );
die ("Argument 2 incorrect: \"$subcmd\"") 
if( ! exists $cmds->{$cmd}->{$subcmd} );

#-----------------------------------------------------------------------------
# Execute command

print "$0 ${cmd} ${subcmd} ${arg}\n";

Dumper( $cmds->{$cmd} ) if($debug);

doexec( $cmd, $subcmd, $arg);

#-----------------------------------------------------------------------------

# Function: help
# Prints help and then exits
# Help is created from the %$cmd hash. Consequently, it must be populated
# before help() is called. 
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
    exit 0;
}

# Function: replace_strings
# Replaces the string arguments from global %ini_hash
# into global %$iptable_cmds.
sub replace_strings {
    for my $option (keys %ini_hash) {
	next if( ! ($option =~ /default.(.*)/) );
	my $key = uc $1;
	my $value = $ini_hash{$option};
	my $ref = ref($ini_hash{$option});
	if( $ref eq '' ) {
	    $value = $ini_hash{$option};
	} elsif( ref($ini_hash{$option}) eq 'SCALAR' ) {
	    $value = $ini_hash{$option};
	} elsif( ref($ini_hash{$option}) eq 'ARRAY' ) {
	    $value = join(',', @$value);
	} else {
	    say "unknown: ${key}";
	    exit 1;
	}
	my $pat = "\\[$key]";
	for my $cmd (keys %$iptable_cmds) {
	    $iptable_cmds->{$cmd} =~ s/${pat}/$value/;
	}
    }

    print Data::Dumper->Dump( [$iptable_cmds], ['iptable_cmds'] ) if($debug);
}

# Function: doexec
# Executes the commands for the given command line.
# Arguments:
#   1. - Command string
#   2. - Sub-command string
#   3. - Argument (iptables -s <arg>)
sub doexec {
    print "doexec {\n";
    my ($cmd, $subcmd, $arg) = @_;
    my $cmds = $cmds->{$cmd}->{$subcmd};
    for my $option (@$cmds) {
	my $cmdline = sprintf($iptable_cmds->{$subcmd}, $option, $arg);
	print "\t";
	system("echo", $cmdline);
    }
    print "}\n";
}

