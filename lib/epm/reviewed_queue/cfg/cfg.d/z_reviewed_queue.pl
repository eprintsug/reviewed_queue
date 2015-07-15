$c->{plugins}{"Screen::UBReviewed"}{params}{disable} = 0;

$c->{plugin_alias_map}->{"Screen::EPrint::Move"} = "Screen::EPrint::UBMove";
$c->{plugin_alias_map}->{"Screen::EPrint::UBMove"} = undef;

$c->{plugin_alias_map}->{"Screen::Items"} = "Screen::UBItems";
$c->{plugin_alias_map}->{"Screen::UBItems"} = undef;

$c->{plugin_alias_map}->{"Screen::Status"} = "Screen::UBStatus";
$c->{plugin_alias_map}->{"Screen::UBStatus"} = undef;

push @{$c->{user_roles}->{admin}}, "review-eprint";

$c->{roles}->{"review-eprint"} = [
	"eprint/buffer/move_reviewed:editor",
    "eprint/reviewed/move_archive:editor",
    "eprint/reviewed/rest/get:editor",
	"eprint/reviewed/rest/put:editor",
];

$c->{datasets}->{reviewed} = {
                sqlname => "eprint",
                virtual => 1,
                class => "EPrints::DataObj::EPrint",
                confid => "eprint",
                import => 1,
                index => 1,
                order => 1,
                filters => [ { meta_fields => [ 'eprint_status' ], value => 'reviewed', describe=>0 } ],
				dataset_id_field => "eprint_status",
                datestamp => "lastmod",
                columns => [qw( eprintid type status_changed userid eprint_status )], # default columns for Review screen
				};