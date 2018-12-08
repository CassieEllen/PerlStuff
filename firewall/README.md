# firewall.pl

## Requirements
**Debian**
  sudo apt install -y libconfig-simple-perl
  
## Introduction
firewall.pl is a simple command line interface to iptables  

## Setting up documentation

Documentation can be produced uing either doxygen or naturaldocs. 
Each has an advantage and disadvantage.

### Documentation using Doxygen
Documentatin is done with Doxygen and Markdown (.md) files.
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
These changes will use the README file as the main page and will only use perl files as source files. 

###  Documentation using naturaldocs
