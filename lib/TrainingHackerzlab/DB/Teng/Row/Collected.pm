package TrainingHackerzlab::DB::Teng::Row::Collected;
use Mojo::Base 'Teng::Row';

# 該当の問題の順番を取得
sub fetch_collected_sorts {
    my $self = shift;
    my $cond = +{ collected_id => $self->id, deleted => 0, };
    my $attr = +{ order_by => 'sort_id ASC' };
    my @collected_sorts
        = $self->handle->search( 'collected_sort', $cond, $attr );
    return \@collected_sorts;
}

# 該当の問題一覧を取得
#     $question_list = [
#         +{  collected_sort => +{},
#             question => +{},
#             answer => +{},
#         },
#     ],
sub fetch_question_list_to_hash {
    my $self            = shift;
    my $user_id         = shift;
    my $collected_sorts = $self->fetch_collected_sorts;
    my $question_list;
    for my $collected_sort ( @{$collected_sorts} ) {
        my $hash = +{
            collected_sort => $collected_sort->get_columns,
            question       => $collected_sort->fetch_question->get_columns,
        };
        my $answer = $collected_sort->fetch_answer($user_id);
        if ($answer) {
            $hash->{answer} = $answer->get_columns;
        }
        push @{$question_list}, $hash;
    }
    return $question_list;
}

# 解答結果を含む該当の問題に関連する情報一式
# [
#     +{  collected_sort_row => $collected_sort_row,
#         question_row       => $question_row,
#         hint_opened_rows   => $hint_opened_row || [],
#         answer_row         => $answer_row || undef,
#     },
# ];
sub fetch_question_row_list {
    my $self         = shift;
    my $user_id      = shift;
    my $collected_id = $self->id;

    # 問題集にひもづく問題の順番を取得
    my $collected_sort_rows = $self->fetch_collected_sorts;
    my $question_row_list;
    for my $collected_sort_row ( @{$collected_sort_rows} ) {
        my $hash = +{
            collected_sort_row => $collected_sort_row,
            question_row       => $collected_sort_row->fetch_question,
            hint_opened_rows   => $collected_sort_row->search_opened_hint(
                $user_id, $collected_id
            ),
        };
        my $answer_row = $collected_sort_row->fetch_answer($user_id);
        if ($answer_row) {
            $hash->{answer_row} = $answer_row;
        }
        push @{$question_row_list}, $hash;
    }
    return $question_row_list;
}

1;

__END__
