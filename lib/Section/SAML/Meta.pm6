use Site::Tools;
use Auth::SAML2::EntityDescriptor;
use Config;

unit class Section::SAML::Meta is Site::Controller;

method handle { 
    my $x509-pem = Config.get('saml-local-idp')<cert>;
    my $meta = Auth::SAML2::EntityDescriptor.new(
                :entity-id('https://egeler.us/saml2/metadata'),
                :organization-name('The Egelers'),
                :organization-display-name('The Egelers'),
                :organization-url('https://egeler.us/'),
                :organization-contact('SurName' => 'Egeler',
                                      'EmailAddress' => 'andrew@egeler.us'),
                :single-sign-on-service('HTTP-POST' => 'https://egeler.us/saml2/auth'),
                :$x509-pem);
    return [200, [ 'Content-Type' => 'text/xml' ], [ ~$meta ] ];
}
