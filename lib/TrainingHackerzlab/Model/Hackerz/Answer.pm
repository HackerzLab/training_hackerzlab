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

    # TODO: ヒントの開封を考慮した獲得点数
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
        $hash->{answer}    = $answer_hash->{answer};
        $hash->{how}       = $answer_hash->{how};
        $hash->{how_text}  = $answer_hash->{how_text};
        $hash->{get_score} = $answer_hash->{get_score};
    }
    return $hash;
}

# 問題集関連データ一式
sub _collected_data_hash {
    my $self = shift;
    my $data = shift;

    # 問題関連データ一式
    my $question_list = [];
    for my $question_data ( @{ $data->{question_row_list} } ) {
        push @{$question_list}, $self->_question_data_hash($question_data);
    }
    return +{
        collected     => $data->{collected_row}->get_columns,
        question_list => $question_list,
    };
}

# 解答結果点数
sub to_template_score {
    my $self    = shift;
    my $master  = $self->db->master;
    my $user_id = $self->req_params->{user_id};
    my $score   = +{
        result         => 0,
        list           => [],
        collected_list => undef,
    };

    # my $score = +{
    #     collected_list => [
    #         +{  collected     => +{},
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
    my $collected_row_list = $user_row->fetch_collected_row_list();

    # 問題集関連データ一式
    my $collected_list;
    for my $collected_data ( @{$collected_row_list} ) {
        push @{$collected_list}, $self->_collected_data_hash($collected_data);
    }
    $score->{collected_list} = $collected_list;

    my $cond = +{
        user_id => $user_id,
        deleted => 0,
    };

    # 解答入力済み
    my @answer_rows = $self->db->teng->search( 'answer', $cond );
    return $score if scalar @answer_rows eq 0;

    # ヒントの開封履歴 (下書き)
    my $list = [];
    for my $answer_row (@answer_rows) {

        my $question_row = $answer_row->fetch_question;
        my $data         = +{
            question          => $question_row->get_columns,
            collected         => undef,
            answer_result     => '不正解',
            hint_opened_level => [],
            get_score         => 0,
        };

        # 問題集の情報
        my $collected    = $answer_row->fetch_collected;
        my $collected_id = 0;
        if ($collected) {
            $data->{collected} = $collected->get_columns;
            $collected_id = $collected->id;
        }

        # 問題のヒントが開封ずみのヒントを取得
        my $hint_rows
            = $question_row->search_opened_hint( $user_id, $collected_id );
        $data->{hint_opened_level} = [ map { $_->level } @{$hint_rows} ];

        # 不正解の場合は 0 点
        if ( $answer_row->is_correct ) {

            # ヒントの開封を考慮した獲得点数
            $data->{get_score} = $answer_row->get_score_opened_hint( $user_id,
                $collected_id );
            $data->{answer_result} = '正解';
        }
        push @{$list}, $data;
    }
    $score->{list} = $list;

    # 獲得点数の計算
    my $total_score = 0;
    for my $row ( @{$list} ) {
        $total_score += $row->{get_score};
    }
    $score->{result} = $total_score;
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
