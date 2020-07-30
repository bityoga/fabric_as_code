#!/usr/bin/python


def filter_enumerate(v):
    return list(enumerate(v))


class FilterModule (object):
    def filters(self):
        return {
            'enumerate': filter_enumerate,
        }