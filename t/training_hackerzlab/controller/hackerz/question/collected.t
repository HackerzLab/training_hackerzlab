use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

my $t = Test::Mojo->with_roles('+Basic')->new('TrainingHackerzlab')->init;

subtest 'router' => sub {
    my $user_id = 1;
    $t->login_ok($user_id);
    my $id           = 9999;
    my $collected_id = 9999;
    my $sort_id      = 9999;
    $t->get_ok("/hackerz/question/collected/$id")->status_is(200);
    $t->get_ok("/hackerz/question/collected/$collected_id/$sort_id/think")
        ->status_is(200);
    $t->logout_ok();
};

# 各問題集をとく画面
subtest 'get /hackerz/question/collected/:id show' => sub {
    subtest 'template' => sub {
        my $user_id = 1;
        $t->login_ok($user_id);
        my $cond = +{ deleted => 0 };
        my @rows = $t->app->test_db->teng->search( 'collected', $cond );
        for my $row (@rows) {
            my $id          = $row->id;
            my $title       = $row->title;
            my $description = $row->description;

            # 問題集をとくんだな
            $t->get_ok("/hackerz/question/collected/$id")->status_is(200);

            # 画面確認
            $t->content_like(qr{\Q$title\E});
            $t->content_like(qr{\Q$description\E});
        }
        $t->logout_ok();
    };
    subtest 'logic' => sub {
        ok(1);
    };
};

# 問題集からの各問題画面
# - GET - `/hackerz/question/collected/:collected_id/:sort_id/think` - think -
subtest 'get /:collected_id/:sort_id/think think' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'logic' => sub {

       # form(10) ->
       # 問題文に対して入力フォームにテキスト入力で解答
        subtest 'all q for pattern 10' => sub {

            # 初期値
            my $user_id      = 1;
            my $collected_id = 1;
            my $sort_id      = 1;
            my $cond         = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0
            };
            my $row
                = $t->app->test_db->teng->single( 'collected_sort', $cond );
            my $user_answer = $row->fetch_question->answer;
            my $question_id = $row->fetch_question->id;
            my $pattern     = $row->fetch_question->pattern;
            is( $pattern, 10, 'pattern' );

            $t->login_ok($user_id);

            # menu 画面から問題集リンク取得
            my $link = "a[href=/hackerz/question/collected/$collected_id]";
            $t->element_exists($link);
            my $link_url = $t->tx->res->dom->at($link)->attr('href');

            # 問題集画面から問題画面リンク取得
            $t->get_ok($link_url)->status_is(200);
            $t->content_unlike(qr{\Q正解\E});
            my $q_link
                = "a[href=/hackerz/question/collected/$collected_id/$sort_id/think]";
            $t->element_exists($q_link);
            my $q_link_url = $t->tx->res->dom->at($q_link)->attr('href');

            # 問題画面から解答送信の値を作成
            $t->get_ok($q_link_url)->status_is(200);
            my $name   = 'form_answer';
            my $action = '/hackerz/answer';
            my $form   = "form[name=$name][method=POST][action=$action]";
            $t->element_exists($form);
            my $dom        = $t->tx->res->dom;
            my $action_url = $dom->at($form)->attr('action');
            my $val        = +{ user_answer => $user_answer, };
            $dom = $t->input_val_in_dom( $dom, $form, $val );
            my $params = $t->get_input_val( $dom, $form );

            # バリデートを確認
            my $e_params = +{
                user_id      => $params->{user_id},
                sort_id      => $params->{sort_id},
                user_answer  => '',
                question_id  => $params->{question_id},
                collected_id => $params->{collected_id},
            };
            $t->post_ok( $action_url => form => $e_params )->status_is(200);
            $t->content_like(
                qr{\Q<b>解答が入力されていません</b>\E});

            # 解答未入力画面から問題集リンク存在確認
            $t->element_exists($link);

            # 解答を送信から解答結果画面
            $t->post_ok( $action_url => form => $params )->status_is(302);
            my $location_url = $t->tx->res->headers->location;
            $t->get_ok($location_url)->status_is(200);
            $t->content_like(qr{\Qおまえの解答だ！\E});
            $t->content_like(qr{\Q$user_answer\E});

            # 解答結果画面から問題集リンク取得
            $t->element_exists($link);
            $link_url = $t->tx->res->dom->at($link)->attr('href');

            # 問題集画面から解答結果の表示の確認
            $t->get_ok($link_url)->status_is(200);
            $t->content_like(qr{\Q正解\E});

            # DB 確認
            my @answer_rows = $t->app->test_db->teng->search( 'answer', +{} );
            is( scalar @answer_rows, 1, 'count' );
            my $answer_row = shift @answer_rows;
            is( $answer_row->question_id,  $question_id,  'question_id' );
            is( $answer_row->collected_id, $collected_id, 'collected_id' );
            is( $answer_row->user_id,      $user_id,      'user_id' );
            is( $answer_row->user_answer,  $user_answer,  'user_answer' );

            $t->logout_ok();
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };

        # choice(20) ->
        # 問題文に対して答えを4択から選択して解答
        subtest 'all q for pattern 20' => sub {

            # 初期値
            my $user_id      = 1;
            my $collected_id = 1;
            my $sort_id      = 2;
            my $cond         = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0
            };
            my $row
                = $t->app->test_db->teng->single( 'collected_sort', $cond );
            my $user_answer = $row->fetch_question->answer;
            my $question_id = $row->fetch_question->id;
            my $pattern     = $row->fetch_question->pattern;
            is( $pattern, 20, 'pattern' );

            $t->login_ok($user_id);

            # menu 画面から問題集リンク取得
            my $link = "a[href=/hackerz/question/collected/$collected_id]";
            $t->element_exists($link);
            my $link_url = $t->tx->res->dom->at($link)->attr('href');

            # 問題集画面から問題画面リンク取得
            $t->get_ok($link_url)->status_is(200);
            $t->content_unlike(qr{\Q正解\E});
            my $q_link
                = "a[href=/hackerz/question/collected/$collected_id/$sort_id/think]";
            $t->element_exists($q_link);
            my $q_link_url = $t->tx->res->dom->at($q_link)->attr('href');

            # 問題画面から解答送信の値を作成
            $t->get_ok($q_link_url)->status_is(200);
            my $name   = 'form_answer';
            my $action = '/hackerz/answer';
            my $form   = "form[name=$name][method=POST][action=$action]";
            $t->element_exists($form);
            my $dom        = $t->tx->res->dom;
            my $action_url = $dom->at($form)->attr('action');
            my $val        = +{ user_answer => $user_answer, };
            $dom = $t->input_val_in_dom( $dom, $form, $val );
            my $params = $t->get_input_val( $dom, $form );

            # 解答を送信から解答結果画面
            $t->post_ok( $action_url => form => $params )->status_is(302);
            my $location_url = $t->tx->res->headers->location;
            $t->get_ok($location_url)->status_is(200);
            $t->content_like(qr{\Qおまえの解答だ！\E});
            $t->content_like(qr{\Q$user_answer\E});

            # 解答結果画面から問題集リンク取得
            $t->element_exists($link);
            $link_url = $t->tx->res->dom->at($link)->attr('href');

            # 問題集画面から解答結果の表示の確認
            $t->get_ok($link_url)->status_is(200);
            $t->content_like(qr{\Q正解\E});

            # DB 確認
            my @answer_rows = $t->app->test_db->teng->search( 'answer', +{} );
            is( scalar @answer_rows, 1, 'count' );
            my $answer_row = shift @answer_rows;
            is( $answer_row->question_id,  $question_id,  'question_id' );
            is( $answer_row->collected_id, $collected_id, 'collected_id' );
            is( $answer_row->user_id,      $user_id,      'user_id' );
            is( $answer_row->user_answer,  $user_answer,  'user_answer' );

            $t->logout_ok();
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };

        # survey(30) ->
        # 調査するページから解答を導き出して
        subtest 'all q for pattern 30' => sub {

            # 初期値
            my $user_id      = 1;
            my $collected_id = 1;
            my $sort_id      = 3;
            my $cond         = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0
            };
            my $row
                = $t->app->test_db->teng->single( 'collected_sort', $cond );

            my $db_params = +{
                question_id  => $row->question_id,
                collected_id => $row->collected_id,
                user_id      => $user_id,
                user_answer  => $row->fetch_question->answer,
                sort_id      => $row->sort_id,
                pattern      => $row->fetch_question->pattern,
                s_action =>
                    "/hackerz/question/collected/$collected_id/$sort_id/survey/cracking",
            };
            is( $db_params->{pattern}, 30, 'pattern' );

            # 各画面のリンク
            my $link_base = '/hackerz/question/collected';
            my $link      = +{
                c => "a[href=$link_base/$collected_id]",
                q => "a[href=$link_base/$collected_id/$sort_id/think]",
                crack =>
                    "a[href=$link_base/$collected_id/$sort_id/survey/cracking]",
            };

            # ログイン後はアプリメニュー画面
            $t->login_ok($user_id);

            # menu > 問題集 > 問題 > クラッキングページ
            _menu_for_collected( $t, $link );
            _collected_for_question( $t, $link );
            _question_for_crack( $t, $link );

            # クラッキングページから値を作成
            my $crack_val = _crack_to_result( $t, $db_params );

            # クラッキングページ > 送信後 > 問題画面
            _post_for_crack( $t, $crack_val, $link );
            _crack_for_question( $t, $link );

            # 問題画面から解答送信の値を作成
            my $answer = _question_to_result( $t, $db_params );

            # 解答送信 > 解答結果 > 問題集
            _post_for_answer( $t, $answer, $db_params );
            _answer_for_question( $t, $link );

            # DB 確認
            _test_db( $t, $db_params );

            $t->logout_ok();
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };

        # survey(31) ->
        # 調査するページから解答を導き出して
        subtest 'all q for pattern 31' => sub {

            # 初期値
            my $user_id      = 1;
            my $collected_id = 1;
            my $sort_id      = 5;
            my $cond         = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0
            };
            my $row
                = $t->app->test_db->teng->single( 'collected_sort', $cond );

            my $db_params = +{
                question_id  => $row->question_id,
                collected_id => $row->collected_id,
                user_id      => $user_id,
                user_answer  => $row->fetch_question->answer,
                sort_id      => $row->sort_id,
                pattern      => $row->fetch_question->pattern,
                s_action =>
                    "/hackerz/question/collected/$collected_id/$sort_id/survey/cracking_from_list",
            };
            is( $db_params->{pattern}, 31, 'pattern' );

            # 各画面のリンク
            my $link_base = '/hackerz/question/collected';
            my $link      = +{
                c => "a[href=$link_base/$collected_id]",
                q => "a[href=$link_base/$collected_id/$sort_id/think]",
                crack =>
                    "a[href=$link_base/$collected_id/$sort_id/survey/cracking_from_list]",
            };

            # ログイン後はアプリメニュー画面
            $t->login_ok($user_id);

            # menu > 問題集 > 問題 > クラッキングページ
            _menu_for_collected( $t, $link );
            _collected_for_question( $t, $link );
            _question_for_crack( $t, $link );

            # クラッキングページから値を作成
            my $crack_val = _crack_to_result( $t, $db_params );

            # クラッキングページ > 送信後 > 問題画面
            _post_for_crack( $t, $crack_val, $link );
            _crack_for_question( $t, $link );

            # 問題画面から解答送信の値を作成
            my $answer = _question_to_result( $t, $db_params );

            # 解答送信 > 解答結果 > 問題集
            _post_for_answer( $t, $answer, $db_params );
            _answer_for_question( $t, $link );

            # DB 確認
            _test_db( $t, $db_params );

            $t->logout_ok();
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };
    };
};

# menu > 問題集
sub _menu_for_collected {
    my ( $t, $link ) = @_;
    $t->get_ok( $t->tx->res->dom->at( $link->{c} )->attr('href') );
    $t->status_is(200)->content_unlike(qr{\Q正解\E});
    return;
}

# 問題集 > 問題
sub _collected_for_question {
    my ( $t, $link ) = @_;
    $t->get_ok( $t->tx->res->dom->at( $link->{q} )->attr('href') );
    $t->status_is(200)->element_exists( $link->{c} );
    return;
}

# 問題 > クラッキングページ
sub _question_for_crack {
    my ( $t, $link ) = @_;
    $t->get_ok( $t->tx->res->dom->at( $link->{crack} )->attr('href') );
    $t->status_is(200)->element_exists( $link->{q} );
    return;
}

# クラッキングページから値を作成
sub _crack_to_result {
    my ( $t, $params ) = @_;
    my $cond = +{
        question_id => $params->{question_id},
        deleted     => 0
    };
    my $row    = $t->app->test_db->teng->single( 'survey', $cond );
    my $action = $params->{s_action};
    my $form   = "form[name=form_survey][method=POST][action=$action]";

    my $dom        = $t->tx->res->dom;
    my $action_url = $dom->at($form)->attr('action');
    my $val        = +{
        secret_id       => $row->secret_id,
        secret_password => $row->secret_password,
    };
    my $input_dom = $t->input_val_in_dom( $dom, $form, $val );

    # クラッキングの答えは問題の答え
    is( $params->{user_answer}, $row->secret_password, 'user_answer' );
    return +{
        action_url => $action_url,
        params     => $t->get_input_val( $input_dom, $form ),
        row        => $row,
    };
}

# クラッキングページ > 送信後
sub _post_for_crack {
    my ( $t, $crack_val, $link ) = @_;
    my $action_url = $crack_val->{action_url};
    my $params     = $crack_val->{params};
    $t->post_ok( $action_url => form => $params )->status_is(200);
    $t->content_like(qr{\Qやるじゃんクラック成功！！\E});
    $t->element_exists( $link->{q} );
    return;
}

# 送信後 > 問題画面
sub _crack_for_question {
    my ( $t, $link ) = @_;
    $t->get_ok( $t->tx->res->dom->at( $link->{q} )->attr('href') );
    $t->status_is(200)->element_exists( $link->{c} );
    return;
}

# 問題画面から解答送信の値を作成
sub _question_to_result {
    my ( $t, $db_params ) = @_;
    my $user_answer = $db_params->{user_answer};
    my $name        = 'form_answer';
    my $action      = '/hackerz/answer';
    my $form        = "form[name=$name][method=POST][action=$action]";

    my $dom        = $t->tx->res->dom;
    my $action_url = $dom->at($form)->attr('action');
    my $val        = +{ user_answer => $user_answer, };
    my $input_dom  = $t->input_val_in_dom( $dom, $form, $val );

    return +{
        action_url => $action_url,
        params     => $t->get_input_val( $input_dom, $form ),
    };
}

# 解答送信 > 解答結果画面
sub _post_for_answer {
    my ( $t, $val, $db_params ) = @_;
    my $user_answer = $db_params->{user_answer};
    $t->post_ok( $val->{action_url} => form => $val->{params} )
        ->status_is(302);
    $t->get_ok( $t->tx->res->headers->location )->status_is(200);
    $t->content_like(qr{\Qおまえの解答だ！\E});
    $t->content_like(qr{\Q$user_answer\E});
    return;
}

# 解答結果画面 > 問題集画面
sub _answer_for_question {
    my ( $t, $link ) = @_;
    $t->get_ok( $t->tx->res->dom->at( $link->{c} )->attr('href') );
    $t->status_is(200)->content_like(qr{\Q正解\E});
    return;
}

# DB 確認
sub _test_db {
    my ( $t, $params ) = @_;
    my @rows = $t->app->test_db->teng->single( 'answer', +{} );
    is( scalar @rows, 1, 'count' );
    my $row = shift @rows;
    is( $row->question_id,  $params->{question_id},  'question_id' );
    is( $row->collected_id, $params->{collected_id}, 'collected_id' );
    is( $row->user_id,      $params->{user_id},      'user_id' );
    is( $row->user_answer,  $params->{user_answer},  'user_answer' );
    return;
}

done_testing();
