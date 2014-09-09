#!/usr/bin/env python

networkList = {}

from netifaces import interfaces, ifaddresses, AF_INET
from json import dumps
import re
from urllib import quote_plus
import urllib2
import socket

for ifaceName in interfaces():
    if ifaceName != 'lo':
        networkList[ifaceName] = [i['addr'] for i in ifaddresses(ifaceName).setdefault(AF_INET, [{'addr':'No IP addr'}] ) ]

for line in open("/home/{{pi_user}}/signage.conf"):
    if "ConcertoScreenNumber=" in line:
        screen = re.search('(?<==)\w+', line)
        if screen != None:
            screenname = screen.group(0)
        else:
            screenname = "default"

hostname = socket.gethostname()

ga_url = "http://www.google-analytics.com/collect?v=1&tid={{ga_code}}&cid=6&t=event&ec=rpisignage&ea=%s|%s&el=%s"
ip_info = quote_plus(dumps(networkList))
final_url = ga_url % (screenname, hostname, ip_info)
urllib2.urlopen(final_url, timeout=10).close
