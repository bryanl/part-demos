{
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
}
