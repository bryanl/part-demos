local dex = {
    generateConfigMap(src)::
        {
            apiVersion: "v1",
            kind: "ConfigMap",
            metadata: {
                name: "changeme",
            },
            data: {
                "config.yaml": src,
            },
        },

    generate(issuer, staticClients, connectors)::
        local x = std.manifestYamlDoc({
            issuer: issuer,
            web: {
                https: "0.0.0.0:5556",
                tlsCert: "/etc/dex/tls/tls.crt",
                tlsKey: "/etc/dex/tls/tls.key",
            },
            telemetry: {
                http: "0.0.0.0:5558",
            },
            staticClients: staticClients,
            connectors: connectors,
            skipApproval: true,
            storage: {
                type: "kubernetes",
                config: {
                    inCluster: true,
                },
            },
            enablePasswordDB: true,
        });

        self.generateConfigMap(std.manifestYamlDoc(x)),

    staticClient:: {
        gangway(redirectURI, secret)::
            {
                id: "gangway",
                redirectURIs: [redirectURI],
                name: "Gangway",
                secret: secret,
            },
    },

    connectors:: {
        saml(ssoURL, ca, redirectURI, entityIssurer, ssoIssuer, username, email, id='simplesaml', name='SimpleSaml', insecureSkipSignatureValidation=false, nameIDPolicyFormat='transient')::
            {
                type: 'saml',
                id: id,
                name: name,
                config: {
                    ssoURL: ssoURL,
                    ca: ca,
                    insecureSkipSignatureValidation: insecureSkipSignatureValidation,
                    entityIssurer: entityIssurer,
                    ssoIssuer: ssoIssuer,
                    usernameAttr: username,
                    emailAttr: email,
                    nameIDPolicyFormat: nameIDPolicyFormat,
                },
            },
    },
};

local issuer = "https://192.168.107.102:32000/dex";

local staticClients = [
    dex.staticClient.gangway('http://192.168.107.102:31284/callback', 'ZXhhbXBsZS1hcHAtc2VjcmV0'),
];

local connectors = [
    dex.connectors.saml(
        "http://192.168.107.10:8084/simplesaml/saml2/idp/SSOService.php",
        "/tmp/saml-ca.pem",
        "https://192.168.107.102:32000/dex/callback",
        "https://192.168.107.102:32000/dex",
        "http://192.168.107.10:8084/simplesaml/saml2/idp/metadata.php",
        "name",
        "email",
    ),
];

dex.generate(issuer, staticClients, connectors)
