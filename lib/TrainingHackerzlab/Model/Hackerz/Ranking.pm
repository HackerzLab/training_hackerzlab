package TrainingHackerzlab::Model::Hackerz::Ranking;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

# ランキング一覧画面
sub to_template_index {
    my $self = shift;

    # 登録者のすべての得点
    my $cond = +{deleted => 0,};
    my @user_rows = $self->db->teng->search('user', $cond);

    my $ranking_list = [];
    for my $user_row (@user_rows) {
        my $data = +{
            user_id  => $user_row->id,
            login_id => $user_row->login_id,
            name     => $user_row->name,
            score    => $user_row->get_score_opened_hint,
        };
        push @{$ranking_list}, $data;
    }

    # 順位
    my @sort_ranks = sort { $b->{score} <=> $a->{score} } @{$ranking_list};
    my $rank_list = $self->_rank_sort(\@sort_ranks);
    return $rank_list;
}

# 順位は点数が同じ場合は同じ順位
sub _rank_sort {
    my $self       = shift;
    my $sort_ranks = shift;

    my $rank  = 0;
    my $score = undef;
    for my $sort_rank (@{$sort_ranks}) {

        # 順位をつける
        $rank += 1;
        $sort_rank->{rank} = $rank;

        # 前回の点数と比較 (最初は undef スキップ)
        if (defined $score) {

            # 同点の場合、あげたものを下げる
            if ($sort_rank->{score} == $score) {
                $rank -= 1;
                $sort_rank->{rank} = $rank;
            }
        }
        $score = $sort_rank->{score};
    }
    return $sort_ranks;
}

1;
