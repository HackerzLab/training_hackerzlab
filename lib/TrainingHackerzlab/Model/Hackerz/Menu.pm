package TrainingHackerzlab::Model::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

# 問題メニュー画面
sub to_template_index {
    my $self          = shift;
    my $cond          = +{ deleted => 0, };
    my @question_rows = $self->db->teng->search( 'question', $cond );
    my $questions;
    for my $question ( @question_rows ) {
        push @{$questions}, $question->get_columns;
    }
    return +{ questions => $questions, };
}

1;
