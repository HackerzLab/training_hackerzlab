use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use t::Util;

my $test_util = t::Util->new();
my $t         = $test_util->init;

subtest 'router' => sub {
    my $user_id = 1;
    $test_util->login( $t, $user_id );
    my $id           = 9999;
    my $collected_id = 9999;
    my $sort_id      = 9999;
    $t->get_ok("/hackerz/question/collected/$id")->status_is(200);
    $t->get_ok("/hackerz/question/collected/$collected_id/$sort_id/think")
        ->status_is(200);
    $test_util->logout($t);
};

# 各問題集をとく画面
subtest 'get /hackerz/question/collected/:id show' => sub {
    subtest 'template' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );
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
        $test_util->logout($t);
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

        # form(10) -> 問題文に対して入力フォームにテキスト入力で解答
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

            $test_util->login( $t, $user_id );

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
            $dom = $test_util->input_val_in_dom( $dom, $form, $val );
            my $params = $test_util->get_input_val( $dom, $form );

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

            $test_util->logout($t);
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };

        # choice(20) -> 問題文に対して答えを4択から選択して解答
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

            $test_util->login( $t, $user_id );

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
            $dom = $test_util->input_val_in_dom( $dom, $form, $val );
            my $params = $test_util->get_input_val( $dom, $form );

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

            $test_util->logout($t);
            $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };

        # survey(30) -> 調査するページから解答を導き出してテキスト入力で解答
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
            my $user_answer = $row->fetch_question->answer;
            my $question_id = $row->fetch_question->id;
            my $pattern     = $row->fetch_question->pattern;
            is( $pattern, 30, 'pattern' );

            $test_util->login( $t, $user_id );

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

            # 問題画面からクラッキングページリンク取得
            $t->get_ok($q_link_url)->status_is(200);
            my $c_link
                = "a[href=/hackerz/question/collected/$collected_id/$sort_id/survey/cracking]";
            $t->element_exists($c_link);
            my $c_link_url = $t->tx->res->dom->at($c_link)->attr('href');

            # クラッキングページに解答入力
            $t->get_ok($c_link_url)->status_is(200);

            # クラッキングページ入力フォーム

            # 問題ページへもどるのリンク
            $t->element_exists($q_link);

            # 問題画面から解答送信の値を作成

            # my $name   = 'form_answer';
            # my $action = '/hackerz/answer';
            # my $form   = "form[name=$name][method=POST][action=$action]";
            # $t->element_exists($form);
            # my $dom        = $t->tx->res->dom;
            # my $action_url = $dom->at($form)->attr('action');
            # my $val        = +{ user_answer => $user_answer, };
            # $dom = $test_util->input_val_in_dom( $dom, $form, $val );
            # my $params = $test_util->get_input_val( $dom, $form );
            # # 解答を送信から解答結果画面
            # $t->post_ok( $action_url => form => $params )->status_is(302);
            # my $location_url = $t->tx->res->headers->location;
            # $t->get_ok($location_url)->status_is(200);
            # $t->content_like(qr{\Qおまえの解答だ！\E});
            # $t->content_like(qr{\Q$user_answer\E});

            # # 解答結果画面から問題集リンク取得
            # $t->element_exists($link);
            # $link_url = $t->tx->res->dom->at($link)->attr('href');

            # # 問題集画面から解答結果の表示の確認
            # $t->get_ok($link_url)->status_is(200);
            # $t->content_like(qr{\Q正解\E});

            # # DB 確認
            # my @rows = $t->app->test_db->teng->single( 'answer', +{} );
            # is( scalar @rows, 1, 'count' );
            # my $row = shift @rows;
            # is( $row->question_id,  $question_id,  'question_id' );
            # is( $row->collected_id, $collected_id, 'collected_id' );
            # is( $row->user_id,      $user_id,      'user_id' );
            # is( $row->user_answer,  $user_answer,  'user_answer' );

            # $test_util->logout($t);
            # $t->app->commands->run( 'generatemore', 'sqlitedb' );
        };
    };
};

done_testing();
