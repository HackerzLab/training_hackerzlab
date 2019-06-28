package TrainingHackerzlab::Model::Exakids;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

sub to_template_index {
    my $self = shift;
    my $to_template = +{ exakids_users => [] };

    # エクサキッズ対象ユーザー
    my $exa_ids = $self->conf->{exa_ids};
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids } );
    for my $user (@exakids_users) {
        push @{ $to_template->{exakids_users} }, $user->get_columns;
    }
    return $to_template;
}

# 解答結果を含む指定の問題集に関連する情報一式
# +{  collected_row      => $collected_row,
#     question_rows_list => [
#         +{  collected_sort_row => $collected_sort_row,
#             question_row       => $question_row,
#             hint_opened_rows   => $hint_opened_row || [],
#             answer_row         => $answer_row || undef,
#         },
#     ],
# };
# 横2列、縦行なりゆき
# my $entry_users_data = [
#     [   +{ user => $user_row->get_columns },
#         +{  collected     => $collected_row->get_columns,
#             total_score   => $total_score,
#             question_list => [
#                 +{  collected_id      => 14,
#                     collected_sort    => $collected_sort_row->get_columns,
#                     get_score         => 0,
#                     hint_opened_level => [],
#                     how               => "未",
#                     how_text          => "primary",
#                     is_answered       => 0,
#                     q_url    => "/hackerz/question/collected/14/1/think",
#                     question => $question_row->get_columns,
#                     short_question => "クイズ...",
#                     short_title    => "クイズタイトル",
#                     sort_id        => 1,
#                 },
#                 +{},
#             ],
#         },
#         +{},
#     ],
#     [],
# ];

sub to_template_menu {
    my $self        = shift;
    my $to_template = +{};

    # 表示したい問題集のナンバーをきめなくてはいけない
    my $show_collected_id = $self->conf->{exa_collected_id};
    my $exa_collected_ids = $self->conf->{exa_collected_ids};

    # 解答者
    my $exa_ids_entry = $self->conf->{exa_ids_entry};
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids_entry } );
    my $entry_users_data = [];
    my $count            = 0;
    my $line             = [];
    for my $row (@exakids_users) {
        $count = $count + 1;
        if ( $count == 1 ) {

            # 解答状況の情報一式
            my $collected_rows_list
                = $row->fetch_collected_rows_list($exa_collected_ids);
            my $collected_list;
            push @{$collected_list}, +{ user => $row->get_columns };
            for my $collected_data ( @{$collected_rows_list} ) {
                push @{$collected_list},
                    $self->collected_data_hash($collected_data);
            }
            push @{$line}, $collected_list;
            next;
        }
        if ( $count == 2 ) {
            my $collected_rows_list
                = $row->fetch_collected_rows_list($exa_collected_ids);
            my $collected_list;
            push @{$collected_list}, +{ user => $row->get_columns };
            for my $collected_data ( @{$collected_rows_list} ) {
                push @{$collected_list},
                    $self->collected_data_hash($collected_data);
            }
            push @{$line},             $collected_list;
            push @{$entry_users_data}, $line;
            $line  = [];
            $count = 0;
            next;
        }
    }
    $to_template->{entry_users_data} = $entry_users_data;
    return $to_template;
}

# 順位は点数が同じ場合は同じ順位
sub _rank_sort {
    my $self       = shift;
    my $sort_ranks = shift;

    my $rank  = 0;
    my $score = undef;
    for my $sort_rank ( @{$sort_ranks} ) {

        # 順位をつける
        $rank += 1;
        $sort_rank->{rank} = $rank;

        # 前回の点数と比較 (最初は undef スキップ)
        if ( defined $score ) {

            # 同点の場合、あげたものを下げる
            if ( $sort_rank->{overall_score} == $score ) {
                $rank -= 1;
                $sort_rank->{rank} = $rank;
            }
        }
        $score = $sort_rank->{overall_score};
    }
    return $sort_ranks;
}

sub to_template_ranking {
    my $self        = shift;
    my $to_template = +{};

    # エクサキッズ、解答者
    my $exa_ids_entry = $self->conf->{exa_ids_entry};
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids_entry } );

    # 解答時の条件を考慮した点数 (overall_score)
    my $ranking_list = [];
    for my $user_row (@exakids_users) {
        my $data = +{
            user_id       => $user_row->id,
            login_id      => $user_row->login_id,
            name          => $user_row->name,
            score         => $user_row->get_score_opened_hint,
            overall_score => $user_row->get_overall_score,
        };
        push @{$ranking_list}, $data;
    }

    # 順位
    my @sort_ranks = sort { $b->{overall_score} <=> $a->{overall_score} }
        @{$ranking_list};
    my $rank_list = $self->_rank_sort( \@sort_ranks );
    $to_template->{rankings} = $rank_list;
    return $to_template;
}

1;
