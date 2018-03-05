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
    my $id = 9999;
    $t->get_ok( "/hackerz/answer/report" )->status_is(200);
    $t->get_ok( "/hackerz/answer/$id/result" )->status_is(200);
    $t->post_ok( "/hackerz/answer" )->status_is(200);
    $test_util->logout($t);
};

# 成績一覧画面
subtest 'get /hackerz/answer/report report' => sub {
    subtest 'template' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );
        $t->get_ok( "/hackerz/answer/report" )->status_is(200);

        # 問題集のタイトル表示、クリックすると解答履歴
        my $cond = +{ deleted => 0 };
        my @collected_rows
            = $t->app->test_db->teng->search( 'collected', $cond );
        for my $row (@collected_rows) {
            my $title   = $row->title;
            my $element = "[id=myModalLabel" . $row->id . "]";
            $t->element_exists($element);
            $t->text_is($element, $title);
        }
        $test_util->logout($t);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

# 解答を送信したぞ画面
subtest 'get /hackerz/answer/:id/result result' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );

        # 問題の答え
        my $collected_id = 1;
        my $sort_id      = 1;
        my $cond = +{collected_id => $collected_id, sort_id => $sort_id, deleted => 0};
        my $collected_sort_row = $t->app->test_db->teng->single('collected_sort', $cond);
        my $user_answer = $collected_sort_row->fetch_question->answer;
        my $question_id = $collected_sort_row->fetch_question->id;

        # 問題を解く画面
        $t->get_ok( "/hackerz/question/collected/$collected_id/$sort_id/think" )->status_is(200);
        my $name   = 'form_answer';
        my $action = '/hackerz/answer';

        # form
        my $form = "form[name=$name][method=POST][action=$action]";
        $t->element_exists($form);

        my $dom        = $t->tx->res->dom;
        my $action_url = $dom->at($form)->attr('action');

        # 入力データーの元
        my $msg_hash = +{ user_answer => $user_answer, };

        # dom に 値を埋め込み
        $dom = $test_util->input_val_in_dom( $dom, $form, $msg_hash );

        # input val 取得
        my $params = $test_util->get_input_val( $dom, $form );

        # 解答を送信
        $t->post_ok( $action_url => form => $params )->status_is(302);

        # 解答を送信したぞ画面
        my $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);
        $t->content_like(qr{\Qおまえの解答だ！\E});
        $t->content_like(qr{\Q$user_answer\E});

        # db 確認
        my @rows = $t->app->test_db->teng->single('answer', +{});
        is(scalar @rows, 1, 'count');
        my $row = shift @rows;
        is($row->question_id,  $question_id,  'question_id');
        is($row->collected_id, $collected_id, 'collected_id');
        is($row->user_id,      $user_id,      'user_id');
        is($row->user_answer,  $user_answer,  'user_answer');
        $test_util->logout($t);
    };
};

# 解答内容送信
subtest 'post /hackerz/answer store' => sub {
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
