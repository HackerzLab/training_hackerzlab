package TrainingHackerzlab::Model::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

# 問題メニュー画面
sub to_template_index {
    my $self          = shift;
    my $is_exa        = shift;
    my $cond          = +{ deleted => 0, };
    my @question_rows = $self->db->teng->search( 'question', $cond );
    my $questions;
    for my $question (@question_rows) {
        push @{$questions}, $question->get_columns;
    }

    # exa id ログインの時は指定の問題集のみ
    my $exa_collected_ids = $self->conf->{exa_collected_ids};
    if ($is_exa) {
        $cond->{id} = $exa_collected_ids;
    }
    my @collected_rows = $self->db->teng->search( 'collected', $cond );
    my $collecteds;
    for my $collected (@collected_rows) {
        push @{$collecteds}, $collected->get_columns;
    }
    return +{
        questions  => $questions,
        collecteds => $collecteds,
    };
}

1;
