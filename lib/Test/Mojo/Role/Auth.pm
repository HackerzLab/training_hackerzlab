package Test::Mojo::Role::Auth;
use Mojo::Base -role;
use Test::More;
use Mojo::Util qw{dumper};

# ログインする
sub login_ok {
    my $t       = shift;
    my $user_id = shift || 1;
    my $master  = $t->app->test_db->master;
    my $msg     = $master->auth->to_word('IS_LOGIN');

    my $submit_params = $t->_submit_params_login($user_id);

    my $action_url = $submit_params->{action_url};
    my $params     = $submit_params->{params};

    # ログイン実行
    $t->post_ok( $action_url => form => $params )->status_is(302);
    my $location_url = $t->tx->res->headers->location;
    $t->get_ok($location_url)->status_is(200);

    # 成功画面
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    ok( $session_id, 'session_id' );
    return $t;
}

# ログアウトする
sub logout_ok {
    my $t = shift;

    # ログアウトボタンの存在する画面
    $t->get_ok('/hackerz/menu')->status_is(200);
    my $dom        = $t->tx->res->dom;
    my $form       = 'form[name=form_logout]';
    my $action_url = $dom->at($form)->attr('action');
    my $master     = $t->app->test_db->master;

    # ログアウト実行
    $t->post_ok($action_url)->status_is(302);
    my $location_url = $t->tx->res->headers->location;
    $t->get_ok($location_url)->status_is(200);

    # 成功画面
    my $msg = $master->auth->to_word('IS_LOGOUT');
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # 他 button, link
    $t->element_exists("a[href=/]");
    $t->element_exists("a[href=/auth]");

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );
    return $t;
}

# ログインができない
sub not_login {
    my $t       = shift;
    my $user_id = shift || 1;
    my $master  = $t->app->test_db->master;
    my $msg     = $master->auth->to_word('NOT_LOGIN_ID');

    my $submit_params = $t->_submit_params_login($user_id);
    my $action_url    = $submit_params->{action_url};
    my $params        = $submit_params->{params};

    # ログイン実行 (ログインできない)
    $t->post_ok( $action_url => form => $params )->status_is(200);

    # ログイン失敗画面
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );
    return $t;
}

# ログイン入力実行する値を取得
sub _submit_params_login {
    my $t = shift;
    my $user_id = shift || 1;

    my $user = $t->app->test_db->teng->single( 'user', +{ id => $user_id } );
    my $login_id = $user->login_id;
    my $password = $user->password;

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );

    # ログイン画面
    $t->get_ok('/auth')->status_is(200);
    my $dom        = $t->tx->res->dom;
    my $form       = 'form[name=form_login]';
    my $action_url = $dom->at($form)->attr('action');

    # 値を入力
    $dom->at('input[name=login_id]')->attr( +{ value => $login_id } );
    $dom->at('input[name=password]')->attr( +{ value => $password } );

    # input val 取得
    my $params = $t->get_input_val( $dom, $form );
    return +{ action_url => $action_url, params => $params };
}

1;

__END__
