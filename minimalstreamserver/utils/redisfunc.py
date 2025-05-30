import redis
from datetime import datetime
import time

r = redis.Redis(
    host='redis-15456.c308.sa-east-1-1.ec2.redns.redis-cloud.com',
    port=15456,
    decode_responses=True,
    username="streamingserver",
    password='E-5X|?]B2:Cy0Lso]"_|PqlE*',
)
r.config_set('notify-keyspace-events', 'KEA')
p = r.pubsub()
p.psubscribe('__keyspace@0__:heartrates')
p.psubscribe('__keyspace@0__:steps')
p.psubscribe('__keyspace@0__:distance')
p.psubscribe('__keyspace@0__:imMetaDataJson')

bbimgKey  = "40c55ae70e20ccebe2d7e90343434180"

def setbbimgKey():
    r.set('imgbbKey',bbimgKey)

def getImgJson():
    return r.hgetall('imMetaDataJson')
    
def getData(r,key):
    return r.lrange(key,0,99)

def getLastDataUpdate(r,key):
    l = r.lrange(key,0,0)
    if len(l) == 1:
        return l[0]
    return None
    
def addData(l,data):
    if data.split(',')[1] != '0': #Fix later
        l.insert(0, data)
        if len(l) > 99:
            l.pop()

def flushServer():
    return r.flushdb()
