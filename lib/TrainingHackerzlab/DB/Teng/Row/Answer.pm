package TrainingHackerzlab::DB::Teng::Row::Answer;
use Mojo::Base 'Teng::Row';

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
    return;
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

1;

__END__
