# RS256

## How keys were made

```shell
# No passphrase
# Generates the public and private keys:
ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key
# Converts the key to PEM format
openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub
```
