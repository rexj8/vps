# https://docs.python.org/3/library/getopt.html
import os
import json
import sys

path = sys.argv[-1] + "knockpy_report/"
# path_py = os.path.join(os.path.expanduser('~'),path_py)
# path_py = os.path.join(path_py)

# print(dir_list[0])
# print(path)
# print(sys.argv[-1])


if sys.argv[-1] == '-h' or sys.argv[-1] == '-help' or sys.argv[-1] == '--help':
    print("Example:")
    print("     python3 knockpyscript.py -h")
    print("     python3 knockpyscript.py -sub ~/geotab/lat-lon")
    print("     python3 knockpyscript.py -ip ~/geotab/lat-lon")
    print("")
    print("Flags:")
    print("     -h: help")
    print("     -sub: for parsing Subdomains from knockpy_report")
    print("     -ip: for parsing IPs from knockpy_report")


elif sys.argv[1] == '-sub':
    dir_list = os.listdir(path)
    for fl in dir_list:
        file = path + fl
        with open(file, "r") as read_it:
            parser=""
            for i in read_it.readlines():
                parser+=i 
            JsonMap = eval(parser)

            for key in JsonMap.keys():
                if key == '_meta':
                    quit()
                print(key)


elif sys.argv[1] == '-ip':
    dir_list = os.listdir(path)
    for fl in dir_list:
        file = path + fl
        with open(file, "r") as read_it:
            parser=""
            for i in read_it.readlines():
                parser+=i 
            JsonMap = eval(parser)

            # print(JsonMap['calendar.mapsbi.com']['ipaddr'])

            for key in JsonMap.keys():
                if key == '_meta':
                    quit()

                for ip in JsonMap[key]['ipaddr']:
                    print(ip)