use Web::RF;
use Site::Tools;
use Config;
use Auth::SAML2::Assertion;

unit class Section::SAML::AuthRespond is Web::RF::Controller::Authed;

multi method handle(Get :$request) {
    my $sp-info = Config.get('saml-remote-sp');
    my $x509-pem = Config.get('saml-local-idp')<cert>;
    my $private-pem = Config.get('saml-local-idp')<key>;
    my $session = $request.session;

    my $authn = $session.get('saml2-authn-request');

    die X::BadRequest.new unless $authn && $sp-info{$authn.issuer};

    $session.remove('saml2-authn-request');

    my %attributes;
    %attributes<email> = [ $session.data<local-login> ~ '@egeler.us' ];
    %attributes<lname> = [ 'Egeler' ];
    %attributes<fname> = [ $session.data<local-login>.tc ];

    my $assertion = Auth::SAML2::Assertion.new(
        :issuer('https://egeler.us/saml2/metadata'),
        :subject(NameID => $session.data<local-login> ~ '@egeler.us'),
        :%attributes#,
        #:signed,
        #:signature-cert($x509-pem),
        #:signature-key($private-pem)
    );

    my $response = Auth::SAML2::Response.new(
        :issuer('https://egeler.us/saml2/metadata'),
        :$assertion,
        :signed,
        :signature-cert($x509-pem),
        :signature-key($private-pem)
    );

    my $response-b64 = MIME::Base64.encode-str(~$response);
    $response-b64 ~~ s:g/\s+//;

    my $content = '<form method="POST" action="' ~ $sp-info{$authn.issuer}<endpoint> ~ '">'
     ~ '<input type="hidden" name="SAMLResponse" value="' ~ $response-b64 ~ '"></form>'
     ~ '<script language="javascript">document.forms[0].submit();</script>';

    return [200, [ 'Content-Type' => 'text/html' ], [ $content ]];
}
