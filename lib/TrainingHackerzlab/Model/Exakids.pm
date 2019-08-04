package TrainingHackerzlab::Model::Exakids;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

sub to_template_index {
    my $self = shift;
    my $to_template = +{ exakids_users => [] };

    # エクサキッズ対象ユーザー
    my $exa_ids    = $self->conf->{exa_ids};
    my $exa_ids_sp = $self->conf->{exa_ids_sp};
    my $cond_ids   = [];
    for my $id ( @{$exa_ids} ) {
        push @{$cond_ids}, $id;
    }
    for my $id ( @{$exa_ids_sp} ) {
        push @{$cond_ids}, $id;
    }
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $cond_ids } );
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
    my $self          = shift;
    my $login_user_id = shift;
    my $to_template   = +{};

    # 表示したい問題集のナンバーをきめなくてはいけない
    my $show_collected_id = $self->conf->{exa_collected_id};
    my $exa_collected_ids = $self->conf->{exa_collected_ids};

    # 解答者
    my $exa_ids_entry = $self->conf->{exa_ids_entry};

    # ログイン状況によって表示する user を変更する
    my $exa_ids_sp = $self->conf->{exa_ids_sp};
    for my $id ( @{$exa_ids_sp} ) {
        if ( $login_user_id eq $id ) {
            $exa_ids_entry = $self->conf->{exa_ids_entrysp};
        }
    }

    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids_entry } );
    my $entry_users = [];
    my $count       = 0;
    my $user_line   = [];
    for my $row (@exakids_users) {
        $count = $count + 1;
        if ( $count == 1 ) {
            push @{$user_line}, +{ user => $row->get_columns };
            next;
        }
        if ( $count == 2 ) {
            push @{$user_line}, +{ user => $row->get_columns };
            push @{$entry_users}, $user_line;
            $user_line = [];
            $count     = 0;
            next;
        }
    }
    $to_template->{entry_users} = $entry_users;
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
    my $self          = shift;
    my $login_user_id = shift;
    my $to_template   = +{};

    # エクサキッズ、解答者
    my $exa_ids_entry = $self->conf->{exa_ids_entry};

    # ログイン状況によって表示する user を変更する
    my $is_exa_sp  = 0;
    my $exa_ids_sp = $self->conf->{exa_ids_sp};
    for my $id ( @{$exa_ids_sp} ) {
        if ( $login_user_id eq $id ) {
            $exa_ids_entry = $self->conf->{exa_ids_entrysp};
            $is_exa_sp     = 1;

        }
    }
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
            overall_score => $user_row->get_overall_score($is_exa_sp),
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

sub to_template_user {
    my $self        = shift;
    my $to_template = +{ status => 200, user => +{} };
    my $teng        = $self->db->teng;

    # 表示該当の user.id を全て取得する
    if ( exists $self->req_params->{mode}
        && $self->req_params->{mode} eq 'exasp' )
    {
        my $exa_ids_sp = $self->conf->{exa_ids_entrysp};
        my $cond_ids   = [];
        for my $id ( @{$exa_ids_sp} ) {
            push @{$cond_ids}, $id;
        }
        $to_template->{user_ids} = $cond_ids;
        return $to_template;
    }

    my $user_row
        = $teng->single( 'user', +{ id => $self->req_params->{user_id} } );
    $to_template->{user} = $user_row->get_columns;

    # 解答状況の情報一式
    my $exa_collected_ids = $self->conf->{exa_collected_ids};
    my $collected_rows_list
        = $user_row->fetch_collected_rows_list($exa_collected_ids);
    my $collected_list;
    for my $collected_data ( @{$collected_rows_list} ) {
        push @{$collected_list}, $self->collected_data_hash($collected_data);
    }

    # 早押し総取りの条件反映
    for my $data ( @{$collected_list} ) {
        my $subtract = 0;
        for my $q_list ( @{ $data->{question_list} } ) {

            # 回答済みの者に対して条件を加える
            next if !$q_list->{is_answered};
            my $answer_row = $teng->single( 'answer',
                +{ id => $q_list->{answer}->{id} } );
            next if !$answer_row->is_correct;
            next if $answer_row->is_top_answer;
            $subtract            = $subtract + $q_list->{get_score};
            $q_list->{how}       = '正解(得点なし)';
            $q_list->{how_text}  = 'info';
            $q_list->{get_score} = 0;
        }
        if ( $data->{total_score} ) {
            $data->{total_score} = $data->{total_score} - $subtract;
        }
    }
    $to_template->{collected_list} = $collected_list;
    return $to_template;
}

sub to_template_quick_answer {
    my $self = shift;
    my $to_template = +{ status => 200, quick_answers => +{} };

    # エクサキッズ拡張の確認(早押し総取り解答状況)
    # answer_time を entered_ts の順番に全部取得
    my $at_params = +{ deleted  => 0, };
    my $at_attr   = +{ order_by => 'entered_ts ASC' };
    my @at_rows
        = $self->db->teng->search( 'answer_time', $at_params, $at_attr );

    my $quick_answers = [];
    for my $at_row (@at_rows) {

        # 解答を取得
        my $answer_row = $at_row->fetch_answer;

        # 今見ている問題の該当情報だけを取得
        if (( $answer_row->question_id eq $self->req_params->{question_id} )
            && ( $answer_row->collected_id eq
                $self->req_params->{collected_id} )
            )
        {
            my $quick_answer = +{
                answer      => $answer_row->get_columns,
                answer_time => $at_row->get_columns,
                user        => $answer_row->fetch_user->get_columns,
                question    => $answer_row->fetch_question->get_columns,
                how         => '不正解',
                how_text    => 'danger',
                get_score   => 0,
            };

            # 正解状況
            if ( $answer_row->is_correct ) {
                $quick_answer->{how}      = '正解';
                $quick_answer->{how_text} = 'success';
            }
            $quick_answer->{get_score} = $answer_row->get_score_opened_hint();
            push @{$quick_answers}, $quick_answer;
        }
    }

    # 早押しの得点条件を加える
    $to_template->{quick_answers} = $self->_quick_cond($quick_answers);
    return $to_template;
}

# 早押しの得点条件を加える
sub _quick_cond {
    my $self          = shift;
    my $quick_answers = shift;

    my $rank  = 1;
    my $quick = 0;
    for my $quick_answer ( @{$quick_answers} ) {
        $quick_answer->{rank} = $rank;
        $rank = $rank + 1;

        # 不正解は 0 点
        if ( $quick_answer->{how} eq '不正解' ) {
            $quick_answer->{get_score} = 0;
            next;
        }

        if ( $quick_answer->{how} eq '正解' ) {
            $quick = $quick + 1;

            # 初めての正解者
            next if $quick eq 1;

            # 2回目以降は正解でも 0 点
            $quick_answer->{how}       = '正解(得点なし)';
            $quick_answer->{how_text}  = 'info';
            $quick_answer->{get_score} = 0;
            next;
        }
    }
    return $quick_answers;
}

1;
