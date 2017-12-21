package TrainingHackerzlab::DB;
use Mojo::Base 'TrainingHackerzlab::DB::Base';
use TrainingHackerzlab::DB::Master;

has master => sub { TrainingHackerzlab::DB::Master->new(); };

1;
