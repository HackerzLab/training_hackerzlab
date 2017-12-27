package t::Util;
use Mojo::Base -base;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use TrainingHackerzlab::DB;

sub init {
    my $self = shift;
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('TrainingHackerzlab');
    die 'not testing mode' if $t->app->mode ne 'testing';

    # test DB
    $t->app->commands->run('generatemore', 'sqlitedb');
    $t->app->helper(
        test_db => sub { TrainingHackerzlab::DB->new( +{ conf => $t->app->config } ) }
    );
    return $t;
}

1;
