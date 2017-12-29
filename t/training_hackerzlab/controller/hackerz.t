use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use t::Util;

my $test_util = t::Util->new();
my $t         = $test_util->init;

sub _url_list {
    my $id = shift || '';
    return +{
        top         => "/",
        index       => "/hackerz",
        auth_create => "/auth/create",
        auth_index  => "/auth",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{index} )->status_is(200);
    $t->ua->max_redirects(0);
};

# トップページ画面 (ログインなし)
subtest 'get /hackerz index' => sub {
    subtest 'template' => sub {
        my $url = _url_list();
        $t->get_ok( $url->{index} )->status_is(200);

        # 他 button, link
        $t->element_exists("a[href=$url->{auth_create}]");
        $t->element_exists("a[href=$url->{auth_index}]");
        $t->element_exists("a[href=$url->{top}]");

        subtest 'not show logget in' => sub {
            my $user_id = 1;
            $test_util->login( $t, $user_id );
            my $url = _url_list();
            $t->get_ok( $url->{index} )->status_is(302);
            my $location_url = $t->tx->res->headers->location;

            # ログイン中はアプリメニューへ強制遷移
            is( $location_url, '/hackerz/menu', 'logged in' );
            $t->get_ok($location_url)->status_is(200);
            $t->element_exists_not("a[href=$url->{auth_create}]");
            $t->element_exists_not("a[href=$url->{auth_index}]");
            $test_util->logout($t);
        };
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

done_testing();
