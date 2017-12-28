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
        my $url = _url_list();
        $t->get_ok( $url->{create} )->status_is(200);

        # form
        my $form = "form[name=form_store][method=post][action=$url->{store}]";
        $t->element_exists($form);

        # input text
        my $text_names = [qw{user_id username}];
        for my $name ( @{$text_names} ) {
            $t->element_exists("$form input[name=$name][type=text]");
        }

        # input password
        $t->element_exists("$form input[name=password][type=password]");

        # 他 button, link
        $t->element_exists("$form button[type=submit]");
        $t->element_exists("a[href=$url->{top}]");
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
        my $url = _url_list();
        $t->get_ok( $url->{index} )->status_is(200);

        # form
        my $form = "form[name=form_login][method=post][action=$url->{login}]";
        $t->element_exists($form);

        # input text
        my $text_names = [qw{login_id}];
        for my $name ( @{$text_names} ) {
            $t->element_exists("$form input[name=$name][type=text]");
        }

        # input password
        $t->element_exists("$form input[name=password][type=password]");

        # 他 button, link
        $t->element_exists("$form button[type=submit]");
        $t->element_exists("a[href=$url->{top}]");
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
        subtest 'not login id' => sub {
            my $login_id = 9999;
            my $password = 'dummy';
            my $master   = $t->app->test_db->master;
            my $msg      = $master->auth->word(
                $master->auth->constant('NOT_LOGIN_ID') );

            # セッション確認
            my $session_id
                = $t->app->build_controller( $t->tx )->session('user');
            is( $session_id, undef, 'session_id' );

            # ログイン画面
            my $url = _url_list();
            $t->get_ok( $url->{index} )->status_is(200);
            my $dom        = $t->tx->res->dom;
            my $form       = 'form[name=form_login]';
            my $action_url = $dom->at($form)->attr('action');

            # 値を入力
            $dom->at('input[name=login_id]')->attr( +{ value => $login_id } );
            $dom->at('input[name=password]')->attr( +{ value => $password } );

            # input val 取得
            my $params = $test_util->get_input_val( $dom, $form );

            # ログイン実行
            $t->post_ok( $action_url => form => $params )->status_is(200);

            # 失敗時の画面
            $t->content_like(qr{\Q<b>$msg</b>\E});

            # セッション確認
            $session_id
                = $t->app->build_controller( $t->tx )->session('user');
            is( $session_id, undef, 'session_id' );
        };

        subtest 'not password' => sub {
            my $user = $t->app->test_db->teng->single( 'user', +{ id => 1 } );
            my $login_id = $user->login_id;
            my $password = 'dummy';
            my $master   = $t->app->test_db->master;
            my $msg      = $master->auth->word(
                $master->auth->constant('NOT_PASSWORD') );

            # セッション確認
            my $session_id
                = $t->app->build_controller( $t->tx )->session('user');
            is( $session_id, undef, 'session_id' );

            # ログイン画面
            my $url = _url_list();
            $t->get_ok( $url->{index} )->status_is(200);
            my $dom        = $t->tx->res->dom;
            my $form       = 'form[name=form_login]';
            my $action_url = $dom->at($form)->attr('action');

            # 値を入力
            $dom->at('input[name=login_id]')->attr( +{ value => $login_id } );
            $dom->at('input[name=password]')->attr( +{ value => $password } );

            # input val 取得
            my $params = $test_util->get_input_val( $dom, $form );

            # ログイン実行
            $t->post_ok( $action_url => form => $params )->status_is(200);

            # 失敗時の画面
            $t->content_like(qr{\Q<b>$msg</b>\E});

            # セッション確認
            $session_id
                = $t->app->build_controller( $t->tx )->session('user');
            is( $session_id, undef, 'session_id' );
        };
    };
    subtest 'success' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );

        # セッション確認 (切断)
        $t->reset_session;
        my $session_id = $t->app->build_controller( $t->tx )->session('user');
        is( $session_id, undef, 'session_id' );
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

        # ログイン実行
        my $user_id = 1;
        $test_util->login( $t, $user_id );

        # ログアウト実行
        $test_util->logout($t);
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
