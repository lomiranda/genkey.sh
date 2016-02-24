# genkey.sh
Bash script to create a ssh-key to an user in serveral instances.<br>

### How does it works?
The genkey.sh creates the user specified in the current server it it does not exist, then creates the directory where his keys will be stored, with the proper permission. The private and public keys are created and the created user will be setted as the owner, and appends the content of the public key in the authorized_keys file.<br>
<br>
The script fetches the IP of the servers that will be synchronized from a file, and does a rsync that creates the user and his home directory in each of the remote hosts and synchonizes the authorized_keys file.<br>
<br>
**Do not forget to change the content of the file with the IPs or hostnames!**<br>
<br>
When deleting an user, the script will only remove the public key from the authorized_keys file and synchonizess it in the others severs. The home directory, the user and the private and public keys will not be deleted.

### Dependencies
- rsync package
- ssh-key from the running server to the hosts that will be synchronized
- a file with the list of the servers that will be synchronized

### Usage
```
bash genkey.sh [arguments] [username]

Arguments:
-h, --help		show help 
--generate		generates a new ssh key 
--delete		deletes the ssh key for the user
```
