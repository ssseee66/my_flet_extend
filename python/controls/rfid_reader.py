from flet_core.constrained_control import ConstrainedControl
from typing import Optional
import binascii

class RfidReader(ConstrainedControl):
    """
    RfidReader 控件
    """

    def __init__(
        self,
        message_tag: Optional[str] = "",
        epc_data: Optional[str] = "",
        epc_data_area: Optional[int] = 0,
        start_connect: Optional[bool] = False,
        # close_connect: Optional[bool] = False,
        turn_on_power: Optional[bool] = False,
        turn_off_power: Optional[bool] = False,
        start_reader: Optional[bool] = False,
        start_reader_epc: Optional[bool] = False,
        start_write_epc: Optional[bool] = False,
        connect_message: Optional[str] = "",
        power_message: Optional[str] = "",
        epc_messages: Optional[str] = "",
        write_epc_message: Optional[str] = "",
        reader_operation_message: Optional[str] = "",
        on_listener = None,
    ):
        ConstrainedControl.__init__(self)
        self.start_connect = start_connect     # 设备连接标志
        # self.close_connect = close_connect     # 断开设备连接标志
        self.turn_on_power = turn_on_power     # 设备上电标志
        self.turn_off_power = turn_off_power   # 设备下电标志
        self.start_reader = start_reader   # 启动读写器读卡标志
        self.start_reader_epc = start_reader_epc    # 读取epc标签数据标志
        self.connect_message = connect_message    # 连接设备时返回的提示信息
        self.power_message = power_message   # 设备上下电信息
        self.epc_messages = epc_messages    # 单次盘点所获取的epc标签数据
        self.reader_operation_message = reader_operation_message    # 启动读写器读卡返回的信息
        self.on_listener = on_listener     # 用于监听Android端发送过来的信息事件方法
        self.message_tag = message_tag    # 用于甄别Android端发送过来的信息是何种类型
        self.epc_data = epc_data           # 需要向标签写入的数据（仅限于十六进制）在输入的时候进行限制较为简单
        self.epc_data_area = epc_data_area     #  写入数据的区域
        self.start_write_epc = start_write_epc    #  进行写卡的标志
        self.write_epc_emssage = write_epc_message   #  写卡时返回过来的信息

    def _get_control_name(self) -> str:
        return "rfid_reader"


    
    @property
    def start_connect(self):
        return self._get_attr("start_connect")

    @start_connect.setter
    def start_connect(self, value):
        self._set_attr("start_connect", value)

    # @property
    # def close_connect(self):
    #     return self._get_attr("close_connect")

    # @close_connect.setter
    # def close_connect(self, value):
    #     self._set_attr("close_connect", value)
    
    @property
    def turn_on_power(self):
        return self._get_attr("turn_on_power")

    @turn_on_power.setter
    def turn_on_power(self, value):
        self._set_attr("turn_on_power", value)
    
    @property
    def turn_off_power(self):
        return self._get_attr("turn_off_power")

    @turn_off_power.setter
    def turn_off_power(self, value):
        self._set_attr("turn_off_power", value)

    @property
    def start_reader(self):
        return self._get_attr("start_reader")

    @start_reader.setter
    def start_reader(self, value):
        self._set_attr("start_reader", value)

    @property
    def start_reader_epc(self):
        return self._get_attr("start_reader_epc")

    @start_reader_epc.setter
    def start_reader_epc(self, value):
        self._set_attr("start_reader_epc", value)

    @property
    def connect_message(self):
        return self._get_attr("connect_message")

    @connect_message.setter
    def connect_message(self, value):
        self._set_attr("connect_message", value)

    @property
    def epc_messages(self):
        return self._get_attr("epc_messages")

    @epc_messages.setter
    def epc_messages(self, value):
        self._set_attr("epc_messages", value)
    
    @property
    def power_message(self):
        return self._get_attr("power_message")

    @power_message.setter
    def power_message(self, value):
        self._set_attr("power_message", value)
    
    @property
    def reader_operation_message(self):
        return self._get_attr("reader_operation_message")

    @reader_operation_message.setter
    def reader_operation_message(self, value):
        self._set_attr("reader_operation_message", value)

    @property
    def on_listener(self):
        return self._get_event_handler("on_listener")

    @on_listener.setter
    def on_listener(self, handler):
        self._add_event_handler("on_listener", handler)
        # self._set_attr("start_listener", True if handler is not None else None)
    @property
    def message_tag(self):
        return self._get_attr("message_tag")

    @message_tag.setter
    def message_tag(self, value):
        self._set_attr("message_tag", value)

    @property
    def epc_data(self):
        return self._get_attr("epc_data")

    @epc_data.setter
    def epc_data(self, value):
        self._set_attr("epc_data", value)
    
    @property
    def start_write_epc(self):
        return self._get_attr("start_write_epc")

    @start_write_epc.setter
    def start_write_epc(self, value):
        self._set_attr("start_write_epc", value)
    
    @property
    def epc_data_area(self):
        return self._get_attr("epc_data_area")

    @epc_data_area.setter
    def epc_data_area(self, value):
        self._set_attr("epc_data_area", value)

    @property
    def write_epc_message(self):
        return self._get_attr("write_epc_message")

    @write_epc_message.setter
    def write_epc_message(self, value):
        self._set_attr("write_epc_message", value)
    
    def connect(self):
        self._set_attr("start_connect", True)
    
    def turn_on(self):
        self._set_attr("turn_on_power", True)
    
    def turn_off(self):
        self._set_attr("turn_off_power", True)
    
    def reader(self):
        self._set_attr("start_reader", True)
    
    def reader_epc(self):
        self._set_attr("start_reader_epc", True)
    
    def write_epc(self, epc_data_area, epc_data):
        epc_data = binascii.hexlify(epc_data.encode("utf-8")).decode("utf-8")    #  转换为十六进制
        self._set_attr("epc_data", epc_data)
        self._set_attr("epc_data_area", epc_data_area)
        self._set_attr("start_write_epc", True)


