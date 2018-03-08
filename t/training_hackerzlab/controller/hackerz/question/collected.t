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

# - GET - `/hackerz/question/collected/:collected_id/:sort_id/think` - think - 問題集からの各問題画面
subtest 'get /hackerz/question/collected/:collected_id/:sort_id/think think' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'logic' => sub {

        # ログイン
        my $user_id = 1;
        $test_util->login( $t, $user_id );

        # 問題集選択
        # menu 画面にいる
        warn $t->tx->res->body;

        my $collected_id = 1;

        # 選択した問題集をリクエスト(全ての問題)
        my $menu_params =+{
            collected_id => $collected_id,
        };
        $t = _menu_for_collected($t, $menu_params,);

        # 問題選択
        warn $t->tx->res->body;

        # 1問目を
        # my $q_link = "a[href=/hackerz/question/collected/1/1/think]";
        # $t->element_exists($q_link);
        # my $q_link_url = $t->tx->res->dom->at($q_link)->attr('href');
        # $t->get_ok( $q_link_url )->status_is(200);

        # my $collected_id = 1;
        # my $sort_id      = 1;
        # my $cond         = +{
        #     collected_id => $collected_id,
        #     sort_id      => $sort_id,
        #     deleted      => 0
        # };
        # my $collected_sort_row
        #     = $t->app->test_db->teng->single( 'collected_sort', $cond );
        # my $user_answer = $collected_sort_row->fetch_question->answer;
        # my $question_id = $collected_sort_row->fetch_question->id;

        # # 問題を解く画面
        # $t->get_ok("/hackerz/question/collected/$collected_id/$sort_id/think")
        #     ->status_is(200);
        # my $name   = 'form_answer';
        # my $action = '/hackerz/answer';

        # # form
        # my $form = "form[name=$name][method=POST][action=$action]";
        # $t->element_exists($form);

        # my $dom        = $t->tx->res->dom;
        # my $action_url = $dom->at($form)->attr('action');

        # # 入力データーの元
        # my $msg_hash = +{ user_answer => $user_answer, };

        # # dom に 値を埋め込み
        # $dom = $test_util->input_val_in_dom( $dom, $form, $msg_hash );

        # # input val 取得
        # my $params = $test_util->get_input_val( $dom, $form );

        # # 解答を送信
        # $t->post_ok( $action_url => form => $params )->status_is(302);

        # # 解答を送信したぞ画面
        # my $location_url = $t->tx->res->headers->location;
        # $t->get_ok($location_url)->status_is(200);

        # warn $t->tx->res->body;

        # 入力結果

        # 問題一覧へもどる

        $test_util->logout($t);
        ok(1);
    };
};

# ログイン後のメニュー画面から問題集へ
sub _menu_for_collected {
    my $t            = shift;
    my $params       = shift;
    my $collected_id = $params->{collected_id};

    my $link = "a[href=/hackerz/question/collected/$collected_id]";
    $t->element_exists($link);
    my $link_url = $t->tx->res->dom->at($link)->attr('href');
    $t->get_ok($link_url)->status_is(200);
    return $t;
}

# 問題を解く画面
sub _show_question {
    my $t            = shift;
    my $params       = shift;
    my $collected_id = $params->{collected_id};
    my $sort_id      = $params->{sort_id};

    my $cond = +{
        collected_id => $collected_id,
        sort_id      => $sort_id,
        deleted      => 0
    };
    my $collected_sort_row = $t->app->test_db->teng->single('collected_sort', $cond);
    my $user_answer        = $collected_sort_row->fetch_question->answer;
    my $question_id        = $collected_sort_row->fetch_question->id;

    # 問題を解く画面
    $t->get_ok("/hackerz/question/collected/$collected_id/$sort_id/think")->status_is(200);
    return $t;
}

# 解答を入力する

done_testing();
