#!/usr/bin/bash
docker stop test_sender test_receiver
docker rm test_sender test_receiver

#last step: cd /var/run/netns/  delet invalid netspace link
