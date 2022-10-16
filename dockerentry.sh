#!/bin/sh
echo "Running startup"
export GOOGLE_APPLICATION_CREDENTIALS=/accounts/key.json
echo "Running fuse"
gcsfuse -o rw,allow_other ${BUCKET} /export
echo -e "
[export]
 path = /export
 public = yes
 writable = yes
 guest ok = yes 
 browseable = yes 
 force user = mysmbuser
 force group = smbgroup
" >> /etc/samba/smb.conf
smbd -F
