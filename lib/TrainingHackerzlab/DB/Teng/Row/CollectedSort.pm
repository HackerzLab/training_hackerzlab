package TrainingHackerzlab::DB::Teng::Row::CollectedSort;
use Mojo::Base 'Teng::Row';

# 該当の問題
sub fetch_question {
    my $self = shift;
    my $cond = +{ id => $self->question_id, deleted => 0, };
    return $self->handle->single( 'question', $cond );
}

# 問題のヒントが開封ずみのヒントを取得
sub search_opened_hint {
    my $self         = shift;
    my $user_id      = shift;
    my $collected_id = $self->collected_id;
    my $question_row = $self->fetch_question;
    return $question_row->search_opened_hint( $user_id, $collected_id );
}

# 該当の問題集
sub fetch_collected {
    my $self = shift;
    my $cond = +{ id => $self->collected_id, deleted => 0, };
    return $self->handle->single( 'collected', $cond );
}

# 該当の入力済みの解答を取得
sub fetch_answer {
    my $self    = shift;
    my $user_id = shift;
    my $cond    = +{
        question_id  => $self->question_id,
        collected_id => $self->collected_id,
        user_id      => $user_id,
        deleted      => 0,
    };
    return $self->handle->single( 'answer', $cond );
}

# 次の問題の順番
sub next_question_sort_id {
    my $self         = shift;
    my $next_sort_id = $self->sort_id + 1;
    my $cond         = +{
        collected_id => $self->collected_id,
        sort_id      => $next_sort_id,
        deleted      => 0,
    };
    my $collected_sort_row = $self->handle->single( 'collected_sort', $cond );
    return if !$collected_sort_row;
    return $next_sort_id;
}

# 解答結果を含む該当の問題ひとつに関連する情報一式
# +{  question_row     => $question_row,
#     hint_opened_rows => $hint_opened_row || [],
#     answer_row       => $answer_row || undef,
# };
sub fetch_question_row_list {
    my $self              = shift;
    my $user_id           = shift;
    my $question_row_list = +{
        question_row     => $self->fetch_question,
        hint_opened_rows => $self->search_opened_hint($user_id),
    };
    my $answer_row = $self->fetch_answer($user_id);
    if ($answer_row) {
        $question_row_list->{answer_row} = $answer_row;
    }
    return $question_row_list;
}

1;

__END__
