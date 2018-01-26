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
        $score_all += $answer_row->get_score_opened_hint( $self->id,
            $answer_row->collected_id );
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

# # 解答結果を含む問題集に関連する情報一式
# sub fetch_collected_list_to_hash {
#     my $self           = shift;
#     my $cond           = +{ deleted => 0, };
#     my @collected_rows = $self->handle->search( 'collected', $cond );
#     my $collected_list;
#     for my $collected_row (@collected_rows) {
#         my $question_list
#             = $collected_row->fetch_question_list_to_hash( $self->id );
#         push @{$collected_list},
#             +{
#             collected     => $collected_row->get_columns,
#             question_list => $question_list,
#             };
#     }
#     return $collected_list;
# }

# 解答結果を含む問題集に関連する情報一式
# [   +{  collected_row     => $collected_row,
#         question_row_list => [
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
    my $self = shift;
    my $cond = +{ deleted => 0, };
    my $collected_rows_list;
    my @collected_rows = $self->handle->search( 'collected', $cond );
    for my $collected_row (@collected_rows) {

        # 問題集にひもづく問題の順番を取得
        my $row_list = +{
            collected_row => $collected_row,
            question_row_list =>
                $collected_row->fetch_question_row_list( $self->id ),
        };
        push @{$collected_rows_list}, $row_list;
    }
    return $collected_rows_list;
}

# 解答結果を含む指定の問題集に関連する情報一式
# +{  collected_row     => $collected_row,
#     question_row_list => [
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

    my $cond = +{
        id      => $collected_id,
        deleted => 0,
    };
    my $collected_row = $self->handle->single( 'collected', $cond );
    return if !$collected_row;

    # 問題集にひもづく問題の順番を取得
    return +{
        collected_row => $collected_row,
        question_row_list =>
            $collected_row->fetch_question_row_list( $self->id ),
    };
}

1

__END__
