package TrainingHackerzlab::DB::Teng::Row::User;
use Mojo::Base 'Teng::Row';
use TrainingHackerzlab::Util qw{now_datetime};

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
    for my $answer_row ( @{$answer_rows} ) {
        next if !$answer_row->is_correct;
        $score_all += $answer_row->get_score_opened_hint( $self->id );
    }
    return $score_all;
}

# 関連情報全て削除
sub soft_delete {
    my $self = shift;

    my $params = +{
        deleted     => 1,
        modified_ts => now_datetime(),
    };

    # 解答結果削除
    my $answer_rows = $self->search_answer;
    for my $answer ( @{$answer_rows} ) {
        $answer->update($params);
    }

    # ヒント開封履歴削除
    my $cond = +{ user_id => $self->id, deleted => 0, };
    my @rows = $self->handle->search( 'hint_opened', $cond );
    map { $_->update($params) } @rows;

    # ユーザー削除
    $self->update($params);
    return;
}

1

__END__
