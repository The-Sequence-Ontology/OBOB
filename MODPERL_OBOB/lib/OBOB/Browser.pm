package OBOB::Browser;

use strict;
use warnings;

use lib $ENV{OBOB_PERL5LIB};

use base 'OBOB';
use OBOB::Graph;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::RequestUtil ();

use Apache2::Const -compile => qw(OK);

#----------------------------------------------------------------------------
sub handler: method{
    my ($pkg, $r) = @_;
    my $self = $pkg->new();
    $self->run();
    
    return Apache2::Const::OK;
}
#-----------------------------------------------------------------------------
sub setup {

  my $self = shift;

  $self->start_mode('home');
  $self->run_modes(['home',
		    'term_list',
		    'term_detail',
		    'export_form',
		    'export',
		    'async_treeview_json',
		    'typedefs_treeview_json',
		    'obsolete_treeview_json',
		    'autocomplete'
		   ]);
}
#-----------------------------------------------------------------------------
sub teardown {

  my $self = shift;

}
#-----------------------------------------------------------------------------
sub home {

    my $self = shift;
    my $cgi_path = $self->param('cgi_path');
    my $title = $self->param('title');
    my $head1 = $self->param('head1');
    my $head2 = $self->param('head2');
    my $menu_bar = $self->param('menu_bar');
    my $css_style = $self->param('css_style');
    my $footer = $self->param('footer');
    my $body_inf = $self->param('body_inf');
    my $q = $self->query;

    return $self->tt_process('home.tt',{cgi_path   => $cgi_path,
					title      => $title,
					head1      => $head1,
					head2      => $head2,
					menu_bar   => $menu_bar,
					css_style  => $css_style,
					footer     => $footer,
					body_inf   => $body_inf,
				    });
}
#-----------------------------------------------------------------------------
sub term_list {

    my $self = shift;
    my $cgi_path = $self->param('cgi_path');
    my $title = $self->param('title');
    my $head1 = $self->param('head1');
    my $head2 = $self->param('head2');
    my $menu_bar = $self->param('menu_bar');
    my $css_style = $self->param('css_style');
    my $footer = $self->param('footer');
    my $server_url = $self->param('server_url');
    my $q = $self->query;
    my $obo_query = $q->param('obo_query') || $q->param('term_acc');

    my $release  = $q->param('release') ;

    my $url_base_dir = $self->param('url_base_dir');

    my $db = $self->param('db');

    my $results;
    $results = $db->search_ids_names_synonyms($obo_query);

     #If we had an exact match to an ID or a term, then redirect to that term
    if (! $obo_query) {
	return $self->redirect("$cgi_path/obob.cgi?release=$release");
    }

    if (scalar @{$results->{ids}} == 1) {
	return $self->redirect("/$url_base_dir/$release/term/$results->{ids}[0]{id}");
    }
    elsif (scalar @{$results->{exact_name}} == 1) {
	return $self->redirect("/$url_base_dir/$release/term/$results->{exact_name}[0]{id}");
    }elsif(scalar @{$results->{exact_synonym}} == 1) {
	return $self->redirect("/$url_base_dir/$release/term/$results->{exact_synonym}[0]{id}");
    }

    my @list;
    push @list, (@{$results->{ids}},
		 @{$results->{exact_name}},
		 @{$results->{exact_synonym}},
		 @{$results->{part_name}},
		 @{$results->{part_synonym}},
		 );

    #If there were no matches at all return an error page.
    if (! @list) {
	return $self->tt_process('ERROR_no_search_hit.tt',{cgi_path    => $cgi_path,
							   title       => $title,
							   head1       => $head1,
							   head2       => $head2,
							   menu_bar    => $menu_bar,
							   css_style   => $css_style,
							   footer      => $footer,
							   termname    => $obo_query,
							   release     => $release
						       });
    }

    return $self->tt_process('term_list.tt', {list       => \@list,
					      cgi_path   => $cgi_path,
					      title      => $title,
					      head1      => $head1,
					      head2      => $head2,
					      menu_bar   => $menu_bar,
					      css_style  => $css_style,
					      footer     => $footer,
					      server_url => $server_url,
					      termname   => $obo_query,
					  });
}
#-----------------------------------------------------------------------------
sub term_detail {

    my $self = shift;
    my $server_url = $self->param('server_url');
    my $cgi_path = $self->param('cgi_path');
    my $title = $self->param('title');
    my $head1 = $self->param('head1');
    my $head2 = $self->param('head2');
    my $menu_bar = $self->param('menu_bar');
    my $css_style = $self->param('css_style');
    my $footer = $self->param('footer');
    my $img_path = $self->param('img_path');
    my $wiki_path = $self->param('wiki_path');
    my $img_url = $self->param('img_url');
    my $term_redirect_url = $self->param('term_redirect_url');
    my $db = $self->param('db');

    my $focus_font_color = $self->param('focus_font_color');
    my $focus_fill_color = $self->param('focus_fill_color');
    my $diff_font_color = $self->param('diff_font_color');
    my $diff_fill_color = $self->param('diff_fill_color');
    my $parents_fill_color = $self->param('parents_fill_color');
    my $parents_font_color = $self->param('parents_font_color');
    my $children_fill_color = $self->param('children_fill_color');
    my $children_font_color = $self->param('children_font_color');
    my $graph_root_node = $self->param('graph_root_node');
    my $dbxrefs_url_map = $self->param('dbxrefs_url_map');
    
    my $q = $self->query;
    my $term_acc = $q->param('term_acc');
    my $release  = $q->param('release');

    my $obo_graph = $db->obo_graph;

    my $term     = $obo_graph->get_term($term_acc);

    my $children = $obo_graph->get_child_terms($term_acc);

    my $parents  = $obo_graph->get_parent_terms($term_acc);

    my $gv = OBOB::Graph->new({obo_graph           => $obo_graph,
			       });
    $img_path = $img_path .'/' . $release . "/";
    $img_url = $img_url .'/' . $release . "/"; 

    my $term_url  = $term_redirect_url . '/' . $release.'/'.  "/term/";

    $ENV{PATH} .= ':/usr/local/bin';

    my $gv_rv = $gv->get_graphviz(term_url            => $term_url,
				  img_url             => $img_url,
				  img_path            => $img_path,
				  acc                 => $term_acc,
				  focus_font_color    => $focus_font_color,
				  focus_fill_color    => $focus_fill_color,
				  parents_fill_color  => $parents_fill_color,
				  parents_font_color  => $parents_font_color,
				  children_fill_color => $children_fill_color,
				  children_font_color => $children_font_color,
				  diff_fill_color     => $diff_fill_color,
				  diff_font_color     => $diff_font_color,
				  graph_root_node     => $graph_root_node,
				  force               => 1,
				  );

    my $gif_sm_link = $gv_rv->{gif_sm_link};
    my $gif_sm_map  = $gv_rv->{gif_sm_map};
    my $gif_lg_link = $gv_rv->{gif_lg_link};
    my $gif_lg_map  = $gv_rv->{gif_lg_map};

#    my @link_list;
#
#    if($term){
#	my $dbxref_list = $term->definition_dbxref_list;
#	for my $dbxref (@{$dbxref_list}) {
#	    my %links;
#	    my %link;
#	
#	    if(($dbxref->xref_dbname eq 'PMID')  or
#	       ($dbxref->xref_dbname eq 'ISBN')  or
#	       ($dbxref->xref_dbname eq 'CHEBI') or
#	       ($dbxref->xref_dbname eq 'URL')){
#		if($dbxref->xref_dbname eq 'URL'){
#		    $link{$dbxref->xref_key} = $dbxref->xref_key;
#		}else{
#		    my @keys = split /:/, $dbxref->xref_key;
#		    for my $key (@keys){
#			$key =~ s/\=//;
#			my $web = $dbxrefs_url_map->{$dbxref->xref_dbname}.$key;
#			$link{$key} = $web;
#		    }
#		}
#	    }else{
#		$link{$dbxref->xref_key} = "";
#	    }
#    
#	    $links{"web"} = \%link;
#	    $links{"xref_dbname"} = $dbxref->xref_dbname;
#	    push @link_list, \%links;
#	}
#    }
#    

# Change from original form for OBOB, now display only definition ref.

    my $dbxref_list = $term->definition_dbxref_list;

    my @link_list;
    for my $dbxref (@{$dbxref_list}) {
        my %links;
        my %link;

        if(($dbxref->xref_dbname eq 'MeSH'|| 'FMA' || 'SYMP')){
                my @keys = split /:/, $dbxref->xref_key;
                for my $key (@keys){
                    my $tag = $dbxref->xref_key;
                    $link{$key} = $tag;
                }
            }

        $links{"tag"} = \%link;
        $links{"xref_dbname"} = $dbxref->xref_dbname;
        push @link_list, \%links;
    }

# Copied and changed to allow view of xref: data in obo file.


        my $db_xref = $term->dbxref_list;

        my @xref_list;
        for my $db (@$db_xref) {

                my $value;
                if ($db->xref_desc) {
                        my $ref = join(':', $db->xref_dbname, $db->xref_key);
                        my $desc = join(' ', $ref, $db->xref_desc);
                        push @xref_list, $desc;
                }
                else {
                        my $value .= join(':', $db->xref_dbname, $db->xref_key);
                        push @xref_list, $value;
                }

        }



    return $self->tt_process('term_detail.tt', {term            => $term,
						children        => $children,
						parents         => $parents,
						gif_link        => $gif_sm_link,
						gif_map         => $gif_sm_map,
						gif_normal_link => $gif_lg_link,
						gif_normal_map  => $gif_lg_map,
						link_list       => \@link_list,
						cgi_path        => $cgi_path,
						title           => $title,
						head1           => $head1,
						head2           => $head2,
						menu_bar        => $menu_bar,
						css_style       => $css_style,
						footer          => $footer,
						server_url      => $server_url,
						wiki_path       => $wiki_path,
						xref_list	=> \@xref_list,
						});
}
#-----------------------------------------------------------------------------
sub export_form {

    my $self = shift;

    my $url_base_dir = $self->param('url_base_dir');
    my $q = $self->query;

    my $graph_type = $q->param('graph_type');
    my $release    = $q->param('release');
    my $format     = $q->param('format');
    my $term_acc   = $q->param('term_acc');

    return $self->redirect("/$url_base_dir/$release/export/$graph_type/$format/$term_acc");
}
#-----------------------------------------------------------------------------
sub export {

    my $self = shift;

    my $q = $self->query;
    my $graph_type = $q->param('graph_type');
    my $format     = $q->param('format');
    my $term_acc   = $q->param('term_acc');

    my $db = $self->param('db');
    my $obo_graph = $db->obo_graph;

    my $term = $obo_graph->get_term($term_acc);
    my $children = $obo_graph->get_child_terms($term_acc);
    my $parents  = $obo_graph->get_parent_terms($term_acc);

    my $sub_graph;
    if ($graph_type eq 'term_only') {
	$sub_graph = $obo_graph->subgraph_by_terms([$term],
						  {partial => 1});
    }
    elsif ($graph_type eq 'term_with_children') {
	$sub_graph = $obo_graph->subgraph_by_terms([$term, @{$children}],
						  {partial => 1} );
    }
    elsif ($graph_type eq 'term_with_parents') {
	$sub_graph = $obo_graph->subgraph_by_terms([$term, @{$parents}],
						  {partial => 1});
    }
    elsif ($graph_type eq 'term_with_parents_children') {
	$sub_graph = $obo_graph->subgraph_by_terms([$term, @{$children}, @{$parents}],
						   {partial => 1});
    }
    elsif ($graph_type eq 'complete_term_graph') {
	my $children = $obo_graph->get_recursive_child_terms($term_acc);
	my $parents  = $obo_graph->get_recursive_parent_terms($term_acc);
	$sub_graph = $obo_graph->subgraph_by_terms([$term, @{$children}, @{$parents}]);
    }

    $format = 'to_' . $format;

    $self->$format($sub_graph, $obo_graph);
}
#-----------------------------------------------------------------------------
sub to_obo {

    my ($self, $sub_graph, $obo_graph) = @_;

    my $relations = $sub_graph->get_all_relationships;

    my @relation_terms;
    for my $relation (@{$relations}) {
	my $relation_term = $obo_graph->get_term_by_name($relation->type);
	push(@relation_terms, $relation_term) if $relation_term;
    }
    
    $sub_graph = $obo_graph->subgraph_by_terms([@{$sub_graph->get_all_nodes}, @relation_terms]);

    $self->header_props(-type=>'text/plain');
    
    return $sub_graph->export({format => 'obo'});
}
#-----------------------------------------------------------------------------
sub to_html_table {

    my ($self, $sub_graph, $obo_graph) = @_;

    my $server_url = $self->param('server_url');
    my $cgi_path = $self->param('cgi_path');
    my $wiki_path = $self->param('wiki_path');
    
    $self->header_props(-type=>'text/plain');
    
    return $self->tt_process('export_to_html.tt', {sub_graph  => $sub_graph,
						   obo_graph  => $obo_graph,
						   server_url => $server_url,
						   cgi_path   => $cgi_path,
						   wiki_path  => $wiki_path,
					       });
}
#-----------------------------------------------------------------------------
sub to_csv_text {

    my ($self, $sub_graph, $obo_graph) = @_;
    $self->header_props(-type=>'text/plain');
    
    return $self->tt_process('export_to_csv_text.tt', {sub_graph  => $sub_graph,
						       obo_graph  => $obo_graph,
						   });
}
#-----------------------------------------------------------------------------
sub autocomplete {
    my $self = shift;
    
    my $q = $self->query;
    my $obo_query = $q->param('obo_query') || $q->param('q');
    if($obo_query =~ /\\|\*|\(|\+|\[/){
	return;
    }

    my $db = $self->param('db');
    my $obo_names    = $db->get_names;
    my $obo_synonyms = $db->get_synonyms;
    my $obo_ids      = $db->get_ids;
    
    my @begining_matches;
    my @internal_matches;
    
    for my $term (sort {length($a) <=> length($b) || $a cmp $b} @{$obo_names}) {
	if ($term =~ /^($obo_query)/i) {
	    push @begining_matches, "<span class='autolist_name'>$term [TERM]</span>";
	}
	elsif ($term =~ /($obo_query)/i) {
	    push @internal_matches, "<span class='autolist_name'>$term [TERM]</span>";
	}
    }
    
    for my $term (sort {length($a) <=> length($b) || $a cmp $b} @{$obo_synonyms}) {
	if ($term =~ /^($obo_query)/i) {
	    push @begining_matches, "<span class='autolist_synonym'>$term [SYNONYM]</span>";
	}
	elsif ($term =~ /($obo_query)/i) {
	    push @internal_matches, "<span class='autolist_synonym'>$term [SYNONYM]</span>";
	}
    }
    
    for my $term (sort {length($a) <=> length($b) || $a cmp $b} @{$obo_ids}) {
	if ($term =~ /^($obo_query)/i) {
	    push @begining_matches, "<span class='autolist_id'>$term [ID]</span>";
	}
	elsif ($term =~ /($obo_query)/i) {
	    push @internal_matches, "<span class='autolist_id'>$term [ID]</span>";
	}
    }
    
    return join "\n", @begining_matches, @internal_matches;
}
#-----------------------------------------------------------------------------
sub async_treeview_json {
  
  my $self = shift;
  
  my $q               = $self->query;
  my $root_acc        = $q->param('root');
  my $graph_root_node = $q->param('graph_root_node');
  my $term_acc        = $q->param('term_acc');
  my $tree_control    = $q->param('tree_control');
  my $release         = $q->param('release');
  my $db              = $self->param('db');
  
  $root_acc ||= $graph_root_node;
  
  my $treeview_json = $db->get_treeview_json($root_acc, $term_acc, $release, $tree_control);
  
  return $treeview_json;
}
#-----------------------------------------------------------------------------
sub typedefs_treeview_json {

  my $self = shift;

  my $q               = $self->query;
  my $root_acc        = $q->param('root');
  my $graph_root_node = $q->param('graph_root_node');
  my $term_acc        = $q->param('term_acc');
  my $tree_control    = $self->param('tree_control');
  
  $root_acc ||= $graph_root_node;

  my $db = $self->param('db');
  my $release = $q->param('release');
  my $treeview_json = $db->get_typedefs_treeview_json($root_acc, $term_acc, $release, $tree_control);

  return $treeview_json;
}
#-----------------------------------------------------------------------------
sub obsolete_treeview_json {

  my $self = shift;

  my $q        = $self->query;
  my $term_acc = $q->param('term_acc');

  my $release                = $q->param('release');
  my $db                     = $self->param('db');
  my $obsolete_treeview_json = $db->get_obsolete_treeview_json($term_acc,$release);

  return $obsolete_treeview_json;
}
#-----------------------------------------------------------------------------
1;
