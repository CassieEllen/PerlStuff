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
Add '*.pl' to the end of list <pre>FILE_PATTERNS</PRE> to ensure perl files are read.

These changes will use the README file as the main page and will only use perl files as source files. 

## Configuration