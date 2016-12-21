# -*- coding: utf-8 -*- 
#!/usr/bin/python
'''
author : li.guo
'''

import urllib
import string
import time
import os
import sys
import time
import platform
from terminalColor import bcolors
from terminalSize  import getTerminalSize

serverlist = []

def cur_file_dir():
    path = sys.path[0]
    if os.path.isdir(path):
        return path
    elif os.path.isfile(path):
        return os.path.dirname(path)

def getTime():
    return time.strftime('%Y-%m-%d %A %p %X', time.localtime(time.time()))

def readData():
    print("{0}My Servers  {1}{2}".format(bcolors.RED, getTime(), bcolors.ENDC))
    global serverlist
    tuple_xy = getTerminalSize()
    cols = tuple_xy[0]
    rows = tuple_xy[1] - 3

    f = open(cur_file_dir()+'/servers.txt', 'r')
    serverlist = f.read().split('\n')
    serverlist.remove("")
    serverlist = list(set(serverlist))
    serverlist.sort()
    f.close()

    maxlen = 0
    minlen = 100000
    for item in serverlist:
        if len(item) > maxlen:
            maxlen = len(item)
        if len(item) < minlen:
            if len(item) != 0:
                minlen = len(item)

    if maxlen == minlen:
        maxlen += 2
    else:
        maxlen += 1

    maxlen += len(bcolors.WHITE)
    maxlen += len(bcolors.OKBLUE)
    maxlen += len("000) ")

    maxcols = cols/maxlen

    serverlength = len(serverlist)
    servercols = serverlength/rows + 1
    for j in range(0,rows):
        buf = ""
        for i in range(0,servercols):
            index = i*rows + j
            if index < serverlength:
                item = serverlist[index]
                prefix = "{0})".format(index).rjust(4)
                buf = buf + "{0}{1} {2}{3}".format(bcolors.WHITE,prefix,bcolors.OKBLUE,item).ljust(maxlen)
        print(buf)
def clearScreen():
    sysstr = platform.system()
    if sysstr == 'Darwin':
        i = os.system('clear')
    elif sysstr == 'Windows':
        i = os.system('cls')
    elif sysstr == 'Linux':
        i = os.system('clear')
def is_num_by_except(num):
    try:
        int(num)
        return True
    except ValueError:
        return False

while True:
    try:
        clearScreen()
        readData()
        serverid = raw_input("{0}type the number to enter the server:\n{1}".format(bcolors.GREEN,bcolors.ENDC))
        if serverid=="exit":
            break
        if is_num_by_except(serverid):
            if int(serverid)<len(serverlist):
                servername = serverlist[int(serverid)]
                clearScreen()
                print("%s Try to login to %s.............. %s" % (bcolors.RED,servername,bcolors.ENDC))
                time.sleep(0.2)
                os.system("ssh {0}".format(servername))
    except KeyboardInterrupt: 
        break
