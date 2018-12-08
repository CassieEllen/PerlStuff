# PerlStuff
Little Perl scripts that may be useful.

## Documentation Tools

### Install Doxygen
http://www.doxygen.nl/

I am writing documentation in the form of doxygen perl comments. It
requires the use of the Doxygen::Filter::Perl module. 

**Install on Ubuntu**
```bash
sudo apt install -y doxygen
sudo apt install -y libdoxygen-filter-perl
sudo apt install -y graphviz
```

### Install naturaldocs
https://www.naturaldocs.org/

#### Debian
```bash
sudo apt install -y naturaldocs
```

## git-filter.pl
Provides a simple filter for the output of 
*apt search git*

## firewall.pl (./firewall/firewall.pl)
Provides a simple frontend to iptables.

