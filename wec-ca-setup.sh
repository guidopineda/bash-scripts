rm -rf pki/*

# Generate the key of the WEC CA

mkdir -p pki/ca/private
echo '<a password>' > pki/ca/private/passphrase.txt
echo -e "- Generating private key for WEC CA:\t\t\t\t\twec_ca.key"

openssl genrsa \
        -aes256 \
        -passout \
        file:pki/ca/private/passphrase.txt \
        -out pki/ca/private/wec_ca.key 4096 &>/dev/null

chmod -R 700 pki/ca/private/

# Generate the self-signed certificate of the LogManagementClientCA

mkdir pki/ca/certs
echo -e "- Generating self-signed certificate for WEC CA:\t\t\twec_ca.crt"
sleep 2
openssl req \
        -x509 \
        -passin file:pki/ca/private/passphrase.txt \
        -new \
        -nodes \
        -key pki/ca/private/wec_ca.key \
        -days 7300 -out pki/ca/certs/wec_ca.crt \
        -subj '/C=Country/L=City/O=Organization/OU=OrganizationUnit/CN=CommonName' &>/dev/null

# Compute the fingerprint for wec_ca.crt (It will be used by the Windows host)

openssl x509 \
        -in pki/ca/certs/wec_ca.crt \
        -fingerprint \
        -sha1 \
        -noout | sed -e 's/\://g' | sed -e 's/[^=]*=//g' > pki/ca/wec_ca.crt.sha1-print

fingerprint=`cat pki/ca/wec_ca.crt.sha1-print`
echo -e "- Certificate Fingerprint:\t\t\t\t\t\t"${fingerprint}
sleep 2
# Generate the generic private key for the Windows clients

mkdir -p pki/client
echo -e "- Generating the generic private key and CSR for the Windows clients:\twec-client-generic.key, wec-client-generic.csr"
sleep 2
openssl req \
        -new \
        -newkey rsa:4096 \
        -nodes \
        -out pki/client/wec-client-generic.csr \
        -keyout pki/client/wec-client-generic.key \
        -subj '/C=Country/L=City/O=Organization/OU=OrganizationUnit/CN=*' &>/dev/null

# Signing the CSR

echo -e "- Signinging the CSR:\t\t\t\t\t\t\twec-client-generic.csr"
sleep 2
openssl x509 \
        -req \
        -passin file:pki/ca/private/passphrase.txt \
        -in pki/client/wec-client-generic.csr \
        -out pki/client/wec-client-generic.crt \
        -CA pki/ca/certs/wec_ca.crt \
        -CAkey pki/ca/private/wec_ca.key \
        -CAcreateserial \
        -extfile etc/templates/wec-client-generic-certopts.cnf \
        -extensions req_ext \
        -days 3650 &>/dev/null

# Export file for Windows client in .p12 format

echo -e "- Generating file for Windows client in .p12 format:\t\t\twec-client-generic.p12"
sleep 2
openssl pkcs12 \
        -export \
        -passout file:pki/ca/private/passphrase.txt \
        -inkey pki/client/wec-client-generic.key \
        -in pki/client/wec-client-generic.crt \
        -certfile pki/ca/certs/wec_ca.crt \
        -out pki/client/wec-client-generic.p12

tree pki
sleep 2
# Verify the trust for the created certificates

echo "- Trust verification"
openssl verify -CAfile pki/ca/certs/wec_ca.crt pki/client/wec-client-generic.crt
