use HTMLPage;
use Config;
use Auth::SAML2::Assertion;

unit class Section::SAML::AuthRespond does HTMLPage;

has $!status = 200;
has @!headers;

method html-data {
    my $sp-info = Config.get('saml-remote-sp');
    my $x509-pem = Config.get('saml-local-idp')<cert>;
    my $private-pem = Config.get('saml-local-idp')<key>;

    unless $.session.data<local-login> {
        $!status = 302;
        @!headers.push('Location' => '/login?return=/saml2/authrespond');
        return '';
    }

    my $authn = $.session.data<saml2-authn-request>:delete;

    die "No current auth request" unless $authn;

    die "Unknown remote: " ~ $authn.issuer unless $sp-info{$authn.issuer};

    my %attributes;
    %attributes<email> = [ $.session.data<local-login> ~ '@egeler.us' ];
    %attributes<lname> = [ 'Egeler' ];
    %attributes<fname> = [ $.session.data<local-login>.tc ];

    my $assertion = Auth::SAML2::Assertion.new(
        :issuer('https://egeler.us/saml2/metadata'),
        :subject(NameID => $.session.data<local-login> ~ '@egeler.us'),
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

    return '<form method="POST" action="' ~ $sp-info{$authn.issuer}<endpoint> ~ '">'
     ~ '<input type="hidden" name="SAMLResponse" value="' ~ $response-b64 ~ '"></form>'
     ~ '<script language="javascript">document.forms[0].submit();</script>';
}

method html-status { $!status }
method html-headers { @!headers }
