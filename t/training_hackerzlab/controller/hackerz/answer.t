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
        ok(1);
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
