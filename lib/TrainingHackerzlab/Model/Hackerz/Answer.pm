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
    my $collected_id = $params->{collected_id};

    # 全ての問題の場合は collected_id は 0 にする
    if ( !$collected_id ) {
        $collected_id = 0;
    }

    # 二重登録防止
    my $cond = +{
        user_id      => $params->{user_id},
        question_id  => $params->{question_id},
        collected_id => $collected_id,
        deleted      => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $answer = $self->db->teng->single( 'answer', $cond );
    $self->error_msg( $master->answer->to_word('EXISTS_ANSWER') );
    return 1 if $answer;
    $self->error_msg(undef);
    return;
}

# 問題へのurl
sub _question_url {
    my $self           = shift;
    my $collected_sort = shift;
    my $sort_id        = $collected_sort->{sort_id};
    my $collected_id   = $collected_sort->{collected_id};
    my $url = "/hackerz/question/collected/$collected_id/$sort_id/think";
    return $url;
}

# 解答関連データ一式
sub _answer_data_hash {
    my $self = shift;
    my $data = shift;

    my $answer   = $data->{answer_row}->get_columns;
    my $question = $data->{question_row}->get_columns;

    my $hash = +{
        answer    => $answer,
        how       => '不正解',
        how_text  => 'danger',
        get_score => 0,
    };
    return $hash if $answer->{user_answer} ne $question->{answer};

    $hash->{how}      = '正解';
    $hash->{how_text} = 'success';

    # ヒントの開封を考慮した獲得点数
    $hash->{get_score}
        = $data->{answer_row}->get_score_opened_hint_from_answer();
    return $hash;
}

# 問題関連データ一式
sub _question_data_hash {
    my $self = shift;
    my $data = shift;

    my $collected_sort = $data->{collected_sort_row}->get_columns;
    my $question       = $data->{question_row}->get_columns;
    my $hint_rows      = $data->{hint_opened_rows};

    my $hash = +{
        collected_sort => $collected_sort,
        question       => $question,
        sort_id        => $collected_sort->{sort_id},
        collected_id   => $collected_sort->{collected_id},
        q_url          => $self->_question_url($collected_sort),
        short_question => substr( $question->{question}, 0, 20 ) . ' ...',
        how            => '未',
        how_text       => 'primary',
        hint_opened_level => [ map { $_->level } @{$hint_rows} ],
        get_score         => 0,
    };

    if ( exists $data->{answer_row} ) {
        my $answer_hash = $self->_answer_data_hash($data);
        while ( my ( $key, $val ) = each %{$answer_hash} ) {
            $hash->{$key} = $val;
        }
    }
    return $hash;
}

# 問題集関連データ一式
sub _collected_data_hash {
    my $self = shift;
    my $data = shift;

    # 問題関連データ一式
    my $question_list = [];
    for my $question_data ( @{ $data->{question_rows_list} } ) {
        push @{$question_list}, $self->_question_data_hash($question_data);
    }

    # 獲得点数の計算
    my $total_score = 0;
    for my $question_data ( @{$question_list} ) {
        $total_score += $question_data->{get_score};
    }

    return +{
        collected     => $data->{collected_row}->get_columns,
        total_score   => $total_score,
        question_list => $question_list,
    };
}

# 問題関連データ一式
sub _question_data_hash_all {
    my $self     = shift;
    my $data_row = shift;

    my $question_row = $data_row->{question_row};
    my $hint_rows    = $data_row->{hint_opened_rows};

    my $sort_id   = $question_row->id;
    my $data_hash = +{
        sort_id           => $sort_id,
        question          => $question_row->get_columns,
        q_url             => "/hackerz/question/$sort_id/think",
        how               => '未',
        how_text          => 'primary',
        hint_opened_level => [ map { $_->level } @{$hint_rows} ],
        get_score         => 0,
    };

    # 問題の解答状況
    my $answer_row = $data_row->{answer_row};
    if ($answer_row) {
        my $answer_hash = $self->_answer_data_hash_all($data_row);
        while ( my ( $key, $val ) = each %{$answer_hash} ) {
            $data_hash->{$key} = $val;
        }
    }
    return $data_hash;
}

# 解答関連データ一式
sub _answer_data_hash_all {
    my $self     = shift;
    my $data_row = shift;

    my $answer   = $data_row->{answer_row}->get_columns;
    my $question = $data_row->{question_row}->get_columns;

    my $data_hash = +{
        answer   => $answer,
        how      => '不正解',
        how_text => 'danger',
    };
    return $data_hash if $answer->{user_answer} ne $question->{answer};

    $data_hash->{how}      = '正解';
    $data_hash->{how_text} = 'success';

    # ヒントの開封を考慮した獲得点数
    $data_hash->{get_score}
        = $data_row->{answer_row}->get_score_opened_hint_from_answer();

    return $data_hash;
}

# 解答結果点数
sub to_template_score {
    my $self    = shift;
    my $master  = $self->db->master;
    my $user_id = $self->req_params->{user_id};
    my $score   = +{
        collected_list            => undef,
        question_list             => undef,
        question_list_total_score => 0,
    };

    # my $score = +{
    #     collected_list => [
    #         +{  collected     => +{},
    #             total_score   => 0,
    #             question_list => [
    #                 +{  collected_sort => +{},
    #                     question       => +{},
    #                     answer         => +{},
    #                     q_url          => '',
    #                     how            => '',
    #                     how_text       => '',
    #                 },
    #             ],
    #         },
    #         +{},
    #     ],
    # };
    my $user_row = $self->db->teng->single(
        'user',
        +{  id      => $user_id,
            deleted => 0,
        }
    );

    # 関連情報一式取得
    my $collected_rows_list = $user_row->fetch_collected_rows_list();

    # 問題集関連データ一式
    my $collected_list;
    for my $collected_data ( @{$collected_rows_list} ) {
        push @{$collected_list}, $self->_collected_data_hash($collected_data);
    }
    $score->{collected_list} = $collected_list;

    # 全ての問題をとくの得点状況
    my $question_rows_list = $user_row->fetch_question_rows_list();

    # 問題関連データ一式に整形
    my $question_list;
    for my $data_row ( @{$question_rows_list} ) {
        push @{$question_list}, $self->_question_data_hash_all($data_row);
    }
    $score->{question_list} = $question_list;

    # 獲得点数の計算
    my $question_list_total_score = 0;
    for my $question_data ( @{$question_list} ) {
        $question_list_total_score += $question_data->{get_score};
    }
    $score->{question_list_total_score} = $question_list_total_score;
    return $score;
}

# 登録実行
sub store {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = +{
        question_id  => $self->req_params->{question_id},
        collected_id => $self->req_params->{collected_id} || 0,
        user_id      => $self->req_params->{user_id},
        user_answer  => $self->req_params->{user_answer},
        deleted      => $master->deleted->constant('NOT_DELETED'),
    };
    return $self->db->teng_fast_insert( 'answer', $params );
}

sub to_template_list {
    my $self   = shift;
    my $master = $self->db->master;
    my $list   = +{ answers => [], };

    my $cond = +{
        id      => $self->req_params->{user_id},
        deleted => $master->deleted->constant('NOT_DELETED'),
    };
    my $user_row = $self->db->teng->single( 'user', $cond );
    return $list if !$user_row;

    my $answer_rows = $user_row->search_answer;
    return $list if !$answer_rows;

    $list->{answers} = [ map { $_->get_columns } @{$answer_rows} ];
    return $list;
}

sub to_template_result {
    my $self   = shift;
    my $master = $self->db->master;
    my $result = +{};

    my $cond = +{
        id      => $self->req_params->{answer_id},
        deleted => 0,
    };

    my $answer_row = $self->db->teng->single( 'answer', $cond );
    return if !$answer_row;
    $result->{answer} = $answer_row->get_columns;

    my $question_row = $answer_row->fetch_question;

    if ( $answer_row->user_answer eq $question_row->answer ) {
        $result->{result} = '正解だ！';
    }
    else {
        $result->{result} = '間違いだ！';
    }

    # 次の問題
    my $question_id = $question_row->id;
    $question_id += 1;
    $result->{next_question_id} = $question_id;
    $result->{collected_url}    = '/hackerz/question';
    if ( my $collected = $answer_row->fetch_collected ) {
        $result->{collected} = $collected->get_columns;
        $result->{collected_url} .= '/collected/' . $collected->id;
    }
    return $result;
}

1;
