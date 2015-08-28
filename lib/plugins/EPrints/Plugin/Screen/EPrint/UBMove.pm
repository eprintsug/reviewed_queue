=head1 NAME

EPrints::Plugin::Screen::EPrint::UBMove

=cut

package EPrints::Plugin::Screen::EPrint::UBMove;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Move' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	#	$self->{priv} = # no specific priv - one per action

	$self->{actions} = [qw/ move_inbox move_buffer move_archive move_deletion move_reviewed /];

	$self->{appears} = [
{ place => "eprint_actions", 	action => "move_inbox", 	position => 600, },
{ place => "eprint_editor_actions", 	action => "move_archive", 	position => 400, },
{ place => "eprint_editor_actions", 	action => "move_buffer", 	position => 500, },
{ place => "eprint_editor_actions",	action => "move_reviewed",	position => 600, },
{ place => "eprint_editor_actions", 	action => "move_deletion", 	position => 700, },
{ place => "eprint_actions_bar_buffer", action => "move_archive", position => 100, },
{ place => "eprint_actions_bar_buffer", action => "move_reviewed", position => 100, },
{ place => "eprint_actions_bar_reviewed", action => "move_archive", position => 100, },
{ place => "eprint_actions_bar_reviewed", action => "move_buffer", position => 100, },
{ place => "eprint_actions_bar_archive", action => "move_buffer", position => 100, },
{ place => "eprint_actions_bar_archive", action => "move_deletion", position => 100, },
{ place => "eprint_actions_bar_deletion", action => "move_archive", position => 100, },
{ place => "eprint_review_actions", action => "move_archive", position => 200, },
{ place => "eprint_review_actions", action => "move_reviewed", position => 400, },
{ place => "eprint_review_actions", action => "move_buffer", position => 600, },
	];
	$self->{action_icon} = { move_archive => "action_approve.png",
				 move_reviewed => "reviewed.png",
				 move_buffer => "revert.png", };

	return $self;
}

##### Experimental Lizz #####

sub allow_move_reviewed
{
        my( $self ) = @_;

        return 0 unless $self->could_obtain_eprint_lock;
        return $self->allow( "eprint/move_reviewed" );
}

sub action_move_reviewed
{
        my( $self ) = @_;

        my $ok = $self->{processor}->{eprint}->move_to_reviewed;

        $self->add_result_message( $ok );
}

##### End Experimental Lizz ####

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

