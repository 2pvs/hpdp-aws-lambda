from utils import utils as ut

def lambda_handler(event, context):
    evt = ut.S3Event(event)
    folder = ut.Folder(evt.bucket, evt.prefix)
    folder.list_objects()
    queue = ut.Queue()
    queue.push_objects(evt.bucket, folder.object_list)
    alarm = ut.EmptyReceivesAlarm()
    alarm.put()
    print(len(folder.object_list), ' objects pushed to queue. ')