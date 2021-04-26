from libs import utils as ut

def lambda_handler(event, context):
    #process s3 event to launch
    evt = ut.S3Event(event)
    folder = ut.Folder(evt.bucket, evt.prefix)
    #list all objects within an s3 profix
    folder.list_objects()
    queue = ut.Queue()
    #push object to process to SQS queue
    queue.push_objects(evt.bucket, folder.object_list)
    alarm = ut.EmptyReceivesAlarm()
    #put CloudWatch alarm to trigger when processing is complete
    alarm.put()
    print(len(folder.object_list), ' objects pushed to queue. ')