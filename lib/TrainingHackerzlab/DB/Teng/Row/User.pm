package TrainingHackerzlab::DB::Teng::Row::User;
use Mojo::Base 'Teng::Row';

# 解答結果を取得
sub search_answer {
    my $self = shift;
    my $cond = +{ user_id => $self->id, deleted => 0, };
    my @rows = $self->handle->search( 'answer', $cond );
    return if scalar @rows eq 0;
    return \@rows;
}

# ヒントの開封を考慮した獲得点数
sub get_score_opened_hint {
    my $self = shift;

    # 解答結果を取得
    my $answer_rows = $self->search_answer;
    return 0 if !$answer_rows;

    # 全ての解答結果の得点
    my $score_all = 0;

    # ヒントの開封を考慮した獲得点数
    for my $answer_row (@{$answer_rows}) {
        next if !$answer_row->is_correct;
        $score_all += $answer_row->get_score_opened_hint( $self->id );
    }
    return $score_all;
}

1

__END__
