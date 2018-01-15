package TrainingHackerzlab::DB::Teng::Row::CollectedSort;
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

1;

__END__
