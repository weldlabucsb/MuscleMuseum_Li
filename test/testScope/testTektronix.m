rName = 'USB0::0x0699::0x03B4::C011351::0::INSTR';
s = TekTronix1104(rName,"LatticeScope");
s.connect;

% s = oscilloscope();
% set(s, 'Resource', rName);
% connect(s)
