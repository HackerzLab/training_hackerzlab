package TrainingHackerzlab::DB::Teng::Row::Answer;
use Mojo::Base 'Teng::Row';

# 該当のユーザー
sub fetch_user {
    my $self = shift;
    my $cond = +{ id => $self->user_id, deleted => 0, };
    return $self->handle->single( 'user', $cond );
}

# 該当の問題
sub fetch_question {
    my $self = shift;
    my $cond = +{ id => $self->question_id, deleted => 0, };
    return $self->handle->single( 'question', $cond );
}

# 該当の問題集
sub fetch_collected {
    my $self = shift;
    my $cond = +{ id => $self->collected_id, deleted => 0, };
    return $self->handle->single( 'collected', $cond );
}

# 解答結果は正解
sub is_correct {
    my $self         = shift;
    my $question_row = $self->fetch_question;
    return 1 if $self->user_answer eq $question_row->answer;
    return 0;
}

# ヒントの開封を考慮した獲得点数
sub get_score_opened_hint {
    my $self = shift;

    # 問題のヒントが開封ずみのヒントを取得
    my $question_row = $self->fetch_question;
    my $hint_rows
        = $question_row->search_opened_hint( $self->user_id,
        $self->collected_id );
    my $count = scalar @{$hint_rows};
    return $question_row->score - ( $count * 2 );
}

# 回答の残り時間
sub fetch_answer_time {
    my $self = shift;
    my $cond = +{ answer_id => $self->id, deleted => 0, };
    return $self->handle->single( 'answer_time', $cond );
}

# 回答の入力が一番早い
sub is_top_answer {
    my $self       = shift;
    my $my_user_id = $self->user_id;
    my $cond       = +{
        question_id  => $self->question_id,
        collected_id => $self->collected_id,
        deleted      => 0,
    };

    my @rows = $self->handle->search( 'answer', $cond );
    my $answer_ids = [ map { $_->id } @rows ];
    my $at_params = +{ answer_id => $answer_ids, deleted => 0, };

    # 該当の入力された時間取得
    my $at_attr = +{ order_by => 'entered_ts ASC' };
    my @at_rows
        = $self->handle->search( 'answer_time', $at_params, $at_attr );
    return 0 if scalar @at_rows eq 0;

    # 正解者のみ
    my $is_correct_users = [];
    for my $at_row (@at_rows) {
        if ( $at_row->fetch_answer->is_correct ) {
            push @{$is_correct_users}, $at_row->fetch_answer;
        }
    }

    # 一番最初の解答者
    my $top_answer = shift @{$is_correct_users};
    return 0 if !$top_answer;

    if ( $top_answer->user_id eq $my_user_id ) {
        return 1;
    }
    return 0;
}

1;

__END__
