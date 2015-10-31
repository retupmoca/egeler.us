use Site::Template;
use Page::Redirect;

use Auth::PAM::Simple;

unit class Page::Login;

method display_login($return) {
    return [ 200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('login.tmpl'))
                            .render(return => $return) ]];
}

multi method handle(:$request! where { $_.method eq 'GET' }, :$session) {
    my $params = $request.parameters;

    return self.display_login($params<return>);
}

multi method handle(:$request! where { $_.method eq 'POST' }, :$session) {
    my $params = $request.parameters;

    if authenticate('login', $params<user>, $params<password>) {
        $session.data<local-login> = $params<user>;
        my $return = $params<return>;
        return Page::Redirect.go(:code(302), :url($return || '/'));
    }
    return self.display_login($params<return>);
}
