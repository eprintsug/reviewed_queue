=head1 NAME

EPrints::Plugin::Screen::UBStatus

=cut


package EPrints::Plugin::Screen::UBStatus;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen::Status' );

use strict;

sub render
{
	my( $self ) = @_;

	$self->indexer_warnings();

	my $session = $self->{session};
	my $user = $session->current_user;

	my $rows;

	# Number of users in each group
	my $total_users = $session->dataset( "user" )->count( $session );

	my %num_users = ();
	my $userds = $session->dataset( "user" );
	my $subds = $session->dataset( "saved_search" );
	my @usertypes = $session->get_repository->get_types( "user" );
	foreach my $usertype ( @usertypes )
	{
		my $searchexp = new EPrints::Search(
			session => $session,
			dataset => $userds );
	
		$searchexp->add_field(
			$userds->get_field( "usertype" ),
			$usertype );

		my $result = $searchexp->perform_search();
		$num_users{ $usertype } = $result->count();
	}

	my %num_eprints = ();
	my @esets = ( "archive", "buffer", "reviewed", "inbox", "deletion" );

	foreach( @esets )
	{
		# Number of submissions in dataset
		$num_eprints{$_} = $session->dataset( $_ )->count( $session );
	}
	
	my $db_status = ( $total_users > 0 ? "ok" : "down" );


	my $indexer_status;

	if( !$self->get_daemon->is_running() )
	{
		$indexer_status = "stopped";
	}
	elsif( $self->get_daemon->has_stalled() )
	{
		$indexer_status = "stalled";
	}
	else
	{
		$indexer_status = "running";
	}

	my( $html , $table , $p , $span );
	
	# Write the results to a table
	
	$html = $session->make_doc_fragment;

	$html->appendChild( $self->render_common_action_buttons );

	$table = $session->make_element( "table", border=>"0" );
	$html->appendChild( $table );
	
	$table->appendChild( $session->render_row( 
			$session->html_phrase( "cgi/users/status:release" ),
			$session->make_text( EPrints->human_version ) ) );

	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:database_driver" ),
			$session->make_text( $session->get_database()->get_driver_name ) ) );
	
	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:database_version" ),
			$session->make_text( $session->get_database()->get_server_version ) ) );
	
	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:database" ),
			$session->html_phrase( "cgi/users/status:database_".$db_status ) ) );
	
	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:indexer" ),
			$session->html_phrase( "cgi/users/status:indexer_".$indexer_status ) ) );
	
	{
		my $dataset = $session->dataset( "event_queue" );
		my $n = $session->get_database->count_table( $dataset->get_sql_table_name );
		my $link = $session->render_link( "?screen=Listing&dataset=".$dataset->id );
		$link->appendChild( $session->html_phrase( "cgi/users/status:indexer_queue_size", size => $session->make_text( $n ) ) );
		$table->appendChild(
			$session->render_row( 
				$session->html_phrase( "cgi/users/status:indexer_queue" ),
				$link ) );
	}
	
	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:xml_version" ),
			$session->make_text( EPrints::XML::version() ) ) );
	
	$table = $session->make_element( "table", border=>"0" );
	$html->appendChild( $session->html_phrase( "cgi/users/status:usertitle" ) );
	$html->appendChild( $table );
	
	foreach my $usertype ( keys %num_users )
	{
		my $k = $session->make_doc_fragment;
		$k->appendChild( $session->render_type_name( "user", $usertype ) );
		$table->appendChild(
			$session->render_row( 
				$k, 
				$session->make_text( $num_users{$usertype} ) ) );
	}
	$table->appendChild(
		$session->render_row( 
			$session->html_phrase( "cgi/users/status:users" ),
			$session->make_text( $total_users ) ) );
	
	$table = $session->make_element( "table", border=>"0" );
	$html->appendChild( $session->html_phrase( "cgi/users/status:articles" ) );
	$html->appendChild( $table );
	
	foreach( @esets )
	{
		$table->appendChild(
			$session->render_row( 
				$session->html_phrase( "cgi/users/status:set_".$_ ),
				$session->make_text( $num_eprints{$_} ) ) );
	}
	
	
	unless( $EPrints::SystemSettings::conf->{disable_df} )
	{
		$table = $session->make_element( "table", border=>"0" );
		$html->appendChild( $session->html_phrase( "cgi/users/status:diskspace" ) );
		$html->appendChild( $table );
	
		my $best_size = 0;
	
		my @dirs = $session->get_repository->get_store_dirs();
		my $dir;
		foreach $dir ( @dirs )
		{
			my $size = $session->get_repository->get_store_dir_size( $dir );
			$table->appendChild(
				$session->render_row( 
					$session->html_phrase( 
						"cgi/users/status:diskfree",
						dir=>$session->make_text( $dir ) ),
					$session->html_phrase( 
						"cgi/users/status:mbfree",
						mb=>$session->make_text( 
							int($size/1024/1024) ) ) ) );
		
			$best_size = $size if( $size > $best_size );
		}
		
		if( $best_size < $session->config( 
						"diskspace_error_threshold" ) )
		{
			$p = $session->make_element( "p" );
			$html->appendChild( $p );
			$p->appendChild( 
				$session->html_phrase( 
					"cgi/users/status:out_of_space" ) );
		}
		elsif( $best_size < $session->config( 
							"diskspace_warn_threshold" ) )
		{
			$p = $session->make_element( "p" );
			$html->appendChild( $p );
			$p->appendChild( 
				$session->html_phrase( 
					"cgi/users/status:nearly_out_of_space" ) );
		}
	}
	
	
	$table = $session->make_element( "table", border=>"0" );
	$html->appendChild( $session->html_phrase( "cgi/users/status:saved_searches" ) );
	$html->appendChild( $table );
	
	$table->appendChild(
		$session->render_row( 
			undef,
			$session->html_phrase( "cgi/users/status:subcount" ),
			$session->html_phrase( "cgi/users/status:subsent" ) ) );
	foreach my $freq ( "never", "daily", "weekly", "monthly" )
	{
		my $sent;
		if( $freq ne "never" )
		{
			$sent = EPrints::DataObj::SavedSearch::get_last_timestamp( 
				$session, 
				$freq );
		}
		if( !defined $sent )
		{
			$sent = "?";
		}
		my $searchexp = new EPrints::Search(
			session => $session,
			dataset => $subds );
	
		$searchexp->add_field(
			$userds->get_field( "frequency" ),
			$freq );

		my $result = $searchexp->perform_search();
		my $n = $result->count;

		my $k = $session->make_doc_fragment;
		$k->appendChild( $session->html_phrase( "saved_search_fieldopt_frequency_".$freq ) );
		$table->appendChild(
			$session->render_row( 
				$k,
				$session->make_text( $n ),
				$session->make_text( $sent ) ) );
	}

	$self->{processor}->{title} = $session->html_phrase( "cgi/users/status:title" );

	return $html;
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

