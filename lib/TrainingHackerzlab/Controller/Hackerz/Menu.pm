package TrainingHackerzlab::Controller::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログイン中)
sub index {
    my $self              = shift;
    my $to_template_index = $self->model->hackerz->menu->to_template_index;
    my $collected         = [
        '2016-01-31 Vol.1 [q1-10]',
        '2016-05-08 Vol.3 [q11-15]',
        '2016-06-26 Vol.4 [q16-25]',
        '2016-11-20 Vol.7 [q26-35]',
        '2017-01-22 Vol.8 [q36-45]',
    ];
    $self->render(
        %{$to_template_index},
        collected => $collected,
        template  => 'hackerz/menu/index',
        format    => 'html',
        handler   => 'ep',
    );
    return;
}

1;
