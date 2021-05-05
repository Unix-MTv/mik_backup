# mik_bkp
Simple bash script backup to mikrotik for linux server.

<p>Create key mik_rsa:<br />
# cd ~/.ssh/<br />
# ssh-keygen -t rsa -b 2048<br />
- /root/.ssh/mik_rsa<br />
id_rsa [mik_rsa] - secret key (for the host from which we are connecting)<br />
id_rsa.pub [mik_rsa.pub] - public key (for the host to which we are connecting)</p>

<p>We specify a lot of hosts through a space:<br />
# nano ~/.ssh/config<br />
Host 172.16.5.1 172.17.5.1<br />
IdentityFile ~/.ssh/mik_rsa<br />
# chmod 600 ~/.ssh/config<br />
# service sshd restart</p>
