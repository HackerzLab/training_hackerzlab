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
        $score_all += $answer_row->get_score_opened_hint();
    }
    return $score_all;
}

# 解答時の条件を考慮した点数
sub get_overall_score {
    my $self      = shift;
    my $is_exa_sp = shift;

    # 解答結果を取得
    my $answer_rows = $self->search_answer;
    return 0 if !$answer_rows;

    # 早押し総取りの場合
    my $score_all = 0;
    if ($is_exa_sp) {
        for my $answer_row ( @{$answer_rows} ) {
            next if !$answer_row->is_correct;
            next if !$answer_row->is_top_answer;
            $score_all += $answer_row->get_score_opened_hint();
        }
        return $score_all;
    }

    # ヒントの開封と残り時間を考慮した点数
    for my $answer_row ( @{$answer_rows} ) {
        next if !$answer_row->is_correct;
        $score_all += $answer_row->get_score_opened_hint();
        my $answer_time = $answer_row->fetch_answer_time();
        next if !$answer_time;
        $score_all += $answer_time->remaining_sec;
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
sub fetch_collected_row_list {
    my $self         = shift;
    my $collected_id = shift;
    my $ids          = [$collected_id];

    my $collected_rows_list = $self->fetch_collected_rows_list($ids);
    my $collected_row_list  = shift @{$collected_rows_list};
    return $collected_row_list;
}

# 解答結果を含む問題集に関連する情報一式
# [   +{  collected_row     => $collected_row,
#         question_rows_list => [
#             +{  collected_sort_row => $collected_sort_row,
#                 question_row       => $question_row,
#                 hint_opened_rows   => $hint_opened_row || [],
#                 answer_row         => $answer_row || undef,
#             },
#         ],
#     },
#     +{},
#     ...
# ];
sub fetch_collected_rows_list {
    my $self          = shift;
    my $collected_ids = shift;

    my $cond = +{ deleted => 0, };
    if ($collected_ids) {
        $cond->{id} = $collected_ids;
    }
    my $collected_rows_list;
    my @collected_rows = $self->handle->search( 'collected', $cond );
    for my $collected_row (@collected_rows) {

        # 問題集にひもづく問題の順番を取得
        my $row_list = +{
            collected_row => $collected_row,
            question_rows_list =>
                $collected_row->fetch_question_rows_list( $self->id ),
        };
        push @{$collected_rows_list}, $row_list;
    }
    return $collected_rows_list;
}

# 解答結果を含むすべての問題に関連する情報一式
# [   +{  question_row     => $question_row,
#         hint_opened_rows => $hint_opened_row || [],
#         answer_row       => $answer_row || undef,
#     },
#     +{},
#     ...
# ];
sub fetch_question_rows_list {
    my $self          = shift;
    my $user_id       = $self->id;
    my $cond          = +{ deleted => 0, };
    my @question_rows = $self->handle->search( 'question', $cond );
    my $question_rows_list;
    for my $question_row (@question_rows) {
        my $list = $question_row->fetch_answer_row_list($user_id);
        $list->{question_row} = $question_row;
        push @{$question_rows_list}, $list;
    }
    return $question_rows_list;
}

1

__END__
