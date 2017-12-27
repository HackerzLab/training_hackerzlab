package TrainingHackerzlab::Model;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use TrainingHackerzlab::Model::Auth;

has auth => sub {
    TrainingHackerzlab::Model::Auth->new( +{ conf => shift->conf } );
};

# add method
# use TrainingHackerzlab::Model::Example;
# has example => sub {
#     TrainingHackerzlab::Model::Example->new( +{ conf => shift->conf } );
# };

# add helper method
# package TrainingHackerzlab;
# use Mojo::Base 'Mojolicious';
# use TrainingHackerzlab::Model;
#
# sub startup {
#    my $self = shift;
#    ...
#    my $config = $self->config;
#    $self->helper(
#        model => sub { TrainingHackerzlab::Model->new( +{ conf => $config } ); } );
#    ...
# }

1;
