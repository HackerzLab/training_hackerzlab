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

# - POST - `/exakids/entry` - entry 解答者のエントリー実行
subtest 'GET - `/exakids/entry` - entry' => sub {

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

};

# エクサidでログイン時の問題解答にはかかった時間が記録される
subtest 'q exa id' => sub {

    # exa id でログイン
    my $exa_ids = $t->app->config->{exa_ids};
    my $user_id = $exa_ids->[0];
    $t->login_ok($user_id);

    # 問題の答え
    my $collected_id = 1;
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

    # 「登録してある全ての問題」を表示のリンク
    my $q_link = "a[href=$c_link]";
    $t->element_exists($q_link);

    # 問題集へ移動
    $t->get_ok($c_link)->status_is(200);

    # 問題「社長は誰」のリンク
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

done_testing();
