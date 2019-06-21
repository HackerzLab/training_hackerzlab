package TrainingHackerzlab::Model::Hackerz::Answer;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};
has [qw{error_msg}] => undef;

# 簡易的なバリデート
sub has_error_easy {
    my $self   = shift;
    my $params = $self->req_params;
    my $master = $self->db->master;
    $self->error_msg( $master->answer->to_word('NOT_INPUT') );
    return 1 if !$params->{user_id};
    return 1 if !$params->{user_answer};
    return 1 if !$params->{question_id};
    return 1 if !$params->{collected_id};

    # 二重登録防止
    my $cond = +{
        user_id      => $params->{user_id},
        question_id  => $params->{question_id},
        collected_id => $params->{collected_id},
        deleted      => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $answer = $self->db->teng->single( 'answer', $cond );
    $self->error_msg( $master->answer->to_word('EXISTS_ANSWER') );
    return 1 if $answer;
    $self->error_msg(undef);
    return;
}

# 解答結果点数
# +{  question_list             => [],
#     question_list_total_score => 0,
#     collected_list            => [
#         +{  collected     => +{},
#             total_score   => 0,
#             question_list => [
#                 +{  collected_sort => +{},
#                     question       => +{},
#                     answer         => +{},
#                     q_url          => '',
#                     how            => '',
#                     how_text       => '',
#                     sort_id           => '',
#                     collected_id      => '',
#                     short_question    => '',
#                     hint_opened_level => [],
#                     get_score         => 0,
#                 },
#             ],
#         },
#         +{},
#     ],
# };
sub to_template_report {
    my $self  = shift;
    my $score = +{
        question_list             => undef,
        question_list_total_score => 0,
        collected_list            => undef,
    };

    my $user_id = $self->req_params->{user_id};

    my $cond = +{
        id      => $user_id,
        deleted => 0,
    };
    my $user_row = $self->db->teng->single( 'user', $cond );
    return $score if !$user_row;

    # 全ての問題をとくの得点状況
    my $question_rows_list = $user_row->fetch_question_rows_list();

    # 問題関連データ一式に整形
    my $question_list;
    for my $data_row ( @{$question_rows_list} ) {
        push @{$question_list}, $self->question_data_hash_all($data_row);
    }

    # 獲得点数の計算
    my $question_list_total_score = 0;
    for my $question_data ( @{$question_list} ) {
        $question_list_total_score += $question_data->{get_score};
    }

    $score->{question_list}             = $question_list;
    $score->{question_list_total_score} = $question_list_total_score;

    # 関連情報一式取得
    my $collected_rows_list = $user_row->fetch_collected_rows_list();

    # 問題集関連データ一式
    my $collected_list;
    for my $collected_data ( @{$collected_rows_list} ) {
        push @{$collected_list}, $self->collected_data_hash($collected_data);
    }
    $score->{collected_list} = $collected_list;
    return $score;
}

# 登録実行
sub store {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = +{
        question_id  => $self->req_params->{question_id},
        collected_id => $self->req_params->{collected_id},
        user_id      => $self->req_params->{user_id},
        user_answer  => $self->req_params->{user_answer},
        deleted      => $master->deleted->constant('NOT_DELETED'),
    };
    my $txn = $self->db->teng->txn_scope;
    my $answer_id = $self->db->teng_fast_insert( 'answer', $params );

    # エクサキッズ仕様は時間の記録も取得
    my $exa_ids = $self->conf->{exa_ids};
    my $is_exa  = 0;
    for my $id ( @{$exa_ids} ) {
        next if $self->req_params->{user_id} ne $id;
        $is_exa = 1;
    }

    if ($is_exa) {
        my $time_params = +{
            answer_id     => $answer_id,
            remaining_sec => $self->req_params->{remaining_sec},
            deleted       => $master->deleted->constant('NOT_DELETED'),
        };
        my $answer_time_id
            = $self->db->teng_fast_insert( 'answer_time', $time_params );
    }
    $txn->commit;
    return $answer_id;
}

sub to_template_result {
    my $self   = shift;
    my $master = $self->db->master;
    my $result = +{
        answer        => undef,
        result        => undef,
        collected     => undef,
        collected_url => undef,
    };

    my $cond = +{
        id      => $self->req_params->{answer_id},
        deleted => 0,
    };

    my $answer_row = $self->db->teng->single( 'answer', $cond );
    return $result if !$answer_row;

    $result->{answer} = $answer_row->get_columns;
    my $question_row = $answer_row->fetch_question;
    if ( $answer_row->user_answer eq $question_row->answer ) {
        $result->{result} = '正解だ！';
    }
    else {
        $result->{result} = '間違いだ！';
    }

    my $collected = $answer_row->fetch_collected;
    $result->{collected} = $collected->get_columns;
    $result->{collected_url}
        .= '/hackerz/question/collected/' . $collected->id;
    return $result;
}

1;
