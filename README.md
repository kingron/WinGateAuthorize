# WinGateAuthorize
A Simple, Fast, Clean Client to replace the WinGate Authorization Java Applet, needn't Install Java Virtual Machin any longer

If you use WinGate and use the user name and password to login WinGate server to access internet you need install the ugly WinGate Authorization Java Applet, you need install heavy Java Virtual Machine at your system and config it for your browser, now, you can use this client to replace the old WinGate authrozation client.


Knwon issue:
WinGate use MD5 and chanllenge to verify the user name and password, but WinGate MD5 string without zero-leading.
Our Client MD5 string is zero-leading string for HEX converting, so sometime it will failed if the MD5 hex have zero-leading chars.
