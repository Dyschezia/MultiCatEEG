function send_triggerIO64(condition)
%config_io
ioObj = io64;
status = io64(ioObj);
address = hex2dec('3FE0');
io64(ioObj, address, condition);
%data_out=0;
WaitSecs(.01);  
io64(ioObj, address, 0);
