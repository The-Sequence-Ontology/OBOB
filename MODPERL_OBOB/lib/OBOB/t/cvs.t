#!/usr/bin/perl

use strict;
use warnings;

my $result = system ("cvs -d:pserver:anonymous\@song.cvs.sourceforge.net:/cvsroot/song history");
print "Result = $result\n";
