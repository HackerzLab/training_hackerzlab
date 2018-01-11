package TrainingHackerzlab::Model::Hackerz::Ranking;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

# ランキング一覧画面
sub to_template_index {
    my $self = shift;

    # 登録者のすべての得点
    my $cond = +{ deleted => 0, };
    my @user_rows = $self->db->teng->search( 'user', $cond );

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
    my $rank = 0;
    for my $sort_rank (@sort_ranks) {
        $rank += 1;
        $sort_rank->{rank} = $rank;
    }
    return \@sort_ranks;
}

1;
