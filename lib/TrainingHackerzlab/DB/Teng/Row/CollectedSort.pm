package TrainingHackerzlab::DB::Teng::Row::CollectedSort;
use Mojo::Base 'Teng::Row';

# 該当の問題
sub fetch_question {
    my $self = shift;
    my $cond = +{ id => $self->question_id, deleted => 0, };
    return $self->handle->single( 'question', $cond );
}

1;

__END__
