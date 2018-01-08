package TrainingHackerzlab::Model::Hackerz;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use TrainingHackerzlab::Model::Hackerz::Question;
use TrainingHackerzlab::Model::Hackerz::Answer;

has question => sub {
    TrainingHackerzlab::Model::Hackerz::Question->new(
        +{ conf => shift->conf } );
};

has answer => sub {
    TrainingHackerzlab::Model::Hackerz::Answer->new(
        +{ conf => shift->conf } );
};

1;
