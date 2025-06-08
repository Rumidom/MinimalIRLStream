import redis
from datetime import datetime
import time

#redis-15456.c308.sa-east-1-1.ec2.redns.redis-cloud.com
#15456
#streamingserver
#E-5X|?]B2:Cy0Lso]"_|PqlE*
#40c55ae70e20ccebe2d7e90343434180

class RedisController:
    def __init__(self, host, port, username, password,bbimgKey):

        self.r = redis.Redis(
            host=host,
            port=port,
            decode_responses=True,
            username=username,
            password=password,
        )
        self.bbimgKey  = bbimgKey
        self.p = self.r.pubsub()

    def initStremingServer(self):
        res_notify = self.r.config_set('notify-keyspace-events', 'KEA')
        print('res_notify: ',res_notify)
        self.p.psubscribe('__keyspace@0__:heartrates')
        self.p.psubscribe('__keyspace@0__:steps')
        self.p.psubscribe('__keyspace@0__:distance')
        self.p.psubscribe('__keyspace@0__:imMetaDataJson')
        res_bb = self.r.set('imgbbKey',self.bbimgKey)
        print('res_bb: ',res_bb)
        if res_notify and res_bb:
            return True
        else:
            return False
    
    def getImgJson(self):
        return self.r.hgetall('imMetaDataJson')
        
    def getData(self,key):
        return self.r.lrange(key,0,99)

    def getLastDataUpdate(self,key):
        l = self.r.lrange(key,0,0)
        if len(l) == 1:
            return l[0]
        return None
        
    def addData(self,l,data):
        if data.split(',')[1] != '0': #Proper fix later
            l.insert(0, data)
            if len(l) > 50:
                l.pop()

    def get_message(self):
        return self.p.get_message()
    
    def flushServer(self):
        return self.r.flushdb()
