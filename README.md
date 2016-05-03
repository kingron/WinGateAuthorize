# WinGateAuthorize
A Simple, Fast, Clean Client to replace the WinGate Authorization Java Applet, needn't Install Java Virtual Machin any longer

If you use WinGate and use the user name and password to login WinGate server to access internet you need install the ugly WinGate Authorization Java Applet, you need install heavy Java Virtual Machine at your system and config it for your browser, now, you can use this client to replace the old WinGate authrozation client.


Knwon issue:
WinGate use MD5 and chanllenge to verify the user name and password, but WinGate MD5 string without zero-leading.
Our Client MD5 string is zero-leading string for HEX converting, so sometime it will failed if the MD5 hex have zero-leading chars.


WinGate Authenticate代理登录身份验证客户端程序。可替代WinGate本身的那个浏览器Java Applet客户端，效果完全一致，提供额外的功能，包括自动启动，自动登录，热键定义，断开时的连接检测功能等等。
