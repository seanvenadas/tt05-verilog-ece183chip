import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.coroutine
def initialize_clock(dut):
    clock = Clock(dut.clk, 10, units="ns") 
    cocotb.fork(clock.start())

@cocotb.coroutine
def tt_um_seanvenadas_tb(dut):
    yield initialize_clock(dut)

    dut.ui_in <= 8'b00000000;
    dut.ena <= 0
    dut.rst_n <= 1

    yield RisingEdge(dut.clk)
    dut.rst_n <= 0
    yield RisingEdge(dut.clk)
    dut.rst_n <= 1

    # Test when p is not 2'b11
    dut.ui_in <= 8'b00000000;
    yield RisingEdge(dut.clk)
    assert dut.uo_out == 8'b00000000, "Output signals should be zero when p is not 2'b11"
    yield RisingEdge(dut.clk)

    # Test when p is 2'b11
    dut.ui_in <= 8'b11000000;
    yield RisingEdge(dut.clk)
    assert dut.uo_out != 8'b00000000, "Output signals should not be zero when p is 2'b11"
    yield RisingEdge(dut.clk)
    
tf = TestFactory(tt_um_seanvenadas_tb)

tf.generate_tests("tt_um_seanvenadas")

tf.generate_tests()
