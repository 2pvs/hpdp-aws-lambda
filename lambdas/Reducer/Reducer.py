from libs import utils as ut

def lambda_handler(event, context):
    #function triggered on NumberOfEmptyReceives alarm
    evt = ut.CWAlarm(event)
    queue = ut.Queue()
    alarm = ut.EmptyReceivesAlarm()
    #Check if the queue is really empty
    if queue.check_empty():
        alarm.delete()
        print('Reducer job complete')
    else:
        #if queue is not empty, reset the alarm and wait for next trigger
        alarm.reset()
        print('Reset alarm')