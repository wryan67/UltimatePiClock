import os

def execOne(command):
    cmd = os.popen(command)
    line = cmd.read()
    cmd.close()
    return line.strip()

def getHome():
    return execOne("awk -F: '{if($1==\"" + os.getlogin() + "\")print $6}' /etc/passwd")
