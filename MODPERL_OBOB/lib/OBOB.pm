package OBOB;

use strict;
use warnings;

use base 'CGI::Application';
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::Config::Context;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::ValidateRM(qw/check_rm/);

use lib $ENV{OBOB_PERL5LIB};

use OBOB::DB;

our (%db_global) = undef;

# Needed for the public version of OBOB.
use PHP::Session;
use CGI::Lite;
use CGI::Carp 'fatalsToBrowser';
use DBI;
my $dbh = DBI->connect('dbi:mysql:obob_members','srynearson','********') || die $DBI::errstr, "\n";

#-----------------------------------------------------------------------------

sub cgiapp_init {

    my $self = shift;
    my $q = $self->query;

    # Load cofiguratoin file
    $self->conf->init(
		      file   => $ENV{OBOB_CONFIG},
		      driver => 'ConfigGeneral',
		      );

	#-----------------------------------------------------------------------------
	# -->
	# This section is for the public version of OBOB	

	my $cgi = new CGI::Lite;
	my $cookies = $cgi->parse_cookies;
	
	my ( $username, $obo_file, $isSession);
	if ( $cookies )
	{
		# Default session_name;
		my $session_name = 'PHPSESSID';

		my ( $id, $fname, $lname );
		if ( $cookies->{$session_name} )
		{
			my $session = eval {PHP::Session->new($cookies->{$session_name}, { save_path => '/var/lib/php/session' } )};
			$id         = eval { $session->get('SESS_MEMBER_ID') };
			$fname      = eval { $session->get('SESS_FIRST_NAME') };
			$lname      = eval { $session->get('SESS_LAST_NAME') };
			$obo_file   = eval { $session->get('obofile')};
		}
	
		# Look up username.
		my $query = $dbh->prepare('SELECT login FROM members WHERE member_id = ? AND firstname = ? AND lastname = ?');
		$query->execute($id, $fname, $lname);
	
		my @login_ary = $query->fetchrow_array;
		$username     = shift @login_ary;
	}

	# Sets the path to file location if login.
	my $user_path;
	if ( $username ) { $user_path = $self->conf->param('ontology_data')->{file_path} . '/' . $username; }
	
	# Select the path desired file.
	my $obo_path;
	if ($user_path) { $obo_path = $user_path; }
	else{ $obo_path =  $self->conf->param('ontology_data')->{file_path}; }
	
	# selects user files or default
	my $view_file;
	if ( $obo_file && $username ){ $view_file = $obo_file; }
	else { $view_file = $q->param('release') || $self->conf->param('ontology_data')->{default_release}; }

	# clean up the file so OBOB can read it and assign release.
	$view_file =~ s/^(.*)\.obo/$1/;
	my $release = $view_file;

	# -->
	#-----------------------------------------------------------------------------
    
    # Configure the template
    my $tmp_path =  $self->conf->param('browser')->{tmp_path};
    $self->tt_config(TEMPLATE_OPTIONS => {INCLUDE_PATH => $tmp_path});
    $self->tt_params($self->conf->context);
    
    my $ontology_file;
    my $obo_extension =  $self->conf->param('ontology_data')->{obo_extension};
    
    my $server_url =  $self->conf->param('browser')->{server_url};
    my $cgi_path =  $self->conf->param('browser')->{cgi_path};
    my $img_url =  $self->conf->param('browser')->{img_url};
    my $img_path =  $self->conf->param('browser')->{img_path};
    my $wiki_path =  $self->conf->param('browser')->{wiki_path};
    my $title =  $self->conf->param('browser')->{title};
    my $head1 =  $self->conf->param('browser')->{head1};
    my $head2 =  $self->conf->param('browser')->{head2};
    my $menu_bar =  $self->conf->param('browser')->{menu_bar};
    my $css_style =  $self->conf->param('browser')->{css_style};
    my $footer =  $self->conf->param('browser')->{footer};
    my $body_inf =  $self->conf->param('browser')->{body_inf};
    my $focus_font_color = $self->conf->param('graph')->{focus_font_color};
    my $focus_fill_color = $self->conf->param('graph')->{focus_fill_color};
    my $term_font_color = $self->conf->param('graph')->{term_font_color};
    my $term_fill_color = $self->conf->param('graph')->{term_fill_color};
    my $diff_font_color = $self->conf->param('graph')->{diff_font_color};
    my $diff_fill_color = $self->conf->param('graph')->{diff_fill_color};
    my $parents_fill_color = $self->conf->param('graph')->{parents_fill_color};
    my $parents_font_color = $self->conf->param('graph')->{parents_font_color};
    my $children_fill_color = $self->conf->param('graph')->{children_fill_color};
    my $children_font_color = $self->conf->param('graph')->{children_font_color};
    my $graph_root_node = $self->conf->param('graph')->{graph_root_node};
    my $term_redirect_url =  $self->conf->param('browser')->{term_redirect_url};
    my $url_base_dir =  $self->conf->param('browser')->{url_base_dir};
    
    my $file_pattern_match =  $self->conf->param('ontology_data')->{file_pattern_match};
    my $dbxrefs_url_map =  $self->conf->param('dbxrefs')->{url_map};
    
    if(!($db_global{$release})){ 
	$db_global{$release} = OBOB::DB->new({obo_release        => $release,
					      obo_extension      => $obo_extension,
					      obo_path           => $obo_path,
					      url_base_dir       => $url_base_dir,
					      file_pattern_match => $file_pattern_match,
					      ontology_file      => $ontology_file,
					  });
    } 
    
    $self->param(db => $db_global{$release});
    $self->param(server_url => $server_url);
    $self->param(cgi_path => $cgi_path);
    $self->param(img_url => $img_url);
    $self->param(img_path => $img_path);
    $self->param(wiki_path => $wiki_path);
    $self->param(title => $title);
    $self->param(head1 => $head1);
    $self->param(head2 => $head2);
    $self->param(menu_bar => $menu_bar);
    $self->param(css_style => $css_style);
    $self->param(footer => $footer);
    $self->param(body_inf => $body_inf);
    
    $self->param(term_redirect_url => $term_redirect_url);
    $self->param(focus_font_color => $focus_font_color);
    $self->param(focus_fill_color => $focus_fill_color);
    $self->param(term_font_color => $term_font_color);
    $self->param(term_fill_color => $term_fill_color);
    $self->param(diff_font_color => $diff_font_color);
    $self->param(diff_fill_color => $diff_fill_color);
    $self->param(parents_fill_color => $parents_fill_color);
    $self->param(parents_font_color => $parents_font_color);
    $self->param(children_fill_color => $children_fill_color);
    $self->param(children_font_color => $children_font_color);
    $self->param(graph_root_node => $graph_root_node);
    $self->param(dbxrefs_url_map => $dbxrefs_url_map);
    $self->param(url_base_dir => $url_base_dir);
    
    # Get List of available releases
    my $releases = $db_global{$release}->obo_release_names;

    # only allow select release.
    $self->tt_params({releases          => $releases,
		      active_release    => $release,
		  });

}

#-----------------------------------------------------------------------------

1;
