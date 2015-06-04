#!/usr/bin/perl


use strict;
use warnings;

use lib '../../';
use MISO::DB;

my $db = MISO::DB->new();

my $graph = $db->so_graph;

my $sub_graph = $graph->subgraph({acc => 'SO:0000147'});

$graph->export({format => 'owl'});
