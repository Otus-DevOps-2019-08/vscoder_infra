#!/usr/bin/env python3

__author__ = 'Aleksey Koloskov'
__author_email__ = 'vsyscoder@yandex.ru'

import os
import sys
import argparse
import json
import logging


def main():
    parser = argparse.ArgumentParser(
        description=f"""Read json file and print them content to stdout.
        Author: {__author__} <{__author_email__}>""",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--json-file', default=os.path.join(os.path.dirname(__file__), "inventory.json"),
                        help='path to dynamic json-inventory file')
    parser.add_argument('-l', '--list', action='store_true',
                        help='print json content to stdout')
    parser.add_argument('--host', help='print single host variables')
    parser.add_argument('-d', '--debug', action='store_true',
                        help='print debug messages')
    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.WARNING)

    logging.info("Read json-file '%s'", args.json_file)
    try:
        with open(args.json_file) as json_file:
            json_data = json.load(json_file)
    except json.decoder.JSONDecodeError as e:
        logging.error("Error decoding json-file '%s': %s", args.json_file, e)
        sys.exit(10)

    if args.list:
        logging.debug("Print inventory")
        print(json.dumps(json_data))
        sys.exit(0)

    if args.host:
        logging.debug("Print host variables for '%s'", args.host)
        # TODO: print also variables inherited from groupvars
        print(json.dumps(json_data.get("_meta", {}).get(
            "hostvars", {}).get(args.host, {})))
        sys.exit(0)

    logging.critical(
        "One of arguments '--list' or '--host' must be specified")
    sys.exit(20)


if __name__ == '__main__':
    main()
