package TrainingHackerzlab::DB::Teng::Row::AnswerTime;
use Mojo::Base 'Teng::Row';

# 該当の解答
sub fetch_answer {
    my $self = shift;
    my $cond = +{ id => $self->answer_id, deleted => 0, };
    return $self->handle->single( 'answer', $cond );
}

1;

__END__
