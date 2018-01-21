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

1;

__END__
