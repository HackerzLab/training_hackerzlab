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
        top    => "/",
        index  => "/hackerz/menu",
        logout => "/auth/logout",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{index} )->status_is(200);
    $t->ua->max_redirects(0);
};

# トップページ画面 (ログイン中)
subtest 'get /hackerz/menu index' => sub {
    subtest 'template' => sub {
        my $url = _url_list();
        $t->get_ok( $url->{index} )->status_is(200);

        # form
        my $form
            = "form[name=form_logout][method=post][action=$url->{logout}]";
        $t->element_exists($form);

        # 他 button, link
        $t->element_exists("$form button[type=submit]");
        # $t->element_exists("a[href=$url->{auth_index}]");
        # $t->element_exists("a[href=$url->{top}]");
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
