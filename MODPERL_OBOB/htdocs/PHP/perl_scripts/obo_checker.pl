#!/usr/bin/perl 
use GO::Parser;
use IO::File;

# I/O for object.
my $input = shift;

# Make the iterator object.
my $parser = new GO::Parser( { handler => 'obj' } );
$parser->parse($input);

# make graph object
my $graph = $parser->handler->graph;

# make iterator object
my $it = eval { $graph->create_iterator };

my $term;
while ( my $ni = $it->next_node_instance ) {
        $term = $ni->term;
}

if ( $term ){ print '1';}
