#!/usr/bin/perl


use strict;
use warnings;

use lib '../../';
use MISO::DB;
use GO::Parser;
use Time::HiRes qw(gettimeofday tv_interval);

for (0 .. 9) {
    my $t0 = [gettimeofday];
    my $db = MISO::DB->new();
    my $graph = $db->so_graph;
    $db->get_treeview_json('SO:0000000', 'SO:1000184');
    my $elapsed = tv_interval ( $t0 );
    print "$elapsed\n";
    undef $db;
    undef $graph;
}

die;

print "\n";
print "-" x 80;
print "\n";

for (0 .. 9) {
    my $t0 = [gettimeofday];
    my $parser = new GO::Parser({handler=>'obj'});
    $parser->parse('so-xp.obo');
    my $elapsed = tv_interval ( $t0 );
    print "$elapsed\n";
    undef $parser;
}

print "\n";
print "-" x 80;
print "\n";

my $parser = new GO::Parser({handler=>'obj',use_cache=>1});
$parser->parse('so-xp.obo');

for (0 .. 9) {
    my $t0 = [gettimeofday];
    my $parser = new GO::Parser({handler=>'obj',use_cache=>1});
    $parser->parse('so-xp.obo');
    my $elapsed = tv_interval ( $t0 );
    print "$elapsed\n";
    undef $parser;
}
