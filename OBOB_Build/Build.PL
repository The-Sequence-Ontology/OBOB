#!/usr/bin/perl
eval 'exec /usr/bin/env perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;
use FindBin;
use Module::Build;

chdir($FindBin::Bin); #alway go here for safety

#configure Build

my $build = Module::Build->new
(
     module_name => 'OBOB',
     dist_author => 'Eilbeck Lab',
     dist_version_from  => "$FindBin::Bin/version",
     license => 'artistic_2',   
     dist_abstract => ('OBOB is a generic browser for ontologies that use OBO format. '.
		       'OBOB can search for an ontology term by entering the term name or synonym in the query box above; '.
		       'Explore the structure of ontology and browse for terms using the expandable, cascading tree on the left; '
		       ),
     auto_configure_requires => 1,
 requires => {
     'perl'               => '5.8.0',
     'mod_perl'       => '2.0',
     #'Apache'         => '2.0',

     'Apache2::RequestRec' => '0',
     'Apache2::RequestIO' => '0',
     'Apache2::RequestUtil' => '0',
     'Apache2::Const' => '0',
     'CGI::Application' => '0',
     'CGI::Application::Plugin::TT' => '0',
     'CGI::Application::Plugin::Config::Context' => '0',
     'CGI::Application::Plugin::Redirect' => '0',
     'CGI::Application::Plugin::ValidateRM' => '0',
     'GO::Parser'     => '0',
     'JSON::XS'       => '0',
     'GraphViz'       => '0',
   },
  install_base => "$FindBin::Bin/../",
 install_base_relpaths => {
     arch   => [qw(lib)],
     lib    => [qw(lib)],
     #bindoc => [qw(perl/man)],
     #libdoc => [qw(perl/man)],
  },
);


$build->create_build_script;

print "\n\nThe file 'Build' has been created for you to finish installing OBOB.\n";


