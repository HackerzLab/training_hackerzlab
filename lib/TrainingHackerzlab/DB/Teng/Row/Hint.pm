package TrainingHackerzlab::DB::Teng::Row::Hint;
use Mojo::Base 'Teng::Row';

# ヒントの開封履歴が存在する
sub is_opened {
    my $self         = shift;
    my $user_id      = shift;
    my $collected_id = shift;

    my $cond = +{
        user_id      => $user_id,
        hint_id      => $self->id,
        collected_id => $collected_id,
        opened       => 1,
        deleted      => 0,
    };
    my $row = $self->handle->single( 'hint_opened', $cond );
    return 1 if $row;
    return;
}

1;

__END__
