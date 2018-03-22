use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

my $t = Test::Mojo->with_roles('+Basic')->new('TrainingHackerzlab')->init;

sub _url_list {
    my $id = shift || '';
    return +{
        top   => "/",
        think => "/hackerz/question/$id/think",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{think} )->status_is(200);
    $t->ua->max_redirects(0);

    # ログイン時
    my $user_id = 1;
    $t->login_ok($user_id);
    $t->get_ok( $url->{think} )->status_is(200);
    $t->logout_ok();
};

# 各問題画面
subtest 'get - /hackerz/question/:id/think think' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

done_testing();
