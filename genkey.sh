#!/bin/bash

#This script supposes that the running server have the rsync tool installed.
#We also assume that we have a file with a list of the servers that will be synchronized.
#This server should have a root ssh-key access to the others servers to sync the files.

#If the arguments are null, show help
if [ -z "$1" ] || [ -z "$2" ]; then
	echo ""
        echo "USAGE: genkey.sh [arguments] [username]"
        echo ""
        echo "Arguments:"
        echo "  -h, --help                show this help"
        echo "  --generate                generates a new ssh key"
        echo "  --delete          deletes the ssh key for the user"
        echo ""
        exit 1
fi

USERNAME="$2"
KEYPATH="/tmp/keys/$USERNAME"
KEY="$KEYPATH/$USERNAME.key"
PUBKEY="$KEY.pub"
KEYCOMMENT="$USERNAME-public-key"
AUTHPATH="/home/$USERNAME/.ssh"
AUTHFILE="$AUTHPATH/authorized_keys"
SERVERS="/opt/servers"

while test $# -gt 0; do
        case "$1" in
                        --h|--help)
                                echo ""
                                echo "USAGE: genkey.sh [arguments] [username]"
                                echo ""
                                echo "Arguments:"
                                echo "  -h, --help                show this help"
                                echo "  --generate                generates a new ssh key"
                                echo "  --delete          deletes the ssh key for the user"
                                echo ""
                                exit 0
                                ;;
                                
                        --generate)
                                shift
                                
                                #Creates the user and the key paths if they do not exist
                                id -u $USERNAME &>/dev/null || useradd $USERNAME
                                mkdir -p $KEYPATH
                                mkdir -p $AUTHPATH
								
				#Sets the proper permission to the user keys' folder
                                chown -R $USERNAME $KEYPATH
                                
                                #Creates the private and public keys with the username in comment
                                su $USERNAME -c "ssh-keygen -t rsa -N '' -f $KEY -n $USERNAME -C $KEYCOMMENT"
                                
                                #Inserts the new public key in the authorized_keys
                                cat $PUBKEY >> $AUTHFILE
								
				#Sets the proper permission to the user keys' folder again
                                chown -R $USERNAME:$USERNAME $AUTHPATH
                                
                                #Sync the authorized_keys with the others server instances. It also creates the user and his .ssh directory
                                for IPADD in `cat $SERVERS | egrep -v '^(#|$)'`; do
                                        rsync -ravzp --rsync-path="id -u $USERNAME &>/dev/null || useradd $USERNAME && mkdir -p $AUTHPATH && rsync" $AUTHFILE root@$IPADD:$AUTHFILE
                                done
                                
                                shift
                                ;;
                                
                        --delete)
                                shift
                                
				#Remove the line the has the username from the authorized_keys
                                sed --i "/$KEYCOMMENT/d" $AUTHFILE
                                
                                #Sync the authorized_keys with the others server instances.
                                for IPADD in `cat $SERVERS | egrep -v '^(#|$)'`; do
                                        rsync -ravzp $AUTHFILE root@$IPADD:$AUTHFILE
                                done
                                
				#Deletes the keys' directory of the user
                                rm -rf $KEYPATH
                                
                                shift
                                ;;

                        *)
				echo ""
                                echo "Invalid Argument!"
                                echo "Run \"bash genkey.sh -h\" to show all arguments"
                                echo ""
                                break
                                ;;
        esac
done
