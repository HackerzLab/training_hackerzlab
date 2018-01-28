package TrainingHackerzlab::Model::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

# 解答関連データ一式
sub _answer_data_hash {
    my $self     = shift;
    my $data_row = shift;

    my $answer   = $data_row->{answer_row}->get_columns;
    my $question = $data_row->{question_row}->get_columns;

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
        = $data_row->{answer_row}->get_score_opened_hint();
    return $hash;
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

# 問題関連データ一式
sub _question_data_hash {
    my $self           = shift;
    my $data_row       = shift;
    my $collected_sort = $data_row->{collected_sort_row}->get_columns;
    my $question       = $data_row->{question_row}->get_columns;
    my $hint_rows      = $data_row->{hint_opened_rows};
    my $data_hash      = +{
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
    if ( $data_row->{answer_row} ) {
        my $answer_hash = $self->_answer_data_hash($data_row);
        while ( my ( $key, $val ) = each %{$answer_hash} ) {
            $data_hash->{$key} = $val;
        }
    }
    return $data_hash;
}

# 問題集関連データ一式
sub _collected_data_hash {
    my $self     = shift;
    my $data_row = shift;

    # 問題関連データ一式
    my $question_list = [];
    for my $question_data ( @{ $data_row->{question_rows_list} } ) {
        push @{$question_list}, $self->_question_data_hash($question_data);
    }

    # # 獲得点数の計算
    # my $total_score = 0;
    # for my $question_data ( @{$question_list} ) {
    #     $total_score += $question_data->{get_score};
    # }

    return +{
        collected     => $data_row->{collected_row}->get_columns,
        question_list => $question_list,
    };
}

sub to_template_show {
    my $self = shift;
    my $show = +{
        collected     => undef,
        question_list => undef,
    };

    # 関連情報一式取得
    my $cond_user = +{
        id      => $self->req_params->{user_id},
        deleted => 0,
    };
    my $user_row = $self->db->teng->single( 'user', $cond_user );
    return $show if !$user_row;

    my $collected_row_list = $user_row->fetch_collected_row_list(
        $self->req_params->{collected_id} );

    # 問題集関連データ一式
    my $collected_list = $self->_collected_data_hash($collected_row_list);
    while ( my ( $key, $val ) = each %{$collected_list} ) {
        $show->{$key} = $val;
    }
    return $show;
}

1;
