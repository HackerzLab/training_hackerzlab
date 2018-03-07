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

done_testing();
