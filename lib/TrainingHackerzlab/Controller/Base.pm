package TrainingHackerzlab::Controller::Base;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm::Lite;

sub render_fillin {
    my $self     = shift;
    my $template = shift;
    my $params   = shift;
    my $fiilin   = HTML::FillInForm::Lite->new();
    my $html     = $self->render_to_string( template => $template );
    my $output   = $fiilin->fill( \$html, $params );
    $self->render( text => $output );
    return;
}

# ログイン中はアクセスできない
sub transition_logged_in {
    my $self = shift;
    return if !$self->session('user');
    $self->redirect_to('/hackerz/menu');
    return 1;
}

1;
