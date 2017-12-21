package TrainingHackerzlab::Model::Base;
use Mojo::Base -base;
use TrainingHackerzlab::DB;

has [qw{conf req_params}];

has db => sub {
    TrainingHackerzlab::DB->new( +{ conf => shift->conf } );
};

1;
