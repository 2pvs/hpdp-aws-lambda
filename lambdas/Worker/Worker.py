from libs import utils as ut
from libs import images as im

def lambda_handler(event, context):
    evt = ut.SQSEvent(event)
    queue = ut.Queue()
    for i, m in enumerate(evt.messages):
        msg = ut.QueueMessage(m)
        print(msg.message)
        source_file =  msg.read_obj_from_s3()
        dest_file = im.convert_jpeg(source_file)
        copy_status = msg.save_obj_to_s3(dest_file) 
        if copy_status:
            queue.delete_message(evt.receipt_handles[i])
        else:
            #if the message can not processed delete it from incoming queue and move it to DLQ
            print('Messaga processing failed: ', m, evt.receipt_handles[i])