package OBOB::Graph;

use strict;
use warnings;

use lib $ENV{OBOB_PERL5LIB};

use GraphViz;

#-----------------------------------------------------------------------------
sub new {
    my ($class, $args) = @_;
    my $self = {};
    bless $self, $class;
    $self->init($args);
    return $self;
}
#-----------------------------------------------------------------------------
sub init {
    my ($self, $args) = @_;
    
    $self->obo_graph($args->{obo_graph});
    $self->graph_color($args->{graph_color});
    return;
}
#-----------------------------------------------------------------------------
sub obo_graph {
    my ($self, $obo_graph) = @_;
    if ($obo_graph) {
	$self->{obo_graph} = $obo_graph;
    }
    return $self->{obo_graph};
}
#-----------------------------------------------------------------------------
sub graph_color {
    my ($self, $graph_color) = @_;
    if ($graph_color) {
	$self->{graph_color} = $graph_color;
    }
    return $self->{graph_color};
}
#-----------------------------------------------------------------------------
sub get_graphviz {

    #rename _build_graphviz_graph
    my ($self, %args) = @_;
    my $focus_font_color = $args{focus_font_color};
    my $focus_fill_color = $args{focus_fill_color};
    my $parents_font_color = $args{parents_font_color};
    my $parents_fill_color = $args{parents_fill_color};
    my $children_font_color = $args{children_font_color};
    my $children_fill_color = $args{children_fill_color};
    my $diff_font_color = $args{diff_font_color};
    my $diff_fill_color = $args{diff_fill_color};
    my $graph_root_node = $args{graph_root_node};

    my $img_path = $args{img_path} || '';
    my $acc       = $args{acc};
    my $term_url  = $args{term_url}  || '';
    my $img_url   = $args{img_url}   || '';
    my $force     = $args{force}     || 0;

    $img_path = clean_path($img_path);
    $term_url  = clean_path($term_url);
    $img_url   = clean_path($img_url);
    
    my $gif_sm_file = $acc . "_sm.gif";
    my $gif_lg_file = $acc . "_lg.gif";

    system("mkdir -p $img_path");
 
    my $gif_sm_path = $img_path . $gif_sm_file;
    my $gif_lg_path = $img_path . $gif_lg_file;

    my $gif_sm_link = $img_url . $gif_sm_file;
    my $gif_lg_link = $img_url . $gif_lg_file;

    my $gif_sm_map_file = $acc . "_sm.txt";
    my $gif_lg_map_file = $acc . "_lg.txt";
    my $gif_sm_map_path = $img_path . $gif_sm_map_file;
    my $gif_lg_map_path = $img_path . $gif_lg_map_file;
	
    if (! $force            &&
	-e $gif_sm_path     &&
	-e $gif_lg_path     &&
	-e $gif_sm_map_path &&
	-e $gif_lg_map_path ){

	open(my $SM_TXT, $gif_sm_map_path) or die "Can't open $gif_sm_map_path for reading\n";

	my $gif_sm_map;
	while (my $map=<$SM_TXT>){
	    $gif_sm_map .= $map;
	}

	close($SM_TXT);

	open(my $LG_TXT, $gif_lg_map_path) or die "Can't open $gif_lg_map_path for reading\n";

        my $gif_lg_map;
        while (my $map=<$LG_TXT>){
            $gif_lg_map .= $map;
        }

        close($LG_TXT);
    
	my %return_value = (gif_sm_link => $gif_sm_link, 
			    gif_sm_map  => $gif_sm_map, 
			    gif_lg_link => $gif_lg_link,
			    gif_lg_map  => $gif_lg_map,
			    );

	return wantarray ? %return_value : \%return_value;
    }

    my $gv_sm = GraphViz->new(layout   => 'dot',
			      directed => '1',
			      ratio    => 'auto',
			      overlap  => 'scalexy',
			      bgcolor  => 'white',
			      width    => 6,
			      height   => 6,
			      name     => 'small',
			      );

    my $gv_lg = GraphViz->new(layout   => 'dot',
			      directed => '1',
			      ratio    => 'auto',
			      overlap  => 'scalexy',
			      bgcolor  => 'white',
			      name     => 'large',
			      );

    my $obo_graph = $self->obo_graph;

    my $term = $obo_graph->get_term($acc);
    if(!$term){
	return;
    }

    $gv_sm->add_node($term->name,
		     fontsize  => 20,
		     shape     => 'oval',
		     style     => 'filled',
		     fontcolor => $focus_font_color,
		     fillcolor => $focus_fill_color,
		     URL       => $term_url . $term->acc,
		     );

    $gv_lg->add_node($term->name,
		     fontsize  => 20,
		     shape     => 'oval',
		     style     => 'filled',
		     fontcolor => $focus_font_color,
		     fillcolor => $focus_fill_color,
		     URL       => $term_url . $term->acc,
		     );

    my $seen = {};

    my $children = $obo_graph->get_child_terms($acc);
    for my $child (@{$children}) {
	
	$gv_sm->add_node($child->name,
			 fontsize  => '20',
			 shape	   => 'box',
			 style	   => 'filled',
			 fontcolor => $children_font_color,
			 fillcolor => $children_fill_color,
			 URL       => $term_url . $child->acc,
			 );
	
	$gv_lg->add_node($child->name,
			 fontsize  => '20',
			 shape     => 'box',
			 style     => 'filled',
			 fontcolor => $children_font_color,
			 fillcolor => $children_fill_color,
			 URL       => $term_url . $child->acc,
			 );
	
	my $relations = $obo_graph->get_relationships_between_terms($term->acc, $child->acc);
	
	for my $relation (@{$relations}) {
	    
	    $gv_sm->add_edge($term->name => $child->name,
			     label       => ' ' . $relation ->type(),
			     dir         => 'back',
			     style       => 'solid'
			     )
		unless $seen->{$term->acc}{$child->acc}{$relation->type};
	    
	    $gv_lg->add_edge($term->name  => $child->name,
			     label        => ' ' . $relation ->type(),
			     dir          => 'back',
			     style        => 'solid'
			     )
		unless $seen->{$term->acc}{$child->acc}{$relation->type};
	    
	    $seen->{$term->acc}{$term->acc}{$relation->type}++;
	}
	
    }

    $self->add_parents(acc   	        => $acc,
		       term  	        => $term,
		       term_url         => $term_url,
		       gv_sm 	        => $gv_sm,
		       gv_lg 	        => $gv_lg,
		       seen  	        => $seen,
		       fillcolor        => $parents_fill_color,
		       fontcolor        => $parents_font_color,
		       diff_font_color  => $diff_font_color,
		       diff_fill_color  => $diff_fill_color,
		       graph_root_node  => $graph_root_node,
		       );

    open (my $GIF_SM,'>', $gif_sm_path) or die "Can't open $gif_sm_path for writing\n";
    binmode $GIF_SM;
    print $GIF_SM $gv_sm->as_gif;
    close($GIF_SM);

    open (my $GIF_LG,'>', $gif_lg_path) or die "Can't open $gif_lg_path for writing\n";
    binmode $GIF_LG;
    print $GIF_LG $gv_lg->as_gif;
    close($GIF_LG);
    
    open (my $TXT, '>', $gif_sm_map_path) or die "Can't open $gif_sm_map_path for writing\n";
    print $TXT $gv_sm->as_cmapx;
    close($TXT);

    open (my $LG_TXT, '>', $gif_lg_map_path) or die "Can't open $gif_lg_map_path for writing\n";
    print $LG_TXT $gv_lg->as_cmapx;
    close($LG_TXT);

    my $gif_sm_map = $gv_sm->as_cmapx;
    my $gif_lg_map = $gv_lg->as_cmapx;

    my %return_value = (gif_sm_link => $gif_sm_link, 
			gif_sm_map  => $gif_sm_map, 
			gif_lg_link => $gif_lg_link,
			gif_lg_map  => $gif_lg_map,
			);

    return wantarray ? %return_value : \%return_value;
}
#-----------------------------------------------------------------------------
sub add_parents {
    my ($self, %args) = @_;

    my $acc   	  = $args{acc};
    my $term  	  = $args{term};
    my $term_url  = $args{term_url};
    my $gv_sm 	  = $args{gv_sm};
    my $gv_lg 	  = $args{gv_lg};
    my $seen  	  = $args{seen};
    my $fillcolor = $args{fillcolor};
    my $fontcolor = $args{fontcolor};
    my $diff_font_color = $args{diff_font_color};
    my $diff_fill_color = $args{diff_fill_color};
    my $graph_root_node = $args{graph_root_node};

    my $obo_graph = $self->obo_graph;
    my $parents  = $obo_graph->get_parent_terms($acc);

    for my $parent (@{$parents}) {
	next if $parent->acc eq $graph_root_node;
	my $relation;
	$seen = $self->draw_parent(parent    => $parent,
				   term      => $term,
				   term_url  => $term_url,
				   gv_sm     => $gv_sm,
				   gv_lg     => $gv_lg,
				   seen      => $seen,
				   relation  => $relation,
				   fillcolor => $fillcolor,
				   fontcolor => $fontcolor);

	$self->add_parents(acc              => $parent->acc,
			   term             => $parent,
			   term_url         => $term_url,
			   gv_sm            => $gv_sm,
			   gv_lg            => $gv_lg,
			   seen             => $seen,
			   fillcolor        => $fillcolor,
			   fontcolor        => $fontcolor,
			   diff_font_color  => $diff_font_color,
			   diff_fill_color  => $diff_fill_color,
			   graph_root_node  => $graph_root_node
			   );
    }

    if ($term->logical_definition) {
	my ($generic_term, $differentia) = $self->get_parents_by_logical_def($term);

	if($generic_term->acc ne $graph_root_node){
	    my $relation = 'is_a'.'\n(genus)';

	    $seen = $self->draw_parent(parent    => $generic_term,
				       term      => $term,
				       term_url  => $term_url,
				       gv_sm     => $gv_sm,
				       gv_lg     => $gv_lg,
				       seen      => $seen,
				       relation  => $relation,
				       fillcolor => $fillcolor,
				       fontcolor => $fontcolor);

	    $self->add_parents(acc              => $generic_term->acc,
			       term             => $generic_term,
			       term_url         => $term_url,
			       gv_sm            => $gv_sm,
			       gv_lg            => $gv_lg,
			       seen             => $seen,
			       fillcolor        => $fillcolor,
			       fontcolor        => $fontcolor,
			       diff_font_color  => $diff_font_color,
			       diff_fill_color  => $diff_fill_color,
			       graph_root_node  => $graph_root_node
			       );
	}

	foreach my $differentia_arr (@{$differentia}){
	    my $relation = $differentia_arr->[0].'\n(differentia)';	    
	    my $differentia_acc = $differentia_arr->[1];
	    my $parent = $obo_graph->get_term($differentia_acc);

	    if($parent->acc ne $graph_root_node){

		$fillcolor = $diff_fill_color;
		$fontcolor = $diff_font_color;

		$seen = $self->draw_parent(parent    => $parent,
					   term      => $term,
					   term_url  => $term_url,
					   gv_sm     => $gv_sm,
					   gv_lg     => $gv_lg,
					   seen      => $seen,
					   relation  => $relation,
					   fillcolor => $fillcolor,
					   fontcolor => $fontcolor);

		$self->add_parents(acc               => $parent->acc,
				   term              => $parent,
				   term_url          => $term_url,
				   gv_sm             => $gv_sm,
				   gv_lg             => $gv_lg,
				   seen              => $seen,
				   fillcolor         => $fillcolor,
				   fontcolor         => $fontcolor,
				   diff_font_color   => $diff_font_color,
				   diff_fill_color   => $diff_fill_color,
				   graph_root_node   => $graph_root_node
				   );
	    }
	}
    }
}
#-----------------------------------------------------------------------------
sub draw_parent{

    my ($self, %args) = @_;

    my $parent 	  = $args{parent};
    my $term   	  = $args{term}; 
    my $term_url  = $args{term_url};
    my $gv_sm  	  = $args{gv_sm}; 
    my $gv_lg  	  = $args{gv_lg}; 
    my $seen   	  = $args{seen}; 
    my $relation  = $args{relation}; 
    my $fillcolor = $args{fillcolor}; 
    my $fontcolor = $args{fontcolor}; 
    
    my $obo_graph =$self->obo_graph;

    if ($fillcolor eq 'black' || ! exists $gv_sm->{NODES}{$parent->name}) {
	$gv_sm->add_node($parent->name,
		      fontsize  => '20',
		      shape     => 'box',
		      style     => 'filled',
		      fontcolor => $fontcolor,
		      fillcolor => $fillcolor,
		      URL       => $term_url . $parent->acc,
		      );
	$gv_lg->add_node($parent->name,
			     fontsize  => '20',
			     shape     => 'box',
			     style     => 'filled',
			     fontcolor => $fontcolor,
			     fillcolor => $fillcolor,
			     URL       => $term_url . $parent->acc,
			     );
    }

    if ($relation){
	$gv_sm->add_edge($parent->name => $term->name,
			 label         => ' ' . $relation,
			 dir           => 'back',
			 style         => 'solid'
			 )
	    unless $seen->{$term->acc}{$parent->acc}{$relation};

	$gv_lg->add_edge($parent->name => $term->name,
			 label         => ' ' . $relation,
			 dir           => 'back',
			 style         => 'solid'
			 )
	    unless $seen->{$term->acc}{$parent->acc}{$relation};
	$seen->{$term->acc}{$parent->acc}{$relation}++;
    }
    else{
	my $relations = $obo_graph->get_relationships_between_terms($parent->acc, $term->acc);
	for $relation (@{$relations}) {
	    
	    $gv_sm->add_edge($parent->name => $term->name,
			     label         => ' ' . $relation ->type(),
			     dir           => 'back',
			     style         => 'solid'
			     )
		unless $seen->{$term->acc}{$parent->acc}{$relation->type};

	    $gv_lg->add_edge($parent->name => $term->name,
			     label         => ' ' . $relation ->type(),
			     dir           => 'back',
			     style         => 'solid'
			     )
		unless $seen->{$term->acc}{$parent->acc}{$relation->type};
	    $seen->{$term->acc}{$parent->acc}{$relation->type}++;
	}
    }
    return $seen;
}
#-----------------------------------------------------------------------------
sub get_parents_by_logical_def {

    my ($self, $term) = @_;
    
    my $obo_graph = $self->obo_graph; 

    my $ldef = $term->logical_definition;

    my $generic_term_acc = $ldef->generic_term_acc;

    my $generic_term = $obo_graph->get_term($generic_term_acc);

    my $differentia_array = $ldef->differentia;

    return ($generic_term, $differentia_array);
}
#-----------------------------------------------------------------------------
sub clean_path {

    my $path = shift;

    $path .= '/';

    $path =~ s|([^:])//|$1/|g;

    return $path;
}
#-----------------------------------------------------------------------------
1;
