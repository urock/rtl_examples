import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

CLK_PERIOD = 20000

@cocotb.coroutine
def reset(dut):
   dut.reset = 1
   yield Timer(CLK_PERIOD*10)
   dut.reset = 0

@cocotb.test()
def my_first_test(dut):
   dut.log.info("Running test")
   cocotb.fork(Clock(dut.clk, CLK_PERIOD).start())
   yield reset(dut)
   yield Timer(CLK_PERIOD*100)
