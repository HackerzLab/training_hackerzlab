use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use t::Util;

my $test_util = t::Util->new();
my $t         = $test_util->init;

subtest 'router' => sub {
    $t->ua->max_redirects(1);
    $t->post_ok( '/hackerz/hint/opened' )->status_is(200);
    $t->ua->max_redirects(0);
};

# ヒント開封履歴記録
subtest 'post /hackerz/hint/opened opened' => sub {

    # 例: /hackerz/question/collected/1/4/think
    # 各問題をとく画面を表示、ヒントと開封履歴の js 確認
    subtest 'template' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );
        my $collected_id = 1;
        my $sort_id = 1;
        my $url = "/hackerz/question/collected/$collected_id/$sort_id/think";
        $t->get_ok($url)->status_is(200);
        my $msg = q{$.post("/hackerz/hint/opened"};
        $t->content_like(qr{\Q$msg\E});
        $test_util->logout($t);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {

        # DB 確認
        my $row = $t->app->test_db->teng->single('hint_opened', +{});
        is($row, undef, 'count');

        # ヒントを開封を行う
        my $user_id = 1;
        $test_util->login( $t, $user_id );
        my $collected_id = 1;
        my $sort_id = 1;

        subtest 'create' => sub {
            my $cond = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0,
            };
            my $collected_sort_row = $t->app->test_db->teng->single('collected_sort', $cond);

            my $list      = $collected_sort_row->fetch_question_row_list($user_id);
            my $hint_rows = $list->{question_row}->search_hint;
            my $hint_row  = shift @{$hint_rows};
            my $hint_id   = $hint_row->id;
            my $params    = +{
                user_id      => $user_id,
                collected_id => $collected_id,
                hint_id      => $hint_id,
                opened       => 1,
            };
            $t->post_ok('/hackerz/hint/opened' => form => $params)->status_is(200);

            # DB 確認
            my @rows = $t->app->test_db->teng->search('hint_opened', +{});
            is(scalar @rows, 1, 'count');
            my $hint_opened_row = shift @rows;
            $t->json_is('/status'         => 200);
            $t->json_is('/hint_opened/id' => $hint_opened_row->id);
        };

        subtest 'error' => sub {
            my $cond = +{
                collected_id => $collected_id,
                sort_id      => $sort_id,
                deleted      => 0,
            };
            my $collected_sort_row = $t->app->test_db->teng->single('collected_sort', $cond);

            my $list      = $collected_sort_row->fetch_question_row_list($user_id);
            my $hint_rows = $list->{question_row}->search_hint;
            my $hint_row  = shift @{$hint_rows};
            my $hint_id   = $hint_row->id;

            # collected_id が 0 はみとめない
            my $params = +{
                user_id      => $user_id,
                collected_id => 0,
                hint_id      => $hint_id,
                opened       => 1,
            };
            $t->post_ok('/hackerz/hint/opened' => form => $params)->status_is(200);

            # DB 確認
            my @rows = $t->app->test_db->teng->search('hint_opened', +{});
            is(scalar @rows, 1, 'count');
            $t->json_is('/status' => 500);
            $t->json_is('/hint_opened/id' => undef);
        };
        $test_util->logout($t);
    };
    ok(1);
};

ok(1);

done_testing();
