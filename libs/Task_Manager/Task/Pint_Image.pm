package Homyaki::Task_Manager::Task::Print_Image;

use strict;

use File::stat;

use Homyaki::Task_Manager::DB::Task;
use Homyaki::Task_Manager::DB::Constants;

use Homyaki::Gallery::Print;

use Homyaki::Logger;

use Image::Magick;
use DateTime;

use constant BASE_IMAGE_PATH  => '/home/alex/Share/Photo/';

sub start {
	my $class = shift;
	my %h = @_;
	
	my $params = $h{params};
	my $task   = $h{task};

	my $result = {};


	my $image = Homyaki::Gallery::Print->find_unprinted_image();

	if ($image) {
		my $error = print_image($image->{path}, $image->{resume});
		$result->{error} = $error if $error;

		my $current_date = DateTime->now();

		my $printed_image = Homyaki::Gallery::Print->find_or_create({
			image_id => $image->id
		});
		$printed_image->printed(1);
		$printed_image->print_date($current_date->ymd() . ' ' .  $current_date->hms());
		$printed_image->update();
	}	

	$result->{task} = {
		retry => {
			days => 7,
		},
		params => $params,
		
	};
 

	return $result;
}

sub print_image {
	my $path = shift;
	my $resume = shift;


	my $im = new Image::Magick;

	my $e = $im->Read($path);

	$im->Polaroid(
		fill => 'white',
		stroke => 'black',
		strokewidth => 3,
		gravity => 'center',
		pointsize => 78,
		caption => $resume
	);

	$e = $im->Trim();
	return $e if $e;

	$e = $im->Set(page=>'0x0+0+0'); # +repage
	return $e if $e;

	$e = $im->Write('/var/homyaki/gallery/print/print.png');
	return $e if $e;
	
	`lp -o fitplot /var/homyaki/gallery/print/print.png`;

	return 0;
}

#start();
1;

__END__


		my @task_types = Homyaki::Task_Manager::DB::Task_Type->search(
			handler => 'Homyaki::Task_Manager::Task::Print_Image'
		);

		if (scalar(@task_types) > 0) {

			my $task = Homyaki::Task_Manager->create_task(
				task_type_id => $task_types[0]->id(),
				params => {
				}
			);

		}
1;
