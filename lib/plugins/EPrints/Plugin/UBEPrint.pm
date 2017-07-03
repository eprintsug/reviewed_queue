package EPrints::Plugin::UBEPrint;
use strict;
our @ISA = qw/ EPrints::Plugin /;

package EPrints::DataObj::EPrint;

BEGIN { delete $EPrints::DataObj::EPrint::{get_system_field_info}; }

sub get_system_field_info
{
	my( $class ) = @_;

	return ( 
	{ name=>"eprintid", type=>"counter", required=>1, import=>0, can_clone=>0,
		sql_counter=>"eprintid" },

	{ name=>"rev_number", type=>"int", required=>1, can_clone=>0,
		sql_index=>0, default_value=>0, volatile=>1 },

	{ name=>"documents", type=>"subobject", datasetid=>'document',
		multiple=>1, text_index=>1, dataobj_fieldname=>'eprintid' },

	{ name=>"files", type=>"subobject", datasetid=>"file",
		multiple=>1 },

	### Lizz added "reviewed" status to help manage the workflow of datasets which need to be completely unavailable until the publication is out
	{ name=>"eprint_status", type=>"set", required=>1,
		options=>[qw/ inbox buffer reviewed archive deletion /] },

	# UserID is not required, as some bulk importers
	# may not provide this info. maybe bulk importers should
	# set a userid of -1 or something.

	{ name=>"userid", type=>"itemref", 
		datasetid=>"user", required=>0 },

	{ name=>"importid", type=>"itemref", required=>0, datasetid=>"import" },

	{ name=>"source", type=>"text", required=>0, },

	{ name=>"dir", type=>"text", required=>0, can_clone=>0,
		text_index=>0, import=>0, show_in_fieldlist=>0 },

	{ name=>"datestamp", type=>"time", required=>0, import=>0,
		render_res=>"minute", render_style=>"short", can_clone=>0 },

	{ name=>"lastmod", type=>"timestamp", required=>0, import=>0,
		render_res=>"minute", render_style=>"short", can_clone=>0, volatile=>1 },

	{ name=>"status_changed", type=>"time", required=>0, import=>0,
		render_res=>"minute", render_style=>"short", can_clone=>0 },

	{ name=>"type", type=>"namedset", set_name=>"eprint", required=>1, 
		"input_style"=> "long" },

	{ name=>"succeeds", type=>"itemref", required=>0,
		datasetid=>"eprint", can_clone=>0 },

	{ name=>"commentary", type=>"itemref", required=>0,
		datasetid=>"eprint", can_clone=>0, sql_index=>0 },

	{ name=>"metadata_visibility", type=>"set", required=>1,
		default_value => "show",
		volatile => 1,
		options=>[ "show", "no_search", "hide" ] },

	{ name=>"contact_email", type=>"email", required=>0, can_clone=>0 },

	{ name=>"fileinfo", type=>"longtext", 
		text_index=>0,
		export_as_xml=>0,
		render_value=>"EPrints::DataObj::EPrint::render_fileinfo" },

	{ name=>"latitude", type=>"float", required=>0 },

	{ name=>"longitude", type=>"float", required=>0 },

	{ name=>"relation", type=>"compound", multiple=>1,
		fields => [
			{
				sub_name => "type",
				type => "text",
			},
			{
				sub_name => "uri",
				type => "text",
			},
		],
	},

	{ name=>"item_issues", type=>"compound", multiple=>1,
		fields => [
			{
				sub_name => "id",
				type => "id",
				text_index => 0,
			},
			{
				sub_name => "type",
				type => "id",
				text_index => 0,
				sql_index => 1,
			},
			{
				sub_name => "description",
				type => "longtext",
				text_index => 0,
				render_single_value => "EPrints::Extras::render_xhtml_field",
			},
			{
				sub_name => "timestamp",
				type => "time",
			},
			{
				sub_name => "status",
				type => "set",
				text_index => 0,
				options=> [qw/ discovered ignored reported autoresolved resolved /],
			},
			{
				sub_name => "reported_by",
				type => "itemref",
				datasetid => "user",
			},
			{
				sub_name => "resolved_by",
				type => "itemref",
				datasetid => "user",
			},
			{
				sub_name => "comment",
				type => "longtext",
				text_index => 0,
				render_single_value => "EPrints::Extras::render_xhtml_field",
			},
		],
		make_value_orderkey => "EPrints::DataObj::EPrint::order_issues_newest_open_timestamp",
		render_value=>"EPrints::DataObj::EPrint::render_issues",
		volatile => 1,
	},

	{ name=>"item_issues_count", type=>"int",  volatile=>1 },

	{ 'name' => 'sword_depositor', 'type' => 'itemref', datasetid=>"user" },

	{ 'name' => 'sword_slug', 'type' => 'text' },

	{ 'name' => 'edit_lock', 'type' => 'compound', volatile => 1, export_as_xml=>0,
		'fields' => [
			{ 'sub_name' => 'user',  'type' => 'itemref', 'datasetid' => 'user', sql_index=>0 },
			{ 'sub_name' => 'since', 'type' => 'int', sql_index=>0 },
			{ 'sub_name' => 'until', 'type' => 'int', sql_index=>0 },
		],
		render_value=>"EPrints::DataObj::EPrint::render_edit_lock",
 	},
	
	)
}

######################################################################
=pod

=item $success = $eprint->move_to_reviewed

Transfer the EPrint into the "reviewed" dataset. Should only be
called in eprints in the "buffer" dataset.

=cut
######################################################################
sub move_to_reviewed
{
        my( $self ) = @_;

        my $success = $self->_transfer( "reviewed" );

        if( $success )
        {
                # supported but deprecated. use eprint_status_change instead.
                if( $self->{session}->get_repository->can_call( "update_submitted_eprint" ) )
                {
                        $self->{session}->get_repository->call(
                                "update_submitted_eprint", $self );
                        $self->commit;
                }
        }

        return( $success );
}
