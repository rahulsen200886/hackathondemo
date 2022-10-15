echo "Running startup"
export GOOGLE_APPLICATION_CREDENTIALS=/accounts/key.json
var_smbuser="mysmbuser"
var_smbpassword="changemelater"
var_smbgroup="smbgroup"
useradd $var_smbuser
groupadd $var_smbgroup
usermod -a -G $var_smbgroup $var_smbuser
(echo "$var_smbpassword" ;echo "$var_smbpassword" )|smbpassword -s -a $var_smbuser
mkdir -p /export
chmod 755 /export
chown $var_smbuser:$var_smbgroup /export
echo "Running fuse"
gcsfuse -o rw,allow_other ${BUCKET} /export
echo -e "
[export]
 path = /export
 public = yes
 writable = yes
 guest ok = yes 
 browseable = yes 
 force user = $var_smbuser
 force group = $var_smbgroup
" >> /etc/samba/smb.conf


smdb --foreground --log-stdout
