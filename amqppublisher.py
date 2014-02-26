# Copyright 2014 E-Bay Inc.
#
# Author: Ron Rickard <rickard@ebaysf.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
import sys, getopt, ast
from kombu import Connection, Exchange, Queue

def main(argv):

    usage = 'ampq_producer.py -u <uri> -e <exchange> -k <routing key> -b <body>'
    reliable = False
    uri = None
    exchange = None
    routing_key = None
    body_string = None

    try:
        opts, args = getopt.getopt(
            argv, "hu:e:k:b:", ["help", "uri=", "exchange=", "key=", "body="])
    except getopt.GetoptError:
        print '%s' % usage
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print '%s' % usage
            sys.exit()
        elif opt in ("-u", "--uri"):
            uri = arg
        elif opt in ("-e", "--exchange"):
            exchange = arg
        elif opt in ("-k", "--key"):
            routing_key = arg
        elif opt in ("-b", "--body"):
            body_string = arg 
      
    if not uri or not exchange or not routing_key or not body_string:
        print '%s' % usage
        sys.exit(2)

    try:
        body = ast.literal_eval(body_string)
    except SyntaxError,ValueError:
        print 'body must be convertible to a Python expression'
        sys.exit(2)

    exchange = Exchange(exchange, 'topic', durable=False)
    queue = Queue(routing_key, exchange=exchange, routing_key=routing_key)

    with Connection(uri, transport_options={'confirm_publish': True}) as conn:
        producer = conn.Producer(serializer='json')
        producer.publish(body, exchange=exchange, routing_key=routing_key,
                         declare=[queue])

if __name__ == "__main__":
    main(sys.argv[1:])
