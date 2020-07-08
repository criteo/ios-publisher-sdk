# Wiremock

## Why

While Open Sourcing our SDKs, we noticed some of our tests relied on our preprod
services. As this is no longer possible, and because some of the network calls
occurs in Third Party SDKs, which cannot be mocked by code easily, we decided to
use WireMock.

## Generate self signed certificate

We need for these tests HTTP support, for doing so we need a self-signed
certificate. It was generated mostly following [this post][ios-self-signed]

1. Generate self signed certificate
    ```sh
    openssl req -config wiremock.cnf -new -x509 -out wiremock.crt
    ```
    You can check certificate correctness
    ```sh
    openssl x509 -in wiremock.crt -text -noout
    ```

2. Export the certificate
    ```sh
    openssl pkcs12 -export -name wiremock -in wiremock.crt -inkey wiremock.key -out wiremock.p12
    ```
    The password used is `password`

3. Convert this to java keystore
    ```sh
    keytool -importkeystore -destkeystore wiremock.jks -srckeystore wiremock.p12 -srcstoretype pkcs12 -alias wiremock
    ```
    Again, the password used is `password`

## Start wiremock

```sh
java -jar wiremock.jar --https-port 9099 --root-dir wiremock --https-keystore wiremock/cert/wiremock.jks --keystore-password password
```
You can check it works on wiremock side
```sh
curl -k 'https://localhost:9099/cdb-stubs/delivery/ajs.php?width=320&height=50'
```

## Register Self Signed certificate on iOS simulator

You can register the self-signed certificate by drag & dropping the `crt` file
to the Simulator window. You can also do this using [iostrust] gem by running
the following command:
```sh
bundle exec iostrust add ./wiremock/cert/wiremock.crt
```

[ios-self-signed]: https://medium.com/vmware-end-user-computing/creating-a-tls-connection-with-wiremock-e275daf72549
[iostrust]: https://github.com/yageek/iostrust
