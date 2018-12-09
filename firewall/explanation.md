# firewall.pl

## Requirements
**Debian**
  sudo apt install -y libconfig-simple-perl
  
## Introduction
firewall.pl is a simple command line interface to iptables

## Setting up documentation
Documentation is done with Doxygen and Markdown (.md) files.
To setup Doxygen, use the command:
```bash
doxygen -g
```
Which will create file *Doxyfile*. Next edit Doxyfile and change the following settings:
```text
USE_MDFILE_AS_MAINPAGE = README.md
GENERATE_LATEX         = NO
EXTRACT_ALL            = YES
```
Add '*.pl  *.pm' to the end of list <pre>FILE_PATTERNS</PRE> to ensure perl files are read.

These changes will use the README file as the main page and will only use perl files as source files. 

## Degugging
The first thing to know is that I use the scalar $debug to turn on and off debug messages. If $debug is undefined (or false), then debug messages do not print. If you define $debug (set it to 1), then debug messages will print.

This uses the perl syntax <pre>statement if(condition);</pre>
The statement is executed if the condition is true. 

Data::Dumper provides a look into the data structures. It requires
```bash
use Data::Dumper
```
And can be invoked either by calling Dumper() or Data::Dumper->Dump(). Calling Dumper provides  a quick, easy view, and calling 
 Data::Dumper->Dump() allows naming of the variables being dumped. 

## Configuration File: firewall.ini
Configuration uses [Config::Simple](https://metacpan.org/pod/Config::Simple)  to load values from a configuration file. Config::Simple was not loaded automatically when perl was installed, so you will need to install it separately with CPAN or apt. 
```bash
sudo apt install -y libconfig-simple-perl
```
Then it will need to be use'ed in the script.
```perl
use Config::Simple;
```
Loading the config file is very simple. You need to define a config hash, and then import the values from the config file. 
```perl
my $filename = 'config.ini';
my %config = ();
Config::Simple->import_from($filename, \%config) or die Config::Simple->error();
```
To see the imported values, you can use Data::Dumper->Dump().
```perl
print Data::Dumper->Dump( [ \%config], [ qw(config) ] );
```
## Unwinding $cmds
$cmds is a hash reference to an unnamed hash of commands. 

Currently, printing $cmds yields
```perl
$cmds = {
          'open' => {
                      'general' => [
                                     'D',
                                     'I'
                                   ],
                      'ssh' => [
                                 'I'
                               ]
                    },
          'close' => {
                       'ssh' => [
                                  'D'
                                ],
                       'general' => [
                                      'D'
                                    ]
                     }
        };

```
$cmds is a reference to an unnamed hash mapping the command name to a subcommand hash. 
The subcommand hash maps the subcommandname to an array of values to be substituted on the command line. 