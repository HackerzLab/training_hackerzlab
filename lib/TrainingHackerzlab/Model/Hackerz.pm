package TrainingHackerzlab::Model::Hackerz;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use TrainingHackerzlab::Model::Hackerz::Question;
use TrainingHackerzlab::Model::Hackerz::Answer;
use TrainingHackerzlab::Model::Hackerz::Hint;
use TrainingHackerzlab::Model::Hackerz::Ranking;

has question => sub {
    TrainingHackerzlab::Model::Hackerz::Question->new(
        +{ conf => shift->conf } );
};

has answer => sub {
    TrainingHackerzlab::Model::Hackerz::Answer->new(
        +{ conf => shift->conf } );
};

has hint => sub {
    TrainingHackerzlab::Model::Hackerz::Hint->new(
        +{ conf => shift->conf } );
};

has ranking => sub {
    TrainingHackerzlab::Model::Hackerz::Ranking->new(
        +{ conf => shift->conf } );
};

1;
