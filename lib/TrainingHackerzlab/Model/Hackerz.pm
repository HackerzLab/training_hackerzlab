package TrainingHackerzlab::Model::Hackerz;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use TrainingHackerzlab::Model::Hackerz::Question;

has question => sub {
    TrainingHackerzlab::Model::Hackerz::Question->new(
        +{ conf => shift->conf } );
};

1;
