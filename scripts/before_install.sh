#!/bin/bash
if [ -d /home/ec2-user/app ]; then
    rm -rf /home/ec2-user/app/*
else
    mkdir -p /home/ec2-user/app
fi
