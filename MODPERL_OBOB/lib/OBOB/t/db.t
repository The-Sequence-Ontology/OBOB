#!/usr/bin/perl


use strict;
use warnings;

use lib '../../';
use MISO::DB;

$ENV{MISO_SO_PATH} = '/home/miso/MISO_DEV/data/miso_ontology_files/';

my $db = MISO::DB->new();

my $so_path = $db->so_path;

my $release_names = $db->so_release_names;

my $so_file = $db->so_file;

my $names = $db->cheap_get_names;

my $synonyms = $db->cheap_get_synonyms;

my $search_results = $db->search_ids_names_synonyms('DNA');

my $so_terms = $db->cheap_parse_so_file;

my $name_map = $db->name_map;

my $synonym_map = $db->synonym_map;

my $graph = $db->so_graph;

my $source_json = $db->get_treeview_json('source');

my $obsoloete_json = $db->get_obsolete_treeview_json;

my $children_json = $db->get_treeview_json('SO:0000110', 'SO:0001037');

my $child_graph = $db->get_children_graph('SO:0000110');

my $all_child_graph = $db->get_recursive_children_graph('SO:0000110');

print '';

#my $html = $db->get_html_tree;

