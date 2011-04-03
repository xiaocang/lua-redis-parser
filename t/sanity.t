# vi:ft=

use strict;
use warnings;

use t::RedisParser;
plan tests => 1 * blocks();

run_tests();

__DATA__

=== TEST 1: no crlf in status reply
--- lua
parser = require("redis.parser")
reply = '+OK'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BAD_REPLY)
print("res == " .. res)
--- out
typ == 0 == 0
res == bad status reply



=== TEST 2: good status reply
--- lua
parser = require("redis.parser")
reply = '+OK\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.STATUS_REPLY)
print("res == " .. res)
--- out
typ == 1 == 1
res == OK



=== TEST 3: good error reply
--- lua
parser = require("redis.parser")
reply = '-Bad argument\rHey\r\nblah blah blah\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.ERROR_REPLY)
print("res == " .. res)
--- out eval
"typ == 2 == 2
res == Bad argument\rHey\n"



=== TEST 4: good integer reply
--- lua
parser = require("redis.parser")
reply = ':-32\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.INTEGER_REPLY)
print("res == " .. res)
print("res type == " .. type(res))
--- out
typ == 3 == 3
res == -32
res type == number



=== TEST 5: non-numeric integer reply
--- lua
parser = require("redis.parser")
reply = ':abc\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.INTEGER_REPLY)
print("res == " .. res)
print("res type == " .. type(res))
--- out
typ == 3 == 3
res == 0
res type == number



=== TEST 6: bad integer reply
--- lua
parser = require("redis.parser")
reply = ':12\r'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BAD_REPLY)
print("res == " .. res)
print("res type == " .. type(res))
--- out
typ == 0 == 0
res == bad integer reply
res type == string



=== TEST 7: good bulk reply
--- lua
parser = require("redis.parser")
reply = '$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 4 == 4
res == hello



=== TEST 8: good bulk reply (ignoring trailing stuffs)
--- lua
parser = require("redis.parser")
reply = '$5\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 4 == 4
res == hello



=== TEST 9: bad bulk reply (bad bulk size)
--- lua
parser = require("redis.parser")
reply = '$3b\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 0 == 4
res == bad bulk reply



=== TEST 10: bad bulk reply (bulk size too small)
--- lua
parser = require("redis.parser")
reply = '$3\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 0 == 4
res == bad bulk reply



=== TEST 11: bad bulk reply (bulk size too large)
--- lua
parser = require("redis.parser")
reply = '$6\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 0 == 4
res == bad bulk reply



=== TEST 12: bad bulk reply (bulk size too large, 2)
--- lua
parser = require("redis.parser")
reply = '$7\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 0 == 4
res == bad bulk reply



=== TEST 13: bad bulk reply (bulk size too large, 3)
--- lua
parser = require("redis.parser")
reply = '$8\r\nhello\r\nblah'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res == " .. res)
--- out
typ == 0 == 4
res == bad bulk reply



=== TEST 14: good bulk reply (nil value)
--- lua
parser = require("redis.parser")
reply = '$-1\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res", res)
--- out eval
"typ == 4 == 4
res\tnil\n"



=== TEST 15: good bulk reply (nil value, -25 size)
--- lua
parser = require("redis.parser")
reply = '$-25\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res", res)
--- out eval
"typ == 4 == 4
res\tnil\n"



=== TEST 16: bad bulk reply (nil value, -1 size)
--- lua
parser = require("redis.parser")
reply = '$-1\r'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res", res)
--- out eval
"typ == 0 == 4
res\tbad bulk reply\n"



=== TEST 17: bad bulk reply (nil value, -1 size)
--- lua
parser = require("redis.parser")
reply = '$-1\ra'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res", res)
--- out eval
"typ == 0 == 4
res\tbad bulk reply\n"



=== TEST 18: bad bulk reply (nil value, -1 size)
--- lua
parser = require("redis.parser")
reply = '$-1ab'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.BULK_REPLY)
print("res", res)
--- out eval
"typ == 0 == 4
res\tbad bulk reply\n"



=== TEST 19: good multi bulk reply (1 bulk)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*1\r\n$1\r\na\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 5 == 5
res == ["a"]\n}



=== TEST 20: good multi bulk reply (4 bulks)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*4\r\n$1\r\na\r\n$-1\r\n$0\r\n\r\n$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 5 == 5
res == ["a",null,"","hello"]\n}



=== TEST 21: bad multi bulk reply (4 bulks)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*4\r\n$1\r\na\r\n$-1\r\n$0\r\n\n$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 0 == 5
res == "bad multi bulk reply"\n}



=== TEST 22: bad multi bulk reply (4 bulks)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*6\r\n$1\r\na\r\n$-1\r\n$0\r\n\n$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 0 == 5
res == "bad multi bulk reply"\n}



=== TEST 23: bad multi bulk reply (4 bulks)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*6\n$1\r\na\r\n$-1\r\n$0\r\n\n$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 0 == 5
res == "bad multi bulk reply"\n}



=== TEST 24: bad multi bulk reply (4 bulks)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
reply = '*6$1\r\na\r\n$-1\r\n$0\r\n\n$5\r\nhello\r\n'
res, typ = parser.parse_reply(reply)
print("typ == " .. typ .. ' == ' .. parser.MULTI_BULK_REPLY)
print("res == " .. yajl.to_string(res))
--- out eval
qq{typ == 0 == 5
res == "bad multi bulk reply"\n}



=== TEST 25: build query (empty param table)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- err
empty input param table



=== TEST 26: build query (single param)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {'ping'}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*1\r\n$4\r\nping\r\n"



=== TEST 27: build query (single param)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {'get', 'one', '\r\n'}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*3\r\n$3\r\nget\r\n$3\r\none\r\n$2\r\n\r\n\r\n"



=== TEST 28: build query (empty param "")
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {''}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*1\r\n$0\r\n\r\n"



=== TEST 29: build query (empty param "")
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {''}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*1\r\n$0\r\n\r\n"



=== TEST 30: build query (nil param)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {parser.null}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*1\r\n$-1\r\n"



=== TEST 31: build query (numeric param)
--- lua
yajl = require('yajl')
parser = require("redis.parser")
q = {'set', 'foo', 3.1415926}
local query = parser.build_query(q)
print("query == " .. yajl.to_string(query))
--- out
query == "*3\r\n$3\r\nset\r\n$3\r\nfoo\r\n$9\r\n3.1415926\r\n"

