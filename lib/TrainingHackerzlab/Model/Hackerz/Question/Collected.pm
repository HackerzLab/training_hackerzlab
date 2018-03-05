package TrainingHackerzlab::Model::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

sub to_template_show {
    my $self = shift;
    my $show = +{
        collected     => undef,
        question_list => undef,
    };
    my $user_id      = $self->req_params->{user_id};
    my $collected_id = $self->req_params->{collected_id};

    # 関連情報一式取得
    my $cond = +{
        id      => $user_id,
        deleted => 0,
    };
    my $user_row = $self->db->teng->single( 'user', $cond );
    return $show if !$user_row;

    my $collected_row_list
        = $user_row->fetch_collected_row_list($collected_id);
    return $show if !$collected_row_list;

    # 問題集関連データ一式
    my $collected_list = $self->collected_data_hash($collected_row_list);

    while ( my ( $key, $val ) = each %{$collected_list} ) {
        $show->{$key} = $val;
    }
    return $show;
}

1;
