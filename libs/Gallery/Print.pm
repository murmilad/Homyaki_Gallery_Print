package Homyaki::Gallery::Print;

use Homyaki::Gallery::Image;

use strict;
use base 'Homyaki::Gallery::DB';

__PACKAGE__->table('print');
__PACKAGE__->columns(Primary   => qw/image_id/);
__PACKAGE__->columns(Essential => qw/printed print_date/);

sub find_unprinted_image {
	my $class  = shift;

	my $sth = $class->execute_free_query(
		query => q{
			SELECT id
				FROM image
			WHERE id NOT IN (
				SELECT image_id
					FROM print
				WHERE printed = 1 
			) AND resume IS NOT NULL
			ORDER BY RAND() LIMIT 0,1
		},
	);

	my $image_id_array = $sth->fetchall_arrayref({});

	if ($image_id_array && scalar(@{$image_id_array}) > 0) {
		return Homyaki::Gallery::Image->retrieve($image_id_array->[0]->{id});
	} else {
		return 0;
	}
}

1;
