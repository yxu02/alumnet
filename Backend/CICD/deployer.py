#!/usr/bin/env python

#
# Hyunwook Shin
# Code is from CMPE272 Final Project
# The AMI ID has been updated to use
# the premade AMI.

import os
import boto3
import copy
import argparse
import paramiko
import time
import sys

AWS_ACCESS_ID = os.environ.get( 'AWS_ACCESS_ID' )
AWS_SECRET_KEY = os.environ.get( 'AWS_SECRET_KEY' )
KEY_NAME = 'FirstEC2'

def parseArgs():
   parser = argparse.ArgumentParser(description='Argument parser')
   parser.add_argument('--deploy', action="store_true")
   parser.add_argument('--host', action="store_true")
   parser.add_argument('--destroy', action="store_true")
   parser.add_argument('--tag', required=False )
   return parser.parse_args()

def getInstances( tagname, ec2 ):
   instances = []
   for instance in ec2.instances.all():
      if not instance.tags:
         continue
      ts = [ tag for tag in instance.tags if tag.get( 'Key' ) == 'Name' ]
      if ts:
         if ts[0][ 'Value' ] == tagname:
            instances.append( instance )
   return instances

def main():
   args = parseArgs()
   TAG = args.tag if args.tag  else ''
   instanceCount = 1
   ec2  = boto3.resource( 'ec2',
                           aws_access_key_id=AWS_ACCESS_ID,
                           aws_secret_access_key=AWS_SECRET_KEY,
                           region_name='us-east-2' )
   if args.deploy:
      instances = ec2.create_instances( ImageId='ami-2ef2cf4b',
                                        MinCount=1,
                                        MaxCount=instanceCount,
                                        KeyName=KEY_NAME,
                                        InstanceType='t2.nano' )
      instanceIds = [ instance.id for instance in instances ]
      instancesToTrack = [ instance for instance in instances ]

      ec2.create_tags(
         Resources=instanceIds,
         Tags = [ { 'Key' : 'Name', 'Value' : TAG } ] )

      print 'Waiting for instances to warm up...',
      instancesToTrack = getInstances( TAG, ec2 )
      while True:
         print '.',
         good = 0
         for instance in instancesToTrack:
            print instance.state
            if instance.state[ 'Name' ] == 'running':
               good +=1
         print '%d instances are ready' % good
         if good >= instanceCount:
            break
         instancesToTrack = getInstances( TAG, ec2 )
      print 'Done'

   elif args.host:
      instances = getInstances( TAG, ec2 )
      if len( instances ) == 0:
         raise IndexError( 'No EC2 found' )
      else:
         for instance in instances:
            if instance.state[ 'Name' ] == 'running':
               print instance.public_ip_address
               return
      raise IndexError( 'No running EC2 found' )

   elif args.destroy:
      instances = getInstances( TAG, ec2 )
      print '%d instances to remove' % len( instances )
      ec2.instances.filter(
          InstanceIds=[ instance.id for instance in instances ] ).terminate()

if __name__ == '__main__':
   main()
