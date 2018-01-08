package TrainingHackerzlab::DB::Teng::Row::User;
use Mojo::Base 'Teng::Row';

# 解答結果を取得
sub search_answer {
    my $self = shift;
    my $cond = +{user_id => $self->id, deleted => 0,};
    my @rows = $self->handle->search('answer', $cond);
    return if scalar @rows eq 0;
    return \@rows;
}

1;

__END__
