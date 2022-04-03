import os

def execOne(command):
    cmd = os.popen(command)
    line = cmd.read()
    cmd.close()
    return line.strip()