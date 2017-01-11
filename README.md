## STEPS FOR CREATE SELF-SIGNED SSL CERTIFICATE FOR EC2 LOAD BALANCER

Provide Required Input in Attribute file 
+ NOTE - make sure there is no emty value set. script will automatically taking care of that.

Default value set in attribute.cfg file.

| SR.NO       | ATTRIBUTE           | DEFAULT VALUE  |
| ------------- |-------------| -----|
| 1      | package_name | openssl |
| 2      | domain_name  |   example.com |
| 3 | country |    IN |
| 4 | state     |    MAHARASHTRA |
| 5 | locality      |    PUNE |
| 6 | organization      |    example pvt ltd |
| 7 | organizationalunit     |    IT |
| 8 | email     |    administrator@example.com |
| 9 | certificate_validity     |    365 |
| 10 | password     |    test123 |
| 11 | upload_cert_dir     |    example.com |


1. Update your input in attribute.cfg file.
2. Assign execution permission to setup.sh.
3. Please execute setup.sh using root account.
_____________________________________________________________________________

###1: Generate private key

openssl genrsa -des3 -out my_domain.key 1024
[Enter and confirm pass phrase]

###2: Generate CSR

openssl req -nodes -newkey rsa:2048 -keyout my_domain.key -out my_domain.csr

###3: Remove pass phrase from key

Make sure key only readable by root!

cp my_domain.key my_domain.key.org
openssl rsa -in my_domain.key.org -out my_domain.key

###4: Generate certificate

openssl x509 -req -days 365 -in my_domain.csr -signkey my_domain.key -out my_domain.crt

### Certificate uploading steps - 

1. Go to AWS Control Panel -> EC2 Management Console -> Load Balancers
2. Add listner to HTTPS 
3. Choose Upload SSL Certificate
4. Display key text in terminal window:

openssl rsa -in my_domain.key -text

5. Copy that, including “Begin…End” sections; paste into text field in AWS console
Do the same with the certificate:

openssl x509 -inform PEM -in my_domain.crt

Several layers of saving…

