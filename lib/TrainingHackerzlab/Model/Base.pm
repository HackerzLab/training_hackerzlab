package TrainingHackerzlab::Model::Base;
use Mojo::Base -base;
use TrainingHackerzlab::DB;

has [qw{conf req_params}];

has db => sub {
    TrainingHackerzlab::DB->new( +{ conf => shift->conf } );
};

# 問題へのurl
# 例
# "/hackerz/question/collected/$collected_id/$sort_id/think"
# "/hackerz/question/$sort_id/think"
sub create_question_url {
    my $self         = shift;
    my $sort_id      = shift;
    my $collected_id = shift;
    my $q_url        = "/hackerz/question";
    if ( defined $collected_id ) {
        $q_url .= "/collected/$collected_id";
    }
    $q_url .= "/$sort_id/think";
    return $q_url;
}

# 解答関連データ一式
sub answer_data_hash {
    my $self     = shift;
    my $data_row = shift;

    my $answer          = $data_row->{answer_row}->get_columns;
    my $question        = $data_row->{question_row}->get_columns;
    my $answer_time_row = $data_row->{answer_row}->fetch_answer_time;
    my $answer_time     = +{};
    if ($answer_time_row) {
        $answer_time = $answer_time_row->get_columns;
    }

    my $hash_row = +{
        answer      => $answer,
        how         => '不正解',
        how_text    => 'danger',
        get_score   => 0,
        is_answered => 1,
        answer_time => $answer_time,
    };
    return $hash_row if $answer->{user_answer} ne $question->{answer};

    $hash_row->{how}      = '正解';
    $hash_row->{how_text} = 'success';

    # ヒントの開封を考慮した獲得点数
    $hash_row->{get_score}
        = $data_row->{answer_row}->get_score_opened_hint();
    return $hash_row;
}

# 問題関連データ一式
sub question_data_hash_collected {
    my $self     = shift;
    my $data_row = shift;

    my $collected_sort = $data_row->{collected_sort_row}->get_columns;
    my $question       = $data_row->{question_row}->get_columns;
    my $hint_rows      = $data_row->{hint_opened_rows};

    my $data_hash = +{
        collected_sort => $collected_sort,
        question       => $question,
        short_title    => _short_cut( $question->{title} ),
        sort_id        => $collected_sort->{sort_id},
        collected_id   => $collected_sort->{collected_id},
        q_url          => $self->create_question_url(
            $collected_sort->{sort_id},
            $collected_sort->{collected_id},
        ),
        short_question    => substr( $question->{question}, 0, 20 ) . ' ...',
        how               => '未',
        how_text          => 'primary',
        hint_opened_level => [ map { $_->level } @{$hint_rows} ],
        get_score         => 0,
        is_answered       => 0,
    };

    # 問題開封履歴
    my $qo_params = +{
        question_id  => $question->{id},
        collected_id => $collected_sort->{collected_id},
        opened       => 1,
        deleted      => 0,
    };
    my $qo_row = $self->db->teng->single( 'question_opened', $qo_params );
    if ($qo_row) {
        $data_hash->{how}      = '開封済';
        $data_hash->{how_text} = 'info';
    }

    if ( $data_row->{answer_row} ) {
        my $answer_hash = $self->answer_data_hash($data_row);
        while ( my ( $key, $val ) = each %{$answer_hash} ) {
            $data_hash->{$key} = $val;
        }
    }
    return $data_hash;
}

# 20文字以上は ...
sub _short_cut {
    my $text = shift;
    my $short_str = substr( $text, 0, 20 );
    if ( length $short_str >= 20 ) {
        $short_str .= ' ...';
    }
    return $short_str;
}

# 問題関連データ一式 (すべての問題)
sub question_data_hash_all {
    my $self     = shift;
    my $data_row = shift;

    my $question_row = $data_row->{question_row};
    my $hint_rows    = $data_row->{hint_opened_rows};
    my $sort_id      = $question_row->id;

    my $data_hash = +{
        sort_id           => $sort_id,
        question          => $question_row->get_columns,
        short_title       => _short_cut( $question_row->title ),
        q_url             => $self->create_question_url($sort_id),
        how               => '未',
        how_text          => 'primary',
        hint_opened_level => [ map { $_->level } @{$hint_rows} ],
        get_score         => 0,
    };
    if ( $data_row->{answer_row} ) {
        my $answer_hash = $self->answer_data_hash($data_row);
        while ( my ( $key, $val ) = each %{$answer_hash} ) {
            $data_hash->{$key} = $val;
        }
    }
    return $data_hash;
}

# 問題集関連データ一式
sub collected_data_hash {
    my $self     = shift;
    my $data_row = shift;

    # 問題関連データ一式
    my $question_list = [];
    for my $question_data ( @{ $data_row->{question_rows_list} } ) {
        push @{$question_list},
            $self->question_data_hash_collected($question_data);
    }

    # 獲得点数の計算
    my $total_score = 0;
    for my $question_data ( @{$question_list} ) {
        $total_score += $question_data->{get_score};
    }

    return +{
        collected     => $data_row->{collected_row}->get_columns,
        total_score   => $total_score,
        question_list => $question_list,
    };
}

1;

