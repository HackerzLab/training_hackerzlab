use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

my $t = Test::Mojo->with_roles('+Basic')->new('TrainingHackerzlab')->init;

# - GET - `/exakids` - index - エントリー画面
subtest 'GET - `/exakids` - index' => sub {

    # ログインまえのトップ画面
    $t->get_ok('/')->status_is(200);

    # エントリーのリンク
    my $link = "/exakids";

    # 「登録してある全ての問題」を表示のリンク
    my $e_link = "a[href=$link]";
    $t->element_exists($e_link);

    # exakids エントリー画面
    $t->get_ok($link)->status_is(200);

    # エントリーへのフォーム確認
    my $name   = 'form_entry';
    my $action = "/exakids/entry";
    my $form   = "form[name=$name][method=POST][action=$action]";
    $t->element_exists($form);
    $t->element_exists("$form select[name=user_id]");
    $t->element_exists("$form input[name=name]");
    $t->element_exists("$form input[name=password]");
    $t->element_exists("$form button[type=submit]");
};

# - GET - `/exakids/:user_id/edit` - edit - 解答者のエントリー情報更新画面
subtest 'GET - `/exakids/:user_id/edit` - edit' => sub {
    my $master = $t->app->test_db->master;
    my $msg    = $master->auth->to_word('DONE_ENTRY');

    # exakids id でのログイン者のみ、みれる
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];

    # ログインしていないとみれない
    $t->get_ok("/exakids/$user_id/edit")->status_is(302);

    # exakids id でのログイン者のみ、みれる
    $t->login_ok($user_id);
    $t->get_ok("/exakids/$user_id/edit")->status_is(200);

    # エントリーへのフォーム確認
    my $name   = 'form_update';
    my $action = "/exakids/$user_id/update";
    my $form   = "form[name=$name][method=POST][action=$action]";
    $t->element_exists($form);
    $t->element_exists("$form input[name=login_id]");
    $t->element_exists("$form input[name=name]");
    $t->element_exists("$form input[name=password]");
    $t->element_exists("$form button[type=submit]");

    my $user_row
        = $t->app->test_db->teng->single( 'user', +{ id => $user_id } );
    my $dom        = $t->tx->res->dom;
    my $action_url = $dom->at($form)->attr('action');

    # 入力データーの元
    my $update_hash = +{
        login_id => $user_row->login_id,
        password => $user_row->password,
        name     => 'テスト変更ユーザー',
    };

    # dom に 値を埋め込み
    $dom = $t->input_val_in_dom( $dom, $form, $update_hash );

    # input val 取得
    my $params = $t->get_input_val( $dom, $form );
    $t->post_ok( $action_url => form => $params )->status_is(302);
    my $location_url = $t->tx->res->headers->location;

    # エクサキッズ用のメニュー画面へ
    $t->get_ok($location_url)->status_is(200);
    $t->content_like(qr{\Q<b>$msg</b>\E});
    my $row
        = $t->app->test_db->teng->single( 'user', +{ id => $user_row->id } );
    ok( $row, 'user row' );
    is( $row->name, $update_hash->{name}, 'name' );
    $t->logout_ok();
};

# - POST - `/exakids/entry` - entry 解答者のエントリー実行
subtest 'POST - `/exakids/entry` - entry' => sub {

    my $master  = $t->app->test_db->master;
    my $msg     = $master->auth->to_word('IS_LOGIN');
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];
    my $user_row
        = $t->app->test_db->teng->single( 'user', +{ id => $user_id } );

    # exakids エントリー画面
    $t->get_ok('/exakids')->status_is(200);
    my $form = "form[name=form_entry][method=POST][action=/exakids/entry]";
    my $dom  = $t->tx->res->dom;
    my $action_url = $dom->at($form)->attr('action');

    # 入力データーの元
    my $entry_hash = +{
        user_id  => $user_row->id,
        password => $user_row->password,
        name     => 'テストユーザー',
    };

    # dom に 値を埋め込み
    $dom = $t->input_val_in_dom( $dom, $form, $entry_hash );

    # input val 取得
    my $params = $t->get_input_val( $dom, $form );

    # エントリーを送信
    $t->post_ok( $action_url => form => $params )->status_is(302);
    my $location_url = $t->tx->res->headers->location;

    # エクサキッズ用のメニュー画面へ
    $t->get_ok($location_url)->status_is(200);
    $t->content_like(qr{\Q<b>$msg</b>\E});

    # ログイン状態を確認する
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    ok( $session_id, 'session_id' );

    # 名前も登録されている
    my $row
        = $t->app->test_db->teng->single( 'user', +{ id => $user_row->id } );
    ok( $row, 'user row' );
    is( $row->name, $entry_hash->{name}, 'name' );
    $t->logout_ok();
};

# - GET - `/exakids/menu` - menu - メニュー
subtest 'GET - `/exakids/menu` - menu' => sub {

    # ログインしていないとみれない
    $t->get_ok('/exakids/menu')->status_is(302);

    # exakids id でのログイン者のみ、みれる
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];
    $t->login_ok($user_id);
    $t->get_ok('/exakids/menu')->status_is(200);
    my $logout_form
        = "form[name=form_logout][method=post][action=/auth/logout]";
    $t->element_exists("$logout_form button[type=submit]");
    $t->element_exists("a[href=/exakids/menu]");
    $t->element_exists("a[href=/hackerz/menu]");
    $t->element_exists("a[href=/exakids/ranking]");
    $t->element_exists("a[href=/exakids/$user_id/edit]");
    $t->logout_ok();
};

# - GET - `/exakids/ranking` - ranking - 解答者ランキング一覧
subtest 'GET - `/exakids/ranking` - ranking' => sub {

    # ログインしていないとみれない
    $t->get_ok('/exakids/ranking')->status_is(302);

    # exakids id でのログイン者のみ、みれる
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];
    $t->login_ok($user_id);
    $t->get_ok('/exakids/ranking')->status_is(200);
    $t->logout_ok();
};

# - POST - `/exakids/refresh` - refresh - 解答状況を初期状態にもどす
subtest 'POST - `/exakids/refresh` - refresh' => sub {

    # データベースのデータが違うのでデータの検証はなし
    # リフレッシュボタンがみれるのは閲覧者IDのみ
    my $exa_ids_browse = $t->app->config->{exa_ids_browse};
    my $user_id        = $exa_ids_browse->[0];
    $t->login_ok($user_id);
    $t->get_ok('/exakids/menu')->status_is(200);

    # リフレッシュボタンのリンク
    my $refresh_form
        = "form[name=form_refresh][method=post][action=/exakids/refresh]";
    $t->element_exists("$refresh_form button[type=submit]");
    my $dom        = $t->tx->res->dom;
    my $action_url = $dom->at($refresh_form)->attr('action');

    # リフレッシュ実行
    $t->post_ok($action_url)->status_is(302);
    my $location_url = $t->tx->res->headers->location;

    # データ初期化されて、ログアウト状態、トップ画面へ
    $t->get_ok($location_url)->status_is(200);

    # セッション確認
    my $session_id = $t->app->build_controller( $t->tx )->session('user');
    is( $session_id, undef, 'session_id' );
};

# エクサidでログイン時の問題解答にはかかった時間が記録される
subtest 'q exa id' => sub {

    # exa id でログイン
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];
    $t->login_ok($user_id);

    # 指定の問題集が表示
    my $exa_collected_ids = $t->app->config->{exa_collected_ids};

    # 問題の答え
    my $collected_id = $exa_collected_ids->[0];
    my $sort_id      = 2;
    my $cond         = +{
        collected_id => $collected_id,
        sort_id      => $sort_id,
        deleted      => 0
    };

    # 今の画面
    $t->element_exists( 'html head title', 'HackerzLab.博多' );

    # 問題集のリンク
    my $c_link = "/hackerz/question/collected/$collected_id";
    my $q_link = "a[href=$c_link]";
    $t->element_exists($q_link);

    # 問題集へ移動
    $t->get_ok($c_link)->status_is(200);
    my $think_link
        = "/hackerz/question/collected/$collected_id/$sort_id/think";
    my $q2_link = "a[href=$think_link]";
    $t->element_exists($q2_link);

    # 問題を解く画面
    $t->get_ok($think_link)->status_is(200);

    # 制限時間のタイマー出現
    $t->element_exists("div[id=exatimer]");

    # js で動的に時間がかわるので、固定で値を作り込み
    my $name   = 'form_answer';
    my $action = '/hackerz/answer';

    # form
    my $form = "form[name=$name][method=POST][action=$action]";
    $t->element_exists($form);

    my $dom        = $t->tx->res->dom;
    my $action_url = $dom->at($form)->attr('action');

    my $collected_sort_row
        = $t->app->test_db->teng->single( 'collected_sort', $cond );
    my $user_answer = $collected_sort_row->fetch_question->answer;
    my $question_id = $collected_sort_row->fetch_question->id;

    # 入力データーの元
    my $msg_hash = +{ user_answer => $user_answer, };

    # dom に 値を埋め込み
    $dom = $t->input_val_in_dom( $dom, $form, $msg_hash );

    # input val 取得
    my $params = $t->get_input_val( $dom, $form );

    # タイマーの時間を手動で埋め込み
    $params = +{ %{$params}, remaining_sec => 18, };

    # 解答を送信
    $t->post_ok( $action_url => form => $params )->status_is(302);

    # 解答を送信したぞ画面
    my $location_url = $t->tx->res->headers->location;
    $t->get_ok($location_url)->status_is(200);
    $t->content_like(qr{\Qおまえの解答だ！\E});
    $t->content_like(qr{\Q$user_answer\E});

    # db 確認
    my @rows = $t->app->test_db->teng->single( 'answer', +{} );
    is( scalar @rows, 1, 'count' );
    my $row = shift @rows;
    is( $row->question_id,  $question_id,  'question_id' );
    is( $row->collected_id, $collected_id, 'collected_id' );
    is( $row->user_id,      $user_id,      'user_id' );
    is( $row->user_answer,  $user_answer,  'user_answer' );

    # 残り時間取得
    my @answer_time_rows
        = $t->app->test_db->teng->single( 'answer_time', +{} );
    is( scalar @answer_time_rows, 1, 'count' );
    my $time_row = shift @answer_time_rows;
    is( $time_row->answer_id,     $row->id, 'answer_id' );
    is( $time_row->remaining_sec, 18,       'remaining_sec' );
    $t->logout_ok();
};

# 問題解答、早押し正解者のみ得点クイズ形式
subtest 'q exa id sp' => sub {
    $t->app->commands->run( 'generate', 'sqlitedb' );

    # exa id 早押しでログイン (閲覧者)
    subtest 'browse' => sub {
        my $exa_ids_browsesp = $t->app->config->{exa_ids_browsesp};
        my $user_id          = $exa_ids_browsesp->[0];
        $t->login_ok($user_id);

        # 指定の問題集が表示
        my $exa_collected_ids = $t->app->config->{exa_collected_ids};

        # 問題の答え
        my $collected_id = $exa_collected_ids->[0];
        my $sort_id      = 2;
        my $cond         = +{
            collected_id => $collected_id,
            sort_id      => $sort_id,
            deleted      => 0
        };

        # 今の画面
        $t->element_exists( 'html head title', 'HackerzLab.博多' );

        # 問題集のリンク
        my $c_link = "/hackerz/question/collected/$collected_id";
        my $q_link = "a[href=$c_link]";
        $t->element_exists($q_link);

        # 問題集へ移動
        $t->get_ok($c_link)->status_is(200);
        my $think_link
            = "/hackerz/question/collected/$collected_id/$sort_id/think";
        my $q2_link = "a[href=$think_link]";
        $t->element_exists($q2_link);

        # 問題を解く画面
        $t->get_ok($think_link)->status_is(200);

        # 問題をオープンするボタンが出現
        my $name   = 'form_opened';
        my $action = "/hackerz/question/opened";
        my $form   = "form[name=$name][method=POST][action=$action]";
        $t->element_exists($form);
        $t->element_exists("$form input[name=user_id]");
        $t->element_exists("$form input[name=question_id]");
        $t->element_exists("$form input[name=collected_id]");
        $t->element_exists("$form input[name=opened]");
        $t->element_exists("$form button[type=submit]");

        # オープン実行後、問題と開封時間出現
        my $dom        = $t->tx->res->dom;
        my $action_url = $dom->at($form)->attr('action');

        # input val 取得
        my $params = $t->get_input_val( $dom, $form );
        $t->post_ok( $action_url => form => $params )->status_is(302);
        my $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);

        # もう一度オープンしてもオープンボタンはない
        $t->element_exists_not($form);
        $t->element_exists_not("$form input[name=user_id]");
        $t->element_exists_not("$form input[name=question_id]");
        $t->element_exists_not("$form input[name=collected_id]");
        $t->element_exists_not("$form input[name=opened]");
        $t->element_exists_not("$form button[type=submit]");
        $t->logout_ok();
    };

    # exa id 早押しでログイン (解答者)
    subtest 'entry' => sub {
        my $exa_ids_entrysp = $t->app->config->{exa_ids_entrysp};
        my $user_id         = $exa_ids_entrysp->[0];
        $t->login_ok($user_id);

        # 指定の問題集が表示
        my $exa_collected_ids = $t->app->config->{exa_collected_ids};

        # 問題の答え
        my $collected_id = $exa_collected_ids->[0];
        my $sort_id      = 2;
        my $cond         = +{
            collected_id => $collected_id,
            sort_id      => $sort_id,
            deleted      => 0
        };

        # 今の画面
        $t->element_exists( 'html head title', 'HackerzLab.博多' );

        # 問題集のリンク
        my $c_link = "/hackerz/question/collected/$collected_id";
        my $q_link = "a[href=$c_link]";
        $t->element_exists($q_link);

        # 問題集へ移動
        $t->get_ok($c_link)->status_is(200);

        my $think_link
            = "/hackerz/question/collected/$collected_id/$sort_id/think";
        my $q2_link = "a[href=$think_link]";
        $t->element_exists($q2_link);

        # 問題を解く画面
        $t->get_ok($think_link)->status_is(200);

        # 問題入力フォームが出現
        my $name   = 'form_answer';
        my $action = "/hackerz/answer";
        my $form   = "form[name=$name][method=POST][action=$action]";
        $t->element_exists($form);
        $t->element_exists("$form input[name=user_id]");
        $t->element_exists("$form input[name=question_id]");
        $t->element_exists("$form input[name=collected_id]");
        $t->element_exists("$form input[name=user_answer]");
        $t->element_exists("$form button[type=submit]");

        my $dom        = $t->tx->res->dom;
        my $action_url = $dom->at($form)->attr('action');

        my $collected_sort_row
            = $t->app->test_db->teng->single( 'collected_sort', $cond );
        my $user_answer = $collected_sort_row->fetch_question->answer;
        my $question_id = $collected_sort_row->fetch_question->id;

        # 入力データーの元
        my $msg_hash = +{ user_answer => $user_answer, };

        # dom に 値を埋め込み
        $dom = $t->input_val_in_dom( $dom, $form, $msg_hash );

        # input val 取得
        my $params = $t->get_input_val( $dom, $form );
        $t->post_ok( $action_url => form => $params )->status_is(302);
        my $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);

        # 入力時間
        my @answer_time_rows
            = $t->app->test_db->teng->single( 'answer_time', +{} );
        is( scalar @answer_time_rows, 1, 'count' );
        my $time_row = shift @answer_time_rows;
        ok( $time_row->entered_ts, 'entered_ts' );

        $t->logout_ok();

        # 閲覧権限、問題画面に解答状況が表示されている
    };
};

done_testing();
