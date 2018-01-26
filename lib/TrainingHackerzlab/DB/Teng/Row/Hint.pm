package TrainingHackerzlab::DB::Teng::Row::Hint;
use Mojo::Base 'Teng::Row';

# ヒントの開封履歴が存在する
sub is_opened {
    my $self         = shift;
    my $user_id      = shift;
    my $collected_id = shift;

    my $cond = +{
        user_id      => $user_id,
        hint_id      => $self->id,
        collected_id => $collected_id,
        opened       => 1,
        deleted      => 0,
    };
    my $row = $self->handle->single( 'hint_opened', $cond );
    return 1 if $row;
    return;
}

# この問題は解答済み
sub is_answer_ended {
    my $self         = shift;
    my $user_id      = shift;
    my $collected_id = shift || 0;
    my $question_row = $self->fetch_question;
    return 1 if $question_row->is_answer_ended( $user_id, $collected_id );
    return;
}

# 該当の問題
sub fetch_question {
    my $self = shift;
    my $cond = +{ id => $self->question_id, deleted => 0, };
    return $self->handle->single( 'question', $cond );
}

1;

__END__
