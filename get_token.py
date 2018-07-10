#!/usr/bin/env python2
# -*- coding: utf-8 -*-
######################################################################
#  ###  ###  ###  ###  #   # ###  ##### #### ####    ###  ###  ###   #
# #    #   # #  # #  # #   # #  #   #   #___ #   #   #  # #  #   #   #
# #    #   # ###  ###  #   # ###    #   #    #   #   ###  ###    #   #
#  ###  ###  #  # #  #  ###  #      #   #### ####    #    #  # ##  # #
######################################################################
#   Corrupted Prj.                                                   #
#   Copyright (c) 2017 <corruptedproject@yandex.ru>                  #
#   Contributors: Mathtin, Plaguedo                                  #
#   This file is released under the MIT license.                     #
######################################################################

__author__ = "Mathtin, Plaguedo"
__date__ = "$5.07.2018 03:11:27$"

import hmac, hashlib, sys, imp
import mysql.connector as mysql
wrk = imp.load_source('worker', 'worker/app.py')

def calc_token(key, usr):
    token = hmac.new(str(key), str(usr), hashlib.sha256)
    return token.hexdigest()

def main(argv):
    if len(sys.argv) != 2:
        print "USAGE: get_token.py username" 
        return
    username   = sys.argv[1]
    configfile = 'worker/main.cnf'
    cnf = wrk.read_config(configfile)
    try:
        cnx = mysql.connect(user=cnf['mysql_username'], 
                            password=cnf['mysql_password'],
                            host=cnf['mysql_host'],
                            port=cnf['mysql_port'],
                            database=cnf['mysql_database'])
    except mysql.Error as e:
        print e
        return
    cursor = cnx.cursor()
    query = ('SELECT password FROM users WHERE username = \'root\'')
    cursor.execute(query)
    key = list(cursor)[0][0]
    print calc_token(key, username)
    cursor.close()
    cnx.close()



if __name__ == "__main__":
    main(sys.argv)
