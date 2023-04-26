#!/usr/bin/expect
set timeout 30
spawn openssl req -x509 -sha256 -new -nodes -key "./ca/key.pem" -out "./ca/cert.pem" -days 60
expect "Country Name*"
send "CN\r"
expect "State or Province Name*"
send "EF\n"
expect "Locality Name*"
send "GL\r"
expect "Organization Name*"
send "zgclab\r"
expect "Organizational Unit Name*"
send "AS\r"
expect "Common Name*"
send "SAVOP Testing CA\r"
expect "Email Address*"
send "myemail@example.com\r"


interact

