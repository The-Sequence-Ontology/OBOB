package OBOB::DB;
use strict;
use warnings;

use lib $ENV{OBOB_PERL5LIB};

use GO::Parser;
use JSON::XS;

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
    my ($self, $arg) = @_;

    # all data come in through arg.
    $self->obo_path($arg->{obo_path})       if $arg->{obo_path};
    $self->obo_extension($arg->{obo_extension})       if $arg->{obo_extension};
    $self->obo_release($arg->{obo_release})           if $arg->{obo_release};
    $self->url_base_dir($arg->{url_base_dir})	    if $arg->{url_base_dir};
    $self->file_pattern_match($arg->{file_pattern_match})	    if $arg->{file_pattern_match};
    $self->ontology_file($arg->{ontology_file})	    if $arg->{ontology_file};
    return;
}
#-----------------------------------------------------------------------------
sub url_base_dir {
    my ($self, $url_base_dir) = @_;
    
    $self->{url_base_dir} ||= 'browser'; 
    $self->{url_base_dir} = $url_base_dir if $url_base_dir;

    return $self->{url_base_dir};
}
#-----------------------------------------------------------------------------
sub obo_release {
    my ($self, $obo_release) = @_;

    $self->{obo_release} = $obo_release if $obo_release;

    return $self->{obo_release};
}
#-----------------------------------------------------------------------------
sub obo_release_names {

    my $self = shift;

    my $ontology_file = $self->ontology_file;
    my $file_num = scalar(keys %{$ontology_file}); 
    my $obo_extension = $self->obo_extension;

    if($file_num > 0){
	my @files;
	for my $file (sort {$ontology_file->{$a}{'sort_order'} <=> $ontology_file->{$b}{'sort_order'}} keys %{$ontology_file}){
	    push @files, $ontology_file->{$file}{'public_name'};
	}
	map {s/.${obo_extension}$/$1/} @files;
	return \@files;
    }else{
	my $path = $self->obo_path;
	my $file_pattern_match = $self->file_pattern_match;
	my @files = <${path}${file_pattern_match}>;
	map {s/.*?([^\/]+).${obo_extension}$/$1/} @files;
	return \@files;
    }
}
#-----------------------------------------------------------------------------
sub obo_path {
    my ($self, $obo_path) = @_;
    
    $self->{obo_path} = $obo_path . '/' if $obo_path;
    $self->{obo_path} =~ s|//$|/|;

    return $self->{obo_path};
}
#-----------------------------------------------------------------------------
sub obo_file {
    my ($self, $obo_file) = @_;

    my $ontology_file = $self->ontology_file;
    my $file_num = scalar(keys %{$ontology_file});
    my $obo_extension = $self->obo_extension;

    if($file_num > 0){
	for my $file (keys %{$ontology_file}){
	    my $pub_name = $ontology_file->{$file}{'public_name'};
	    $pub_name =~ s/.${obo_extension}$//;
	    
	    if($pub_name eq $self->obo_release){
		$self->{obo_file} ||= $ontology_file->{$file}{'local_file'}; 
	    }
	}
    }else{
	$self->{obo_file} ||= $self->obo_path . $self->obo_release . '.' . $self->obo_extension;
	
	$self->{obo_file} = $obo_file if $obo_file;
    }
    return $self->{obo_file};
}
#-----------------------------------------------------------------------------
sub obo_extension {
    my ($self, $obo_extension) = @_;

    $self->{obo_extension} ||= 'obo';
    $self->{obo_extension} = $obo_extension if $obo_extension;

    return $self->{obo_extension};
}
#-----------------------------------------------------------------------------
sub file_pattern_match {
    my ($self, $file_pattern_match) = @_;

    $self->{file_pattern_match} ||= '*.obo';
    $self->{file_pattern_match} = $file_pattern_match if $file_pattern_match;

    return $self->{file_pattern_match};
}
#-----------------------------------------------------------------------------
sub ontology_file {
    my ($self, $ontology_file) = @_;

    $self->{ontology_file} = $ontology_file if $ontology_file;

    return $self->{ontology_file};
}
#-----------------------------------------------------------------------------
sub get_names {
    my $self = shift;
    if ($self->{names}) {
	return wantarray ? @{$self->{names}} : $self->{names};
    }
    
    my $obo_file = $self->obo_file;
    
    my @names = `grep -P '^name:' $obo_file`;
    chomp @names;
    map {s/^name:\s+//; s/\s+$//} @names;
    
    $self->{names} = \@names;
    
    return wantarray ? @{$self->{names}} : $self->{names};
}
#-----------------------------------------------------------------------------
sub get_synonyms {
    my $self = shift;
    if ($self->{synonyms}) {
	return wantarray ? @{$self->{synonyms}} : $self->{synonyms};
    }

    my $obo_file = $self->obo_file;
    
    my @synonyms = `grep -P '^synonym:' $obo_file`;
    chomp @synonyms;
    map {s/^synonym:\s+"\s*//; s/\s*"\s+(BROAD|EXACT|NARROW|RELATED)\s+\[\]//} @synonyms;
    
    $self->{synonyms} = \@synonyms;
    
    return wantarray ? @{$self->{synonyms}} : $self->{synonyms};
}
#-----------------------------------------------------------------------------
sub get_ids {
    my $self = shift;

    if ($self->{ids}) {
	return wantarray ? @{$self->{ids}} : $self->{ids};
    }
    
    my $obo_file = $self->obo_file;
    
    my @ids = `grep -P '^id:' $obo_file`;
    chomp @ids;
    map {s/^id:\s+//; s/\s+$//} @ids;
    $self->{ids} = \@ids;
    
    return wantarray ? @{$self->{ids}} : $self->{ids};
}
#-----------------------------------------------------------------------------
sub cheap_get_map {
    my $self = shift;

    my $obo_file = $self->obo_file;
    
    my @lines = `grep -P '^(id:|name)' $obo_file`;

    chomp @lines;

    my %map;
    while (@lines) {

	my $id   = shift @lines;
	my $name = shift @lines;
	
	$id   =~ s/id:\s+//;
	$name =~ s/name:\s+//;
	
	$map{$id}   = $name;
	$map{$name} = $id;
	
    }
    
    return \%map;
}
#-----------------------------------------------------------------------------
sub search_id{
    my ($self,$text) = @_;
    my $name_map = $self->name_map;
    my @exact_name;

    for my $name (keys %{$name_map}) {
	return $name_map->{$name}{id} if $name =~ /^$text$/i;
    }

    return undef;
}
#-----------------------------------------------------------------------------
sub search_ids_names_synonyms {
    my ($self, $text) = @_;
    
    my $obo_graph = $self->obo_graph;
    
    my @ids;
    my $id_list = $self->get_ids;
    for my $id (@{$id_list}) {
	if ($id =~ /$text/) {
	    my $term = $obo_graph->get_term($id);
	    push @ids, {id    => $id,
			term  => $term,
			text  => $text,
		    };
	}
    }
    my @exact_name;
    my @part_name;
    my $name_map = $self->name_map;
    for my $name (keys %{$name_map}) {
	if ($name =~ /^$text$/) {
	    my $id = $name_map->{$name}{id};
	    my $term = $obo_graph->get_term($id);
	    push @exact_name, {id    => $id,
			       term  => $term,
			       text  => $text,
			   };
	}
	elsif ($name =~ /$text/i) {
	    my $id = $name_map->{$name}{id};
	    my $term = $obo_graph->get_term($id);
	    push @part_name, {id    => $id,
			      term  => $term,
			      text  => $text,
			  };
	}
    }
    
    my @exact_synonym;
    my @part_synonym;
    my $synonym_map = $self->synonym_map;
    for my $synonym (keys %{$synonym_map}) {
	if ($synonym =~ /^$text$/) {
	    my $id = $synonym_map->{$synonym}{id};
	    my $term = $obo_graph->get_term($id);
	    push @exact_synonym, {id    => $id,
				  term  => $term,
				  text  => $text,
			      };
	}
	elsif ($synonym =~ /$text/i) {
	    my $id = $synonym_map->{$synonym}{id};
	    my $term = $obo_graph->get_term($id);
	    push @part_synonym, {id    => $id,
				 term  => $term,
				 text  => $text,
			     };
	}
    }
    
    @ids           = sort {$a->{id}           cmp $b->{id}} @ids;
    @exact_name    = sort {length($a->{term}->name) <=> length($b->{term}->name)} @exact_name;
    @part_name     = sort {length($a->{term}->name) <=> length($b->{term}->name)} @part_name;
    @exact_synonym = sort {length($a->{term}->name) <=> length($b->{term}->name)} @exact_synonym;
    @part_synonym  = sort {length($a->{term}->name) <=> length($b->{term}->name)} @part_synonym;

    my $search_results = {ids           => \@ids,
			  exact_name    => \@exact_name,
			  exact_synonym => \@exact_synonym,
			  part_name     => \@part_name,
			  part_synonym  => \@part_synonym,
		      };
    
    return $search_results;
}
#-----------------------------------------------------------------------------
sub parse_obo_file {
    my $self = shift;

    return $self->{obo_terms} if $self->{obo_terms};

    my $obo_file = $self->obo_file;

    open (my $IN, '<', $obo_file) or die "Can't open $obo_file for reading\n";

    my $data = do {local $/; <$IN>};

    my @terms = $data =~ /\[Term\]\n(.*?)\n{2,}/gs;

    my %obo_terms;
    for my $term (@terms) {
	my @attributes = split /\n/, $term;
	my %attributes_hash;
	for my $attribute (@attributes) {
	    my ($key, $value) = split /:\s+/, $attribute;
	    if ($key eq 'synonym') {
		$value =~ s/"(.*)".*/$1/;
	    }
	    push @{$attributes_hash{$key}}, $value;
	}
	$obo_terms{$attributes_hash{id}[0]} = \%attributes_hash;
    }
    
    $self->{obo_terms} = \%obo_terms;
    
    return $self->{obo_terms};
}
#-----------------------------------------------------------------------------
sub get_obo_typedefs {
    my $self = shift;

    return $self->{obo_typedefs} if $self->{obo_typedefs};

    my $obo_file = $self->obo_file;

    open (my $IN, '<', $obo_file) or die "Can't open $obo_file for reading\n";

    my $data = do {local $/; <$IN>};

    my @typedefs = $data =~ /\[Typedef\]\n(.*?)\n{1,}/gs;
    my %obo_typedefs;
    
    for my $typedef (@typedefs) {
	my ($key, $value) = split /:\s+/, $typedef;
	$obo_typedefs{$value}++;
    }
    
    $self->{obo_typedefs} = \%obo_typedefs;
    
    return $self->{obo_typedefs};
}
#-----------------------------------------------------------------------------
sub name_map {
    my $self = shift;

    return $self->{name_map} if $self->{name_map};

    my $obo_terms = $self->parse_obo_file;

    my %name_map;
    for my $id (keys %{$obo_terms}) {
	for my $name (@{$obo_terms->{$id}{name}}) {
	    $name_map{$name} = {id   => $id,
				synonym => $obo_terms->{$id}{synonym},
			    };
	}
    }

    $self->{name_map} = \%name_map;

    return  $self->{name_map};
}
#-----------------------------------------------------------------------------
sub synonym_map {
    my $self = shift;

    return $self->{synonym_map} if $self->{synonym_map};

    my $obo_terms = $self->parse_obo_file;

    my %synonym_map;
    for my $id (keys %{$obo_terms}) {
	for my $synonym (@{$obo_terms->{$id}{synonym}}) {
	    $synonym_map{$synonym} = {id   => $id,
				      name => $obo_terms->{$id}{name}[0],
				  };
	}
    }
    
    $self->{synonym_map} = \%synonym_map;
    
    return  $self->{synonym_map};
}
#-----------------------------------------------------------------------------
sub obo_graph {
    my $self = shift;

    return $self->{obo_graph} if $self->{obo_graph};
	
    my $parser = new GO::Parser({handler   => 'obj',
				 use_cache => 1
				 });
    
    $parser->parse($self->obo_file);
    
    my $obo_graph = $parser->handler->graph;
    
    $self->{obo_graph} = $obo_graph;
    
    return $self->{obo_graph};
}
#----------------------------------------------------------------------------
sub obo_graph_xp {
    my $self = shift;

    return $self->{obo_graph_xp} if $self->{obo_graph_xp};

    my $parser = new GO::Parser({handler   => 'obj',
				 use_cache =>1
				 });

    $parser->parse($self->obo_file_xp);

    my $obo_graph_xp = $parser->handler->graph;

    $self->{obo_graph_xp} = $obo_graph_xp;

    return $self->{obo_graph_xp};
}
#-----------------------------------------------------------------------------
sub get_children_graph {
    my ($self, $parent_acc) = @_;

    my $args = {partial => 1};

    my $obo_graph = $self->obo_graph;

    my $child_terms = $obo_graph->get_child_terms($parent_acc);

    my $subgraph = $obo_graph->subgraph_by_terms($child_terms, $args);

    return $subgraph;
}
#-----------------------------------------------------------------------------
sub get_recursive_children_graph {
    my ($self, $parent_acc) = @_;

    my $args = {partial => 0};

    my $obo_graph = $self->obo_graph;

    my $terms = $obo_graph->term_query({acc => $parent_acc});

    my $child_terms = $obo_graph->get_recursive_child_terms($parent_acc);

    push @{$terms} , @{$child_terms};

    my $subgraph = $obo_graph->subgraph_by_terms($terms, $args);

    return $subgraph;
}
#-----------------------------------------------------------------------------
sub get_treeview_json {
    my ($self, $root_acc, $child_acc, $release, $tree_control) = @_;

    my $obo_graph = $self->obo_graph;

    my $path_terms;
    if ($child_acc) {
	my $child_term = $obo_graph->get_term($child_acc);
	$path_terms    = $obo_graph->get_recursive_parent_terms_by_type($child_acc, 'is_a');
	push @{$path_terms}, $child_term;
    }
    
    my $tree = $self->get_child_tree($obo_graph, $root_acc, $child_acc, $path_terms, $release, $tree_control);
	
    return JSON::XS->new->pretty(1)->encode($tree);
}
#-----------------------------------------------------------------------------
sub get_typedefs_treeview_json {
    my ($self, $root_acc, $child_acc, $release, $tree_control) = @_;

    my $obo_graph = $self->obo_graph;

    my $path_terms;

    if ($child_acc) {
	my $child_term = $obo_graph->get_term($child_acc);
	$path_terms = $obo_graph->get_recursive_parent_terms_by_type($child_acc, 'is_a');
	push @{$path_terms}, $child_term;
    }

    my $expand = JSON::XS::false ;
    my $child_tree;
    ($child_tree,$expand) = $self->get_typedefs_child_tree($obo_graph, $root_acc, $child_acc, $path_terms, $expand, $release, $tree_control);

    if($root_acc eq 'source'){
	my $tree;
	$tree = [
		 {
		     has_children => JSON::XS::true,
		     id           => 'Relationship',
		     text         => 'Relationship',
		     children     => \@{$child_tree},
		     expanded     => $expand,
		 }
		 ];
	
	return JSON::XS->new->pretty(1)->encode($tree);
    }else{
	return JSON::XS->new->pretty(1)->encode($child_tree);
    }
}
#-----------------------------------------------------------------------------
sub get_obsolete_treeview_json {
    my ($self, $query_acc, $release) = @_;
    my $url_base_dir = $self->url_base_dir;
    my $obo_graph = $self->obo_graph;
    my $root_nodes = $obo_graph->find_roots;
    my @obsolete_terms = grep {$_->is_obsolete} @{$root_nodes};
 
    $query_acc ||= '';

    my $expand;
    if (grep {$_->acc eq $query_acc} @obsolete_terms) {
	$expand = JSON::XS::true ;
    }
    else {
	$expand = JSON::XS::false;
    }

    my @obsoletes_tree;

    for my $term (sort{$a->{'name'} cmp $b->{'name'}} @obsolete_terms) {
	my $term_text = '<a href="' . "/$url_base_dir/$release/term/" . $term->acc . '">' . $term->name . '</a>';

	my $node = {
            text 	 => $term_text,
	    id   	 => $term->acc,
	    has_children => JSON::XS::false,
	};
	push @obsoletes_tree, $node,
    }
    
    my $tree;
 
    $tree = [
	     {
		 has_children => JSON::XS::true,
		 id           => 'Obsoletes',
		 text         => 'Obsolete Terms',
		 children     => \@obsoletes_tree,
		 expanded     => $expand,
	     }
	     ];
    
    return JSON::XS->new->pretty(1)->encode($tree);
}
#-----------------------------------------------------------------------------
sub get_child_tree {

    my ($self, $obo_graph, $root_acc, $child_acc, $path_terms, $release, $tree_control) = @_;

    # Edit for non-SO use.                                                                                
    my $obo_typedefs = $self->get_obo_typedefs;

    my $url_base_dir = $self->url_base_dir;
    my $children;
    if ($root_acc eq 'source') {
	my $root_nodes = $obo_graph->find_roots;
	my @root_terms = grep {! $_->is_obsolete && ! $obo_typedefs->{$_->acc}} @{$root_nodes};
	#When at the source of the tree, let the root terms be the children;
	$children = \@root_terms;
    }
    else {
	#$children = $obo_graph->get_child_terms($root_acc);
	$children = $obo_graph->get_child_terms_by_type($root_acc, 'is_a');
    }

    return [] if ! scalar @{$children};
    
    my $tree = [];
    for my $term (sort {$a->{'name'} cmp $b->{'name'}} @{$children}) {
	my $acc = $term->acc;
	my $term_text = '<a href="' . "/$url_base_dir/$release/term/" . $term->acc . '">' . $term->name . '</a>';
	my $term_tree = {text => $term_text,
			 id   => $acc
			 };
	
	if ($acc eq $child_acc) {
	    $term_tree->{classes} = 'focus';
	}
	if ($root_acc eq 'source') {
	    if (ref $path_terms eq 'ARRAY' && grep {$acc eq $_->acc} @{$path_terms}) {
		$term_tree->{expanded} = JSON::XS::true;
		my $child_tree = $self->get_child_tree($obo_graph, $acc, $child_acc, $path_terms, $release, $tree_control);
		$term_tree->{children} = $child_tree if scalar @{$child_tree};
	    }else{
		$term_tree->{hasChildren} = JSON::XS::true if ! $obo_graph->is_leaf_node($acc);
	    }
	}else{
	    if($tree_control){
		$term_tree->{expanded} = JSON::XS::true;
		my $child_tree = $self->get_child_tree($obo_graph, $acc, $child_acc, $path_terms, $release, $tree_control);
		$term_tree->{children} = $child_tree if scalar @{$child_tree};
	    }else{
		if (ref $path_terms eq 'ARRAY' && grep {$acc eq $_->acc} @{$path_terms}) {
		    $term_tree->{expanded} = JSON::XS::true;
		    my $child_tree = $self->get_child_tree($obo_graph, $acc, $child_acc, $path_terms, $release, $tree_control);
		    $term_tree->{children} = $child_tree if scalar @{$child_tree};
		}else{
		    $term_tree->{hasChildren} = JSON::XS::true if ! $obo_graph->is_leaf_node($acc);
		}
	    }
	}
	push @{$tree}, $term_tree;
    }
    
    return $tree;
}
#-----------------------------------------------------------------------------
sub get_typedefs_child_tree {

    my ($self, $obo_graph, $root_acc, $child_acc, $path_terms, $expand, $release, $tree_control) = @_;

    # Edit for non-SO use.                                                                                
    my $obo_typedefs = $self->get_obo_typedefs;
    my $url_base_dir = $self->url_base_dir;
    my $children;
    
    if ($root_acc eq 'source') {
	my $root_nodes = $obo_graph->find_roots;
	my @root_terms = grep {! $_->is_obsolete && $obo_typedefs->{$_->acc}} @{$root_nodes};
	#When at the source of the tree, let the root terms be the children;
	$children = \@root_terms;
    }
    else {
	$children = $obo_graph->get_child_terms($root_acc);
    }
    
    return [] if ! scalar @{$children};

    my $tree = [];
    for my $term (sort {$a->{'name'} cmp $b->{'name'}} @{$children}) {
	my $acc = $term->acc;
	my $term_tree = [];
	my $term_text = '<a href="' . "/$url_base_dir/$release/term/" . $term->acc . '">' . $term->name . '</a>';
	$term_tree = {text => $term_text,
		      id   => $acc
		      };
	
	if ($acc eq $child_acc) {
	    $term_tree->{classes} = 'focus';
	}
	if($tree_control){
	    $term_tree->{expanded} = JSON::XS::true;
	}else{
	    $term_tree->{expanded} = JSON::XS::false;
	}
	if (ref $path_terms eq 'ARRAY' && grep {$acc eq $_->acc} @{$path_terms}) {
	    $term_tree->{expanded} = JSON::XS::true;
	    $expand = JSON::XS::true;
	}
	my ($child_tree, $expand) = $self->get_typedefs_child_tree($obo_graph, $acc, $child_acc, $path_terms,$expand, $release, $tree_control);
	$term_tree->{children} = $child_tree if scalar @{$child_tree};
	
	push @{$tree}, $term_tree;
	
    }
    return ($tree, $expand);
}
#-----------------------------------------------------------------------------
1;

