package Test::Mojo::Role::Basic;
use Mojo::Base -role;
use Test::More;
use Mojo::Util qw{dumper};

sub init {
    my $self = shift;
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('TrainingHackerzlab');
    die 'not testing mode' if $t->app->mode ne 'testing';

    # test DB
    $t->app->commands->run('generate', 'sqlitedb');
    $t->app->helper(
        test_db => sub { TrainingHackerzlab::DB->new( +{ conf => $t->app->config } ) }
    );
    return $t;
}

1;
