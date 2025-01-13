from flet_core.constrained_control import ConstrainedControl
from typing import Optional

class BluetoothPrinter(ConstrainedControl):
    """
    蓝牙打印机控件
    """
    def __init__(
        self,
        address: Optional[str] = "",
        send_data: Optional[str] = "",
        start_scan: Optional[bool] = False,
        stop_scan: Optional[bool] = False,
        start_connect: Optional[bool] = False,
        close_connect: Optional[bool] = False,
        start_send: Optional[bool] = False,
        bluetooth_list: Optional[str] = "",
        connect_message: Optional[str] = "",
        connect_response: Optional[str] = "",
        data_response: Optional[str] = "",
        scan_message: Optional[str] = "",
        message_tag: Optional[str] = "",
        on_listener = None,
    ):
        ConstrainedControl.__init__(self)
        self.address = address
        self.send_data = send_data
        self.start_scan = start_scan
        self.stop_scan = stop_scan
        self.start_connect = start_connect
        self.close_connect = close_connect
        self.start_send = start_send
        self.bluetooth_list = bluetooth_list
        self.connect_message = connect_message
        self.connect_response = connect_response
        self.data_response = data_response
        self.scan_message = scan_message
        self.message_tag = message_tag
        self.on_listener = on_listener
        self.channel_name = str(id(self))
    
    def _get_control_name(self) -> str:
        return "bluetooth_printer"
    
    @property
    def address(self):
        return self._get_attr("address")

    @address.setter
    def address(self, value):
        self._set_attr("address", value)
    
    @property
    def send_data(self):
        return self._get_attr("send_data")

    @send_data.setter
    def send_data(self, value):
        self._set_attr("send_data", value)

    @property
    def start_scan(self):
        return self._get_attr("start_scan")

    @start_scan.setter
    def start_scan(self, value):
        self._set_attr("start_scan", value)

    @property
    def stop_scan(self):
        return self._get_attr("stop_scan")

    @stop_scan.setter
    def stop_scan(self, value):
        self._set_attr("stop_scan", value)
    
    @property
    def start_connect(self):
        return self._get_attr("start_connect")

    @start_connect.setter
    def start_connect(self, value):
        self._set_attr("start_connect", value)

    @property
    def close_connect(self):
        return self._get_attr("close_connect")

    @close_connect.setter
    def close_connect(self, value):
        self._set_attr("close_connect", value)

    @property
    def start_send(self):
        return self._get_attr("start_send")

    @start_send.setter
    def start_send(self, value):
        self._set_attr("start_send", value)

    @property
    def bluetooth_list(self):
        return self._get_attr("bluetooth_list")

    @bluetooth_list.setter
    def bluetooth_list(self, value):
        self._set_attr("bluetooth_list", value)

    @property
    def connect_message(self):
        return self._get_attr("connect_message")

    @connect_message.setter
    def connect_message(self, value):
        self._set_attr("connect_message", value)

    @property
    def connect_response(self):
        return self._get_attr("connect_response")

    @connect_response.setter
    def connect_response(self, value):
        self._set_attr("connect_response", value)

    @property
    def data_response(self):
        return self._get_attr("data_response")

    @data_response.setter
    def data_response(self, value):
        self._set_attr("data_response", value)

    @property
    def scan_message(self):
        return self._get_attr("scan_message")

    @scan_message.setter
    def scan_message(self, value):
        self._set_attr("scan_message", value)

    @property
    def message_tag(self):
        return self._get_attr("message_tag")

    @message_tag.setter
    def message_tag(self, value):
        self._set_attr("message_tag", value)
    
    @property
    def channel_name(self):
        return self._get_attr("channel_name")

    @channel_name.setter
    def channel_name(self, value):
        self._set_attr("channel_name", value)
    
    @property
    def on_listener(self):
        return self._get_event_handler("on_listener")

    @on_listener.setter
    def on_listener(self, handler):
        self._add_event_handler("on_listener", handler)
    
    def scan(self):
        self._set_attr("start_scan", True)
    
    def stop(self):
        self._set_attr("stop_scan", True)
    
    def connect(self, address):
        self._set_attr("address", address)
        self._set_attr("start_connect", True)
    
    def close(self):
        self._set_attr("close_connect", True)
    
    def send(self, send_data):
        self._set_attr("send_data", send_data)
        self._set_attr("start_send", True)