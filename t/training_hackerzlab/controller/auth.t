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
        create => "/auth/create",
        edit   => "/auth/$id/edit",
        show   => "/auth/$id",
        index  => "/auth",
        login  => "/auth/login",
        logout => "/auth/logout",
        update => "/auth/$id/update",
        remove => "/auth/$id/remove",
        store  => "/auth",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{create} )->status_is(200);
    $t->get_ok( $url->{edit} )->status_is(200);
    $t->get_ok( $url->{show} )->status_is(200);
    $t->get_ok( $url->{index} )->status_is(200);
    $t->post_ok( $url->{login} )->status_is(200);
    $t->post_ok( $url->{logout} )->status_is(200);
    $t->post_ok( $url->{update} )->status_is(200);
    $t->post_ok( $url->{remove} )->status_is(200);
    $t->post_ok( $url->{store} )->status_is(200);
    $t->ua->max_redirects(0);
};

# ユーザー登録画面
subtest 'get /auth/create create' => sub {
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

# ユーザーパスワード変更画面 (未実装)
subtest 'get /auth/:id/edit edit' => sub {
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

# ユーザー情報詳細 (未実装)
subtest 'get /auth/:id show' => sub {
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

# ログイン入力画面
subtest 'get /auth index' => sub {
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

# ユーザーログイン実行
subtest 'post /auth/login login' => sub {
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

# ユーザーログアウト実行
subtest 'post /auth/logout logout' => sub {
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

# ユーザーパスワード変更実行 (未実装)
subtest 'post /auth/:id/update update' => sub {
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

# ユーザー削除実行 (未実装)
subtest 'post /auth/:id/remove remove' => sub {
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

# ユーザー新規登録実行
subtest 'post /auth store' => sub {
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
