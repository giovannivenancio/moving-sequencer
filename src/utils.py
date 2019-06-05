from __future__ import division

import zmq
import psutil

def create_conn(model, role, ip, port):
    """Creates connections based on ZMQ Message Patterns."""

    socket = None
    context = zmq.Context()

    if model == 'client_server':
        socket = context.socket(zmq.REP)

        if role == 'server':
            if ip:
                socket.bind("tcp://%s:%s" % (ip, port))
            else:
                socket.bind("tcp://*:%s" % port)

    elif model == 'pair':
        socket = context.socket(zmq.PAIR)

        if role == 'server':

            if ip:
                socket.bind("tcp://%s:%s" % (ip, port))
            else:
                print "binding on port", port
                socket.bind("tcp://*:%s" % port)

        elif role == 'client':
            socket.connect("tcp://%s:%s" % (ip, port))

    return socket

class Performance():
    """
    This class uses bandiwdth snapshots to generate performance results.
    eval_bandwidth returns:

    traffic_in: total traffic received in mbits over 'time_interval' seconds;
    traffic_out: total traffic sent in mbits over 'time_interval' seconds;
    traffic_in_avg: average traffic received in mbits/s over all replicas;
    traffic_out_avg: average traffic sent in mbits/s over all replicas;
    traffic_in_avg per replica: average traffic received in mbits/s per replica;
    traffic_out_avg per replica: average traffic sent in mbits/s per replica;
    packet_in: total number of packets received over 'time_interval' seconds;
    packet_out: total number of packets sent over 'time_interval' seconds;
    packet_in_avg per replica: average number of packets received per replica;
    packet_out_avg per replica: average number of packets sent per replica;
    """

    def __init__(self):
        pass

    def get_bandwidth_snapshot(self):
        """Create a bandwidth snapshot."""

        return {
            'net_in': psutil.net_io_counters(pernic=True)['docker0'].bytes_recv,
            'net_out': psutil.net_io_counters(pernic=True)['docker0'].bytes_sent,
            'packet_in': psutil.net_io_counters(pernic=True)['docker0'].packets_recv,
            'packet_out': psutil.net_io_counters(pernic=True)['docker0'].packets_sent
        }

    def eval_bandwidth(self, snap_ini, snap_final, time_interval, num_replicas):
        """Generate performance results based on two snapshots metrics."""

        if num_replicas == 0:
            num_replicas = 1

        # Compare and get current speed
        if snap_ini['net_in'] > snap_final['net_in']:
            current_in = 0
            packet_in = 0
        else:
            current_in = snap_final['net_in'] - snap_ini['net_in']
            packet_in = snap_final['packet_in'] - snap_ini['packet_in']

        if snap_ini['net_out'] > snap_final['net_out']:
            current_out = 0
            packet_out = 0
        else:
            current_out = snap_final['net_out'] - snap_ini['net_out']
            packet_out = snap_final['packet_out'] - snap_ini['packet_out']

        current_in = current_in/1000 #kbytes
        current_in = current_in/1000 #mbytes
        current_in = current_in*8    #mbits

        current_out = current_out/1000 #kbytes
        current_out = current_out/1000 #mbytes
        current_out = current_out*8    #mbits

        current_in_avg = current_in/time_interval
        current_out_avg = current_out/time_interval

        packet_in_avg = packet_in/time_interval
        packet_out_avg = packet_out/time_interval

        in_avg_per = current_in_avg/num_replicas
        out_avg_per = current_out_avg/num_replicas

        packet_in_per = packet_in_avg/num_replicas
        packet_out_per = packet_out_avg/num_replicas

        print 'traffic_in: %s mbits in %s seconds' % (current_in, time_interval)
        print 'traffic_out: %s mbits in %s seconds' % (current_out, time_interval)
        print 'traffic_in_avg: %s mbits/s' % current_in_avg
        print 'traffic_out_avg: %s mbits/s' % current_out_avg
        print 'traffic_in_avg per replica: %s mbits/s' % in_avg_per
        print 'traffic_out_avg per replica: %s mbits/s' % out_avg_per
        print 'packet_in: %s packets in %s seconds' % (packet_in, time_interval)
        print 'packet_out: %s packets in %s seconds' % (packet_out, time_interval)
        print 'packet_in_avg per replica: %s packets/s' % packet_in_per
        print 'packet_out_avg per replica: %s packets/s' % packet_out_per
